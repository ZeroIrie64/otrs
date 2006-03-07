# --
# Kernel/System/Ticket/Event/ForceState.pm - set state
# Copyright (C) 2001-2006 Martin Edenhofer <martin+code@otrs.org>
# --
# $Id: ForceState.pm,v 1.2 2006-03-07 06:39:36 martin Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl.txt.
# --

package Kernel::System::Ticket::Event::ForceState;

use strict;

use vars qw($VERSION);
$VERSION = '$Revision: 1.2 $';
$VERSION =~ s/^\$.*:\W(.*)\W.+?$/$1/;

# --
sub new {
    my $Type = shift;
    my %Param = @_;

    # allocate new hash for object
    my $Self = {};
    bless ($Self, $Type);

    # get needed objects
    foreach (qw(ConfigObject TicketObject LogObject UserObject CustomerUserObject SendmailObject TimeObject EncodeObject)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }

    return $Self;
}
# --
sub Run {
    my $Self = shift;
    my %Param = @_;
    # check needed stuff
    foreach (qw(TicketID Event Config)) {
      if (!$Param{$_}) {
        $Self->{LogObject}->Log(Priority => 'error', Message => "Need $_!");
        return;
      }
    }
    my %Ticket = $Self->{TicketObject}->TicketGet(%Param);
    # should I unlock a ticket after move?
    if ($Ticket{Lock} =~ /^lock$/i) {
        foreach (keys %{$Param{Config}}) {
            if ($_ eq $Ticket{State} && $_) {
                $Self->{TicketObject}->StateSet(
                    TicketID => $Param{TicketID},
                    State => $Param{Config}->{$_},
                    SendNoNotification => 1,
                    UserID => 1,
                );
            }
        }
    }
    return 1;
}
# --
1;

