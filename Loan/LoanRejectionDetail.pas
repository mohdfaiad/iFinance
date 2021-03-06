unit LoanRejectionDetail;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, BasePopupDetail, Vcl.StdCtrls, Vcl.Mask,
  RzEdit, RzDBEdit, Vcl.DBCtrls, RzDBCmbo, RzButton, RzTabs, RzLabel,
  Vcl.Imaging.pngimage, Vcl.ExtCtrls, RzPanel;

type
  TfrmLoanRejectionDetail = class(TfrmBasePopupDetail)
    dteDateRejected: TRzDBDateTimeEdit;
    dbluReason: TRzDBLookupComboBox;
    mmRemarks: TRzDBMemo;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  protected
    procedure Save; override;
    procedure Cancel; override;
    procedure BindToObject; override;
    function ValidEntry: boolean; override;
  end;

implementation

{$R *.dfm}

uses
  LoanData, FormsUtil, Loan, LoansAuxData, IFinanceDialogs;

procedure TfrmLoanRejectionDetail.Save;
begin
  ln.Save;
end;

procedure TfrmLoanRejectionDetail.BindToObject;
begin
  inherited;

end;

procedure TfrmLoanRejectionDetail.Cancel;
begin
  ln.Cancel;
end;

function TfrmLoanRejectionDetail.ValidEntry: boolean;
var
  error: string;
begin
  if dteDateRejected.Text = '' then
    error := 'Please enter date rejected.'
  else if dbluReason.Text = '' then
    error := 'Please select reject reason.';

  Result := error = '';

  if not Result then ShowErrorBox(error);
end;

procedure TfrmLoanRejectionDetail.FormCreate(Sender: TObject);
begin
  inherited;
  OpenDropdownDataSources(tsDetail);
end;

end.
