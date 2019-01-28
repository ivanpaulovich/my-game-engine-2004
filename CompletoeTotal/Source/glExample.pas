(*******************************************************)
(*                                                     *)
(*       Engine Paulovich DirectX                      *)
(*       Win32-DirectX API Unit                        *)
(*                                                     *)
(*       Copyright (c) 2003-2004, Ivan Paulovich       *)
(*                                                     *)
(*       iskatrek@hotmail.com  uin#89160524            *)
(*                                                     *)
(*       Unit: glExample                               *)
(*                                                     *)
(*******************************************************)

unit glExample;

interface

uses
  Windows, MMSystem, SysUtils, glSprite, Classes, glUtil,
  glApplication, glWindow, glSound, gl3DGraphics, glCanvas, glConst,
  D3DX8, {$IFDEF DXG_COMPAT}DirectXGraphics{$ELSE}Direct3D8{$ENDIF};

type
  TBackground = class(TBackgroundSprite)
  public
    procedure DoMove(MoveCount: Integer); override;
  end;

  THit = class(TImageSprite)
  public
    Time: Integer;
    procedure DoMove(MoveCount: Integer); override;
  end;

  TShootSprite = class(TImageSprite)
  private
    Time: Integer;
  public
    procedure DoMove(MoveCount: Integer); override;
    procedure Hit;
  end;

  TPlayerSprite = class(TImageSprite)
  private
    Inclination: Single;
    Armed: Boolean;
    Time: Integer;
  protected
    procedure DoMove(MoveCount: Integer); override;
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
  end;

  TEnemySprite = class(TImageSprite)
  private
    Damage: Integer;
  public
    procedure DoMove(MoveCount: Integer); override;
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
    procedure Hit;
  end;

  TNewWindow = class(TWindow)
  private
  protected
    procedure DoInitialize; override;
  public
    procedure DoFrame(Sender: TObject; TimeDelta: Single);
  end;

  TNewGraphics = class(TGraphics)
  private
    DXSpriteEngine: TSpriteEngine;
    Collection: TPictureCollection;
  protected
    procedure DoInitialize; override;
    procedure CreateShoot(MyX, MyY: Single);
    procedure CreateHit(MyX, MyY: Single);
    procedure CreateBoom(MyX, MyY: Single);
  public

  end;

var
  NewWindow: TNewWindow;
  NewGraphics: TNewGraphics;

implementation

procedure THit.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  X := X - Round(MoveCount * 0.5);

  Dec(Time);

  if Time < 0 then
    Dead;
end;

procedure TBackground.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  X := X - Round(MoveCount * 0.25);
end;

procedure TShootSprite.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  Dec(Time);

  if Time < 0 then
    Dead;

  X := X + Round(MoveCount * 0.9);
end;

procedure TShootSprite.Hit;
begin
  Sounds.Play(2);
  Dead;
end;

procedure TPlayerSprite.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  if Armed then
  begin
    if NewWindow.Key[VK_SPACE] then
    begin
      Armed := False;
      NewGraphics.CreateShoot(X, Y);
      Sounds.Play(1);
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

  if NewWindow.Key[VK_UP] then
  begin
    Y := Y - Round(MoveCount * 0.25);
    if Inclination > -80 then
      Inclination := Inclination - Round(MoveCount * 0.25);
  end;

  if NewWindow.Key[VK_DOWN] then
  begin
    Y := Y + Round(MoveCount * 0.25);
    if Inclination < 80 then
      Inclination := Inclination + Round(MoveCount * 0.25);
  end;

//  X := X + Round(MoveCount * 0.4);

  if NewWindow.Key[VK_LEFT] then
  begin
    X := X - Round(MoveCount * 0.15);
  end;

  if NewWindow.Key[VK_RIGHT] then
  begin
    X := X + Round(MoveCount * 0.25);
  end;

  if (not NewWindow.Key[VK_UP] and not NewWindow.Key[VK_DOWN]) or
    (NewWindow.Key[VK_UP] and NewWindow.Key[VK_DOWN]) then
  begin
    if Inclination < 0 then
      Inclination := Inclination + MoveCount * 0.25
    else if Inclination > 0 then
      Inclination := Inclination - MoveCount * 0.25;
  end;

  if Inclination < -75 then AnimPos := 0
  else if Inclination < -45 then AnimPos := 1
  else if Inclination < -15 then AnimPos := 2
  else if Inclination < 15 then AnimPos := 3
  else if Inclination < 45 then AnimPos := 4
  else if Inclination < 75 then AnimPos := 5
  else AnimPos := 6;

  Collision;

 // Engine.X := Engine.X - Round(MoveCount * 0.25);//(-X + Engine.Width div 2 - Width div 2) - (Engine.Width div 3);
  //Engine.Y := Engine.Y + Round(MoveCount * 0.25); //(-Y + Engine.Height div 2 - Height div 2);
end;

procedure TPlayerSprite.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  if Sprite is TEnemySprite then
    TEnemySprite(Sprite).Hit;

  Done := False;
end;

procedure TEnemySprite.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  X := X - Round(MoveCount * 0.6);
  if X < -80 then
    X := X + 1000;

  Collision;
end;

procedure TEnemySprite.Hit;
begin
  Sounds.Play(2);
  NewGraphics.CreateBoom(X, Y);
  Dead;
end;

procedure TEnemySprite.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  if Sprite is TShootSprite then
  begin
    NewGraphics.CreateHit(TShootSprite(Sprite).X, TShootSprite(Sprite).Y);
    TShootSprite(Sprite).Hit;
    Dec(Damage);
    if Damage < 0 then
    begin
      NewGraphics.CreateBoom(TShootSprite(Sprite).X, TShootSprite(Sprite).Y);
      Dead;
    end;
  end;

  Done := False;
end;

procedure TNewWindow.DoFrame;
begin
  Graphics.Clear;

  NewGraphics.DXSpriteEngine.Move(1000 div 60);
  NewGraphics.DXSpriteEngine.Dead;

  Graphics.BeginScene;

  Canvas.SpriteBegin;

  NewGraphics.DXSpriteEngine.Draw;

  Canvas.SpriteEnd;

  Canvas.TextOut(10, 10, IntToStr(Application.Fps));
  Canvas.TextOut(10, 30, IntToStr(NewGraphics.DXSpriteEngine.AllCount));
  Canvas.TextOut(10, 50, IntToStr(NewGraphics.DXSpriteEngine.DrawCount));

  Graphics.EndScene;

  Graphics.Flip;
end;

procedure TNewWindow.DoInitialize;
begin
  Sounds.Add('Sound.wav');
  Sounds.Add('SingleGunShot.wav');
  Sounds.Add('explode2.wav');
  Application.OnDoFrame := DoFrame;
  Application.OnDoIdleFrame := DoFrame;
end;

procedure TNewGraphics.DoInitialize;
var
  I, J: Integer;
begin
  DXSpriteEngine := TSpriteEngine.Create(nil);
  DXSpriteEngine.SurfaceRect := Rect(0, 0, 640, 480);
  InitCosinTable;

  Collection := TPictureCollection.Create;
  Collection.Add('1.bmp', 'One', 32, 32, clFuchsia);
  Collection.Add('Fundo1.bmp', 'Fundo', 0, 0, clFuchsia);
  Collection.Add('player2.bmp', 'Jogador', 69, 65, clBlack);
  Collection.Add('Tiro2.bmp', 'Tiro', 8, 4, clBlack);
  Collection.Add('Enemy.bmp', 'Inimigo', 69, 65, clBlack);
  Collection.Add('Testando.bmp', 'Testando', 32, 32, clBlack);
  Collection.Add('inimigo_hit1.bmp', 'EnemyHit', 16, 16, clBlack);
  Collection.Add('expl_inimigo1.bmp', 'EnemyBoom', 63, 62, clBlack);

  with TBackground.Create(DXSpriteEngine) do
  begin
    Image := Collection.Find('Fundo');
    SetMapSize(1, 1);
   // Collisioned := True;
    Z := -10;
    Width := 32;
    Height := 32;
  {  for i := 0 to MapHeight - 1 do
      for j := 0 to MapWidth - 1 do
      begin
        Chips[j, i] := Random(2);
        CollisionMap[j, i] := False;
      end;  }
    Tile := True;
    {Chips[2, 2] := 3;
    CollisionMap[2, 2] := True;
    Chips[2, 3] := 3;
    CollisionMap[2, 3] := True;
    Chips[3, 3] := 3;
    CollisionMap[3, 3] := True;
    Chips[3, 2] := 3;
    CollisionMap[3, 2] := True;  }
  end;

  with TPlayerSprite.Create(DXSpriteEngine) do
  begin
    Image := Collection.Find('Jogador');
  {  AnimStart := 0;
    AnimCount := 7;
    AnimLooped := True;
    AnimSpeed := 15/1000;
    AnimPos := 2;  }
    Z := 3;
    Width := 69;
    Height := 65;
    Armed := True;
    Time := 5;
    X := 0;
    Y := 0;
    Shadow := True;
  end;

  for I := 0 to 30 do
    with TEnemySprite.Create(DXSpriteEngine) do
    begin
      Image := Collection.Find('Inimigo');
      AnimStart := 0;
      AnimCount := 7;
      AnimLooped := True;
      AnimSpeed := 15 / 1000;
      AnimPos := Random(7);
      Z := 2;
      Width := 69;
      Height := 65;
      X := Random(50) * 100;
      Y := Random(5) * 80;
      Shadow := True;
      Damage := 5;
    end;
end;

procedure TNewGraphics.CreateShoot;
begin
  with TShootSprite.Create(DXSpriteEngine) do
  begin
    Image := Collection.Find('Tiro');
    X := MyX + 20;
    Y := MyY + 18 + (Random(2) * 26);
    Z := 0;
    Width := 8;
    Height := 4;
    Time := 30;
  end;
end;

procedure TNewGraphics.CreateHit;
begin
  with THit.Create(DXSpriteEngine) do
  begin
    Image := Collection.Find('EnemyHit');
    AnimStart := 0;
    AnimCount := 14;
    AnimLooped := True;
    AnimSpeed := 15 / 100;
    AnimPos := 0;
    X := MyX;
    Y := MyY;
    Z := 0;
    Width := 16;
    Height := 16;
    Time := 5;
  end;
end;

procedure TNewGraphics.CreateBoom;
begin
  with THit.Create(DXSpriteEngine) do
  begin
    Image := Collection.Find('EnemyBoom');
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

