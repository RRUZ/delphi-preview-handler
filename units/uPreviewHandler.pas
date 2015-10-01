//**************************************************************************************************
//
// Unit uPreviewHandler
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
// The Original Code is uPreviewHandler.pas.
//
// The Initial Developer of the Original Code is Rodrigo Ruz V.
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2015 Rodrigo Ruz V.
// All Rights Reserved.
//
//*************************************************************************************************


unit uPreviewHandler;


interface

uses
  Forms,
  Classes,
  Controls,
  ComObj,
  ShlObj,
  Windows,
  uPreviewContainer,
  ActiveX;


type
  TPreviewHandler = class abstract
  public
    constructor Create(AParent: TWinControl); virtual;
    class function GetComClass: TComClass; virtual; abstract;
    class procedure RegisterExtentions(const AClassID: TGUID; const AName, ADescription : string;Extensions:array of string);
    procedure Unload; virtual;
  end;


  TPreviewHandlerClass = class of TPreviewHandler;

  TComPreviewHandler = class(TComObject, IOleWindow, IObjectWithSite, IPreviewHandler, IPreviewHandlerVisuals)
 // strict private
    function IPreviewHandler.DoPreview = IPreviewHandler_DoPreview;
    function ContextSensitiveHelp(fEnterMode: LongBool): HRESULT; stdcall;
    function GetSite(const riid: TGUID; out site: IInterface): HRESULT; stdcall;
    function GetWindow(out wnd: HWND): HRESULT; stdcall;
    function IPreviewHandler_DoPreview: HRESULT; stdcall;
    function QueryFocus(var phwnd: HWND): HRESULT; stdcall;
    function SetBackgroundColor(color: TColorRef): HRESULT; stdcall;
    function SetFocus: HRESULT; stdcall;
    function SetFont(const plf: TLogFont): HRESULT; stdcall;
    function SetRect(var prc: TRect): HRESULT; stdcall;
    function SetSite(const pUnkSite: IInterface): HRESULT; stdcall;
    function SetTextColor(color: TColorRef): HRESULT; stdcall;
    function SetWindow(hwnd: HWND; var prc: TRect): HRESULT; stdcall;
    function TranslateAccelerator(var pmsg: tagMSG): HRESULT; stdcall;
    function Unload: HRESULT; stdcall;
  private
    FBackgroundColor: TColorRef;
    FBounds: TRect;
    FContainer: TPreviewContainer;
    FLogFont: TLogFont;
    FParentWindow: HWND;
    FPreviewHandler: TPreviewHandler;
    FPreviewHandlerClass: TPreviewHandlerClass;
    FPreviewHandlerFrame: IPreviewHandlerFrame;
    FSite: IInterface;
    FTextColor: TColorRef;
  protected
    procedure CheckContainer;
    procedure CheckPreviewHandler;
    procedure InternalUnload; virtual; abstract;
    procedure InternalDoPreview; virtual; abstract;
    property  BackgroundColor : TColorRef read FBackgroundColor write FBackgroundColor;
    property  TextColor : TColorRef read FTextColor write FTextColor;
    property  Bounds : TRect read FBounds write FBounds;
    property  Container: TPreviewContainer read FContainer;
    property  LogFont : TLogFont read FLogFont  write FLogFont;
    property  ParentWindow: HWND read FParentWindow write FParentWindow;
    property  PreviewHandler: TPreviewHandler read FPreviewHandler;
    property  PreviewHandlerFrame : IPreviewHandlerFrame read FPreviewHandlerFrame;
    property  Site : IInterface read FSite;
  public
    destructor Destroy; override;
    property PreviewHandlerClass: TPreviewHandlerClass read FPreviewHandlerClass write FPreviewHandlerClass;
  end;


implementation

uses
    ComServ,
    Types,
    SysUtils,
    Graphics,
    ExtCtrls,
    uMisc,
    uLogExcept,
    uPreviewHandlerRegister;


destructor TComPreviewHandler.Destroy;
begin
  FPreviewHandler.Free;
  FContainer.Free;
  inherited Destroy;
end;

procedure TComPreviewHandler.CheckContainer;
begin
  if (FContainer = nil) and IsWindow(FParentWindow) then
  begin
    FContainer := TPreviewContainer.Create(nil);
    FContainer.ParentWindow := FParentWindow;
    FContainer.BorderStyle := bsNone;
    FContainer.Visible:=True;
    FContainer.SetBoundsRect(FBounds);
  end;
end;

procedure TComPreviewHandler.CheckPreviewHandler;
begin
  if FPreviewHandler = nil then
  begin
    CheckContainer;
    FPreviewHandler := PreviewHandlerClass.Create(Container);
  end;
end;

function TComPreviewHandler.ContextSensitiveHelp(fEnterMode: LongBool): HRESULT;
begin
  result := E_NOTIMPL;
end;

function TComPreviewHandler.GetSite(const riid: TGUID; out site: IInterface): HRESULT;
begin
  site := nil;
  if FSite = nil then
    result := E_FAIL
  else
  if Supports(FSite, riid, site) then
    result := S_OK
  else
    result := E_NOINTERFACE;
end;

function TComPreviewHandler.GetWindow(out wnd: HWND): HRESULT;
begin
  if Container = nil then
  begin
    result := E_FAIL;
  end
  else
  begin
    wnd := Container.Handle;
    result := S_OK;
  end;
end;

function TComPreviewHandler.IPreviewHandler_DoPreview: HRESULT;
begin
  try
    CheckPreviewHandler;
    InternalDoPreview;
  except
    on E: Exception do
      TLogException.Add(Format('Error in TComPreviewHandler.IPreviewHandler_DoPreview - Message : %s : Trace %s', [E.Message, E.StackTrace]));
  end;
  Result := S_OK;
end;

function TComPreviewHandler.QueryFocus(var phwnd: HWND): HRESULT;
begin
  phwnd := GetFocus;
  Result := S_OK;
end;

function TComPreviewHandler.SetBackgroundColor(color: Cardinal): HRESULT;
begin
  FBackgroundColor := color;
  if Container <> nil then
    Container.SetBackgroundColor(FBackgroundColor);
  Result := S_OK;
end;

function TComPreviewHandler.SetFocus: HRESULT;
begin
  if Container <> nil then
  begin
    if GetKeyState(VK_SHIFT) < 0 then
      Container.SetFocusTabLast
    else
      Container.SetFocusTabFirst;
  end;
  Result := S_OK;
end;

function TComPreviewHandler.SetFont(const plf: TLogFont): HRESULT;
begin
  FLogFont := plf;
  if Container <> nil then
    Container.SetTextFont(FLogFont);
  Result := S_OK;
end;

function TComPreviewHandler.SetRect(var prc: TRect): HRESULT;
begin
  FBounds := prc;
  if Container <> nil then
    Container.SetBoundsRect(FBounds);
  Result := S_OK;
end;

function TComPreviewHandler.SetSite(const pUnkSite: IInterface): HRESULT;
begin
  FSite := PUnkSite;
  FPreviewHandlerFrame := FSite as IPreviewHandlerFrame;
  result := S_OK;
end;

function TComPreviewHandler.SetTextColor(color: Cardinal): HRESULT;
begin
  FTextColor := color;
  if Container <> nil then
    Container.SetTextColor(FTextColor);
  Result := S_OK;
end;

function TComPreviewHandler.SetWindow(hwnd: HWND; var prc: TRect): HRESULT;
begin
  FParentWindow := hwnd;
  FBounds := prc;
  if Container <> nil then
  begin
    Container.ParentWindow := FParentWindow;
    Container.SetBoundsRect(FBounds);
  end;
  Result := S_OK;
end;

function TComPreviewHandler.TranslateAccelerator(var pmsg: tagMSG): HRESULT;
begin
  if FPreviewHandlerFrame = nil then
    result := S_FALSE
  else
    result := FPreviewHandlerFrame.TranslateAccelerator(pmsg);
end;

function TComPreviewHandler.Unload: HRESULT;
begin
  if PreviewHandler <> nil then
    PreviewHandler.Unload;
  InternalUnload;
  result := S_OK;
end;

constructor TPreviewHandler.Create(AParent: TWinControl);
begin
  inherited Create;
end;

class procedure TPreviewHandler.RegisterExtentions(const AClassID: TGUID; const AName, ADescription: string;Extensions:array of string);
begin
  TPreviewHandlerRegister.Create(Self, AClassID, AName, ADescription, Extensions);
end;

procedure TPreviewHandler.Unload;
begin
end;

end.


