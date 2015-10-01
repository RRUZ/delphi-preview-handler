//**************************************************************************************************
//
// Unit uXmlPreviewHandler
// unit for the Delphi Preview Handler  https://github.com/RRUZ/delphi-preview-handler
//
// The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the
// License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
// ANY KIND, either express or implied. See the License for the specific language governing rights
// and limitations under the License.
//
// The Original Code is uXmlPreviewHandler.pas.
//
// The Initial Developer of the Original Code is Rodrigo Ruz V.
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2015 Rodrigo Ruz V.
// All Rights Reserved.
//
//*************************************************************************************************

unit uXmlPreviewHandler;

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
  GUID_XmlPreviewHandler: TGUID = '{5B96A782-E9C7-4620-B9DA-4B219BF97AB3}';

type
  TXmlPreviewHandler = class(TBasePreviewHandler)
  public
    constructor Create(AParent: TWinControl); override;
  end;


implementation

Uses
 uDelphiIDEHighlight,
 uDelphiVersions,
 uLogExcept,
 SynEdit,
 SynHighlighterXML,
 Windows,
 Forms,
 uMisc;


procedure RefreshSynXmlHighlighter(FCurrentTheme:TIDETheme;SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;

    RefreshSynEdit(FCurrentTheme, SynEdit);

    with TSynXMLSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.AttributeNames, AttributeAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.AttributeValues, AttributeValueAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CDATAAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Preprocessor, DocTypeAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, ElementAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, EntityRefAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, NamespaceAttributeAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, NamespaceAttributeValueAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Preprocessor, ProcessingInstructionAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, SymbolAttri,DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Character, TextAttri,DelphiVer);
    end;
end;

type
 TWinControlClass = class(TWinControl);

constructor TXmlPreviewHandler.Create(AParent: TWinControl);
begin
  inherited Create(AParent);
  //ReportMemoryLeaksOnShutdown:=True;
  try
    if IsWindow(TWinControlClass(AParent).WindowHandle) then
    begin
      Editor := TFrmEditor.Create(AParent);
      Editor.Parent := AParent;
      Editor.Align  := alClient;
      Editor.BorderStyle :=bsNone;
      //Editor.Visible:=True;
      Editor.SynEdit1.Highlighter:=Editor.SynXMLSyn1;
      Editor.RefreshSynHighlighter:=RefreshSynXmlHighlighter;
      Editor.LoadTheme;
    end;
  except
    on E: Exception do
      TLogException.Add(Format('Error in TXmlPreviewHandler.Create - Message : %s : Trace %s',
        [E.Message, E.StackTrace]));
  end;
end;

end.
