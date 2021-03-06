unit brActors;

interface

uses
  Windows, Messages, SysUtils, Classes, MMSystem,
  brForms, brGraphics, brSound, brInput, brSprite, brUtils, brControls,
  D3DX8, {$IFDEF DXG_COMPAT}DirectXGraphics{$ELSE}Direct3D8{$ENDIF};

type

  TCompassDirection = (cdNorth, cdEast, cdSouth, cdWest);

  TDirectionOffset = array[TCompassDirection] of TPoint;

  TNode = record
    Direction: TCompassDirection;
    GridPt: TPoint;
  end;
  PNode = ^TNode;

  TBackground = class(TBackgroundSprite)
  private

  public

  end;

  TDirection = (drUp, drRight, drDown, drLeft, drStop);

  TActor = class(TImageSprite)
  private
    FVisited: Pointer;
    FGrid: Pointer;
    FMap: Pointer;
    FDirection: TDirection;
    FMapWidth: Integer;
    FMapHeight: Integer;
    function GetMap(X, Y: Integer): Integer;
    procedure SetMap(X, Y: Integer; Value: Integer);
    function GetGrid(X, Y: Integer): Integer;
    procedure SetGrid(X, Y: Integer; Value: Integer);
    function GetVisited(X, Y: Integer): Boolean;
    procedure SetVisited(X, Y: Integer; Value: Boolean);
    procedure SetMapHeight(Value: Integer);
    procedure SetMapWidth(Value: Integer);
  protected
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
  public
    StartPt, EndPt: TPoint;
    SetStart: Boolean;
    PathQueue: TList;
    I: Integer;
    Variation: Integer;
    procedure ClearPathQueue;
    procedure Calculate;
    property Direction: TDirection read FDirection write FDirection;
    procedure SetMapSize(AMapWidth, AMapHeight: Integer);
    property MapHeight: Integer read FMapHeight write SetMapHeight;
    property MapWidth: Integer read FMapWidth write SetMapWidth;
    property Map[X, Y: Integer]: Integer read GetMap write SetMap;
    property Grid[X, Y: Integer]: Integer read GetGrid write SetGrid;
    property Visited[X, Y: Integer]: Boolean read GetVisited write SetVisited;
  end;

  TDirectionX = (StoppedX, Left, Right);
  TDirectionY = (StoppedY, Up, Down);

  TPlayer = class(TImageSprite)
  private
    FDirectionX: TDirectionX;
    FDirectionY: TDirectionY;
  protected
    procedure DoCollision(Sprite: TSprite; var Done: Boolean); override;
  public
    property DirectionX: TDirectionX read FDirectionX write FDirectionX;
    property DirectionY: TDirectionY read FDirectionY write FDirectionY;
  end;

  TPlayer1 = class(TPlayer)
  private

  protected
    procedure DoMove(MoveCount: Integer); override;
  public

  end;

  TActor1 = class(TActor)
  private

  protected
    procedure DoMove(MoveCount: Integer); override;
  public

  end;

  TActor2 = class(TActor)
  private

  protected
    procedure DoMove(MoveCount: Integer); override;
  public

  end;

var
  Background: TBackground;
  Player: TPlayer1;

const
  DirectionOffset: TDirectionOffset = ((X: 0; Y: - 1), (X: 1; Y: 0), (X: 0; Y: 1), (X: - 1; Y: 0));

  NODECLEAR = 0;
  NODEOBSTACLE = 1;
  NODESTART = 2;
  NODEEND = 3;
  NODEPATH = 4;
  NODEVISITED = 5;

implementation

function TActor.GetMap(X, Y: Integer): Integer;
begin
  if (X >= 0) and (X < FMapWidth) and (Y >= 0) and (Y < FMapHeight) then
    Result := PInteger(Integer(FMap) + (Y * FMapWidth + X) * SizeOf(Byte))^
  else
    Result := -1;
end;

procedure TActor.SetMap(X, Y: Integer; Value: Integer);
begin
  if (X >= 0) and (X < FMapWidth) and (Y >= 0) and (Y < FMapHeight) then
    PInteger(Integer(FMap) + (Y * FMapWidth + X) * SizeOf(Byte))^ := Value;
end;

function TActor.GetGrid(X, Y: Integer): Integer;
begin
  if (X >= 0) and (X < FMapWidth) and (Y >= 0) and (Y < FMapHeight) then
    Result := PInteger(Integer(FGrid) + (Y * FMapWidth + X) * SizeOf(Byte))^
  else
    Result := -1;
end;

procedure TActor.SetGrid(X, Y: Integer; Value: Integer);
begin
  if (X >= 0) and (X < FMapWidth) and (Y >= 0) and (Y < FMapHeight) then
    PInteger(Integer(FGrid) + (Y * FMapWidth + X) * SizeOf(Byte))^ := Value;
end;

function TActor.GetVisited(X, Y: Integer): Boolean;
begin
  if (X >= 0) and (X < FMapWidth) and (Y >= 0) and (Y < FMapHeight) then
    Result := PBoolean(Integer(FVisited) + (Y * FMapWidth + X) * SizeOf(Boolean))^
  else
    Result := False;
end;

procedure TActor.SetVisited(X, Y: Integer; Value: Boolean);
begin
  if (X >= 0) and (X < FMapWidth) and (Y >= 0) and (Y < FMapHeight) then
    PBoolean(Integer(FVisited) + (Y * FMapWidth + X) * SizeOf(Boolean))^ := Value;
end;

procedure TActor.SetMapHeight(Value: Integer);
begin
  SetMapSize(FMapWidth, Value);
end;

procedure TActor.SetMapWidth(Value: Integer);
begin
  SetMapSize(Value, FMapHeight);
end;

procedure TActor.DoCollision(Sprite: TSprite; var Done: Boolean);
var
  dr: Integer;
begin
  if Sprite.Visible then
    if Sprite is TBackgroundSprite then
    begin
      case Direction of
        drUp: Y := Y + 1;
        drDown: Y := Y - 1;
        drRight: X := X - 1;
        drLeft: X := X + 1;
      end;
      {dr := Ord(Direction) + 1;
      if dr > 3 then
        dr := 0;

      Direction := TDirection(dr);   }
    end;
  Done := False;
end;

procedure TActor.ClearPathQueue;
var
  iCount: Integer;
begin
  for iCount := 0 to PathQueue.Count - 1 do
    FreeMem(PathQueue[iCount], SizeOf(TNode));
  PathQueue.Clear;
end;

procedure TActor.Calculate;
var
  iCount, iCount2: Integer;
  CurPt, EvalPt, NewPt: TPoint;
  TempNode: PNode;
  Dist, EvalDist: Longword;
  Dir, NewDir: TCompassDirection;
  SearchDirs: array[0..2] of TCompassDirection;
begin
  if (StartPt.X < 0) or (EndPt.X < 0) then
    Exit;

  SetMapSize(13, 11);

  for iCount := 0 to FMapWidth - 1 do
    for iCount2 := 0 to FMapHeight - 1 do
      if Map[iCount, iCount2] = NODEOBSTACLE then
        Grid[iCount, iCount2] := 1
      else
        Grid[iCount, iCount2] := 0;

  ClearPathQueue;

  CurPt := StartPt;
  Visited[CurPt.X, CurPt.Y] := True;

  if EndPt.X < StartPt.X then
    Dir := cdWest
  else
    if EndPt.X > StartPt.X then
      Dir := cdEast
    else
      if EndPt.Y > StartPt.Y then
        Dir := cdSouth
      else
        Dir := cdNorth;

  GetMem(TempNode, SizeOf(TNode));

  TempNode^.Direction := Dir;
  TempNode^.GridPt.X := CurPt.X;
  TempNode^.GridPt.Y := CurPt.Y;

  PathQueue.Add(TempNode);

  while (CurPt.X <> EndPt.X) or (CurPt.Y <> EndPt.Y) do
  begin
    NewPt := Point(-1, -1);
    Dist := $FFFFFFFF;
    SearchDirs[1] := Dir;
    case Dir of
      cdNorth:
        begin
          SearchDirs[0] := cdEast;
          SearchDirs[2] := cdWest;
        end;
      cdWest:
        begin
          SearchDirs[0] := cdNorth;
          SearchDirs[2] := cdSouth;
        end;
      cdEast:
        begin
          SearchDirs[0] := cdSouth;
          SearchDirs[2] := cdNorth;
        end;
      cdSouth:
        begin
          SearchDirs[0] := cdWest;
          SearchDirs[2] := cdEast;
        end;
    end;

    for iCount := 0 to 2 do
    begin
      EvalPt.X := CurPt.X + DirectionOffset[SearchDirs[iCount]].X;
      EvalPt.Y := CurPt.Y + DirectionOffset[SearchDirs[iCount]].Y;
      if (EvalPt.X >= 0) and (EvalPt.X < FMapWidth) and (EvalPt.Y >= 0) and (EvalPt.Y < FMapHeight) then
        if not Visited[EvalPt.X, EvalPt.Y] then
          if Grid[EvalPt.X, EvalPt.Y] = 0 then
          begin
            EvalDist := ((EndPt.X - EvalPt.X) * (EndPt.X - EvalPt.X)) +
              ((EndPt.Y - EvalPt.Y) * (EndPt.Y - EvalPt.Y));
            if EvalDist < Dist then
            begin
              Dist := EvalDist;
              NewPt := EvalPt;
              NewDir := SearchDirs[iCount];
            end
          end;
    end;

    if NewPt.X <> -1 then
    begin
      CurPt := NewPt;
      Dir := NewDir;
      Visited[CurPt.X, CurPt.Y] := TRUE;
      GetMem(TempNode, SizeOf(TNode));
      TempNode^.Direction := Dir;
      TempNode^.GridPt.X := CurPt.X;
      TempNode^.GridPt.Y := CurPt.Y;
      PathQueue.Add(TempNode);
      if PathQueue.Count > 50 then
        Break;
    end
    else
    begin
      if PathQueue.Count = 1 then
        Break;
      Dir := TNode(PathQueue[PathQueue.Count - 2]^).Direction;
      CurPt := Point(TNode(PathQueue[PathQueue.Count - 2]^).GridPt.X,
        TNode(PathQueue[PathQueue.Count - 2]^).GridPt.Y);
      FreeMem(PathQueue[PathQueue.Count - 1], SizeOf(TNode));
      PathQueue.Delete(PathQueue.Count - 1);
    end;
  end;

  for iCount := 0 to FMapWidth - 1 do
    for iCount2 := 0 to FMapHeight - 1 do
      if Visited[iCount, iCount2] then
        Map[iCount, iCount2] := NODEVISITED;

  for iCount := 0 to PathQueue.Count - 1 do
    Map[TNode(PathQueue[iCount]^).GridPt.X, TNode(PathQueue[iCount]^).GridPt.Y] := NODEPATH;


  Map[StartPt.X, StartPt.Y] := NODESTART;
  Map[EndPt.X, EndPt.Y] := NODEEND;
end;

procedure TActor.SetMapSize(AMapWidth, AMapHeight: Integer);
var
  I, J: Integer;
begin
  if (FMapWidth <> AMapWidth) or (FMapHeight <> AMapHeight) then
  begin
    if (AMapWidth <= 0) or (AMapHeight <= 0) then
    begin
      AMapWidth := 0;
      AMapHeight := 0;
    end;
    FMapWidth := AMapWidth;
    FMapHeight := AMapHeight;
    ReAllocMem(FMap, FMapWidth * FMapHeight * SizeOf(Byte));
    FillChar(FMap^, FMapWidth * FMapHeight * SizeOf(Byte), 0);

    for I := 0 to FMapWidth - 1 do
      for J := 0 to FMapHeight - 1 do
        if Background.CollisionMap[I, J] then
          Map[I, J] := 1
        else
          Map[I, J] := 0;

    ReAllocMem(FGrid, FMapWidth * FMapHeight * SizeOf(Byte));
    FillChar(FGrid^, FMapWidth * FMapHeight * SizeOf(Byte), 1);

    ReAllocMem(FVisited, FMapWidth * FMapHeight * SizeOf(Boolean));
    FillChar(FVisited^, FMapWidth * FMapHeight * SizeOf(Boolean), 0);
  end;
end;

procedure TPlayer.DoCollision(Sprite: TSprite; var Done: Boolean);
begin
  if Sprite.Visible then
    if Sprite is TBackgroundSprite then
    begin
      case DirectionY of
        Up: Y := Y + 1;
        Down: Y := Y - 1;
      end;

      case DirectionX of
        Right: X := X - 1;
        Left: X := X + 1;
      end;
    end;
  Done := False;
end;

procedure TPlayer1.DoMove(MoveCount: Integer);
begin
  inherited DoMove(MoveCount);

  AnimLooped := False;
  AnimSpeed := 20 / 1000;
  AnimStart := 30;

  if Window.Key[VK_UP] then
  begin
    Y := Y - 1;
    DirectionY := Up;
    AnimStart := 20;
    AnimLooped := True;
    AnimSpeed := 15 / 1000;
  end;

  if Window.Key[VK_DOWN] then
  begin
    Y := Y + 1;
    DirectionY := Down;
    AnimStart := 30;
    AnimLooped := True;
    AnimSpeed := 15 / 1000;
  end;

  DirectionX := StoppedX;
  Collision;
  if not RectInRect(GetBoundsRect, Engine.SurfaceRect) then
  begin
    case DirectionY of
      Up: Y := Y + 1;
      Down: Y := Y - 1;
    end;

    case DirectionX of
      Right: X := X - 1;
      Left: X := X + 1;
    end;
  end;

  if Window.Key[VK_LEFT] then
  begin
    X := X - 1;
    DirectionX := Left;
    AnimStart := 10;
    AnimLooped := True;
    AnimSpeed := 15 / 1000;
  end;

  if Window.Key[VK_RIGHT] then
  begin
    X := X + 1;
    DirectionX := Right;
    AnimStart := 0;
    AnimLooped := True;
    AnimSpeed := 15 / 1000;
  end;

  DirectionY := StoppedY;
  Collision;
  if not RectInRect(GetBoundsRect, Engine.SurfaceRect) then
  begin
    case DirectionY of
      Up: Y := Y + 1;
      Down: Y := Y - 1;
    end;

    case DirectionX of
      Right: X := X - 1;
      Left: X := X + 1;
    end;
  end;
end;

procedure TActor1.DoMove(MoveCount: Integer);
var
  dr: Integer;
begin
  inherited DoMove(MoveCount);

  Variation := Variation + 1;
  if Variation = 16 then
  begin
    Inc(I);
    Variation := 0;
    if (I < PathQueue.Count) then
      Direction := TDirection(Ord(TNode(PathQueue[I]^).Direction))
    else
      Direction := drStop;
  end;

  case Direction of
    drUp: Y := Y - 1;
    drDown: Y := Y + 1;
    drRight: X := X + 1;
    drLeft: X := X - 1;
  end;

  Collision;

  if not RectInRect(GetBoundsRect, Engine.SurfaceRect) then
  begin
    case Direction of
      drUp: Y := Y + 1;
      drDown: Y := Y - 1;
      drRight: X := X - 1;
      drLeft: X := X + 1;
    end;

    {dr := Ord(Direction) + 1;
    if dr > 3 then
      dr := 0;

    Direction := TDirection(dr); }
  end;

  AnimStart := Ord(Direction) * AnimCount;
end;

procedure TActor2.DoMove(MoveCount: Integer);
var
  dr: Integer;
begin
  inherited DoMove(MoveCount);

  case Direction of
    drUp: Y := Y - 1;
    drDown: Y := Y + 1;
    drRight: X := X + 1;
    drLeft: X := X - 1;
  end;

  if not RectInRect(GetBoundsRect, Engine.SurfaceRect) then
  begin
    case Direction of
      drUp: Y := Y + 1;
      drDown: Y := Y - 1;
      drRight: X := X - 1;
      drLeft: X := X + 1;
    end;

    dr := Ord(Direction) + 1;
    if dr > 3 then
      dr := 0;

    Direction := TDirection(dr);
  end;

  Collision;
end;

end.

 