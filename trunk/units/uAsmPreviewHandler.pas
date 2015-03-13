//**************************************************************************************************
//
// Unit uAsmPreviewHandler
// unit for the Delphi Preview Handler
//
// The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the
// License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
// ANY KIND, either express or implied. See the License for the specific language governing rights
// and limitations under the License.
//
// The Original Code is uAsmPreviewHandler.pas.
//
// The Initial Developer of the Original Code is Rodrigo Ruz V.
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2015 Rodrigo Ruz V.
// All Rights Reserved.
//
//*************************************************************************************************



unit uAsmPreviewHandler;

interface

uses
  uStackTrace,
  Classes,
  Controls,
  StdCtrls,
  SysUtils,
  uEditor,
  uCommonPreviewHandler,
  uPreviewHandler;

const
  GUID_AsmPreviewHandler: TGUID = '{691100A7-2A53-456B-BFE5-6BA17A0AB768}';

type
  TAsmPreviewHandler = class(TBasePreviewHandler)
  public
    constructor Create(AParent: TWinControl); override;
  end;


implementation

Uses
 uDelphiIDEHighlight,
 uDelphiVersions,
 uLogExcept,
 SynEdit,
 SynHighlighterAsm,
 Windows,
 Forms,
 uMisc;

procedure RefreshSynAsmHighlighter(FCurrentTheme:TIDETheme;SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
  DelphiVer := DelphiXE;
  RefreshSynEdit(FCurrentTheme, SynEdit);
  with TSynAsmSyn(SynEdit.Highlighter) do
  begin
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri,DelphiVer);
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri,DelphiVer);
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri,DelphiVer);
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri,DelphiVer);
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri,DelphiVer);
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri,DelphiVer);
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri,DelphiVer);
  end;
end;

constructor TAsmPreviewHandler.Create(AParent: TWinControl);
begin
  inherited Create(AParent);
  try
    if IsWindow(AParent.Handle) then
    begin
      Editor := TFrmEditor.Create(AParent);
      Editor.Parent := AParent;
      Editor.Align  := alClient;
      Editor.BorderStyle :=bsNone;
      //Editor.Visible:=True;
      Editor.SynEdit1.Highlighter:=Editor.SynAsmSyn1;
      Editor.RefreshSynHighlighter:=RefreshSynAsmHighlighter;
      Editor.LoadTheme;
    end;
  except
    on E: Exception do
      TLogException.Add(Format('Error in TAsmPreviewHandler.Create - Message : %s : Trace %s',
        [E.Message, E.StackTrace]));
  end;
end;

end.

