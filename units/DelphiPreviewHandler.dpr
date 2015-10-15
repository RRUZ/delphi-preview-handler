//**************************************************************************************************
//
// Unit DelphiPreviewHandler
// unit for the Delphi Preview Handler https://github.com/RRUZ/delphi-preview-handler
//
// The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the
// License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
// ANY KIND, either express or implied. See the License for the specific language governing rights
// and limitations under the License.
//
// The Original Code is DelphiPreviewHandler.dpr
//
// The Initial Developer of the Original Code is Rodrigo Ruz V.
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2015 Rodrigo Ruz V.
// All Rights Reserved.
//
//*************************************************************************************************


// JCL_DEBUG_EXPERT_GENERATEJDBG ON
// JCL_DEBUG_EXPERT_INSERTJDBG ON
// JCL_DEBUG_EXPERT_DELETEMAPFILE ON
library DelphiPreviewHandler;

uses
  EMapWin32,
  ComServ,
  Main in 'Main.pas',
  uEditor in 'uEditor.pas' {FrmEditor},
  uSettings in 'uSettings.pas' {FrmSettings},
  uPreviewHandler in 'uPreviewHandler.pas',
  uMisc in 'uMisc.pas',
  uStreamPreviewHandler in 'uStreamPreviewHandler.pas',
  uFilePreviewHandler in 'uFilePreviewHandler.pas',
  uPreviewHandlerRegister in 'uPreviewHandlerRegister.pas',
  uPreviewContainer in 'uPreviewContainer.pas' {PreviewContainer},
  uDelphiIDEHighlight in 'uDelphiIDEHighlight.pas',
  uDelphiVersions in 'uDelphiVersions.pas',
  uRegistry in 'uRegistry.pas',
  uStackTrace in 'uStackTrace.pas',
  uSynEditPopupEdit in 'uSynEditPopupEdit.pas',
  uLogExcept in 'uLogExcept.pas',
  uCommonPreviewHandler in 'uCommonPreviewHandler.pas',
  uGlobalPreviewHandler in 'uGlobalPreviewHandler.pas',
  uAbout in 'uAbout.pas' {FrmAbout},
  dlgSearchText in 'dlgSearchText.pas' {TextSearchDialog},
  Vcl.Styles.Utils.Menus in '..\VCL Styles Utils\Vcl.Styles.Utils.Menus.pas',
  Vcl.Styles.Utils.SysControls in '..\VCL Styles Utils\Vcl.Styles.Utils.SysControls.pas',
  Vcl.Styles.Utils.SysStyleHook in '..\VCL Styles Utils\Vcl.Styles.Utils.SysStyleHook.pas',
  Vcl.Styles.Ext in '..\VCL Styles Utils\Vcl.Styles.Ext.pas',
  Vcl.Styles.Utils.Graphics in '..\VCL Styles Utils\Vcl.Styles.Utils.Graphics.pas',
  Vcl.Styles.Hooks in '..\VCL Styles Utils\Vcl.Styles.Hooks.pas',
  Vcl.Styles.UxTheme in '..\VCL Styles Utils\Vcl.Styles.UxTheme.pas',
  Vcl.Styles.Utils.ComCtrls in '..\VCL Styles Utils\Vcl.Styles.Utils.ComCtrls.pas',
  Vcl.Styles.Utils.Forms in '..\VCL Styles Utils\Vcl.Styles.Utils.Forms.pas',
  Vcl.Styles.Utils.ScreenTips in '..\VCL Styles Utils\Vcl.Styles.Utils.ScreenTips.pas',
  Vcl.Styles.Utils.StdCtrls in '..\VCL Styles Utils\Vcl.Styles.Utils.StdCtrls.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer,
  DllInstall;

{$R *.RES}

begin
end.
