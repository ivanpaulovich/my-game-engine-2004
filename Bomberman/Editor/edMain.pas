unit edMain;

interface

uses
  Windows, Messages, SysUtils, Classes, MMSystem, D3DX8, {$IFDEF DXG_COMPAT}DirectXGraphics{$ELSE}Direct3D8{$ENDIF},
  glWindow, glApplication, glGraphics, glCanvas, glError, glConst, glUtil, glSound, glDialogs, glSprite, glControls,
  edPanels;

type

  THeader = record
    Version: Integer;
    Description: string[255];
    Width, Height: Integer;
  end;

  TTile = record
    Index: Integer;
    Collide: Boolean;
  end;

  TWindow1 = class(TWindow)
  private
    FileWork: string;
    MapHeader: THeader;
    SpriteEngine: TSpriteEngine;
    PanelSprite: TPanelSprite;
    PanelTile: TPanelTile;
  public
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);
    procedure New;
    procedure DoInitialize; override;
    procedure DoCreate; override;
    procedure DoMouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure DoCommand(ID: Integer); override;
    procedure DoFrame(Sender: TObject; TimeDelta: Single);
    procedure DoIdleFrame(Sender: TObject; TimeDelta: Single);
    procedure CreateSprite(XPos, YPos: Integer; Index: Integer);
    procedure CreateTileAnim(XPos, YPos: Integer; Index: Integer);
  end;

  TGraphics1 = class(TGraphics)
  private
    procedure DoInitialize; override;
  public
    { Public declarations }
  end;

  TBackground = class(TBackgroundSprite)
  protected

  end;

  TActor = class(TImageSprite)
  private
    PosX: Integer;
    PosY: Integer;
  protected
    procedure DoMove(MoveCount: Integer); override;
  end;

var
  Window1: TWindow1;
  Graphics1: TGraphics1;
  Background: TBackground;

const
  PATH_IMG = 'Media\Img\';
  PATH_SOUND = 'Media\Sound\';
  Path_MUSIC = 'Media\Music\';

implementation

procedure TWindow1.LoadFromFile(const FileName: string);
var
  FileHeader: file of THeader;
  FileTile: file of TTile;
  Tile: TTile;
  Header: THeader;
  I, J: Integer;
begin
  if Length(FileName) = 0 then
    Exit;

  FileWork := FileName;

  AssignFile(FileHeader, FileName);
{$I-}
  Reset(FileHeader);
{$I+}
  if IORESULT <> 0 then
  begin
    CloseFile(FileHeader);
    Exit;
  end;
  Read(FileHeader, Header);
  CloseFile(FileHeader);

  MapHeader := Header;
  Background.SetMapSize(MapHeader.Width, MapHeader.Height);

  AssignFile(FileTile, FileName);
{$I-}
  Reset(FileTile);
{$I+}
  if IORESULT <> 0 then
  begin
    CloseFile(FileTile);
    Exit;
  end;
  Seek(FileTile, SizeOf(FileHeader));

  try
    for I := 0 to Background.MapWidth - 1 do
      for J := 0 to Background.MapHeight - 1 do
      begin
        Read(FileTile, Tile);
        Background.Chips[I, J] := Tile.Index;
        Background.CollisionMap[I, J] := Tile.Collide;
      end;
  finally
    CloseFile(FileTile);
  end;

  Caption := Format('%s - XBomber', [ExtractFileName(FileWork)]);
end;

procedure TWindow1.SaveToFile(const FileName: string);
var
  FileHeader: file of THeader;
  FileTile: file of TTile;
  Tile: TTile;
  Header: THeader;
  I, J: Integer;
begin
  if Length(FileName) = 0 then
    Exit;

  FileWork := FileName;

  AssignFile(FileHeader, FileName);
  if FileExists(FileName) then
    Reset(FileHeader)
  else
    Rewrite(FileHeader);

  Header := MapHeader;

  write(FileHeader, Header);
  CloseFile(FileHeader);

  AssignFile(FileTile, FileName);
  if FileExists(FileName) then
    Reset(FileTile)
  else
    Rewrite(FileTile);
  Seek(FileTile, SizeOf(FileHeader));

  try
    for I := 0 to Background.MapWidth - 1 do
      for J := 0 to Background.MapHeight - 1 do
      begin
        Tile.Index := Background.Chips[I, J];
        Tile.Collide := Background.CollisionMap[I, J];
        Write(FileTile, Tile);
      end;
  finally
    CloseFile(FileTile);
  end;

  Caption := Format('%s - XBomber', [ExtractFileName(FileWork)]);
end;

procedure TWindow1.New;
var
  I, J: Integer;
begin
  for I := 0 to Background.MapHeight - 1 do
    for J := 0 to Background.MapWidth - 1 do
    begin
      Background.Chips[J, I] := 0;
      Background.CollisionMap[J, I] := False;
    end;
end;

procedure TWindow1.DoFrame(Sender: TObject; TimeDelta: Single);
var
  I, J: Integer;
  Pos: TPoint;
begin
  if Window1.Key[VK_F2] then
    Application.Pause;

  if Window1.Key[VK_ESCAPE] then
    Application.Terminate;

  SpriteEngine.Move(1000 div 60);
  SpriteEngine.Dead;

  Graphics1.Clear;

  Graphics1.BeginScene;

  Canvas.SpriteBegin;

  Canvas.Draw(192, 128, Pictures.Item[2], 0);

  SpriteEngine.Draw;

  GetCursorPos(Pos);
  case IndexPage of
    0: Canvas.Draw(Pos.X- Window.Left, Pos.Y- Window.Top, Pictures.Item[0], PanelTile.Index);
    1: Canvas.Draw(Pos.X- Window.Left, Pos.Y- Window.Top, Pictures.Item[1], PanelSprite.Index * 10);
  end;

  PanelSprite.Draw;
  PanelTile.Draw;

  Canvas.SpriteEnd;

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
  BorderStyle := bsSingle;
  MenuName := 1;
  Left := 0;
  Top := 0;
  Width := 640;
  Height := 480;
  ClientRect := Bounds(0, 0, Width, Height);
  Caption := 'Mapa - XBomber';
  MapHeader.Version := 1;
  MapHeader.Description := 'XBomber';
  MapHeader.Width := 13;
  MapHeader.Height := 11;
  Position := poCenter;
end;

procedure TWindow1.DoMouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if MapFocus then
    case IndexPage of
      0:
        begin
          //Background.Chips[(X div 16) - (Round(Background.X) div 16), (Y div 16) - (Round(Background.Y) div 16)] := PanelTile.Index;
          if PanelTile.Index > 0 then
          begin
            Background.CollisionMap[(X div 16) - (Round(Background.X) div 16), (Y div 16) - (Round(Background.Y) div 16)] := True;
            if PanelTile.Index = 2 then
              CreateTileAnim(192+24+((X div 16) - (Round(Background.X) div 16)) * 16, 128+35+((Y div 16) - (Round(Background.Y) div 16)) * 16, 0);
          end
          else
            Background.CollisionMap[(X div 16) - (Round(Background.X) div 16), (Y div 16) - (Round(Background.Y) div 16)] := False;
        end;
      1: CreateSprite(((X div 16) - (Round(Background.X) div 16)) * 16, ((Y div 16) - (Round(Background.Y) div 16)) * 16, PanelSprite.Index);
    end;
  MapFocus := True;
end;

procedure TWindow1.DoCommand(ID: Integer);
begin
  case ID of
    1000:
      begin
        if Length(FileWork) = 0 then
        begin
          if MessageBox(Handle, PChar(Format(MSG_BOXSAVE, ['Mapa.map'])), MSG_CONFIRM, MB_YESNOCANCEL + MB_ICONEXCLAMATION) = IDYES then
          begin
            SaveToFile(SaveFile(0));
            if Length(FileWork) > 0 then
              New;
          end
          else
            New;
        end
        else
          New;
      end;
    1001: LoadFromFile(OpenFile(0));
    1002:
      begin
        if Length(FileWork) = 0 then
          SaveToFile(SaveFile(0))
        else
          SaveToFile(FileWork);
      end;
    1003: SaveToFile(SaveFile(0));

    1005: MessageBox(0, 'Em implementação', 'Em implementação', MB_OK);
    1006: Application.Terminate;
  end;
end;

procedure TWindow1.CreateSprite(XPos, YPos: Integer; Index: Integer);
begin
  with TActor.Create(SpriteEngine) do
  begin
    Image := Pictures.Find('Bomberman');
    X := XPos;
    Y := YPos;
    PosX := XPos;
    PosY := YPos;
    Z := 3;
    Width := Image.Width;
    Height := Image.Height;
    AnimStart := Index * 10;
    AnimCount := 10;
    AnimLooped := True;
    AnimSpeed := 15 / 1000;
    AnimPos := Random(9); //
    Angle := 0.0;
    Shadow := False;
    Center := D3DXVector2(32, 32);
    Shadow := False;
  end;
end;

procedure TWindow1.CreateTileAnim(XPos, YPos: Integer; Index: Integer);
begin
  with TImageSprite.Create(SpriteEngine) do
  begin
    Image := Pictures.Find('Tile');
    X := XPos;
    Y := YPos;
    Z := 3;
    Width := Image.Width;
    Height := Image.Height;
    AnimStart := 2;
    AnimCount := 4;
    AnimLooped := True;
    AnimSpeed := 15 / 1000;
    AnimPos := 2;
    Angle := 0.0;
    Shadow := False;
    Center := D3DXVector2(32, 32);
    Shadow := False;
  end;
end;

procedure TGraphics1.DoInitialize;
var
  I, J: Integer;
begin
  Randomize;

  Window1.SpriteEngine := TSpriteEngine.Create(nil);
  Window1.SpriteEngine.SurfaceRect := Bounds(0, 0, Window1.Width, Window1.Height);

  Pictures := TPictures.Create(TPicture);
  with Pictures.Add do
  begin
    Name := 'Tile';
    PatternWidth := 16;
    PatternHeight := 16;
    SkipWidth := 0;
    SkipHeight := 0;
    TransparentColor := clFuchsia;
    FileName := PATH_IMG + 'Tile.bmp';
  end;

  with Pictures.Add do
  begin
    Name := 'Bomberman';
    PatternWidth := 17;
    PatternHeight := 24;
    SkipWidth := 0;
    SkipHeight := 0;
    TransparentColor := clBlack;
    FileName := PATH_IMG + 'Bomberman.bmp';
  end;

  with Pictures.Add do
  begin
    Name := 'Background';
    PatternWidth := 256;
    PatternHeight := 224;
    SkipWidth := 0;
    SkipHeight := 0;
    TransparentColor := clFuchsia;
    FileName := PATH_IMG + 'Background.bmp';
  end;

  Background := TBackground.Create(Window1.SpriteEngine);
  with Background do
  begin
    Image := Pictures.Find('Tile');
    SetMapSize(Window1.MapHeader.Width, Window1.MapHeader.Height);
    X := 192 + 24;
    Y := 128 + 35;
    Z := -1;
    Width := Image.Width;
    Height := Image.Height;
    Tile := False;
    for I := 0 to MapWidth - 1 do
      for J := 0 to MapHeight - 1 do
      begin
        Chips[I, J] := 0;
        CollisionMap[I, J] := False;
      end;
  end;

  Window1.PanelSprite := TPanelSprite.Create;
  with Window1.PanelSprite do
  begin
    Initialize;
    Left := 10;
    Top := 10;
    Width := 2 * 17;
    Height := 24 + 16;
  end;

  Window1.PanelTile := TPanelTile.Create;
  with Window1.PanelTile do
  begin
    Initialize;
    Left := 10;
    Top := 80;
    Width := 5 * 16;
    Height := (1 * 16) + 16;
  end;

  Canvas.Brush.Color := D3DCOLOR_ARGB(255, 100, 100, 255);
  Canvas.Font.Color := clWhite;
end;

procedure TActor.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  X := Background.X + PosX;
  Y := Background.Y + PosY;
end;

end.

 