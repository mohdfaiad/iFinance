unit DevParams;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, BasePopupDetail, RzButton, RzTabs,
  Vcl.StdCtrls, RzLabel, Vcl.Imaging.pngimage, Vcl.ExtCtrls, RzPanel,
  JvExControls, JvLabel, Vcl.Mask, RzEdit;

type
  TfrmDevParams = class(TfrmBasePopupDetail)
    JvLabel7: TJvLabel;
    dteApplicationDate: TRzDateTimeEdit;
    JvLabel1: TJvLabel;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure Save; override;
    procedure Cancel; override;
    function ValidEntry: boolean; override;
  public
    { Public declarations }
  end;

var
  frmDevParams: TfrmDevParams;

implementation

{$R *.dfm}

uses
  IFinanceGlobal, Posting;

{ TfrmBasePopupDetail1 }

procedure TfrmDevParams.Cancel;
begin
  inherited;

end;

procedure TfrmDevParams.FormCreate(Sender: TObject);
begin
  inherited;
  // initialise controls
  dteApplicationDate.Date := ifn.AppDate;
end;

procedure TfrmDevParams.Save;
var
  LPosting: TPosting;
begin
  ifn.AppDate := dteApplicationDate.Date;
  LPosting := TPosting.Create;
  try
    LPosting.PostInterest;
  finally
    LPosting.Free;
  end;
end;

function TfrmDevParams.ValidEntry: boolean;
begin
  Result := true;
end;

end.