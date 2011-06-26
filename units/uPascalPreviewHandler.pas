{**************************************************************************************************}
{                                                                                                  }
{ Unit uPascalPreviewHandler                                                                       }
{ unit for the Delphi Preview Handler                                                              }
{                                                                                                  }
{ The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License"); }
{ you may not use this file except in compliance with the License. You may obtain a copy of the    }
{ License at http://www.mozilla.org/MPL/                                                           }
{                                                                                                  }
{ Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF   }
{ ANY KIND, either express or implied. See the License for the specific language governing rights  }
{ and limitations under the License.                                                               }
{                                                                                                  }
{ The Original Code is uPascalPreviewHandler.pas.                                                  }
{                                                                                                  }
{ The Initial Developer of the Original Code is Rodrigo Ruz V.                                     }
{ Portions created by Rodrigo Ruz V. are Copyright (C) 2011 Rodrigo Ruz V.                         }
{ All Rights Reserved.                                                                             }
{                                                                                                  }
{**************************************************************************************************}

unit uPascalPreviewHandler;

interface

{$DEFINE USE_TStreamPreviewHandler}

uses
  uStackTrace,
  Classes,
  Controls,
  StdCtrls,
  SysUtils,
  uEditor,
{$IFDEF USE_TStreamPreviewHandler}
  uStreamPreviewHandler,
{$ELSE}
  uFilePreviewHandler,
{$ENDIF}
  uPreviewHandler;

const
  GUID_PascalPreviewHandler: TGUID = '{AD8855FB-F908-4DDF-982C-ADB9DE5FF000}';
//  GUID_PascalPreviewHandler: TGUID = '{DC6EFB56-9CFA-464D-8880-44885D7DC192}'; just for tests not activate
type
{$IFDEF USE_TStreamPreviewHandler}
  TPascalPreviewHandler = class(TStreamPreviewHandler)
{$ElSE}
  TPascalPreviewHandler = class(TFilePreviewHandler)
{$ENDIF}
  private
    FEditor: TFrmEditor;
    property Editor : TFrmEditor read FEditor;
  public
    constructor Create(AParent: TWinControl); override;
    procedure Unload; override;
{$IFDEF USE_TStreamPreviewHandler}
    procedure DoPreview(Stream: TIStreamAdapter); override;
{$ElSE}
    procedure DoPreview(const FilePath: string); override;
{$ENDIF}
  end;


implementation

Uses
 uDelphiIDEHighlight,
 uDelphiVersions,
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
  inherited ;
  //ReportMemoryLeaksOnShutdown:=True;
  try
    if IsWindow(AParent.Handle) then
    begin
      FEditor := TFrmEditor.Create(AParent);
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
      MsgBox(Format('Error in TPascalPreviewHandler.Create - Message : %s : Trace %s',
        [E.Message, E.StackTrace]));
  end;
end;

{$IFDEF USE_TStreamPreviewHandler}
procedure TPascalPreviewHandler.DoPreview(Stream: TIStreamAdapter);
begin
  try
    if IsWindow(Editor.Handle) then
    begin
      Editor.Visible:=True;
      Editor.SynEdit1.Lines.LoadFromStream(Stream);
    end;
  except
    on E: Exception do
      MsgBox(Format('Error in TPascalPreviewHandler.DoPreview(Stream) - Message : %s : Trace %s',
        [E.Message, E.StackTrace]));
  end;
end;
{$ElSE}
procedure TPascalPreviewHandler.DoPreview(const FilePath: string);
begin
  try
    if IsWindow(Editor.Handle) then
    begin
      Editor.Visible:=True;
      Editor.SynEdit1.Lines.LoadFromFile(FilePath);
    end;
  except
    on E: Exception do
      MsgBox(Format('Error in TPascalPreviewHandler.DoPreview(FilePath) - Message : %s : Trace %s',
        [E.Message, E.StackTrace]));
  end;
end;
{$ENDIF}

{
http://msdn.microsoft.com/en-us/library/bb776865%28v=vs.85%29.aspx
IPreviewHandler::Unload
When this method is called, stop any rendering, release any resources allocated by reading data from the stream, and release the IStream itself.
Once this method is called, the handler must be reinitialized before any attempt to call IPreviewHandler::DoPreview again.
}

procedure TPascalPreviewHandler.Unload;
begin
  try
    if IsWindow(Editor.Handle) then
    begin
     Editor.Visible:=False;
     Editor.SynEdit1.Lines.Clear;
    end;
    inherited;
  except
    on E: Exception do
      MsgBox(Format('Error in TPascalPreviewHandler.Unload - Message : %s : Trace %s',
        [E.Message, E.StackTrace]));
  end;
end;

end.
