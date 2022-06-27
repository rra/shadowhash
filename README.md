# Tie::ShadowHash

[![Build
status](https://github.com/rra/shadowhash/workflows/build/badge.svg)](https://github.com/rra/shadowhash/actions)
[![CPAN
version](https://img.shields.io/cpan/v/Tie-ShadowHash)](https://metacpan.org/release/Tie-ShadowHash)
[![License](https://img.shields.io/cpan/l/Tie-ShadowHash)](https://github.com/rra/shadowhash/blob/master/LICENSE)
[![Debian
package](https://img.shields.io/debian/v/libtie-shadowhash-perl/unstable)](https://tracker.debian.org/pkg/libtie-shadowhash-perl)

Copyright 1999, 2002, 2010, 2022 Russ Allbery <rra@cpan.org>.  This
software is distributed under the same terms as Perl itself.  Please see
the section [License](#license) below for more information.

## Blurb

Tie::ShadowHash is a Perl module that lets you stack together multiple
hash-like data structures, including tied hashes such as DB_File databases
or text files parsed into a hash, and then treat them like a merged hash.
Lookups are handled in the order of the added sources.  You can store
additional values, change values, and delete values from the hash and
those actions will be reflected in later operations, but the underlying
objects are not changed.

## Description

If you have a bunch of key/value data sources in the form of Perl hashes,
tied hashes (of whatever type, including on-disk databases tied with
DB_File, GDBM_File, or similar modules), or text files that you want to
turn into hashes, and you want to be able to query all of those sources of
data at once for a particular key without having to check each one of them
individually, this module may be what you're looking for.  If you want to
use a hash-like data source, even just one, but make modifications to its
data over the course of your program that override its contents while your
program runs but which don't have any permanent effect on it, this module
may be what you're looking for.

Tie::ShadowHash lets you create a "shadow hash" that looks like a regular
Perl hash to your program but behind the scenes queries a whole list of
data sources.  All the data sources underneath have to also behave like
Perl hashes, but that's the only constraint.  They can be regular Perl
hashes or other tied hashes, including tied DB_File or GDBM_File hashes or
the like to access on-disk databases.  All data sources are treated as
read-only; modifications to any data is stored in the shadow hash itself,
and subsequent accesses reflect any modifications, but none of the data
sources are changed.

## Requirements

The only requirement for this module is Perl 5.006 or later.

## Building and Installation

Tie::ShadowHash uses ExtUtils::MakeMaker and can be installed using the
same process as any other ExtUtils::MakeMaker module:

```
    perl Makefile.PL
    make
    make install
```

You'll probably need to do the last as root unless you're installing into
a local Perl module tree in your home directory.

## Testing

Tie::ShadowHash comes with a test suite, which you can run after building
with:

```
    make test
```

If a test vails, you can run a single test with verbose output via:

```
    prove -vb <path-to-test>
```

The following additional Perl modules will be used by the test suite if
present:

* Devel::Cover
* Perl::Critic::Freenode
* Test::CPAN::Changes (part of CPAN-Changes)
* Test::Kwalitee
* Test::MinimumVersion
* Test::Perl::Critic
* Test::Pod
* Test::Pod::Coverage
* Test::Spelling
* Test::Strict
* Test::Synopsis

To enable tests that don't detect functionality problems but are used to
sanity-check the release, set the environment variable `RELEASE_TESTING`
to a true value.  To enable tests that may be sensitive to the local
environment or that produce a lot of false positives without uncovering
many problems, set the environment variable `AUTHOR_TESTING` to a true
value.

## Thanks

To Chris Nandor <pudge@pobox.com> for testing this module on the Mac,
pointing out that SDBM_File wasn't available there, mentioning that SDBM
was byte-order-dependent anyway, and suggesting using AnyDBM_File instead.

## Support

The [Tie::ShadowHash web
page](https://www.eyrie.org/~eagle/software/shadowhash/) will always have
the current version of this package, the current documentation, and
pointers to any additional resources.

For bug tracking, use the [issue tracker on
GitHub](https://github.com/rra/shadowhash/issues).  However, please be
aware that I tend to be extremely busy and work projects often take
priority.  I'll save your report and get to it as soon as I can, but it
may take me a couple of months.

## Source Repository

Tie::ShadowHash is maintained using Git.  You can access the current
source on [GitHub](https://github.com/rra/shadowhash) or by cloning the
repository at:

https://git.eyrie.org/git/perl/shadowhash.git

or [view the repository on the
web](https://git.eyrie.org/?p=perl/shadowhash.git).

The eyrie.org repository is the canonical one, maintained by the author,
but using GitHub is probably more convenient for most purposes.  Pull
requests are gratefully reviewed and normally accepted.

## License

The Tie::ShadowHash package as a whole is covered by the following
copyright statement and license:

> Copyright 1999, 2002, 2010, 2022
>     Russ Allbery <rra@cpan.org>
>
> This program is free software; you may redistribute it and/or modify it
> under the same terms as Perl itself.  This means that you may choose
> between the two licenses that Perl is released under: the GNU GPL and the
> Artistic License.  Please see your Perl distribution for the details and
> copies of the licenses.

Some files in this distribution are individually released under different
licenses, all of which are compatible with the above general package
license but which may require preservation of additional notices.  All
required notices, and detailed information about the licensing of each
file, are recorded in the LICENSE file.

Files covered by a license with an assigned SPDX License Identifier
include SPDX-License-Identifier tags to enable automated processing of
license information.  See https://spdx.org/licenses/ for more information.

For any copyright range specified by files in this package as YYYY-ZZZZ,
the range specifies every single year in that closed interval.
