{**************************************************************************************************}
{                                                                                                  }
{ Unit uAsmPreviewHandler                                                                          }
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
{ The Original Code is uAsmPreviewHandler.pas.                                                     }
{                                                                                                  }
{ The Initial Developer of the Original Code is Rodrigo Ruz V.                                     }
{ Portions created by Rodrigo Ruz V. are Copyright (C) 2011 Rodrigo Ruz V.                         }
{ All Rights Reserved.                                                                             }
{                                                                                                  }
{**************************************************************************************************}


unit uAsmPreviewHandler;

{$DEFINE USE_TStreamPreviewHandler}

interface

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
  GUID_AsmPreviewHandler: TGUID = '{691100A7-2A53-456B-BFE5-6BA17A0AB768}';

type
{$IFDEF USE_TStreamPreviewHandler}
  TAsmPreviewHandler = class(TStreamPreviewHandler)
{$ElSE}
  TAsmPreviewHandler = class(TFilePreviewHandler)
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
      Editor.SynEdit1.Highlighter:=Editor.SynAsmSyn1;
      Editor.RefreshSynHighlighter:=RefreshSynAsmHighlighter;
      Editor.LoadTheme;
    end;
  except
    on E: Exception do
      MsgBox(Format('Error in TAsmPreviewHandler.Create - Message : %s : Trace %s',
        [E.Message, E.StackTrace]));
  end;
end;

{$IFDEF USE_TStreamPreviewHandler}
procedure TAsmPreviewHandler.DoPreview(Stream: TIStreamAdapter);
begin
  try
    if IsWindow(Editor.Handle) then
    begin
      Editor.Visible:=True;
      Editor.SynEdit1.Lines.LoadFromStream(Stream);
    end;
  except
    on E: Exception do
      MsgBox(Format('Error in TAsmPreviewHandler.DoPreview(Stream) - Message : %s : Trace %s',
        [E.Message, E.StackTrace]));
  end;
end;
{$ElSE}
procedure TAsmPreviewHandler.DoPreview(const FilePath: string);
begin
  try
    if IsWindow(Editor.Handle) then
    begin
      Editor.Visible:=True;
      Editor.SynEdit1.Lines.LoadFromFile(FilePath);
    end;
  except
    on E: Exception do
      MsgBox(Format('Error in TAsmPreviewHandler.DoPreview(FilePath) - Message : %s : Trace %s',
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

procedure TAsmPreviewHandler.Unload;
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
      MsgBox(Format('Error in TAsmPreviewHandler.Unload - Message : %s : Trace %s',
        [E.Message, E.StackTrace]));
  end;
end;


end.

