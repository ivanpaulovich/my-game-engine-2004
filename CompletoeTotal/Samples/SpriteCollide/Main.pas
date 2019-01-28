unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, MMSystem,
  glApplication, glWindow, gl3DGraphics, glSound, glError, glSprite, glCanvas, glUtil, glConst,
  D3DX8, {$IFDEF DXG_COMPAT}DirectXGraphics{$ELSE}Direct3D8{$ENDIF};

type

  TWindow1 = class(TWindow)
  private
    { Private declarations }
  protected
    procedure DoInitialize; override;
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
    procedure CreateShoot(MyX, MyY: Single; MyAngle: Single);
    procedure CreateHit(MyX, MyY: Single; MyAngle: Single);
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
    FArmed: Boolean;
    FTime: Integer;
  protected
    procedure DoMove(MoveCount: Integer); override;
  public

  end;

  TEnemyPlane = class(TImageSprite)
  private
    FAcel: Single;
    FVelX: Single;
    FVelY: Single;
    FDamage: Integer;
    FTime: Integer;
    FArmed: Boolean;
  protected
    procedure DoMove(MoveCount: Integer); override;
  public

  end;

  TShoot = class(TImageSprite)
  private
    FAcel: Single;
    FVelX: Single;
    FVelY: Single;
    FTime: Integer;
  protected
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
    procedure DoMove(MoveCount: Integer); override;
  public

  end;

  THit = class(TImageSprite)
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

  if (Window1.Key[VK_UP]) and (FAcel <= 6.0) then
    FAcel := FAcel + 0.05;

  if (Window1.Key[VK_DOWN]) and (FAcel >= -1.0) then
    FAcel := FAcel - 0.1;

  if Window1.Key[VK_LEFT] then
    Angle := Angle + 2.0;

  if Window1.Key[VK_RIGHT] then
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

  if FArmed then
  begin
    if Window1.Key[VK_SPACE] then
    begin
      Sounds.Play('Tiro');
      FArmed := False;
      Graphics1.CreateShoot((X + 32) + 64 * Sin(D3DXToRadian(Angle)), (Y + 32) + 64 * Cos(D3DXToRadian(Angle)), Angle);
    end;
  end
  else
  begin
    Dec(FTime);
    if FTime < 0 then
    begin
      FTime := 5;
      FArmed := True;
    end;
  end;

  Engine.X := -X + ((Engine.Width - Width) div 2);
  Engine.Y := -Y + ((Engine.Height - Height) div 2);
end;

procedure TShoot.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  if Sprite.Visible then
    if Sprite is TPlayerPlane then
    begin
      Graphics1.CreateHit(X, Y, Angle);
      Sounds.Play('Explosão');
      Dead;
    end;

  if Sprite.Visible then
    if Sprite is TShoot then
    begin
      Graphics1.CreateHit(X, Y, Angle);
      Sounds.Play('Explosão');
      Sprite.Dead;
      Dead;
    end;

  if Sprite.Visible then
    if Sprite is TEnemyPlane then
    begin
      Graphics1.CreateHit(X, Y, Angle);
      Sounds.Play('Explosão');
      Dec(TEnemyPlane(Sprite).FDamage);
      if TEnemyPlane(Sprite).FDamage < 0 then
        Sprite.Dead;
      Dead;
    end;

  Done := False;
end;

procedure TShoot.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  FVelX := FAcel * Sin(D3DXToRadian(Angle));
  FVelY := FAcel * Cos(D3DXToRadian(Angle));

  X := X + FVelX;
  Y := Y + FVelY;

  Dec(FTime);

  if FTime < 0 then
    Dead;

  Collision;
end;

procedure THit.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  FVelX := FAcel * Sin(D3DXToRadian(Angle));
  FVelY := FAcel * Cos(D3DXToRadian(Angle));

  X := X + FVelX;
  Y := Y + FVelY;

  if AnimPos = AnimCount - 1 then
    Dead;
end;

procedure TEnemyPlane.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  FAcel := FAcel + 0.05;
  if FAcel >= 6.0 then
    FAcel := 0.0;

  Angle := Angle + 2.0;
  if Angle > 360 then
    Angle := 0;

  FVelX := FAcel * Sin(D3DXToRadian(Angle));
  FVelY := FAcel * Cos(D3DXToRadian(Angle));

  X := X + FVelX;
  Y := Y + FVelY;

  ShadowX := FAcel * 2;
  ShadowY := FAcel * 2;

  if FArmed then
  begin
    Sounds.Play('Tiro');
    FArmed := False;
    Graphics1.CreateShoot((X + 32) + 64 * Sin(D3DXToRadian(Angle)),
      (Y + 32) + 64 * Cos(D3DXToRadian(Angle)), Angle);
  end
  else
  begin
    Dec(FTime);
    if FTime < 0 then
    begin
      FTime := 5;
      FArmed := True;
    end;
  end;
end;

procedure TWindow1.DoFrame(Sender: TObject; TimeDelta: Single);
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
  Pictures.Add('Media\Plane2.bmp', 'Aviao2', 64, 64, clBlack);
  Pictures.Add('Media\Tile.bmp', 'Tile', 64, 64, clBlack);
  Pictures.Add('Media\BombaMini.bmp', 'Bomba', 32, 32, clBlack);
  Pictures.Add('Media\Tiro1.bmp', 'Tiro', 9, 9, clBlack);

  Sounds.Add('Media\Metranca.wav', 'Tiro');
  Sounds.Add('Media\Boom.wav', 'Explosão');

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
    Angle := 0.0;
    FAcel := 0.0;
    FVelX := 0.0;
    FVelY := 0.0;
    Center := D3DXVector2(Image.Width div 2, Image.Height div 2);
    Shadow := True;
    FArmed := True;
    FTime := 5;
  end;

  for I := 0 to 2 do
    with TEnemyPlane.Create(SpriteEngine) do
    begin
      Image := Pictures.Find('Aviao2');
      X := 500 * Random(3);
      Y := 500 * Random(3);
      Z := 3;
      Width := Image.Width;
      Height := Image.Height;
      AnimStart := 0;
      AnimCount := 3;
      AnimLooped := True;
      AnimSpeed := 15 / 1000;
      AnimPos := 0;
      Center := D3DXVector2(Image.Width div 2, Image.Height div 2);
      Shadow := True;
      FDamage := 3;
    end;
end;

procedure TGraphics1.CreateShoot(MyX, MyY: Single; MyAngle: Single);
begin
  with TShoot.Create(SpriteEngine) do
  begin
    Image := Pictures.Find('Tiro');
    X := MyX;
    Y := MyY;
    Z := 2;
    Angle := MyAngle;
    Width := 9;
    Height := 9;
    FTime := 100;
    FAcel := 8.0;
    AnimStart := 0;
    AnimCount := 6;
    AnimLooped := True;
    AnimSpeed := 15 / 1000;
    AnimPos := 0;
  end;
end;

procedure TGraphics1.CreateHit(MyX, MyY: Single; MyAngle: Single);
begin
  with THit.Create(SpriteEngine) do
  begin
    Image := Pictures.Find('Bomba');
    X := MyX;
    Y := MyY;
    Z := 4;
    Angle := MyAngle;
    Width := 9;
    Height := 9;
    FAcel := 0.0;
    AnimStart := 0;
    AnimCount := 6;
    AnimLooped := False;
    AnimSpeed := 15 / 1000;
    AnimPos := 0;
  end;
end;

end.

