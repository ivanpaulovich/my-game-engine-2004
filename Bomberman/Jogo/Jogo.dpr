program Jogo;

uses
  glApplication,
  jMain in 'jMain.pas';

begin
  Application.Initialize;
  Application.CreateForm(TWindow1, Window1);
  Application.CreateGraphics(TGraphics1, Graphics1);
  Application.Run;
end.
