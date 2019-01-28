unit brMain;

interface

uses
  Windows, Messages, SysUtils, Classes, MMSystem,
  brForms, brGraphics, brSound, brInput, brSprite, brUtils, brControls,
  D3DX8, {$IFDEF DXG_COMPAT}DirectXGraphics{$ELSE}Direct3D8{$ENDIF};

type

  TWindow1 = class(TWindow)
    T : TButton;
  private
    { Private declarations }
  protected
    procedure DoInitialize; override;
    procedure DoCreate; override;
  public
    procedure DoFrame(Sender: TObject; TimeDelta: Single);
    procedure DoIdleFrame(Sender: TObject; TimeDelta: Single);
  end;

  TGraphics1 = class(TGraphics)
  private
    { Private declarations }
  protected
    { Protected declarations }
  public
    { Public declarations }
    procedure DoInitialize; override;
  end;

  Teste = class(TControl)
    procedure DoMouseEnter; override;
    procedure DoMouseLeave; override;
  end;

var
  Window1: TWindow1;
  Graphics1: TGraphics1;
  MouseX: longint = 0;
  MouseY: longint = 0;
  Mouse0: longint = 0; // # Clicks
  Mouse1: longint = 0; // # Clicks
  Mouse0Z: longint = 0; // # Dbl. Clicks
  Mouse1Z: longint = 0; // # Dbl. Clicks
  Mouse0T: longint = 0; // # Timeout Clicka
  MTI0: TTimedInput;
  MTI1: TTimedInput;

implementation

procedure TWindow1.DoFrame(Sender: TObject; TimeDelta: Single);
var
  _x, _y: longint;
  _0u, _0d, _0z, _1u, _1d, _1z: Longint;
var
  S: TD3DXVector2;
  uX, uY, uWidth, uHeight: Integer;
begin
  uWidth := 50;
  uHeight := 50;
  uX := 50;
  uY := 50;
  if Window1.Key[VK_F2] then
    Application.Pause;

  Graphics1.Clear;

  Graphics1.BeginScene;

  Canvas.SpriteBegin;

  Canvas.SpriteEnd;

  Canvas.TextOut(10, 10, IntToStr(Application.Fps));
  Canvas.TextOut(10, 30, 'Pressione Esc para sair.');

  T.DoDraw;
  Graphics1.EndScene;

  Graphics1.Flip;

 { if Input.MouseState(_x, _y, _0u, _0d, _0z, _1u, _1d, _1z) then
  begin
    inc(MouseX, _x);
    inc(MouseY, _y);
    Caption := Format('%d,%d', [mousex, mouseY]);
  end; }
end;

procedure TWindow1.DoIdleFrame(Sender: TObject; TimeDelta: Single);
begin
  if Window1.Key[VK_F3] then
    Application.UnPause;

  if Window1.Key[VK_ESCAPE] then
    Application.Terminate;

  Graphics1.Clear;

  Graphics1.BeginScene;

  Canvas.SpriteBegin;

  Canvas.SpriteEnd;

  Canvas.TextOut(10, 10, IntToStr(Application.Fps));
  Canvas.TextOut(10, 30, 'Pressione Esc para sair.');
  Canvas.TextOut(10, 50, 'Parado');

  Graphics1.EndScene;

  Graphics1.Flip;
end;

procedure Teste.DoMouseEnter;
begin
  Window1.Caption := 'Enter';
end;

procedure Teste.DoMouseLeave;
begin
  Window1.Caption := 'leave';
  //MessageBox(0, '0', '0', MB_OK);
end;

procedure TWindow1.DoInitialize;
begin
  Application.OnDoFrame := DoFrame;
  Application.OnDoIdleFrame := DoIdleFrame;
 { Input := TInput.Create(Handle, True, True, True);
  Input.Run;
  Input.InitializeMouse;
  Input.MouseAcquire(True);
  TimedInputReset(MTI0);
  TimedInputReset(MTI1);  }
end;

procedure TWindow1.DoCreate;
begin
  Caption := 'Window IskaTreK';
  Position := poCenter;
  T := TButton.Create;
  T.Left := 10;
  T.Top := 10;
  T.Width := 72;
  T.Height := 21;
end;

procedure TGraphics1.DoInitialize;
begin
  Canvas.Brush.Color := $FFAACC;
end;

end.

