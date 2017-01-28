inherited frmEmployerList: TfrmEmployerList
  Caption = 'frmEmployerList'
  PixelsPerInch = 96
  TextHeight = 14
  inherited pnlTitle: TRzPanel
    inherited lblTitle: TRzLabel
      Width = 78
      Caption = 'Employer list'
      ExplicitWidth = 78
    end
  end
  inherited pnlList: TRzPanel
    inherited grList: TRzDBGrid
      DataSource = dmEntities.dscEmployers
      Columns = <
        item
          Expanded = False
          FieldName = 'emp_name'
          Title.Alignment = taCenter
          Title.Caption = 'Name'
          Width = 400
          Visible = True
        end>
    end
  end
  inherited pcDetail: TRzPageControl
    Visible = False
    FixedDimension = 20
    inherited tsDetail: TRzTabSheet
      Caption = 'Employer details'
    end
  end
  inherited pnlDetail: TRzPanel
    object JvLabel1: TJvLabel [0]
      Left = 13
      Top = 39
      Width = 33
      Height = 14
      Caption = 'Name'
      Transparent = True
    end
    object JvLabel2: TJvLabel [1]
      Left = 13
      Top = 118
      Width = 35
      Height = 14
      Caption = 'Group'
      Transparent = True
    end
    object JvLabel3: TJvLabel [2]
      Left = 13
      Top = 63
      Width = 45
      Height = 14
      Caption = 'Address'
      Transparent = True
    end
    inherited pnlAdd: TRzPanel
      TabOrder = 3
    end
    inherited pnlDetailHead: TRzPanel
      TabOrder = 4
    end
    object dbluGroup: TRzDBLookupComboBox
      Left = 63
      Top = 112
      Width = 201
      Height = 22
      DataField = 'grp_id'
      DataSource = dmEntities.dscEmployers
      KeyField = 'grp_id'
      ListField = 'grp_name'
      ListSource = dmEntities.dscGroups
      TabOrder = 2
      FlatButtonColor = 8675134
      FlatButtons = True
      DisabledColor = clWhite
      FrameColor = 8675134
      FrameHotColor = clBlack
      FrameVisible = True
      FramingPreference = fpCustomFraming
      TabOnEnter = True
    end
    object edEmployerName: TRzDBEdit
      Left = 63
      Top = 33
      Width = 201
      Height = 22
      DataSource = dmEntities.dscEmployers
      DataField = 'emp_name'
      CharCase = ecUpperCase
      DisabledColor = clWhite
      FrameColor = 8675134
      FrameVisible = True
      FramingPreference = fpCustomFraming
      TabOnEnter = True
      TabOrder = 0
    end
    object RzDBMemo1: TRzDBMemo
      Left = 63
      Top = 57
      Width = 201
      Height = 53
      DataField = 'emp_add'
      DataSource = dmEntities.dscEmployers
      TabOrder = 1
      DisabledColor = clWhite
      FrameColor = 8675134
      FrameVisible = True
      FramingPreference = fpCustomFraming
      TabOnEnter = True
    end
  end
end
