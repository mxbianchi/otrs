# --
# Kernel/Modules/AgentBook.pm - spelling module
# Copyright (C) 2001-2004 Martin Edenhofer <martin+code@otrs.org>
# --
# $Id: AgentBook.pm,v 1.6 2004-11-04 11:04:39 martin Exp $
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (GPL). If you
# did not receive this file, see http://www.gnu.org/licenses/gpl.txt.
# --

package Kernel::Modules::AgentBook;

use strict;
use Kernel::System::CustomerUser;

use vars qw($VERSION);
$VERSION = '$Revision: 1.6 $';
$VERSION =~ s/^\$.*:\W(.*)\W.+?$/$1/;

# --
sub new {
    my $Type = shift;
    my %Param = @_;

    # allocate new hash for object
    my $Self = {};
    bless ($Self, $Type);

    # get common opjects
    foreach (keys %Param) {
        $Self->{$_} = $Param{$_};
    }

    # check all needed objects
    foreach (qw(TicketObject ParamObject DBObject QueueObject LayoutObject
      ConfigObject LogObject)) {
        die "Got no $_" if (!$Self->{$_});
    }

    $Self->{CustomerUserObject} = Kernel::System::CustomerUser->new(%Param);

    return $Self;
}
# --
sub Run {
    my $Self = shift;
    my %Param = @_;
    # get params
    foreach (qw(To Cc Bcc)) {
        $Param{$_} = $Self->{ParamObject}->GetParam(Param => $_);
    }
    # get list of users
    my $Search = $Self->{ParamObject}->GetParam(Param => 'Search');
    my %CustomerUserList = ();
    if ($Search) {
        %CustomerUserList = $Self->{CustomerUserObject}->CustomerSearch(
            Search => $Search,
        );
    }
    my %List = ();
    foreach (keys %CustomerUserList) {
        my %CustomerUserData = $Self->{CustomerUserObject}->CustomerUserDataGet(
            User => $_,
        );
        $List{$CustomerUserData{UserEmail}} = $CustomerUserList{$_};
    }
    foreach (sort { $List{$b} <=> $List{$a} } keys %List) {
        $Self->{LayoutObject}->Block(
            Name => 'Row',
            Data => {
                Name => $List{$_},
                Email => $_,
            },
        );
    }
    # start with page ...
    my $Output = $Self->{LayoutObject}->Header(Area => 'Agent', Title => 'Address Book', Type => 'Small');
    $Output .= $Self->{LayoutObject}->Output(TemplateFile => 'AgentBook', Data => \%Param);
    $Output .= $Self->{LayoutObject}->Footer(Type => 'Small');
    return $Output;
}
# --
1;
