// **************************************************************************************************
//
// Unit uEditor
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
// The Original Code is uEditor.pas.
//
// The Initial Developer of the Original Code is Rodrigo Ruz V.
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2015 Rodrigo Ruz V.
// All Rights Reserved.
//
// *************************************************************************************************

unit uEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, SynEdit, pngimage,
  System.Generics.Collections,
  SynEditHighlighter,
  uDelphiIDEHighlight,
  uDelphiVersions,
  SynHighlighterPas, ComCtrls, ToolWin, ImgList, SynHighlighterXML,
  SynHighlighterCpp, SynHighlighterAsm, uSynEditPopupEdit,
  SynHighlighterFortran, SynHighlighterEiffel, SynHighlighterPython,
  SynHighlighterPerl, SynHighlighterDfm, SynHighlighterBat,
  SynHighlighterVBScript, SynHighlighterPHP, SynHighlighterJScript,
  SynHighlighterHtml, SynHighlighterCSS, SynHighlighterCS, SynHighlighterCobol,
  SynHighlighterVB, SynHighlighterM3, SynHighlighterJava, SynHighlighterSml,
  SynHighlighterIni, SynHighlighterInno, SynHighlighterSQL,
  SynHighlighterUNIXShellScript, SynHighlighterRuby, Vcl.Menus, SynEditExport,
  SynExportHTML, SynExportRTF;

type
  TProcRefreshSynHighlighter = procedure(FCurrentTheme: TIDETheme; SynEdit: SynEdit.TSynEdit);

  TFrmEditor = class(TForm)
    SynEdit1: TSynEdit;
    PanelTop: TPanel;
    SynPasSyn1: TSynPasSyn;
    PanelEditor: TPanel;
    ImageList1: TImageList;
    ToolBar1: TToolBar;
    ToolButtonZoomIn: TToolButton;
    ToolButtonZommOut: TToolButton;
    ToolButtonAbout: TToolButton;
    ToolButtonSave: TToolButton;
    PanelToolBar: TPanel;
    SynXMLSyn1: TSynXMLSyn;
    SynCppSyn1: TSynCppSyn;
    SynAsmSyn1: TSynAsmSyn;
    SynEiffelSyn1: TSynEiffelSyn;
    SynFortranSyn1: TSynFortranSyn;
    SynJavaSyn1: TSynJavaSyn;
    SynVBSyn1: TSynVBSyn;
    SynCobolSyn1: TSynCobolSyn;
    SynCSSyn1: TSynCSSyn;
    SynCssSyn1: TSynCssSyn;
    SynHTMLSyn1: TSynHTMLSyn;
    SynJScriptSyn1: TSynJScriptSyn;
    SynPHPSyn1: TSynPHPSyn;
    SynVBScriptSyn1: TSynVBScriptSyn;
    SynBatSyn1: TSynBatSyn;
    SynDfmSyn1: TSynDfmSyn;
    SynPerlSyn1: TSynPerlSyn;
    SynPythonSyn1: TSynPythonSyn;
    SynRubySyn1: TSynRubySyn;
    SynUNIXShellScriptSyn1: TSynUNIXShellScriptSyn;
    SynSQLSyn1: TSynSQLSyn;
    SynInnoSyn1: TSynInnoSyn;
    SynIniSyn1: TSynIniSyn;
    ToolButton1: TToolButton;
    ToolButtonExport: TToolButton;
    PopupMenuExport: TPopupMenu;
    SynExporterHTML1: TSynExporterHTML;
    ExporttoHTML1: TMenuItem;
    SynExporterRTF1: TSynExporterRTF;
    dlgFileSaveAs: TSaveDialog;
    N1: TMenuItem;
    Copynativeformattoclipboard1: TMenuItem;
    Copyastexttoclipboard1: TMenuItem;
    ExporttoRTF1: TMenuItem;
    ToolButton2: TToolButton;
    ToolButtonSelectMode: TToolButton;
    PopupMenuSelectionMode: TPopupMenu;
    Normal1: TMenuItem;
    Columns1: TMenuItem;
    Lines1: TMenuItem;
    PopupMenuThemes: TPopupMenu;
    ToolButtonThemes: TToolButton;
    CoolBar1: TCoolBar;
    procedure FormCreate(Sender: TObject);
    procedure ToolButtonZoomInClick(Sender: TObject);
    procedure ToolButtonZommOutClick(Sender: TObject);
    procedure ToolButtonSaveClick(Sender: TObject);
    procedure ToolButtonAboutClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ExporttoHTML1Click(Sender: TObject);
    procedure Copynativeformattoclipboard1Click(Sender: TObject);
    procedure Copyastexttoclipboard1Click(Sender: TObject);
    procedure ExporttoRTF1Click(Sender: TObject);
    procedure Normal1Click(Sender: TObject);
    procedure Columns1Click(Sender: TObject);
    procedure Lines1Click(Sender: TObject);
  private
    FCurrentTheme: TIDETheme;
    FPathThemes: string;
    FThemeName: string;
    FFileName: string;
    FRefreshSynHighlighter: TProcRefreshSynHighlighter;
    FExtensions: TDictionary<TSynCustomHighlighterClass, TStrings>;
    FListThemes  : TStringList;
    function GetThemeNameFromFile(const FileName: string): string;
    procedure AppException(Sender: TObject; E: Exception);
    function GetHighlighter: TSynCustomHighlighter;
    procedure RunRefreshHighlighter;
    procedure MenuThemeOnCLick(Sender: TObject);
  public
    procedure FillThemes;
    procedure LoadCurrentTheme;
    property PathThemes: string read FPathThemes write FPathThemes;
    property ThemeName: string read FThemeName write FThemeName;
    property RefreshSynHighlighter: TProcRefreshSynHighlighter read FRefreshSynHighlighter write FRefreshSynHighlighter;

    property Extensions: TDictionary<TSynCustomHighlighterClass, TStrings> read FExtensions write FExtensions;
    procedure LoadFile(const FileName: string);
  end;


var
  FrmEditor: TFrmEditor;

implementation

uses
  SynEditTypes,
  Vcl.Clipbrd,
  uLogExcept,
  System.Types,
  Registry, uMisc, IOUtils, ShellAPI, ComObj, IniFiles, GraphUtil, uAbout;

const
  sThemesExt = '.theme.xml';
  sSettingsLocation = 'DelphiPreviewHandler';
  sDefaultThemeName = 'nightfall.theme.xml';
  MaxfontSize = 30;
  MinfontSize = 8;

{$R *.dfm}


{ TFrmEditor }

procedure TFrmEditor.AppException(Sender: TObject; E: Exception);
begin
  // log unhandled exceptions (TSynEdit, etc)
  TLogPreview.Add('AppException');
  TLogPreview.Add(E);
end;

procedure TFrmEditor.Columns1Click(Sender: TObject);
begin
 TMenuItem(Sender).Checked:=True;
 SynEdit1.SelectionMode := smColumn;
end;

procedure TFrmEditor.Copyastexttoclipboard1Click(Sender: TObject);
var
  Exporter: TSynCustomExporter;
begin
  Exporter := SynExporterRTF1;
  with Exporter do
  begin
    Title := 'Source file exported to clipboard (as text)';
    ExportAsText := True;
    Highlighter := SynEdit1.Highlighter;
    ExportAll(SynEdit1.Lines);
    CopyToClipboard;
  end;
end;

procedure TFrmEditor.Copynativeformattoclipboard1Click(Sender: TObject);
begin
  Clipboard.Open;
  try
    Clipboard.AsText := SynEdit1.Lines.Text;
    with SynExporterRTF1 do
    begin
      Title := 'Source file exported to clipboard (native format)';
      ExportAsText := FALSE;
      Highlighter := SynEdit1.Highlighter;
      ExportAll(SynEdit1.Lines);
      CopyToClipboard;
    end;
  finally
    Clipboard.Close;
  end;
end;

procedure TFrmEditor.ExporttoHTML1Click(Sender: TObject);
var
  FileName: string;
  Exporter: TSynCustomExporter;
begin
  dlgFileSaveAs.Filter := SynExporterHTML1.DefaultFilter;
  if dlgFileSaveAs.Execute then
  begin
    FileName := dlgFileSaveAs.FileName;
    if ExtractFileExt(FileName) = '' then
      FileName := FileName + '.html';
    Exporter := SynExporterHTML1;
    if Assigned(Exporter) then
      with Exporter do
      begin
        Title := 'Source file exported to file';
        Highlighter := SynEdit1.Highlighter;
        ExportAsText := True;
        ExportAll(SynEdit1.Lines);
        SaveToFile(FileName);
      end;
  end;
end;

procedure TFrmEditor.ExporttoRTF1Click(Sender: TObject);
var
  FileName: string;
  Exporter: TSynCustomExporter;
begin
  dlgFileSaveAs.Filter := SynExporterRTF1.DefaultFilter;
  if dlgFileSaveAs.Execute then
  begin
    FileName := dlgFileSaveAs.FileName;
    if ExtractFileExt(FileName) = '' then
      FileName := FileName + '.rtf';
    Exporter := SynExporterRTF1;
    if Assigned(Exporter) then
      with Exporter do
      begin
        Title := 'Source file exported to file';
        Highlighter := SynEdit1.Highlighter;
        ExportAsText := True;
        ExportAll(SynEdit1.Lines);
        SaveToFile(FileName);
      end;
  end;
end;

function TFrmEditor.GetThemeNameFromFile(const FileName: string): string;
begin
  Result := Copy(ExtractFileName(FileName), 1, Pos('.theme', ExtractFileName(FileName)) - 1);
end;

procedure TFrmEditor.FillThemes;
var
  s, Theme: string;
  LMenuItem : TMenuItem;
begin
  if not TDirectory.Exists(PathThemes) then
    exit;

    for Theme in TDirectory.GetFiles(PathThemes, '*.theme.xml') do
    begin
      s := GetThemeNameFromFile(Theme);
      FListThemes.Add(s);
      LMenuItem:=TMenuItem.Create(PopupMenuThemes);
      PopupMenuThemes.Items.Add(LMenuItem);
      LMenuItem.Caption:=s;
      LMenuItem.RadioItem:=True;
      LMenuItem.OnClick := MenuThemeOnCLick;
      LMenuItem.Tag:= FListThemes.Count-1;
    end;

//  if ComboBoxThemes.Items.Count > 0 then
//    ComboBoxThemes.ItemIndex := ComboBoxThemes.Items.IndexOf(GetThemeNameFromFile(ThemeName));
end;

procedure TFrmEditor.FormCreate(Sender: TObject);
var
  Settings: TIniFile;
  // i : integer;
begin
  Application.OnException := AppException;
  TLogPreview.Add('FormCreate');
  FListThemes:=TStringList.Create;
  // TLogPreview.Add(Format('Forms %d', [Screen.FormCount]));
  // for i:=0 to Screen.FormCount-1 do
  // TLogPreview.Add(Format('  %s', [Screen.Forms[i].ClassName]));
  Settings := TIniFile.Create(ExtractFilePath(GetAppDataFolder) + 'Settings.ini');
  try
    FPathThemes := Settings.ReadString('Global', 'ThemesPath', 'Themes');
    FPathThemes := IncludeTrailingPathDelimiter(ExtractFilePath(GetDllPath)) + FPathThemes;
    FPathThemes := ExcludeTrailingPathDelimiter(FPathThemes);
    FThemeName := Settings.ReadString('Global', 'ThemeFile', sDefaultThemeName);
    SynEdit1.Font.Size := Settings.ReadInteger('Global', 'FontSize', 10);
  finally
    Settings.Free;
  end;
  FillThemes;
end;

procedure TFrmEditor.FormDestroy(Sender: TObject);
begin
  FListThemes.Free;
  TLogPreview.Add('FormDestroy');
end;

function TFrmEditor.GetHighlighter: TSynCustomHighlighter;
var
  LExt: string;
  LHighlighterClass: TSynCustomHighlighterClass;
  LItem: TPair<TSynCustomHighlighterClass, TStrings>;
  i: integer;
begin
  Result := SynPasSyn1;
  LHighlighterClass := TSynCustomHighlighter;
  LExt := LowerCase(ExtractFileExt(FFileName));
  for LItem in FExtensions do
    if LItem.Value.IndexOf(LExt) >= 0 then
    begin
      LHighlighterClass := LItem.Key;
      Break;
    end;

  for i := 0 to ComponentCount - 1 do
    if (Components[i] is TSynCustomHighlighter) and (Components[i].ClassType = LHighlighterClass) then
    begin
      TLogPreview.Add('found ' + Components[i].Name);
      Result := TSynCustomHighlighter(Components[i]);
      Break;
    end;
end;

procedure TFrmEditor.Lines1Click(Sender: TObject);
begin
 TMenuItem(Sender).Checked:=True;
 SynEdit1.SelectionMode := smLine;
end;

procedure TFrmEditor.LoadFile(const FileName: string);
var
  LSynCustomHighlighter: TSynCustomHighlighter;
begin
  TLogPreview.Add('TFrmEditor.LoadFile Init');
  FFileName := FileName;
  LSynCustomHighlighter := GetHighlighter;
  if SynEdit1.Highlighter <> LSynCustomHighlighter then
  begin
    SynEdit1.Lines.Clear;
    SynEdit1.Highlighter := LSynCustomHighlighter;
    LoadCurrentTheme();

    SynExporterHTML1.Color := GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[TIDEHighlightElements.Whitespace].BackgroundColorNew),
      DelphiXE);

    SynExporterRTF1.Color := GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[TIDEHighlightElements.Whitespace].BackgroundColorNew),
      DelphiXE);
  end;

  SynEdit1.Lines.LoadFromFile(FFileName);
  TLogPreview.Add('TFrmEditor.LoadFile Done');
end;

procedure TFrmEditor.LoadCurrentTheme;
var
  FileName: string;
  i : Integer;
begin
  TLogPreview.Add('TFrmEditor.LoadCurrentTheme Init');
  FileName := IncludeTrailingPathDelimiter(PathThemes) + ThemeName;
  LoadThemeFromXMLFile(FCurrentTheme, FileName);
  RunRefreshHighlighter;

  for i :=0 to PopupMenuThemes.Items.Count-1 do
   if SameText(FListThemes[PopupMenuThemes.Items[i].Tag], GetThemeNameFromFile(ThemeName)) then
   begin
     PopupMenuThemes.Items[i].Checked:=True;
     Break;
   end;

  TLogPreview.Add('TFrmEditor.LoadCurrentTheme Done');
end;

procedure TFrmEditor.MenuThemeOnCLick(Sender: TObject);
var
  FileName: string;
begin
  TMenuItem(Sender).Checked:=True;
  FileName := FListThemes[TMenuItem(Sender).Tag];
  FileName := IncludeTrailingPathDelimiter(PathThemes) + FileName + sThemesExt;
  LoadThemeFromXMLFile(FCurrentTheme, FileName);
  RunRefreshHighlighter();

  SynExporterHTML1.Color := GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[TIDEHighlightElements.Whitespace].BackgroundColorNew),
    DelphiXE);

  SynExporterRTF1.Color := GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[TIDEHighlightElements.Whitespace].BackgroundColorNew),
    DelphiXE);
end;
procedure TFrmEditor.Normal1Click(Sender: TObject);
begin
 TMenuItem(Sender).Checked:=True;
 SynEdit1.SelectionMode := smNormal;
end;

procedure TFrmEditor.RunRefreshHighlighter;
begin
  if SynEdit1.Highlighter <> nil then
    if SynEdit1.Highlighter = SynPasSyn1 then
      RefreshSynPasHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynXMLSyn1 then
      RefreshSynXmlHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynAsmSyn1 then
      RefreshSynAsmHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynBatSyn1 then
      RefreshBatSynHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynCobolSyn1 then
      RefreshSynCobolHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynCppSyn1 then
      RefreshSynCppHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynCSSyn1 then
      RefreshSynCSharpHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynCssSyn1 then
      RefreshSynCSSHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynDfmSyn1 then
      RefreshSynDfmHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynEiffelSyn1 then
      RefreshSynEiffelHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynFortranSyn1 then
      RefreshSynFortranHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynHTMLSyn1 then
      RefreshSynHTMLHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynIniSyn1 then
      RefreshSynIniHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynInnoSyn1 then
      RefreshSynInnoHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynJavaSyn1 then
      RefreshSynJavaHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynJScriptSyn1 then
      RefreshSynJScriptHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynPerlSyn1 then
      RefreshSynPerlHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynPHPSyn1 then
      RefreshSynPhpHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynPythonSyn1 then
      RefreshSynPythonHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynRubySyn1 then
      RefreshSynRubyHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynSQLSyn1 then
      RefreshSynSqlHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynUNIXShellScriptSyn1 then
      RefreshSynUnixHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynVBSyn1 then
      RefreshSynVBHighlighter(FCurrentTheme, SynEdit1)
    else if SynEdit1.Highlighter = SynVBScriptSyn1 then
      RefreshSynVbScriptHighlighter(FCurrentTheme, SynEdit1);
end;

procedure TFrmEditor.ToolButtonAboutClick(Sender: TObject);
var
  LFrm : TFrmAbout;
begin
  LFrm:=TFrmAbout.Create(nil);
  try
   LFrm.ShowModal();
  finally
   LFrm.Free;
  end;
end;

procedure TFrmEditor.ToolButtonSaveClick(Sender: TObject);
var
  Settings : TIniFile;
  Theme : string;
  i : integer;
begin

  for i := 0 to PopupMenuThemes.Items.Count-1  do
    if PopupMenuThemes.Items[i].Checked then
    begin
     Theme := FListThemes[PopupMenuThemes.Items[i].Tag];
     Break;
    end;


  if Application.MessageBox(PChar(Format('Do you want save the current settings? %s', [''])), 'Confirmation', MB_YESNO + MB_ICONQUESTION) = idYes
  then
  begin
    try
      Settings := TIniFile.Create(ExtractFilePath(GetAppDataFolder) + 'Settings.ini');
      // Settings.RootKey:=HKEY_CURRENT_USER;
      // if Settings.OpenKey('\Software\'+sSettingsLocation,true) then
      try
        Settings.WriteString('Global', 'ThemeFile', Theme + sThemesExt);
        Settings.WriteInteger('Global', 'FontSize', SynEdit1.Font.Size);
      finally
        Settings.Free;
      end;
    except
      on E: Exception do
        TLogPreview.Add(Format('Error in TFrmEditor.Save - Message : %s : Trace %s', [E.Message, E.StackTrace]));
    end;
  end;
end;

{
  var
  Settings : TIniFile;
  begin
  Settings:=TIniFile.Create(ExtractFilePath(GetAppDataFolder)+'Settings.ini');
  try
  FPathThemes    := Settings.ReadString('Global', 'ThemesPath', 'Themes');
  FPathThemes    := IncludeTrailingPathDelimiter(ExtractFilePath(GetDllPath))+FPathThemes;
  FPathThemes    := ExcludeTrailingPathDelimiter(FPathThemes);
  FThemeName     := Settings.ReadString('Global', 'ThemeFile',sDefaultThemeName);
  SynEdit1.Font.Size :=Settings.ReadInteger('Global', 'FontSize',10);
  finally
  Settings.Free;
  end;

  FillThemes;
  end;

}

procedure TFrmEditor.ToolButtonZommOutClick(Sender: TObject);
begin
  if SynEdit1.Font.Size > MinfontSize then
    SynEdit1.Font.Size := SynEdit1.Font.Size - 1;
end;

procedure TFrmEditor.ToolButtonZoomInClick(Sender: TObject);
begin
  if SynEdit1.Font.Size < MaxfontSize then
    SynEdit1.Font.Size := SynEdit1.Font.Size + 1;
end;

end.
