unit Main;

interface

uses
  Windows, Messages, SysUtils, Classes, MMSystem,
  glApplication, glWindow, gl3DGraphics, glSound, glError, glSprite, glCanvas, glUtil, glConst,
  D3DX8, {$IFDEF DXG_COMPAT}DirectXGraphics{$ELSE}Direct3D8{$ENDIF};

type

  TWindow1 = class(TWindow)
    FLineLight: array[0..2] of TVertex;
  private
    procedure vai;
  protected
    procedure DoInitialize; override;
    procedure DoCreate; override;
  public
    procedure DoFrame(Sender: TObject; TimeDelta: Single);
    procedure DoIdleFrame(Sender: TObject; TimeDelta: Single);
  end;

  TGraphics1 = class(TGraphics)
    Pictures: TPictureCollection;
  private
    { Private declarations }
  protected
    procedure DoInitialize; override;
  public
    { Public declarations }
  end;

var
  Window1: TWindow1;
  Graphics1: TGraphics1;

implementation

procedure TWindow1.vai;
var
  MatWorld, MatRotation, MatTranslation, MatScale: TD3DXMatrix;
  FX, FY: Single;
begin
  D3DXMatrixIdentity(MatTranslation);

  D3DXMatrixScaling(MatScale, 500, 500, 1.0);
  D3DXMatrixMultiply(MatTranslation, MatTranslation, MatScale);

  D3DXMatrixRotationZ(MatRotation, 0.0);
  D3DXMatrixMultiply(MatWorld, MatTranslation, MatRotation);


  FX := -(Graphics1.Width div 2) + 10;
  FY := (Graphics1.Height div 2) - 500 - 10;

  MatWorld._41 := FX;
  MatWorld._42 := FY;

  Graphics.Device.SetTransform(D3DTS_WORLD, MatWorld);
//  Graphics.Device.SetTexture(0, Texture);
  //Graphics.Device.SetStreamSource(0, Graphics.VertexBuffer, SizeOf(TVertex));
  Graphics.Device.SetVertexShader(D3DFVFVERTEX);
FLineLight[0] := Vertex(D3DXVECTOR3(0.0, 0.0, 0.0), D3DXVECTOR3(0.0, 0.0, 1.0), 0.0, 1.0);
  FLineLight[1] := Vertex(D3DXVECTOR3(0.0, 5000.0, 0.0), D3DXVECTOR3(0.0, 0.0, 1.0), 0.0, 0.0);
  FLineLight[2] := Vertex(D3DXVECTOR3(5000.0, 0.0, 0.0), D3DXVECTOR3(0.0, 0.0, 1.0), 1.0, 1.0);
  if FAiled(Graphics1.Device.DrawPrimitiveUP(D3DPT_LINESTRIP, 2, FLineLight, SizeOf(D3DFVFVERTEX))) then
    Show(Application.Handle, 'Ola', 'Num deu', 0);

  //Graphics.Device.DrawPrimitive(D3DPT_TRIANGLESTRIP, 0, 2);

  Graphics.Device.SetTexture(0, nil);
end;

procedure TWindow1.DoFrame(Sender: TObject; TimeDelta: Single);
begin
  if Window1.Key[VK_F2] then
    Application.Pause;

  Graphics1.Clear;

  Graphics1.BeginScene;

  Canvas.SpriteBegin;
        vai;
  //Canvas.Draw(50, 50, 100, 100, Graphics1.Pictures.Items[0].PatternTextures[0].Image);

 { FLineLight[0] := Vertex(D3DXVECTOR3(0.0, 0.0, 0.0), D3DXVECTOR3(0.0, 0.0, 1.0), 0.0, 1.0);
  FLineLight[1] := Vertex(D3DXVECTOR3(0.0, 5000.0, 0.0), D3DXVECTOR3(0.0, 0.0, 1.0), 0.0, 0.0);
  FLineLight[2] := Vertex(D3DXVECTOR3(5000.0, 0.0, 0.0), D3DXVECTOR3(0.0, 0.0, 1.0), 1.0, 1.0);

  if FAiled(Graphics1.Device.DrawPrimitiveUP(D3DPT_LINESTRIP, 2, FLineLight, SizeOf(D3DFVFVERTEX))) then
    Show(Application.Handle, 'Ola', 'Num deu', 0); { }

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

procedure TWindow1.DoCreate;
begin
  Caption := 'Window IskaTreK';
end;

procedure TGraphics1.DoInitialize;
begin
  Pictures := TPictureCollection.Create;
  Pictures.Add('Media\Plane.bmp', 'Aviao', 64, 64, clBlack);
end;

end.

