#!perl
#---------------------------------------------------------------------
# $Id: Makefile.PL,v 1.2 1996/02/08 19:19:39 Madsen Exp $
# Copyright 1996 Christopher J. Madsen
#
# Makefile.PL for Getopt::Mixed
#---------------------------------------------------------------------

use ExtUtils::MakeMaker;
require './lib/Getopt/Mixed.pm'; # To get the current version number

WriteMakefile(
    NAME     => 'Getopt::Mixed',
    DISTNAME => 'Getopt-Mixed',
    linkext  => {LINKTYPE => ''}, # not needed for MakeMakers gt '5.00'
    VERSION  => $Getopt::Mixed::VERSION,
    dist     => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
);
