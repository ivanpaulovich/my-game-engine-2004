(*******************************************************)
(*                                                     *)
(*       Engine Paulovich DirectX                      *)
(*       Win32-DirectX API Unit                        *)
(*                                                     *)
(*       Copyright (c) 2003-2004, Ivan Paulovich       *)
(*                                                     *)
(*       iskatrek@hotmail.com  uin#89160524            *)
(*                                                     *)
(*       Unit: glApplication                           *)
(*                                                     *)
(*******************************************************)

unit glApplication;

interface

uses
  Windows, SysUtils, Classes, MMSystem, glWindow, gl3DGraphics, glCanvas;

type

  (* Events *)

  TDoFrameEvent = procedure(Sender: TObject; TimeDelta: Single) of object;

  (* TReferer *)

  PReferer = ^TReferer;
  TReferer = class of TApplication;

  (* TFPS *)

  PFps = ^TFps;
  TFps = record
    Time: Cardinal;
    Ticks: Cardinal;
    FPS: Cardinal;
  end;

  (* TApplication *)

  PApplication = ^TApplication;
  TApplication = class
  private
    FHandle: HWND;
    FActive: Boolean;
    FFps: TFps;
    FOnInitialize: TNotifyEvent;
    FOnFinalize: TNotifyEvent;
    FOnDoFrame: TDoFrameEvent;
    FOnDoIdleFrame: TDoFrameEvent;
    function GetExeName: string;
  protected
    procedure DoInitialize; virtual;
    procedure DoFinalize; virtual;
    procedure DoFrame(TimeDelta: Single); virtual;
    procedure DoIdleFrame(TimeDelta: Single); virtual;
  public
    constructor Create;
    destructor Destroy;
    procedure Initialize;
    procedure CreateForm(InstanceClass: TWindowReferer; var Reference);
    procedure CreateGraphics(InstanceClass: TGraphicsReferer; var Reference);
    function Run: Integer;
    procedure Pause;
    procedure UnPause;
    procedure Terminate;
    class function GetApplication: PApplication;
    class procedure KillApplication;
    property Active: Boolean read FActive write FActive; 
    property ExeName: string read GetExeName;
    property Handle: HWND read FHandle;
    property Fps: Cardinal read FFps.Fps;
    property OnInitialize: TNotifyEvent read FOnInitialize write FOnInitialize;
    property OnFinalize: TNotifyEvent read FOnFinalize write FOnFinalize;
    property OnDoFrame: TDoFrameEvent read FOnDoFrame write FOnDoFrame;
    property OnDoIdleFrame: TDoFrameEvent read FOnDoIdleFrame write FOnDoIdleFrame;
  end;

var
  Application: TApplication = nil;

implementation

uses
  glError, glConst;

  (* TApplication *)

constructor TApplication.Create;
begin
  SaveLog(Format(EVENT_TALK, ['TApplication.Create']));

  if Assigned(Application) then
    raise ELogError.Create(Format(ERROR_EXISTS, ['TApplication']))
  else
    SaveLog(Format(EVENT_CREATE, ['TApplication']));
  Application := Self;

  FHandle := 0;
  FActive := True;

  FFPS.Time := 0;
  FFPS.Ticks := 0;
  FFPS.FPS := 0;
end;

destructor TApplication.Destroy;
begin
  TWindow.GetWindow^.Free;
end;

procedure TApplication.Initialize;
begin
  //Waiting...
end;

procedure TApplication.CreateForm(InstanceClass: TWindowReferer; var Reference);
begin
  try
    TWindow(Reference) := InstanceClass.Create;
    TWindow(Reference).Run;
    FHandle := TWindow(Reference).Handle;
  except
    on E: Exception do
      SaveLog(Format(EVENT_ERROR, [E.Message]));
  end;
end;

procedure TApplication.CreateGraphics(InstanceClass: TGraphicsReferer; var Reference);
begin
  try
    TGraphics(Reference) := InstanceClass.Create;
    TGraphics(Reference).Handle := FHandle;
    TGraphics(Reference).Run;
  except
    on E: Exception do
      SaveLog(Format(EVENT_ERROR, [E.Message]));
  end;
end;

function TApplication.Run: Integer;
var
  Done: Boolean;
  LastTime, CurrTime, Delta: Single;
begin
  SaveLog(Format(EVENT_TALK, ['TWindow.Create']));

  Done := False;
  LastTime := TimeGetTime;

  try
    DoInitialize;

    while not Done do
    begin
      while (not Done) and (TWindow.GetWindow^.HasMessages) do
        if not TWindow.GetWindow^.Pump then
          Done := True;

      CurrTime := TimeGetTime;
      Delta := (CurrTime - LastTime) / 1000.0;

      Inc(FFPs.Ticks);
      if (FFPs.Time + 1000) <= GetTickCount then
      begin
        FFPS.FPS := FFPS.Ticks;
        FFPS.Ticks := 0;
        FFPS.Time := GetTickCount;
      end;

    if FActive then
    begin
   //   if Assigned(TInput.GetInput^) then
   //     TInput.GetInput^.UpdateDevices;

      DoFrame(Delta);
    end
    else
      DoIdleFrame(Delta);

      LastTime := CurrTime;
    end;

  except
    on E: Exception do
    begin
      SaveLog(Format(EVENT_ERROR, [E.Message]));
      Application.Free;
      ExitCode := 0;
      Result := 0;
      Exit;
    end;
  end;

  Application.Free;

  ExitCode := 0;
  Result := 0;
end;

procedure TApplication.Pause;
begin
  FActive := False;
end;

procedure TApplication.UnPause;
begin
  FActive := True;
end;

procedure TApplication.Terminate;
begin
  PostQuitMessage(0);
end;

class function TApplication.GetApplication: PApplication;
begin
  Result := @Application;
end;

class procedure TApplication.KillApplication;
begin
  Application.Free;
end;

procedure TApplication.DoInitialize;
begin
  if Assigned(FOnInitialize) then FOnInitialize(Self);
end;

procedure TApplication.DoFinalize;
begin
  if Assigned(FOnFinalize) then FOnFinalize(Self);
end;

procedure TApplication.DoFrame;
begin
  if Assigned(FOnDoFrame) then FOnDoFrame(Self, TimeDelta);
end;

procedure TApplication.DoIdleFrame;
begin
  if Assigned(FOnDoIdleFrame) then FOnDoIdleFrame(Self, TimeDelta);
end;

function TApplication.GetExeName: string;
begin
  Result := ParamStr(0);
end;

initialization
  SaveLog(Format(EVENT_START,[Application.ExeName]));
  Application := TApplication.Create;

end.

