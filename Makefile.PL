#!perl
#---------------------------------------------------------------------
# $Id: Makefile.PL,v 1.1 1996/02/03 04:13:35 Madsen Exp $
# Copyright 1996 Christopher J. Madsen
#
# Makefile.PL for Getopt::Mixed
#---------------------------------------------------------------------

use ExtUtils::MakeMaker;
require './Getopt/Mixed.pm';    # To get the current version number

# Avoid creating auto/... directories:
sub MY::top_targets {
    my $self = shift;
    my $text = $self->MM::top_targets(@_);
    $text =~ s|^config :: \$\(INST[A-Z_]+AUTODIR\)/\.exists *|config :: |gm;
    $text =~ s/^config :: *\n+//gm;
    $text;
}

# Avoid creating auto/... directories:
sub MY::installpm {
    my $self = shift;
    my $text = $self->MM::installpm(@_);
    $text =~ s|\$\(INST[A-Z_]+AUTODIR\)/\.exists *||g;
    $text =~ s|^\t.+\$\(INST[A-Z_]+AUTODIR\)/\.packlist.*\n||gm;
    $text;
}

WriteMakefile(
        NAME => 'Getopt::Mixed',
        DISTNAME => 'Getopt-Mixed',
        installpm => {SPLITLIB=>''}, # Nothing to autosplit
        linkext => {LINKTYPE => ''}, # not needed for MakeMakers gt '5.00'
        MAN3PODS => { 'Getopt/Mixed.pm' => '$(INST_MAN3DIR)/Getopt.Mixed.3' },
        PM => { 'Getopt/Mixed.pm' => '$(INST_LIB)/Getopt/Mixed.pm' },
        VERSION => $Getopt::Mixed::VERSION,
        dist => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
);
