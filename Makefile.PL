#! /usr/bin/perl
#---------------------------------------------------------------------
# $Id: Makefile.PL,v 1.4 2005/01/15 17:11:11 Madsen Exp $
# Copyright 2007 Christopher J. Madsen
#
# Makefile.PL for Getopt::Mixed
#---------------------------------------------------------------------

use ExtUtils::MakeMaker;

my @PREOP;

my $fixup = ($^O =~ /Win32/ ? 'cjm_fixup.bat' : './cjm_fixup.sh');

if (-e $fixup) {
  @PREOP = (PREOP => "$fixup \$(DISTVNAME)");
}

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
                 @PREOP },
);
