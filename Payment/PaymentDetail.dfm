inherited frmPaymentDetail: TfrmPaymentDetail
  Caption = 'frmPaymentDetail'
  ClientHeight = 336
  ClientWidth = 539
  OnCreate = FormCreate
  ExplicitWidth = 539
  ExplicitHeight = 336
  PixelsPerInch = 96
  TextHeight = 14
  inherited pnlTitle: TRzPanel
    Width = 539
    ExplicitWidth = 539
    inherited imgClose: TImage
      Left = 518
      ExplicitLeft = 318
    end
    inherited lblCaption: TRzLabel
      Width = 92
      Caption = 'Payment details'
      ExplicitWidth = 92
    end
  end
  inherited pnlMain: TRzPanel
    Width = 539
    Height = 315
    ExplicitWidth = 539
    ExplicitHeight = 315
    object urlLedger: TRzURLLabel [0]
      Tag = 1
      Left = 10
      Top = 287
      Width = 68
      Height = 14
      Caption = 'Open ledger'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 6572079
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = [fsUnderline]
      ParentFont = False
      OnClick = urlLedgerClick
    end
    inherited pnlDetail: TRzPanel
      Width = 522
      Height = 266
      ExplicitWidth = 522
      ExplicitHeight = 266
      inherited pcDetail: TRzPageControl
        Width = 520
        Height = 264
        ExplicitWidth = 520
        ExplicitHeight = 264
        FixedDimension = 20
        inherited tsDetail: TRzTabSheet
          ExplicitWidth = 520
          ExplicitHeight = 264
          object JvLabel1: TJvLabel
            Left = 252
            Top = 55
            Width = 54
            Height = 14
            Caption = 'Loan ID:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -12
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = []
          end
          object JvLabel2: TJvLabel
            Left = 252
            Top = 79
            Width = 35
            Height = 14
            Caption = 'Type:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -12
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = []
          end
          object JvLabel3: TJvLabel
            Left = 252
            Top = 104
            Width = 57
            Height = 14
            Caption = 'Account:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -12
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = []
          end
          object JvLabel4: TJvLabel
            Left = 252
            Top = 128
            Width = 86
            Height = 14
            Caption = 'Loan balance:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -12
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = []
          end
          object lblLoanId: TJvLabel
            Left = 324
            Top = 55
            Width = 32
            Height = 14
            Caption = 'xxxxx'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object lblType: TJvLabel
            Left = 306
            Top = 79
            Width = 32
            Height = 14
            Caption = 'xxxxx'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object lblAccount: TJvLabel
            Left = 324
            Top = 104
            Width = 32
            Height = 14
            Caption = 'xxxxx'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object lblLoanBalance: TJvLabel
            Left = 356
            Top = 128
            Width = 32
            Height = 14
            Caption = 'xxxxx'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object JvLabel5: TJvLabel
            Left = 19
            Top = 55
            Width = 53
            Height = 14
            Caption = 'Principal'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -12
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = []
          end
          object JvLabel6: TJvLabel
            Left = 19
            Top = 120
            Width = 52
            Height = 14
            Caption = 'Interest'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -12
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = []
          end
          object lblTotal: TJvLabel
            Left = 252
            Top = 21
            Width = 162
            Height = 23
            Caption = 'Total amount: 0.00'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = 8675134
            Font.Height = -19
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            Transparent = True
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -19
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = []
          end
          object JvLabel8: TJvLabel
            Left = 19
            Top = 185
            Width = 48
            Height = 14
            Caption = 'Penalty'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            Visible = False
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -12
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = []
          end
          object JvLabel9: TJvLabel
            Left = 120
            Top = 55
            Width = 30
            Height = 14
            Caption = 'Due:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -12
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = []
          end
          object JvLabel10: TJvLabel
            Left = 120
            Top = 120
            Width = 30
            Height = 14
            Caption = 'Due:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -12
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = []
          end
          object urlPrincipalDue: TRzURLLabel
            Tag = 1
            Left = 159
            Top = 55
            Width = 25
            Height = 14
            Caption = '0.00'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clGreen
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = [fsUnderline]
            ParentFont = False
            OnClick = urlPrincipalDueClick
          end
          object urlInterestTotalDue: TRzURLLabel
            Tag = 1
            Left = 159
            Top = 120
            Width = 25
            Height = 14
            Caption = '0.00'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clGreen
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = [fsUnderline]
            ParentFont = False
            OnClick = urlInterestTotalDueClick
          end
          object JvLabel11: TJvLabel
            Left = 252
            Top = 153
            Width = 106
            Height = 14
            Caption = 'Interest balance:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -12
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = []
          end
          object JvLabel12: TJvLabel
            Left = 252
            Top = 180
            Width = 154
            Height = 14
            Caption = 'Due as of payment date:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            WordWrap = True
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -12
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = []
          end
          object lblInterestBalance: TJvLabel
            Left = 372
            Top = 153
            Width = 32
            Height = 14
            Caption = 'xxxxx'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clBlack
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            Transparent = True
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -12
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = []
          end
          object lblInterestDue: TJvLabel
            Left = 412
            Top = 180
            Width = 32
            Height = 14
            Caption = 'xxxxx'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object JvLabel7: TJvLabel
            Left = 252
            Top = 205
            Width = 106
            Height = 14
            Caption = 'Last transaction:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            WordWrap = True
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -12
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = []
          end
          object lblLastTransaction: TJvLabel
            Left = 372
            Top = 205
            Width = 32
            Height = 14
            Caption = 'xxxxx'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object JvLabel13: TJvLabel
            Left = 252
            Top = 229
            Width = 35
            Height = 14
            Caption = 'Days:'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            WordWrap = True
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -12
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = []
          end
          object lblDays: TJvLabel
            Left = 300
            Top = 229
            Width = 32
            Height = 14
            Caption = 'xxxxx'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = []
            ParentFont = False
            Transparent = True
          end
          object lblRemainingAmount: TJvLabel
            Left = 19
            Top = 229
            Width = 147
            Height = 14
            Caption = 'Remaining amount: xxx'
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clRed
            Font.Height = -12
            Font.Name = 'Tahoma'
            Font.Style = [fsBold]
            ParentFont = False
            Transparent = True
            Visible = False
            HotTrackFont.Charset = DEFAULT_CHARSET
            HotTrackFont.Color = clWindowText
            HotTrackFont.Height = -12
            HotTrackFont.Name = 'Tahoma'
            HotTrackFont.Style = []
          end
          object edPrincipal: TRzNumericEdit
            Left = 19
            Top = 75
            Width = 198
            Height = 31
            DisabledColor = clWindow
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -19
            Font.Name = 'Tahoma'
            Font.Style = []
            FrameColor = 8675134
            FrameVisible = True
            FramingPreference = fpCustomFraming
            ParentFont = False
            TabOnEnter = True
            TabOrder = 0
            OnChange = edPrincipalChange
            IntegersOnly = False
            DisplayFormat = '###,###,##0.00'
          end
          object edInterest: TRzNumericEdit
            Left = 19
            Top = 140
            Width = 198
            Height = 31
            Color = 13290239
            DisabledColor = 13290239
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -19
            Font.Name = 'Tahoma'
            Font.Style = []
            FrameColor = 8675134
            FrameVisible = True
            FramingPreference = fpCustomFraming
            ParentFont = False
            TabOrder = 1
            OnChange = edInterestChange
            IntegersOnly = False
            DisplayFormat = '###,###,##0.00'
          end
          object edPenalty: TRzNumericEdit
            Left = 19
            Top = 205
            Width = 198
            Height = 31
            Color = 13290239
            Font.Charset = DEFAULT_CHARSET
            Font.Color = clWindowText
            Font.Height = -19
            Font.Name = 'Tahoma'
            Font.Style = []
            FrameColor = 8675134
            FrameVisible = True
            FramingPreference = fpCustomFraming
            ParentFont = False
            TabOrder = 2
            Visible = False
            OnChange = edPenaltyChange
            IntegersOnly = False
            DisplayFormat = '###,###,##0.00'
          end
          object cbxFullPayment: TRzCheckBox
            Left = 19
            Top = 21
            Width = 88
            Height = 16
            Caption = 'Full payment'
            State = cbUnchecked
            TabOrder = 3
            OnClick = cbxFullPaymentClick
          end
        end
      end
    end
    inherited pnlCancel: TRzPanel
      Left = 480
      Top = 283
      ExplicitLeft = 480
      ExplicitTop = 283
    end
    inherited pnlSave: TRzPanel
      Left = 424
      Top = 283
      ExplicitLeft = 424
      ExplicitTop = 283
      inherited btnSave: TRzShapeButton
        Caption = 'Add'
      end
    end
  end
end
