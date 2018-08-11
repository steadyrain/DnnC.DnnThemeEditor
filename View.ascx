<!--
'   BSD 3-Clause License
'   
'   Copyright (c) 2017, Geoff Barlow (DnnConsulting.net)
'   All rights reserved.
'   
'   Redistribution and use in source and binary forms, with or without
'   modification, are permitted provided that the following conditions are met:
'   
'   * Redistributions of source code must retain the above copyright notice, this
'     list of conditions and the following disclaimer.
'   
'   * Redistributions in binary form must reproduce the above copyright notice,
'     this list of conditions and the following disclaimer in the documentation
'     and/or other materials provided with the distribution.
'   
'   * Neither the name of the copyright holder nor the names of its
'     contributors may be used to endorse or promote products derived from
'     this software without specific prior written permission.
'   
'   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
'   AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
'   IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
'   DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
'   FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
'   DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
'   SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
'   CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
'   OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
'   OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
-->    
    <%@ Control Language="C#" AutoEventWireup="true" CodeBehind="View.ascx.cs" Inherits="DnnC.Modules.DnnThemeEditor.View" %>
<%@ Register TagPrefix="dnn" Namespace="DotNetNuke.Web.Client.ClientResourceManagement" Assembly="DotNetNuke.Web.Client" %>
<%@ Import Namespace="DnnC.Modules.DnnThemeEditor.Components" %>
<%@ Import Namespace="System.Text" %>

<dnn:DnnCssInclude ID="DnnCssJQueryConfirm" runat="server" FilePath="https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.1.1/jquery-confirm.min.css" Name="jquery-confirm" Version="3.1.1" />
<dnn:DnnCssInclude ID="DnnCssSpectrum" runat="server" FilePath="/DesktopModules/DnnThemeEditor/assets/css/spectrum.css" Name="spectrum" Version="1.8.0" />
<dnn:DnnCssInclude ID="DnnCssThemeEditor" runat="server" FilePath="/DesktopModules/DnnThemeEditor/assets/css/dnnthemeeditor.css" Name="dnnthemeeditor" Version="1.0.0" />

<asp:Panel ID="dnnThemeEditorPnl" runat="server" Visible="false">
    <div id="stylePnl" class="dte-panel dark" runat="server">
        <!-- Start : Menu bar off canvas -->
        <div id="dte-toolbar" class="toolbar-container">
            <div class="dte-container">
                <div class="header">
                    <div class="left-div">                    
                        <h1>
                            <img src="/DesktopModules/DnnThemeEditor/assets/svg/icon_editor.svg" alt="Dnn Theme Editor" /> 
                            Dnn Theme Editor
                        </h1>                    
                    </div>
                    <div class="button-div">
                        <a class="dte-btn dte-resize">
                            <img src="/DesktopModules/DnnThemeEditor/assets/svg/icon_resize.svg" alt="Resize Dnn Theme Editor" />
                        </a>
                        <a class="dte-btn dte-close">
                            <img src="/DesktopModules/DnnThemeEditor/assets/svg/icon_close.svg" alt="Close Dnn Theme Editor" />
                        </a>
                    </div>             
                </div>

                <div class="content scroll">
                    <div class="dnnc">
                        <!--<div class="alert alert-success alert-autocloseable-success error-message">Styles have been saved!</div>-->
                        <div class="cssItems"></div>    
                    </div> 
                </div>

                <div class="footer">
                    <div class="left-div">
                        
                        <input id="chkMinify" type="checkbox" name="chkMinify" value="minify" title="Minify css" /> Minify css?
                    </div>
                    <div class="button-div save">


                        <a class="dte-btn" id="btnSaveThemeValues">
                            <img src="/DesktopModules/DnnThemeEditor/assets/svg/icon_save.svg" alt="Save css settings" /> Save settings
                        </a>
                        <a class="dte-btn grey" id="btnRestore">
                            <img src="/DesktopModules/DnnThemeEditor/assets/svg/icon_restore.svg" alt="Restore to default" />
                        </a>
                    </div>  
                </div>
            </div><!-- ./dte-container -->
        </div><!-- ./End : Menu bar off canvas -->    
        <a id="dte-tab"><img src="/DesktopModules/DnnThemeEditor/assets/svg/icon_editor.svg" alt="Dnn Theme Editor" /></a>
    </div>
</asp:Panel>



<script type="text/javascript">    
$(function(){
    $.ajaxSetup({ 
        headers : { 'TabId': <%= PortalSettings.Current.ActiveTab.TabID %>, 
        'ModuleId': <%:ModuleContext.ModuleId%>, 
        'RequestVerificationToken': $.ServicesFramework().getAntiForgeryValue() 
        } 
    });

    function LoadThemeEditor() {
        GetListURL = "/desktopmodules/DnnThemeEditor/api/csssetting/getcomponents?t=<%= PortalSettings.Current.ActiveTab.TabID %>";
        $.getJSON(GetListURL, function (result) {
            $(".cssItems").append(result);
            SetupDoc()
        });
    }; //LoadThemeEditor

    function LoadToolbar() {
        GetthemeURL = "/desktopmodules/DnnThemeEditor/api/csssetting/checkforfiles?t=<%= PortalSettings.Current.ActiveTab.TabID %>";

        $.ajax({
            type: "POST",
            url: GetthemeURL,
            contentType: "application/json",
            success: function (htmlData) {
                if (htmlData == "") {
                    LoadThemeEditor();
                } else {
                    $(".cssItems").append("<div class=\"error-holder\"><ul class=\"fileListErrors\">" + htmlData + "</ul></div>");
                    $('#btnSaveThemeValues').hide();
                    $('.alert-autocloseable-success').hide();
                    $('btnRestore').hide();
                }
            }
        }); //ajax   
    } //LoadToolbar

    $("#btnRestore").click(function () {
        if (confirm('Are you sure you want to restore to the default style?')) {
            RestoreURL = "/desktopmodules/DnnThemeEditor/api/csssetting/restoretodefault?t=<%= PortalSettings.Current.ActiveTab.TabID %>";

            $.ajax({
                type: "POST",
                url: RestoreURL,
                success: function (htmlData) {
                    $(".cssItems").empty();
                    reloadStylesheets(<%= PortalSettings.Current.ActiveTab.TabID %>);
                    LoadToolbar();
                }
            }); //ajax  
        }
    }); //btnRestore



    $('#btnSaveThemeValues').click(function () {  
        var cssSettings = [];
        var minify = $("#chkMinify").prop('checked');
  
        GetListURL = "/desktopmodules/DnnThemeEditor/api/csssetting/getitemlist?t=<%= PortalSettings.Current.ActiveTab.TabID %>";
        SaveJSonURL = "/desktopmodules/DnnThemeEditor/api/csssetting/savejson?t=<%= PortalSettings.Current.ActiveTab.TabID %>&minify=" + minify;

        $.getJSON(GetListURL, function (result) {
            $.each(result, function () {
                s = {};
                s.itemname = this.ItemName;
                s.itemlabel = this.ItemLabel;
                s.itemdefault = this.ItemDefault;
                s.itemvalue = $('#' + this.ItemName).val();
                s.itemtype = this.ItemType;
                s.itemunit = this.ItemUnit;
                s.itemoptions = this.ItemOptions;
                cssSettings.push(s);               
            });

            var sf = $.ServicesFramework(<%:ModuleContext.ModuleId%>);
            $.ajax({
                url: SaveJSonURL,
                type: "POST",
                contentType: "application/json",
                beforeSend: sf.setModuleHeaders,
                data: JSON.stringify(cssSettings),
                success: function (data) {
                    showSaveAlert();
                    reloadStylesheets(<%= PortalSettings.Current.ActiveTab.TabID %>);                    
                }
            });

        }); // getJSON
       
    }); // btnSaveThemeValues click    
    

    LoadToolbar();
});
</script>

<dnn:DnnJsInclude ID="DnnJsJQueryConfirm" runat="server" FilePath="https://cdnjs.cloudflare.com/ajax/libs/jquery-confirm/3.1.1/jquery-confirm.min.js" ForceProvider="DnnFormBottomProvider" Name="jquery-confirm" Version="3.1.1" />
<dnn:DnnJsInclude ID="DnnJsSpectrum" runat="server" FilePath="/DesktopModules/DnnThemeEditor/assets/js/spectrum.js" ForceProvider="DnnFormBottomProvider" Name="Spectrum" Version="1.8.0" />
<dnn:DnnJsInclude ID="DnnJsInclude1" runat="server" FilePath="/DesktopModules/DnnThemeEditor/assets/js/DnnThemeEditor.js" ForceProvider="DnnFormBottomProvider" Name="dnnthemeeditor" Version="1.0.0" />
