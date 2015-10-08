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
  SynHighlighterUNIXShellScript, SynHighlighterRuby;

type
  TProcRefreshSynHighlighter = procedure (FCurrentTheme:TIDETheme; SynEdit: SynEdit.TSynEdit);

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
    ToolButton1: TToolButton;
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
    FFileName : string;
    FRefreshSynHighlighter : TProcRefreshSynHighlighter;
    FExtensions: TDictionary<TSynCustomHighlighterClass, TStrings>;
    function GetThemeNameFromFile(const FileName:string):string;
    procedure AppException(Sender: TObject; E: Exception);
    function  GetHighlighter : TSynCustomHighlighter;
    procedure RunRefreshHighlighter;
  public
    procedure FillThemes;
    procedure LoadTheme;
    property PathThemes : string read FPathThemes write FPathThemes;
    property ThemeName  : string read FThemeName write FThemeName;
    property RefreshSynHighlighter : TProcRefreshSynHighlighter read FRefreshSynHighlighter write FRefreshSynHighlighter;


    property  Extensions  : TDictionary<TSynCustomHighlighterClass, TStrings>  read  FExtensions write FExtensions;
    procedure LoadFile(const FileName : string);
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

procedure RefreshSynPasHighlighter(FCurrentTheme:TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;

    RefreshSynEdit(FCurrentTheme, SynEdit);

    with TSynPasSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Assembler, AsmAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Character, CharAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Preprocessor, DirectiveAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Float, FloatAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Hex, HexAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
    end;
end;

procedure RefreshSynCobolHighlighter(FCurrentTheme:TIDETheme;SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynCobolSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, AreaAIdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Preprocessor, PreprocessorAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, BooleanAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, SequenceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, IndicatorAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, TagAreaAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.EnabledBreak, DebugLinesAttri, DelphiVer);
    end;
end;

procedure RefreshSynCppHighlighter(FCurrentTheme:TIDETheme;SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynCppSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Assembler, AsmAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Character, CharAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Preprocessor, DirecAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Float, FloatAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Hex, HexAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Preprocessor, InvalidAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, OctalAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
    end;
end;


procedure RefreshSynCSharpHighlighter(FCurrentTheme:TIDETheme;SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynCSSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Assembler, AsmAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Preprocessor, DirecAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ErrorLine, InvalidAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
    end;
end;

procedure RefreshSynCSSHighlighter(FCurrentTheme:TIDETheme;SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynCssSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, PropertyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, ColorAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.PlainText, TextAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, ValueAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, UndefPropertyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, ImportantPropertyAttri, DelphiVer);
    end;
end;


procedure RefreshSynDfmHighlighter(FCurrentTheme:TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynDfmSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
    end;
end;

procedure RefreshSynEiffelHighlighter(FCurrentTheme:TIDETheme;SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynEiffelSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, BasicTypesAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, LaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, OperatorAndSymbolsAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, PredefinedAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, ResultValueAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
    end;
end;

procedure RefreshSynFortranHighlighter(FCurrentTheme:TIDETheme;SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynFortranSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
    end;
end;

procedure RefreshSynHTMLHighlighter(FCurrentTheme:TIDETheme;SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynHTMLSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, AndAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.PlainText, TextAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, UndefKeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, ValueAttri, DelphiVer);
    end;
end;

procedure RefreshSynIniHighlighter(FCurrentTheme:TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynIniSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, TextAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, SectionAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
    end;
end;

procedure RefreshSynInnoHighlighter(FCurrentTheme:TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynInnoSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, ConstantAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ErrorLine, InvalidAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, ParameterAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, SectionAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
    end;
end;

procedure RefreshSynJavaHighlighter(FCurrentTheme:TIDETheme;SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynJavaSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, DocumentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.IllegalChar, InvalidAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
    end;
end;


procedure RefreshSynJScriptHighlighter(FCurrentTheme:TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynJScriptSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, NonReservedKeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, EventAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
    end;
end;

procedure RefreshSynPerlHighlighter(FCurrentTheme:TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynPerlSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ErrorLine, InvalidAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, OperatorAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Preprocessor, PragmaAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, VariableAttri, DelphiVer);
    end;
end;

procedure RefreshSynPhpHighlighter(FCurrentTheme:TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynPHPSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, VariableAttri, DelphiVer);
    end;
end;

procedure RefreshSynPythonHighlighter(FCurrentTheme:TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynPythonSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, NonKeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, SystemAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Hex, OctalAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Hex, HexAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Float, FloatAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Preprocessor, DocStringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ErrorLine, ErrorAttri, DelphiVer);
    end;
end;

procedure RefreshSynRubyHighlighter(FCurrentTheme:TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynRubySyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, SecondKeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
    end;
end;

procedure RefreshSynSqlHighlighter(FCurrentTheme:TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynSQLSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Preprocessor, ConditionalCommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, DataTypeAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, DefaultPackageAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, DelimitedIdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ErrorLine, ExceptionAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, FunctionAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, PLSQLAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, SQLPlusAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, TableNameAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, VariableAttri, DelphiVer);
    end;
end;

procedure RefreshSynUnixHighlighter(FCurrentTheme:TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynUNIXShellScriptSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, SecondKeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, VarAttri, DelphiVer);
    end;
end;


procedure RefreshSynVBHighlighter(FCurrentTheme:TIDETheme;SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynVBSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
    end;
end;

procedure RefreshSynVbScriptHighlighter(FCurrentTheme:TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynVBScriptSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, StringAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Symbol, SymbolAttri, DelphiVer);
    end;
end;

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


procedure RefreshBatSynHighlighter(FCurrentTheme:TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer : TDelphiVersions;
begin
    DelphiVer := DelphiXE;
    RefreshSynEdit(FCurrentTheme, SynEdit);
    with TSynBatSyn(SynEdit.Highlighter) do
    begin
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, IdentifierAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, KeyAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Number, NumberAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
      SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, VariableAttri, DelphiVer);
    end;
end;

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
  RunRefreshHighlighter();
end;

function TFrmEditor.GetThemeNameFromFile(const FileName:string): string;
begin
   Result:=Copy(ExtractFileName(FileName), 1, Pos('.theme', ExtractFileName(FileName)) - 1);
end;

procedure TFrmEditor.Image1Click(Sender: TObject);
begin
  ShellExecute(Handle, 'open', 'https://github.com/RRUZ/delphi-preview-handler', nil, nil, SW_SHOWNORMAL) ;
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
//  i : integer;
begin
   Application.OnException := AppException;
   TLogPreview.Add('FormCreate');
//   TLogPreview.Add(Format('Forms %d', [Screen.FormCount]));
//    for i:=0 to Screen.FormCount-1 do
//      TLogPreview.Add(Format('  %s', [Screen.Forms[i].ClassName]));
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


function TFrmEditor.GetHighlighter: TSynCustomHighlighter;
var
  LExt    : string;
  LHighlighterClass : TSynCustomHighlighterClass;
  LItem : TPair<TSynCustomHighlighterClass, TStrings>;
  i : integer;
begin
 Result:=SynPasSyn1;

  LExt:= LowerCase(ExtractFileExt(FFileName));
  for LItem in FExtensions do
    if LItem.Value.IndexOf(LExt)>=0 then
    begin
      LHighlighterClass:=LItem.Key;
      Break;
    end;

  for i := 0 to ComponentCount-1 do
   if (Components[i] is TSynCustomHighlighter) and (Components[i].ClassType = LHighlighterClass) then
   begin
    TLogPreview.Add('found '+Components[i].Name);
    Result:=TSynCustomHighlighter(Components[i]);
    break;
   end;
end;


procedure TFrmEditor.LoadFile(const FileName: string);
var
 LSynCustomHighlighter : TSynCustomHighlighter;
begin
  TLogPreview.Add('TFrmEditor.LoadFile Init');
  FFileName:= FileName;
  LSynCustomHighlighter := GetHighlighter;
  if SynEdit1.Highlighter<>LSynCustomHighlighter then
  begin
    SynEdit1.Lines.Clear;
    SynEdit1.Highlighter := LSynCustomHighlighter;
    LoadTheme();
  end;

  SynEdit1.Lines.LoadFromFile(FFileName);
  TLogPreview.Add('TFrmEditor.LoadFile Done');
end;

procedure TFrmEditor.LoadTheme;
var
 FileName : string;
begin
  TLogPreview.Add('TFrmEditor.LoadTheme Init');
  FileName:=IncludeTrailingPathDelimiter(PathThemes)+ThemeName;
  LoadThemeFromXMLFile(FCurrentTheme, FileName);
  RunRefreshHighlighter;
  TLogPreview.Add('TFrmEditor.LoadTheme Done');
end;


procedure TFrmEditor.RunRefreshHighlighter;
begin
  if SynEdit1.Highlighter<>nil then
   if SynEdit1.Highlighter = SynPasSyn1 then
     RefreshSynPasHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynXMLSyn1 then
     RefreshSynXmlHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynAsmSyn1 then
     RefreshSynAsmHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynBatSyn1 then
     RefreshBatSynHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynCobolSyn1 then
     RefreshSynCobolHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynCppSyn1 then
     RefreshSynCppHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynCSSyn1 then
     RefreshSynCSharpHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynCssSyn1 then
     RefreshSynCSSHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynDfmSyn1 then
     RefreshSynDfmHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynEiffelSyn1 then
     RefreshSynEiffelHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynFortranSyn1 then
     RefreshSynFortranHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynHTMLSyn1 then
     RefreshSynHTMLHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynIniSyn1 then
     RefreshSynIniHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynInnoSyn1 then
     RefreshSynInnoHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynJavaSyn1 then
     RefreshSynJavaHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynJScriptSyn1 then
     RefreshSynJScriptHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynPerlSyn1 then
     RefreshSynPerlHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynPHPSyn1 then
     RefreshSynPhpHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynPythonSyn1 then
     RefreshSynPythonHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynRubySyn1 then
     RefreshSynRubyHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynSQLSyn1 then
     RefreshSynSqlHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynUNIXShellScriptSyn1 then
     RefreshSynUnixHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynVBSyn1 then
     RefreshSynVBHighlighter(FCurrentTheme, SynEdit1)
   else
   if SynEdit1.Highlighter = SynVBScriptSyn1 then
     RefreshSynVbScriptHighlighter(FCurrentTheme, SynEdit1);
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
