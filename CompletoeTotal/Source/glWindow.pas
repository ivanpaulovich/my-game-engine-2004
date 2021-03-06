(*******************************************************)
(*                                                     *)
(*       Engine Paulovich DirectX                      *)
(*       Win32-DirectX API Unit                        *)
(*                                                     *)
(*       Copyright (c) 2003-2004, Ivan Paulovich       *)
(*                                                     *)
(*       iskatrek@hotmail.com  uin#89160524            *)
(*                                                     *)
(*       Unit: glWindow                                *)
(*                                                     *)
(*******************************************************)

unit glWindow;

interface

uses
  Windows, Messages, Classes, SysUtils;

type

  (* Events *)

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

  (* TReferer *)

  PWindowReferer = ^TWindowReferer;
  TWindowReferer = class of TWindow;

 (* TWindowOption *)

  TWindowOption = (doFullScreen, doAutoSize, doMaximizeBox, doMinimizeBox, doSysMenu,
    doCenter, doResMenu);

 (* TWindowOptions *)

  TWindowOptions = set of TWindowOption;

 (* TWindow *)

  PWindow = ^TWindow;
  TWindow = class
  private
    FHandle: HWND;
    FActive: Boolean;
    FInitialized: Boolean;
    FClientRect: TRect;
    FStyle: Integer;
    FKeys: array[0..255] of Byte;
    FClicked: Boolean;
    FNowOptions: TWindowOptions;
    FOptions: TWindowOptions;
    FCaption: string;
    FMenuName: Integer;
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
    FOnCommand: TCommandEvent;
    function KeyDown(var Message: TWMKey): Boolean;
    function KeyUp(var Message: TWMKey): Boolean;
    function KeyPress(var Message: TWMKey): Boolean;
    procedure MouseDown(var Message: TWMMouse; Button: TMouseButton;
      Shift: TShiftState);
    procedure MouseUp(var Message: TWMMouse; Button: TMouseButton);
    procedure MouseMove(var Message: TWMMouse);
    function GetBoundsRect: TRect;
    function GetKey(Index: Integer): Boolean;
    function GetCaption: string;
    procedure SetWindowRect;
    procedure SetWidth(Value: Integer);
    procedure SetHeight(Value: Integer);
    procedure SetLeft(Value: Integer);
    procedure SetTop(Value: Integer);
    procedure SetOptions(Value: TWindowOptions);
    procedure SetCaption(Value: string);
  protected
    procedure DoKeyDown(var Key: Word; Shift: TShiftState); virtual;
    procedure DoKeyPress(var Key: Char); virtual;
    procedure DoKeyUp(var Key: Word; Shift: TShiftState); virtual;
    procedure DoMouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); virtual;
    procedure DoMouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); virtual;
    procedure DoCommand(ID: Integer); virtual;
    procedure DoMouseMove(Shift: TShiftState; X, Y: Integer); virtual;
    procedure DoCreate; virtual;
    procedure DoInitialize; virtual;
    procedure DoFinalize; virtual;
    procedure DoResize; virtual;
  public
    constructor Create;
    destructor Destroy;
    function WndProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; virtual;
    function Run: Integer;
    function IsActive: Boolean;
    function HasMessages: Boolean;
    function Pump: Boolean;
    class function GetWindow: PWindow;
    property Initialized: Boolean read FInitialized;
    property Handle: HWND read FHandle;
    property Width: Integer read FClientRect.Right write SetWidth;
    property Height: Integer read FClientRect.Bottom write SetHeight;
    property Left: Integer read FClientRect.Left write SetLeft;
    property Top: Integer read FClientRect.Top write SetTop;
    property Caption: string read GetCaption write SetCaption;
    property MenuName: Integer read FmenuName write FMenuName;
    property NowOptions: TWindowOptions read FNowOptions;
    property Options: TWindowOptions read FOptions write SetOptions;
    property Key[Index: Integer]: Boolean read GetKey;
    property Client: TRect read FClientRect write FClientRect;
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
  end;

var
  Window: TWindow = nil;

implementation

uses
  glError, glConst;

const
  WINDOW_OPTIONS = [doMaximizeBox, doMinimizeBox, doSysMenu, doCenter];

var
  CountWindow: Integer = 0;
  Log: PLogError = nil;

function GlobalWndProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  Result := Window.WndProc(hWnd, uMsg, wParam, lParam);
end;

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

  (* TWindow *)

constructor TWindow.Create;
begin
  SaveLog(Format(EVENT_TALK, ['TWindow.Create']));

  Window := Self;

  FHandle := 0;
  FActive := False;
  FInitialized := False;
  SetRect(FClientRect, 0, 0, 640, 480);
  FStyle := 0;
  ZeroMemory(@FKeys, 256);
  FNowOptions := WINDOW_OPTIONS;
  FOptions := WINDOW_OPTIONS;
  FCaption := Format('Window%d', [CountWindow]);

  SaveLog(Format(EVENT_RESOLUTION, [FClientRect.Right, FClientRect.Bottom]));
  Inc(CountWindow);

  DoCreate;
end;

destructor TWindow.Destroy;
begin
  DoFinalize;
  DestroyWindow(FHandle);
  Window := nil;
end;

function TWindow.WndProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  MouseMessage: TWMMouse;
  KeyboardMessage: TWMKey;

  procedure UpdateMouse;
  begin
    MouseMessage.Msg := uMsg;
    MouseMessage.Keys := wParam;
    MouseMessage.XPos := LOWORD(lParam);
    MouseMessage.YPos := HIWORD(lParam);
  end;

  procedure UpdateKeyboard;
  begin
    KeyboardMessage.Msg := uMsg;
    KeyboardMessage.CharCode := wParam;
    KeyboardMessage.KeyData := Integer(@FKeys);
  end;

begin
  if Assigned(Log) then
  begin
    Result := DefWindowProc(hWnd, uMsg, wParam, lParam);
    Exit;
  end;

  try
    case uMsg of

      WM_CREATE:
        begin
          Window.FActive := True;
        end;

      WM_PAINT:
        begin
          ValidateRect(hWnd, nil);
        end;

      WM_MOVE:
        begin
          FClientRect.Left := LOWORD(lParam);
          FClientRect.Top := HIWORD(lParam);
        end;

      WM_SIZE:
        begin
          FClientRect.Right := LOWORD(lParam);
          FClientRect.Bottom := HIWORD(lParam);
          DoResize;
        end;

      WM_KEYDOWN:
        begin
          FKeys[wParam] := 1;
          UpdateKeyboard;
          KeyDown(KeyboardMessage);
        end;

      WM_CHAR:
        begin
          FKeys[wParam] := 1;
          UpdateKeyboard;
          KeyPress(KeyboardMessage);
        end;

      WM_KEYUP:
        begin
          FKeys[wParam] := 0;
          UpdateKeyboard;
          KeyUp(KeyboardMessage);
        end;

      WM_LBUTTONDOWN:
        begin
          UpdateMouse;
          MouseDown(MouseMessage, mbLeft, []);
        end;

      WM_LBUTTONUP:
        begin
          UpdateMouse;
          MouseUp(MouseMessage, mbLeft);
        end;

      WM_RBUTTONDOWN:
        begin
          UpdateMouse;
          MouseDown(MouseMessage, mbRight, []);
        end;

      WM_RBUTTONUP:
        begin
          UpdateMouse;
          MouseUp(MouseMessage, mbRight);
        end;

      WM_MOUSEMOVE:
        begin
          UpdateMouse;
          MouseMove(MouseMessage);
        end;
      WM_COMMAND:
        begin
          DoCommand(LOWORD(wParam));
        end;
      WM_DESTROY, WM_CLOSE:
        begin
          PostQuitMessage(0);
        end;

    else
      begin
        Result := DefWindowProc(hWnd, uMsg, wParam, lParam);
        Exit;
      end;
    end;

  except
    New(Log);
    Result := 0;
    Exit;
  end;

  Result := 0;
end;

function TWindow.Run: Integer;
var
  Wc: TWndClass;
begin
  Result := E_FAIL;

  SaveLog(Format(EVENT_TALK, ['TWindow.Run']));

  if doFullScreen in FNowOptions then
    FStyle := FStyle or WS_POPUP;

  if doMinimizeBox in FNowOptions then
    FStyle := FStyle or WS_MINIMIZEBOX;

  if doMaximizeBox in FNowOptions then
    FStyle := FStyle or WS_MAXIMIZEBOX;

  if doSysMenu in FNowOptions then
    FStyle := FStyle or WS_SYSMENU;

  if doAutoSize in FNowOptions then
  begin
    FClientRect.Left := 0;
    FClientRect.Top := 0;
    FClientRect.Right := GetSystemMetrics(SM_CXSCREEN);
    FClientRect.Bottom := GetSystemMetrics(SM_CYSCREEN);
  end;

  if DoCenter in FNowOptions then
    SetRect(FClientRect, (GetSystemMetrics(SM_CXSCREEN) - FClientRect.Right) div 2,
      (GetSystemMetrics(SM_CYSCREEN) - FClientRect.Bottom) div 2, FClientRect.Right, FClientRect.Bottom);

  FillChar(Wc, SizeOf(TWndClass), 0);
  Wc.lpszClassName := PChar(FCaption);
  Wc.lpfnWndProc := @GlobalWndProc;
  Wc.style := CS_VREDRAW or CS_HREDRAW;
  Wc.hInstance := HInstance;
  Wc.hIcon := LoadIcon(0, IDI_WINLOGO);
  Wc.hCursor := LoadCursor(0, IDC_ARROW);
  Wc.hbrBackground := GetStockObject(BLACK_BRUSH);
  if DoResMenu in FnowOptions then
    Wc.lpszMenuName := MakeIntResource(FMenuName)
  else
    Wc.lpszMenuName := nil;
  Wc.cbClsExtra := 0;
  Wc.cbWndExtra := 0;

  if Windows.RegisterClass(Wc) = 0 then
    raise ELogError.Create(Format(ERROR_REGISTRY, ['TWindow']))
  else
    SaveLog(Format(EVENT_REGISTRY, ['TWindow']));

  AdjustWindowRect(FClientRect, FStyle, False);

  FHandle := CreateWindow(PChar(FCaption), PChar(FCaption), FStyle or WS_VISIBLE, FClientRect.Left,
    FClientRect.Top, FClientRect.Right, FClientRect.Bottom, 0, 0, HInstance, nil);
  if FHandle = 0 then
    raise ELogError.Create(Format(ERROR_INSTANCE, ['TWindow']))
  else
  begin
    FInitialized := True;
    Result := S_OK;
    SaveLog(Format(EVENT_INSTANCE, ['TWindow']));
  end;

  DoInitialize;

  if not (doFullScreen in FOptions) then
    ShowWindow(FHandle, SW_SHOW);

  UpdateWindow(FHandle);
end;

function TWindow.IsActive: Boolean;
begin
  Result := FActive;
end;

function TWindow.HasMessages: Boolean;
var
  Msg: TMsg;
begin
  Result := PeekMessage(Msg, 0, 0, 0, PM_NOREMOVE);
end;

function TWindow.Pump: Boolean;
var
  Msg: TMsg;
  ErrorOut: ELogError;
begin
  PeekMessage(Msg, 0, 0, 0, PM_REMOVE);

  if Msg.message = WM_QUIT then
  begin
    Result := False;
    Exit;
  end;

  TranslateMessage(Msg);
  DispatchMessage(Msg);

  if Assigned(Log) then
  begin
    ErrorOut := Log^;
    Dispose(Log);
    raise ELogError.Create(Format(ERROR_SITE, ['TWindow.Pump']));
  end;

  Result := True;
end;

function TWindow.GetBoundsRect;
begin
  GetClientRect(FHandle, FClientRect);
  Result := FClientRect;
end;

function TWindow.GetKey(Index: Integer): Boolean;
begin
  Result := FKeys[Index] <> 0;
end;

function TWindow.GetCaption: string;
begin
  GetWindowText(FHandle, PChar(FCaption), 255);
  Result := FCaption;
end;

procedure TWindow.SetWindowRect;
begin
  MoveWindow(FHandle, FClientRect.Left, FClientRect.Top,
    FClientRect.Right, FClientRect.Bottom, True);
end;

procedure TWindow.SetWidth(Value: Integer);
begin
  FClientRect.Right := Value;
  SetWindowRect;
end;

procedure TWindow.SetHeight(Value: Integer);
begin
  FClientRect.Bottom := Value;
  SetWindowRect;
end;

procedure TWindow.SetLeft(Value: Integer);
begin
  FClientRect.Left := Value;
  SetWindowRect;
end;

procedure TWindow.SetTop(Value: Integer);
begin
  FClientRect.Top := Value;
  SetWindowRect;
end;

procedure TWindow.SetCaption(Value: string);
begin
  FCaption := Value;
  SetWindowText(FHandle, PChar(FCaption));
end;

procedure TWindow.SetOptions(Value: TWindowOptions);
var
  OldOptions: TWindowOptions;
begin
  FOptions := Value;
  FNowOptions := Value;
 { if FInitialized then
  begin
    OldOptions := FNowOptions;
    FNowOptions := FNowOptions * WINDOW_OPTIONS + (FOptions - WINDOW_OPTIONS);
  end
  else
    FNowOptions := FOptions;   }
end;

class function TWindow.GetWindow: PWindow;
begin
  Result := @Window;
end;

procedure TWindow.DoCreate;
begin
  if Assigned(FOnCreate) then FOnCreate(Self);
end;

procedure TWindow.DoInitialize;
begin
  if Assigned(FOnInitialize) then FOnInitialize(Self);
end;

procedure TWindow.DoFinalize;
begin
  if Assigned(FOnFinalize) then FOnFinalize(Self);
end;

procedure TWindow.DoResize;
begin
  if Assigned(FOnResize) then FOnResize(Self);
end;

function TWindow.KeyDown(var Message: TWMKey): Boolean;
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

function TWindow.KeyPress(var Message: TWMKey): Boolean;
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

function TWindow.KeyUp(var Message: TWMKey): Boolean;
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

procedure TWindow.DoKeyDown(var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyDown) then FOnKeyDown(Self, Key, Shift);
end;

procedure TWindow.DoKeyPress(var Key: Char);
begin
  if Assigned(FOnKeyPress) then FOnKeyPress(Self, Key);
end;

procedure TWindow.DoKeyUp(var Key: Word; Shift: TShiftState);
begin
  if Assigned(FOnKeyUp) then FOnKeyUp(Self, Key, Shift);
end;

procedure TWindow.MouseDown(var Message: TWMMouse; Button: TMouseButton;
  Shift: TShiftState);
begin
  FClicked := True;
  DoMouseDown(Button, KeysToShiftState(Message.Keys) + Shift, Message.XPos, Message.YPos);
end;

procedure TWindow.MouseUp(var Message: TWMMouse; Button: TMouseButton);
var
  Region: HRGN;
  Pos: TRect;
begin
  FClicked := False;
  Pos := GetBoundsRect;
  Region := CreateRectRgn(Pos.Left, Pos.Top, Pos.Right, Pos.Bottom);
  if PtInRegion(Region, Message.XPos, Message.YPos) then
    with Message do DoMouseUp(Button, KeysToShiftState(Keys), XPos, YPos);
end;

procedure TWindow.MouseMove(var Message: TWMMouse);
begin
  with Message do DoMouseMove(KeysToShiftState(Keys), XPos, YPos);
end;

procedure TWindow.DoMouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if Assigned(FOnMouseDown) then FOnMouseDown(Self, Button, Shift, Left, Top);
end;

procedure TWindow.DoMouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if Assigned(FOnMouseMove) then FOnMouseMove(Self, Shift, Left, Top);
end;

procedure TWindow.DoMouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  if Assigned(FOnMouseUp) then FOnMouseUp(Self, Button, Shift, Left, Top);
end;

procedure TWindow.DoCommand(ID: Integer);
begin
  if Assigned(FOnCommand) then FOnCommand(Self, ID);
end;

end.

