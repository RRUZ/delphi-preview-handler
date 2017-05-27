// **************************************************************************************************
//
// Unit uMisc
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
// The Original Code is uMisc.pas.
//
// The Initial Developer of the Original Code is Rodrigo Ruz V.
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2017 Rodrigo Ruz V.
// All Rights Reserved.
//
// *************************************************************************************************

unit uMisc;

interface

uses
  SynEdit,
  SynEditHighlighter,
  uDelphiVersions,
  uDelphiIDEHighlight;

  function GetDllPath: String;
  function GetTempDirectory: string;
  function GetSpecialFolder(const CSIDL: integer): string;
  function GetFileVersion(const FileName: string): string;
  function  GetModuleLocation : string;

  procedure RefreshSynEdit(FCurrentTheme: TIDETheme; SynEdit: SynEdit.TSynEdit);
  procedure SetSynAttr(FCurrentTheme: TIDETheme; Element: TIDEHighlightElements; SynAttr: TSynHighlighterAttributes;
    DelphiVersion: TDelphiVersions);

  procedure RefreshSynPasHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynCobolHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynCppHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynCSharpHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynCSSHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynDfmHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynEiffelHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynFortranHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynHTMLHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynIniHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynInnoHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynJavaHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynJScriptHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynPerlHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynPhpHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynPythonHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynRubyHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynSqlHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynUnixHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynXmlHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynAsmHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynVBHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshSynVbScriptHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
  procedure RefreshBatSynHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);

var
  gbSearchBackwards: boolean;
  gbSearchCaseSensitive: boolean;
  gbSearchFromCaret: boolean;
  gbSearchSelectionOnly: boolean;
  gbSearchTextAtCaret: boolean;
  gbSearchWholeWords: boolean;
  gbSearchRegex: boolean;

  gsSearchText: string;
  gsSearchTextHistory: string;
  gsReplaceText: string;
  gsReplaceTextHistory: string;

resourcestring
  STextNotFound = 'Text not found';

implementation

uses
  ComObj,
  System.SysUtils,
  WinApi.Windows,
  WinApi.ShlObj,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.GraphUtil,
  SynHighlighterPas, SynHighlighterXML,
  SynHighlighterCpp, SynHighlighterAsm,
  SynHighlighterFortran, SynHighlighterEiffel, SynHighlighterPython,
  SynHighlighterPerl, SynHighlighterDfm, SynHighlighterBat,
  SynHighlighterVBScript, SynHighlighterPHP, SynHighlighterJScript,
  SynHighlighterHtml, SynHighlighterCSS, SynHighlighterCS, SynHighlighterCobol,
  SynHighlighterVB, SynHighlighterM3, SynHighlighterJava, SynHighlighterSml,
  SynHighlighterIni, SynHighlighterInno, SynHighlighterSQL,
  SynHighlighterUNIXShellScript, SynHighlighterRuby;

procedure RefreshSynPasHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynCobolHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynCppHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynCSharpHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynCSSHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynDfmHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynEiffelHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynFortranHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynHTMLHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynIniHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynInnoHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynJavaHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynJScriptHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynPerlHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynPhpHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynPythonHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynRubyHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynSqlHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynUnixHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynVBHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynVbScriptHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynXmlHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
begin
  DelphiVer := DelphiXE;

  RefreshSynEdit(FCurrentTheme, SynEdit);

  with TSynXMLSyn(SynEdit.Highlighter) do
  begin
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.AttributeNames, AttributeAttri, DelphiVer);
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.AttributeValues, AttributeValueAttri, DelphiVer);
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CDATAAttri, DelphiVer);
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.Comment, CommentAttri, DelphiVer);
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.Preprocessor, DocTypeAttri, DelphiVer);
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, ElementAttri, DelphiVer);
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.ReservedWord, EntityRefAttri, DelphiVer);
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, NamespaceAttributeAttri, DelphiVer);
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.String, NamespaceAttributeValueAttri, DelphiVer);
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.Preprocessor, ProcessingInstructionAttri, DelphiVer);
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.Whitespace, SpaceAttri, DelphiVer);
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.Identifier, SymbolAttri, DelphiVer);
    SetSynAttr(FCurrentTheme, TIDEHighlightElements.Character, TextAttri, DelphiVer);
  end;
end;

procedure RefreshBatSynHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
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

procedure RefreshSynAsmHighlighter(FCurrentTheme: TIDETheme; SynEdit: TSynEdit);
var
  DelphiVer: TDelphiVersions;
begin
  DelphiVer := DelphiXE;
  RefreshSynEdit(FCurrentTheme, SynEdit);
  with TSynAsmSyn(SynEdit.Highlighter) do
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

procedure SetSynAttr(FCurrentTheme: TIDETheme; Element: TIDEHighlightElements; SynAttr: TSynHighlighterAttributes;
  DelphiVersion: TDelphiVersions);
begin
  SynAttr.Background := GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[Element].BackgroundColorNew), DelphiVersion);
  SynAttr.Foreground := GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[Element].ForegroundColorNew), DelphiVersion);
  SynAttr.Style := [];
  if FCurrentTheme[Element].Bold then
    SynAttr.Style := SynAttr.Style + [fsBold];
  if FCurrentTheme[Element].Italic then
    SynAttr.Style := SynAttr.Style + [fsItalic];
  if FCurrentTheme[Element].Underline then
    SynAttr.Style := SynAttr.Style + [fsUnderline];
end;

procedure RefreshSynEdit(FCurrentTheme: TIDETheme; SynEdit: SynEdit.TSynEdit);
var
  Element: TIDEHighlightElements;
  DelphiVer: TDelphiVersions;
begin
  DelphiVer := DelphiXE;

  Element := TIDEHighlightElements.RightMargin;
  SynEdit.RightEdgeColor := GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[Element].ForegroundColorNew), DelphiVer);

  Element := TIDEHighlightElements.MarkedBlock;
  SynEdit.SelectedColor.Foreground := GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[Element].ForegroundColorNew), DelphiVer);
  SynEdit.SelectedColor.Background := GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[Element].BackgroundColorNew), DelphiVer);

  Element := TIDEHighlightElements.LineNumber;
  SynEdit.Gutter.Color := StringToColor(FCurrentTheme[Element].BackgroundColorNew);
  SynEdit.Gutter.Font.Color := GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[Element].ForegroundColorNew), DelphiVer);

  Element := TIDEHighlightElements.PlainText;
  SynEdit.Gutter.BorderColor := GetHighLightColor(StringToColor(FCurrentTheme[Element].BackgroundColorNew));

  Element := TIDEHighlightElements.LineHighlight;
  SynEdit.ActiveLineColor := GetDelphiVersionMappedColor(StringToColor(FCurrentTheme[Element].BackgroundColorNew), DelphiVer);

end;

function GetDllPath: String;
var
  Path: array [0 .. MAX_PATH - 1] of Char;
begin
  SetString(Result, Path, GetModuleFileName(HInstance, Path, SizeOf(Path)));
end;

function GetTempDirectory: string;
var
  lpBuffer: array [0 .. MAX_PATH] of Char;
begin
  GetTempPath(MAX_PATH, @lpBuffer);
  Result := StrPas(lpBuffer);
end;

function GetWindowsDirectory: string;
var
  lpBuffer: array [0 .. MAX_PATH] of Char;
begin
  WinApi.Windows.GetWindowsDirectory(@lpBuffer, MAX_PATH);
  Result := StrPas(lpBuffer);
end;

function GetSpecialFolder(const CSIDL: integer): string;
var
  lpszPath: PWideChar;
begin
  lpszPath := StrAlloc(MAX_PATH);
  try
    ZeroMemory(lpszPath, MAX_PATH);
    if SHGetSpecialFolderPath(0, lpszPath, CSIDL, False) then
      Result := lpszPath
    else
      Result := '';
  finally
    StrDispose(lpszPath);
  end;
end;



function GetFileVersion(const FileName: string): string;
var
  FSO  : OleVariant;
begin
  FSO    := CreateOleObject('Scripting.FileSystemObject');
  Result := FSO.GetFileVersion(FileName);
end;

function  GetModuleLocation : string;
begin
  SetLength(Result, MAX_PATH);
  GetModuleFileName(HInstance, PChar(Result), MAX_PATH);
  Result:=PChar(Result);
end;
end.
