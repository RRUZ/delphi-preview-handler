//**************************************************************************************************
//
// Unit uCobolPreviewHandler
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
// The Original Code is uCobolPreviewHandler.pas.
//
// The Initial Developer of the Original Code is Rodrigo Ruz V.
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2015 Rodrigo Ruz V.
// All Rights Reserved.
//
//*************************************************************************************************


unit uCobolPreviewHandler;

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
  GUID_CobolPreviewHandler: TGUID = '{B8961094-8033-4D5B-AAB3-A6BCC76E0004}';

type
  TCobolPreviewHandler = class(TBasePreviewHandler)
  public
    constructor Create(AParent: TWinControl); override;
  end;


implementation

Uses
 uDelphiIDEHighlight,
 uDelphiVersions,
 uLogExcept,
 SynEdit,
 SynHighlighterCobol,
 Windows,
 Forms,
 uMisc;

procedure RefreshSynCobolHighlighter(FCurrentTheme:TIDETheme;SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynCobolSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, AreaAIdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Preprocessor, PreprocessorAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, BooleanAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, SequenceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, IndicatorAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, TagAreaAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.EnabledBreak, DebugLinesAttri, DelphiVer);
    end;
end;


constructor TCobolPreviewHandler.Create(AParent: TWinControl);
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
      Editor.SynEdit1.Highlighter:=Editor.SynCobolSyn1;
      Editor.RefreshSynHighlighter:=RefreshSynCobolHighlighter;
      Editor.LoadTheme;
    end;
  except
    on E: Exception do
      TLogException.Add(Format('Error in %s.Create - Message : %s : Trace %s',
        [Self.ClassName, E.Message, E.StackTrace]));
  end;
end;


end.

