{**************************************************************************************************}
{                                                                                                  }
{ Unit uPreviewHandlerRegister                                                                     }
{ unit for the Delphi Preview Handler                                                              }
{                                                                                                  }
{ The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License"); }
{ you may not use this file except in compliance with the License. You may obtain a copy of the    }
{ License at http://www.mozilla.org/MPL/                                                           }
{                                                                                                  }
{ Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF   }
{ ANY KIND, either express or implied. See the License for the specific language governing rights  }
{ and limitations under the License.                                                               }
{                                                                                                  }
{ The Original Code is uPreviewHandlerRegister.pas.                                                }
{                                                                                                  }
{ The Initial Developer of the Original Code is Rodrigo Ruz V.                                     }
{ Portions created by Rodrigo Ruz V. are Copyright (C) 2011 Rodrigo Ruz V.                         }
{ All Rights Reserved.                                                                             }
{                                                                                                  }
{**************************************************************************************************}

unit uPreviewHandlerRegister;

interface

uses
  ComObj,
  Classes,
  Windows,
  uPreviewHandler;

type
  TPreviewHandlerRegister = class(TComObjectFactory)
  private
    FExtensions: TStrings;
    FPreviewHandlerClass: TPreviewHandlerClass;
    class procedure DeleteRegValue(const Key, ValueName: string; RootKey: DWord);
  protected
    property Extensions: TStrings read FExtensions;
  public
    constructor Create(APreviewHandlerClass: TPreviewHandlerClass; const AClassID: TGUID; const AName, ADescription: string;Extensions:array of string);
    destructor Destroy; override;
    function CreateComObject(const Controller: IUnknown): TComObject; override;
    procedure UpdateRegistry(Register: Boolean); override;
    property PreviewHandlerClass: TPreviewHandlerClass read FPreviewHandlerClass;
  end;


implementation

uses
  Math,
  StrUtils,
  SysUtils,
  ShlObj,
  ComServ;

constructor TPreviewHandlerRegister.Create(APreviewHandlerClass: TPreviewHandlerClass; const AClassID: TGUID;  const AName, ADescription: string;Extensions:array of string);
var
 i  :  Integer;
begin
  inherited Create(ComServ.ComServer, APreviewHandlerClass.GetComClass, AClassID, AName, ADescription, ciMultiInstance, tmApartment);
  FPreviewHandlerClass := APreviewHandlerClass;
  FExtensions:=TStringList.Create;
  for i:= low(Extensions) to high(Extensions) do
   FExtensions.Add(Extensions[i]);
end;

function TPreviewHandlerRegister.CreateComObject(const Controller: IUnknown): TComObject;
begin
  result := inherited CreateComObject(Controller);
  TComPreviewHandler(result).PreviewHandlerClass := PreviewHandlerClass;
end;

class procedure TPreviewHandlerRegister.DeleteRegValue(const Key, ValueName: string; RootKey: DWord);
var
  RegKey: HKEY;
begin
  if RegOpenKeyEx(RootKey, PChar(Key), 0, KEY_ALL_ACCESS, regKey) = ERROR_SUCCESS then
  begin
    try
      RegDeleteValue(regKey, PChar(ValueName));
    finally
      RegCloseKey(regKey)
    end;
  end;
end;

destructor TPreviewHandlerRegister.Destroy;
begin
  FExtensions.Free;
  inherited;
end;

//How to Register a Preview Handler
//http://msdn.microsoft.com/en-us/library/cc144144%28v=vs.85%29.aspx
procedure TPreviewHandlerRegister.UpdateRegistry(Register: Boolean);

    function IsWow64Process: Boolean;
    type
      TIsWow64Process = function( hProcess: Windows.THandle; var Wow64Process: Windows.BOOL): Windows.BOOL; stdcall;
    var
      IsWow64Process: TIsWow64Process;
      Wow64Process  : Windows.BOOL;
    begin
      Result := False;
      IsWow64Process := GetProcAddress(GetModuleHandle(Windows.kernel32), 'IsWow64Process');
      if Assigned(IsWow64Process) then
      begin
        if not IsWow64Process(GetCurrentProcess, Wow64Process) then
        Raise Exception.Create('Invalid handle');
        Result := Wow64Process;
      end;
    end;

const
  Prevhost_32='{534A1E02-D58F-44f0-B58B-36CBED287C7C}';
  Prevhost_64='{6d2b5079-2f0b-48dd-ab7f-97cec514d30b}';
var
  sComServerKey : string;
  sAppID, sClassID, ProgID: string;
  RootKey: HKEY;
  RootKey2: HKEY;
  RootPrefix    : string;
  i       : Integer;
begin

  if Instancing = ciInternal then
    Exit;

    ComServer.GetRegRootAndPrefix(RootKey, RootPrefix);
    RootKey2      := IfThen(ComServer.PerUserRegistration,HKEY_CURRENT_USER,HKEY_LOCAL_MACHINE);
    sClassID      := SysUtils.GUIDToString(ClassID);
    ProgID        := GetProgID;
    sComServerKey := Format('%sCLSID\%s\%s',[RootPrefix,sClassID,ComServer.ServerKey]);
    sAppID        := IfThen(IsWow64Process,Prevhost_32,Prevhost_64);
    if Register then
    begin
      inherited UpdateRegistry(True);
      CreateRegKey(Format('%sCLSID\%s',[RootPrefix,sClassID]), 'AppID', sAppID, RootKey);
      if ProgID <> '' then
      begin
        //RegPrefix     HKEY_CLASSES_ROOT
        //ServerKeyName CLSID\{AD8855FB-F908-4DDF-982C-ADB9DE5FF000}\InprocServer32
        //ProgID        DelphiPreviewHandler.Delphi project file
        //RootKey       2147483648
        //sClassID      {AD8855FB-F908-4DDF-982C-ADB9DE5FF000}
        //FileExtension .dpr
        //RootKey2      HKEY_LOCAL_MACHINE

        CreateRegKey(sComServerKey, 'ProgID', ProgID, RootKey);

        for i:=0 to FExtensions.Count -1 do
          CreateRegKey(RootPrefix + FExtensions[i] + '\shellex\' + SID_IPreviewHandler, '', sClassID, RootKey);

        CreateRegKey(sComServerKey, 'VersionIndependentProgID', ProgID, RootKey);
        CreateRegKey(RootPrefix + ProgID + '\shellex\' + SID_IPreviewHandler, '', sClassID, RootKey);
        CreateRegKey('SOFTWARE\Microsoft\Windows\CurrentVersion\PreviewHandlers', sClassID, Description, RootKey2);
      end;
    end
    else
    begin
      if ProgID <> '' then
      begin
        DeleteRegValue('SOFTWARE\Microsoft\Windows\CurrentVersion\PreviewHandlers', sClassID, RootKey2);
        DeleteRegKey(RootPrefix + ProgID + '\shellex', RootKey);
        //DeleteRegValue('AppID\'+sClassID,'DllSurrogate',RootKey);
        for i:=0 to FExtensions.Count -1 do
         DeleteRegKey(RootPrefix + FExtensions[i] + '\shellex\' + SID_IPreviewHandler, RootKey);
      end;
      inherited UpdateRegistry(False);
    end;
end;


//
//        protected static void RegisterPreviewHandler(string name, string extensions, string previewerGuid, string appId)
//        {
//            // Create a new prevhost AppID so that this always runs in its own isolated process
//            using (var appIdsKey = Registry.ClassesRoot.OpenSubKey("AppID", true))
//            using (var appIdKey = appIdsKey.CreateSubKey(appId))
//            {
//                appIdKey.SetValue("DllSurrogate", @"%SystemRoot%\system32\prevhost.exe", RegistryValueKind.ExpandString);
//            }
//
//            // Add preview handler to preview handler list
//            using (var handlersKey = Registry.LocalMachine.OpenSubKey("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\PreviewHandlers", true))
//            {
//                handlersKey.SetValue(previewerGuid, name, RegistryValueKind.String);
//            }
//
//            // Modify preview handler registration
//            using (var clsidKey = Registry.ClassesRoot.OpenSubKey("CLSID"))
//            using (var idKey = clsidKey.OpenSubKey(previewerGuid, true))
//            {
//                idKey.SetValue("DisplayName", name, RegistryValueKind.String);
//                idKey.SetValue("AppID", appId, RegistryValueKind.String);
//                //idKey.SetValue("DisableLowILProcessIsolation", 1, RegistryValueKind.DWord);
//            }
//
//            foreach (var extension in extensions.Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries))
//            {
//                Trace.WriteLine("Registering extension '" + extension + "' with previewer '" + previewerGuid + "'");
//
//                // Set preview handler for specific extension
//                using (var extensionKey = Registry.ClassesRoot.CreateSubKey(extension))
//                using (var shellexKey = extensionKey.CreateSubKey("shellex"))
//                using (var previewKey = shellexKey.CreateSubKey("{8895b1c6-b41f-4c1c-a562-0d564250836f}"))
//                {
//                    previewKey.SetValue(null, previewerGuid, RegistryValueKind.String);
//                }
//            }
//        }
//
//        protected static void UnregisterPreviewHandler(string extensions, string previewerGuid, string appId)
//        {
//            foreach (var extension in extensions.Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries))
//            {
//                Trace.WriteLine("Unregistering extension '" + extension + "' with previewer '" + previewerGuid + "'");
//                using (var shellexKey = Registry.ClassesRoot.OpenSubKey(extension + "\\shellex", true))
//                {
//                    try { shellexKey.DeleteSubKey("{8895b1c6-b41f-4c1c-a562-0d564250836f}"); }
//                    catch { }
//                }
//            }
//
//            using (var appIdsKey = Registry.ClassesRoot.OpenSubKey("AppID", true))
//            {
//                try { appIdsKey.DeleteSubKey(appId); }
//                catch { }
//            }
//
//            using (var classesKey = Registry.LocalMachine.OpenSubKey("SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\PreviewHandlers", true))
//            {
//                try { classesKey.DeleteValue(previewerGuid); }
//                catch { }
//            }
//        }


end.
