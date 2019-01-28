unit Main;

interface

uses
  Windows, SysUtils, Classes, MMSystem, D3DX8, {$IFDEF DXG_COMPAT}DirectXGraphics{$ELSE}Direct3D8{$ENDIF},
  glApplication, glWindow, gl3DGraphics, glSound, glError, glSprite, glCanvas, glUtil, glConst;

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
  public
    procedure DoMove(MoveCount: Integer); override;
  end;

  TEnemyPlane = class(TImageSprite)
  private
    FAcel: Single;
    FVelX: Single;
    FVelY: Single;
    FDamage: Integer;
    FTime: Integer;
    FArmed: Boolean;
    procedure Hit;
  protected
   // procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
    procedure DoMove(MoveCount: Integer); override;
  public

  end;

  TEnemyBoat = class(TImageSprite)
  private
    FArmed: Boolean;
    FTime: Integer;
    FAngleGun: Single;
    FTimeWater: Integer;
    FTimeSob: Integer;
    FDamage: Integer;
    procedure Hit;
  protected
    //procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
    procedure DoMove(MoveCount: Integer); override;
  public

  end;

  TWindow2D = class(TWindow)
  private

  protected
    procedure DoInitialize; override;
  public
    procedure DoFrame(Sender: TObject; TimeDelta: Single);
    procedure DoIdleFrame(Sender: TObject; TimeDelta: Single);
  end;

  TGraphics2D = class(TGraphics)
  private

  protected
    procedure DoInitialize; override;
  public
    SpriteEngine: TSpriteEngine;
    PictureCollection: TPictureCollection;
    procedure CreateShoot(MyX, MyY: Single; MyAngle: Single);
    procedure CreateHit(MyX, MyY: Single; MyAngle: Single);
  end;

var
  Window2D: TWindow2D;
  Graphics2D: TGraphics2D;

  Jogador: TPlayerPlane;

implementation

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

  if FArmed then
  begin
    if Window.Key[VK_SPACE] then
    begin
      SoundList.Play(0);
      FArmed := False;
      Graphics2D.CreateShoot((X + 32) + 64 * Sin(D3DXToRadian(Angle)), (Y + 32) + 64 * Cos(D3DXToRadian(Angle)), Angle);
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

  ShadowX := FAcel * 2;
  ShadowY := FAcel * 2;

  Engine.X := -X + ((Engine.Width - Width) div 2);
  Engine.Y := -Y + ((Engine.Height - Height) div 2);
end;

procedure TShoot.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  if Sprite.Visible then
    if Sprite is TPlayerPlane then
    begin
      Graphics2D.CreateHit(X, Y, Angle);
      SoundList.Play(1);
      Dead;
    end;

  if Sprite.Visible then
    if Sprite is TShoot then
    begin
      Graphics2D.CreateHit(X, Y, Angle);
      SoundList.Play(1);
      Sprite.Dead;
      Dead;
    end;

  if Sprite.Visible then
    if Sprite is TEnemyPlane then
    begin
      Graphics2D.CreateHit(X, Y, Angle);
      SoundList.Play(1);
      Sprite.Dead;
      Dead;
    end;

  if Sprite.Visible then
    if Sprite is TEnemyBoat then
    begin
      Graphics2D.CreateHit(X, Y, Angle);
      SoundList.Play(1);
      Dead;
   // Dec(FDamage);
    //if FDamage < 0 then
     // Dead;
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

procedure TEnemyPlane.Hit;
begin
  //Graphics2D.CreateHit(X, Y, Angle);
end;
              {
procedure TEnemyPlane.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  if Sprite is TPlayerPlane then
    Hit;

  if Sprite is TShoot then
  begin
    Graphics2D.CreateHit(TShoot(Sprite).X, TShoot(Sprite).Y, Angle);
    SoundList.Play(1);
    TShoot(Sprite).Dead;
    Dec(FDamage);
    if FDamage < 0 then
      Dead;
  end;

  Done := False;
end;  }

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
    SoundList.Play(0);
    FArmed := False;
    Graphics2D.CreateShoot((X + 32) + 64 * Sin(D3DXToRadian(Angle)),
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

 // Collision;
end;

procedure TEnemyBoat.Hit;
begin
  //Graphics2D.CreateHit(X, Y, Angle);
end;

procedure TEnemyBoat.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  if AnimPos = 0 then
  begin
    Dec(FTimeSob);
    if FTimeSob < 0 then
    begin
      AnimStart := 0;
      AnimCount := 6;
      AnimLooped := False;
      AnimSpeed := 15 / 1000;
      AnimPos := 0;
      AnimReverse := False;
      FTimeSob := 100;
    end;
  end;

  if AnimPos = AnimCount - 1 then
  begin
    Visible := False;
    Dec(FTimeWater);
    if FTimeWater < 0 then
    begin
      X := Random(4) * 100;
      Y := Random(4) * 100;
      AnimStart := 0;
      AnimCount := 6;
      AnimLooped := False;
      AnimSpeed := 15 / 1000;
      AnimPos := 5;
      AnimReverse := True;
      Visible := True;
      FTimeWater := 100;
    end;
  end;

  FAngleGun := FAngleGun + 2.0;
  if FAngleGun > 360 then
    FAngleGun := 0;

  if Visible then
    if AnimPos <= 2 then
      if FArmed then
      begin
        SoundList.Play(0);
        FArmed := False;
        Graphics2D.CreateShoot((X + 32) + 64 * Sin(D3DXToRadian(FAngleGun)),
          (Y + 32) + 64 * Cos(D3DXToRadian(FAngleGun)), FAngleGun);
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

  //Collision;
end;
                     {
procedure TEnemyBoat.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  if Sprite is TPlayerPlane then
    Hit;

  if Sprite is TShoot then
  begin
    Graphics2D.CreateHit(TShoot(Sprite).X, TShoot(Sprite).Y, Angle);
    SoundList.Play(1);
    TShoot(Sprite).Dead;
   // Dec(FDamage);
    //if FDamage < 0 then
     // Dead;
  end;

  Done := False;
end;
         }

       {
procedure TPlayerCar.DoDraw;
var
  ImageIndex: Integer;
  r: TRect;
  Pos: TD3DXVector2;
  S: TD3DXVector2;
  RC: TD3DXVector2;
begin
  ImageIndex := GetDrawImageIndex;
  r := GetDrawRect;
  Pos := D3DXVector2(r.Left, r.Top);
  S := D3DXVector2(1.0, 1.0);
  RC := D3DXVector2(26,31);//(r.Left + 26, r.Top + 31);
  ShadowAlpha := 255;
  Canvas.Sprite.Draw(Image.PatternTextures[0].Image, nil, nil, @RC, D3DXToRadian(Angulo), @Pos, (ShadowAlpha shl 24) + clWhite);
  SetWindowText(Application.Handle, PChar(Format('Angulo: %f; Posicao: %d,%d', [D3DXToRadian(Angulo), r.Left, r.Top])));
end;}
{
procedure TPlayerCar.DoCollision(Sprite: TSprite; var Done: Boolean);
begin


end;
}
{ TWindow 2D }

procedure TWindow2D.DoFrame(Sender: TObject; TimeDelta: Single);
var
  I: Integer;
begin
  if Window2D.Key[VK_F2] then
    Application.Pause;

  Graphics2D.Clear;

  Graphics2D.SpriteEngine.Move(1000 div 60);
  Graphics2D.SpriteEngine.Dead;

  Graphics2D.BeginScene;

  Canvas.SpriteBegin;

  Graphics2D.SpriteEngine.Draw;


  Canvas.SpriteEnd;

  Canvas.TextOut(10, 380, IntToStr(Application.Fps));
  Canvas.TextOut(10, 400, Format('Total de sprites: %d', [Graphics2D.SpriteEngine.AllCount]));
  Canvas.TextOut(10, 420, Format('Sprites desenhados: %d', [Graphics2D.SpriteEngine.DrawCount]));

  Canvas.Draw(10, 10, Graphics2D.PictureCollection.Find('Radar'), 0, D3DXVector2(1.0, 1.0), D3DXVector2(0.0, 0.0), 0, 180, clWhite);
  for I := 1 to Graphics2D.SpriteEngine.Count - 1 do
    Canvas.Draw((Graphics2D.SpriteEngine.Items[I].BoundsRect.Left div 32)+32, (Graphics2D.SpriteEngine.Items[I].BoundsRect.Top div 32)+32,
      Graphics2D.PictureCollection.Find('Vermelho'), 0, 255);

  Graphics2D.EndScene;

  Graphics2D.Flip;
end;

procedure TWindow2D.DoIdleFrame(Sender: TObject; TimeDelta: Single);
begin
  if Window2D.Key[VK_F3] then
    Application.UnPause;

  Graphics2D.Clear;

  Graphics2D.BeginScene;

  Canvas.SpriteBegin;

  Canvas.SpriteEnd;

  Canvas.TextOut(10, 10, IntToStr(Application.Fps));
  Canvas.TextOut(10, 30, 'Paused');

  Graphics2D.EndScene;

  Graphics2D.Flip;
end;

procedure TWindow2D.DoInitialize;
begin
  Application.OnDoFrame := DoFrame;
  Application.OnDoIdleFrame := DoIdleFrame;
end;

{ TGraphics 2D }

procedure TGraphics2D.DoInitialize;
var
  I, J: Integer;
begin
  SpriteEngine := TSpriteEngine.Create(nil);
  SpriteEngine.SurfaceRect := Rect(0, 0, 640, 480);
  InitCosinTable;

  PictureCollection := TPictureCollection.Create;
  PictureCollection.Add('Media\Plane.bmp', 'Plane', 64, 64, clBlack);
  PictureCollection.Add('Media\Tile.bmp', 'Tile', 64, 64, clBlack);
  PictureCollection.Add('Media\Boat.bmp', 'Boat', 32, 98, clBlack);
  PictureCollection.Add('Media\Plane2.bmp', 'Plane2', 64, 64, clBlack);
  PictureCollection.Add('Media\Tiro1.bmp', 'Tiro', 9, 9, clBlack);
  PictureCollection.Add('Media\BombaMini.bmp', 'Bomba', 32, 32, clBlack);
  PictureCollection.Add('Media\Preto.bmp', 'Preto', 16, 16, clFuchsia);
  PictureCollection.Add('Media\Vermelho.bmp', 'Vermelho', 4, 4, clFuchsia);
  PictureCollection.Add('Media\Radar.bmp', 'Radar', 64, 64, clFuchsia);
  PictureCollection.Add('Sprites\Bomba_Grande.bmp', 'BombaGrande', 64, 64, clBlack);

  SoundList.Add('Media\Metranca.wav');
  SoundList.Add('Media\Boom.wav');

  with TBackgroundSprite.Create(SpriteEngine) do
  begin
    Image := PictureCollection.Find('Tile');
    SetMapSize(9, 7);
    Z := -1;
    Width := 64;
    Height := 64;
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

  for i := 0 to 2 do
    with TEnemyPlane.Create(SpriteEngine) do
    begin
      Image := PictureCollection.Find('Plane2');
      X := 50 * Random(10);
      Y := 50 * Random(20);
      Z := 3;
      Width := 64;
      Height := 64;
      AnimStart := 0;
      AnimCount := 3;
      AnimLooped := True;
      AnimSpeed := 15 / 1000;
      AnimPos := 0;
      Center := D3DXVector2(32, 32);
      Shadow := True;
      FDamage := 3;
    end;

  Jogador := TPlayerPlane.Create(SpriteEngine);
  with Jogador do
  begin
    Image := PictureCollection.Find('Plane');
    X := 100;
    Y := 100;
    Z := 3;
    Width := 52;
    Height := 62;
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
    FArmed := True;
    FTime := 5;
  end;

  with TEnemyBoat.Create(SpriteEngine) do
  begin
    Image := PictureCollection.Find('Boat');
    X := 128;
    Y := 128;
    Z := 1;
    Width := 32;
    Height := 98;
    AnimStart := 0;
    AnimCount := 6;
    AnimLooped := False;
    AnimSpeed := 15 / 1000;
    AnimPos := 6;
    AnimReverse := True;
    Angle := 0;
    Center := D3DXVector2(16, 51);
    Shadow := False;
    FTimeWater := 100;
    FTimeSob := 20;
  end;
end;

procedure TGraphics2D.CreateShoot(MyX, MyY: Single; MyAngle: Single);
begin
  with TShoot.Create(SpriteEngine) do
  begin
    Image := PictureCollection.Find('Tiro');
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

procedure TGraphics2D.CreateHit(MyX, MyY: Single; MyAngle: Single);
begin
  with THit.Create(SpriteEngine) do
  begin
    Image := PictureCollection.Find('Bomba');
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

