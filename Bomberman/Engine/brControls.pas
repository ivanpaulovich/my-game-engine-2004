(*******************************************************)
(*                                                     *)
(*       Engine Paulovich DirectX                      *)
(*       Win32-DirectX API Unit                        *)
(*                                                     *)
(*       Copyright (c) 2003-2004, Ivan Paulovich       *)
(*                                                     *)
(*       iskatrek@hotmail.com  uin#89160524            *)
(*                                                     *)
(*       Unit: brControls                              *)
(*                                                     *)
(*******************************************************)

unit brControls;

interface

uses
  Windows, Messages, SysUtils, Classes, brUtils;

type

  (* Eventos *)

  TMouseButton = (mbLeft, mbRight, mbMiddle);
  TShiftState = set of (ssShift, ssAlt, ssCtrl,
    ssLeft, ssRight, ssMiddle, ssDouble);
  TNotifyEvent = procedure(Sender: TObject) of object;
  TCommandEvent = procedure(Sender: TObject; ID: Integer) of object;
  TMouseEvent = procedure(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer) of object;
  TMouseMoveEvent = procedure(Sender: TObject; Shift: TShiftState;
    X, Y: Integer) of object;
  TKeyEvent = procedure(Sender: TObject; var Key: Word;
    Shift: TShiftState) of object;
  TKeyPressEvent = procedure(Sender: TObject; var Key: Char) of object;

  PControl = ^TControl;
  TControl = class
  private
    FOnCreate: TNotifyEvent;
    FOnInitialize: TNotifyEvent;
    FOnFinalize: TNotifyEvent;
    FOnResize: TNotifyEvent;
    FOnClick: TNotifyEvent;
    FOnDblClick: TNotifyEvent;
    FOnMouseDown: TMouseEvent;
    FOnMouseMove: TMouseMoveEvent;
    FOnMouseUp: TMouseEvent;
    FOnKeyDown: TKeyEvent;
    FOnKeyPress: TKeyPressEvent;
    FOnKeyUp: TKeyEvent;
    FOnMouseEnter: TNotifyEvent;
    FOnMouseLeave: TNotifyEvent;
  protected
    procedure SetWidth(Value: Integer); virtual;
    procedure SetHeight(Value: Integer); virtual;
    procedure SetLeft(Value: Integer); virtual;
    procedure SetTop(Value: Integer); virtual;
  public
    Clicked: Boolean;
    ClientRect: TRect;
    MouseIn: Boolean;
    constructor Create; virtual;
    procedure MouseDown(var Message: TWMMouse; Button: TMouseButton;
      Shift: TShiftState);
    procedure MouseMove(var Message: TWMMouse);
    procedure MouseUp(var Message: TWMMouse; Button: TMouseButton);
    function KeyDown(var Message: TWMKey): Boolean;
    function KeyPress(var Message: TWMKey): Boolean;
    function KeyUp(var Message: TWMKey): Boolean;
    procedure DoCreate; virtual;
    procedure DoInitialize; virtual;
    procedure DoFinalize; virtual;
    procedure DoResize; virtual;
    procedure DoClick; virtual;
    procedure DoDblClick; virtual;
    procedure DoMouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); virtual;
    procedure DoMouseMove(Shift: TShiftState; X, Y: Integer); virtual;
    procedure DoMouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); virtual;
    procedure DoKeyDown(var Key: Word; Shift: TShiftState); virtual;
    procedure DoKeyPress(var Key: Char); virtual;
    procedure DoKeyUp(var Key: Word; Shift: TShiftState); virtual;
    procedure DoMouseEnter; virtual;
    procedure DoMouseLeave; virtual;
    property Left: Integer read ClientRect.Left write SetLeft;
    property Top: Integer read ClientRect.Top write SetTop;
    property Width: Integer read ClientRect.Right write SetWidth;
    property Height: Integer read ClientRect.Bottom write SetHeight;
    property OnCreate: TNotifyEvent read FOnCreate write FOnCreate;
    property OnInitialize: TNotifyEvent read FOnInitialize write FOnInitialize;
    property OnFinalize: TNotifyEvent read FOnFinalize write FOnFinalize;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnMouseDown: TMouseEvent read FOnMouseDown write FOnMouseDown;
    property OnMouseMove: TMouseMoveEvent read FOnMouseMove write FOnMouseMove;
    property OnMouseUp: TMouseEvent read FOnMouseUp write FOnMouseUp;
    property OnKeyDown: TKeyEvent read FOnKeyDown write FOnKeyDown;
    property OnKeyPress: TKeyPressEvent read FOnKeyPress write FOnKeyPress;
    property OnKeyUp: TKeyEvent read FOnKeyUp write FOnKeyUp;
    property OnMouseEnter: TNotifyEvent read FOnMouseEnter write FOnMouseEnter;
    property OnMouseLeave: TNotifyEvent read FOnMouseLeave write FOnMouseLeave;
  end;

function KeysToShiftState(Keys: Word): TShiftState;
function KeyDataToShiftState(KeyData: Longint): TShiftState;

var
  ControlList: TList;

implementation

function KeysToShiftState(Keys: Word): TShiftState;
begin
  Result := [];
  if Keys and MK_SHIFT <> 0 then Include(Result, ssShift);
  if Keys and MK_CONTROL <> 0 then Include(Result, ssCtrl);
  if Keys and MK_LBUTTON <> 0 then Include(Result, ssLeft);
  if Keys and MK_RBUTTON <> 0 then Include(Result, ssRight);
  if Keys and MK_MBUTTON <> 0 then Include(Result, ssMiddle);
  if GetKeyState(VK_MENU) < 0 then Include(Result, ssAlt);
end;

function KeyDataToShiftState(KeyData: Longint): TShiftState;
const
  AltMask = $20000000;
begin
  Result := [];
  if GetKeyState(VK_SHIFT) < 0 then Include(Result, ssShift);
  if GetKeyState(VK_CONTROL) < 0 then Include(Result, ssCtrl);
  if KeyData and AltMask <> 0 then Include(Result, ssAlt);
end;

constructor TControl.Create;
begin
  ControlList.Add(Self);
end;

procedure TControl.MouseDown(var Message: TWMMouse; Button: TMouseButton;
  Shift: TShiftState);
begin
  with Message do
    if PointInRect(Point(XPos, YPos), Bounds(Left, Top, Width, Height)) then
    begin
      Clicked := True;
      DoMouseDown(Button, KeysToShiftState(Keys) + Shift, XPos, YPos);
      DoClick;
    end;
end;

procedure TControl.MouseMove(var Message: TWMMouse);
begin
  with Message do
    if PointInRect(Point(XPos, YPos), Bounds(Left, Top, Width, Height)) then
    begin
      DoMouseMove(KeysToShiftState(Keys), XPos, YPos);
      if not MouseIn then
        DoMouseEnter;
      MouseIn := True;
    end
    else
    begin
      if MouseIn then
        DoMouseLeave;
      MouseIn := False;
    end;
end;

procedure TControl.MouseUp(var Message: TWMMouse; Button: TMouseButton);
begin
  with Message do
    if PointInRect(Point(XPos, YPos), Bounds(Left, Top, Width, Height)) then
      DoMouseUp(Button, KeysToShiftState(Keys), XPos, YPos);
  Clicked := False;
end;

function TControl.KeyDown(var Message: TWMKey): Boolean;
var
  ShiftState: TShiftState;
begin
  with Message do
  begin
    ShiftState := KeyDataToShiftState(KeyData);
    DoKeyDown(CharCode, ShiftState);
  end;
  Result := Message.CharCode <> 0;
end;

function TControl.KeyPress(var Message: TWMKey): Boolean;
var
  Ch: Char;
begin
  with Message do
  begin
    Ch := Char(CharCode);
    DoKeyPress(Ch);
    CharCode := Word(Ch);
  end;
  Result := Char(Message.CharCode) <> #0;
end;

function TControl.KeyUp(var Message: TWMKey): Boolean;
var
  ShiftState: TShiftState;
begin
  with Message do
  begin
    ShiftState := KeyDataToShiftState(KeyData);
    DoKeyUp(CharCode, ShiftState);
  end;
  Result := Message.CharCode <> 0;
end;

procedure TControl.DoCreate;
begin
  if Assigned(FOnCreate) then FOnCreate(Self);
end;

procedure TControl.DoInitialize;
begin
  if Assigned(FOnInitialize) then FOnInitialize(Self);
end;

procedure TControl.DoFinalize;
begin
  if Assigned(FOnFinalize) then FOnFinalize(Self);
end;

procedure TControl.DoResize;
begin
  if Assigned(FOnResize) then FOnResize(Self);
end;

procedure TControl.DoClick;
begin
  if Assigned(FOnClick) then FOnClick(Self);
end;

procedure TControl.DoDblClick;
begin
  if Assigned(FOnDblClick) then FOnDblClick(Self);
end;

procedure TControl.DoMouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if Assigned(FOnMouseDown) then FOnMouseDown(Self, Button, Shift, Left, Top);
end;

procedure TControl.DoMouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseMove) then FOnMouseMove(Self, Shift, Left, Top);
end;

procedure TControl.DoMouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if Assigned(FOnMouseUp) then FOnMouseUp(Self, Button, Shift, Left, Top);
end;

procedure TControl.DoKeyDown(var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyDown) then FOnKeyDown(Self, Key, Shift);
end;

procedure TControl.DoKeyPress(var Key: Char);
begin
  if Assigned(FOnKeyPress) then FOnKeyPress(Self, Key);
end;

procedure TControl.DoKeyUp(var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyUp) then FOnKeyUp(Self, Key, Shift);
end;

procedure TControl.DoMouseEnter;
begin
  if Assigned(FOnMouseEnter) then FOnMouseEnter(Self);
end;

procedure TControl.DoMouseLeave;
begin
  if Assigned(FOnMouseLeave) then FOnMouseLeave(Self);
end;

procedure TControl.SetWidth(Value: Integer);
begin
  ClientRect.Right := Value;
end;

procedure TControl.SetHeight(Value: Integer);
begin
  ClientRect.Bottom := Value;
end;

procedure TControl.SetLeft(Value: Integer);
begin
  ClientRect.Left := Value;
end;

procedure TControl.SetTop(Value: Integer);
begin
  ClientRect.Top := Value;
end;

initialization
  ControlList := TList.Create;

end.

