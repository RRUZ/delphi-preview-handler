//**************************************************************************************************
//
// Unit uPascalPreviewHandler
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
// The Original Code is uPascalPreviewHandler.pas.
//
// The Initial Developer of the Original Code is Rodrigo Ruz V.
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2015 Rodrigo Ruz V.
// All Rights Reserved.
//
//*************************************************************************************************

unit uPascalPreviewHandler;

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
  GUID_PascalPreviewHandler: TGUID = '{AD8855FB-F908-4DDF-982C-ADB9DE5FF000}';
//  GUID_PascalPreviewHandler: TGUID = '{DC6EFB56-9CFA-464D-8880-44885D7DC192}'; just for tests not activate
type
  TPascalPreviewHandler = class(TBasePreviewHandler)
  public
    constructor Create(AParent: TWinControl); override;
  end;


implementation

Uses
 uDelphiIDEHighlight,
 uDelphiVersions,
 uLogExcept,
 SynEdit,
 SynHighlighterPas,
 Windows,
 Forms,
 uMisc;

procedure RefreshSynPasHighlighter(FCurrentTheme:TIDETheme;SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;

    RefreshSynEdit(FCurrentTheme, SynEdit);

    with TSynPasSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Assembler, AsmAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Character, CharAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Preprocessor, DirectiveAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Float, FloatAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Hex, HexAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri,DelphiVer);
    end;
end;

constructor TPascalPreviewHandler.Create(AParent: TWinControl);
begin
  inherited Create(AParent);
  try
    if IsWindow(AParent.Handle) then
    begin
      Editor        := TFrmEditor.Create(AParent);
      Editor.Parent := AParent;
      Editor.Align  := alClient;
      Editor.BorderStyle :=bsNone;
      //Editor.Visible:=True;
      Editor.SynEdit1.Highlighter:=Editor.SynPasSyn1;
      Editor.RefreshSynHighlighter:=RefreshSynPasHighlighter;
      Editor.LoadTheme;
    end;
  except
    on E: Exception do
      TLogException.Add(Format('Error in TPascalPreviewHandler.Create - Message : %s : Trace %s',
        [E.Message, E.StackTrace]));
  end;
end;


end.
