#!perl
#---------------------------------------------------------------------
# $Id: Makefile.PL,v 1.3 1996/02/08 20:10:51 Madsen Exp $
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
                PREOP => 'toix $(DISTVNAME)' # Converts CRLF to LF
                },
);
