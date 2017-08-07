unit AppData;

interface

uses
  System.SysUtils, System.Classes, Data.DB, Data.Win.ADODB, ConnUtil;

type
  TdmApplication = class(TDataModule)
    acMain: TADOConnection;
    spGenId: TADOStoredProc;
    dstUser: TADODataSet;
    acCore: TADOConnection;
    dstConfig: TADODataSet;
    dstClients: TADODataSet;
    dscClients: TDataSource;
    dstLoans: TADODataSet;
    dscLoans: TDataSource;
    dstLocation: TADODataSet;
    dstPayments: TADODataSet;
    dscPayments: TDataSource;
    dstPaymentspayment_id: TStringField;
    dstPaymentsreceipt_no: TStringField;
    dstPaymentspayment_date: TDateTimeField;
    dstPaymentsentity_id: TStringField;
    dstPaymentsloc_code: TStringField;
    dstPaymentscreated_date: TDateTimeField;
    dstPaymentscreated_by: TStringField;
    dstPaymentsref_no: TStringField;
    dstPaymentspost_date: TDateTimeField;
    dstPaymentsname: TStringField;
    dstPaymentstotal_amount: TFMTBCDField;
    dstDuplicate: TADODataSet;
    dscDuplicate: TDataSource;
    dstPaymentspmt_method: TWordField;
    procedure DataModuleCreate(Sender: TObject);
    procedure acMainBeforeConnect(Sender: TObject);
    procedure DataModuleDestroy(Sender: TObject);
    procedure acCoreBeforeConnect(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  dmApplication: TdmApplication;

implementation

{%CLASSGROUP 'System.Classes.TPersistent'}

{$R *.dfm}

procedure TdmApplication.acCoreBeforeConnect(Sender: TObject);
begin
  acCore.ConnectionString := GetConnection('','','',true);
end;

procedure TdmApplication.acMainBeforeConnect(Sender: TObject);
begin
  acMain.ConnectionString := GetConnection('','','');
end;

procedure TdmApplication.DataModuleCreate(Sender: TObject);
begin
  acCore.Open;
end;

procedure TdmApplication.DataModuleDestroy(Sender: TObject);
begin
  acMain.Close;
end;

end.
