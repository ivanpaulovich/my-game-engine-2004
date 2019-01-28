(*******************************************************)
(*                                                     *)
(*       Engine Paulovich DirectX                      *)
(*       Win32-DirectX API Unit                        *)
(*                                                     *)
(*       Copyright (c) 2003-2004, Ivan Paulovich       *)
(*                                                     *)
(*       iskatrek@hotmail.com  uin#89160524            *)
(*                                                     *)
(*       Unit: brUtils                                 *)
(*                                                     *)
(*******************************************************)

unit brUtils;

interface

uses
  Windows, SysUtils;

 (* Outras Funções *)

function Max(Val1, Val2: Integer): Integer;
function Min(Val1, Val2: Integer): Integer;

procedure InitCosinTable;
function Cos256(i: Integer): Double;
function Sin256(i: Integer): Double;

function PointInRect(const Point: TPoint; const Rect: TRect): Boolean;
function RectInRect(const Rect1, Rect2: TRect): Boolean;
function OverlapRect(const Rect1, Rect2: TRect): Boolean;

function WideRect(ALeft, ATop, AWidth, AHeight: Integer): TRect;

function Show(hWnd: HWND; const Text, Caption: string; Flags: UINT): Integer;

implementation

 (* Outras Funções *)

function Max(Val1, Val2: Integer): Integer;
begin
  if Val1 >= Val2 then Result := Val1 else Result := Val2;
end;

function Min(Val1, Val2: Integer): Integer;
begin
  if Val1 <= Val2 then Result := Val1 else Result := Val2;
end;

function PointInRect(const Point: TPoint; const Rect: TRect): Boolean;
begin
  Result := (Point.X >= Rect.Left) and
    (Point.X <= Rect.Right) and
    (Point.Y >= Rect.Top) and
    (Point.Y <= Rect.Bottom);
end;

function RectInRect(const Rect1, Rect2: TRect): Boolean;
begin
  Result := (Rect1.Left >= Rect2.Left) and
    (Rect1.Right <= Rect2.Right) and
    (Rect1.Top >= Rect2.Top) and
    (Rect1.Bottom <= Rect2.Bottom);
end;

function OverlapRect(const Rect1, Rect2: TRect): Boolean;
begin
  Result := (Rect1.Left < Rect2.Right) and
    (Rect1.Right > Rect2.Left) and
    (Rect1.Top < Rect2.Bottom) and
    (Rect1.Bottom > Rect2.Top);
end;

function WideRect(ALeft, ATop, AWidth, AHeight: Integer): TRect;
begin
  with Result do
  begin
    Left := ALeft;
    Top := ATop;
    Right := ALeft + AWidth;
    Bottom := ATop + AHeight;
  end;
end;

function Show(hWnd: HWND; const Text, Caption: string; Flags: UINT): Integer;
begin
  Result := MessageBox(hWnd, PChar(Text), PChar(Caption), Flags);
end;

var
  CosinTable: array[0..255] of Double;

procedure InitCosinTable;
var
  i: Integer;
begin
  for i := 0 to 255 do
    CosinTable[i] := Cos((i / 256) * 2 * PI);
end;

function Cos256(i: Integer): Double;
begin
  Result := CosinTable[i and 255];
end;

function Sin256(i: Integer): Double;
begin
  Result := CosinTable[(i + 192) and 255];
end;

end.

