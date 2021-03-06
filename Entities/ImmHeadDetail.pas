unit ImmHeadDetail;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, BasePopupDetail, RzButton, RzTabs,
  Vcl.StdCtrls, RzLabel, Vcl.Imaging.pngimage, Vcl.ExtCtrls, RzPanel, Vcl.Mask,
  RzEdit, RzDBEdit;

type
  TfrmImmHeadDetail = class(TfrmBasePopupDetail)
    edMiddle: TRzDBEdit;
    edFirstname: TRzDBEdit;
    edLastname: TRzDBEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
  private
    { Private declarations }
  protected
    procedure Save; override;
    procedure Cancel; override;
    procedure BindToObject; override;
    function ValidEntry: boolean; override;
  end;

implementation

uses
  EntitiesData, ImmediateHead, IFinanceDialogs, EntityUtils;

{$R *.dfm}

procedure TfrmImmHeadDetail.BindToObject;
begin
  inherited;

end;

procedure TfrmImmHeadDetail.Cancel;
begin
  inherited;
  immHead.Cancel;
end;

procedure TfrmImmHeadDetail.Save;
begin
  immHead.Save;
end;

function TfrmImmHeadDetail.ValidEntry: boolean;
var
  error: string;
  duplicates: integer;
begin
  if Trim(edLastname.Text) = '' then
    error := 'Please enter a lastname.'
  else if Trim(edFirstname.Text) = '' then
    error := 'Please enter a firstname.'
  else if Trim(edMiddle.Text) = '' then
    error := 'Please enter a middlename.'
  else
  begin
    duplicates := CheckDuplicate(edLastname.Text,edFirstname.Text,edMiddle.Text,false);
    if duplicates > 0 then  error := 'Duplicates found.';
  end;

  Result := error = '';

  if not Result then ShowErrorBox(error);
end;

end.
