program dts;

{%File 'db\dts-sp.sql'}
{%File 'db\dts-schema.sql'}
{%File 'db\piss-data.txt'}
{%File 'db\dts-triggers.sql'}

uses
  Forms,
  main in 'main.pas' {FormMain},
  data_module in 'data_module.pas' {dm: TDataModule},
  login in 'login.pas' {FormLogin},
  shared in 'shared.pas',
  loginas in 'loginas.pas' {FormLoginAs},
  ticket in 'ticket.pas' {FormTicket},
  comment in 'comment.pas' {FormComment};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFormLogin, FormLogin);
  Application.CreateForm(TFormMain, FormMain);
  Application.CreateForm(Tdm, dm);
  Application.CreateForm(TFormLoginAs, FormLoginAs);
  Application.CreateForm(TFormTicket, FormTicket);
  Application.CreateForm(TFormComment, FormComment);
  Application.Run;
end.
