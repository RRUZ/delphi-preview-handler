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


library DelphiPreviewHandler;

uses
  EMemLeaks,
  EResLeaks,
  ESendMailSMAPI,
  EMapWin32,
  EAppDLL,
  ExceptionLog7,
  ComServ,
  Main in 'Main.pas',
  uEditor in 'units\uEditor.pas' {FrmEditor},
  uPreviewHandler in 'units\uPreviewHandler.pas',
  uMisc in 'units\uMisc.pas',
  uStreamPreviewHandler in 'units\uStreamPreviewHandler.pas',
  uFilePreviewHandler in 'units\uFilePreviewHandler.pas',
  uPreviewHandlerRegister in 'units\uPreviewHandlerRegister.pas',
  uPreviewContainer in 'units\uPreviewContainer.pas' {PreviewContainer},
  uPascalPreviewHandler in 'units\uPascalPreviewHandler.pas',
  uXmlPreviewHandler in 'units\uXmlPreviewHandler.pas',
  uCppPreviewHandler in 'units\uCppPreviewHandler.pas',
  uAsmPreviewHandler in 'units\uAsmPreviewHandler.pas',
  uDelphiIDEHighlight in 'units\uDelphiIDEHighlight.pas',
  uDelphiVersions in 'units\uDelphiVersions.pas',
  uRegistry in 'units\uRegistry.pas',
  uStackTrace in 'units\uStackTrace.pas',
  uSynEditPopupEdit in 'units\uSynEditPopupEdit.pas',
  uLogExcept in 'units\uLogExcept.pas',
  uCommonPreviewHandler in 'units\uCommonPreviewHandler.pas',
  uEiffelPreviewHandler in 'units\uEiffelPreviewHandler.pas',
  uFortranPreviewHandler in 'units\uFortranPreviewHandler.pas',
  uJavaPreviewHandler in 'units\uJavaPreviewHandler.pas',
  uVBPreviewHandler in 'units\uVBPreviewHandler.pas',
  uCobolPreviewHandler in 'units\uCobolPreviewHandler.pas',
  uCSharpPreviewHandler in 'units\uCSharpPreviewHandler.pas',
  uCSSPreviewHandler in 'units\uCSSPreviewHandler.pas',
  uHTMLPreviewHandler in 'units\uHTMLPreviewHandler.pas',
  uJScriptPreviewHandler in 'units\uJScriptPreviewHandler.pas',
  uPhpPreviewHandler in 'units\uPhpPreviewHandler.pas',
  uVBScriptPreviewHandler in 'units\uVBScriptPreviewHandler.pas',
  uBatPreviewHandler in 'units\uBatPreviewHandler.pas',
  uDfmPreviewHandler in 'units\uDfmPreviewHandler.pas',
  uPerlPreviewHandler in 'units\uPerlPreviewHandler.pas',
  uPythonPreviewHandler in 'units\uPythonPreviewHandler.pas',
  uRubyPreviewHandler in 'units\uRubyPreviewHandler.pas',
  uUnixPreviewHandler in 'units\uUnixPreviewHandler.pas',
  uSqlPreviewHandler in 'units\uSqlPreviewHandler.pas',
  uInnoPreviewHandler in 'units\uInnoPreviewHandler.pas',
  uIniPreviewHandler in 'units\uIniPreviewHandler.pas';





exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer,
  DllInstall;

{$R *.RES}

begin
end.
