(*******************************************************)
(*                                                     *)
(*       Engine Paulovich DirectX                      *)
(*       Win32-DirectX API Unit                        *)
(*                                                     *)
(*       Copyright (c) 2003-2004, Ivan Paulovich       *)
(*                                                     *)
(*       iskatrek@hotmail.com  uin#89160524            *)
(*                                                     *)
(*       Unit: glError                                 *)
(*                                                     *)
(*******************************************************)

unit glError;

interface

uses
  Windows, SysUtils, glConst;

type

 (* EError *)

  EError = class(Exception);

 (* ELogError *)

  PLogError = ^ELogError;
  ELogError = class(EError)
  public
    constructor Create(const Text: string);
  end;

function SaveLog(const FileName, Text: string): string; overload;
function SaveLog(const Text: string): string; overload;

implementation

function SaveLog(const FileName, Text: string): string;
var
  FileLog: TextFile;
begin
  AssignFile(FileLog, FileName);
  if FileExists(FileName) then
    Append(FileLog)
  else
    Rewrite(FileLog);
  try
    Writeln(FileLog, DateTimeToStr(Now) + ': ' + Text);
  finally
    CloseFile(FileLog);
  end;

  Result := Text;
end;

function SaveLog(const Text: string): string;
begin
  SaveLog(FILE_LOG, Text);
end;

 (* ELogError *)

constructor ELogError.Create(const Text: string);
begin
  Message := SaveLog(Text);
end;

end.
