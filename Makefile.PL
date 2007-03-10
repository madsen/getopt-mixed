#! /usr/bin/perl
#---------------------------------------------------------------------
# $Id: Makefile.PL,v 1.4 2005/01/15 17:11:11 Madsen Exp $
# Copyright 1996 Christopher J. Madsen
#
# Makefile.PL for Getopt::Mixed
#---------------------------------------------------------------------

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Getopt::Mixed',
    AUTHOR              => 'Christopher J. Madsen <perl@cjmweb.net>',
    VERSION_FROM        => 'lib/Getopt/Mixed.pm',
    ABSTRACT_FROM       => 'lib/Getopt/Mixed.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist     => {COMPRESS => 'gzip -9f', SUFFIX => 'gz',
# This next line is just for my own use, you can comment it out if you want:
                PREOP => 'cjm_fixup $(DISTVNAME)' # Converts CRLF to LF
                },
);
