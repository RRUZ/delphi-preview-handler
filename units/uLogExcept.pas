//**************************************************************************************************
//
// Unit uLogExcept
// unit for the Delphi Preview Handler  https://github.com/RRUZ/delphi-preview-handler
//
// The contents of this file are subject to the Mozilla Public License Version 1.1 (the "License");
// you may not use this file except in compliance with the License. You may obtain a copy of the
// License at http://www.mozilla.org/MPL/
//
// Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF
// ANY KIND, either express or implied. See the License for the specific language governing rights
// and limitations under the License.
//
// The Original Code is uLogExcept.pas.
//
// The Initial Developer of the Original Code is Rodrigo Ruz V.
// Portions created by Rodrigo Ruz V. are Copyright (C) 2011-2015 Rodrigo Ruz V.
// All Rights Reserved.
//
//*************************************************************************************************

unit uLogExcept;

interface

Uses
 System.Classes;

type
  TLogException = class
  private
    FLogStream: TStream;
  public
    property LogStream : TStream read FLogStream write FLogStream;
    class procedure Add(const StrException :string);
  end;


implementation

uses
  SysUtils,
  IOUtils;

{ TLogException }
class procedure TLogException.Add(const StrException: string);
begin
  TFile.AppendAllText('C:\Users\RRUZ\AppData\Local\Temp\shell.log', FormatDateTime('hh:nn:ss.zzz', Now) + ' ' + StrException + sLineBreak);
end;

end.
