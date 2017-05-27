// **************************************************************************************************
//
// Unit uPreviewContainer
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
// The Original Code is uPreviewContainer.pas.
//
// The Initial Developer of the Original Code is Rodrigo Ruz V.
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2017 Rodrigo Ruz V.
// All Rights Reserved.
//
// *************************************************************************************************

unit uPreviewContainer;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs;

type
  TPreviewContainer = class(TForm)
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FPreview: TObject;
  public
    procedure SetFocusTabFirst;
    procedure SetFocusTabLast;
    procedure SetBackgroundColor(color: TColorRef);
    procedure SetBoundsRect(const ARect: TRect);
    procedure SetTextColor(color: TColorRef);
    procedure SetTextFont(const plf: TLogFont);
    property  Preview  : TObject read FPreview write FPreview;
  end;

implementation

uses
  SynEdit,
  Vcl.Styles.Ext,
  Vcl.Styles,
  Vcl.Themes,
  uSettings, uLogExcept;

{$R *.dfm}

procedure TPreviewContainer.SetFocusTabFirst;
begin
  SelectNext(nil, True, True);
end;

procedure TPreviewContainer.SetFocusTabLast;
begin
  SelectNext(nil, False, True);
end;

procedure TPreviewContainer.FormCreate(Sender: TObject);
var
  LSettings: TSettings;
begin
  TLogPreview.Add('TPreviewContainer.FormCreate');
  LSettings := TSettings.Create;
  try
    if not IsStyleHookRegistered(TCustomSynEdit, TScrollingStyleHook) then
      TStyleManager.Engine.RegisterStyleHook(TCustomSynEdit, TScrollingStyleHook);

    if (Trim(LSettings.StyleName) <> '') and not SameText('Windows', LSettings.StyleName) then    
      TStyleManager.TrySetStyle(LSettings.StyleName, False);
  finally
    LSettings.Free;
  end;
  TLogPreview.Add('TPreviewContainer.FormCreate Done');
end;

procedure TPreviewContainer.FormDestroy(Sender: TObject);
begin
  TLogPreview.Add('TPreviewContainer.FormDestroy');
end;

procedure TPreviewContainer.SetBackgroundColor(color: TColorRef);
begin
end;

procedure TPreviewContainer.SetBoundsRect(const ARect: TRect);
begin
  SetBounds(ARect.Left, ARect.Top, ARect.Right - ARect.Left, ARect.Bottom - ARect.Top);
end;

procedure TPreviewContainer.SetTextColor(color: TColorRef);
begin
end;

procedure TPreviewContainer.SetTextFont(const plf: TLogFont);
begin
end;

end.
