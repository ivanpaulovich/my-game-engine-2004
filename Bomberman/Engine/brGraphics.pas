(*******************************************************)
(*                                                     *)
(*       Engine Paulovich DirectX                      *)
(*       Win32-DirectX API Unit                        *)
(*                                                     *)
(*       Copyright (c) 2003-2004, Ivan Paulovich       *)
(*                                                     *)
(*       iskatrek@hotmail.com  uin#89160524            *)
(*                                                     *)
(*       Unit: brGraphics                              *)
(*                                                     *)
(*******************************************************)

unit brGraphics;

interface

uses
  Windows, SysUtils, Classes, brControls,
  D3DX8, {$IFDEF DXG_COMPAT}DirectXGraphics{$ELSE}Direct3D8{$ENDIF};

type

  (* Pre-Declarações *)

  TPicture = class;
  TPictures = class;

  (* Referências *)

  TRefGraphics = class of TGraphics;

  (* TVertex *)

  TVertex = record
    Pos: TD3DXVector3;
    Normal: TD3DXVector3;
    Tu, Tv: Single;
  end;
  PVertex = array[0..0] of TVertex;

  (* TGraphics *)

  PGraphics = ^TGraphics;
  TGraphics = class
  private
    FD3D: IDirect3D8;
    FDevice: IDirect3DDevice8;
    FVertexBuffer: IDirect3DVertexBuffer8;
    FD3DDM: TD3DDisplayMode;
    FD3DPP: TD3DPresent_Parameters;
    FBackSurface: IDirect3DSurface8;
    FBpp: Integer;
    FOnInitialize: TNotifyEvent;
    FOnFinalize: TNotifyEvent;
    FInitialized: Boolean;
  protected
    procedure DoInitialize; virtual;
    procedure DoFinalize; virtual;
  public
    constructor Create;
    destructor Destroy;
    function Run: Integer;
    procedure Clear;
    procedure BeginScene;
    procedure EndScene;
    procedure Flip;
    procedure Restore;
    property OnInitialize: TNotifyEvent read FOnInitialize write FOnInitialize;
    property OnFinalize: TNotifyEvent read FOnFinalize write FOnFinalize;
    property D3D: IDirect3D8 read FD3D write FD3D;
    property Device: IDirect3DDevice8 read FDevice write FDevice;
    property VertexBuffer: IDirect3DVertexBuffer8 read FVertexBuffer write FVertexBuffer;
    property BackBuffer: IDirect3DSurface8 read FBackSurface write FBackSurface;
    property Parameters: TD3DPresent_Parameters read FD3DPP write FD3DPP;
    property DisplayMode: TD3DDisplayMode read FD3DDM write FD3DDM;
    property Bpp: Integer read FBpp write FBpp;
    property Initialized: Boolean read FInitialized;
  end;

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
    procedure TextOut(X, Y: Single; const Text: string);
    procedure CreateTextureFromSurface(Surface: IDirect3DSurface8; SrcRect: TRect;
      ColorKey: TD3DColor; var Texture: IDirect3DTexture8);
    procedure DrawTexture(X, Y: Single; Width, Height: Integer; const Texture: IDirect3DTexture8);
    procedure DrawEx(X, Y: Single; Source: TRect; Scale: TD3DXVector2; AxisRot: TD3DXVector2;
      Rotation: Single; Alpha: Byte; Color: TD3DColor; const Texture: IDirect3DTexture8);
    procedure DrawExP(X, Y: Single; Source: PRect; Scale: PD3DXVector2; AxisRot: PD3DXVector2;
      Rotation: Single; Alpha: Byte; Color: TD3DColor; const Texture: IDirect3DTexture8);
    procedure Draw(X, Y: Single; Picture: TPicture; Index: Integer);
    procedure DrawAlpha(X, Y: Single; Picture: TPicture; Index: Integer; Alpha: Byte);
    procedure DrawRotate(X, Y: Single; Picture: TPicture; Index: Integer; CenterX, CenterY: Single; Angle: Single);
    procedure DrawSub(X, Y: Single; Picture: TPicture; Index: Integer; Alpha: Byte);
    procedure DrawRotateAlpha(X, Y: Single; Picture: TPicture; Index: Integer; Alpha: Byte; CenterX, CenterY: Single; Angle: Single);
    procedure DrawRotateSub(X, Y: Single; Picture: TPicture; Index: Integer; Alpha: Byte; CenterX, CenterY: Single; Angle: Single);
    procedure SpriteBegin;
    procedure SpriteEnd;
    property Brush: T3DBrush read F3DBrush write F3DBrush;
    property Font: T3DFont read F3DFont write F3DFont;
    property Sprite: ID3DXSprite read FDXSprite write FDXSprite;
  end;

  TImage = class
  public
    Image: IDirect3DTexture8;
  end;

  TPicture = class(TCollectionItem)
  private
    FInfo: TD3DXImageInfo;
    FName: string[255];
    FFileName: string[255];
    FPatternWidth: Integer;
    FPatternHeight: Integer;
    FSkipWidth: Integer;
    FSkipHeight: Integer;
    FTransparent: Boolean;
    FTransparentColor: TD3DColor;
    FTextureList: TList;
    function GetName: string;
    procedure SetName(Value: string);
    function GetWidth: Integer;
    function GetHeight: Integer;
    function GetItem(Index: Integer): TImage;
    function GetCount: Integer;
    function GetFileName: string;
    procedure SetFileName(Value: string);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy;
    function LoadFromFile(const FilePicture: string): Boolean;
    function SaveToFile(const FilePicture: string): Boolean;
    property Info: TD3DXImageInfo read FInfo write FInfo;
    property Name: string read GetName write SetName;
    property PatternWidth: Integer read FPatternWidth write FPatternWidth;
    property PatternHeight: Integer read FPatternHeight write FPatternHeight;
    property SkipWidth: Integer read FSkipWidth write FSkipWidth;
    property SkipHeight: Integer read FSkipHeight write FSkipHeight;
    property Transparent: Boolean read FTransparent write FTransparent;
    property TransparentColor: TD3DColor read FTransparentColor write FTransparentColor;
    property FileName: string read GetFileName write SetFileName;
    property PatternTextures[Index: Integer]: TImage read GetItem;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
    property PatternCount: Integer read GetCount;
  end;

  TPictures = class(TCollection)
  private
    function IndexOf(Name: string): TPicture;
    function GetItem(Index: Integer): TPicture;
  public
    function Add: TPicture;
    function AddEx(FileName: string; Name: string; PatternWidth, PatternHeight: Integer; ColorKey: Longint;
      SkipWidth: Integer = 0; SkipHeight: Integer = 0): TPicture;
    function Find(const Name: string): TPicture;
    property Item[Index: Integer]: TPicture read GetItem;
  end;

  THeaderPicture = record
    Name: string[255];
    FilePicture: string[255];
    PatternWidth: Integer;
    PatternHeight: Integer;
    SkipWidth: Integer;
    SkipHeight: Integer;
    TransparentColor: TD3DColor;
  end;

  TButton = class(TControl)
  public
    Style: Integer;
    procedure DoMouseEnter; override;
    procedure DoMouseLeave; override;
    procedure DoDraw;
  end;

const
  D3DFVFVERTEX = D3DFVF_XYZ or D3DFVF_NORMAL or D3DFVF_TEX1;

function Vertex(Pos: TD3DXVector3; Normal: TD3DXVector3; Tu, Tv: Single): TVertex;
function TextWidth(const Text: string): Integer;
function TextHeight(const Text: string): Integer;
function DrawButton(X, Y: Single; Width, Height, Style: Integer; const Text: string): Boolean;

var
  Graphics: TGraphics;
  Canvas: TCanvas = nil;

implementation

uses
  brForms;

function Vertex(Pos: TD3DXVector3; Normal: TD3DXVector3; Tu, Tv: Single): TVertex;
begin
  Result.Pos := Pos;
  Result.Normal := Normal;
  Result.tu := tu;
  Result.tv := tv;
end;

function TextWidth(const Text: string): Integer;
var
  Sz: TSize;
begin
  Windows.GetTextExtentPoint32(Window.Handle, PChar(Text), Length(Text), Sz);
  Result := Sz.cx;
end;

function TextHeight(const Text: string): Integer;
var
  Sz: TSize;
begin
  Windows.GetTextExtentPoint32(Window.Handle, PChar(Text), Length(Text), Sz);
  Result := Sz.cy;
end;

function DrawButton(X, Y: Single; Width, Height, Style: Integer; const Text: string): Boolean;
var
  S: TD3DXVector2;
begin
  Result := True;

  case Style of
    0:
      begin
        S := D3DXVector2(Width, Height);
        Canvas.DrawExP(X, Y, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[29].Image);

        S := D3DXVector2(Width, 1);
        Canvas.DrawExP(X, Y, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[28].Image);

        S := D3DXVector2(1, Height);
        Canvas.DrawExP(X, Y, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[28].Image);
        Canvas.DrawExP(X + Width, Y, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[0].Image);

        S := D3DXVector2(Width + 1, 1);
        Canvas.DrawExP(X, Y + Height, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[0].Image);

        S := D3DXVector2(1, Height - 2);
        Canvas.DrawExP(X + Width - 1, Y + 1, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[30].Image);

        S := D3DXVector2(Width - 1, 1);
        Canvas.DrawExP(X + 1, Y + Height - 1, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[30].Image);

      //  Canvas.TextOut(X + ((Width - TextWidth(Text)) div 2), Y + ((Height - TextHeight(Text)) div 2), Text);
      end;
    1:
      begin
        S := D3DXVector2(Width, Height);
        Canvas.DrawExP(X, Y, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[29].Image);

        S := D3DXVector2(Width - 2, 1);
        Canvas.DrawExP(X + 1, Y + 1, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[28].Image);

        S := D3DXVector2(1, Height - 2);
        Canvas.DrawExP(X + 1, Y + 1, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[28].Image);

        S := D3DXVector2(Width - 3, 1);
        Canvas.DrawExP(X + 2, Y + Height - 2, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[30].Image);

        S := D3DXVector2(1, Height - 4);
        Canvas.DrawExP(X + Width - 2, Y + 2, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[30].Image);

        S := D3DXVector2(Width, 1);
        Canvas.DrawExP(X, Y, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[0].Image);
        Canvas.DrawExP(X, Y + Height - 1, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[0].Image);

        S := D3DXVector2(1, Height);
        Canvas.DrawExP(X, Y, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[0].Image);
        Canvas.DrawExP(X + Width, Y, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[0].Image);

        S := D3DXVector2(Width + 1, 1);
        Canvas.DrawExP(X, Y + Height, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[0].Image);
        S := D3DXVector2(1, Height);
        Canvas.DrawExP(X + Width - 1, Y, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[0].Image);

      //  Canvas.TextOut(X + ((Width - TextWidth(Text)) div 2), Y + ((Height - TextHeight(Text)) div 2), Text);
      end;
    2:
      begin
        S := D3DXVector2(Width, Height);
        Canvas.DrawExP(X, Y, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[29].Image);

        S := D3DXVector2(Width, 1);
        Canvas.DrawExP(X, Y, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[0].Image);

        S := D3DXVector2(1, Height);
        Canvas.DrawExP(X, Y, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[0].Image);
        Canvas.DrawExP(X + Width, Y, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[0].Image);

        S := D3DXVector2(Width + 1, 1);
        Canvas.DrawExP(X, Y + Height, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[0].Image);

        S := D3DXVector2(Width - 2, 1);
        Canvas.DrawExP(X + 1, Y + 1, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[30].Image);
        Canvas.DrawExP(X + 1, Y + 1, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[30].Image);

        S := D3DXVector2(1, Height - 2);
        Canvas.DrawExP(X + 1, Y + 1, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[30].Image);
        Canvas.DrawExP(X + 1, Y + 1, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[30].Image);

        S := D3DXVector2(Width - 1, 1);
        Canvas.DrawExP(X + 1, Y + Height - 1, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[30].Image);

        S := D3DXVector2(1, Height - 2);
        Canvas.DrawExP(X + Width - 1, Y + 1, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[30].Image);

      //  Canvas.TextOut(X + 1 +((Width - TextWidth(Text)) div 2), Y + 1 + ((Height - TextHeight(Text)) div 2), Text);
      end;
  else
    Result := False;
  end;

end;

  (* TGraphics *)

constructor TGraphics.Create;
begin
  if Assigned(Graphics) then
    raise ELogError.Create(Format(ERROR_EXISTS, ['TGraphics']))
  else
    SaveLog(Format(EVENT_CREATE, ['TGraphics']));

  Graphics := Self;
  FD3D := nil;
  FDevice := nil;
  FBackSurface := nil;
  FBpp := 32;
  FInitialized := False;
end;

destructor TGraphics.Destroy;
begin
  DoFinalize;

  if Assigned(FBackSurface) then
  begin
    FBackSurface._Release;
    FBackSurface := nil;
  end;
  if Assigned(FDevice) then
  begin
    FDevice._Release;
    FDevice := nil;
  end;
  if Assigned(FD3D) then
  begin
    FD3D._Release;
    FD3D := nil;
  end;
end;

function TGraphics.Run: Integer;
var
  Hr: HResult;
  MatProj, MatView: TD3DXMatrix;
  pVertices: ^PVertex;
  K: Integer;
begin
  Result := E_FAIL;

  SaveLog(Format(EVENT_TALK, ['TGraphics.Run']));

  FD3D := Direct3DCreate8(D3D_SDK_VERSION);
  if FD3D = nil then
    raise EError.Create(Format(ERROR_EXISTS, ['IDirect3D8']))
  else
    SaveLog(Format(EVENT_CREATE, ['IDirect3D8']));

  Fillchar(FD3DPP, SizeOf(FD3DPP), 0);

  FD3DPP.Windowed := not Window.FullScreen;
  FD3DPP.hDeviceWindow := Window.Handle;
  FD3DPP.EnableAutoDepthStencil := False;
  FD3DPP.BackBufferCount := 1;
  FD3DPP.Flags := D3DPRESENTFLAG_LOCKABLE_BACKBUFFER;

  if Window.FullScreen then
  begin
    FD3DPP.BackBufferWidth := Window.Width;
    FD3DPP.BackBufferHeight := Window.Height;
    case FBpp of
      8: FD3DPP.BackBufferFormat := D3DFMT_R3G3B2;
      15: FD3DPP.BackBufferFormat := D3DFMT_X1R5G5B5;
      16: FD3DPP.BackBufferFormat := D3DFMT_R5G6B5;
      24: FD3DPP.BackBufferFormat := D3DFMT_X8R8G8B8;
      32: FD3DPP.BackBufferFormat := D3DFMT_A8R8G8B8;
    else
      FD3DPP.BackBufferFormat := D3DFMT_A8R8G8B8;
    end;
    FD3DPP.SwapEffect := D3DSWAPEFFECT_COPY;
    FD3DPP.MultiSampleType := D3DMULTISAMPLE_NONE;
    FD3DPP.EnableAutoDepthStencil := False;
    FD3DPP.AutoDepthStencilFormat := D3DFMT_D16;
    FD3DPP.FullScreen_RefreshRateInHz := D3DPRESENT_RATE_DEFAULT;
    FD3DPP.FullScreen_PresentationInterval := D3DPRESENT_INTERVAL_IMMEDIATE;
  end
  else
  begin
    if Failed(FD3D.GetAdapterDisplayMode(D3DADAPTER_DEFAULT, FD3DDM)) then
      raise EError.Create(Format(EVENT_ERROR, ['TGraphics.Initialize']));

    FD3DPP.BackBufferFormat := FD3DDM.Format;
    FD3DPP.SwapEffect := D3DSWAPEFFECT_DISCARD;
  end;

  Hr := FD3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, Window.Handle,
    D3DCREATE_HARDWARE_VERTEXPROCESSING, FD3DPP, FDevice);
  if Failed(hr) then
  begin
    Hr := FD3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, Window.Handle,
      D3DCREATE_MIXED_VERTEXPROCESSING, FD3DPP, FDevice);
    if Failed(Hr) then
    begin
      Hr := FD3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_HAL, Window.Handle,
        D3DCREATE_SOFTWARE_VERTEXPROCESSING, FD3DPP, FDevice);
      if FAILED(Hr) then
        Hr := FD3D.CreateDevice(D3DADAPTER_DEFAULT, D3DDEVTYPE_REF, Window.Handle,
          D3DCREATE_SOFTWARE_VERTEXPROCESSING, FD3DPP, FDevice);
      if Failed(Hr) then
        raise EError.Create(ERROR_CREATEDEVICE)
      else
        SaveLog(Format(EVENT_CREATE, ['IDirect3DDevice8']));
    end;
  end;

  D3DXMatrixIdentity(MatView);
  FDevice.SetTransform(D3DTS_VIEW, MatView);

  D3DXMatrixOrthoLH(MatProj, Window.Width, Window.Height, 0, 1);
  FDevice.SetTransform(D3DTS_PROJECTION, MatProj);
  FDevice.SetRenderState(D3DRS_CULLMODE, D3DCULL_CW);
  FDevice.SetRenderState(D3DRS_LIGHTING, iFalse);
  FDevice.SetRenderState(D3DRS_ZENABLE, iFalse);
  FDevice.SetRenderState(D3DRS_ZWRITEENABLE, iFalse);

  if Failed(FDevice.CreateVertexBuffer(4 * Sizeof(TVertex), 0, D3DFVFVERTEX,
    D3DPOOL_DEFAULT, FVertexBuffer)) then
    Exit;

  if FAILED(FVertexBuffer.Lock(0, 0, PByte(pVertices), 0)) then
    Exit;

  K := 1;

  pVertices[0 * K] := Vertex(D3DXVECTOR3(0.0, 0.0, 0.0), D3DXVECTOR3(0.0, 0.0, 1.0), 0.0, 1.0);

  pVertices[1 * K] := Vertex(D3DXVECTOR3(0.0, 1.0, 0.0), D3DXVECTOR3(0.0, 0.0, 1.0), 0.0, 0.0);

  pVertices[2 * K] := Vertex(D3DXVECTOR3(1.0, 0.0, 0.0), D3DXVECTOR3(0.0, 0.0, 1.0), 1.0, 1.0);

  pVertices[3 * K] := Vertex(D3DXVECTOR3(1.0, 1.0, 0.0), D3DXVECTOR3(0.0, 0.0, 1.0), 1.0, 0.0);

  FVertexBuffer.Unlock;

  FDevice.GetBackBuffer(0, D3DBACKBUFFER_TYPE_MONO, FBackSurface);

  Canvas := TCanvas.Create(Self);

  DoInitialize;

  FInitialized := True;
  
  Result := S_OK;
end;

procedure TGraphics.Clear;
begin
  FDevice.Clear(0, nil, D3DCLEAR_TARGET, Canvas.Brush.Color, 1.0, 0);
end;

procedure TGraphics.BeginScene;
begin
  FDevice.BeginScene;
end;

procedure TGraphics.EndScene;
begin
  FDevice.EndScene;
end;

procedure TGraphics.Flip;
begin
  FDevice.Present(nil, nil, 0, nil);
end;

procedure TGraphics.Restore;
var
  MatProj, MatView: TD3DXMatrix;
begin
  D3DXMatrixIdentity(MatView);
  FDevice.SetTransform(D3DTS_VIEW, MatView);

  D3DXMatrixOrthoLH(MatProj, Window.Width, Window.Height, 0, 1);
end;

procedure TGraphics.DoInitialize;
begin
  if Assigned(FOnInitialize) then FOnInitialize(Self);
end;

procedure TGraphics.DoFinalize;
begin
  if Assigned(FOnFinalize) then FOnFinalize(Self);
end;

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

procedure TCanvas.TextOut(X, Y: Single; const Text: string);
var
  I: Integer;
  Rect: TRect;
begin
  I := Length(Text);

  SetRect(Rect, Trunc(X), Trunc(Y), Trunc(X) + (F3DFont.Size * I), Trunc(Y) + F3DFont.Size);

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
  TexSurface: IDirect3DSurface8;
begin
  D3DXCreateTexture(Graphics.Device, SrcRect.Right - SrcRect.Left,
    SrcRect.Bottom - SrcRect.Top, 0, 0, 0, D3DPOOL_DEFAULT, Texture);

  Texture.GetSurfaceLevel(0, TexSurface);

  D3DXLoadSurfaceFromSurface(TexSurface, nil, nil, Surface, nil, @SrcRect, D3DX_FILTER_NONE, ColorKey);
end;

procedure TCanvas.Draw(X, Y: Single; Picture: TPicture; Index: Integer);
begin
  DrawAlpha(X, Y, Picture, Index, 255);
end;

procedure TCanvas.DrawAlpha(X, Y: Single; Picture: TPicture; Index: Integer; Alpha: Byte);
var
  Pos: TD3DXVector2;
begin
  Pos := D3DXVector2(X, Y);
  FDXSprite.Draw(TImage(Picture.PatternTextures[Index]).Image, nil, nil, nil, 0, @Pos, (Alpha shl 24) + $FFFFFF);
end;

procedure TCanvas.DrawRotate(X, Y: Single; Picture: TPicture; Index: Integer; CenterX, CenterY: Single; Angle: Single);
var
  Pos: TD3DXVector2;
  Center: TD3DXVector2;
begin
  Pos := D3DXVector2(X, Y);
  Center := D3DXVector2(CenterX, CenterY);
  FDXSprite.Draw(TImage(Picture.PatternTextures[Index]).Image, nil, nil, @Center, Angle, @Pos, $FFFFFFFF);
end;

procedure TCanvas.DrawSub(X, Y: Single; Picture: TPicture; Index: Integer; Alpha: Byte);
var
  Pos: TD3DXVector2;
begin
  Pos := D3DXVector2(X, Y);
  FDXSprite.Draw(TImage(Picture.PatternTextures[Index]).Image, nil, nil, nil, 0, @Pos, (Alpha shl 24) + clBlack);
end;

procedure TCanvas.DrawRotateAlpha(X, Y: Single; Picture: TPicture; Index: Integer; Alpha: Byte; CenterX, CenterY: Single; Angle: Single);
var
  Pos: TD3DXVector2;
  Center: TD3DXVector2;
begin
  Pos := D3DXVector2(X, Y);
  Center := D3DXVector2(CenterX, CenterY);
  FDXSprite.Draw(TImage(Picture.PatternTextures[Index]).Image, nil, nil, @Center, Angle, @Pos, (Alpha shl 24) + $FFFFFF);
end;

procedure TCanvas.DrawRotateSub(X, Y: Single; Picture: TPicture; Index: Integer; Alpha: Byte; CenterX, CenterY: Single; Angle: Single);
var
  Pos: TD3DXVector2;
  Center: TD3DXVector2;
begin
  Pos := D3DXVector2(X, Y);
  Center := D3DXVector2(CenterX, CenterY);
  FDXSprite.Draw(TImage(Picture.PatternTextures[Index]).Image, nil, nil, @Center, Angle, @Pos, (Alpha shl 24) + clBlack);
end;

procedure TCanvas.DrawTexture(X, Y: Single; Width, Height: Integer; const Texture: IDirect3DTexture8);
var
  MatWorld, MatRotation, MatTranslation, MatScale: TD3DXMatrix;
  FX, FY: Single;
begin
  D3DXMatrixIdentity(MatTranslation);

  D3DXMatrixScaling(MatScale, Width, Height, 1.0);
  D3DXMatrixMultiply(MatTranslation, MatTranslation, MatScale);

  D3DXMatrixRotationZ(MatRotation, 0.0);
  D3DXMatrixMultiply(MatWorld, MatTranslation, MatRotation);


  FX := -(Window.Width div 2) + X;
  FY := (Window.Height div 2) - Height - Y;

  MatWorld._41 := FX;
  MatWorld._42 := FY;

  Graphics.Device.SetTransform(D3DTS_WORLD, MatWorld);
  Graphics.Device.SetTexture(0, Texture);
  Graphics.Device.SetStreamSource(0, Graphics.VertexBuffer, SizeOf(TVertex));
  Graphics.Device.SetVertexShader(D3DFVFVERTEX);
  Graphics.Device.DrawPrimitive(D3DPT_TRIANGLESTRIP, 0, 2);

  Graphics.Device.SetTexture(0, nil);
end;

procedure TCanvas.DrawEx(X, Y: Single; Source: TRect; Scale: TD3DXVector2; AxisRot: TD3DXVector2;
  Rotation: Single; Alpha: Byte; Color: TD3DColor; const Texture: IDirect3DTexture8);
var
  Pos: TD3DXVector2;
begin
  Pos := D3DXVector2(X, Y);
  FDXSprite.Draw(Texture, @Source, @Scale, @AxisRot, Rotation, @Pos, (Alpha shl 24) + Color);
end;

procedure TCanvas.DrawExP(X, Y: Single; Source: PRect; Scale: PD3DXVector2; AxisRot: PD3DXVector2;
  Rotation: Single; Alpha: Byte; Color: TD3DColor; const Texture: IDirect3DTexture8);
var
  Pos: TD3DXVector2;
begin
  Pos := D3DXVector2(X, Y);
  if Failed(FDXSprite.Draw(Texture, Source, Scale, AxisRot, Rotation, @Pos, (Alpha shl 24) + Color)) then
    MessageBox(0, '0', '0', MB_OK); ;
end;

procedure TCanvas.SpriteBegin;
begin
  FDXSprite._Begin;
end;

procedure TCanvas.SpriteEnd;
begin
  FDXSprite._End;
end;

constructor TPicture.Create;
begin
  inherited Create(Collection);
  FPatternWidth := 0;
  FPatternHeight := 0;
  FSkipWidth := 0;
  FSkipHeight := 0;
  FTransparent := True;
  FTransparentColor := clFuchsia;
end;

destructor TPicture.Destroy;
begin
  FTextureList.Free;
end;

function TPicture.GetItem(Index: Integer): TImage;
begin
  Result := TImage(FTextureList.Items[Index]);
end;

function TPicture.GetCount: Integer;
begin
  Result := FTextureList.Count - 1;
end;

function TPicture.GetName: string;
begin
  Result := FName;
end;

procedure TPicture.SetName(Value: string);
begin
  FName := Value;
end;

function TPicture.GetWidth: Integer;
begin
  Result := FPatternWidth;

  if (Result <= 0) then
    Result := FInfo.Width;
end;

function TPicture.GetHeight: Integer;
begin
  Result := FPatternHeight;

  if (Result <= 0) then
    Result := FInfo.Height;
end;

function TPicture.GetFileName: string;
begin
  Result := FileName;
end;

function D3DXLoadSurfaceFromFile(_filename: pChar;
  _format: TD3DFormat): IDirect3DSurface8;

var _r: TRect;
  _imginfo: TD3DXImageInfo;

begin
  Result := nil;

  // Create a 16 bit dummy surface.
  if (failed(Graphics.Device.CreateImageSurface(4, 4, D3DFMT_R5G6B5,
    Result))) or (Result = nil) then exit;

  // Load file into dummy surface.
  _r.Left := 0;
  _r.Top := 0;
  _r.Right := 3;
  _r.Bottom := 3;
  if (failed(D3DXLoadSurfaceFromFileA(Result, nil, @_r, _filename, nil,
    D3DX_FILTER_NONE, 0, @_imginfo)))
    then Result := nil;

  // All right ?
  if Result <> nil then
  begin
   // MessageBox(0, '0', '0', MB_OK);
      // Destroy dummy surface and create a new one with the image
      // dimensions.
    Result := nil;

      // Create the surface.
    if _format = 0 then _format := _imginfo.Format;
    with _imginfo do
      if (failed(Graphics.Device.CreateImageSurface(Width, Height, _format,
        Result))) or (Result = nil) then exit;

      // Load file into the surface.
    if (failed(D3DXLoadSurfaceFromFileA(Result, nil, nil, _filename,
      nil, D3DX_FILTER_NONE, 0, nil)))
      then Result := nil;
  end;
end;

procedure TPicture.SetFileName(Value: string);
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
  FTextureList := TList.Create;

  FFileName := Value;

  if Failed(D3DXGetImageInfoFromFile(PChar(Value), FInfo)) then
    raise EError.Create(Format(ERROR_NOTFOUND, [Value]))
  else
    SaveLog(Format(EVENT_FOUND, [Value]));

  Surface := D3DXLoadSurfaceFromFile(PChar(Value), 0);

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
end;

function TPicture.LoadFromFile(const FilePicture: string): Boolean;
var
  FileHeader: file of THeaderPicture;
  HeaderPicture: THeaderPicture;
begin
  if Length(FilePicture) = 0 then
    Exit;

  AssignFile(FileHeader, FilePicture);
{$I-}
  Reset(FileHeader);
{$I+}
  if IORESULT <> 0 then
  begin
    CloseFile(FileHeader);
    Exit;
  end;
  Read(FileHeader, HeaderPicture);
  CloseFile(FileHeader);

  FName := HeaderPicture.Name;
  FFileName := HeaderPicture.FilePicture;
  FPatternWidth := HeaderPicture.PatternWidth;
  FPatternHeight := HeaderPicture.PatternHeight;
  FSkipWidth := HeaderPicture.SkipWidth;
  FSkipHeight := HeaderPicture.SkipHeight;
  FTransparentColor := HeaderPicture.TransparentColor;

  SetFileName(FFileName);
end;

function TPicture.SaveToFile(const FilePicture: string): Boolean;
var
  FileHeader: file of THeaderPicture;
  HeaderPicture: THeaderPicture;
begin
  if Length(FilePicture) = 0 then
    Exit;

  AssignFile(FileHeader, FilePicture);
  if FileExists(FilePicture) then
    Reset(FileHeader)
  else
    Rewrite(FileHeader);

  HeaderPicture.Name := FName;
  HeaderPicture.FilePicture := FFileName;
  HeaderPicture.PatternWidth := FPatternWidth;
  HeaderPicture.PatternHeight := FPatternHeight;
  HeaderPicture.SkipWidth := FSkipWidth;
  HeaderPicture.SkipHeight := FSkipHeight;
  HeaderPicture.TransparentColor := FTransparentColor;

  Write(FileHeader, HeaderPicture);
  CloseFile(FileHeader);
end;

function TPictures.IndexOf(Name: string): TPicture;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if GetItem(I).Name = Name then
    begin
      Result := GetItem(I);
      Exit;
    end;
  end;

  Result := nil;
end;

function TPictures.GetItem(Index: Integer): TPicture;
begin
  Result := inherited Items[Index] as TPicture;
end;

function TPictures.Add: TPicture;
begin
  Result := inherited Add as TPicture;
end;

function TPictures.AddEx(FileName: string; Name: string; PatternWidth, PatternHeight: Integer;
  ColorKey: Longint; SkipWidth: Integer = 0; SkipHeight: Integer = 0): TPicture;
begin
  Result := inherited Add as TPicture;

  Result.Name := Name;
  Result.PatternWidth := PatternWidth;
  Result.PatternHeight := PatternHeight;
  Result.SkipWidth := SkipWidth;
  Result.SkipHeight := SkipHeight;
  Result.TransparentColor := ColorKey;

  Result.FileName := FileName;
end;

function TPictures.Find(const Name: string): TPicture;
begin
  Result := IndexOf(Name);
  if Result = nil then
    raise EError.Create(Format(ERROR_NOTFOUND, [Name]));
end;

procedure TButton.DoMouseEnter;
begin
  Style := 1;
end;

procedure TButton.DoMouseLeave;
begin
  Style := 0;
end;

procedure TButton.DoDraw;
begin
  if (Clicked) and (MouseIn) then
    DrawButton(Left, Top, Width, Height, 2, 'Teste')
  else
    DrawButton(Left, Top, Width, Height, Style, 'Teste')
end;

end.

