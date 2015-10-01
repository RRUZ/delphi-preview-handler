//**************************************************************************************************
//
// Unit uCppPreviewHandler
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
// The Original Code is uCppPreviewHandler.pas.
//
// The Initial Developer of the Original Code is Rodrigo Ruz V.
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2015 Rodrigo Ruz V.
// All Rights Reserved.
//
//*************************************************************************************************

unit uCppPreviewHandler;

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
  GUID_CppPreviewHandler: TGUID = '{B8961094-8033-4D5B-AAB3-A6BCC76EB7A5}';

type
  TCppPreviewHandler = class(TBasePreviewHandler)
  public
    constructor Create(AParent: TWinControl); override;
  end;


implementation

Uses
 uDelphiIDEHighlight,
 uDelphiVersions,
 uLogExcept,
 SynEdit,
 SynHighlighterCpp,
 Windows,
 Forms,
 uMisc;

procedure RefreshSynCppHighlighter(FCurrentTheme:TIDETheme;SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynCppSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Assembler, AsmAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Character, CharAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Preprocessor, DirecAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Float, FloatAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Hex, HexAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Preprocessor, InvalidAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, OctalAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
    end;
end;


type
 TWinControlClass = class(TWinControl);

constructor TCppPreviewHandler.Create(AParent: TWinControl);
begin
  inherited Create(AParent);
  try
    if IsWindow(TWinControlClass(AParent).WindowHandle) then
    begin
      Editor := TFrmEditor.Create(AParent);
      Editor.Parent := AParent;
      Editor.Align  := alClient;
      Editor.BorderStyle :=bsNone;
      //Editor.Visible:=True;
      Editor.SynEdit1.Highlighter:=Editor.SynCppSyn1;
      Editor.RefreshSynHighlighter:=RefreshSynCppHighlighter;
      Editor.LoadTheme;
    end;
  except
    on E: Exception do
      TLogException.Add(Format('Error in %s.Create - Message : %s : Trace %s',
        [Self.ClassName, E.Message, E.StackTrace]));
  end;
end;


end.

