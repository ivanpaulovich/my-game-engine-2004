unit jMain;

interface

uses
  Windows, Messages, SysUtils, Classes, MMSystem,
  glApplication, glWindow, glGraphics, glSound, glError, glSprite, glCanvas, glUtil, glConst, glControls,
  D3DX8, {$IFDEF DXG_COMPAT}DirectXGraphics{$ELSE}Direct3D8{$ENDIF};

type

  TCompassDirection = (cdNorth, cdNorthEast, cdEast, cdSouthEast, cdSouth,
    cdSouthWest, cdWest, cdNorthWest);

  TDirectionOffset = array[TCompassDirection] of TPoint;

  TNode = record
    Direction: TCompassDirection;
    GridPt: TPoint;
  end;
  PNode = ^TNode;

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
    Engine: TSpriteEngine;
    Pictures: TPictures;
  protected
    procedure DoCreate; override;
    procedure DoInitialize; override;
  public
    procedure DoFrame(Sender: TObject; TimeDelta: Single);
    procedure DoIdleFrame(Sender: TObject; TimeDelta: Single);
    procedure LoadFromFile(const FileName: string);
    procedure DoClick; override;
  end;

  TGraphics1 = class(TGraphics)
  private
    procedure DoInitialize; override;
  public
    procedure CreateShoot(MyX, MyY: Single; MyAngle: Single);
  end;

var
  Window1: TWindow1;
  Graphics1: TGraphics1;
  Background: TBackgroundSprite;
  StartPt, EndPt: TPoint;
  SetStart: Boolean;
  PathQueue: TList;
  MapGrid: array[0..14, 0..19] of Byte;
  VisitedNodes: array[0..14, 0..19] of Boolean;

const
  PATH_IMG = 'Media\Img\';
  PATH_SOUND = 'Media\Sound\';
  Path_MUSIC = 'Media\Music\';

  DirectionOffset: TDirectionOffset = ((X: 0; Y: - 1), (X: 1; Y: - 1), (X: 1; Y: 0),
    (X: 1; Y: 1), (X: 0; Y: 1), (X: - 1; Y: 1), (X: - 1; Y: 0), (X: - 1; Y: - 1));

  NODECLEAR = 0;
  NODEOBSTACLE = 1;
  NODESTART = 2;
  NODEEND = 3;
  NODEPATH = 4;
  NODEVISITED = 5;

procedure ClearPathQueue;

implementation

procedure TWindow1.DoCreate;
begin
  Left := 50;
  Top := 50;
  Width := 640;
  Height := 480;
  Caption := 'Bomber IskaTreK';
  ClientRect := Bounds(0, 0, 640, 480);
  StartPt := Point(2, 2);
  EndPt := Point(10, 10);
  SetStart := True;
  PathQueue := TList.Create;
end;

procedure ClearPathQueue;
var
  iCount: Integer;
begin
  for iCount := 0 to PathQueue.Count - 1 do
    FreeMem(PathQueue[iCount], SizeOf(TNode));
  PathQueue.Clear;
end;

procedure TWindow1.DoInitialize;
begin
  Application.OnDoFrame := DoFrame;
  Application.OnDoIdleFrame := DoIdleFrame;
end;

procedure TWindow1.DoFrame(Sender: TObject; TimeDelta: Single);
begin
  if Window1.Key[VK_F2] then
    Application.Pause;

  if Window1.Key[VK_ESCAPE] then
    Application.Terminate;

  Graphics1.Clear;

  Engine.Move(1000 div 60);
  Engine.Dead;

  Graphics1.BeginScene;

  Canvas.SpriteBegin;

  Engine.Draw;

  Canvas.SpriteEnd;

  Canvas.TextOut(10, 10, IntToStr(Application.Fps));

  Graphics1.EndScene;

  Graphics1.Flip;
end;

procedure TWindow1.DoIdleFrame(Sender: TObject; TimeDelta: Single);
begin
  if Window.Key[VK_F3] then
    Application.UnPause;

  if Window.Key[VK_ESCAPE] then
    Application.Terminate;

  Graphics.Clear;

  Graphics.BeginScene;

  Canvas.SpriteBegin;

  Canvas.SpriteEnd;

  Canvas.TextOut(10, 10, IntToStr(Application.Fps));
  Canvas.TextOut(10, 30, 'Pressione Esc para sair.');
  Canvas.TextOut(10, 50, 'Parado');

  Graphics.EndScene;

  Graphics.Flip;
end;

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
end;

procedure TWindow1.DoClick;
var
  iCount, iCount2: Integer;
  CurPt, EvalPt, NewPt: TPoint;
  TempNode: PNode;
  Dist, EvalDist: Longword;
  Dir, NewDir: TCompassDirection;
  SearchDirs: array[0..2] of TCompassDirection;
begin
{don’t do anything until a starting and ending point have been set}
  if (StartPt.X = -1) or (EndPt.X = -1) then
    Exit;
{clear out the visited nodes array}
  FillChar(VisitedNodes, SizeOf(VisitedNodes), 0);
{populate the map grid with the specified impassible tiles}
  for iCount := 0 to 19 do
    for iCount2 := 0 to 14 do
      if Background.Chips[iCount, iCount2] = NODEOBSTACLE then
        MapGrid[iCount, iCount2] := 1
      else
        MapGrid[iCount, iCount2] := 0;
{delete the current path}
  ClearPathQueue;
{initialize the tracking variables}
  CurPt := StartPt;
  VisitedNodes[CurPt.X, CurPt.Y] := TRUE;
{determine the initial direction}
{destination left of origin}
  if EndPt.X < StartPt.X then
  begin
    if EndPt.Y > StartPt.Y then
      Dir := cdSouthWest
    else
      if EndPt.Y < StartPt.Y then
        Dir := cdNorthWest
      else
        Dir := cdWest;
  end
  else
{destination right of origin}
    if EndPt.X > StartPt.X then
    begin
      if EndPt.Y > StartPt.Y then
        Dir := cdSouthEast
      else
        if EndPt.Y < StartPt.Y then
          Dir := cdNorthEast
        else
          Dir := cdEast;
    end
    else
{destination directly above or below origin}
      if EndPt.Y > StartPt.Y then
        Dir := cdSouth
      else
        Dir := cdNorth;
{create a node object}
  GetMem(TempNode, SizeOf(TNode));
{initialize the node object with our current (starting) node information}
  TempNode^.Direction := Dir;
  TempNode^.GridPt.X := CurPt.X;
  TempNode^.GridPt.Y := CurPt.Y;
{add this starting node to the path list}
  PathQueue.Add(TempNode);
{begin searching the path until we reach the destination node}
  while (CurPt.X <> EndPt.X) or (CurPt.Y <> EndPt.Y) do
  begin
{reset the new coordinates to indicate nothing has been found}
    NewPt := Point(-1, -1);
{reset our distance to the largest value available (new nodes should
be well under this distance to the destination)}
    Dist := $FFFFFFFF;
{determine the 3 search directions}
    SearchDirs[0] := Pred(Dir);
    if Ord(SearchDirs[0]) < Ord(cdNorth) then
      SearchDirs[0] := cdNorthWest;
    SearchDirs[1] := Dir;
    SearchDirs[2] := Succ(Dir);
    if Ord(SearchDirs[2]) > Ord(cdNorthWest) then
      SearchDirs[2] := cdNorth;
{evaluate grid locations in 3 directions}
    for iCount := 0 to 2 do
    begin
{get the coordinates of the next node to examine relative to the
current node, based on the direction we are facing }
      EvalPt.X := CurPt.X + DirectionOffset[SearchDirs[iCount]].X;
      EvalPt.Y := CurPt.Y + DirectionOffset[SearchDirs[iCount]].Y;
{make sure this node is on the map}
      if (EvalPt.X > -1) and (EvalPt.X < 15) and
        (EvalPt.Y > -1) and (EvalPt.Y < 15) then
{make sure we’ve never visited this node}
        if not VisitedNodes[EvalPt.X, EvalPt.Y] then
{make sure this isn’t an impassible node}
          if MapGrid[EvalPt.X, EvalPt.Y] = 0 then
          begin
{this is a clear node that we could move to. calculate
the distance from this node to the destination.
NOTE: since we’re interested in just relative distances as
opposed to exact distances, we don’t need to perform a square
root. this will dramatically speed up this calculation}
            EvalDist := ((EndPt.X - EvalPt.X) * (EndPt.X - EvalPt.X)) +
              ((EndPt.Y - EvalPt.Y) * (EndPt.Y - EvalPt.Y));
{if we have found a node closer to the destination, make this
the current node}
            if EvalDist < Dist then
            begin
{record the new distance and node}
              Dist := EvalDist;
              NewPt := EvalPt;
{record the direction of this new node}
              NewDir := SearchDirs[iCount];
            end
          end;
    end;
{at this point, if NewPt is still (–1, –1), we’ve run into a wall and
cannot move any further. thus, we have to back up one and try again.
otherwise, we can add this new node to our list of nodes}
{we’ve got a valid node}
    if NewPt.X <> -1 then
    begin
{make this new node our current node}
      CurPt := NewPt;
{point us in the direction of this new node}
      Dir := NewDir;
{mark this node as visited}
      VisitedNodes[CurPt.X, CurPt.Y] := TRUE;
{create a node object}
      GetMem(TempNode, SizeOf(TNode));
{initialize this node object with the new node information}
      TempNode^.Direction := Dir;
      TempNode^.GridPt.X := CurPt.X;
      TempNode^.GridPt.Y := CurPt.Y;
{put this new node in the path list}
      PathQueue.Add(TempNode);
{if we’ve recorded 50 nodes, break out of this loop}
      if PathQueue.Count > 50 then
        Break;
    end
    else
    begin
{we’ve backed up to the point where we can no longer back up. thus, a
path could not be found. we could improve this algorithm by
recalculating the starting direction and trying again until we’ve
searched in all possible directions}
      if PathQueue.Count = 1 then
        Break;
{point us in the direction of the previous node}
      Dir := TNode(PathQueue[PathQueue.Count - 2]^).Direction;
{retrieve the coordinates of the previous node and make that
our current node}
      CurPt := Point(TNode(PathQueue[PathQueue.Count - 2]^).GridPt.X,
        TNode(PathQueue[PathQueue.Count - 2]^).GridPt.Y);
{free the last node in the list and delete it}
      FreeMem(PathQueue[PathQueue.Count - 1], SizeOf(TNode));
      PathQueue.Delete(PathQueue.Count - 1);
    end;
  end;
  for iCount := 0 to 19 do
    for iCount2 := 0 to 14 do
      if VisitedNodes[iCount, iCount2] then
        Background.Chips[iCount, iCount2] := NODEVISITED;
{specify nodes on the path}
  for iCount := 0 to PathQueue.Count - 1 do
  begin
    Background.Chips[TNode(PathQueue[iCount]^).GridPt.X,
      TNode(PathQueue[iCount]^).GridPt.Y] := NODEPATH;
  end;
{specify the starting and ending nodes}
  Background.Chips[StartPt.X, StartPt.Y] := NODESTART;
  Background.Chips[EndPt.X, EndPt.Y] := NODEEND;
end;

procedure TGraphics1.DoInitialize;
var
  I, J: Integer;
begin

  Window1.Engine := TSpriteEngine.Create(nil);
  Window1.Engine.SurfaceRect := Bounds(0, 0, Window1.Width, Window1.Height);

  Window1.Pictures := TPictures.Create(TPicture);
  with Form.Pictures.Add do
  begin
    Name := 'Tile';
    PatternWidth := 32;
    PatternHeight := 32;
    SkipWidth := 1;
    SkipHeight := 1;
    TransparentColor := clFuchsia;
    FileName := PATH_IMG + 'Tile.bmp';
  end;

  with Form.Pictures.Add do
  begin
    Name := 'Tank';
    PatternWidth := 32;
    PatternHeight := 32;
    SkipWidth := 1;
    SkipHeight := 1;
    TransparentColor := clBlack;
    FileName := PATH_IMG + 'Tank.bmp';
  end;

  with Form.Pictures.Add do
  begin
    Name := 'Tiro';
    PatternWidth := 8;
    PatternHeight := 8;
    SkipWidth := 0;
    SkipHeight := 0;
    TransparentColor := clBlack;
    FileName := PATH_IMG + 'Tiro1.bmp';
  end;

  Background := TBackground.Create(Form.Engine);
  with Background do
  begin
    Image := Form.Pictures.Find('Tile');
    SetMapSize(20, 15);
    X := -32;
    Y := -32;
    Z := -1;
    Width := Image.Width;
    Height := Image.Height;
    Tile := False;
    Collisioned := True;
    for I := 0 to MapWidth - 1 do
      for J := 0 to MapHeight - 1 do
      begin
        Chips[I, J] := 0;
        CollisionMap[I, J] := False;
      end;
  end;

  Form.LoadFromFile(PATH_MAP + 'Mapa.map');

  with TPlayerTank.Create(Form.Engine) do
  begin
    Image := Form.Pictures.Find('Tank');
    X := 0;
    Y := 0;
    Z := 3;
    Width := 28;
    Height := 28;
    AnimStart := 0;
    AnimCount := 7;
    AnimLooped := True;
    AnimSpeed := 15 / 1000;
    AnimPos := 0;
    Angle := 0.0;
    Center := D3DXVector2(Image.Width div 2, Image.Height div 2);
    Shadow := False;
  end;
end;

procedure TGraphics1.CreateShoot(MyX, MyY: Single; MyAngle: Single);
begin
  with TShoot.Create(Form.Engine) do
  begin
    Image := Form.Pictures.Find('Tiro');
    X := MyX;
    Y := MyY;
    Z := 2;
    Angle := MyAngle;
    Width := 8;
    Height := 8;
    MyTime := 60;
    Aceleration := 3.0;
  end;
end;

end.
