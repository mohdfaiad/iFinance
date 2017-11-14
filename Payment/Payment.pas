unit Payment;

interface

uses
  ActiveClient, PaymentMethod, System.Classes, SysUtils, System.Rtti;

type
  TPaymentType = (ptPrincipal,ptInterest,ptPenalty);

  TPaymentDetail = class
  strict private
    FPaymentId: string;
    FPaymentDate: TDateTime;
    FLoan: TLoan;
    FRemarks: string;
    FCancelled: boolean;
    FPrincipal: real;
    FInterest: real;
    FPenalty: real;
    FPaymentType: TPaymentType;

    function GetTotalAmount: real;
    function GetHasInterest: boolean;
    function GetHasPrincipal: boolean;
    function GetPenalty: boolean;
    function PostInterest(const interest: real; const loanId: string;
      const ADate: TDateTime; const source, status: string): string;

    procedure SaveInterest;

  public
    property Loan: TLoan read FLoan write FLoan;
    property TotalAmount: real read GetTotalAmount;
    property Remarks: string read FRemarks write FRemarks;
    property Cancelled: boolean read FCancelled write FCancelled;
    property Principal: real read FPrincipal write FPrincipal;
    property Interest: real read FInterest write FInterest;
    property Penalty: real read FPenalty write FPenalty;
    property HasPrincipal: boolean read GetHasPrincipal;
    property HasInterest: boolean read GetHasInterest;
    property HasPenalty: boolean read GetPenalty;
    property PaymentType: TPaymentType read FPaymentType write FPaymentType;
    property PaymentId: string read FPaymentId write FPaymentId;
    property PaymentDate: TDateTime read FPaymentDate write FPaymentDate;

    function PaymentTypeToString(const payType: TPaymentType): string;
    function IsScheduled(const paymentDate: TDateTime): boolean;
    function IsAdvanced(const paymentDate: TDateTime): boolean;
    function IsLate(const paymentDate: TDateTime): boolean;

    procedure Post;
  end;

  TPayment = class
  private
    FClient: TActiveClient;
    FPaymentId: string;
    FReceiptNo: string;
    FDate: TDateTime;
    FDetails: array of TPaymentDetail;
    FPostDate: TDateTime;
    FReferenceNo: string;
    FLocationCode: string;
    FPaymentMethod: TPaymentMethod;
    FWithdrawn: real;
    FWithdrawalId: string;

    procedure SaveDetails;
    procedure UpdateLoanRecord;

    function GetDetail(const i: integer): TPaymentDetail;
    function GetTotalAmount: real;
    function GetDetailCount: integer;
    function GetIsPosted: boolean;
    function GetIsNew: boolean;
    function GetIsWithdrawal: boolean;
    function GetIsAdvance: boolean;
    function GetIsLate: boolean;

  public
    property Client: TActiveClient read FClient write FClient;
    property PaymentId: string read FPaymentId write FPaymentId;
    property ReceiptNo: string read FReceiptNo write FReceiptNo;
    property Date: TDateTime read FDate write FDate;
    property Details[const i: integer]: TPaymentDetail read GetDetail;
    property TotalAmount: real read GetTotalAmount;
    property DetailCount: integer read GetDetailCount;
    property PostDate: TDateTime read FPostDate write FPostDate;
    property ReferenceNo: string read FReferenceNo write FReferenceNo;
    property IsPosted: boolean read GetIsPosted;
    property LocationCode: string read FLocationCode write FLocationCode;
    property IsNew: boolean read GetIsNew;
    property PaymentMethod: TPaymentMethod read FPaymentMethod write FPaymentMethod;
    property Withdrawn: real read FWithdrawn write FWithdrawn;
    property WithdrawalId: string read FWithdrawalId write FWithdrawalId;
    property IsWithdrawal: boolean read GetIsWithdrawal;
    property IsAdvance: boolean read GetIsAdvance;
    property IsLate: boolean read GetIsLate;

    procedure Add;
    procedure AddDetail(const detail: TPaymentDetail);
    procedure RemoveDetail(const loan: TLoan);
    procedure Save;
    procedure Retrieve;

    function DetailExists(const loan: TLoan): boolean;

    constructor Create;
    destructor Destroy; reintroduce;
  end;

var
  pmt: TPayment;

implementation

uses
  PaymentData, IFinanceDialogs, DBUtil, Posting, IFinanceGlobal, Ledger, AppConstants;

constructor TPayment.Create;
begin
  if pmt <> nil then pmt := self
  else begin
    inherited Create;
    FPaymentMethod := TPaymentMethod.Create;
  end;
end;

destructor TPayment.Destroy;
begin
  if pmt = self then pmt := nil;
end;

procedure TPayment.Add;
begin
  with dmPayment do
  begin
    dstPayment.Open;
    dstPayment.Append;
  end;
end;

procedure TPayment.AddDetail(const detail: TPaymentDetail);
begin
  SetLength(FDetails,Length(FDetails)+1);
  FDetails[Length(FDetails)-1] := detail;
end;

procedure TPayment.RemoveDetail(const loan: TLoan);
var
  i, ii, len: integer;
  detail: TPaymentDetail;
begin
  len := Length(FDetails);

  ii := 0;
  for i := 0 to len - 1 do
  begin
    detail := FDetails[i];
    if detail.Loan.Id <> loan.Id then
    begin
      FDetails[ii] := detail;
      Inc(ii);
    end;
  end;

  SetLength(FDetails,Length(FDetails) - 1);
end;

procedure TPayment.Save;
var
  LPosting: TPosting;
begin
  LPosting := TPosting.Create;
  try
    try
      with dmPayment do
      begin
        dstPayment.Post;

        SaveDetails;

        LPosting.Post(self);

        dstPayment.UpdateBatch;
        dstPaymentDetail.UpdateBatch;
        dstInterest.UpdateBatch;

        UpdateLoanRecord;
      end;
    except
      on E: Exception do begin
        dmPayment.dstPayment.CancelBatch;
        dmPayment.dstPaymentDetail.CancelBatch;
        dmPayment.dstInterest.CancelBatch;

        ShowErrorBox('An error has occured during payment posting. Entry has been cancelled.');
      end;
    end;
  finally
    LPosting.Free;
  end;
end;

procedure TPayment.SaveDetails;
var
  i, cnt: integer;
begin
  with dmPayment.dstPaymentDetail do
  begin
    cnt := GetDetailCount - 1;

    Open;

    for i := 0 to cnt do
    begin
      FDetails[i].PaymentId := FPaymentId;
      FDetails[i].PaymentDate := FDate;

      // principal
      if FDetails[i].HasPrincipal then
      begin
        Append;
        FieldByName('payment_id').AsString := FPaymentId;
        FieldByName('loan_id').AsString := FDetails[i].Loan.Id;
        FieldByName('payment_amt').AsFloat := FDetails[i].Principal;
        FieldByName('payment_type').AsString := FDetails[i].PaymentTypeToString(ptPrincipal);
        FieldByName('remarks').AsString := FDetails[i].Remarks;
        Post;
      end;

      // interest
      if FDetails[i].HasInterest then
      begin
        Append;
        FieldByName('payment_id').AsString := FPaymentId;
        FieldByName('loan_id').AsString := FDetails[i].Loan.Id;
        FieldByName('payment_amt').AsFloat := FDetails[i].Interest;
        FieldByName('payment_type').AsString := FDetails[i].PaymentTypeToString(ptInterest);
        FieldByName('remarks').AsString := FDetails[i].Remarks;
        Post;
      end;

      // penalty
      if FDetails[i].HasPenalty then
      begin
        Append;
        FieldByName('payment_id').AsString := FPaymentId;
        FieldByName('loan_id').AsString := FDetails[i].Loan.Id;
        FieldByName('payment_amt').AsFloat := FDetails[i].Penalty;
        FieldByName('payment_type').AsString := FDetails[i].PaymentTypeToString(ptPenalty);
        FieldByName('remarks').AsString := FDetails[i].Remarks;
        Post;
      end;

      FDetails[i].Post;
    end;

  end;
end;

procedure TPayment.UpdateLoanRecord;
var
  detail: TPaymentDetail;
  sql: string;
  balance: real;
begin
  // update the principal balance (field loan_balance)
  // update the last transaction date

  try
    for detail in FDetails do
    begin
      balance := detail.Loan.Balance - detail.Principal;
      
      sql := ' UPDATE loan ' +
             '    SET balance = ' + FloatToStr(balance) + ',' +
             '        last_trans_date = ' + QuotedStr(FormatDateTime('mm/dd/yyyy',FDate)) +
             '  WHERE loan_id = ' + QuotedStr(detail.Loan.Id);
    end;
    
    ExecuteSQL(sql);
  except
    on E: Exception do ShowErrorBox(E.Message);
  end;
end;

procedure TPayment.Retrieve;
var
  detail: TPaymentDetail;
  loan: TLoan;
  currentLoanId: string;
begin
  // head
  with dmPayment.dstPayment do
  begin
    Close;
    Open;
  end;

  // detail
  with dmPayment.dstPaymentDetail do
  begin
    Close;
    Open;

    while not Eof do
    begin
      // loan details..instantiate for every loan ID.. NOT for every row
      // Reason: each detail will contain the PRINCIPAL, INTEREST and PENALTY amounts
      if (not Assigned(loan)) or (loan.Id <> currentLoanId) then
      begin
        loan := TLoan.Create;
        loan.Id := FieldByName('loan_id').AsString;
        loan.LoanTypeName := FieldByName('loan_type_name').AsString;
        loan.AccountTypeName := FieldByName('acct_type_name').AsString;
        loan.Balance := FieldByName('balance').AsFloat;

        detail := TPaymentDetail.Create;
        detail.Loan := loan;
        detail.Remarks := FieldByName('remarks').AsString;
        detail.Cancelled := FieldByName('is_cancelled').AsInteger = 1;
      end;

      // set principal, interest, penalty
      if FieldByName('payment_type').AsString = 'PRN' then
        detail.Principal := FieldByName('payment_amt').AsFloat
      else if FieldByName('payment_type').AsString = 'INT' then
        detail.Interest := FieldByName('payment_amt').AsFloat
      else if FieldByName('payment_type').AsString = 'PEN' then
        detail.Penalty := FieldByName('payment_amt').AsFloat;

      Next;

      currentLoanId := FieldByName('loan_id').AsString;

      if (Eof) or (loan.Id <> currentLoanId) then AddDetail(detail);
    end;
  end;
end;

function TPayment.GetDetail(const i: Integer): TPaymentDetail;
begin
  Result := FDetails[i];
end;

function TPayment.GetTotalAmount: real;
var
  pd: TPaymentDetail;
begin
  Result := 0;

  for pd in FDetails do Result := Result + pd.Principal + pd.Interest + pd.Penalty;
end;

function TPayment.DetailExists(const loan: TLoan): boolean;
var
  pd: TPaymentDetail;
begin
  Result := false;
  for pd in FDetails do
  begin
    if pd.Loan.Id = loan.Id then
    begin
      Result := true;
      Exit;
    end;
  end;
end;

function TPayment.GetDetailCount: integer;
begin
  Result := Length(FDetails);
end;

function TPayment.GetIsPosted: boolean;
begin
  Result := FPostDate > 0;
end;

function TPayment.GetIsWithdrawal: boolean;
begin
  Result := FPaymentMethod.Method = mdBankWithdrawal;
end;

function TPayment.GetIsAdvance: boolean;
begin
  Result := FDate < ifn.AppDate;
end;

function TPayment.GetIsLate: boolean;
begin
  Result := FDate > ifn.AppDate;
end;

function TPayment.GetIsNew: boolean;
begin
  Result := FPaymentId = '';
end;

function TPaymentDetail.GetHasInterest: boolean;
begin
  Result := FInterest > 0;
end;

function TPaymentDetail.GetHasPrincipal: boolean;
begin
  Result := FPrincipal > 0;
end;

function TPaymentDetail.GetPenalty: boolean;
begin
  Result := FPenalty > 0;
end;

function TPaymentDetail.GetTotalAmount: real;
begin
  Result := FPrincipal + FInterest + FPenalty;
end;

function TPaymentDetail.IsAdvanced(const paymentDate: TDateTime): boolean;
begin
  Result := paymentDate < FLoan.NextPayment;
end;

function TPaymentDetail.IsLate(const paymentDate: TDateTime): boolean;
begin
  Result := paymentDate > FLoan.NextPayment;
end;

function TPaymentDetail.IsScheduled(const paymentDate: TDateTime): boolean;
begin
  Result := paymentDate = FLoan.NextPayment;
end;

function TPaymentDetail.PaymentTypeToString(
  const payType: TPaymentType): string;
begin
  case payType of
    ptPrincipal: Result := 'PRN';
    ptInterest: Result := 'INT';
    ptPenalty: Result := 'PEN';
  end;
end;

procedure TPaymentDetail.Post;
var
  debitLedger, creditLedger: TLedger;
  balance, debit, credit, payment: single;
  i, cnt: integer;
  caseType: string;
  paymentType: TPaymentTypes;
begin
  //  post the payment in the ledger
  for paymentType := TPaymentTypes.PRN to TPaymentTypes.PEN do
  begin

    // get the amount and casetype to be posted
    case paymentType of
      PRN:
        begin
          caseType :=  TRttiEnumerationType.GetName<TCaseTypes>(TCaseTypes.PRC);
          payment := FPrincipal;
        end;

      INT:
        begin
          caseType :=  TRttiEnumerationType.GetName<TCaseTypes>(TCaseTypes.ITS);
          payment := FInterest;

          // save unposted interest
          SaveInterest;
        end;

      PEN:
        begin
          caseType :=  TRttiEnumerationType.GetName<TCaseTypes>(TCaseTypes.PNT);
          payment := FPenalty;
        end;

    end;

    i := 0;
    cnt := FLoan.LedgerCount - 1;
    balance := payment;

    while (balance > 0) and (i <= cnt) do
    begin
      debitLedger := FLoan.Ledger[i];

      if (debitLedger.ValueDate <= FPaymentDate) and
        (debitLedger.CaseType = caseType) then
      begin
        creditLedger := TLedger.Create;

        // set the amount and the status
        if debitLedger.Debit <= balance then
        begin
          creditLedger.Credit := debitLedger.Debit;

          if debitLedger.Debit = balance then
            debitLedger.NewStatus := TRttiEnumerationType.GetName<TLedgerRecordStatus>(TLedgerRecordStatus.CLS);
        end
        else creditLedger.Credit := balance;

        creditLedger.RefPostingId := debitLedger.PostingId;
        creditLedger.EventObject := TRttiEnumerationType.GetName<TEventObjects>(TEventObjects.PAY);
        creditLedger.PrimaryKey := FPaymentId;
        creditLedger.CaseType := caseType;
        creditLedger.ValueDate := FPaymentDate;
        creditLedger.CurrentStatus := TRttiEnumerationType.GetName<TLedgerRecordStatus>(TLedgerRecordStatus.OPN);
        creditLedger.NewStatus := TRttiEnumerationType.GetName<TLedgerRecordStatus>(TLedgerRecordStatus.OPN);
        creditLedger.Debit := 0;

        FLoan.AddLedger(creditLedger);

        balance := debitLedger.Debit - creditLedger.Credit;
      end;

      Inc(i);
    end;
  end;

end;

function TPaymentDetail.PostInterest(const interest: real; const loanId: string;
  const ADate: TDateTime; const source, status: string): string;
var
  interestId: string;
begin
  interestId := GetInterestId;

  with dmPayment.dstInterest do
  begin
    Append;
    FieldByName('interest_id').AsString := interestId;
    FieldByName('loan_id').AsString := loanId;
    FieldByName('interest_amt').AsCurrency := interest;
    FieldByName('interest_date').AsDateTime := ADate;
    FieldByName('interest_src').AsString := source;
    FieldByName('interest_status_id').AsString := status;
    Post;
  end;

  Result := interestId;
end;

procedure TPaymentDetail.SaveInterest;
var
  LLedger: TLedger;
  i, cnt: integer;
  interestId, loanId, source, status: string;
  interest: single;
  interestDate: TDateTime;
begin
  try
    cnt := FLoan.LedgerCount - 1;

    for i := 0 to cnt do
    begin
      if (LLedger.EventObject = TRttiEnumerationType.GetName<TEventObjects>(TEventObjects.ITR))
         and (LLedger.CaseType = TRttiEnumerationType.GetName<TCaseTypes>(TCaseTypes.ITS))then
      begin
        if not LLedger.Posted then
        begin
          interest := LLedger.Debit;
          loanId := FLoan.Id;
          interestDate := LLedger.ValueDate;
          source := TRttiEnumerationType.GetName<TInterestSource>(TInterestSource.PYT);
          status := TRttiEnumerationType.GetName<TInterestStatus>(TInterestStatus.T);

          interestId := PostInterest(interest,loanId,interestDate,source,status);
          LLedger.PrimaryKey := interestId;
        end;
      end;
    end;
  finally
  end;

end;

end.
