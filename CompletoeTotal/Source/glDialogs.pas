(*******************************************************)
(*                                                     *)
(*       Engine Paulovich DirectX                      *)
(*       Win32-DirectX API Unit                        *)
(*                                                     *)
(*       Copyright (c) 2003-2004, Ivan Paulovich       *)
(*                                                     *)
(*       iskatrek@hotmail.com  uin#89160524            *)
(*                                                     *)
(*       Unit: glDialogs                               *)
(*                                                     *)
(*******************************************************)

unit glDialogs;

interface

uses
  Windows, CommDlg, glConst;

const
  {$EXTERNALSYM OPENFILENAME_SIZE_VERSION_400A}
  OPENFILENAME_SIZE_VERSION_400A = SizeOf(TOpenFileNameA) -
    SizeOf(Pointer) - (2 * SizeOf(DWord));
  {$EXTERNALSYM OPENFILENAME_SIZE_VERSION_400W}
  OPENFILENAME_SIZE_VERSION_400W = SizeOf(TOpenFileNameW) -
    Sizeof(Pointer) - (2 * SizeOf(DWord));
  {$EXTERNALSYM OPENFILENAME_SIZE_VERSION_400}
  OPENFILENAME_SIZE_VERSION_400  = OPENFILENAME_SIZE_VERSION_400A;

function IsNT5OrHigher: Boolean;
function OpenFile(Handle: HWnd): string;
function SaveFile(Handle: HWnd): string;

implementation

function IsNT5OrHigher: Boolean;
var
  Ovi: TOSVERSIONINFO;
begin
  ZeroMemory(@Ovi, SizeOf(TOSVERSIONINFO));
  Ovi.dwOSVersionInfoSize := SizeOf(TOSVERSIONINFO);
  GetVersionEx(Ovi);
  if (Ovi.dwPlatformId = VER_PLATFORM_WIN32_NT) and (ovi.dwMajorVersion >= 5) then
    Result := True
  else
    Result := False;
end;

function OpenFile(Handle: HWnd): string;
var
  Ofn: TOpenFilename;
  Buffer: array[0..MAX_PATH - 1] of Char;
begin
  Result := '';
  ZeroMemory(@Buffer[0], SizeOf(Buffer));
  ZeroMemory(@Ofn, SizeOf(TOpenFilename));
  if IsNt5OrHigher then
    Ofn.lStructSize := SizeOf(TOpenFilename)
  else
    Ofn.lStructSize := OPENFILENAME_SIZE_VERSION_400;
  Ofn.hWndOwner := Handle;
  Ofn.hInstance := hInstance;
  Ofn.lpstrFile := @Buffer[0];
  Ofn.lpstrFilter := FILE_FILTER;
  Ofn.nMaxFile := SizeOf(Buffer);
  Ofn.Flags := OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or OFN_LONGNAMES or
    OFN_EXPLORER or OFN_HIDEREADONLY;
  Ofn.lpstrTitle := MSG_OPEN;

  if GetOpenFileName(Ofn) then
    Result := Ofn.lpstrFile;
end;

function SaveFile(Handle: HWnd): string;
var
  Ofn: TOpenFilename;
  Buffer: array[0..MAX_PATH - 1] of Char;
begin
  Result := '';
  ZeroMemory(@Buffer[0], SizeOf(Buffer));
  ZeroMemory(@Ofn, SizeOf(TOpenFilename));
  if IsNt5OrHigher then
    Ofn.lStructSize := SizeOf(TOpenFilename)
  else
    Ofn.lStructSize := OPENFILENAME_SIZE_VERSION_400;
  Ofn.hWndOwner := Handle;
  Ofn.hInstance := hInstance;
  Ofn.lpstrFile := @Buffer[0];
  Ofn.lpstrFilter := FILE_FILTER;
  Ofn.nMaxFile := SizeOf(Buffer);
  Ofn.Flags := OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or OFN_LONGNAMES or
    OFN_EXPLORER or OFN_HIDEREADONLY;
  Ofn.lpstrTitle := MSG_SAVE;

  if GetSaveFileName(Ofn) then
    Result := Ofn.lpstrFile;
end;

end.
