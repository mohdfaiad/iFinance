object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'i-Finance - Integrated Financial Managment Information System'
  ClientHeight = 592
  ClientWidth = 1074
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  Menu = mmMain
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 13
  object pnlNavbar: TPanel
    Left = 0
    Top = 30
    Width = 185
    Height = 543
    Align = alLeft
    BevelOuter = bvNone
    BorderWidth = 1
    TabOrder = 0
    object npMain: TJvNavigationPane
      Left = 1
      Top = 1
      Width = 183
      Height = 541
      ActivePage = nppClient
      Align = alClient
      AutoHeaders = True
      Background.Stretch = False
      Background.Proportional = False
      Background.Center = False
      Background.Tile = False
      Background.Transparent = False
      Colors.ButtonColorFrom = 8806462
      Colors.ButtonColorTo = 12626063
      Colors.ButtonHotColorFrom = 4235263
      Colors.ButtonHotColorTo = 5220351
      Colors.ButtonSelectedColorFrom = 4235263
      Colors.ButtonSelectedColorTo = 5220351
      Colors.ButtonSeparatorColor = clBlack
      Colors.SplitterColorFrom = 5849128
      Colors.SplitterColorTo = 8677194
      Colors.HeaderColorFrom = 8806462
      Colors.HeaderColorTo = 11110503
      Colors.FrameColor = clBlack
      Colors.ToolPanelColorFrom = clBlack
      Colors.ToolPanelColorTo = clBlack
      Colors.ToolPanelHeaderColorFrom = 8806462
      Colors.ToolPanelHeaderColorTo = 11110503
      MaximizedCount = 5
      NavPanelFont.Charset = ANSI_CHARSET
      NavPanelFont.Color = clBlack
      NavPanelFont.Height = -11
      NavPanelFont.Name = 'Tahoma'
      NavPanelFont.Style = [fsBold]
      NavPanelHotTrackFont.Charset = ANSI_CHARSET
      NavPanelHotTrackFont.Color = clBlack
      NavPanelHotTrackFont.Height = -11
      NavPanelHotTrackFont.Name = 'Tahoma'
      NavPanelHotTrackFont.Style = [fsBold]
      NavPanelHotTrackFontOptions = [hoPreserveColor, hoPreserveStyle]
      object nppClient: TJvNavPanelPage
        Left = 0
        Top = 0
        Width = 181
        Height = 364
        Hint = ''
        Background.Stretch = False
        Background.Proportional = False
        Background.Center = False
        Background.Tile = False
        Background.Transparent = False
        Caption = 'Clients'
        object lblRecentlyAdded: TRzURLLabel
          Left = 15
          Top = 40
          Width = 96
          Height = 13
          Caption = 'Newly-added clients'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clHighlight
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsUnderline]
          ParentFont = False
          OnClick = lblRecentlyAddedClick
        end
        object lblActiveClients: TRzURLLabel
          Left = 15
          Top = 59
          Width = 63
          Height = 13
          Caption = 'Active clients'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clHighlight
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsUnderline]
          ParentFont = False
          OnClick = lblActiveClientsClick
        end
        object lblAllClients: TRzURLLabel
          Left = 15
          Top = 78
          Width = 42
          Height = 13
          Caption = 'All clents'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clHighlight
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsUnderline]
          ParentFont = False
          OnClick = lblAllClientsClick
        end
        object RzLabel1: TRzLabel
          Left = 15
          Top = 112
          Width = 40
          Height = 13
          Caption = 'Recent'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clWindowText
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lbxRecent: TRzListBox
          Left = 15
          Top = 131
          Width = 146
          Height = 222
          BorderStyle = bsNone
          Font.Charset = DEFAULT_CHARSET
          Font.Color = clGray
          Font.Height = -11
          Font.Name = 'Tahoma'
          Font.Style = [fsItalic]
          ItemHeight = 13
          ParentFont = False
          TabOrder = 1
          OnDblClick = lbxRecentDblClick
        end
      end
      object nppLoans: TJvNavPanelPage
        Left = 0
        Top = 0
        Width = 181
        Height = 364
        Hint = ''
        Background.Stretch = False
        Background.Proportional = False
        Background.Center = False
        Background.Tile = False
        Background.Transparent = False
        Caption = 'Loans Management'
      end
      object nppExpense: TJvNavPanelPage
        Left = 0
        Top = 0
        Width = 181
        Height = 364
        Hint = ''
        Background.Stretch = False
        Background.Proportional = False
        Background.Center = False
        Background.Tile = False
        Background.Transparent = False
        Caption = 'Expense Managment'
      end
      object nppInventory: TJvNavPanelPage
        Left = 0
        Top = 0
        Width = 181
        Height = 364
        Hint = ''
        Background.Stretch = False
        Background.Proportional = False
        Background.Center = False
        Background.Tile = False
        Background.Transparent = False
        Caption = 'Inventory'
      end
      object nppReports: TJvNavPanelPage
        Left = 0
        Top = 0
        Width = 181
        Height = 364
        Hint = ''
        Background.Stretch = False
        Background.Proportional = False
        Background.Center = False
        Background.Tile = False
        Background.Transparent = False
        Caption = 'Reports'
      end
    end
  end
  object pnlDockMain: TPanel
    Left = 185
    Top = 30
    Width = 889
    Height = 543
    Align = alClient
    BevelOuter = bvNone
    BorderWidth = 1
    TabOrder = 1
  end
  object sbMain: TRzStatusBar
    Left = 0
    Top = 573
    Width = 1074
    Height = 19
    AutoStyle = False
    BorderInner = fsNone
    BorderOuter = fsFlat
    BorderSides = [sdLeft, sdTop, sdRight, sdBottom]
    BorderWidth = 0
    TabOrder = 2
    object spMain: TRzStatusPane
      Left = 1
      Top = 1
      Width = 553
      Height = 17
      FillColor = clMenu
      ParentFillColor = False
      Transparent = False
      Align = alLeft
      Color = clHighlight
      ParentColor = False
      Caption = ''
      ExplicitLeft = 0
      ExplicitTop = 0
      ExplicitHeight = 19
    end
    object RzVersionInfoStatus1: TRzVersionInfoStatus
      Left = 554
      Top = 1
      Height = 17
      Align = alLeft
      Field = vifProductVersion
      ExplicitLeft = 1074
      ExplicitTop = 0
      ExplicitHeight = 20
    end
  end
  object ToolBar1: TToolBar
    Left = 0
    Top = 0
    Width = 1074
    Height = 30
    BorderWidth = 1
    Caption = 'ToolBar1'
    EdgeBorders = [ebTop, ebBottom]
    Flat = False
    Images = imlToolbar
    TabOrder = 3
    object tbAddClient: TToolButton
      Left = 0
      Top = 0
      Hint = 'Add client'
      Caption = 'tbAddClient'
      ImageIndex = 0
      ParentShowHint = False
      ShowHint = True
      OnClick = tbAddClientClick
    end
    object ToolButton2: TToolButton
      Left = 23
      Top = 0
      Caption = 'ToolButton2'
      ImageIndex = 1
    end
    object ToolButton3: TToolButton
      Left = 46
      Top = 0
      Width = 8
      Caption = 'ToolButton3'
      ImageIndex = 2
      Style = tbsSeparator
    end
    object tbSave: TToolButton
      Left = 54
      Top = 0
      Hint = 'Save changes to current window'
      Caption = 'tbSave'
      ImageIndex = 2
      ParentShowHint = False
      ShowHint = True
      OnClick = tbSaveClick
    end
    object tbCancel: TToolButton
      Left = 77
      Top = 0
      Hint = 'Cancel changes to current window'
      Caption = 'tbCancel'
      ImageIndex = 3
      ParentShowHint = False
      ShowHint = True
      OnClick = tbCancelClick
    end
    object ToolButton1: TToolButton
      Left = 100
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      ImageIndex = 3
      Style = tbsSeparator
    end
    object tbGroups: TToolButton
      Left = 108
      Top = 0
      Hint = 'Groups'
      Caption = 'tbGroups'
      ImageIndex = 4
      ParentShowHint = False
      ShowHint = True
      OnClick = tbGroupsClick
    end
    object tbEmployer: TToolButton
      Left = 131
      Top = 0
      Hint = 'Employer list'
      Caption = 'tbEmployer'
      ImageIndex = 5
      ParentShowHint = False
      ShowHint = True
      OnClick = tbEmployerClick
    end
    object tbBanks: TToolButton
      Left = 154
      Top = 0
      Hint = 'Banks list'
      Caption = 'tbBanks'
      ImageIndex = 6
      ParentShowHint = False
      ShowHint = True
      OnClick = tbBanksClick
    end
    object tbDesignationList: TToolButton
      Left = 177
      Top = 0
      Hint = 'Designation list'
      Caption = 'tbDesignationList'
      ImageIndex = 7
      ParentShowHint = False
      ShowHint = True
      OnClick = tbDesignationListClick
    end
    object ToolButton4: TToolButton
      Left = 200
      Top = 0
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 8
      Style = tbsSeparator
    end
    object tbLoanClass: TToolButton
      Left = 208
      Top = 0
      Hint = 'Loan class'
      Caption = 'tbLoanClass'
      ImageIndex = 8
      ParentShowHint = False
      ShowHint = True
      OnClick = tbLoanClassClick
    end
  end
  object mmMain: TMainMenu
    Left = 200
    Top = 504
    object File1: TMenuItem
      Caption = '&File'
    end
    object ools1: TMenuItem
      Caption = '&Tools'
      object Settings1: TMenuItem
        Caption = 'Settings'
      end
    end
    object About1: TMenuItem
      Caption = '&About'
    end
  end
  object imlToolbar: TJvImageList
    ColorDepth = cd32Bit
    PixelFormat = pf32bit
    TransparentColor = clBlack
    Items = <>
    DrawingStyle = dsTransparent
    Left = 201
    Top = 464
    Bitmap = {
      494C010109000001AC0010001000FFFFFFFF2110FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000003000000001002000000000000030
      000000000000000000000000000000000000000000130000002D010101720303
      0387030303870303038703030387030303870303038703030387030303870430
      02D0044B01E3022200AB00000013000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000A0000001706060682C9C9
      C9FFCDCDCDFFC5C5C5FFCDCDCDFFC5C5C5FFCDCDCDFFC5C5C5FFCDCDCDFF3191
      28FF2ADF19FF085500D10000000A000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000808087BC7C7
      C7FF8A8A8AFFBEBEBEFF8A8A8AFFBEBEBEFF8A8A8AFF53A14BFF268C1BFF3298
      27FF3CE22BFF085900CC085900CC043200990000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000A0A0A77C9C9
      C9FFC9C9C9FFC0C0C0FFC9C9C9FFC0C0C0FFC9C9C9FF329E26FF51E740FF51E7
      40FF51E740FF51E740FF51E740FF0A5E00CC0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000B0B0B76CCCC
      CCFF8F8F8FFFC3C3C3FF8F8F8FFFC3C3C3FF8F8F8FFF57AC4DFF2A9A1CFF36A7
      28FF65EB54FF0B6400CC0B6400CC063800990000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000B0B0B74CFCF
      CFFFCECECEFFC6C6C6FFCECECEFFC6C6C6FFCECECEFFC6C6C6FFCECECEFF39AD
      29FF74EE63FF0C6900CC00000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000B0B0B72D1D1
      D1FF949494FFC8C8C8FF949494FFC8C8C8FF949494FFC8C8C8FF949494FF5EB8
      52FF137D04E3073C009900000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000B0B0B71D4D4
      D4FFD4D4D4FFCBCBCBFFD4D4D4FFCBCBCBFFD4D4D4FFCBCBCBFFD4D4D4FFD4D4
      D4FF0B0B0B710000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000C0C0C6FD8D8
      D8FF999999FFCFCFCFFF999999FFCFCFCFFF999999FFCFCFCFFF999999FFD8D8
      D8FF0C0C0C6F0000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000C0C0C6DDBDB
      DBFFD2D2D2FFD2D2D2FFD2D2D2FFD2D2D2FFD2D2D2FFD2D2D2FFD2D2D2FFDBDB
      DBFF0C0C0C6D0000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000101018F7171
      71FF717171FF717171FF717171FF717171FF717171FF717171FF717171FF7171
      71FF0101018F0000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000000000000000000001010198AADD
      AAFFA7DAA7FFA3D6A3FF9FD29FFF9ACD9AFF96C996FF91C491FF689C68FF8ABD
      8AFF010101980000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000A291C4
      91FF8FC28FFF8DC08DFF8BBE8BFF89BC89FF87BA87FF84B784FF5D915DFF81B4
      81FF000000A20000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000AA5656
      56FF565656FF565656FF565656FF565656FF565656FF565656FF565656FF5656
      56FF000000AA0000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000D0D0D67EAEA
      EAFFE5E5E5FFE5E5E5FFE5E5E5FFE5E5E5FFE5E5E5FFE5E5E5FFE5E5E5FFEAEA
      EAFF0D0D0D670000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000000000000707074D0D0D
      0D660D0D0D660D0D0D660D0D0D660D0D0D660D0D0D660D0D0D660D0D0D660D0D
      0D660707074D0000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000F000000170000001A0000
      001A0000001A0000001A0000001A0000001A0000001A0000001A0000001A0000
      001A0000001A0000001A000000170000000F0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000000006000000170000001A0000
      001A0000001A0000001A0000001A0000001A0000001A0000001A0000001A0000
      001A0000001A0000001700000007000000000000001400000027000000270000
      0027000000270000002700000027000000270000002700000027000000140000
      0000000000000000000000000000000000000000001E00220CA4004416CC0044
      16CC004416CC004416CC004416CC004416CC004416CC004416CC004416CC0044
      16CC004416CC004416CC00220CA40000001E0000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000101016903030388050505890808
      088C0B0B0B8F0D0D0D910F0F0F930F0F0F930E0E0E920D0D0D910909098E0707
      078C05050589030303880101016900000000160B007D4D2701BC492500B34321
      00A73F1F009D090909663F1F009D432100A7492400B24C2701BB160B007D0000
      00000000000000000000000000000000000000000000005624CC6BD9A3FF64D2
      9CFF64D29CFF54C78EFF3CB87AFF39B778FF3ABA7AFF3BBD7CFF3CC07EFF3DC2
      80FF3DC582FF47CE8BFF005624CC0000000000000009000000160000001A0000
      001A0000001A0000000D000000000000000D0000001A0000001A0000001A0000
      00000000001A0000001A000000160000000906060681CDCDCDFFCFCFCFFFD2D2
      D2FFD5D5D5FFD7D7D7FFD9D9D9FFDADADAFFD9D9D9FFD7D7D7FFD4D4D4FFD1D1
      D1FFCFCFCFFFCDCDCDFF0606068100000000442301A7E2B17DFFE7B481FFF6C9
      96FFD6A36FFFE9E9E9FFD6A36FFFF7CA97FFE9B683FFE3B27EFF442301A70000
      0000000000000000000000000000000000000000000000622ECC7EEBB5FF7AE8
      B2FF7AE8B2FF7AE8B2FF74E4ADFF61DC9FFF58DB9AFF57DC9AFF58DE9CFF58DF
      9CFF59E19DFF5DE6A2FF00622ECC00000000000000120000002C0F0000BB1F00
      00EB1D0000E01000009F000000001000009E1E0000DE1E0000E90F0000BB0000
      0000140A005F0C0600540000002C000000120505055C787878DEA8A8A8FF9F9F
      9FFFBABABAFFA8A8A8FF9F9F9FFFBABABAFFA8A8A8FF9F9F9FFFBABABAFFA8A8
      A8FF9F9F9FFF787878DE0505055C0000000023110073895F34CFDCAE7BF8F6C9
      96FFDEAB77FFFCFCFCFFDEAB77FFF7CA97FFDEB17EF98D6337D5271401850000
      00270000002700000027000000270000001400000000003B1D99006B34CC006B
      34CC006B34CC006B34CC006B34CC006B34CC006B34CC006B34CC006B34CC006B
      34CC006B34CC006B34CC003B1D990000000000000000000000001D0000DF3E1E
      1EF2563434FF563434FF00000000563434FF563434FF3E1E1EF21D0000DF0000
      0000140B015E140B015E0000000000000000000000000000006EDFDFDFFFB3B3
      B3FF8F8F8FFFDFDFDFFFB3B3B3FF8F8F8FFFDFDFDFFFB3B3B3FF8F8F8FFFDFDF
      DFFFB3B3B3FF0000006E0000000000000000000000101E0F00683D210392BA8E
      5DE4BDA38AFFAAAAAAFFBDA38AFFC59D66EE543805BB3C3201AF0D0C0A6C173A
      00AF193E00B8194100C21A4300CA071300840000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000010000370D00
      00941D0000DB5A3838FF170E0E805A3838FF1D0000DB0D00009400000000140B
      025D0905003F0100001800000000000000000000000000000074D6D6D6FFAAAA
      AAFF838383FFD6D6D6FFAAAAAAFF838383FFD6D6D6FFAAAAAAFF838383FFD6D6
      D6FFAAAAAAFF0000007400000000000000000000000000000000070400342C16
      007B002851CC80B3E3FF0D3F66E66B531BC88A944FE381B45EFFE9E9E9FF81B4
      5EFFA8DB86FF94C771FF90C36DFF183C00B1000000003A2200A0623700D46237
      00D4623700D4623700D4623700D4623700D4623700D4623700D4623700D46237
      00D4623700D4623700D43A2200A0000000000000000000000000000000000000
      00000300004C1D0000D8000000001D0000D80300004C00000000140B035B0201
      002000000000000000000000000000000000000000000000007CCDCDCDFFA1A1
      A1FF727272FFCDCDCDFFA1A1A1FF727272FFCDCDCDFFA1A1A1FF727272FFCDCD
      CDFFA1A1A1FF0000007C00000000000000000000000000000000000000000303
      02300B345DCB4A7EB1FF16486CE16FA372F6A7DA85FF89BC66FFFCFCFCFF89BC
      66FFA8DB86FF90C16EF84C782FD20C1D007600000000774C00D8E7BE5EFFE0B7
      57FFE0B757FFE0B757FFE0B757FFD8AC46FFCC9C2DFFCD9D2BFFD09F2CFFD2A1
      2CFFD6A32DFFDFAD36FF774C00D8000000000000000000000000000000000000
      00000000000E1C0000D6644242FF1C0000D60000000E140C035A140C035A0000
      0006000000000000000000000000000000000000000001010188C5C5C5FF9A9A
      9AFF595959FFC5C5C5FF9A9A9AFF595959FFC5C5C5FF9A9A9AFF595959FFC5C5
      C5FF9A9A9AFF0101018800000000000000000000000000000000000000000015
      2A8A6EA2D0F783B6E6FF6FA4D2F90F3B3EC373A352E47CB07CFFAAAAAAFF7CB0
      7CFF75A453E4173404950A1A006A0000001000000000885B00DCF9D070FFF6CD
      6DFFF6CD6DFFF6CD6DFFF6CD6DFFF6CD6DFFF3C967FFEEC053FFEFBD48FFF0BE
      48FFF2BF48FFF7C44DFF885B00DC000000000000000000000000000000000000
      0000040000551C0000D4694747FF1C0000D40400005501000016140C04580302
      0024000000000000000000000000000000000303036205050583868686FF8686
      86FF868686FF868686FF868686FF868686FF868686FF868686FF868686FF8686
      86FF868686FF0505058303030362000000000000000000000000000912590424
      47C593C6F2FF8EC1EEFF93C6F2FF062A4CD00D302EB9002851CC80B3E3FF0028
      51CC102A0FA1040B0659000000000000000000000000513900A6936600DE9366
      00DE936600DE936600DE936600DE936600DE936600DE936600DE936600DE9366
      00DE936600DE936600DE513900A6000000000000000000000000000000000000
      00001C0000D26E4C4CFF6E4C4CFF6E4C4CFF1C0000D200000000140C0556140C
      05560000000000000000000000000000000009090978C0C0C0FFC5C5C5FFCCCC
      CCFFD5D5D5FFDBDBDBFFE1E1E1FFE2E2E2FFE0E0E0FFDADADAFFD3D3D3FFCCCC
      CCFFC4C4C4FFC0C0C0FF09090978000000000000000000000000000811570C0C
      1CECA0D3FAFF98CBF5FFA0D3FAFF0E0F25FB001B4CCD0B2D5ACD588DBFFF0B2D
      5ACD000A3ECC00093AC600000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00001B0000D0725050FF725050FF725050FF1B0000D000000000130C0555130C
      05550000000000000000000000000000000005050554535353C3C2C2C2FFAFAF
      AFFF9F9F9FFFB3B3B3FFB9B9B9FFB8B8B8FFB9B9B9FFB3B3B3FF9F9F9FFFAFAF
      AFFFC1C1C1FF535353C305050554000000000000000000000000000000000000
      0DC780A6CAFF99CCF6FF80A6CAFF00021CEF000736CC6A9ECFFF8FC2EFFF6A9E
      CFFF000736CC000529B20000000000000000000000000000349900005ACC0000
      5ACC00005ACC00005ACC00005ACC00005ACC00005ACC00005ACC00005ACC0000
      5ACC00005ACC00005ACC00003499000000000000000000000000000000000000
      0000040000531C0000CE765454FF1C0000CE0400005300000015130C06530302
      012200000000000000000000000000000000000000000303033E2A2A2A9AB8B8
      B8F3B2B2B2FF919191FFB3B3B3FFC7C7C7FFB3B3B3FF919191FFB2B2B2FFB8B8
      B8F32A2A2A9A0303033E00000000000000000000000000000000000000000000
      078E2C2C3CE6616170F9292939E600021EDA00032FCC93C6F2FF8EC1EEFF93C6
      F2FF00032FCC00011995000000000000000000000000000069CC5C4FE9FF4937
      E4FF4937E4FF4937E4FF4937E4FF4937E4FF4937E4FF3825DEFF1F09D7FF1B05
      D8FF1C05DBFF3422E2FF000069CC000000000000000000000000000000000000
      00000000000D0C0000881C0000CD0C000088000000110E090447080502370000
      0006000000000000000000000000000000000000000000000000010101281414
      147A828282D5C7C7C7FF8D8D8DFF888888FF8D8D8DFFC7C7C7FF828282D51414
      147A010101280000000000000000000000000000000000000000000000000000
      00170000078500000AA50000078500000A76000935CC8DC0EBFF98CBF5FF96C9
      F2FF000935CC00000A63000000000000000000000000000072CC8179FCFF7367
      FBFF7367FBFF7367FBFF7367FBFF7367FBFF7367FBFF7367FBFF6D60FAFF5A4C
      F7FF5143F9FF6058FAFF000072CC000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00160A0A0A5E454545AAD2D2D2FBA8A8A8FFD2D2D2FB454545AA0A0A0A5E0000
      0016000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000123001341C71C4F94FF4A7DB8FF699D
      D1FF001341C70000012300000000000000000000000000004399000079CC0000
      79CC000079CC000079CC000079CC000079CC000079CC000079CC000079CC0000
      79CC000079CC000079CC00004399000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000007050505451E1E1E83838383CE1E1E1E8305050545000000070000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000000000122F9B244D8CE83567AAFB1847
      89F400122F9B0000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000010101260D0D0D670101012600000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000011B0017359B002354C20017
      359B0000011B00000000000000000000000000000009000000160000001A0000
      001A0000001A0000001A0000001A0000001A0000001A0000001A0000001A0000
      001A0000001A0000001A0000001600000009000000120000002C2C1F129F593F
      25C4593F25C4593F25C4593F25C4593F25C4593F25C4593F25C4593F25C4593F
      25C4593F25C42C1F129F0000002C000000120000000F000000170000001A0000
      001A0000001A0000001A0000001A0000001A0000001A0000001A0000001A0000
      001A0000001A0000001A000000170000000F00000000000000020000000C0000
      00160000001A0000001A0000001A0000001A0000001A0000001A0000001A0000
      001A000000170000000C00000002000000000000001200000033001300830032
      00BC013A00CC013A00CC013A00CC013A00CC013A00CC013A00CC013A00CC013A
      00CC003200BC00130083000000330000001200000009000000164F371FB5FDF4
      E1FFFBF2DDFFFBF2DCFFFAF1DCFFFAF1DBFFFAF0DBFFF9F0DAFFF9EFDAFFF9EE
      D9FFFCF2DFFF4F371FB500000016000000090000001E0000002E080005633C00
      28C60101018A0101018A0101018A0101018A0101018A0101018A3C0028C63C00
      28C63C0028C63C0028C61D00139E0000001E0000000000000004000000170000
      002B00000C7400003ACC00003ACC00003ACC00003ACC00003ACC00003ACC0000
      0C740000002D00000018000000040000000000000000011600730D6D06DD1EC2
      0FF921D910FF21D910FF21D910FF21D910FF21D910FF21D910FF21D910FF21D9
      10FF1DC20EF90C6D05DD01160073000000000000000000000000422E19A2FBF2
      DDFFF6EED4FFF5EDD3FFF5ECD2FFF4EBD1FFF6C33AFFF4C138FFF1BE35FFEFBC
      33FFF8EDD8FF422E19A2000000000000000000000000050003413A0027BA883E
      70EFB9ABABFFB16498FFB16498FFB5A7A7FFB5A7A7FFB9ABABFFB16498FFC376
      AAFFC073A7FFD68ABDFF3A0027BA000000000000000000000000000000000000
      0A5C000045CC1010D9FF1010D9FF1010D9FF1010D9FF1010D9FF1010D9FF0000
      45CC00000A5C00000000000000000000000000000000054200BA23C014F921D1
      10FF21D110FF21D110FF21D110FF21B610FF21B610FF21D110FF21D110FF21D1
      10FF21D110FF1EBE0EF9054200BA0000000000000000000000003B281597FBF2
      DCFFF5EDD3FFF5ECD2FFF4EBD1FFF4EAD0FFDAD1B1FFF9F3E6FFF9F2E5FFD5C9
      AAFFF8ECD7FF3B281597000000000000000000000000360024ADD488BBFFAD60
      94FFBAB1B1FFAD6094FFAD6094FFB1A8A8FFB1A8A8FFBAB1B1FFAD6094FFC376
      AAFFB86B9FFFD88CBFFF360024AD0000000000000000000000000000105C0000
      4FCC1717D4FF1010B6FF1010D1FF1010D1FF1010D1FF1010D1FF1010B6FF1010
      D1FF00004FCC0000105C000000000000000000000000075400CC2ACC19FF21C8
      10FF21C810FF21C810FF21BC10FFE8E8E8FFECECECFF21BC10FF21C810FF21C8
      10FF21C810FF21C810FF075400CC00000000000000000000000038261492FAF1
      DCFFE1D9B8FFE0D7B7FFDED5B5FFDCD2B2FFE0D5B7FFD8CDAEFFD6CAABFFD4C8
      A8FFF7ECD6FF38261492000000000000000000000000350024A8D286B9FFA95C
      90FFC0BBBBFF95487BFF95487BFFB7B2B2FFB7B2B2FFC0BBBBFFA95C90FFC376
      AAFFB06397FFDA8EC1FF350024A800000000000000000000115C000054CC2222
      D2FF1010B2FFDCDCDCFF1010B2FF1010C8FF1010C8FF1010B2FFEEEEEEFF1010
      B2FF1010C8FF000054CC0000115C0000000000000000075700CC30C61FFF21BE
      10FF21BE10FF21BE10FF21B510FFE4E4E4FFE8E8E8FF21B510FF21BE10FF21BE
      10FF21BE10FF22BE11FF075700CC0000000000000000000000003424138DFAF1
      DBFFE0D8B8FFFAF5E8FFF9F4E7FFF9F3E6FFD9CEAEFFF8F2E5FFF8F1E4FFD3C7
      A8FFF7EBD5FF3424138D000000000000000000000000330023A4D589BCFFA558
      8CFFC8C7C7FFC3C2C2FFC3C2C2FFC3C2C2FFC3C2C2FFC8C7C7FFA5588CFFC376
      AAFFA85B8FFFDD91C4FF330023A40000000000000000000057CC3030D2FF1010
      BEFFD1D1D1FFD6D6D6FFDCDCDCFF1010ADFF1010ADFFEAEAEAFFEEEEEEFFEEEE
      EEFF1010BEFF1111BEFF000057CC0000000000000000085A00CC40C32FFF22B4
      11FF21A810FF21A810FF21A410FFE0E0E0FFE4E4E4FF21A410FF21A810FF21A8
      10FF21B410FF24B513FF085A00CC00000000000000000000000031221288FAF0
      DBFFE0D7B7FFDFD5B5FFDDD2B2FFDBCFB0FFDED2B4FFD7CAABFFD4C7A8FFD3C5
      A6FFF7EAD4FF31221288000000000000000000000000320022A0D98DC0FFA255
      89FFA15488FFA15488FFA15488FFA15488FFA15488FFA15488FFA25589FFA255
      89FFA25589FFE195C8FF320022A0000000000000000000005ACC3333C7FF1111
      B4FF1010B4FFD1D1D1FFD6D6D6FFDCDCDCFFE2E2E2FFE6E6E6FFEAEAEAFF1010
      B4FF1010B4FF1313B6FF00005ACC0000000000000000095D00CC51C940FF32AF
      21FFD4D4D4FFD3D3D3FFD7D7D7FFDCDCDCFFE0E0E0FFE4E4E4FFE8E8E8FFECEC
      ECFF21A610FF27AF16FF095D00CC0000000000000000000000002E1F1083F9F0
      DAFFE0D5B5FFF9F3E6FFF9F2E5FFF8F2E5FFD8CBACFFF7F0E3FFF7EFE2FFD1C1
      A2FFF5E7D1FF2E1F10830000000000000000000000003100219DDC90C3FFD387
      BAFFD387BAFFD387BAFFD387BAFFD387BAFFD387BAFFD387BAFFD387BAFFD387
      BAFFD387BAFFDC90C3FF3100219D000000000000000000005DCC4545CEFF2525
      B5FF1313ABFF1010AAFFD1D1D1FFD6D6D6FFDCDCDCFFE2E2E2FF1010AAFF1010
      AAFF1010AAFF1717B0FF00005DCC00000000000000000A5F00CC54CC43FF3BB3
      2AFFF8F8F8FFE1E1E1FFD5D5D5FFD7D7D7FFDCDCDCFFE0E0E0FFE4E4E4FFE8E8
      E8FF21A010FF2BAA1AFF0A5F00CC0000000000000000000000002C1E0F7FF9EF
      DAFFDFD4B4FFDED2B2FFDCCFB0FFD9CDADFFDDCFB2FFD5C7A8FFD2C2A4FFCEBD
      9EFFF4E4CEFF2C1E0F7F0000000000000000000000003000209AE094C7FFF0DD
      DEFFF4F4E4FFF4F4E4FFF4F4E4FFF4F4E4FFF4F4E4FFF4F4E4FFF4F4E4FFF4F4
      E4FFF0DDDEFFE094C7FF3000209A000000000000000000005FCC4949D2FF3232
      BBFF2D2DB8FF12129FFFCECECEFFD1D1D1FFD6D6D6FFDCDCDCFF10109EFF1010
      A1FF1010A1FF1C1CACFF00005FCC00000000000000000B6200CC59D148FF46BE
      35FF3DB52CFF3DB52CFF36AE25FFEBEBEBFFE2E2E2FF249D13FF229B11FF229B
      11FF269F15FF38B127FF0B6200CC000000000000000000000000291C0E7AF9EE
      D9FFDED2B2FFF8F2E5FFF8F1E4FFF7F0E3FFD6C8A9FFF7EEE1FFF5EBDEFFCDB7
      99FFF3E2CCFF291C0E7A0000000000000000000000002F001F97E397CAFFF6F6
      E9FFECECDFFFECECDFFFECECDFFFECECDFFFECECDFFFECECDFFFECECDFFFECEC
      DFFFF6F6E9FFE397CAFF2F001F970000000000000000000062CC4F4FD8FF3636
      BFFF2222ABFFFFFFFFFFF7F7F7FFE8E8E8FFDEDEDEFFDBDBDBFFDDDDDDFF1010
      9BFF1515A0FF2A2AB5FF000062CC00000000000000000B6400CC5FD74EFF4DC5
      3CFF4DC53CFF4DC53CFF43BB32FFFFFFFFFFFFFFFFFF43BB32FF4DC53CFF4DC5
      3CFF4DC53CFF57CF46FF0B6400CC000000000000000000000000271A0D76F8EE
      D8FFFFCC43FFFECB42FFFBC83FFFF9C63DFFF6C33AFFF4C138FFF1BE35FFEFBC
      33FFF2E1CCFF271A0D760000000000000000000000002E011F94E69ACDFFF8F8
      EFFFF1F1E7FFF1F1E7FFF1F1E7FFF1F1E7FFF1F1E7FFF1F1E7FFF1F1E7FFF1F1
      E7FFF8F8EFFFE69ACDFF2E011F940000000000000000000064CC6F6FF8FF4141
      CAFFFFFFFFFFFFFFFFFFFFFFFFFF4141CAFF4141CAFFFFFFFFFFFFFFFFFFFFFF
      FFFF4141CAFF5A5AE3FF000064CC00000000000000000B6800CC66DE55FF56CE
      45FF56CE45FF56CE45FF49C138FFFFFFFFFFFFFFFFFF49C138FF56CE45FF56CE
      45FF56CE45FF5FD74EFF0B6800CC00000000000000000000000024180C72F8ED
      D7FFF0E2C8FFEFE1C7FFEFDFC5FFEDDBC1FFEAD6BCFFE8D0B6FFE6CDB3FFE5CC
      B2FFF2E1CCFF24180C720000000000000000000000002D011E91EA9ED1FFFBFB
      F5FFF6F6F0FFF6F6F0FFF6F6F0FFF6F6F0FFF6F6F0FFF6F6F0FFF6F6F0FFF6F6
      F0FFFBFBF5FFEA9ED1FF2D011E9100000000000000000000145C000068CC7373
      FCFF4E4ED7FFFFFFFFFF4E4ED7FF4E4ED7FF4E4ED7FF4E4ED7FFFFFFFFFF4E4E
      D7FF6767F0FF000068CC0000145C00000000000000000A5700BA5FD44EF95ED6
      4DFF5ED64DFF5ED64DFF5ED64DFF4FC73EFF4FC73EFF5ED64DFF5ED64DFF5ED6
      4DFF5ED64DFF5BD04AF90A5700BA00000000000000000000000023170B6FF8EC
      D7FFC7BB99FFC5B897FFD1C1A1FFC6B595FFE8D0B6FFE6CDB3FFC2A485FFC2A4
      85FFC2A485FF432F1AA30000000000000000000000002C011E8FECA0D3FFFEFE
      FBFFFBFBF8FFFBFBF8FFFBFBF8FFFBFBF8FFFBFBF8FFFBFBF8FFFBFBF8FFFBFB
      F8FFFEFEFBFFECA0D3FF2C011E8F0000000000000000000000000000155C0000
      69CC7676FFFF5A5AE3FF5A5AE3FF5A5AE3FF5A5AE3FF5A5AE3FF5A5AE3FF7070
      F9FF000069CC0000155C0000000000000000000000000422007329911ADD61D5
      4FF96DE55CFF6DE55CFF6DE55CFF6DE55CFF6CE45BFF6CE45BFF6CE45BFF6CE4
      5BFF5FD54EF9289019DD0422007300000000000000000000000021160B6CF7EB
      D6FFEFDFC5FFEDDBC1FFEAD6BCFFE8D0B6FFE6CDB3FFE5CCB2FFD2B69AFFFFF6
      E5FF21160B6C040201260000000000000000000000002B011D8DF2A6D9FFFFFF
      FFFFFFFFFEFFFFFFFEFFFFFFFEFFFFFFFEFFFFFFFEFFFFFFFEFFFFFFFEFFFFFF
      FEFFFFFFFFFFF2A6D9FF2B011D8D000000000000000000000000000000000000
      155C00006BCC7676FFFF6C6CF5FF6C6CF5FF6C6CF5FF6C6CF5FF7474FDFF0000
      6BCC0000155C000000000000000000000000000000000000000C042200730A5A
      00BA0D6D00CC0D6D00CC0D6D00CC0D6D00CC0D6D00CC0D6D00CC0D6D00CC0D6D
      00CC0A5A00BA042200730000000C0000000000000000000000001F150A69FBF0
      DDFFF7E9D4FFF5E7D1FFF4E4CEFFF3E2CCFFF2E1CCFFF2E1CCFFDCC2A7FF1F15
      0A690302012500000000000000000000000000000000170010682A011C8B1414
      0D6614140D6614140D6614140D6614140D6614140D6614140D6614140D661414
      0D6614140D662A011C8B17001068000000000000000000000000000000000000
      00000000155C00006DCC00006DCC00006DCC00006DCC00006DCC00006DCC0000
      155C000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000110B054D1E14
      0A671E140A671E140A671E140A671E140A671E140A671E140A671E140A670302
      0124000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000300000000100010000000000800100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000}
  end
end
