#---------------------------------------------------------------------
# $Id: Mixed.pm,v 1.1 1995/01/02 17:35:46 Madsen Exp $
# Copyright 1994 Christopher J. Madsen
#
# Process both single-character and extended options
#---------------------------------------------------------------------

package Getopt::Mixed;

require 5.000;
use English;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = ();
@EXPORT_OK = qw(getOptions nextOption);

#=====================================================================
# Package Global Variables:

BEGIN
{
    $REQUIRE_ORDER   = 0;
    $PERMUTE         = 1;
    $RETURN_IN_ORDER = 2;
} # end BEGIN

#=====================================================================
# Subroutines:
#---------------------------------------------------------------------
# Initialize the option processor:
#
# Input:
#   shortOpts:
#     String listing short options
#   longOpts:
#     Reference to hash of long options

sub initialize
{
    my $shortOpts = $ARG[0];
    $longOpts = $ARG[1];

    undef %shortOpts;
    my($opt,$type);

    while ($shortOpts) {
        $opt = substr($shortOpts,0,1);
        substr($shortOpts,0,1) = "";
        $type = substr($shortOpts,0,1);
        if ($type =~ /[=:]/) {
            $shortOpts{$opt} = substr($shortOpts,0,2);
            substr($shortOpts,0,2) = "";
            die "Invalid option string" unless $shortOpts{$opt} =~ /[=:][sif]/;
        } else {
            $shortOpts{$opt} = "";
        }
    } # end while

    # Handle POSIX compliancy:
    if (defined $ENV{"POSIXLY_CORRECT"}) {
        $order = $REQUIRE_ORDER;
    } else {
        $order = $PERMUTE;
    }

    $optionEnd = 0;
    $badOption = \&badOption;
    $optionStart = "-";
} # end initialize

#---------------------------------------------------------------------
sub cleanup
{
    undef $longOpts;
    undef %shortOpts;
} # end cleanup

#---------------------------------------------------------------------
# Abort program with message:

sub abortMsg
{
    print STDERR $0,": ",@ARG,"\n";
    print STDERR "Try `$0 --help' for more information.\n"
        if defined $longOpts->{"help"};
    exit 1;
} # end abortMsg

#---------------------------------------------------------------------
# Standard function for handling bad options:
#
# Prints an error message and exits.
#
# You can override this by setting $Getopt::Mixed::badOption to a
# function reference.
#
# Input:
#   Index into @ARGV
#   The option that caused the error
#
# Note:
#   The option has already been removed from @ARGV.  To put it back,
#   you can say:
#     splice(@ARGV,$_[0],0,$_[1]);
#
#   If your function returns, it should return whatever you want
#   nextOption to return.

sub badOption
{
    abortMsg("unrecognized option `$ARG[1]'");
} # end badOption

#---------------------------------------------------------------------
sub checkArg
{
    my ($i,$value,$option,$optType) = @ARG;

    abortMsg("option `$option' does not take an argument")
        if (not $optType and defined $value);

    if ($optType =~ /^=/) {
        $value = $value || splice(@ARGV,$i,1);
        abortMsg("option `$option' requires an argument")
            unless defined $value;
    }

    if ($optType =~ /i$/) {
        abortMsg("option `$option' requires integer argument")
            if (not defined $value or $value !~ /^[-+]?[0-9]+$/);
    }
    elsif ($optType =~ /f$/) {
        abortMsg("option `$option' requires numeric argument")
            if (not defined $value or
                $value !~ /^[-+]?([0-9]*\.?[0-9]+|[0-9]+\.)$/);
    }

    $value;
} # end checkArg

#---------------------------------------------------------------------
# Return the next option:
#
# Returns (option, value)
# Returns null list if no more options

sub nextOption
{
    return () if $#ARGV < 0;

    if ($optionEnd) {
        return ("", shift @ARGV) if $order == $RETURN_IN_ORDER;
        return ();
    }

    my $i = 0;
    while (length($ARGV[$i]) < 2 or
           index($optionStart,substr($ARGV[$i],0,1)) < 0) {
        return ()                if $order == $REQUIRE_ORDER;
        return ("", shift @ARGV) if $order == $RETURN_IN_ORDER;
        ++$i;
        return () if $i > $#ARGV;
    }

    my($option,$opt,$value,$optType);
    $option = $ARGV[$i];
    if (substr($option,0,1) eq substr($option,1,1)) {
        splice @ARGV,$i,1;
        if (length($option) == 2) {
            $optionEnd = 1;
            return nextOption();
        }
        $opt = substr($option,2);
        if ($opt =~ /^([^=]+)=/) {
            $opt = $1;
            $value = $POSTMATCH;
        }
        return &$badOption($i,$option) unless defined $longOpts->{$opt};
        $optType = $longOpts->{$opt};
        my $prettyOpt = $opt;
        if ($optType =~ /^[^:=]/) {
            $opt = $optType;
            $optType = $shortOpts{$opt};
        }
        $value = checkArg($i,$value,substr($option,0,2).$prettyOpt,$optType);
        return ($opt,$value);
    } else {
        $opt = substr($option,1,1);
        return &$badOption($i,$option) unless defined $shortOpts{$opt};
        $optType = $shortOpts{$opt};
        if (length($option) == 2 or $optType) {
            splice(@ARGV,$i,1);
        }
        else {
            substr($ARGV[$i],1,1) = "";
        }
        if ($optType) {
            $value = substr($option,2);
            $value = $POSTMATCH if $value =~ /^=/;
        }
        $value = checkArg($i,$value,substr($option,0,2),$optType);
        return ($opt,$value);
    } # end else short option
} # end nextOption

#---------------------------------------------------------------------
# Get options:
#
# Input:
#   shortOpts:
#     String listing short options
#   longOpts:
#     Reference to hash of long options

sub getOptions
{
    &initialize;                # Pass arguments on to initialize

    # If you want to use $RETURN_IN_ORDER, you have to call
    # nextOption yourself; getOptions doesn't support it:
    $order = $PERMUTE if $order == $RETURN_IN_ORDER;

    my ($option,$value,$package);

    $package = (caller)[0];

    while (($option, $value) = nextOption()) {
        $option =~ s/\W/_/g;
        $value = 1 unless defined $value;
        eval ("\$" . $package . '::opt_' . $option . ' = $value;');
    } # end while

    cleanup();
} # end getOptions
