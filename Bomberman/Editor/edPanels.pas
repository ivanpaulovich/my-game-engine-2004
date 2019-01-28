unit edPanels;

interface

uses
  D3DX8, {$IFDEF DXG_COMPAT}DirectXGraphics{$ELSE}Direct3D8{$ENDIF},
  glWindow, glApplication, glGraphics, glCanvas, glError, glConst, glUtil, glSound, glDialogs, glSprite, glControls;

type

  TPanelSprite = class(TControl)
  public
    Index: Integer;
    procedure DoMouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Initialize;
    procedure Draw;
  end;

  TPanelTile = class(TControl)
  public
    Index: Integer;
    procedure DoMouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Initialize;
    procedure Draw;
  end;

var
  IndexPage: Integer;
  MapFocus: Boolean;
  Pictures: TPictures;

implementation

procedure TPanelSprite.DoMouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited DoMouseDown(Button, Shift, X, Y);
  Index := (X - Left) div 16;
  IndexPage := 1;
  MapFocus := False;
end;

procedure TPanelSprite.Initialize;
begin
  Index := 0;
end;

procedure TPanelSprite.Draw;
var
  I: Integer;
  S: TD3DXVector2;
begin
  S := D3DXVector2(Width / 2, 16 / 2);
  Canvas.DrawExP(ClientRect.Left, ClientRect.Top, nil, @S, nil, 0, 255, clWhite, PictureList.Item[0].PatternTextures[1].Image);
  for I := 0 to 1 do
    Canvas.Draw((I * 16) + Left, Top, Pictures.Item[1], I * 10);
end;

procedure TPanelTile.DoMouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  Index := ((X - Left) div 16) + (((Y - Top - 16) div 16) * 0);
  IndexPage := 0;
  MapFocus := False;
end;

procedure TPanelTile.Initialize;
begin
  Index := 0;
end;

procedure TPanelTile.Draw;
var
  I: Integer;
begin
  for I := 0 to 4 do
    Canvas.Draw((I * 16) + Left, Top + 16, Pictures.Item[0], I);
end;

end.

 