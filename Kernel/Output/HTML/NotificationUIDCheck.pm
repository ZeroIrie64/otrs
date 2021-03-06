# --
# Kernel/Output/HTML/NotificationUIDCheck.pm
# Copyright (C) 2001-2012 OTRS AG, http://otrs.org/
# --
# $Id: NotificationUIDCheck.pm,v 1.12 2012-11-20 15:01:33 mh Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

package Kernel::Output::HTML::NotificationUIDCheck;

use strict;
use warnings;

use vars qw($VERSION);
$VERSION = qw($Revision: 1.12 $) [1];

sub new {
    my ( $Type, %Param ) = @_;

    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );

    # get needed objects
    for (qw(ConfigObject LogObject DBObject LayoutObject UserID)) {
        $Self->{$_} = $Param{$_} || die "Got no $_!";
    }
    return $Self;
}

sub Run {
    my ( $Self, %Param ) = @_;

    # return if it's not root@localhost
    return '' if $Self->{UserID} != 1;

    # show error notfy, don't work with user id 1
    return $Self->{LayoutObject}->Notify(
        Priority => 'Error',
        Link     => '$Env{"Baselink"}Action=AdminUser',
        Data =>
            '$Text{"Don\'t use the Superuser account to work with OTRS! Create new Agents and work with these accounts instead."}',
    );
}

1;
