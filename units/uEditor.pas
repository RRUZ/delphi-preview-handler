//**************************************************************************************************
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
//*************************************************************************************************



unit uEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, SynEdit, pngimage,
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
  SynHighlighterUNIXShellScript, SynHighlighterRuby;

type
  TProcRefreshSynHighlighter = procedure (FCurrentTheme:TIDETheme;SynEdit: SynEdit.TSynEdit);

  TFrmEditor = class(TForm)
    SynEdit1: TSynEdit;
    PanelBottom: TPanel;
    ComboBoxThemes: TComboBox;
    Image1: TImage;
    SynPasSyn1: TSynPasSyn;
    PanelEditor: TPanel;
    ImageList1: TImageList;
    ToolBar1: TToolBar;
    ToolButtonZoomIn: TToolButton;
    ToolButtonZommOut: TToolButton;
    ToolButtonBugReport: TToolButton;
    ToolButton4: TToolButton;
    ToolButtonSave: TToolButton;
    PanelImage: TPanel;
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
    procedure ComboBoxThemesChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure ToolButtonZoomInClick(Sender: TObject);
    procedure ToolButtonZommOutClick(Sender: TObject);
    procedure ToolButtonSaveClick(Sender: TObject);
    procedure ToolButtonBugReportClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FCurrentTheme:  TIDETheme;
    FPathThemes: string;
    FThemeName: string;
    FRefreshSynHighlighter : TProcRefreshSynHighlighter;
    function GetThemeNameFromFile(const FileName:string):string;
    procedure AppException(Sender: TObject; E: Exception);
  public
    procedure FillThemes;
    procedure LoadTheme;
    property PathThemes : string read FPathThemes write FPathThemes;
    property ThemeName  : string read FThemeName write FThemeName;
    property RefreshSynHighlighter : TProcRefreshSynHighlighter read FRefreshSynHighlighter write FRefreshSynHighlighter;
  end;

    procedure SetSynAttr(FCurrentTheme:TIDETheme;Element: TIDEHighlightElements; SynAttr: TSynHighlighterAttributes;DelphiVersion : TDelphiVersions);
    procedure RefreshSynEdit(FCurrentTheme:TIDETheme;SynEdit: SynEdit.TSynEdit);

var
  FrmEditor: TFrmEditor;

implementation

uses
  uLogExcept,
  System.Types,
  Registry, uMisc, IOUtils, ShellAPI, ComObj, IniFiles, GraphUtil;

const
  sThemesExt          ='.theme.xml';
  sSettingsLocation   ='DelphiPreviewHandler';
  sDefaultThemeName   ='nightfall.theme.xml';
  MaxfontSize = 30;
  MinfontSize = 8;

{$R *.dfm}


procedure SetSynAttr(FCurrentTheme:TIDETheme;Element: TIDEHighlightElements; SynAttr: TSynHighlighterAttributes; DelphiVersion: TDelphiVersions);
begin
  SynAttr.Background := GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[Element].BackgroundColorNew),DelphiVersion);
  SynAttr.Foreground := GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[Element].ForegroundColorNew),DelphiVersion);
  SynAttr.Style      := [];
  if FCurrentTheme[Element].Bold then
    SynAttr.Style := SynAttr.Style + [fsBold];
  if FCurrentTheme[Element].Italic then
    SynAttr.Style := SynAttr.Style + [fsItalic];
  if FCurrentTheme[Element].Underline then
    SynAttr.Style := SynAttr.Style + [fsUnderline];
end;

procedure RefreshSynEdit(FCurrentTheme:TIDETheme;SynEdit: SynEdit.TSynEdit);
var
  Element   : TIDEHighlightElements;
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;

    Element := TIDEHighlightElements.RightMargin;
    SynEdit.RightEdgeColor :=
      GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[Element].ForegroundColorNew),DelphiVer);

    Element := TIDEHighlightElements.MarkedBlock;
    SynEdit.SelectedColor.Foreground :=
      GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[Element].ForegroundColorNew),DelphiVer);
    SynEdit.SelectedColor.Background :=
      GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[Element].BackgroundColorNew),DelphiVer);

    Element := TIDEHighlightElements.LineNumber;
    SynEdit.Gutter.Color := StringToColor(FCurrentTheme[Element].BackgroundColorNew);
    SynEdit.Gutter.Font.Color :=
      GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[Element].ForegroundColorNew),DelphiVer);

    Element := TIDEHighlightElements.PlainText;
    SynEdit.Gutter.BorderColor := GetHighLightColor(StringToColor(FCurrentTheme[Element].BackgroundColorNew));

    Element := TIDEHighlightElements.LineHighlight;
    SynEdit.ActiveLineColor :=
      GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[Element].BackgroundColorNew),DelphiVer);

end;

{ TFrmEditor }

procedure TFrmEditor.AppException(Sender: TObject; E: Exception);
begin
  //log unhandled exceptions (TSynEdit, etc)
  TLogPreview.Add('AppException');
  TLogPreview.Add(E);
end;

procedure TFrmEditor.ComboBoxThemesChange(Sender: TObject);
var
 FileName : string;
begin
  FileName:=TComboBox(Sender).Text;
  FileName:=IncludeTrailingPathDelimiter(PathThemes)+FileName+sThemesExt;
  LoadThemeFromXMLFile(FCurrentTheme, FileName);
  FRefreshSynHighlighter(FCurrentTheme,SynEdit1);
end;

function TFrmEditor.GetThemeNameFromFile(const FileName:string): string;
begin
   Result:=Copy(ExtractFileName(FileName), 1, Pos('.theme', ExtractFileName(FileName)) - 1);
end;

procedure TFrmEditor.Image1Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'http://theroadtodelphi.wordpress.com',nil,nil, SW_SHOWNORMAL) ;
end;

procedure TFrmEditor.FillThemes;
var
  Theme   : string;
begin
  if not TDirectory.Exists(PathThemes) then
    exit;

  try
    ComboBoxThemes.Items.BeginUpdate;
    ComboBoxThemes.Items.Clear;
    for Theme in TDirectory.GetFiles(PathThemes, '*.theme.xml') do
      ComboBoxThemes.Items.Add(GetThemeNameFromFile(Theme));
  finally
    ComboBoxThemes.Items.EndUpdate;
  end;

    if ComboBoxThemes.Items.Count>0 then
    ComboBoxThemes.ItemIndex:=ComboBoxThemes.Items.IndexOf(GetThemeNameFromFile(ThemeName));
end;

procedure TFrmEditor.FormCreate(Sender: TObject);
var
  Settings : TIniFile;
  i : integer;
begin
   Application.OnException := AppException;

   TLogPreview.Add('FormCreate');
   TLogPreview.Add(Format('Forms %d', [Screen.FormCount]));
    for i:=0 to Screen.FormCount-1 do
      TLogPreview.Add(Format('  %s', [Screen.Forms[i].ClassName]));


   Settings:=TIniFile.Create(ExtractFilePath(GetAppDataFolder)+'Settings.ini');
   try
     FPathThemes    := Settings.ReadString('Global', 'ThemesPath', 'Themes');
     FPathThemes    := IncludeTrailingPathDelimiter(ExtractFilePath(GetDllPath))+FPathThemes;
     FPathThemes    := ExcludeTrailingPathDelimiter(FPathThemes);
     FThemeName     := Settings.ReadString('Global', 'ThemeFile', sDefaultThemeName);
     SynEdit1.Font.Size :=Settings.ReadInteger('Global', 'FontSize', 10);
   finally
     Settings.Free;
   end;

  FillThemes;
end;


procedure TFrmEditor.FormDestroy(Sender: TObject);
begin
   TLogPreview.Add('FormDestroy');
end;

procedure TFrmEditor.LoadTheme;
var
 FileName : string;
begin
  FileName:=ThemeName;
  FileName:=IncludeTrailingPathDelimiter(PathThemes)+FileName;
  LoadThemeFromXMLFile(FCurrentTheme, FileName);
  FRefreshSynHighlighter(FCurrentTheme,SynEdit1);
end;


procedure TFrmEditor.ToolButtonBugReportClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'https://github.com/RRUZ/delphi-preview-handler/issues', nil, nil, SW_SHOWNORMAL) ;
end;

procedure TFrmEditor.ToolButtonSaveClick(Sender: TObject);
var
  Settings    : TIniFile;
  Theme       : string;
begin
  Theme:=ComboBoxThemes.Text;
  if Application.MessageBox(PChar(Format('Do you want save the current settings? %s',[''])), 'Confirmation', MB_YESNO + MB_ICONQUESTION) = idYes then
  begin
    try
      Settings:=TIniFile.Create(ExtractFilePath(GetAppDataFolder)+'Settings.ini');
      //Settings.RootKey:=HKEY_CURRENT_USER;
      //if Settings.OpenKey('\Software\'+sSettingsLocation,true) then
      try
       Settings.WriteString('Global', 'ThemeFile', Theme+sThemesExt);
       Settings.WriteInteger('Global', 'FontSize', SynEdit1.Font.Size);
      finally
       Settings.Free;
      end;
    except
      on E: Exception do
        TLogPreview.Add(Format('Error in TFrmEditor.Save - Message : %s : Trace %s',
          [E.Message, E.StackTrace]));
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
  if SynEdit1.Font.Size>MinfontSize then
   SynEdit1.Font.Size:=SynEdit1.Font.Size-1;
end;

procedure TFrmEditor.ToolButtonZoomInClick(Sender: TObject);
begin
  if SynEdit1.Font.Size<MaxfontSize then
   SynEdit1.Font.Size:=SynEdit1.Font.Size+1;
end;

end.
