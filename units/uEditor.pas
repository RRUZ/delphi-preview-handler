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
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2017 Rodrigo Ruz V.
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
  SynExportHTML, SynExportRTF, SynEditRegexSearch, SynEditMiscClasses,
  SynEditSearch, uSettings;

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
    ToolButtonSearch: TToolButton;
    ToolButtonSelectMode: TToolButton;
    PopupMenuSelectionMode: TPopupMenu;
    Normal1: TMenuItem;
    Columns1: TMenuItem;
    Lines1: TMenuItem;
    PopupMenuThemes: TPopupMenu;
    ToolButtonThemes: TToolButton;
    CoolBar1: TCoolBar;
    StatusBar1: TStatusBar;
    SynEditSearch1: TSynEditSearch;
    SynEditRegexSearch1: TSynEditRegexSearch;
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
    procedure ToolButtonSearchClick(Sender: TObject);
    procedure ToolButtonSelectModeClick(Sender: TObject);
    procedure ToolButtonExportClick(Sender: TObject);
    procedure ToolButtonThemesClick(Sender: TObject);
  private
    FCurrentTheme: TIDETheme;
    FFileName: string;
    FRefreshSynHighlighter: TProcRefreshSynHighlighter;
    FListThemes: TStringList;
    fSearchFromCaret: boolean;
    FSettings: TSettings;

    class var FExtensions: TDictionary<TSynCustomHighlighterClass, TStrings>;
    class var  FAParent : TWinControl;

    procedure AppException(Sender: TObject; E: Exception);
    function GetHighlighter: TSynCustomHighlighter;
    procedure RunRefreshHighlighter;
    procedure MenuThemeOnCLick(Sender: TObject);
    procedure ShowSearchDialog;
    procedure DoSearchText(ABackwards: boolean);
  public
    procedure FillThemes;
    procedure LoadCurrentTheme;
    property RefreshSynHighlighter: TProcRefreshSynHighlighter read FRefreshSynHighlighter write FRefreshSynHighlighter;

    class property Extensions: TDictionary<TSynCustomHighlighterClass, TStrings> read FExtensions write FExtensions;
    class property AParent : TWinControl read  FAParent write FAParent;
    procedure LoadFile(const FileName: string);
  end;


implementation

uses
  SynEditTypes,
  Vcl.Clipbrd,
  Vcl.Themes,
  uLogExcept,
  System.Types,
  Registry, uMisc, IOUtils, ShellAPI, ComObj, IniFiles, GraphUtil, uAbout,
  dlgSearchText;

const
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
  TMenuItem(Sender).Checked := True;
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

procedure TFrmEditor.DoSearchText(ABackwards: boolean);
var
  Options: TSynSearchOptions;
begin
  StatusBar1.SimpleText := '';
  Options := [];
  if ABackwards then
    Include(Options, ssoBackwards);
  if gbSearchCaseSensitive then
    Include(Options, ssoMatchCase);
  if not fSearchFromCaret then
    Include(Options, ssoEntireScope);
  if gbSearchSelectionOnly then
    Include(Options, ssoSelectedOnly);
  if gbSearchWholeWords then
    Include(Options, ssoWholeWord);

  if gbSearchRegex then
    SynEdit1.SearchEngine := SynEditRegexSearch1
  else
    SynEdit1.SearchEngine := SynEditSearch1;

  if SynEdit1.SearchReplace(gsSearchText, gsReplaceText, Options) = 0 then
  begin
    MessageBeep(MB_ICONASTERISK);
    StatusBar1.SimpleText := STextNotFound;
    if ssoBackwards in Options then
      SynEdit1.BlockEnd := SynEdit1.BlockBegin
    else
      SynEdit1.BlockBegin := SynEdit1.BlockEnd;
    SynEdit1.CaretXY := SynEdit1.BlockBegin;
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

procedure TFrmEditor.FillThemes;
var
  s, Theme: string;
  LMenuItem: TMenuItem;
begin
  if not TDirectory.Exists(TSettings.PathThemes) then
    exit;

  for Theme in TDirectory.GetFiles(TSettings.PathThemes, '*' + sThemesExt) do
  begin
    s := TSettings.GetThemeNameFromFile(Theme);
    FListThemes.Add(s);
    LMenuItem := TMenuItem.Create(PopupMenuThemes);
    PopupMenuThemes.Items.Add(LMenuItem);
    LMenuItem.Caption := s;
    LMenuItem.RadioItem := True;
    LMenuItem.OnClick := MenuThemeOnCLick;
    LMenuItem.Tag := FListThemes.Count - 1;
  end;

  // if ComboBoxThemes.Items.Count > 0 then
  // ComboBoxThemes.ItemIndex := ComboBoxThemes.Items.IndexOf(GetThemeNameFromFile(ThemeName));
end;

procedure TFrmEditor.FormCreate(Sender: TObject);
begin
  FSettings := TSettings.Create;

  Application.OnException := AppException;
  TLogPreview.Add('FormCreate');
  SynEdit1.Font.Size := FSettings.FontSize;
  SynEdit1.Font.Name := FSettings.FontName;
  SynEdit1.SelectionMode := FSettings.SelectionMode;
  FListThemes := TStringList.Create;
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
  TMenuItem(Sender).Checked := True;
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
  i: integer;
begin
  TLogPreview.Add('TFrmEditor.LoadCurrentTheme Init');
  FileName := IncludeTrailingPathDelimiter(TSettings.PathThemes) + FSettings.SyntaxHighlightTheme;
  LoadThemeFromXMLFile(FCurrentTheme, FileName);
  RunRefreshHighlighter;

  for i := 0 to PopupMenuThemes.Items.Count - 1 do
    if SameText(FListThemes[PopupMenuThemes.Items[i].Tag], TSettings.GetThemeNameFromFile(FSettings.SyntaxHighlightTheme)) then
    begin
      PopupMenuThemes.Items[i].Checked := True;
      Break;
    end;

  TLogPreview.Add('TFrmEditor.LoadCurrentTheme Done');
end;

procedure TFrmEditor.MenuThemeOnCLick(Sender: TObject);
var
  FileName: string;
begin
  TMenuItem(Sender).Checked := True;
  FileName := FListThemes[TMenuItem(Sender).Tag];
  FileName := IncludeTrailingPathDelimiter(TSettings.PathThemes) + FileName + sThemesExt;
  LoadThemeFromXMLFile(FCurrentTheme, FileName);
  RunRefreshHighlighter();

  SynExporterHTML1.Color := GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[TIDEHighlightElements.Whitespace].BackgroundColorNew),
    DelphiXE);

  SynExporterRTF1.Color := GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[TIDEHighlightElements.Whitespace].BackgroundColorNew),
    DelphiXE);
end;

procedure TFrmEditor.Normal1Click(Sender: TObject);
begin
  TMenuItem(Sender).Checked := True;
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

procedure TFrmEditor.ShowSearchDialog;
var
  LTextSearchDialog: TTextSearchDialog;
  LRect: TRect;
  i: integer;
begin
  for i := 0 to Screen.FormCount - 1 do
    if Screen.Forms[i].ClassType = TTextSearchDialog then
    begin
      Screen.Forms[i].BringToFront;
      exit;
    end;

  StatusBar1.SimpleText := '';
  LTextSearchDialog := TTextSearchDialog.Create(Self);
  try
    LTextSearchDialog.SearchBackwards := gbSearchBackwards;
    LTextSearchDialog.SearchCaseSensitive := gbSearchCaseSensitive;
    LTextSearchDialog.SearchFromCursor := gbSearchFromCaret;
    LTextSearchDialog.SearchInSelectionOnly := gbSearchSelectionOnly;

    LTextSearchDialog.SearchText := gsSearchText;
    if gbSearchTextAtCaret then
    begin
      if SynEdit1.SelAvail and (SynEdit1.BlockBegin.Line = SynEdit1.BlockEnd.Line) then
        LTextSearchDialog.SearchText := SynEdit1.SelText
      else
        LTextSearchDialog.SearchText := SynEdit1.GetWordAtRowCol(SynEdit1.CaretXY);
    end;

    LTextSearchDialog.SearchTextHistory := gsSearchTextHistory;
    LTextSearchDialog.SearchWholeWords := gbSearchWholeWords;

    if Self.Parent <> nil then
    begin
      GetWindowRect(Self.Parent.ParentWindow, LRect);
      LTextSearchDialog.Left := (LRect.Left + LRect.Right - LTextSearchDialog.Width) div 2;
      LTextSearchDialog.Top := (LRect.Top + LRect.Bottom - LTextSearchDialog.Height) div 2;
    end;

    if LTextSearchDialog.ShowModal() = mrOK then
    begin
      gbSearchBackwards := LTextSearchDialog.SearchBackwards;
      gbSearchCaseSensitive := LTextSearchDialog.SearchCaseSensitive;
      gbSearchFromCaret := LTextSearchDialog.SearchFromCursor;
      gbSearchSelectionOnly := LTextSearchDialog.SearchInSelectionOnly;
      gbSearchWholeWords := LTextSearchDialog.SearchWholeWords;
      gbSearchRegex := LTextSearchDialog.SearchRegularExpression;
      gsSearchText := LTextSearchDialog.SearchText;
      gsSearchTextHistory := LTextSearchDialog.SearchTextHistory;
      fSearchFromCaret := gbSearchFromCaret;

      if gsSearchText <> '' then
      begin
        DoSearchText(gbSearchBackwards);
        fSearchFromCaret := True;
      end;
    end;
  finally
    LTextSearchDialog.Free;
  end;
end;

procedure TFrmEditor.ToolButtonAboutClick(Sender: TObject);
var
  LFrm: TFrmAbout;
  LRect: TRect;
  i: integer;
begin

  for i := 0 to Screen.FormCount - 1 do
    if Screen.Forms[i].ClassType = TFrmAbout then
    begin
      Screen.Forms[i].BringToFront;
      exit;
    end;

  LFrm := TFrmAbout.Create(nil);
  try
    if Self.Parent <> nil then
    begin
      GetWindowRect(Self.Parent.ParentWindow, LRect);
      LFrm.Left := (LRect.Left + LRect.Right - LFrm.Width) div 2;
      LFrm.Top := (LRect.Top + LRect.Bottom - LFrm.Height) div 2;
    end;

    LFrm.ShowModal();
  finally
    LFrm.Free;
  end;
end;

procedure TFrmEditor.ToolButtonExportClick(Sender: TObject);
begin
  TToolButton(Sender).CheckMenuDropdown;
end;

procedure TFrmEditor.ToolButtonSaveClick(Sender: TObject);
var
  LFrm: TFrmSettings;
  LRect: TRect;
  Theme: string;
  i: integer;
begin

  for i := 0 to Screen.FormCount - 1 do
    if Screen.Forms[i].ClassType = TFrmSettings then
    begin
      Screen.Forms[i].BringToFront;
      exit;
    end;

  LFrm := TFrmSettings.Create(nil);
  try
    for i := 0 to PopupMenuThemes.Items.Count - 1 do

      if PopupMenuThemes.Items[i].Checked then
      begin
        Theme := FListThemes[PopupMenuThemes.Items[i].Tag];
        Break;
      end;

    LFrm.LoadCurrentValues(SynEdit1, Theme + sThemesExt);
    if Self.Parent <> nil then
    begin
      GetWindowRect(Self.Parent.ParentWindow, LRect);
      LFrm.Left := (LRect.Left + LRect.Right - LFrm.Width) div 2;
      LFrm.Top := (LRect.Top + LRect.Bottom - LFrm.Height) div 2;
    end;
    // if Self.Parent <> nil then
    // LFrm.ParentWindow:=Self.Parent.ParentWindow;

    LFrm.ShowModal();
    if LFrm.SettingsChanged then
    begin
      FSettings.ReadSettings;
      SynEdit1.Font.Size := FSettings.FontSize;
      SynEdit1.Font.Name := FSettings.FontName;
      SynEdit1.SelectionMode := FSettings.SelectionMode;
      //TStyleManager.TrySetStyle(FSettings.StyleName, false);

      for i := 0 to PopupMenuThemes.Items.Count - 1 do
        if SameText(FListThemes[PopupMenuThemes.Items[i].Tag], TSettings.GetThemeNameFromFile(FSettings.SyntaxHighlightTheme)) then
        begin
          MenuThemeOnCLick(PopupMenuThemes.Items[i]);
          Break;
        end;
    end;

  finally
    LFrm.Free;
  end;
end;

procedure TFrmEditor.ToolButtonSearchClick(Sender: TObject);
begin
  ShowSearchDialog();
end;

procedure TFrmEditor.ToolButtonSelectModeClick(Sender: TObject);
begin
  TToolButton(Sender).CheckMenuDropdown;
end;

procedure TFrmEditor.ToolButtonThemesClick(Sender: TObject);
begin
  TToolButton(Sender).CheckMenuDropdown;
end;


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
