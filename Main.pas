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

uses
  uXmlPreviewHandler,
  uCppPreviewHandler,
  uAsmPreviewHandler,
  uPascalPreviewHandler;

implementation

initialization
  TPascalPreviewHandler.RegisterExtentions(GUID_PascalPreviewHandler, 'Delphi.Pas.PreviewHandler', 'Delphi Preview Handler', ['.pp','.lpr','.lfm','.lpk','.inc','.pas','.dpr','.dfm','.dpk']);
  //TPascalPreviewHandler.RegisterExtentions(GUID_PascalPreviewHandler, '{6EC00D58-08C0-41DA-B02D-BEEE086315F8}', 'Delphi Preview Handler', ['.pp','.lpr','.lfm','.lpk','.inc','.pas','.dpr','.dfm','.dpk']);
  TXmlPreviewHandler.RegisterExtentions(GUID_XmlPreviewHandler, 'Delphi.Xml.PreviewHandler', 'Delphi Xml Preview Handler', ['.dproj','.bdsproj']);
  TCppPreviewHandler.RegisterExtentions(GUID_CppPreviewHandler, 'Delphi.Cpp.PreviewHandler', 'Delphi Cpp Preview Handler', ['.c','.cpp','.cc','.h','.hpp','.hh','.cxx','.hxx','.cu']);
  TAsmPreviewHandler.RegisterExtentions(GUID_AsmPreviewHandler, 'Delphi.Asm.PreviewHandler', 'Delphi Asm Preview Handler', ['.asm']);
end.



