// **************************************************************************************************
//
// Unit uGlobalPreviewHandler
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
// The Original Code is uGlobalPreviewHandler.pas.
//
// The Initial Developer of the Original Code is Rodrigo Ruz V.
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2017 Rodrigo Ruz V.
// All Rights Reserved.
//
// *************************************************************************************************

unit uGlobalPreviewHandler;

interface

uses
  uStackTrace,
  Classes,
  Controls,
  StdCtrls,
  SysUtils,
  uEditor,
  uCommonPreviewHandler,
  uPreviewHandler;

const
  GUID_GlobalPreviewHandler: TGUID = '{AD8855FB-F908-4DDF-982C-ADB9DE5FF000}';

type
  TGlobalPreviewHandler = class(TBasePreviewHandler)
  public
    constructor Create(AParent: TWinControl); override;
  end;

implementation

Uses
  uDelphiIDEHighlight,
  uDelphiVersions,
  uLogExcept,
  SynEdit,
  Windows,
  Forms,
  uMisc;

type
  TWinControlClass = class(TWinControl);

constructor TGlobalPreviewHandler.Create(AParent: TWinControl);
begin
  TLogPreview.Add('TGlobalPreviewHandler.Create');
  inherited Create(AParent);
  try
    if IsWindow(TWinControlClass(AParent).WindowHandle) then
    begin
//      TLogPreview.Add('TGlobalPreviewHandler TFrmEditor.Create');
//      Editor := TFrmEditor.Create(AParent);
//      Editor.Parent := AParent;
//      Editor.Align := alClient;
//      Editor.BorderStyle := bsNone;
//      Editor.Extensions := FExtensions;

//      TFrmEditor.AParent    := AParent;
      TFrmEditor.Extensions := FExtensions;
      TLogPreview.Add('TGlobalPreviewHandler Done');
    end;
  except
    on E: Exception do
      TLogPreview.Add(Format('Error in %s.Create - Message : %s : Trace %s', [Self.ClassName, E.Message, E.StackTrace]));
  end;
end;

end.
