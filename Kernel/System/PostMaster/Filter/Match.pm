# --
# Kernel/System/PostMaster/Filter/Match.pm - sub part of PostMaster.pm
# Copyright (C) 2001-2012 OTRS AG, http://otrs.org/
# --
# $Id: Match.pm,v 1.23 2012-11-20 15:51:59 mh Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::System::PostMaster::Filter::Match;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.23 $) [1];

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    $Self->{Debug} = $Param{Debug} || 0;

    # get needed objects
    for (qw(ConfigObject LogObject DBObject ParserObject)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # check needed stuff
    for (qw(JobConfig GetParam)) {
        if ( !$Param{$_} ) {
            $Self->{LogObject}->Log( Priority => 'error', Message => "Need $_!" );
            return;
        }
    }

    # get config options
    my %Config;
    my %Match;
    my %Set;
    my $StopAfterMatch;
    if ( $Param{JobConfig} && ref $Param{JobConfig} eq 'HASH' ) {
        %Config = %{ $Param{JobConfig} };
        if ( $Config{Match} ) {
            %Match = %{ $Config{Match} };
        }
        if ( $Config{Set} ) {
            %Set = %{ $Config{Set} };
        }
        $StopAfterMatch = $Config{StopAfterMatch} || 0;
    }

    my $Prefix = '';
    if ( $Config{Name} ) {
        $Prefix = "Filter: '$Config{Name}' ";
    }

    # match 'Match => ???' stuff
    my $Matched    = '';
    my $MatchedNot = 0;
    for ( sort keys %Match ) {

        # match only email addresses
        if ( $Param{GetParam}->{$_} && $Match{$_} =~ /^EMAILADDRESS:(.*)$/ ) {
            my $SearchEmail    = $1;
            my @EmailAddresses = $Self->{ParserObject}->SplitAddressLine(
                Line => $Param{GetParam}->{$_},
            );
            my $LocalMatched;
            for my $Recipients (@EmailAddresses) {
                my $Email = $Self->{ParserObject}->GetEmailAddress( Email => $Recipients );
                if ( $Email =~ /^$SearchEmail$/i ) {
                    $LocalMatched = $SearchEmail || 1;
                    if ( $Self->{Debug} > 1 ) {
                        $Self->{LogObject}->Log(
                            Priority => 'debug',
                            Message  => "$Prefix'$Param{GetParam}->{$_}' =~ /$Match{$_}/i matched!",
                        );
                    }
                    last;
                }
            }
            if ( !$LocalMatched ) {
                $MatchedNot = 1;
            }
            else {
                $Matched = $LocalMatched;
            }
        }

        # match string
        elsif ( $Param{GetParam}->{$_} && $Param{GetParam}->{$_} =~ /$Match{$_}/i ) {

            # don't lose older match values if more than one header is
            # used for matching.
            if ($1) {
                $Matched = $1;
            }
            else {
                $Matched = $Matched || '1';
            }
            if ( $Self->{Debug} > 1 ) {
                $Self->{LogObject}->Log(
                    Priority => 'debug',
                    Message  => "$Prefix'$Param{GetParam}->{$_}' =~ /$Match{$_}/i matched!",
                );
            }
        }
        else {
            $MatchedNot = 1;
            if ( $Self->{Debug} > 1 ) {
                $Self->{LogObject}->Log(
                    Priority => 'debug',
                    Message  => "$Prefix'$Param{GetParam}->{$_}' =~ /$Match{$_}/i matched NOT!",
                );
            }
        }
    }

    # should I ignore the incoming mail?
    if ( $Matched && !$MatchedNot ) {
        for ( sort keys %Set ) {
            $Set{$_} =~ s/\[\*\*\*\]/$Matched/;
            $Param{GetParam}->{$_} = $Set{$_};
            $Self->{LogObject}->Log(
                Priority => 'notice',
                Message  => $Prefix
                    . "Set param '$_' to '$Set{$_}' (Message-ID: $Param{GetParam}->{'Message-ID'}) ",
            );
        }

        # stop after match
        if ($StopAfterMatch) {
            $Self->{LogObject}->Log(
                Priority => 'notice',
                Message  => $Prefix
                    . "Stopped filter processing because of used 'StopAfterMatch' (Message-ID: $Param{GetParam}->{'Message-ID'}) ",
            );
            return 1;
        }
    }
    return 1;
}

1;
