unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, MMSystem,
  glApplication, glWindow, gl3DGraphics, glSound, glError, glSprite, glCanvas, glUtil, glConst,
  D3DX8, {$IFDEF DXG_COMPAT}DirectXGraphics{$ELSE}Direct3D8{$ENDIF};

type

  TWindow1 = class(TWindow)
  private
    procedure DoInitialize; override;
  public
    procedure DoFrame(Sender: TObject; TimeDelta: Single);
    procedure DoIdleFrame(Sender: TObject; TimeDelta: Single);
  end;

  TGraphics1 = class(TGraphics)
    SpriteEngine: TSpriteEngine;
    Pictures: TPictureCollection;
  private
    procedure DoInitialize; override;
  public
    { Public declarations }
  end;

var
  Window1: TWindow1;
  Graphics1: TGraphics1;

implementation

type

  TPlayerPlane = class(TImageSprite)
  private
    FAcel: Single;
    FVelX: Single;
    FVelY: Single;
  protected
    procedure DoMove(MoveCount: Integer); override;
  public

  end;

procedure TPlayerPlane.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  if (Window.Key[VK_UP]) and (FAcel <= 6.0) then
    FAcel := FAcel + 0.05;

  if (Window.Key[VK_DOWN]) and (FAcel >= -1.0) then
    FAcel := FAcel - 0.1;

  if Window.Key[VK_LEFT] then
    Angle := Angle + 2.0;

  if Window.Key[VK_RIGHT] then
    Angle := Angle - 2.0;

  if Angle < 0 then
    Angle := 360;

  if Angle > 360 then
    Angle := 0;

  FVelX := FAcel * Sin(D3DXToRadian(Angle));
  FVelY := FAcel * Cos(D3DXToRadian(Angle));

  X := X + FVelX;
  Y := Y + FVelY;

  ShadowX := FAcel * 2;
  ShadowY := FAcel * 2;

  Engine.X := -X + ((Engine.Width - Width) div 2);
  Engine.Y := -Y + ((Engine.Height - Height) div 2);
end;

procedure TWindow1.DoFrame(Sender: TObject; TimeDelta: Single);
var
  I: Integer;
begin
  if Window1.Key[VK_F2] then
    Application.Pause;

  if Window1.Key[VK_ESCAPE] then
    Application.Terminate;

  Graphics1.Clear;

  Graphics1.SpriteEngine.Move(1000 div 60);
  Graphics1.SpriteEngine.Dead;

  Graphics1.BeginScene;

  Canvas.SpriteBegin;

  Graphics1.SpriteEngine.Draw;

  Canvas.SpriteEnd;

  Canvas.TextOut(10, 10, IntToStr(Application.Fps));
  Canvas.TextOut(10, 30, 'Pressione Esc para sair.');

  Graphics1.EndScene;

  Graphics1.Flip;
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

procedure TWindow1.DoInitialize;
begin
  Application.OnDoFrame := DoFrame;
  Application.OnDoIdleFrame := DoIdleFrame;
end;

procedure TGraphics1.DoInitialize;
var
  I, J: Integer;
begin
  SpriteEngine := TSpriteEngine.Create(nil);
  SpriteEngine.SurfaceRect := Rect(0, 0, Window1.Width, Window1.Height);

  Pictures := TPictureCollection.Create;
  Pictures.Add('Media\Plane.bmp', 'Aviao', 64, 64, clBlack);
  Pictures.Add('Media\Tile.bmp', 'Tile', 64, 64, clBlack);

  with TBackgroundSprite.Create(SpriteEngine) do
  begin
    Image := Pictures.Find('Tile');
    SetMapSize(9, 7);
    Z := -1;
    Width := Image.Width;
    Height := Image.Height;
    Tile := True;
    for i := 0 to MapHeight - 1 do
      for j := 0 to MapWidth - 1 do
      begin
        if Random(5) = 3 then
          Chips[j, i] := Random(3)
        else
          Chips[j, i] := 3;
        CollisionMap[j, i] := False;
      end;
  end;

  with TPlayerPlane.Create(SpriteEngine) do
  begin
    Image := Pictures.Find('Aviao');
    X := 0;
    Y := 0;
    Z := 3;
    Width := Image.Width;
    Height := Image.Height;
    AnimStart := 0;
    AnimCount := 3;
    AnimLooped := True;
    AnimSpeed := 15 / 1000;
    AnimPos := 0;
    Angle := 0;
    FAcel := 0.0;
    FVelX := Window.Width div 2;
    FVelY := Window.Height div 2;
    Center := D3DXVector2(32, 32);
    Shadow := True;
  end;
end;

end.
 