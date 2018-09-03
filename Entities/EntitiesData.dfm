object dmEntities: TdmEntities
  OldCreateOrder = False
  Height = 336
  Width = 771
  object dstEntities: TADODataSet
    Connection = dmApplication.acMain
    CursorType = ctStatic
    Filtered = True
    LockType = ltReadOnly
    CommandText = 'sp_get_entities;1'
    CommandType = cmdStoredProc
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = 0
      end
      item
        Name = '@entity_type'
        Attributes = [paNullable]
        DataType = ftString
        Size = 2
        Value = ''
      end>
    Left = 71
    Top = 22
  end
  object dscEntities: TDataSource
    DataSet = dstEntities
    Left = 159
    Top = 22
  end
  object dstLandlord: TADODataSet
    Tag = 1
    Connection = dmApplication.acMain
    BeforeOpen = dstLandlordBeforeOpen
    BeforePost = dstLandlordBeforePost
    CommandText = 'sp_cl_get_entity'
    CommandType = cmdStoredProc
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = Null
      end
      item
        Name = '@entity_id'
        Attributes = [paNullable]
        DataType = ftString
        Size = 9
        Value = Null
      end>
    Left = 72
    Top = 80
  end
  object dstLlPersonal: TADODataSet
    Tag = 2
    Connection = dmApplication.acMain
    CursorType = ctStatic
    BeforeOpen = dstLlPersonalBeforeOpen
    BeforePost = dstLlPersonalBeforePost
    CommandText = 'sp_cl_get_personal_info'
    CommandType = cmdStoredProc
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = 0
      end
      item
        Name = '@entity_id'
        Attributes = [paNullable]
        DataType = ftString
        Size = 9
        Value = ''
      end>
    Left = 72
    Top = 136
  end
  object dscLlPersonal: TDataSource
    DataSet = dstLlPersonal
    Left = 160
    Top = 136
  end
  object dstLlContact: TADODataSet
    Tag = 2
    Connection = dmApplication.acMain
    BeforeOpen = dstLlContactBeforeOpen
    BeforePost = dstLlContactBeforePost
    CommandText = 'sp_cl_get_contact_info'
    CommandType = cmdStoredProc
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = Null
      end
      item
        Name = '@entity_id'
        Attributes = [paNullable]
        DataType = ftString
        Size = 9
        Value = ''
      end>
    Left = 72
    Top = 192
  end
  object dscLlContact: TDataSource
    DataSet = dstLlContact
    Left = 160
    Top = 192
  end
  object dstImmHead: TADODataSet
    Tag = 3
    Connection = dmApplication.acMain
    BeforeOpen = dstImmHeadBeforeOpen
    BeforePost = dstImmHeadBeforePost
    CommandText = 'sp_cl_get_entity'
    CommandType = cmdStoredProc
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = Null
      end
      item
        Name = '@entity_id'
        Attributes = [paNullable]
        DataType = ftString
        Size = 9
        Value = Null
      end>
    Left = 256
    Top = 24
  end
  object dstIHPersonal: TADODataSet
    Tag = 4
    Connection = dmApplication.acMain
    CursorType = ctStatic
    BeforeOpen = dstIHPersonalBeforeOpen
    BeforePost = dstIHPersonalBeforePost
    CommandText = 'sp_cl_get_personal_info'
    CommandType = cmdStoredProc
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = 0
      end
      item
        Name = '@entity_id'
        Attributes = [paNullable]
        DataType = ftString
        Size = 9
        Value = ''
      end>
    Left = 256
    Top = 80
  end
  object dscIHPersonal: TDataSource
    DataSet = dstIHPersonal
    Left = 344
    Top = 80
  end
  object dstIHContact: TADODataSet
    Tag = 4
    Connection = dmApplication.acMain
    BeforeOpen = dstIHContactBeforeOpen
    BeforePost = dstIHContactBeforePost
    CommandText = 'sp_cl_get_contact_info'
    CommandType = cmdStoredProc
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = Null
      end
      item
        Name = '@entity_id'
        Attributes = [paNullable]
        DataType = ftString
        Size = 9
        Value = ''
      end>
    Left = 256
    Top = 136
  end
  object dscIHContact: TDataSource
    DataSet = dstIHContact
    Left = 344
    Top = 136
  end
  object dstGroups: TADODataSet
    Tag = 5
    Connection = dmApplication.acMain
    CursorType = ctStatic
    Filtered = True
    AfterOpen = dstGroupsAfterOpen
    BeforePost = dstGroupsBeforePost
    AfterPost = dstGroupsAfterPost
    OnNewRecord = dstGroupsNewRecord
    CommandText = 'sp_get_groups;1'
    CommandType = cmdStoredProc
    FieldDefs = <
      item
        Name = 'loc_code'
        Attributes = [faFixed]
        DataType = ftFixedChar
        Size = 3
      end
      item
        Name = 'grp_id'
        Attributes = [faFixed]
        DataType = ftFixedChar
        Size = 8
      end
      item
        Name = 'grp_name'
        DataType = ftString
        Size = 30
      end
      item
        Name = 'is_active'
        Attributes = [faFixed]
        DataType = ftWord
      end
      item
        Name = 'par_grp_id'
        Attributes = [faFixed]
        DataType = ftFixedChar
        Size = 8
      end>
    Parameters = <>
    StoreDefs = True
    Left = 72
    Top = 248
  end
  object dscGroups: TDataSource
    DataSet = dstGroups
    Left = 160
    Top = 248
  end
  object dstParGroup: TADODataSet
    Tag = 5
    Connection = dmApplication.acMain
    CursorType = ctStatic
    Filtered = True
    LockType = ltReadOnly
    CommandText = 'sp_get_groups;1'
    CommandType = cmdStoredProc
    Parameters = <>
    Left = 432
    Top = 136
  end
  object dscParGroup: TDataSource
    DataSet = dstParGroup
    Left = 520
    Top = 136
  end
  object dstEmployers: TADODataSet
    Tag = 6
    Connection = dmApplication.acMain
    CursorType = ctStatic
    Filtered = True
    AfterOpen = dstEmployersAfterOpen
    BeforePost = dstEmployersBeforePost
    AfterPost = dstEmployersAfterPost
    AfterScroll = dstEmployersAfterScroll
    OnNewRecord = dstEmployersNewRecord
    CommandText = 'sp_get_employers;1'
    CommandType = cmdStoredProc
    Parameters = <>
    Left = 256
    Top = 192
  end
  object dscEmployers: TDataSource
    DataSet = dstEmployers
    Left = 344
    Top = 192
  end
  object dstRecipient: TADODataSet
    Tag = 7
    Connection = dmApplication.acMain
    BeforeOpen = dstRecipientBeforeOpen
    BeforePost = dstRecipientBeforePost
    CommandText = 'sp_cl_get_entity'
    CommandType = cmdStoredProc
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = Null
      end
      item
        Name = '@entity_id'
        Attributes = [paNullable]
        DataType = ftString
        Size = 9
        Value = Null
      end>
    Left = 432
    Top = 24
  end
  object dstRcpPersonal: TADODataSet
    Tag = 8
    Connection = dmApplication.acMain
    CursorType = ctStatic
    BeforeOpen = dstLlPersonalBeforeOpen
    BeforePost = dstLlPersonalBeforePost
    CommandText = 'sp_cl_get_personal_info'
    CommandType = cmdStoredProc
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = 0
      end
      item
        Name = '@entity_id'
        Attributes = [paNullable]
        DataType = ftString
        Size = 9
        Value = ''
      end>
    Left = 432
    Top = 80
  end
  object dscRcpPersonal: TDataSource
    DataSet = dstRcpPersonal
    Left = 520
    Top = 80
  end
  object dstReferee: TADODataSet
    Tag = 9
    Connection = dmApplication.acMain
    BeforeOpen = dstRefereeBeforeOpen
    BeforePost = dstRefereeBeforePost
    CommandText = 'sp_cl_get_entity'
    CommandType = cmdStoredProc
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = Null
      end
      item
        Name = '@entity_id'
        Attributes = [paNullable]
        DataType = ftString
        Size = 9
        Value = Null
      end>
    Left = 600
    Top = 24
  end
  object dstRefPersonal: TADODataSet
    Tag = 10
    Connection = dmApplication.acMain
    CursorType = ctStatic
    BeforeOpen = dstRefPersonalBeforeOpen
    BeforePost = dstRefPersonalBeforePost
    CommandText = 'sp_cl_get_personal_info'
    CommandType = cmdStoredProc
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = 0
      end
      item
        Name = '@entity_id'
        Attributes = [paNullable]
        DataType = ftString
        Size = 9
        Value = ''
      end>
    Left = 600
    Top = 80
  end
  object dscRefPersonal: TDataSource
    DataSet = dstRefPersonal
    Left = 688
    Top = 80
  end
  object dstRefContact: TADODataSet
    Tag = 10
    Connection = dmApplication.acMain
    BeforeOpen = dstRefContactBeforeOpen
    BeforePost = dstRefContactBeforePost
    CommandText = 'sp_cl_get_contact_info'
    CommandType = cmdStoredProc
    Parameters = <
      item
        Name = '@RETURN_VALUE'
        DataType = ftInteger
        Direction = pdReturnValue
        Precision = 10
        Value = Null
      end
      item
        Name = '@entity_id'
        Attributes = [paNullable]
        DataType = ftString
        Size = 9
        Value = ''
      end>
    Left = 600
    Top = 136
  end
  object dscRefContact: TDataSource
    DataSet = dstRefContact
    Left = 688
    Top = 136
  end
  object dstGroupAttribute: TADODataSet
    Tag = 5
    Connection = dmApplication.acMain
    CursorType = ctStatic
    Filtered = True
    LockType = ltBatchOptimistic
    BeforePost = dstGroupAttributeBeforePost
    OnNewRecord = dstGroupAttributeNewRecord
    CommandText = 'sp_get_group_attributes;1'
    CommandType = cmdStoredProc
    Parameters = <>
    Left = 256
    Top = 248
  end
  object dscGroupAttribute: TDataSource
    DataSet = dstGroupAttribute
    Left = 344
    Top = 248
  end
  object dstBranches: TADODataSet
    Connection = dmApplication.acCore
    CursorType = ctStatic
    LockType = ltReadOnly
    AfterScroll = dstBranchesAfterScroll
    CommandText = 'hris_dd_get_locations;1'
    CommandType = cmdStoredProc
    Parameters = <>
    Left = 607
    Top = 190
  end
  object dscBranches: TDataSource
    DataSet = dstBranches
    Left = 687
    Top = 190
  end
end
