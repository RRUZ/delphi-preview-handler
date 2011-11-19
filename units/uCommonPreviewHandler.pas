unit uCommonPreviewHandler;

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

type
{$IFDEF USE_TStreamPreviewHandler}
  TBasePreviewHandler = class(TStreamPreviewHandler)
{$ElSE}
  TBasePreviewHandler = class(TFilePreviewHandler)
{$ENDIF}
  private
    FEditor: TFrmEditor;
  public
    constructor Create(AParent: TWinControl); override;
    procedure Unload; override;
{$IFDEF USE_TStreamPreviewHandler}
    procedure DoPreview(Stream: TIStreamAdapter); override;
{$ElSE}
    procedure DoPreview(const FilePath: string); override;
{$ENDIF}
    property Editor : TFrmEditor read FEditor write FEditor;
  end;


implementation

Uses
 uLogExcept,
 SynEdit,
 Windows,
 Forms,
 uMisc;


constructor TBasePreviewHandler.Create(AParent: TWinControl);
begin
  inherited ;
end;

{$IFDEF USE_TStreamPreviewHandler}
procedure TBasePreviewHandler.DoPreview(Stream: TIStreamAdapter);
begin
  try
    if IsWindow(Editor.Handle) then
    begin
      Editor.Visible:=True;
      Editor.SynEdit1.Lines.LoadFromStream(Stream);
    end;
  except
    on E: Exception do
      TLogException.Add(Format('Error in TBasePreviewHandler.DoPreview(Stream) - Message : %s : Trace %s',
        [E.Message, E.StackTrace]));
  end;
end;
{$ElSE}
procedure TBasePreviewHandler.DoPreview(const FilePath: string);
begin
  try
    if IsWindow(Editor.Handle) then
    begin
      Editor.Visible:=True;
      Editor.SynEdit1.Lines.LoadFromFile(FilePath);
    end;
  except
    on E: Exception do
      TLogExpections.Add(Format('Error in TBasePreviewHandler.DoPreview(FilePath) - Message : %s : Trace %s',
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

procedure TBasePreviewHandler.Unload;
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
      TLogException.Add(Format('Error in TBasePreviewHandler.Unload - Message : %s : Trace %s',
        [E.Message, E.StackTrace]));
  end;
end;

end.
