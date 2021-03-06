# --
# CheckModules.t - CheckModules tests
# Copyright (C) 2001-2013 OTRS AG, http://otrs.org/
# --
# $Id: CheckModules.t,v 1.7 2013-01-15 21:06:58 cr Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

use strict;
use warnings;
use utf8;
use vars (qw($Self));

my $Home = $Self->{ConfigObject}->Get('Home');
my $TmpSumString;

if ( open( $TmpSumString, "$^X $Home/bin/otrs.CheckModules.pl NoColors |" ) ) {

    while (<$TmpSumString>) {
        my $TmpLine = $_;
        $TmpLine =~ s/\n//g;
        if ( $TmpLine =~ m{ok|optional}ismx ) {
            $Self->True(
                $TmpLine,
                "$TmpLine",
            );
        }
        else {
            $Self->False(
                $TmpLine,
                "Error in your installed perl modules: $TmpLine",
            );
        }
    }
    close($TmpSumString);

}
else {
    $Self->False(
        1,
        'Unable to check Perl modules',
    );
}

1;
