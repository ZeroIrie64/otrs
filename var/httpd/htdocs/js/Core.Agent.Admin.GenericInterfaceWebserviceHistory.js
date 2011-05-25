// --
// Core.Agent.Admin.GenericInterfaceWebserviceHistory.js - provides the special module functions for the GenericInterface WebserviceHistory.
// Copyright (C) 2001-2011 OTRS AG, http://otrs.org/
// --
// $Id: Core.Agent.Admin.GenericInterfaceWebserviceHistory.js,v 1.8 2011-05-25 17:17:20 cg Exp $
// --
// This software comes with ABSOLUTELY NO WARRANTY. For details, see
// the enclosed file COPYING for license information (AGPL). If you
// did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
// --

"use strict";

var Core = Core || {};
Core.Agent = Core.Agent || {};
Core.Agent.Admin = Core.Agent.Admin || {};

/**
 * @namespace
 * @exports TargetNS as Core.Agent.Admin.GenericInterfaceWebserviceHistory
 * @description
 *      This namespace contains the special module functions for the GenericInterface WebserviceHistory module.
 */
Core.Agent.Admin.GenericInterfaceWebserviceHistory = (function (TargetNS) {


    TargetNS.Init = function (Params) {
        TargetNS.WebserviceID = parseInt(Params.WebserviceID, 10);
        TargetNS.Localization = Params.Localization;
    };

    TargetNS.GetWebserviceList = function() {
        var Data = {
            Action: 'AdminGenericInterfaceWebserviceHistory',
            Subaction: 'GetWebserviceList',
            WebserviceID: TargetNS.WebserviceID,
            FilterRemoteIP: $('#FilterRemoteIP').val() || '',
            FilterType: $('#FilterType').val() || ''
        };

        $('#WebserviceDetails').css('visibility', 'hidden');
        $('.WebserviceListWidget').addClass('Loading');

        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
            if (!Response || !Response.LogData) {
                alert(TargetNS.Localization.WebserviceHistoryErrorMsg);
                return;
            }

            $('.WebserviceListWidget').removeClass('Loading');

            if (!Response.LogData.length) {
                $('#WebserviceList tbody').empty().append('<tr><td colspan="3">' + TargetNS.Localization.NoDataFoundMsg + '</td></tr>');
            }
            else {
                $('#WebserviceList tbody').empty();
                var HTML = '';

                $.each(Response.LogData, function(){
                    HTML += '<tr>';

                    HTML += '<td><a href="#" class="AsBlock">' + this.ID + '<input type="hidden" class="WebserviceHistoryID" value="' + this.ID + '" /></a></td>';
                    HTML += '<td><a href="#" class="AsBlock">' + this.CreateTime + '</a></td>';
                    HTML += '</tr>';

                });
                $('#WebserviceList tbody').html(HTML);

                $('#WebserviceList a').bind('click', function(Event) {
                    var WebserviceHistoryID = $(this).blur().parents('tr').find('input.WebserviceHistoryID').val();

                    TargetNS.LoadWebserviceHistoryDetails(WebserviceHistoryID);

                    return false;
                });

            }
        }, 'json');
    };

    TargetNS.LoadWebserviceHistoryDetails = function(WebserviceHistoryID) {

        var Data = {
            Action: 'AdminGenericInterfaceWebserviceHistory',
            Subaction: 'GetWebserviceHistoryDetails',
            WebserviceID: TargetNS.WebserviceID,
            WebserviceHistoryID: WebserviceHistoryID
        };

        $('#WebserviceHistoryDetails').css('visibility', 'hidden');
        $('.WebserviceListWidget').addClass('Loading');

        Core.AJAX.FunctionCall(Core.Config.Get('CGIHandle'), Data, function (Response) {
            if (!Response || !Response.LogData ) {
                alert(TargetNS.Localization.WebserviceHistoryErrorMsg);
                return;
            }
            $('.WebserviceListWidget').removeClass('Loading');

            if (!Response.LogData.Config) {
                $('#WebserviceHistoryDetails .ControlRow').empty();
                $('#WebserviceHistoryDetails .ControlRow').append(
                    '<h2>History Details</h2>'
                );
                $('#WebserviceHistoryDetails .ConfigCode pre').empty();
                $('#WebserviceHistoryDetails .ConfigCode pre').append(
                    '<span class="ErrorMessage">' + TargetNS.Localization.NoDataFoundMsg + '</span>'
                );
                $('#WebserviceHistoryDetails').css('visibility', 'visible').show();
                $('#WebserviceHistoryDetails .LightRow').hide();
            }
            else {

                $('#WebserviceHistoryID').attr('value',WebserviceHistoryID);
                $('#WebserviceHistoryDetails .ControlRow').empty();
                $('#WebserviceHistoryDetails .ControlRow').append(
                    '<h2>History Details: Version ' + Response.LogData.ID + ', ' + Response.LogData.CreateTime +  '</h2>'
                );

                $('#WebserviceHistoryDetails .ConfigCode pre').empty();
                $('#WebserviceHistoryDetails .ConfigCode pre').append(
                    '<code>' + Response.LogData.Config + '</code>'
                );

                $('#WebserviceHistoryDetails').css('visibility', 'visible').show();
                $('#WebserviceHistoryDetails .LightRow').show();

            }
        }, 'json');
    };


    TargetNS.ShowRollbackDialog = function(Event){

        Core.UI.Dialog.ShowContentDialog(
            $('#RollbackDialogContainer'),
            TargetNS.Localization.RollbackLogMsg,
            '240px',
            'Center',
            true,
            [
               {
                   Label: TargetNS.Localization.RollbackLogMsg,
                   Function: function () {
                       $('#Subaction').attr('value','Rollback');
                       $('#ActionForm').submit();
                   }
               },
               {
                   Label: TargetNS.Localization.CancelMsg,
                   Function: function () {
                       Core.UI.Dialog.CloseDialog($('#RollbackDialog'));
                   }
               }
           ]
        );

        Event.stopPropagation();
        return false;
    };


    return TargetNS;
}(Core.Agent.Admin.GenericInterfaceWebserviceHistory || {}));