unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, MMSystem,
  glApplication, glWindow, gl3DGraphics, glSound, glError, glSprite, glCanvas, glUtil, glConst,
  D3DX8, {$IFDEF DXG_COMPAT}DirectXGraphics{$ELSE}Direct3D8{$ENDIF};

type

  TWindow1 = class(TWindow)
  private
    Time: Integer;
  protected
    procedure DoInitialize; override;
    procedure DoCreate; override;
  public
    procedure DoFrame(Sender: TObject; TimeDelta: Single);
    procedure DoIdleFrame(Sender: TObject; TimeDelta: Single);
  end;

  TGraphics1 = class(TGraphics)
    SpriteEngine: TSpriteEngine;
    Pictures: TPictureCollection;
  private
    { Private declarations }
  protected
    procedure DoInitialize; override;
  public
    procedure CreateEnemyPlane(MyX, MyY: Single);
    procedure CreateShoot(MyX, MyY: Single);
    procedure CreateHit(MyX, MyY: Single);
    procedure CreateBoom(MyX, MyY: Single);
  end;

var
  Window1: TWindow1;
  Graphics1: TGraphics1;

implementation

type

  TPlayerPlane = class(TImageSprite)
  private
    Inclination: Single;
    Armed: Boolean;
    Time: Integer;
    Count: Integer;
  protected
    procedure DoMove(MoveCount: Integer); override;
  end;

  TEnemyPlane = class(TImageSprite)
  private
    Damage: Integer;
  protected
    procedure DoMove(MoveCount: Integer); override;
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
  end;

  TBackground = class(TBackgroundSprite)
  protected
    procedure DoMove(MoveCount: Integer); override;
  end;

  TShoot = class(TImageSprite)
  private
    Time: Integer;
  protected
    procedure DoMove(MoveCount: Integer); override;
  end;

  THit = class(TImageSprite)
  private
    Time: Integer;
  protected
    procedure DoMove(MoveCount: Integer); override;
  end;

var
  Player: TPlayerPlane;

procedure TPlayerPlane.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  if Armed then
  begin
    if Window1.Key[VK_SPACE] then
    begin
      Armed := False;
      Graphics1.CreateShoot(X, Y);
      Sounds.Play('Tiro');
    end;
  end
  else
  begin
    Dec(Time);
    if Time < 0 then
    begin
      Time := 5;
      Armed := True;
    end;
  end;

  if Window1.Key[VK_UP] then
  begin
    Y := Y - (MoveCount * 0.4);
    if Inclination > -80 then
      Inclination := Inclination - (MoveCount * 0.25);
  end;

  if Window1.Key[VK_DOWN] then
  begin
    Y := Y + (MoveCount * 0.4);
    if Inclination < 80 then
      Inclination := Inclination + (MoveCount * 0.25);
  end;

  if Window1.Key[VK_LEFT] then
    X := X - (MoveCount * 0.3);

  if Window1.Key[VK_RIGHT] then
    X := X + (MoveCount * 0.4);

  if (not Window1.Key[VK_UP] and not Window1.Key[VK_DOWN]) or
    (Window1.Key[VK_UP] and Window1.Key[VK_DOWN]) then
  begin
    if Inclination < 0 then
      Inclination := Inclination + (MoveCount * 0.25)
    else if Inclination > 0 then
      Inclination := Inclination - (MoveCount * 0.25);
  end;

  if Inclination < -75 then AnimPos := 0
  else if Inclination < -45 then AnimPos := 1
  else if Inclination < -15 then AnimPos := 2
  else if Inclination < 15 then AnimPos := 3
  else if Inclination < 45 then AnimPos := 4
  else if Inclination < 75 then AnimPos := 5
  else AnimPos := 6;
end;

procedure TEnemyPlane.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  X := X - Trunc(MoveCount * 0.6);
  if X < -80 then
  begin
    X := X + 1000;
    Y := Random(5) * 80;
  end;

  Collision;
end;

procedure TEnemyPlane.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  if Sprite is TShoot then
  begin
    Graphics1.CreateHit(Sprite.X, Sprite.Y);
    Sprite.Dead;
    Sounds.Play('Boom');
    Dec(Damage);
    if Damage < 0 then
    begin
      Graphics1.CreateBoom(Sprite.X, Sprite.Y);
      Inc(Player.Count);
      Dead;
    end;
  end;

  if Sprite is TPlayerPlane then
  begin
    Sounds.Play('Boom');
    Graphics1.CreateBoom(X, Y);
    Dead;
  end;

  Done := False;
end;

procedure TBackground.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  X := X - (MoveCount * 0.25);
end;


procedure TShoot.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  Dec(Time);

  if Time < 0 then
    Dead;

  X := X + (MoveCount * 0.9);
end;

procedure THit.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  X := X - Trunc(MoveCount * 0.5);

  Dec(Time);

  if Time < 0 then
    Dead;
end;

procedure TWindow1.DoFrame(Sender: TObject; TimeDelta: Single);
var
  I: Integer;
begin
  if Window1.Key[VK_F2] then
    Application.Pause;

  if Window1.Key[VK_ESCAPE] then
    Application.Terminate;

  Dec(Time);

  if Time < 0 then
  begin
    Graphics1.CreateEnemyPlane(Player.X, Player.Y);
    Time := 30;
  end;

  Graphics1.Clear;

  Graphics1.SpriteEngine.Move(1000 div 60);
  Graphics1.SpriteEngine.Dead;

  Graphics1.BeginScene;

  Graphics1.SpriteEngine.Draw;

  Canvas.SpriteBegin;

  Canvas.SpriteEnd;

  Canvas.TextOut(10, 10, IntToStr(Application.Fps));
  Canvas.TextOut(10, 30, Format('%d inimigos derrubados', [Player.Count]));
  Canvas.TextOut(10, 50, 'Pressione Esc para sair');

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
  Canvas.TextOut(10, 30, IntToStr(Player.Count));
  Canvas.TextOut(10, 50, 'Pressione Esc para sair');
  Canvas.TextOut(10, 80, 'Parado');

  Graphics1.EndScene;

  Graphics1.Flip;
end;

procedure TWindow1.DoInitialize;
begin
  Application.OnDoFrame := DoFrame;
  Application.OnDoIdleFrame := DoIdleFrame;
end;

procedure TWindow1.DoCreate;
begin
  Caption := 'Shoot IskaTreK';
  Time := 30;
end;

procedure TGraphics1.DoInitialize;
var
  I: Integer;
begin
  SpriteEngine := TSpriteEngine.Create(nil);
  SpriteEngine.SurfaceRect := Rect(0, 0, Window1.Width, Window1.Height);

  Pictures := TPictureCollection.Create;
  Pictures.Add('Media\Deserto.bmp', 'Deserto', 0, 0, clFuchsia);
  Pictures.Add('Media\F22.bmp', 'F22', 69, 65, clBlack);
  Pictures.Add('Media\Bala.bmp', 'Tiro', 8, 4, clBlack);
  Pictures.Add('Media\Explos�o.bmp', 'Explos�o', 16, 16, clBlack);
  Pictures.Add('Media\Explos�o2.bmp', 'Explos�o2', 63, 62, clBlack);

  Sounds.Add('Media\Metranca.wav', 'Tiro');
  Sounds.Add('Media\Boom.wav', 'Boom');

  with TBackground.Create(SpriteEngine) do
  begin
    Image := Pictures.Find('Deserto');
    SetMapSize(1, 1);
    Z := -1;
    Width := Image.Width;
    Height := Image.Height;
    Tile := True;
  end;

  Player := TPlayerPlane.Create(SpriteEngine);
  with Player do
  begin
    Image := Pictures.Find('F22');
    X := 0.0;
    Y := 0.0;
    Z := 3;
    Width := Image.Width;
    Height := Image.Height;
    Armed := True;
    Time := 5;
    Shadow := True;
    Count := 0;
  end;

end;

procedure TGraphics1.CreateEnemyPlane;
begin
  if Random(5) = 0 then
    with TEnemyPlane.Create(SpriteEngine) do
    begin
      Image := Pictures.Find('F22');
      AnimStart := 0;
      AnimCount := 7;
      AnimLooped := True;
      AnimSpeed := 15 / 1000;
      AnimPos := Random(7);
      Z := 3;
      Width := Image.Width;
      Height := Image.Height;
      Angle := 180.0;
      Center := D3DXVector2(Image.Width div 2, Image.Height div 2);
      X := myX + Window.Width + Random(50) * 100;
      Y := myY + Random(5) * 80;
      Shadow := True;
      Damage := 3;
    end;
end;

procedure TGraphics1.CreateShoot;
begin
  with TShoot.Create(SpriteEngine) do
  begin
    Image := Pictures.Find('Tiro');
    X := MyX + 20;
    Y := MyY + 18 + (Random(2) * 26);
    Z := 0;
    Width := 8;
    Height := 4;
    Time := 30;
  end;
end;

procedure TGraphics1.CreateHit;
begin
  with THit.Create(SpriteEngine) do
  begin
    Image := Pictures.Find('Explos�o');
    AnimStart := 0;
    AnimCount := 14;
    AnimLooped := True;
    AnimSpeed := 15 / 100;
    AnimPos := 0;
    X := MyX;
    Y := MyY;
    Z := 0;
    Width := Image.Width;
    Height := Image.Height;
    Time := 5;
  end;
end;

procedure TGraphics1.CreateBoom;
begin
  with THit.Create(SpriteEngine) do
  begin
    Image := Pictures.Find('Explos�o2');
    AnimStart := 0;
    AnimCount := 15;
    AnimLooped := True;
    AnimSpeed := 15 / 100;
    AnimPos := 0;
    X := MyX;
    Y := MyY;
    Z := 3;
    Width := 63;
    Height := 62;
    Time := 5;
  end;
end;

end.

