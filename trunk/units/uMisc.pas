//**************************************************************************************************
//
// Unit uMisc
// unit for the Delphi Preview Handler
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
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2015 Rodrigo Ruz V.
// All Rights Reserved.
//
//*************************************************************************************************

unit uMisc;

interface

function GetAppDataFolder: String;
function GetDllPath: String;
procedure MsgBox(const Msg: string);
function GetTempDirectory: string;
function GetSpecialFolder(const CSIDL: integer) : string;

implementation

uses
 Forms,
 WinApi.Windows,
 Winapi.ShlObj,
 SysUtils;

procedure MsgBox(const Msg: string);
begin
  Application.MessageBox(PChar(Msg), 'Information', MB_OK + MB_ICONINFORMATION);
end;

function GetDllPath: String;
 var
  Path: array[0..MAX_PATH-1] of Char;
begin
 SetString(Result, Path, GetModuleFileName(HInstance, Path, SizeOf(Path)));
end;

function GetTempDirectory: string;
var
  lpBuffer: array[0..MAX_PATH] of Char;
begin
  GetTempPath(MAX_PATH, @lpBuffer);
  Result := StrPas(lpBuffer);
end;

function GetWindowsDirectory : string;
var
  lpBuffer: array[0..MAX_PATH] of Char;
begin
  WinApi.Windows.GetWindowsDirectory(@lpBuffer, MAX_PATH);
  Result := StrPas(lpBuffer);
end;

function GetSpecialFolder(const CSIDL: integer) : string;
var
  lpszPath : PWideChar;
begin
  lpszPath := StrAlloc(MAX_PATH);
  try
     ZeroMemory(lpszPath, MAX_PATH);
    if SHGetSpecialFolderPath(0, lpszPath, CSIDL, False)  then
      Result := lpszPath
    else
      Result := '';
  finally
    StrDispose(lpszPath);
  end;
end;

function GetAppDataFolder: String;
begin
 Result:=IncludeTrailingPathDelimiter(GetSpecialFolder(CSIDL_APPDATA))+ 'DelphiPreviewHandler\';
 SysUtils.ForceDirectories(Result);
end;

end.
