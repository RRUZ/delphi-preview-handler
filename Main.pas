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
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2015 Rodrigo Ruz V.
// All Rights Reserved.
//
//*************************************************************************************************


//TODO
// add application to handle settings of the preview handler


unit Main;

interface

{.$R ManAdmin.RES}


implementation

uses
  uEiffelPreviewHandler,
  uXmlPreviewHandler,
  uCppPreviewHandler,
  uAsmPreviewHandler,
  uPascalPreviewHandler,
  uFortranPreviewHandler,
  uJavaPreviewHandler,
  uVBPreviewHandler,
  uCobolPreviewHandler,
  uCSharpPreviewHandler,
  uCSSPreviewHandler,
  uHTMLPreviewHandler,
  uJScriptPreviewHandler,
  uPhpPreviewHandler,
  uVBScriptPreviewHandler,
  uDfmPreviewHandler,
  uBatPreviewHandler,
  uPerlPreviewHandler,
  uPythonPreviewHandler;

initialization
  //Pascal Files (*.pas;*.pp;*.dpr;*.dpk;*.inc)|*.pas;*.pp;*.dpr;*.dpk;*.inc
  TPascalPreviewHandler.RegisterExtentions(GUID_PascalPreviewHandler, 'Delphi.Pas.PreviewHandler', 'Delphi Pascal Preview Handler',
  ['.pp', '.lpr', '.lfm', '.lpk', '.inc', '.pas', '.dpr', '.dpk']);

  //XML Files (*.xml;*.xsd;*.xsl;*.xslt;*.dtd)|*.xml;*.xsd;*.xsl;*.xslt;*.dtd
  TXmlPreviewHandler.RegisterExtentions(GUID_XmlPreviewHandler, 'Delphi.Xml.PreviewHandler', 'Delphi Xml Preview Handler',
  ['.dproj', '.bdsproj', '.xml', '.xsd' ,'.xsl', '.xslt', '.dtd']);

  //C/C++ Files (*.c;*.cpp;*.cc;*.h;*.hpp;*.hh;*.cxx;*.hxx;*.cu)|*.c;*.cpp;*.cc;*.h;*.hpp;*.hh;*.cxx;*.hxx;*.cu
  TCppPreviewHandler.RegisterExtentions(GUID_CppPreviewHandler, 'Delphi.Cpp.PreviewHandler', 'Delphi Cpp Preview Handler',
  ['.c', '.cpp', '.cc', '.h', '.hpp', '.hh', '.cxx', '.hxx', '.cu']);

  //x86 Assembly Files (*.asm)|*.asm
  TAsmPreviewHandler.RegisterExtentions(GUID_AsmPreviewHandler, 'Delphi.Asm.PreviewHandler', 'Delphi Asm Preview Handler',
  ['.asm']);

  //Eiffel (*.e;*.ace)|*.e;*.ace
  TEiffelPreviewHandler.RegisterExtentions(GUID_EiffelPreviewHandler, 'Delphi.Eiffel.PreviewHandler', 'Delphi Eiffel Preview Handler',
  ['.e', '.ace']);

  //Fortran Files (*.for)|*.for
  TFortranPreviewHandler.RegisterExtentions(GUID_FortranPreviewHandler, 'Delphi.Fortran.PreviewHandler', 'Delphi Fortran Preview Handler',
  ['.for']);

  //Java Files (*.java)|*.java
  TJavaPreviewHandler.RegisterExtentions(GUID_JavaPreviewHandler, 'Delphi.Java.PreviewHandler', 'Delphi Java Preview Handler',
  ['.java']);

  //Visual Basic Files (*.bas)|*.bas
  TVBPreviewHandler.RegisterExtentions(GUID_VBPreviewHandler, 'Delphi.VB.PreviewHandler', 'Delphi VB Preview Handler',
  ['.bas', '.vb']);

  //COBOL Files (*.cbl;*.cob)|*.cbl;*.cob
  TCobolPreviewHandler.RegisterExtentions(GUID_CobolPreviewHandler, 'Delphi.Cobol.PreviewHandler', 'Delphi Cobol Preview Handler',
  ['.cbl', '.cob']);

  //C# Files (*.cs)|*.cs
  TCSharpPreviewHandler.RegisterExtentions(GUID_CSharpPreviewHandler, 'Delphi.CSharp.PreviewHandler', 'Delphi CSharp Preview Handler',
  ['.cs']);

  //Cascading Stylesheets (*.css)|*.css
  TCSSPreviewHandler.RegisterExtentions(GUID_CSSPreviewHandler, 'Delphi.CSS.PreviewHandler', 'Delphi CSS Preview Handler',
  ['.css']);

  //HTML Documents (*.htm;*.html)|*.htm;*.html
  THtmlPreviewHandler.RegisterExtentions(GUID_HTMLPreviewHandler, 'Delphi.HTML.PreviewHandler', 'Delphi HTML Preview Handler',
  ['.htm', '.html']);

  //Javascript Files (*.js)|*.js
  TJScriptPreviewHandler.RegisterExtentions(GUID_JScriptPreviewHandler, 'Delphi.JScript.PreviewHandler', 'Delphi JScript Preview Handler',
  ['.js']);

  //PHP Files (*.php;*.php3;*.phtml;*.inc)|*.php;*.php3;*.phtml;*.inc
  TPhpPreviewHandler.RegisterExtentions(GUID_PhpPreviewHandler, 'Delphi.PHP.PreviewHandler', 'Delphi PHP Preview Handler',
  ['.php', '.php3', '.phtml']);

  //VBScript Files (*.vbs)|*.vbs
  TVBScriptPreviewHandler.RegisterExtentions(GUID_VBScriptPreviewHandler, 'Delphi.VBScript.PreviewHandler', 'Delphi VBScript Preview Handler',
  ['.vbs']);

  //MS-DOS Batch Files (*.bat;*.cmd)|*.bat;*.cmd
  TBatPreviewHandler.RegisterExtentions(GUID_BatPreviewHandler, 'Delphi.Bat.PreviewHandler', 'Delphi Bat Preview Handler',
  ['.bat', '.cmd']);

  //Borland Form Files (*.dfm;*.xfm)|*.dfm;*.xfm
  TDfmPreviewHandler.RegisterExtentions(GUID_DfmPreviewHandler, 'Delphi.DFM.PreviewHandler', 'Delphi DFM Preview Handler',
  ['.dfm', '.xfm']);

  //Perl Files (*.pl;*.pm;*.cgi)|*.pl;*.pm;*.cgi
  TPerlPreviewHandler.RegisterExtentions(GUID_PerlPreviewHandler, 'Delphi.Perl.PreviewHandler', 'Delphi Perl Preview Handler',
  ['.pl', '.pm', '.cgi']);

  //Python Files (*.py)|*.py
  TPythonPreviewHandler.RegisterExtentions(GUID_PythonPreviewHandler, 'Delphi.Python.PreviewHandler', 'Delphi Python Preview Handler',
  ['.py']);

end.



