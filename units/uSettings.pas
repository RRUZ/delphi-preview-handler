// **************************************************************************************************
//
// Unit uSettings
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
// The Original Code is uSettings.pas.
//
// The Initial Developer of the Original Code is Rodrigo Ruz V.
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2017 Rodrigo Ruz V.
// All Rights Reserved.
//
// *************************************************************************************************

unit uSettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.StdCtrls, SynEditTypes, SynEdit;

const
  sThemesExt = '.theme.xml';
  sDefaultThemeName = 'mustang.theme.xml';

type
  TSettings = class
  private
    FSyntaxHighlightTheme: string;
    FFontSize: Integer;
    FStyleName: string;
    FFontName: string;
    FSynSelectionMode: TSynSelectionMode;
    class function GetPathThemes: string; static;
    class function GetSettingsPath: string; static;
    class function GetSettingsFileName: string; static;
  public
    constructor Create;
    property SyntaxHighlightTheme: string read FSyntaxHighlightTheme write FSyntaxHighlightTheme;
    property FontSize: Integer read FFontSize write FFontSize;
    property FontName: string read FFontName write FFontName;
    property StyleName: string read FStyleName write FStyleName;
    property SelectionMode: TSynSelectionMode read FSynSelectionMode write FSynSelectionMode;

    class property PathThemes: string read GetPathThemes;
    class property SettingsFileName: string read GetSettingsFileName;

    class property SettingsPath: string read GetSettingsPath;
    class function GetThemeNameFromFile(const FileName: string): string;

    procedure ReadSettings;
    procedure WriteSettings;
  end;

  TFrmSettings = class(TForm)
    Label1: TLabel;
    CbFont: TComboBox;
    EditFontSize: TEdit;
    Label2: TLabel;
    UpDown1: TUpDown;
    CbVCLStyles: TComboBox;
    Label3: TLabel;
    CbSelectionMode: TComboBox;
    Label4: TLabel;
    ButtonSave: TButton;
    cbSyntaxTheme: TComboBox;
    Label5: TLabel;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure ButtonSaveClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FSettings: TSettings;
    FSettingsChanged: Boolean;
    FOldStyle : string;
    procedure FillData;
  public
    procedure LoadCurrentValues(SynEdit: TSynEdit; const ThemeName: string);
    property SettingsChanged: Boolean read FSettingsChanged;
    property Settings: TSettings read FSettings;
  end;

implementation

{$R *.dfm}

uses
  IniFiles,
  System.Types,
  System.TypInfo,
  System.Rtti,
  System.StrUtils,
  System.IOUtils,
  Winapi.ShlObj,
  Vcl.Themes,
  uMisc, uLogExcept;

function EnumFontsProc(var LogFont: TLogFont; var TextMetric: TTextMetric; FontType: Integer; Data: Pointer): Integer; stdcall;
var
  List: TStrings;
begin
  List := TStrings(Data);
  if ((LogFont.lfPitchAndFamily and FIXED_PITCH) <> 0) then
    if not StartsText('@', LogFont.lfFaceName) and (List.IndexOf(LogFont.lfFaceName) < 0) then
      List.Add(LogFont.lfFaceName);

  Result := 1;
end;

{ TSettings }

constructor TSettings.Create;
begin
  inherited;
  ReadSettings;
end;

class function TSettings.GetPathThemes: string;
begin
  Result := ExtractFilePath(GetModuleLocation()) + 'Themes\';
end;

class function TSettings.GetSettingsFileName: string;
begin
  Result := IncludeTrailingPathDelimiter(GetSettingsPath) + 'Settings.ini';
end;

class function TSettings.GetSettingsPath: string;
begin
  Result := IncludeTrailingPathDelimiter(GetSpecialFolder(CSIDL_APPDATA)) + 'DelphiPreviewHandler\';
  System.SysUtils.ForceDirectories(Result);
end;

class function TSettings.GetThemeNameFromFile(const FileName: string): string;
begin
  Result := Copy(ExtractFileName(FileName), 1, Pos('.theme', ExtractFileName(FileName)) - 1);
end;

procedure TSettings.ReadSettings;
var
  Settings: TIniFile;
begin
  try
    TLogPreview.Add('ReadSettings '+SettingsFileName);
    Settings := TIniFile.Create(SettingsFileName);
    try
      FSyntaxHighlightTheme := Settings.ReadString('Global', 'ThemeFile', sDefaultThemeName);
      FFontSize := Settings.ReadInteger('Global', 'FontSize', 10);
      FFontName := Settings.ReadString('Global', 'FontName', 'Consolas');
      FStyleName := Settings.ReadString('Global', 'StyleName', 'Glow');
      FSynSelectionMode := TSynSelectionMode(Settings.ReadInteger('Global', 'SelectionMode', Ord(smNormal)));
    finally
      Settings.Free;
    end;
  except
    on E: Exception do
      TLogPreview.Add(Format('Error in TSettings.ReadSettings - Message : %s : Trace %s', [E.Message, E.StackTrace]));
  end;
end;

procedure TSettings.WriteSettings;
var
  Settings: TIniFile;
begin
  try
    TLogPreview.Add('WriteSettings '+SettingsFileName);
    Settings := TIniFile.Create(SettingsFileName);
    try
      Settings.WriteString('Global', 'ThemeFile', FSyntaxHighlightTheme);
      Settings.WriteInteger('Global', 'FontSize', FFontSize);
      Settings.WriteString('Global', 'FontName', FFontName);
      Settings.WriteString('Global', 'StyleName', FStyleName);
      Settings.WriteInteger('Global', 'SelectionMode', Ord(FSynSelectionMode));
    finally
      Settings.Free;
    end;
  except
    on E: Exception do
      TLogPreview.Add(Format('Error in TSettings.WriteSettings - Message : %s : Trace %s', [E.Message, E.StackTrace]));
  end;
end;

procedure TFrmSettings.Button1Click(Sender: TObject);
begin
  Close;
end;

procedure TFrmSettings.ButtonSaveClick(Sender: TObject);
var
  s : string;
begin

  s:= Format('Do you want save the current settings? %s', ['']);
  if not SameText(FOldStyle, CbVCLStyles.Text) then
    s := s + sLineBreak + 'Note: Some settings will be aplied when the explorer is restarted';

  if Application.MessageBox(PChar(s), 'Confirmation', MB_YESNO + MB_ICONQUESTION)= IDYES then
  begin
    FSettings.FontName := CbFont.Text;
    FSettings.FontSize := UpDown1.Position;
    FSettings.SyntaxHighlightTheme := cbSyntaxTheme.Text + sThemesExt;
    FSettings.StyleName := CbVCLStyles.Text;
    FSettings.SelectionMode := TSynSelectionMode(GetENumValue(TypeInfo(TSynSelectionMode), CbSelectionMode.Text));
    FSettings.WriteSettings;
    FSettingsChanged := True;
    Close;
  end;
end;

procedure TFrmSettings.FillData;
var
  s, Theme: string;
  sDC: Integer;
  LogFont: TLogFont;
  LSelectionMode: TSynSelectionMode;
begin
  if not TDirectory.Exists(TSettings.PathThemes) then
    exit;

  for Theme in TDirectory.GetFiles(TSettings.PathThemes, '*.theme.xml') do
  begin
    s := TSettings.GetThemeNameFromFile(Theme);
    cbSyntaxTheme.Items.Add(s);
  end;

  CbFont.Items.Clear;
  sDC := GetDC(0);
  try
    ZeroMemory(@LogFont, sizeof(LogFont));
    LogFont.lfCharset := DEFAULT_CHARSET;
    EnumFontFamiliesEx(sDC, LogFont, @EnumFontsProc, Winapi.Windows.LPARAM(CbFont.Items), 0);
  finally
    ReleaseDC(0, sDC);
  end;

  for LSelectionMode := smNormal to smColumn do
    CbSelectionMode.Items.Add(GetEnumName(TypeInfo(TSynSelectionMode), Ord(LSelectionMode)));

  for s in TStyleManager.StyleNames do
    CbVCLStyles.Items.Add(s);
end;

procedure TFrmSettings.FormCreate(Sender: TObject);
begin
  FSettingsChanged := False;
  FSettings := TSettings.Create;
  FillData;
end;

procedure TFrmSettings.FormDestroy(Sender: TObject);
begin
  FSettings.Free;
end;

procedure TFrmSettings.LoadCurrentValues(SynEdit: TSynEdit; const ThemeName: string);
begin
  FOldStyle :=   TStyleManager.ActiveStyle.Name;
  FSettings.SyntaxHighlightTheme := ThemeName;
  FSettings.FontSize := SynEdit.Font.Size;
  FSettings.FontName := SynEdit.Font.Name;
  FSettings.SelectionMode := SynEdit.SelectionMode;
  FSettings.StyleName := TStyleManager.ActiveStyle.Name;

  CbFont.ItemIndex := CbFont.Items.IndexOf(FSettings.FontName);
  UpDown1.Position := FSettings.FontSize;
  cbSyntaxTheme.ItemIndex := cbSyntaxTheme.Items.IndexOf(TSettings.GetThemeNameFromFile(FSettings.SyntaxHighlightTheme));
  CbVCLStyles.ItemIndex := CbVCLStyles.Items.IndexOf(FSettings.StyleName);
  CbSelectionMode.ItemIndex := CbSelectionMode.Items.IndexOf(GetEnumName(TypeInfo(TSynSelectionMode), Ord(FSettings.SelectionMode)));

end;

end.
