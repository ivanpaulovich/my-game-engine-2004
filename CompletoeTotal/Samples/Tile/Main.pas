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
    procedure DoCreate; override;
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

  TDirectionX = (StoppedX, Left, Right);
  TDirectionY = (StoppedY, Up, Down);

  TPlayerPeople = class(TImageSprite)
  private
    FDirectionX: TDirectionX;
    FDirectionY: TDirectionY;
  protected
    procedure DoMove(MoveCount: Integer); override;
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
  public

  end;

procedure TPlayerPeople.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  FDirectionX := StoppedX;
  FDirectionY := StoppedY;
  AnimLooped := False;
  AnimSpeed := 20 / 1000;
  AnimStart := 30;

  if Window.Key[VK_UP] then
  begin
    Y := Y - 1;
    FDirectionY := Up;
    AnimStart := 20;
    AnimLooped := True;
    AnimSpeed := 15 / 1000;
  end;

  if Window.Key[VK_DOWN] then
  begin
    Y := Y + 1;
    FDirectionY := Down;
    AnimStart := 30;
    AnimLooped := True;
    AnimSpeed := 15 / 1000;
  end;

  if Window.Key[VK_Left] then
  begin
    X := X - 1;
    FDirectionX := Left;
    AnimStart := 10;
    AnimLooped := True;
    AnimSpeed := 15 / 1000;
  end;

  if Window.Key[VK_Right] then
  begin
    X := X + 1;
    FDirectionX := Right;
    AnimStart := 0;
    AnimLooped := True;
    AnimSpeed := 15 / 1000;
  end;

  Collision;

  Engine.X := -X + ((Engine.Width - Width) div 2);
  Engine.Y := -Y + ((Engine.Height - Height) div 2);
end;

procedure TPlayerPeople.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  if Sprite.Visible then
    if Sprite is TBackgroundSprite then
    begin
      if FDirectionY = Up then
        Y := Y + 1;

      if FDirectionY = Down then
        Y := Y - 1;

      if FDirectionX = Left then
        X := X + 1;

      if FDirectionX = Right then
        X := X - 1;
    end;

  Done := False;
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

procedure TWindow1.DoCreate;
begin
  Width := 320;
  Height := 240;
  Caption := 'Bomber IskaTreK';
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
  Randomize;

  SpriteEngine := TSpriteEngine.Create(nil);
  SpriteEngine.SurfaceRect := Rect(0, 0, Window1.Width, Window1.Height);

  Pictures := TPictureCollection.Create;
  Pictures.Add('Media\3.bmp', 'Tile', 16, 16, clBlack);
  Pictures.Add('Media\Bomberman.bmp', 'Bomberman', 17, 24, clBlack);

  with TBackgroundSprite.Create(SpriteEngine) do
  begin
    Image := Pictures.Find('Tile');
    SetMapSize(20, 15);
    Z := -1;
    Width := Image.Width;
    Height := Image.Height;
    Tile := True;
    Collisioned := True;
    for i := 0 to MapHeight - 1 do
      for j := 0 to MapWidth - 1 do
      begin
        if Random(10) = 3 then
        begin
          Chips[j, i] := Random(1) + 1;
          CollisionMap[j, i] := True;
        end
        else
        begin
          Chips[j, i] := 0;
          CollisionMap[j, i] := False;
        end;
      end;
    Chips[0, 0] := 0;
    CollisionMap[0, 0] := False;
    Chips[0, 1] := 0;
    CollisionMap[0, 1] := False;
    Chips[1, 1] := 0;
    CollisionMap[1, 1] := False;
    Chips[1, 0] := 0;
    CollisionMap[1, 0] := False;
  end;

  with TPlayerPeople.Create(SpriteEngine) do
  begin
    Image := Pictures.Find('Bomberman');
    X := 0;
    Y := 0;
    Z := 3;
    Width := Image.Width;
    Height := Image.Height;
    AnimStart := 0;
    AnimCount := 10;
    AnimLooped := True;
    AnimSpeed := 15 / 1000;
    AnimPos := 0;
    Angle := 0.0;
    Center := D3DXVector2(32, 32);
    Shadow := False;
  end;
end;

end.

