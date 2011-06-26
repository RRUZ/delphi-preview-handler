{**************************************************************************************************}
{                                                                                                  }
{ Unit uMisc                                                                                       }
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
{ The Original Code is uMisc.pas.                                                                  }
{                                                                                                  }
{ The Initial Developer of the Original Code is Rodrigo Ruz V.                                     }
{ Portions created by Rodrigo Ruz V. are Copyright (C) 2011 Rodrigo Ruz V.                         }
{ All Rights Reserved.                                                                             }
{                                                                                                  }
{**************************************************************************************************}


unit uMisc;

interface


  function GetDllPath: String;
  procedure MsgBox(const Msg: string);

implementation

uses
 Forms,
 Windows,
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


end.
