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
 System.SysUtils,
 System.Classes;

type
  TLogPreview = class
  private
    FLogStream: TStream;
  public
    property LogStream : TStream read FLogStream write FLogStream;
    class procedure Add(const AMessage :string); overload;
    class procedure Add(const AException : Exception); overload;
  end;


implementation

uses
  uMisc,
  IOUtils;

var
 sLogFile : string;
{ TLogException }
class procedure TLogPreview.Add(const AMessage: string);
begin
  TFile.AppendAllText(sLogFile, FormatDateTime('hh:nn:ss.zzz', Now) + ' ' + AMessage + sLineBreak);
end;

class procedure TLogPreview.Add(const AException :Exception);
begin
  TFile.AppendAllText(sLogFile, Format('%s %s StackTrace %s %s', [FormatDateTime('hh:nn:ss.zzz', Now), AException.Message, AException.StackTrace, sLineBreak]));
end;

initialization

 sLogFile := IncludeTrailingPathDelimiter(GetTempDirectory)+'shell.log';

end.
