unit process;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Buttons, ExtCtrls;

type
  TFormProcess = class(TForm)
    TabControl1: TTabControl;
    lsvRIVtransactions: TListView;
    Label2: TLabel;
    MemoRemarks: TMemo;
    Deny: TBitBtn;
    BitBtn2: TBitBtn;
    TabControl2: TTabControl;
    lsvRIV: TListView;
    led_status: TLabeledEdit;
    Approve: TBitBtn;
    procedure transactionsRefresh;
    procedure FormShow(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure DenyClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    NewItem : TListItem;
    riv_id : integer;
    riv_no, riv_rights, riv_description : string;
    current_flow_id : integer;
  end;

var
  FormProcess: TFormProcess;

implementation

{$R *.dfm}

uses data_module, main, login, DB;

procedure TFormProcess.transactionsRefresh;
begin
    current_flow_id := 0;
    if dm.ibt.InTransaction then
        dm.ibt.Commit
    else
        dm.ibt.StartTransaction;

    dm.ibq.SQL.Clear;
    dm.ibq.SQL.Add('select * from SELECT_RIV_TRANSACTIONS(:a)');
    dm.ibq.Params[0].AsInteger := riv_id;
    dm.ibq.Open;

    lsvRIVtransactions.Items.BeginUpdate;
    lsvRIVtransactions.Items.Clear;
    while not dm.ibq.Eof do begin
        NewItem := lsvRIVtransactions.Items.Add;
        NewItem.Caption := dm.ibq.Fields.Fields[1].AsString;
        NewItem.SubItems.Add(dm.ibq.Fields.Fields[0].AsString);
        if dm.ibq.Fields.Fields[2].AsString = '1' then
        begin
            NewItem.Checked := True;
            current_flow_id := dm.ibq.Fields.Fields[0].AsInteger; // if we use a SP we dont need this anymore
        end
        else
            NewItem.Checked := False;
        NewItem.SubItems.Add(dm.ibq.Fields.Fields[3].AsString);
        NewItem.SubItems.Add(dm.ibq.Fields.Fields[4].AsString);
        NewItem.SubItems.Add(dm.ibq.Fields.Fields[5].AsString);
        dm.ibq.Next;
    end;
    lsvRIVtransactions.Items.EndUpdate;

    if dm.ibt.InTransaction then
        dm.ibt.Commit;

    led_status.Text := lsvRIV.Items.Item[current_flow_id].Caption;



    if dm.ibt.InTransaction then
        dm.ibt.Commit
    else
        dm.ibt.StartTransaction;

    dm.ibq.SQL.Clear;
    dm.ibq.SQL.Add('select * from select_current_transaction(:a)');
    dm.ibq.Params[0].AsInteger := riv_id;
    dm.ibq.Open;
    while not dm.ibq.Eof do begin
        current_flow_id := dm.ibq.Fields.Fields[0].AsInteger;

        dm.ibq.Next;
    end;
    



end;

procedure TFormProcess.FormShow(Sender: TObject);
begin
    transactionsRefresh;
    FormProcess.Caption := FormProcess.Caption + ' - ' + riv_no + ' (' + riv_description + ')';
end;


procedure TFormProcess.BitBtn2Click(Sender: TObject);
begin
    Close;
end;

procedure TFormProcess.DenyClick(Sender: TObject);
var action : integer;
begin
    if Sender = Approve then
        action := 1
    else if Sender = Deny then
        action := 0;

    // todo check user rights before running the SP




    if dm.ibt.InTransaction then
        dm.ibt.Commit
    else
        dm.ibt.StartTransaction;

    dm.ibq.SQL.Clear;

    dm.ibq.SQL.Add('execute procedure update_flow_data(:id, :b, :c, :d, :e, :f, :g, :h, :i)');
    dm.ibq.Params[0].AsInteger := 0;                      // id  if 0 > generate_id
    dm.ibq.Params[1].AsString := 'RIV';                   // ftype
    dm.ibq.Params[2].AsInteger := riv_id;                 // riv_id
    dm.ibq.Params[3].AsInteger := current_flow_id + 1;    // flow_id
    dm.ibq.Params[4].AsInteger := action;                 // approved
    dm.ibq.Params[5].AsString := FormLogin.user_id;       // approved_by
    dm.ibq.Params[6].AsDateTime := Now;                   // lastupdate
    if MemoRemarks.Lines.Text = '' then
        if action = 1 then
            dm.ibq.Params[7].AsString := 'Approved'
        else
            dm.ibq.Params[7].AsString := 'Denied'
    else
        dm.ibq.Params[7].AsString := MemoRemarks.Lines.Text;
    dm.ibq.Params[8].AsDateTime := Now;

    dm.ibq.Prepare;
    dm.ibq.ExecSQL;
    if dm.ibt.InTransaction then
        dm.ibt.Commit;

    transactionsRefresh;

end;

end.
