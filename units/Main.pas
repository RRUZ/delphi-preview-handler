//**************************************************************************************************
//
// Unit Main
// Main unit for the Delphi Preview Handler  https://github.com/RRUZ/delphi-preview-handler
//
// The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the
// License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
// ANY KIND, either express or implied. See the License for the specific language governing rights
// and limitations under the License.
//
// The Original Code is Main.pas.
//
// The Initial Developer of the Original Code is Rodrigo Ruz V.
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2017 Rodrigo Ruz V.
// All Rights Reserved.
//
//*************************************************************************************************


//TODO

// done : Add export option
// done : Replace combo theme using Dropdown button
// done : Add search option
// done : Add update option
// done : Add About Form

// done : One form only  (Screenforms)
// done :  Add Setting  Form (font size, VCL Styles, column selection, font size, font)

// done : change vcl style produce invalid window (chnage at restar warning)
// done : styling on confirmation dialog fails under W10



unit Main;

interface

{$R VCLStyles.RES}


implementation

uses
  System.Generics.Collections,
  System.Classes,
  SynEditHighlighter,
  uPreviewHandler,
  SynHighlighterPas,
  SynHighlighterXML,
  SynHighlighterCpp,
  SynHighlighterAsm,
  SynHighlighterEiffel,
  SynHighlighterFortran,
  SynHighlighterJava,
  SynHighlighterVB,
  SynHighlighterCobol,
  SynHighlighterCS,
  SynHighlighterCSS,
  SynHighlighterHtml,
  SynHighlighterJScript,
  SynHighlighterPHP,
  SynHighlighterVBScript,
  SynHighlighterBat,
  SynHighlighterDfm,
  SynHighlighterPerl,
  SynHighlighterPython,
  SynHighlighterRuby,
  SynHighlighterUNIXShellScript,
  SynHighlighterSQL,
  SynHighlighterInno,
  SynHighlighterIni,
  uGlobalPreviewHandler;

initialization
  //use settings to determine previsualizers


  TPreviewHandler.FExtensions := TDictionary<TSynCustomHighlighterClass, TStrings>.Create;
  //Pascal Files (*.pas;*.pp;*.dpr;*.dpk;*.inc)|*.pas;*.pp;*.dpr;*.dpk;*.inc
  TGlobalPreviewHandler.AddExtentions(TSynPasSyn, ['.pp', '.lpr', '.lfm', '.lpk', '.inc', '.pas', '.dpr', '.dpk']);
  //XML Files (*.xml;*.xsd;*.xsl;*.xslt;*.dtd)|*.xml;*.xsd;*.xsl;*.xslt;*.dtd
  TGlobalPreviewHandler.AddExtentions(TSynXMLSyn, ['.dproj', '.bdsproj', '.xml', '.xsd' ,'.xsl', '.xslt', '.dtd', '.csproj', '.xaml', '.sln', '.vcxproj', '.vbproj', '.jsproj', '.appxmanifest']);
  //C/C++ Files (*.c;*.cpp;*.cc;*.h;*.hpp;*.hh;*.cxx;*.hxx;*.cu)|*.c;*.cpp;*.cc;*.h;*.hpp;*.hh;*.cxx;*.hxx;*.cu
  TGlobalPreviewHandler.AddExtentions(TSynCppSyn, ['.c', '.cpp', '.cc', '.h', '.hpp', '.hh', '.cxx', '.hxx', '.cu']);
  //x86 Assembly Files (*.asm)|*.asm
  TGlobalPreviewHandler.AddExtentions(TSynAsmSyn, ['.asm']);
  //Eiffel (*.e;*.ace)|*.e;*.ace
  TGlobalPreviewHandler.AddExtentions(TSynEiffelSyn, ['.e', '.ace']);
  //Fortran Files (*.for)|*.for
  TGlobalPreviewHandler.AddExtentions(TSynFortranSyn, ['.for', '.f']);
  //Java Files (*.java)|*.java
  TGlobalPreviewHandler.AddExtentions(TSynJavaSyn, ['.java']);
  //Visual Basic Files (*.bas)|*.bas
  TGlobalPreviewHandler.AddExtentions(TSynVBSyn, ['.bas', '.vb']);
  //COBOL Files (*.cbl;*.cob)|*.cbl;*.cob
  TGlobalPreviewHandler.AddExtentions(TSynCobolSyn, ['.cbl', '.cob']);
  //C# Files (*.cs)|*.cs
  TGlobalPreviewHandler.AddExtentions(TSynCSSyn, ['.cs']);
  //Cascading Stylesheets (*.css)|*.css
  TGlobalPreviewHandler.AddExtentions(TSynCssSyn, ['.css']);
  //HTML Documents (*.htm;*.html)|*.htm;*.html
  TGlobalPreviewHandler.AddExtentions(TSynHTMLSyn, ['.htm', '.html']);
  //Javascript Files (*.js)|*.js
  TGlobalPreviewHandler.AddExtentions(TSynJScriptSyn, ['.js']);
  //PHP Files (*.php;*.php3;*.phtml;*.inc)|*.php;*.php3;*.phtml;*.inc
  TGlobalPreviewHandler.AddExtentions(TSynPHPSyn, ['.php', '.php3', '.phtml']);
  //VBScript Files (*.vbs)|*.vbs
  TGlobalPreviewHandler.AddExtentions(TSynVBScriptSyn, ['.vbs']);
  //MS-DOS Batch Files (*.bat;*.cmd)|*.bat;*.cmd
  TGlobalPreviewHandler.AddExtentions(TSynBatSyn, ['.bat', '.cmd']);
  //Borland Form Files (*.dfm;*.xfm)|*.dfm;*.xfm
  TGlobalPreviewHandler.AddExtentions(TSynDfmSyn, ['.dfm', '.xfm']);
  //Perl Files (*.pl;*.pm;*.cgi)|*.pl;*.pm;*.cgi
  TGlobalPreviewHandler.AddExtentions(TSynPerlSyn, ['.pl', '.pm', '.cgi']);
  //Python Files (*.py)|*.py
  TGlobalPreviewHandler.AddExtentions(TSynPythonSyn, ['.py']);
  //Ruby Files (*.rb;*.rbw)|*.rb;*.rbw
  TGlobalPreviewHandler.AddExtentions(TSynRubySyn, ['.rb', '.rbw']);
  //UNIX Shell Scripts (*.sh)|*.sh
  TGlobalPreviewHandler.AddExtentions(TSynUNIXShellScriptSyn, ['.sh']);
  //SQL Files (*.sql)|*.sql
  TGlobalPreviewHandler.AddExtentions(TSynSQLSyn, ['.sql']);
  //Inno Setup Scripts (*.iss)|*.iss
  TGlobalPreviewHandler.AddExtentions(TSynInnoSyn, ['.iss']);
  //INI Files (*.ini)|*.ini
  TGlobalPreviewHandler.AddExtentions(TSynIniSyn, ['.ini']);

  TGlobalPreviewHandler.RegisterPreview(GUID_GlobalPreviewHandler, 'Delphi.PreviewHandler', 'Delphi Preview Handler');
end.



