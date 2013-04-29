{**************************************************************************************************}
{                                                                                                  }
{ DelphiPreviewHandler.dproj                                                                       }
{ Project file for the Delphi Preview Handler                                                      }
{                                                                                                  }
{ The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License"); }
{ you may not use this file except in compliance with the License. You may obtain a copy of the    }
{ License at http://www.mozilla.org/MPL/                                                           }
{                                                                                                  }
{ Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF   }
{ ANY KIND, either express or implied. See the License for the specific language governing rights  }
{ and limitations under the License.                                                               }
{                                                                                                  }
{ The Original Code is DelphiPreviewHandler.dproj.                                                 }
{                                                                                                  }
{ The Initial Developer of the Original Code is Rodrigo Ruz V.                                     }
{ Portions created by Rodrigo Ruz V. are Copyright (C) 2011 Rodrigo Ruz V.                         }
{ All Rights Reserved.                                                                             }
{                                                                                                  }
{**************************************************************************************************}

library DelphiPreviewHandler;

uses
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
  uCommonPreviewHandler in 'units\uCommonPreviewHandler.pas';

exports
  DllGetClassObject,
  DllCanUnloadNow,
  DllRegisterServer,
  DllUnregisterServer,
  DllInstall;

{$R *.RES}

begin
end.
