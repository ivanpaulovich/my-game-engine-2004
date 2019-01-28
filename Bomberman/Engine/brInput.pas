(*******************************************************)
(*                                                     *)
(*       Engine Paulovich DirectX                      *)
(*       Win32-DirectX API Unit                        *)
(*                                                     *)
(*       Copyright (c) 2003-2004, Ivan Paulovich       *)
(*                                                     *)
(*       iskatrek@hotmail.com  uin#89160524            *)
(*                                                     *)
(*       Unit: brInput                                 *)
(*                                                     *)
(*******************************************************)

unit brInput;

interface

uses
  Windows, DirectInput8, SysUtils;

type

  TTimedInput = record
    Time: dWord;
    Used: boolean;
  end;

  TInput = class
  private
    FHandle: HWnd;
    DI8: IDirectInput8;
    DIK8: IDirectInputDevice8;
    DIM8: IDirectInputDevice8;
    DIJ8: IDirectInputDevice8;
    DIMEvent: THandle;
    DIMou0Clicked: Boolean;
    DIMou1Clicked: Boolean;
    DIJ8Caps: TDIDevCaps;
    function EnumJoysticksCallback(Device: PDIDeviceInstance; Ref: Pointer): Integer;
    function EnumAxesCallback(var Device: TDIDeviceObjectInstance; Ref: Pointer): Integer;
  public
    constructor Create(Handle: HWnd; Keyboard, Mouse, Joystick: Boolean);
    function Run: Integer;
    procedure Clear;
    function InitializeMouse: Boolean;
    function InitializeJoystick: Boolean;
    function InitializeKeyboard: Boolean;
    function MouseAcquire(Acquire: Boolean): Boolean;
    function MouseState(var X, Y: LongInt; var Up0, Down0, DblClk0,
      Up1, Down1, DblClk1: Longint): Boolean;
    function JoystickState(var Data: TDIJoyState2): Boolean;
    function KeyboardAcquire(Acquire: Boolean): Boolean;
    function KeyboardState: Boolean;
    function KeyDown(Key: Byte): Boolean;
    property Handle: HWnd read FHandle;
  end;

var
  Input: TInput = nil;

procedure TimedInputReset(var Ti: TTimedInput);
function TimedInputRefresh(var Ti: TTimedInput; _Time, TimeOut: DWord;
  Condition: Boolean): Longint;

implementation

uses
  brForms;

const
  DIMBufSize = 16;
  DIMTimeOut = 250;

  DIJoyRange = 32768;

var
  DIMButSwapped: Boolean = False;
  DIM0Released: DWord = 0;
  DIM1Released: DWord = 0;

  DIKeyBuffer: array[0..255] of Byte;

procedure TimedInputReset(var Ti: TTimedInput);
begin
  Ti.Time := 0;
  Ti.Used := False;
end;

function TimedInputRefresh(var Ti: TTimedInput; _Time, TimeOut: DWord;
  Condition: Boolean): LongInt;

begin
  Result := 0;
  if (Ti.Time = 0) and (Condition) then
  begin
    Ti.Time := _Time;
    Exit;
  end;

  if Ti.Time <> 0 then
    if Condition then
    begin
      if _Time - Ti.Time >= Timeout then
      begin
        Ti.Used := true;
        while _Time - Ti.Time >= Timeout do
        begin
          Inc(Result);
          Inc(Ti.Time, Timeout)
        end;
      end;
    end
    else
    begin
      if not Ti.Used then
        Inc(Result);
      Ti.Used := false;
      Ti.Time := 0;
    end;
end;

function GlobalEnumJoysticksCallback(Device: PDIDeviceInstance; Ref: Pointer): Integer; stdcall;
begin
  Input.EnumJoysticksCallback(Device, Ref);
end;

function GlobalEnumAxesCallback(var Device: TDIDeviceObjectInstance; Ref: pointer): Integer; stdcall;
begin
  Input.EnumAxesCallback(Device, Ref);
end;

constructor TInput.Create;
begin
  if Assigned(Input) then
    raise ELogError.Create(Format(ERROR_EXISTS, ['TInput']))
  else
    SaveLog(Format(EVENT_CREATE, ['TInput']));
  DI8 := nil;
  DIK8 := nil;
  DIM8 := nil;
  DIJ8 := nil;
  FHandle := Handle;
end;

function TInput.Run: Integer;
begin
  Clear;

  SaveLog(Format(EVENT_TALK, ['TInput.Run']));

  if Failed(DirectInput8Create(hInstance, DIRECTINPUT_VERSION, IID_IDirectInput8,
    DI8, nil)) then
    Result := E_FAIL
  else
    Result := S_OK;
end;

procedure TInput.Clear;
begin
  if Assigned(DI8) then
  begin
    if Assigned(DIK8) then
    begin
      DIK8.Unacquire;
      DIK8 := nil;
    end;
    if Assigned(DIM8) then
    begin
      DIM8.Unacquire;
      DIM8 := nil;
    end;
    if Assigned(DIJ8) then
    begin
      DIJ8.Unacquire;
      DIJ8 := nil;
    end;
    DI8 := nil;
  end;
end;

function TInput.InitializeMouse: Boolean;
var
  Prop: TDIPropDWord;
begin
  Result := false;

  DIMButSwapped := GetSystemMetrics(SM_SWAPBUTTON) <> 0;

  if Failed(DI8.CreateDevice(GUID_SysMouse, DIM8, nil)) then
    Exit;

  if Failed(DIM8.SetDataFormat(@c_dfDIMouse)) then
    Exit;

  if Failed(DIM8.SetCooperativeLevel(Handle, DISCL_FOREGROUND or DISCL_EXCLUSIVE)) then
    Exit;

  DIMEvent := CreateEvent(nil, False, False, nil);
  if DIMEvent = 0 then
    Exit;

  if Failed(DIM8.SetEventNotification(DIMEvent)) then
    Exit;

  with Prop do begin
    diph.dwSize := SizeOf(TDIPropDWord);
    diph.dwHeaderSize := SizeOf(TDIPropHeader);
    diph.dwObj := 0;
    diph.dwHow := DIPH_DEVICE;
    dwData := DIMBufSize;
  end;

  if Failed(DIM8.SetProperty(DIPROP_BUFFERSIZE, Prop.diph)) then
    Exit;

  Result := True;
end;

function TInput.MouseAcquire(Acquire: Boolean): Boolean;
begin
  if not Acquire then
    Result := not Failed(DIM8.Unacquire)
  else
    Result := not Failed(DIM8.Acquire);
end;

function TInput.MouseState(var X, Y: LongInt; var Up0, Down0, DblClk0,
  Up1, Down1, DblClk1: Longint): Boolean;
var
  Hr: HRESULT;
  Objdata: TDIDeviceObjectData;
  Zero, One: Boolean;
  _Time: DWord;
  Elements: DWord;
begin
  Result := false;

  X := 0;
  Y := 0;
  Up0 := 0;
  Down0 := 0;
  DblClk0 := 0;
  Up1 := 0;
  Down1 := 0;
  DblClk1 := 0;

  repeat
    Elements := 1;
    Hr := DIM8.GetDeviceData(SizeOf(TDIDeviceObjectData), @Objdata, Elements, 0);
    if Hr = DIERR_INPUTLOST then
    begin
      Hr := DIM8.Acquire;
      if not Failed(hr) then
        Hr := DIM8.GetDeviceData(SizeOf(TDIDeviceObjectData), @ObjData, Elements, 0);
    end;

    if (Failed(Hr)) then
      Exit;
    Result := True;
    if (Elements = 0) then
      Exit;

    Zero := False;
    One := False;
    case ObjData.dwOfs of
      DIMOFS_X: X := X + LongInt(ObjData.dwData);
      DIMOFS_Y: Y := Y + LongInt(ObjData.dwData);
      DIMOFS_BUTTON0: if DIMButSwapped then
          One := True
        else
          Zero := True;
      DIMOFS_BUTTON1: if DIMButSwapped then
          Zero := True
        else
          One := True;
    end;

    if Zero then
    begin
      DIMou0Clicked := (ObjData.dwData and $80 = $80);
      if not DIMou0Clicked then
      begin
        Inc(Up0);

        _Time := GetTickCount;
        if (_Time - DIM0Released < DIMTimeOut) then
        begin
          DIM0Released := 0;
          Inc(DblClk0);
        end
        else
          DIM0Released := _time;
      end
      else
        Inc(Down0);
    end;

    if One then
    begin
      DIMou1Clicked := (ObjData.dwData and $80 = $80);
      if not DIMou1Clicked then
      begin
        Inc(Up1);

        _Time := GetTickCount;
        if (_Time - DIM1Released < DIMTimeOut) then
        begin
          DIM1Released := 0;
          Inc(DblClk1);
        end
        else
          DIM1Released := _Time;
      end
      else
        Inc(Down1);
    end;
  until Elements = 0;
end;

function TInput.EnumJoysticksCallback(Device: PDIDeviceInstance; Ref: Pointer): Integer;
begin
  Result := DIENUM_CONTINUE;
  if Failed(DI8.CreateDevice(Device.guidInstance, DIJ8, nil)) then
    Exit;
  Result := DIENUM_STOP;
end;

function TInput.EnumAxesCallback(var Device: TDIDeviceObjectInstance; Ref: Pointer): Integer;
var
  PropRange: TDIPropRange;
begin
  Result := DIENUM_CONTINUE;

  PropRange.diph.dwSize := Sizeof(TDIPropRange);
  PropRange.diph.dwHeaderSize := Sizeof(TDIPropHeader);
  PropRange.diph.dwHow := DIPH_BYID;
  PropRange.diph.dwObj := Device.dwType;
  PropRange.lMin := -DIJoyRange;
  PropRange.lMax := DIJoyRange;

  if Failed(DIJ8.SetProperty(DIPROP_RANGE, PropRange.diph)) then
    Result := DIENUM_STOP;
end;

function TInput.InitializeJoystick: Boolean;
begin
  Result := False;

  DI8.EnumDevices(DI8DEVCLASS_GAMECTRL, @GlobalEnumJoysticksCallback, nil, DIEDFL_ATTACHEDONLY);
  if DIJ8 = nil then
    Exit;

  if Failed(DIJ8.SetDataFormat(@c_dfDIJoystick2)) then
  begin
    DIJ8 := nil;
    Exit;
  end;

  if Failed(DIJ8.SetCooperativeLevel(Handle, DISCL_EXCLUSIVE or DISCL_FOREGROUND)) then
  begin
    DIJ8 := nil;
    Exit;
  end;

  DIJ8CAPS.dwSize := Sizeof(TDIDevCaps);
  if Failed(DIJ8.GetCapabilities(DIJ8CAPS)) then
  begin
    DIJ8 := nil;
    Exit;
  end;

  if Failed(DIJ8.EnumObjects(GlobalEnumAxesCallback, nil, DIDFT_AXIS)) then
  begin
    DIJ8 := nil;
    Exit;
  end;

  Result := True;
end;

function TInput.JoystickState(var Data: TDIJoyState2): Boolean;
begin
  Result := False;

  if Failed(DIJ8.Poll) then
    if DIJ8.Acquire = DIERR_INPUTLOST then
      if Failed(DIJ8.Acquire) then
        Exit;

  Result := not Failed(DIJ8.GetDeviceState(Sizeof(TDIJoyState2), @Data));
end;

function TInput.InitializeKeyboard: Boolean;
begin
  Result := False;

  if Failed(DI8.CreateDevice(GUID_SysKeyboard, DIK8, nil)) then
    Exit;

  if Failed(DIK8.SetDataFormat(@c_dfDIKeyboard)) then
    Exit;

  if Failed(DIK8.SetCooperativeLevel(Handle, DISCL_FOREGROUND or DISCL_NONEXCLUSIVE)) then
    Exit;

  Result := True;
end;

function TInput.KeyboardAcquire(Acquire: Boolean): Boolean;
var
  Hr: hResult;
begin
  if not Acquire then
    Result := not Failed(DIK8.Unacquire)
  else
    Result := not Failed(DIK8.Acquire);
end;

function TInput.KeyboardState: Boolean;
var
  Hr: HRESULT;
begin
  Hr := DIK8.GetDeviceState(SizeOf(DIKeyBuffer), @DIKeyBuffer);

  if Hr = DIERR_INPUTLOST then
  begin
    Hr := DIK8.Acquire;
    if not Failed(Hr) then
      Hr := DIK8.GetDeviceState(SizeOf(DIKeyBuffer), @DIKeyBuffer);
  end;

  Result := not Failed(Hr);
end;

function TInput.KeyDown(Key: Byte): Boolean;
begin
  Result := (DIKeyBuffer[Key] and $80 = $80);
end;

begin
  ZeroMemory(@DIKeyBuffer, SizeOf(DIKeyBuffer));
end.

