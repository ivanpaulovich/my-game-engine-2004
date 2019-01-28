(*******************************************************)
(*                                                     *)
(*       Engine Paulovich DirectX                      *)
(*       Win32-DirectX API Unit                        *)
(*                                                     *)
(*       Copyright (c) 2003-2004, Ivan Paulovich       *)
(*                                                     *)
(*       iskatrek@hotmail.com  uin#89160524            *)
(*                                                     *)
(*       Unit: glCanvas                                *)
(*                                                     *)
(*******************************************************)

unit glCanvas;

interface

uses
  Windows, SysUtils, Classes, glError, glConst, gl3DGraphics,
  D3DX8, {$IFDEF DXG_COMPAT}DirectXGraphics{$ELSE}Direct3D8{$ENDIF};

type

  (* Pre-Declaration *)

  TPictureItem = class;
  TPictureCollection = class;

  (* TReferer *)

  PCanvasReferer = ^TCanvasReferer;
  TCanvasReferer = class of TCanvas;

  (* T3DBrush *)

  P3DBrush = ^T3DBrush;
  T3DBrush = class
    Alpha: Byte;
    Color: TD3DColor;
  end;

  (* T3DFont *)

  P3DFont = ^T3DFont;
  T3DFont = class
    Name: string;
    Size: Integer;
    Color: TD3DColor;
    Font: HFONT;
  end;

  (* TCanvas *)

  PCanvas = ^TCanvas;
  TCanvas = class
  private
    F3DBrush: T3DBrush;
    F3DFont: T3DFont;
    FDXSprite: ID3DXSprite;
    FDXFont: ID3DXFont;
    FOldFont: T3DFont;
  public
    constructor Create(Graphics: TGraphics);
    procedure TextOut(X, Y: Integer; Text: string);
    procedure CreateTextureFromSurface(Surface: IDirect3DSurface8; SrcRect: TRect;
      ColorKey: TD3DColor; var Texture: IDirect3DTexture8);
    procedure Draw(X, Y: Integer; Source: TRect; Scale: TD3DXVector2; AxisRot: TD3DXVector2;
      Rotation: Single; Alpha: Byte; Color: TD3DColor; const Texture: IDirect3DTexture8); overload;
    procedure Draw(X, Y: Integer; Width, Height: Integer; const Texture: IDirect3DTexture8); overload;
    procedure SpriteBegin;
    procedure Draw(X, Y: Integer; Picture: TPictureItem; Index: Integer; Alpha: Byte); overload;
    procedure Draw(X, Y: Integer; Picture: TPictureItem; Index: Integer; Alpha: Byte; Color: TD3DColor); overload;
    procedure Draw(X, Y: Integer; Picture: TPictureItem; Index: Integer; Scale: TD3DXVector2; AxisRot: TD3DXVector2;
      Rotation: Single; Alpha: Byte; Color: TD3DColor); overload;
    procedure SpriteEnd;
    property Brush: T3DBrush read F3DBrush write F3DBrush;
    property Font: T3DFont read F3DFont write F3DFont;
    property Sprite: ID3DXSprite read FDXSprite write FDXSprite;
  end;

  (* TImage *)

  TImage = class
  public
    Image: IDirect3DTexture8;
  end;

  (* TPictureItem *)

  TPictureItem = class
  private
    FInfo: TD3DXImageInfo;
    FName: string;
    FPatternWidth: Integer;
    FPatternHeight: Integer;
    FSkipWidth: Integer;
    FSkipHeight: Integer;
    FTransparent: Boolean;
    FTransparentColor: LongInt;
    FTextureList: TList;
    function GetWidth: Integer;
    function GetHeight: Integer;
    function GetItem(Index: Integer): TImage;
    function GetCount: Integer;
  public
    constructor Create;
    destructor Destroy;
    function Add(const FileName: string): Boolean;
    property Name: string read FName write FName;
    property PatternWidth: Integer read FPatternWidth write FPatternWidth;
    property PatternHeight: Integer read FPatternHeight write FPatternHeight;
    property SkipWidth: Integer read FSkipWidth write FSkipWidth default 0;
    property SkipHeight: Integer read FSkipHeight write FSkipHeight default 0;
    property Transparent: Boolean read FTransparent write FTransparent;
    property TransparentColor: LongInt read FTransparentColor write FTransparentColor;
    property PatternTextures[Index: Integer]: TImage read GetItem;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
    property PatternCount: Integer read GetCount;
  end;

  (* TPictureCollection *)

  TPictureCollection = class
  private
    FListPictures: TList;
    function IndexOf(Name: string): Integer;
    function GetItem(Index: Integer): TPictureItem;
  public
    constructor Create;
    function Add(FileName: string; Name: string; PatternWidth, PatternHeight: Integer; ColorKey: Longint;
      SkipWidth: Integer = 0; SkipHeight: Integer = 0): Boolean;
    function Find(const Name: string): TPictureItem;
    property Items[Index: Integer]: TPictureItem read GetItem;
  end;

var
  Canvas: TCanvas = nil;

implementation

uses
  glApplication;

  (* TCanvas *)

constructor TCanvas.Create;
begin
  F3DFont := T3DFont.Create;
  F3DFont.Name := 'Arial';
  F3DFont.Size := 20;
  F3DFont.Font := 0;
  F3DFont.Font := CreateFont(F3DFont.Size, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    PROOF_QUALITY, 0, PChar(F3DFont.Name));
  F3DFont.Color := clWhite;

  FOldFont := T3DFont.Create;

  F3DBrush := T3DBrush.Create;
  F3DBrush.Alpha := 255;
  F3DBrush.Color := clBlack;

  D3DXCreateSprite(Graphics.Device, FDXSprite);

  D3DXCreateFont(Graphics.Device, F3DFont.Font, FDXFont);
end;

procedure TCanvas.TextOut(X, Y: Integer; Text: string);
var
  I: Integer;
  Rect: TRect;
begin
  I := Length(Text);

  SetRect(Rect, X, Y, X + (F3DFont.Size * I), Y + F3DFont.Size);

  if (F3DFont.Name <> FOldFont.Name) or
    (F3DFont.Size <> FOldFont.Size) or
    (F3DFont.Color <> FOldFont.Color) then
  begin
    F3DFont.Font := CreateFont(F3DFont.Size, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
      PROOF_QUALITY, 0, PChar(F3DFont.Name));
    D3DXCreateFont(Graphics.Device, F3DFont.Font, FDXFont);
    FOldFont := Font;
  end;

  FDXFont._Begin;

  FDXFont.DrawTextA(PChar(Text), Length(Text), Rect, DT_LEFT, (255 shl 24) + F3DFont.Color);

  FDXFont._End;
end;

procedure TCanvas.CreateTextureFromSurface(Surface: IDirect3DSurface8; SrcRect: TRect;
  ColorKey: TD3DColor; var Texture: IDirect3DTexture8);
var
  SurfDesc: TD3DSurface_Desc;
  TexSurface: IDirect3DSurface8;
begin
  Surface.GetDesc(SurfDesc);

  D3DXCreateTexture(Graphics.Device, SrcRect.Right - SrcRect.Left,
    SrcRect.Bottom - SrcRect.Top, 1, 0, D3DFMT_UNKNOWN, D3DPOOL_DEFAULT, Texture);

  Texture.GetLevelDesc(0, SurfDesc);
  Texture.GetSurfaceLevel(0, TexSurface);

  D3DXLoadSurfaceFromSurface(TexSurface, nil, nil, Surface, nil, @SrcRect, D3DX_FILTER_NONE, Colorkey);
end;

procedure TCanvas.Draw(X, Y: Integer; Width, Height: Integer; const Texture: IDirect3DTexture8);
var
  MatWorld, MatRotation, MatTranslation, MatScale: TD3DXMatrix;
  FX, FY: Single;
begin
  D3DXMatrixIdentity(MatTranslation);

  D3DXMatrixScaling(MatScale, Width, Height, 1.0);
  D3DXMatrixMultiply(MatTranslation, MatTranslation, MatScale);

  D3DXMatrixRotationZ(MatRotation, 0.0);
  D3DXMatrixMultiply(MatWorld, MatTranslation, MatRotation);


  FX := -(Graphics.Width div 2) + X;
  FY := (Graphics.Height div 2) - Height - Y;

  MatWorld._41 := FX;
  MatWorld._42 := FY;

  Graphics.Device.SetTransform(D3DTS_WORLD, MatWorld);
  Graphics.Device.SetTexture(0, Texture);
  Graphics.Device.SetStreamSource(0, Graphics.VertexBuffer, SizeOf(TVertex));
  Graphics.Device.SetVertexShader(D3DFVFVERTEX);
  Graphics.Device.DrawPrimitive(D3DPT_TRIANGLESTRIP, 0, 2);

  Graphics.Device.SetTexture(0, nil);
end;

procedure TCanvas.Draw(X, Y: Integer; Source: TRect; Scale: TD3DXVector2; AxisRot: TD3DXVector2;
  Rotation: Single; Alpha: Byte; Color: TD3DColor; const Texture: IDirect3DTexture8);
var
  Pos: TD3DXVector2;
begin
  Pos := D3DXVector2(X, Y);
  FDXSprite.Draw(Texture, @Source, @Scale, @AxisRot, Rotation, @Pos, (Alpha shl 24) + Color);
end;

procedure TCanvas.Draw(X, Y: Integer; Picture: TPictureItem; Index: Integer; Alpha: Byte);
var
  Pos: TD3DXVector2;
  S: TD3DXVector2;
begin
  Pos := D3DXVector2(X, Y);
  S := D3DXVector2(1.0, 1.0);
  if Picture.Transparent then
    FDXSprite.Draw(TImage(Picture.PatternTextures[Index]).Image, nil, @S, nil, 0, @Pos, (Alpha shl 24) + $FFFFFF)
  else
    FDXSprite.Draw(TImage(Picture.PatternTextures[Index]).Image, nil, @S, nil, 0, @Pos, 0);
end;

procedure TCanvas.Draw(X, Y: Integer; Picture: TPictureItem; Index: Integer; Alpha: Byte; Color: TD3DColor);
var
  Pos: TD3DXVector2;
  S: TD3DXVector2;
begin
  Pos := D3DXVector2(X, Y);
  S := D3DXVector2(1.0, 1.0);
  if Picture.Transparent then
    FDXSprite.Draw(TImage(Picture.PatternTextures[Index]).Image, nil, @S, nil, 0, @Pos, (Alpha shl 24) + Color)
  else
    FDXSprite.Draw(TImage(Picture.PatternTextures[Index]).Image, nil, @S, nil, 0, @Pos, 0);
end;

procedure TCanvas.Draw(X, Y: Integer; Picture: TPictureItem; Index: Integer; Scale: TD3DXVector2; AxisRot: TD3DXVector2;
  Rotation: Single; Alpha: Byte; Color: TD3DColor);
var
  Pos: TD3DXVector2;
begin
  Pos := D3DXVector2(X, Y);
  if Picture.Transparent then
    FDXSprite.Draw(TImage(Picture.PatternTextures[Index]).Image, nil, @Scale, @AxisRot, Rotation, @Pos, (Alpha shl 24) + $FFFFFF)
  else
    FDXSprite.Draw(TImage(Picture.PatternTextures[Index]).Image, nil, @Scale, @AxisRot, Rotation, @Pos, 0);
end;

procedure TCanvas.SpriteBegin;
begin
  FDXSprite._Begin;
end;

procedure TCanvas.SpriteEnd;
begin
  FDXSprite._End;
end;

  (* TPictureItem *)

constructor TPictureItem.Create;
begin
  FTextureList := TList.Create;
  FPatternWidth := 0;
  FPatternHeight := 0;
  FSkipWidth := 0;
  FSkipHeight := 0;
  FTransparent := True;
  FTransparentColor := clFuchsia;
end;

destructor TPictureItem.Destroy;
begin
  FTextureList.Free;
end;

function TPictureItem.GetItem(Index: Integer): TImage;
begin
  Result := TImage(FTextureList.Items[Index]);
end;

function TPictureItem.GetCount: Integer;
begin
  Result := FTextureList.Count - 1;
end;

function TPictureItem.Add(const FileName: string): Boolean;
var
  Texture: IDirect3DTexture8;
  Surface: IDirect3DSurface8;
  FRect: TRect;
  I, J: Integer;
  L, M: Integer;

  function AddTexture(const SrcRect: TRect): IDirect3DTexture8;
  begin
    Canvas.CreateTextureFromSurface(Surface, SrcRect, FTransparentColor, Result);
    FTextureList.Add(TImage.Create);
    TImage(FTextureList[FTextureList.Count - 1]).Image := Result;
  end;

begin
  Result := False;

  if Failed(D3DXGetImageInfoFromFile(PChar(FileName), FInfo)) then
    raise EError.Create(Format(ERROR_NOTFOUND,[FileName]))
  else
    SaveLog(Format(EVENT_FOUND,[FileName]));

  Graphics.Device.CreateImageSurface(FInfo.Width, FInfo.Height,
    Graphics.Parameters.BackBufferFormat, Surface);

  D3DXLoadSurfaceFromFile(Surface, nil, nil, PChar(FileName), nil, D3DX_FILTER_NONE, FTransparentColor, nil);

  if (GetWidth = FInfo.Width) and (GetHeight = FInfo.Height) then
  begin
    SetRect(FRect, 0, 0, FInfo.Width, FInfo.Height);
    if AddTexture(FRect) = nil then
      Exit;
  end
  else
  begin
    L := 0;
    if FPatternWidth <> 0 then
      L := (FInfo.Width + FSkipWidth) div (FPatternWidth + FSkipWidth);

    M := 0;
    if FPatternHeight <> 0 then
      M := (FInfo.Height + FSkipHeight) div (FPatternHeight + FSkipHeight);

    for J := 0 to M - 1 do
      for I := 0 to L - 1 do
      begin
        SetRect(FRect, I * (FPatternWidth + FSkipWidth), J * (FPatternHeight + FSkipHeight),
          (I * (FPatternWidth + FSkipWidth)) + FPatternWidth, (J * (FPatternHeight + FSkipHeight)) + FPatternHeight);

        if AddTexture(FRect) = nil then
          Exit;
      end;
  end;

  Result := True;
end;

function TPictureItem.GetWidth: Integer;
begin
  Result := FPatternWidth;

  if (Result <= 0) then
    Result := FInfo.Width;
end;

function TPictureItem.GetHeight: Integer;
begin
  Result := FPatternHeight;

  if (Result <= 0) then
    Result := FInfo.Height;
end;

  (* TPictureCollection *)

constructor TPictureCollection.Create;
begin
  FListPictures := TList.Create;
end;

function TPictureCollection.Add(FileName: string; Name: string; PatternWidth, PatternHeight: Integer;
  ColorKey: Longint; SkipWidth: Integer = 0; SkipHeight: Integer = 0): Boolean;
begin
  Result := False;

  FListPictures.Add(TPictureItem.Create);

  TPictureItem(FListPictures.Items[FListPictures.Count - 1]).Name := Name;
  TPictureItem(FListPictures.Items[FListPictures.Count - 1]).PatternWidth := PatternWidth;
  TPictureItem(FListPictures.Items[FListPictures.Count - 1]).PatternHeight := PatternHeight;
  TPictureItem(FListPictures.Items[FListPictures.Count - 1]).SkipWidth := SkipWidth;
  TPictureItem(FListPictures.Items[FListPictures.Count - 1]).SkipHeight := SkipHeight;
  TPictureItem(FListPictures.Items[FListPictures.Count - 1]).TransparentColor := ColorKey;

  if not TPictureItem(FListPictures.Items[FListPictures.Count - 1]).Add(FileName) then
    Result := True;
end;

function TPictureCollection.IndexOf(Name: string): Integer;
var
  I: Integer;
begin
  for I := 0 to FListPictures.Count - 1 do
  begin
    if TPictureItem(FListPictures[I]).Name = Name then
    begin
      Result := I;
      Exit;
    end;
  end;

  I := -1;
end;

function TPictureCollection.GetItem(Index: Integer): TPictureItem;
begin
  Result := TPictureItem(FListPictures.Items[Index]);
end;

function TPictureCollection.Find(const Name: string): TPictureItem;
var
  I: Integer;
begin
  I := IndexOf(Name);
  if I = -1 then
    raise EError.Create(Format(ERROR_NOTFOUND, [Name]));

  Result := TPictureItem(FListPictures.Items[I]);
end;

end.

 