program Sprite;

uses
  glApplication, 
  Main in 'Main.pas';

begin
  Application.Initialize;
  Application.CreateForm(TWindow2D, Window2D);
  Application.CreateGraphics(TGraphics2D, Graphics2D);
  Application.Run;
end.
