# Tie::ShadowHash -- Merge multiple data sources into a hash.  -*- perl -*-
# $Id$
#
# Copyright 1999 by Russ Allbery <rra@stanford.edu>
#
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# This module combines multiple sources of data into a single tied hash, so
# that they can all be queried simultaneously, the source of any given
# key-value pair irrelevant to the client script.  Data sources are searched
# in the order that they're added to the shadow hash.  Changes to the hashed
# data aren't propagated back to the actual data files; instead, they're
# saved within the tied hash and override any data obtained from the data
# sources.

############################################################################
# Modules and declarations
############################################################################

package Tie::ShadowHash;
require 5.003;

use strict;
use vars qw($VERSION);

# The version of this module is its CVS revision.
($VERSION = (split (' ', q$Revision$ ))[1]) =~ s/\.(\d)$/.0$1/;


############################################################################
# Regular methods
############################################################################

# This should pretty much never be called; tie calls TIEHASH.
sub new { my $class = shift; $class->TIEHASH (@_) }

# Given a file name and optionally a split regex, builds a hash out of the
# contents of the file.  If the split sub exists, use it to split each line
# into an array; if the array has two elements, those are taken as the key
# and value.  If there are more, the value is an anonymous array containing
# everything but the first.  If there's no split sub, take the entire line
# modulo the line terminator as the key and the value the number of times it
# occurs in the file.
sub text_source {
    my ($self, $file, $split) = @_;
    unless (open (HASH, "< $file\0")) {
        require Carp;
        Carp::croak ("can't open file $file: $!");
    }
    local $_;
    my ($key, @rest, %hash);
    while (<HASH>) {
        chomp;
        if (defined $split) {
            ($key, @rest) = &$split ($_);
            $hash{$key} = (@rest == 1) ? $rest[0] : [ @rest ];
        } else {
            $hash{$_}++;
        }
    }
    close HASH;
    return \%hash;
}

# Add data sources to the shadow hash.  This takes a list of either
# anonymous arrays (in which case the first element is the type of source
# and the rest are arguments), filenames (in which case it's taken to be a
# text file with each line being a key), or hash references (possibly to
# tied hashes).
sub add {
    my $self = shift;
    for (@_) {
        my $source = $_;
        if (ref $source eq 'ARRAY') {
            my ($type, @args) = @$source;
            if ($type eq 'text') {
                $source = $self->text_source (@args);
            } else {
                require Carp;
                Carp::croak ("Invalid source type $type");
            }
        } elsif (!ref $source) {
            $source = $self->text_source ($source);
        }
        push (@{$$self{SOURCES}}, $source);
    }
    1;
}


############################################################################
# Tie methods
############################################################################

sub TIEHASH {
    my $class = shift;
    $class = ref $class || $class;
    my $self = {
        DELETED  => {},
        EACH     => -1,
        OVERRIDE => {},
        SOURCES  => []
    };
    bless ($self, $class);
    $self->add (@_) if @_;
    $self;
}

sub FETCH {
    my ($self, $key) = @_;
    return if $$self{DELETED}{$key};
    for ($$self{OVERRIDE}, @{$$self{SOURCES}}) {
        return $$_{$key} if defined $$_{$key};
    }
    undef;
}

sub STORE {
    delete $_[0]{DELETED}{$_[1]};
    $_[0]{OVERRIDE}{$_[1]} = $_[2];
}

sub DELETE {
    delete $_[0]{OVERRIDE}{$_[1]};
    $_[0]{DELETED}{$_[1]} = 1;
}

sub CLEAR {
    my $self = shift;
    $$self{DELETED} = {};
    $$self{OVERRIDE} = {};
    $$self{SOURCES} = [];
    $$self{EACH} = -1;
}

sub EXISTS {
    my ($self, $key) = @_;
    return if exists $$self{DELETED}{$key};
    for ($$self{OVERRIDE}, @{$$self{SOURCES}}) {
        return 1 if exists $$_{$key};
    }
    undef;
}

sub FIRSTKEY {
    my $self = shift;
    scalar keys %{$$self{OVERRIDE}};
    for (@{$$self{SOURCES}}) {
        my $tie = tied $_;
        if ($tie) { $tie->FIRSTKEY } else { scalar keys %$_ }
    }
    $$self{EACH} = -1;
    $self->NEXTKEY;
}

sub NEXTKEY {
    my $self = shift;
    my @result = ();
    while (!@result && $$self{EACH} < @{$$self{SOURCES}}) {
        if ($$self{EACH} == -1) {
            @result = each %{$$self{OVERRIDE}};
        } else {
            @result = each %{$$self{SOURCES}[$$self{EACH}]};
        }
        return (wantarray ? @result : $result[0]) if @result;
        $$self{EACH}++;
    }
    undef;
}
