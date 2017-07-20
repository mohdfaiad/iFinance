unit LoanClassification;

interface

uses
  LoanClassCharge, LoanType, LoansAuxData, Group;

type TLoanClassAction = (lcaNone, lcaCreating, lcaActivating, lcaDeactivating);

type
  TLoanClassification = class
  private
    FClassificationId: integer;
    FGroup: TGroup;
    FClassificationName: string;
    FInterest: real;
    FTerm: integer;
    FLoanType: TLoanType;
    FMaxLoan: real;
    FComakers: integer;
    FValidFrom: TDate;
    FValidUntil: TDate;
    FClassCharges: array of TLoanClassCharge;
    FMaxAge: integer;
    FAction: TLoanClassAction;

    function GetComakersNotRequired: boolean;
    function GetClassCharge(const i: integer): TLoanClassCharge;
    function GetClassChargesCount: integer;
    function GetHasMaxAge: boolean;
    function GetHasConcurrent: boolean;
    function GetIsActive: boolean;
    function GetIsActivated: boolean;
    function GetIsDeactivated: boolean;

  public
    procedure Add;
    procedure Save;
    procedure AppendCharge;

    procedure AddClassCharge(cg: TLoanClassCharge);
    procedure RemoveClassCharge(const cgType: string);
    procedure EmptyClassCharges;

    function ClassChargeExists(const cgType: string;
        const forNew, forRenewal, forRestructure, forReloan: boolean): boolean;

    property ClassificationId: integer read FClassificationId write FClassificationId;
    property Group: TGroup read FGroup write FGroup;
    property ClassificationName: string read FClassificationName write FClassificationName;
    property Interest: real read FInterest write FInterest;
    property Term: integer read FTerm write FTerm;
    property LoanType: TLoanType read FLoanType write FLoanType;
    property MaxLoan: real read FMaxLoan write FMaxLoan;
    property Comakers: integer read FComakers write FComakers;
    property ValidFrom: TDate read FValidFrom write FVAlidFrom;
    property ValidUntil: TDate read FValidUntil write FValidUntil;
    property ComakersNotRequired: boolean read GetComakersNotRequired;
    property ClassCharge[const i: integer]: TLoanClassCharge read GetClassCharge;
    property ClassChargesCount: integer read GetClassChargesCount;
    property MaxAge: integer read FMaxAge write FMaxAge;
    property HasMaxAge: boolean read GetHasMaxAge;
    property HasConcurrent: boolean read GetHasConcurrent;
    property IsActive: boolean read GetIsActive;
    property IsActivated: boolean read GetIsActivated;
    property IsDeactivated: boolean read GetIsDeactivated;
    property Action: TLoanClassAction read FAction write FAction;

    constructor Create(const classificationId: integer; classificationName: string;
        const interest: real; const term: integer; const maxLoan: real;
        const comakers: integer; const validFrom, validUntil: TDate; const age: integer;
        const lt: TLoanType; const gp: TGroup);
  end;

var
  lnc: TLoanClassification;

implementation

uses
  IFinanceGlobal;

constructor TLoanClassification.Create(const classificationId: integer; classificationName: string;
        const interest: real; const term: integer; const maxLoan: real;
        const comakers: integer; const validFrom, validUntil: TDate; const age: integer;
        const lt: TLoanType; const gp: TGroup);
begin
  FClassificationId := classificationId;
  FClassificationName := classificationName;
  FInterest := interest;
  FTerm := term;
  FMaxLoan := maxLoan;
  FComakers := comakers;
  FValidFrom := validFrom;
  FValidUntil := validUntil;
  FMaxAge := age;
  FLoanType := lt;
  FGroup := gp;

  // set action
  if IsActive then FAction := lcaNone
  else FAction := lcaCreating;
end;

procedure TLoanClassification.AddClassCharge(cg: TLoanClassCharge);
begin
  if not ClassChargeExists(cg.ChargeType,cg.ForNew,cg.ForRenewal,cg.ForRestructure,cg.ForReloan) then
  begin
    SetLength(FClassCharges,Length(FClassCharges) + 1);
    FClassCharges[Length(FClassCharges) - 1] := cg;
  end;
end;

procedure TLoanClassification.RemoveClassCharge(const cgType: string);
var
  i, len: integer;
  cg: TLoanClassCharge;
begin
  len := Length(FClassCharges);

  for i := 0 to len - 1 do
  begin
    cg := FClassCharges[i];
    if cg.ChargeType <> cgType then
      FClassCharges[i] := cg;
  end;

  SetLength(FClassCharges,Length(FClassCharges) - 1);
end;

procedure TLoanClassification.EmptyClassCharges;
begin
  FClassCharges := [];
end;

procedure TLoanClassification.Add;
begin

end;

procedure TLoanClassification.Save;
begin

end;

procedure TLoanClassification.AppendCharge;
begin

end;

function TLoanClassification.GetComakersNotRequired: boolean;
begin
  Result := FComakers = 0;
end;

function TLoanClassification.GetClassCharge(const i: Integer): TLoanClassCharge;
begin
  Result := FClassCharges[i];
end;

function TLoanClassification.ClassChargeExists(const cgType: string;
  const forNew, forRenewal, forRestructure, forReloan: boolean): boolean;
var
  i, len: integer;
  ch: TLoanClassCharge;
begin
  Result := false;

  len := Length(FClassCharges);

  for i := 0 to len - 1 do
  begin
    ch := FClassCharges[i];
    if ch.ChargeType = cgType then
    begin
      if (ch.ForNew = forNew) or (ch.ForRenewal = forRenewal) or
         (ch.ForRestructure = forRestructure) or (ch.ForReloan = forReloan) then
      begin
        Result := true;
        Exit;
      end;
    end;
  end;
end;

function TLoanClassification.GetClassChargesCount: integer;
begin
  Result := Length(FClassCharges);
end;

function TLoanClassification.GetHasMaxAge: boolean;
begin
  Result := FMaxAge > 0;
end;

function TLoanClassification.GetHasConcurrent: boolean;
begin
  Result := FGroup.Attributes.MaxConcurrent > 0;
end;

function TLoanClassification.GetIsActive: boolean;
begin
  Result := (FValidFrom <> 0) and
            ((FValidFrom > ifn.AppDate) and (FValidUntil < ifn.AppDate));
end;

function TLoanClassification.GetIsActivated: boolean;
begin
  Result := (FValidFrom <> 0)
end;

function TLoanClassification.GetIsDeactivated: boolean;
begin
  Result := (FValidUntil <> 0)
end;

end.
