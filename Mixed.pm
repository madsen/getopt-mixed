#---------------------------------------------------------------------
package Getopt::Mixed;
#
# Copyright 1995 Christopher J. Madsen
#
# Author: Christopher J. Madsen <ac608@yfn.ysu.edu>
# Created: 1 Jan 1995
# Version: $Revision: 1.3 $ ($Date: 1995/12/08 02:30:00 $)
#    Note that RCS revision 1.23 => $Getopt::Mixed::VERSION = "1.023"
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Perl; see the file COPYING.  If not, write to the
# Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
#
# Process both single-character and extended options
#---------------------------------------------------------------------

require 5.000;
use Carp;
use English;

require Exporter;
@ISA = qw(Exporter);
@EXPORT = ();
@EXPORT_OK = qw(abortMsg getOptions nextOption);

#=====================================================================
# Package Global Variables:

BEGIN
{
    # The permissible settings for $order:
    $REQUIRE_ORDER   = 0;
    $PERMUTE         = 1;
    $RETURN_IN_ORDER = 2;

    # Regular expressions:
    $intRegexp   = '^[-+]?\d+$';               # Match an integer
    $floatRegexp = '^[-+]?(\d*\.?\d+|\d+\.)$'; # Match a real number
    $typeChars   = 'sif';                      # Match type characters

    # Convert RCS revision number (must be main branch) to d.ddd format:
    ' $Revision: 1.3 $ ' =~ / (\d+)\.(\d{1,3}) /
        or die "Invalid version number";
    $VERSION = sprintf("%d.%03d",$1,$2);
} # end BEGIN

#=====================================================================
# Subroutines:
#---------------------------------------------------------------------
# Initialize the option processor:
#
# You should set any customization variables *after* calling init.
#
# Input:
#   List of option declarations (separated by whitespace)
#       Example:  "a b=i c:s apple baker>b charlie:s"
#         -a and --apple do not take arguments
#         -b takes a mandatory integer argument
#         --baker is a synonym for -b
#         -c and --charlie take an optional string argument
#
# Values for argument specifiers are:
#   <none>   option does not take an argument
#   =s :s    option takes a mandatory (=) or optional (:) string argument
#   =i :i    option takes a mandatory (=) or optional (:) integer argument
#   =f :f    option takes a mandatory (=) or optional (:) real number argument
#   >other   option is a synonym for option `other'
#
# If the first argument is entirely non-alphanumeric characters with
# no whitespace, it represents the characters which can begin options.

sub init
{
    undef %options;
    my($opt,$type);

    $ignoreCase  = 1;           # Ignore case by default
    $optionStart = "-";         # Dash is the default option starter

    # If the first argument is entirely non-alphanumeric characters
    # with no whitespace, it is the desired value for $optionStart:
    $optionStart = shift @ARG if $ARG[0] =~ /^[^a-z0-9\s]+$/i;

    foreach $group (@ARG) {
        # Ignore case unless there are upper-case options:
        $ignoreCase = 0 if $group =~ /[A-Z]/;
        foreach $option (split(/\s+/,$group)) {
            croak "Invalid option declaration `$option'"
                unless $option =~ /^([^=:>]+)([=:][$typeChars]|>[^=:>]+)?$/o;
            $opt  = $1;
            $type = $2 || "";
            if ($type =~ /^>/) {
                $type = $POSTMATCH;
                croak "Invalid synonym `$option'"
                    if (not defined $options{$type}
                        or $options{$type} =~ /^[^:=]/);
            } # end if synonym
            $options{$opt} = $type;
        } # end foreach option
    } # end foreach group

    # Handle POSIX compliancy:
    if (defined $ENV{"POSIXLY_CORRECT"}) {
        $order = $REQUIRE_ORDER;
    } else {
        $order = $PERMUTE;
    }

    $optionEnd = 0;
    $badOption = \&badOption;
    $checkArg  = \&checkArg;
} # end init

#---------------------------------------------------------------------
# Clean up when we're done:
#
# This just releases the memory used by the %options hash

sub cleanup
{
    undef %options;
} # end cleanup

#---------------------------------------------------------------------
# Abort program with message:
#
# Prints program name and arguments to STDERR
# If --help is an option, prints message saying 'Try --help'
# Exits with code 1

sub abortMsg
{
    print STDERR $0,": ",@ARG,"\n";
    print STDERR "Try `$0 --help' for more information.\n"
        if defined $options{"help"};
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
# Make sure we have the proper argument for this option:
#
# You can override this by setting $Getopt::Mixed::checkArg to a
# function reference.
#
# Input:
#   $i:       Position of argument in @ARGV
#   $value:   The text appended to the option (undef if no text)
#   $option:  The pretty name of the option (as the user typed it)
#   $type:    The type of the option

sub checkArg
{
    my ($i,$value,$option,$type) = @ARG;

    abortMsg("option `$option' does not take an argument")
        if (not $type and defined $value);

    if ($type =~ /^=/) {
        # An argument is required for this option:
        $value = splice(@ARGV,$i,1) unless defined $value;
        abortMsg("option `$option' requires an argument")
            unless defined $value;
    }

    if ($type =~ /i$/) {
        abortMsg("option `$option' requires integer argument")
            if (defined $value and $value !~ /$intRegexp/o);
    }
    elsif ($type =~ /f$/) {
        abortMsg("option `$option' requires numeric argument")
            if (defined $value and $value !~ /$floatRegexp/o);
    }
    elsif ($type =~ /^[=:]/ and ref($checkType)) {
        $value = &$checkType($i,$value,$option,$type);
    }

    $value = "" if not defined $value and $type =~ /^:/;

    $value;
} # end checkArg

#---------------------------------------------------------------------
# Return the next option:
#
# Returns a list of 3 elements:  (OPTION, VALUE, PRETTYNAME)
# Returns the null list if there are no more options to process
#
# If $order is $RETURN_IN_ORDER, and this is a normal argument (not an
# option), OPTION will be the null string, VALUE will be the argument,
# and PRETTYNAME will be undefined.

sub nextOption
{
    return () if $#ARGV < 0;    # No more arguments

    if ($optionEnd) {
        # We aren't processing any more options:
        return ("", shift @ARGV) if $order == $RETURN_IN_ORDER;
        return ();
    }

    # Find the next option:
    my $i = 0;
    while (length($ARGV[$i]) < 2 or
           index($optionStart,substr($ARGV[$i],0,1)) < 0) {
        return ()                if $order == $REQUIRE_ORDER;
        return ("", shift @ARGV) if $order == $RETURN_IN_ORDER;
        ++$i;
        return () if $i > $#ARGV;
    } # end while

    # Process the option:
    my($option,$opt,$value,$optType,$prettyOpt);
    $option = $ARGV[$i];
    if (substr($option,0,1) eq substr($option,1,1)) {
        # If the option start character is repeated, it's a long option:
        splice @ARGV,$i,1;
        if (length($option) == 2) {
            # A double dash by itself marks the end of the options:
            $optionEnd = 1;     # Don't process any more options
            return nextOption();
        } # end if bare double dash
        $opt = substr($option,2);
        if ($opt =~ /^([^=]+)=/) {
            $opt = $1;
            $value = $POSTMATCH;
        } # end if option is followed by value
        $opt =~ tr/A-Z/a-z/ if $ignoreCase;
        return &$badOption($i,$option)
            unless defined $options{$opt} and length($opt) > 1;
        $optType = $options{$opt};
        $prettyOpt = substr($option,0,2) . $opt;
        if ($optType =~ /^[^:=]/) {
            $opt = $optType;
            $optType = $options{$opt};
        }
        $value = &$checkArg($i,$value,$prettyOpt,$optType);
    } # end if long option
    else {
        # It's a short option:
        $opt = substr($option,1,1);
        $opt =~ tr/A-Z/a-z/ if $ignoreCase;
        return &$badOption($i,$option) unless defined $options{$opt};
        $optType = $options{$opt};
        if ($optType =~ /^[^:=]/) {
            $opt = $optType;
            $optType = $options{$opt};
        }
        if (length($option) == 2 or $optType) {
            # This is the last option in the group, so remove the group:
            splice(@ARGV,$i,1);
        } else {
            # Just remove this option from the group:
            substr($ARGV[$i],1,1) = "";
        }
        if ($optType) {
            $value = (length($option) > 2) ? substr($option,2) : undef;
            $value = $POSTMATCH if $value and $value =~ /^=/;
        } # end if option takes an argument
        $prettyOpt = substr($option,0,2);
        $value = &$checkArg($i,$value,$prettyOpt,$optType);
    } # end else short option
    ($opt,$value,$prettyOpt);
} # end nextOption

#---------------------------------------------------------------------
# Get options:
#
# Input:
#   The same as for init()
#   If no parameters are supplied, init() is NOT called.  This allows
#   you to call init() yourself and then change the configuration
#   variables.
#
# Output Variables:
#   Sets $opt_X for each `-X' option encountered.
#
#   Note that if --apple is a synonym for -a, then --apple will cause
#   $opt_a to be set, not $opt_apple.

sub getOptions
{
    &init if $#ARG >= 0;        # Pass arguments (if any) on to init

    # If you want to use $RETURN_IN_ORDER, you have to call
    # nextOption yourself; getOptions doesn't support it:
    $order = $PERMUTE if $order == $RETURN_IN_ORDER;

    my ($option,$value,$package);

    $package = (caller)[0];

    while (($option, $value) = nextOption()) {
        $option =~ s/\W/_/g;    # Make a legal Perl identifier
        $value = 1 unless defined $value;
        eval("\$" . $package . '::opt_' . $option . ' = $value;');
    } # end while

    cleanup();
} # end getOptions

#=====================================================================
# Package return value:

1;
