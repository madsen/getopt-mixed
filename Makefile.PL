#!perl
#---------------------------------------------------------------------
# $Id: Makefile.PL,v 1.4 2005/01/15 17:11:11 Madsen Exp $
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
    dist     => {COMPRESS => 'gzip -9f', SUFFIX => 'gz',
# This next line is just for my own use, you can comment it out if you want:
                PREOP => 'cjm_fixup $(DISTVNAME)' # Converts CRLF to LF
                },
);
