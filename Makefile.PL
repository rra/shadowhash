# Makefile.PL for Tie::ShadowHash module  -*- perl -*-
# $Id$

use ExtUtils::MakeMaker;

WriteMakefile (
    NAME         => 'Tie::ShadowHash',
    DISTNAME     => 'ShadowHash',
    ($] >= 5.005 ?
     (ABSTRACT   => 'Merge multiple data sources into a hash',
      AUTHOR     => 'Russ Allbery (rra@stanford.edu)') : ()),
    VERSION_FROM => 'ShadowHash.pm',
    dist         => { COMPRESS => 'gzip', SUFFIX => 'gz' }
);
