program Editor;

uses
  brForms,
  brMain in 'brMain.pas',
  brActors in 'brActors.pas';

{$R resource.res}

begin
  Application.Initialize;
  Application.CreateForm(TWindow1, Window1);
  Application.CreateGraphics(TGraphics1, Graphics1);
  Application.Run;
end.
