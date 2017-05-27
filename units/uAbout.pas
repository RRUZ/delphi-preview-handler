//**************************************************************************************************
//
// Unit uAbout
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
// The Original Code is uAbout.pas.
//
// The Initial Developer of the Original Code is Rodrigo Ruz V.
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2017 Rodrigo Ruz V.
// All Rights Reserved.
//
//**************************************************************************************************

unit uAbout;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, pngimage, Vcl.ImgList;

type
  TFrmAbout = class(TForm)
    Panel1:    TPanel;
    Button1:   TButton;
    Image1:    TImage;
    Label1:    TLabel;
    LabelVersion: TLabel;
    MemoCopyRights: TMemo;
    Button3: TButton;
    btnCheckUpdates: TButton;
    ImageList1: TImageList;
    LinkLabel1: TLinkLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Image3Click(Sender: TObject);
    procedure LinkLabel1Click(Sender: TObject);
    procedure btnCheckUpdatesClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;



implementation

uses
  ShellApi, uMisc;

{$R *.dfm}

procedure TFrmAbout.btnCheckUpdatesClick(Sender: TObject);
var
  LBinaryPath, LUpdaterPath: string;
begin
  LBinaryPath:=GetModuleLocation();
  LUpdaterPath := ExtractFilePath(LBinaryPath)+'Updater.exe';
  ShellExecute(0, 'open', PChar(LUpdaterPath), PChar(Format('"%s"', [LBinaryPath])), '', SW_SHOWNORMAL);
end;


procedure TFrmAbout.Button1Click(Sender: TObject);
begin
  Close();
end;

procedure TFrmAbout.Button3Click(Sender: TObject);
begin
   ShellExecute(Handle, 'open', PChar('https://github.com/RRUZ/delphi-preview-handler'), nil, nil, SW_SHOW);
end;

procedure TFrmAbout.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 Action:=caFree;
end;

procedure TFrmAbout.FormCreate(Sender: TObject);
var
  FileVersionStr : string;
begin
  FileVersionStr:=uMisc.GetFileVersion(GetModuleLocation());
  LabelVersion.Caption    := Format('Version %s', [FileVersionStr]);
  MemoCopyRights.Lines.Add(
    'Author Rodrigo Ruz - https://github.com/RRUZ - © 2011-2015 all rights reserved.');
  MemoCopyRights.Lines.Add('https://github.com/RRUZ/delphi-preview-handler');
  MemoCopyRights.Lines.Add('');
  MemoCopyRights.Lines.Add('Third Party libraries and tools used');
  MemoCopyRights.Lines.Add('SynEdit http://synedit.svn.sourceforge.net/viewvc/synedit/ all rights reserved.');
  MemoCopyRights.Lines.Add('');
  MemoCopyRights.Lines.Add('VCL Styles Utils https://github.com/RRUZ/vcl-styles-utils all rights reserved.');
  MemoCopyRights.Lines.Add('');
  MemoCopyRights.Lines.Add('This product includes software developed by the OpenSSL Project for use in the OpenSSL Toolkit (http://www.openssl.org/)');
  MemoCopyRights.Lines.Add('');
  MemoCopyRights.Lines.Add('Go Delphi Go');
end;


procedure TFrmAbout.Image3Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'http://tp.embarcadero.com/ctprefer?partner_id=1445&product_id=0',nil,nil, SW_SHOWNORMAL) ;
end;

procedure TFrmAbout.LinkLabel1Click(Sender: TObject);
begin
   ShellExecute(Handle, 'open', PChar('https://github.com/RRUZ/delphi-preview-handler'), nil, nil, SW_SHOW);

end;

end.
