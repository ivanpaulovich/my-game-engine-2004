(*******************************************************)
(*                                                     *)
(*       Engine Paulovich DirectX                      *)
(*       Win32-DirectX API Unit                        *)
(*                                                     *)
(*       Copyright (c) 2003-2004, Ivan Paulovich       *)
(*                                                     *)
(*       iskatrek@hotmail.com  uin#89160524            *)
(*                                                     *)
(*       Unit: brForms                                 *)
(*                                                     *)
(*******************************************************)

unit brForms;

interface

uses
  Windows, Messages, Classes, SysUtils, MMSystem, CommDlg, brControls, brGraphics, brInput;

const

  (* Arquivos *)

  FILE_LOG = 'log.log';
  FILE_MAP = 'map.map';

  (* Filtros *)

  FILTER_MAP = 'Mapas (*.map)'#0'*.map'#0'Todos os arquivos (*.*)'#0'*.*'#0#0;

  (* Mensagens *)

  EVENT_START =
    '-----------------------------------------------------------------' + #13#10 +
    '------------ Powered by IskaTreK - Copyright(c) 2004 ------------';
  EVENT_TALK = 'Chamando fun��o: %s';
  EVENT_CREATE = 'Objeto da classe %s criado.';
  EVENT_APPLICATION = '[Aplica��o] :: Arquivo: %s';
  EVENT_WINDOW = '[Janela] :: Posi��o: %dx%d. Resolu��o: %dx%d. T�tulo: %s';
  EVENT_FOUND = 'Arquivo encontrado: %s';
  EVENT_ERROR = 'Ocorreu um erro dentro de: %s';

  (* Erros *)

  ERROR_EXISTS = 'Objeto %s j� existente.';
  ERROR_REGISTRY = 'Imposs�vel registrar janela.';
  ERROR_INSTANCE = 'Imposs�vel instanciar janela.';
  ERROR_NOTFOUND = 'Imposs�vel encontrar o arquivo: %s';
  ERROR_MUSICLOADER = 'Imposs�vel carregar m�sica.';
  ERROR_MUSICPERFORMANCE = 'Erro na performance.';
  ERROR_INITAUDIO = 'Imposs�vel inicializar audio.';
  ERROR_PATH = 'Imposs�vel pegar Path do audio.';
  ERROR_VOLUME = 'Imposs�vel definir volume';
  ERROR_LOAD = 'Imposs�vel carregar audio';
  ERROR_DOWNLOAD = 'Imposs�vel baixar audio';
  ERROR_NOSEGMENT = 'N�o existe o segmento de audio';
  ERROR_PLAYFAIL = 'Falha ao iniciar audio.';
  ERROR_CREATEDEVICE = 'Falha ao criar device %s.';
  ERROR_SETDATAFORMAT = 'Imposs�vel definir formato %s';
  ERROR_SETCOOPERATIVELEVEL = 'Imposs�vel definir n�vel cooperativo %%s';

  (* Cores *)

  clRed = $FFFF0000;
  clGreen = $FF00FF00;
  clBlue = $FF0000FF;
  clWhite = $FFFFFFFF;
  clBlack = $FF000000;
  clAqua = $FF00FFFF;
  clFuchsia = $FFFF00FF;
  clYellow = $FFFFFF00;
  clMaroon = $000080;
  clOlive = $008080;
  clNavy = $800000;
  clPurple = $800080;
  clTeal = $808000;
  clGray = $808080;
  clSilver = $C0C0C0;
  clLime = $00FF00;
  clLtGray = $C0C0C0;
  clDkGray = $808080;

const
  {$EXTERNALSYM OPENFILENAME_SIZE_VERSION_400A}
  OPENFILENAME_SIZE_VERSION_400A = SizeOf(TOpenFileNameA) -
    SizeOf(Pointer) - (2 * SizeOf(DWord));
  {$EXTERNALSYM OPENFILENAME_SIZE_VERSION_400W}
  OPENFILENAME_SIZE_VERSION_400W = SizeOf(TOpenFileNameW) -
    Sizeof(Pointer) - (2 * SizeOf(DWord));
  {$EXTERNALSYM OPENFILENAME_SIZE_VERSION_400}
  OPENFILENAME_SIZE_VERSION_400  = OPENFILENAME_SIZE_VERSION_400A;

type

  (* Eventos *)

  TDoFrameEvent = procedure(Sender: TObject; TimeDelta: Single) of object;
  TExceptionEvent = procedure (Sender: TObject; E: Exception) of object;

  (* Op��es *)

  TBorderIcon = (biSystemMenu, biMinimize, biMaximize, biHelp);
  TBorderIcons = set of TBorderIcon;
  TFormBorderStyle = (bsNone, bsSingle, bsSizeable, bsDialog, bsToolWindow,
    bsSizeToolWin);
  TPosition = (poLeft, poRight, poTop, poDown, poCenter);

  (* Refer�ncias *)

  TRefWindow = class of TWindow;

 (* TWindow *)

  PWindow = ^TWindow;
  TWindow = class(TControl)
  private
    FHandle: HWnd;
    FCaption: string;
    FActive: Boolean;
    FBorderIcons: TBorderIcons;
    FBorderStyle: TFormBorderStyle;
    FKeys: array[0..255] of Byte;
    FMenuName: Integer;
    FFullScreen: Boolean;
    FPosition: TPosition;
    FOnCommand: TCommandEvent;
    FOnPaint: TNotifyEvent;
    function GetKey(Index: Integer): Boolean;
    function GetCaption: string;
    procedure SetCaption(Value: string);
  protected
    procedure SetWidth(Value: Integer); override;
    procedure SetHeight(Value: Integer); override;
    procedure SetLeft(Value: Integer); override;
    procedure SetTop(Value: Integer); override;
  public
    constructor Create; override;
    destructor Destroy;
    function WndProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; virtual;
    function Run: Integer;
    function HasMessages: Boolean;
    function Pump: Boolean;
    procedure DoResize;
    procedure DoPaint; virtual;
    procedure DoCommand(ID: Integer); virtual;
    class function GetWindow: PWindow;
    property Handle: HWnd read FHandle;
    property FullScreen: Boolean read FFullScreen write FFullScreen;
    property IsActive: Boolean read FActive;
    property BorderIcons: TBorderIcons read FBorderIcons write FBorderIcons;
    property BorderStyle: TFormBorderStyle read FBorderStyle write FBorderStyle;
    property Position: TPosition read FPosition write FPosition;
    property Caption: string read GetCaption write SetCaption;
    property MenuName: Integer read FMenuName write FMenuName;
    property Key[Index: Integer]: Boolean read GetKey;
    property OnCommand: TCommandEvent read FOnCommand write FOnCommand;
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
  end;

 (* EError *)

  EError = class(Exception);

 (* ELogError *)

  PLogError = ^ELogError;
  ELogError = class(EError)
  public
    constructor Create(const Text: string);
  end;

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
    FExeName: string;
    FOnInitialize: TNotifyEvent;
    FOnFinalize: TNotifyEvent;
    FOnDoFrame: TDoFrameEvent;
    FOnDoIdleFrame: TDoFrameEvent;
    FOnException: TExceptionEvent;
    function GetExeName: string;
  protected
    procedure DoInitialize; virtual;
    procedure DoFinalize; virtual;
    procedure DoFrame(TimeDelta: Single); virtual;
    procedure DoIdleFrame(TimeDelta: Single); virtual;
    procedure DoException(E: Exception); virtual;
  public
    constructor Create;
    destructor Destroy;
    procedure Initialize;
    procedure CreateForm(InstanceClass: TRefWindow; var Reference);
    procedure CreateGraphics(InstanceClass: TRefGraphics; var Reference);
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
    property OnException: TExceptionEvent read FOnException write FOnException;
  end;

var
  Window: TWindow;
  Application: TApplication = nil;
  PictureList: TPictures = nil;

function SaveLog(const FileName, Text: string): string; overload;
function SaveLog(const Text: string): string; overload;
function IsNT5OrHigher: Boolean;
function OpenFile(Handle: HWnd): string;
function SaveFile(Handle: HWnd): string;
function MsgBox(Handle: HWnd; const Text, Caption: string; Flags: Longint = MB_OK): Integer;

implementation

var
  LogError: PLogError = nil;

function GlobalWndProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall;
begin
  Result := Window.WndProc(hWnd, uMsg, wParam, lParam);
end;

constructor TWindow.Create;
var
  I: Integer;
begin
  inherited Create;

  if Assigned(Window) then
    raise ELogError.Create(Format(ERROR_EXISTS, ['TWindow']))
  else
    SaveLog(Format(EVENT_CREATE, ['TWindow']));

  Window := Self;
  FHandle := 0;
  FActive := False;
  Left := 0;
  Top := 0;
  Width := 640;
  Height := 480;
  ClientRect := Bounds(Left, Top, Width, Height);
  FBorderIcons := [biSystemMenu, biMinimize];
  FBorderStyle := bsSingle;
  ZeroMemory(@FKeys, 256);
  FMenuName := 0;
  FFullScreen := False;
  FCaption := 'Window';

  for I := 0 to ControlList.Count - 1 do
    TControl(ControlList[I]).DoCreate;
end;

destructor TWindow.Destroy;
var
  I: Integer;
begin
  for I := 0 to ControlList.Count - 1 do
    TControl(ControlList[I]).DoFinalize;
  DestroyWindow(Handle);
  Window := nil;
end;

function TWindow.WndProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
var
  MouseMessage: TWMMouse;
  KeyboardMessage: TWMKey;
  I: Integer;

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
  if Assigned(LogError) then
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
          DoPaint;
        end;

      WM_MOVE:
        begin
          ClientRect.Left := LOWORD(lParam);
          ClientRect.Top := HIWORD(lParam);
        end;

      WM_SIZE:
        begin
          DoResize;
        end;

      WM_KEYDOWN:
        begin
          FKeys[wParam] := 1;
          UpdateKeyboard;
          for I := 0 to ControlList.Count - 1 do
            TControl(ControlList[I]).KeyDown(KeyboardMessage);
        end;

      WM_CHAR:
        begin
          FKeys[wParam] := 1;
          UpdateKeyboard;
          for I := 0 to ControlList.Count - 1 do
            TControl(ControlList[I]).KeyPress(KeyboardMessage);
        end;

      WM_KEYUP:
        begin
          FKeys[wParam] := 0;
          UpdateKeyboard;
          for I := 0 to ControlList.Count - 1 do
            TControl(ControlList[I]).KeyUp(KeyboardMessage);
        end;

      WM_LBUTTONDOWN:
        begin
          DoClick;
          UpdateMouse;
          for I := 0 to ControlList.Count - 1 do
            TControl(ControlList[I]).MouseDown(MouseMessage, mbLeft, []);
        end;

      WM_LBUTTONDBLCLK:
        begin
          for I := 0 to ControlList.Count - 1 do
            TControl(ControlList[I]).DoDblClick;
        end;

      WM_LBUTTONUP:
        begin
          UpdateMouse;
          for I := 0 to ControlList.Count - 1 do
            TControl(ControlList[I]).MouseUp(MouseMessage, mbLeft);
        end;

      WM_RBUTTONDOWN:
        begin
          UpdateMouse;
          for I := 0 to ControlList.Count - 1 do
            TControl(ControlList[I]).MouseDown(MouseMessage, mbRight, []);
        end;

      WM_RBUTTONUP:
        begin
          UpdateMouse;
          for I := 0 to ControlList.Count - 1 do
            TControl(ControlList[I]).MouseUp(MouseMessage, mbRight);
        end;

      WM_MOUSEMOVE:
        begin
          UpdateMouse;
          for I := 0 to ControlList.Count - 1 do
            TControl(ControlList[I]).MouseMove(MouseMessage);
        end;

      WM_COMMAND:
        begin
          DoCommand(LOWORD(wParam));
        end;

      WM_DESTROY, WM_CLOSE:
        begin
          PostQuitMessage(0);
        end;

      WM_SETFOCUS:
        begin
          if Assigned(Input) then
          begin
            Input.MouseAcquire(True);
            Input.KeyboardAcquire(True);
          end;

          Application.Active := True;
          ShowCursor(False);
        end;

      WM_KILLFOCUS:
        begin
          if Assigned(Input) then
          begin
            Input.MouseAcquire(False);
            Input.KeyboardAcquire(False);
          end;

          Application.Active := False;
          ShowCursor(True);
        end;

    else
      begin
        Result := DefWindowProc(hWnd, uMsg, wParam, lParam);
        Exit;
      end;
    end;

  except
    New(LogError);
    Result := 0;
    Exit;
  end;

  Result := 0;
end;

function TWindow.Run: Integer;
var
  Wc: TWndClass;
  Style: Integer;
  I: Integer;
begin
  Result := E_FAIL;

  SaveLog(Format(EVENT_TALK, ['TWindow.Run']));

  Style := 0;

  if FullScreen then
    Style := Style or WS_POPUP;

  if biSystemMenu in FBorderIcons then
    Style := Style or WS_SYSMENU;

  if biMinimize in FBorderIcons then
    Style := Style or WS_MINIMIZEBOX;

  if biMaximize in FBorderIcons then
    Style := Style or WS_MAXIMIZEBOX;

  if biHelp in FBorderIcons then
    Style := Style or WS_EX_CONTEXTHELP;

  case FBorderStyle of
    bsNone:
      begin
        Style := Style or WS_POPUP;
        BorderIcons := [];
      end;
    bsSingle, bsToolWindow:
      Style := Style or (WS_CAPTION or WS_BORDER);
    bsSizeable, bsSizeToolWin:
      begin
        Style := Style or (WS_CAPTION or WS_THICKFRAME);
      end;
    bsDialog:
      begin
        Style := Style or WS_POPUP or WS_CAPTION;
      end;
  end;

  case FPosition of
    poLeft: ClientRect.Left := 0;
    poTop: ClientRect.Top := 0;
    poRight: ClientRect.Left := GetSystemMetrics(SM_CXSCREEN) - ClientRect.Right;
    poDown: ClientRect.Top := GetSystemMetrics(SM_CYSCREEN) - ClientRect.Bottom;
    poCenter:
      begin
        ClientRect.Left := (GetSystemMetrics(SM_CXSCREEN) - ClientRect.Right) div 2;
        ClientRect.Top := (GetSystemMetrics(SM_CYSCREEN) - ClientRect.Bottom) div 2;
      end;
  end;

  FillChar(Wc, SizeOf(TWndClass), 0);
  Wc.lpszClassName := PChar(FCaption);
  Wc.lpfnWndProc := @GlobalWndProc;
  Wc.style := CS_VREDRAW or CS_HREDRAW;
  Wc.hInstance := HInstance;
  Wc.hIcon := LoadIcon(0, IDI_WINLOGO);
  Wc.hCursor := LoadCursor(0, IDC_ARROW);
  Wc.hbrBackground := GetStockObject(BLACK_BRUSH);
  if FMenuName <> 0 then
    Wc.lpszMenuName := MakeIntResource(FMenuName)
  else
    Wc.lpszMenuName := nil;
  Wc.cbClsExtra := 0;
  Wc.cbWndExtra := 0;

  if Windows.RegisterClass(Wc) = 0 then
    raise ELogError.Create(ERROR_REGISTRY);

  AdjustWindowRect(ClientRect, Style, False);

  FHandle := CreateWindow(PChar(FCaption), PChar(FCaption), Style or WS_VISIBLE, ClientRect.Left,
    ClientRect.Top, ClientRect.Right, ClientRect.Bottom, 0, 0, HInstance, nil);
  if FHandle = 0 then
    raise ELogError.Create(ERROR_INSTANCE)
  else
    Result := S_OK;

  SaveLog(Format(EVENT_WINDOW, [ClientRect.Left, ClientRect.Top, ClientRect.Right, ClientRect.Bottom, FCaption]));

  for I := 0 to ControlList.Count - 1 do
    TControl(ControlList[I]).DoInitialize;

  if not FullScreen then
    ShowWindow(Handle, SW_SHOW);

  UpdateWindow(Handle);
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

  if Assigned(LogError) then
  begin
    ErrorOut := LogError^;
    Dispose(LogError);
    raise ELogError.Create(Format(EVENT_ERROR, ['TWindow.Pump']));
  end;

  Result := True;
end;

procedure TWindow.DoResize;
begin
  GetWindowRect(Handle, ClientRect);
end;

procedure TWindow.SetWidth(Value: Integer);
begin
  inherited SetWidth(Value);
  MoveWindow(Handle, ClientRect.Left, ClientRect.Top,
    ClientRect.Right, ClientRect.Bottom, True);
end;

procedure TWindow.SetHeight(Value: Integer);
begin
  inherited SetHeight(Value);
  MoveWindow(Handle, ClientRect.Left, ClientRect.Top,
    ClientRect.Right, ClientRect.Bottom, True);
end;

procedure TWindow.SetLeft(Value: Integer);
begin
  inherited SetLeft(Value);
  MoveWindow(Handle, ClientRect.Left, ClientRect.Top,
    ClientRect.Right, ClientRect.Bottom, True);
end;

procedure TWindow.SetTop(Value: Integer);
begin
  inherited SetTop(Value);
  MoveWindow(Handle, ClientRect.Left, ClientRect.Top,
    ClientRect.Right, ClientRect.Bottom, True);
end;

function TWindow.GetKey(Index: Integer): Boolean;
begin
  Result := FKeys[Index] <> 0;
end;

function TWindow.GetCaption: string;
begin
  GetWindowText(Handle, PChar(FCaption), 255);
  Result := FCaption;
end;

procedure TWindow.SetCaption(Value: string);
begin
  if FCaption <> Value then
  begin
    FCaption := Value;
    SetWindowText(Handle, PChar(FCaption));
  end;
end;

procedure TWindow.DoCommand(ID: Integer);
begin
  if Assigned(FOnCommand) then FOnCommand(Self, ID);
end;

procedure TWindow.DoPaint;
begin
  if Assigned(FOnPaint) then FOnPaint(Self);
end;

class function TWindow.GetWindow: PWindow;
begin
  Result := @Window;
end;

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
    Writeln(FileLog, Text);
  finally
    CloseFile(FileLog);
  end;

  Result := Text;
end;

function SaveLog(const Text: string): string;
begin
  Result := SaveLog(FILE_LOG, DateTimeToStr(Now) + ': ' + Text);
end;

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
  Ofn.lpstrFilter := FILTER_MAP;
  Ofn.nMaxFile := SizeOf(Buffer);
  Ofn.Flags := OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or OFN_LONGNAMES or
    OFN_EXPLORER or OFN_HIDEREADONLY;

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
  Ofn.lpstrFilter := FILTER_MAP;
  Ofn.nMaxFile := SizeOf(Buffer);
  Ofn.Flags := OFN_FILEMUSTEXIST or OFN_PATHMUSTEXIST or OFN_LONGNAMES or
    OFN_EXPLORER or OFN_HIDEREADONLY;

  if GetSaveFileName(Ofn) then
    Result := Ofn.lpstrFile;
end;

function MsgBox(Handle: HWnd; const Text, Caption: string; Flags: Longint = MB_OK): Integer;
begin
  Result := Windows.MessageBox(Handle, PChar(Text), PChar(Caption), Flags);
end;

 (* ELogError *)

constructor ELogError.Create(const Text: string);
begin
  Message := SaveLog(Text);
end;

  (* TApplication *)

constructor TApplication.Create;
begin
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
  FExeName := ParamStr(0);
end;

procedure TApplication.CreateForm(InstanceClass: TRefWindow; var Reference);
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

procedure TApplication.CreateGraphics(InstanceClass: TRefGraphics; var Reference);
begin
  try
    TGraphics(Reference) := InstanceClass.Create;
    TGraphics(Reference).Run;
    PictureList := TPictures.Create(TPicture);
    with PictureList.Add do
    begin
      Name := 'Colors';
      PatternWidth := 1;
      PatternHeight := 1;
      SkipWidth := 0;
      SkipHeight := 0;
      TransparentColor := 0;
      FileName := 'Colors.bmp';
    end;
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
  SaveLog(Format(EVENT_TALK, ['TApplication.Run']));

  Done := False;
  LastTime := TimeGetTime;

  try
    DoInitialize;

    SaveLog(Format(EVENT_APPLICATION, [ExtractFileName(ExeName)]));

    while not Done do
    begin
      while (not Done) and (Window.HasMessages) do
        if not Window.Pump then
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
        DoFrame(Delta)
      else
        DoIdleFrame(Delta);

      LastTime := CurrTime;
    end;

  except
    on E: Exception do
    begin
      DoException(E);
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

function TApplication.GetExeName: string;
begin
  Result := FExeName;
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

procedure TApplication.DoException;
begin
  if Assigned(FOnException) then FOnException(Self, E);
end;

initialization
  SaveLog(FILE_LOG, EVENT_START);
  Application := TApplication.Create;

end.

