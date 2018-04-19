inherited frmLogin: TfrmLogin
  BorderIcons = [biSystemMenu]
  Caption = ''
  ClientHeight = 243
  ClientWidth = 434
  Position = poScreenCenter
  OnCreate = FormCreate
  OnShow = FormShow
  ExplicitWidth = 434
  ExplicitHeight = 243
  PixelsPerInch = 96
  TextHeight = 14
  inherited pnlTitle: TRzPanel
    Width = 434
    OnMouseDown = pnlTitleMouseDown
    ExplicitWidth = 434
    inherited imgClose: TImage
      Left = 412
      ExplicitLeft = 410
    end
    inherited lblCaption: TRzLabel
      Width = 84
      Caption = 'i-Finance Login'
      ExplicitWidth = 84
    end
  end
  inherited pnlMain: TRzPanel
    Width = 434
    Height = 222
    ExplicitWidth = 434
    ExplicitHeight = 222
    object Label4: TLabel
      Left = 176
      Top = 16
      Width = 139
      Height = 42
      Alignment = taCenter
      Caption = 'i-Finance'
      Color = 10196313
      Font.Charset = ANSI_CHARSET
      Font.Color = 6572079
      Font.Height = -35
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      WordWrap = True
    end
    object Label5: TLabel
      Left = 176
      Top = 54
      Width = 184
      Height = 37
      AutoSize = False
      Caption = 'Integrated Financial Management Information System'
      Color = clWhite
      Font.Charset = ANSI_CHARSET
      Font.Color = 8675134
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      WordWrap = True
    end
    object Label1: TLabel
      Left = 125
      Top = 104
      Width = 54
      Height = 14
      Caption = 'Username'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object Label2: TLabel
      Left = 125
      Top = 131
      Width = 51
      Height = 14
      Caption = 'Password'
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -12
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lbErrorMessage: TLabel
      Left = 14
      Top = 203
      Width = 69
      Height = 13
      Anchors = [akLeft, akBottom]
      Caption = 'Error Message'
      Font.Charset = ANSI_CHARSET
      Font.Color = clRed
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
      Visible = False
    end
    object imgLogo: TImage
      Left = 104
      Top = 23
      Width = 64
      Height = 64
      AutoSize = True
      Picture.Data = {
        0954506E67496D61676589504E470D0A1A0A0000000D49484452000000400000
        00400806000000AA6971DE00000006624B4744000000000000F943BB7F000000
        097048597300000048000000480046C96B3E0000000976704167000000400000
        004000EAF3F8600000196B4944415478DAED5B097854E5B97ECF993593C93249
        26C964230B610B9BB20451B082A8D0B228A54504AAB7EEF5D65E97DBC57A2F7D
        DAC7DADBBA50F569AD7BD5EA05544405AD5A1615109445201248C89E904C92C9
        9ED9CE39F7FBFE33339949220216BDCF73EF0FC9CCFC73CE7FFEEFFDBFEFFDDE
        EF3F2712FE8F37E99B9EC037DD4E170069E9D54BC719148C512549FEA627FD25
        4DD164ADFC95975E29A3F7DA570660D5AA55F141C5BF39A804677FD3969D4933
        1A0CFFB0986DDF7EF6D967BD5F0980E52BBEB7363131E9E61BAEBFDE5C905F00
        59FEDFED00AAAAA2B2B2124F3CF5A4BFA7A7FBA197FFB6EE675F05008900E8BA
        7AF9D5F65917CDFAA66D3BA3B675DB566C78657DC74B2FAE739C3500CB962D4B
        82AC76DCF6A3DB3061FC846FDAA6336A870E1FC2A38F3D8AF5FFFDCA296DFC7F
        00CE14802D6F6FC6840993909D9D3D7020716D20E043574F37521C0E1A548E19
        BDA7BB0B2A1D93989038E41AADED6E24C427C262B1C4CC2A10F0A3B3B31369A9
        6983A629A1A7B787AEA9C09E90A45F9CFA34BA80C12043D3B4AF038089C8CECA
        19B09E9A3FE84717199AE6481D320E03A3692A92C4840703D00A7BBC1D568B35
        A6DFE72740BB68BCB4349A64789A92F8DFD3DD0D95AE9B604F14A4A7D18FF84A
        62F6379D7B00C6130039610FD0F45FFE408026DC81D4547DC29A185A07A79B27
        4C934C4A1A0A80BBD58D4432C462B5C4F4FBFC0468278FE71499478A4AE90CA8
        120C120009110BF4859760367D2D004C404ED64008B0B17E0A0176D9D494349A
        F0C0B0EC92EC193CC3E10068696D110058AD833CC0E74707019A9E964E2B1B35
        4D32B4CDD38A6050A16BA50C324682C9643ED700BC253C203B0A0031612F7340
        17AD582A642976D84E5A49E680E4E4E428AF190680A8D3FC3E1F3AE8BC746706
        A4A855569420DADADB854738A2C22D7C8CD96439F7008C1A3D064E8A4D55F08F
        2666A62AAAE00133AD80A4D1F444BF1E06816040788239B43A5AD485BD3E2FAD
        9A0906D910D3AFA80A116120C40D12C5BC8A0079055F8F0952A3B1CD16B3B886
        0EB8466F25643A33CF3D00A309005E694DBF2CC92F56600A014013A61588F487
        1A1BC23D46238123692110F4576F3F8366846CD43387A4E9AFAA1AA4B00A0ACF
        60FE08122768A1B302FE8098390320852952D243D195EE3AF7008CA7F759311C
        40936297A5984D4B21D23248917E6E7A0890CB260D1565CD2D274576B0C6C5C5
        CCCAC7E37578E0743A857709C8347D5C8FA70D0A7D76D2B506CED169D7628EFB
        1A00289908577656C4425E558E590F19EA4C7322BA60D44200701A4C4E4E1972
        8DE69626022039160030005EB493A1CE681D107AE17ECEFBA961002444526538
        9D9E53004A4A269010CA1A70724DCFDB1D1D2100B860D20642407800B9B1C331
        148093CD4DA0620BB638DB006874AADFEF45635303B25CD97A011645AC020002
        342DD5193122EC1D71D6AFC1034A4AC64742206CA670D9CE766450DA8214A504
        C99A8E100029C388A493CD14028989888B02A0977881737D6F571B7273F3221E
        159E6C1B89276EAC112206E81A893CC0F6F500E06200A25659F7000FA5AD740C
        DE33E9E86817198365F2E02D8AA6931402941E6DA195F3517EAF3DD901BB5543
        77573BF272468484D000DCAD940611E50161EF9084079C630036130045854548
        484888D822D85950BF1A5975689197D0C443C748A134A845FBCFC0748ED77BD0
        EFF5A3C865139F85088A5080AE772561B33410FB927E1CFF1B59587CEE01183B
        662C9CE94E5DEE860CE1D4D4DBD723E299E7C6C64A211BB99F7580DD9E30C4E4
        76F20E3BB9BF99C8CBEDE9C5C7871B503A2E9DD85C12CAD249E99639257C9E4C
        FF587071E36B89BEB050A29F3487F31C03B08542603C7180CB155940F6000E81
        F6760F6CF66424D96365ADA723C401294349B0A9A991247232558356BCBEFD18
        5212ADB8706216FAFAFBD04229322FAF2022ADC3CEC552980175A6A64759A17B
        862D2EFEDC7B80E0804C17C208F0205E122A9BB69763FBC116CC9B9E8FCB4B47
        9051461D008F47B0764ACA000986CB5606209148F0785D173E38D0806BE68F45
        82CDAC03D01C0D801449046D6D3A008203A28CE75FF1717671CCC1037BF0E493
        8FA23475B3F5C78FC0F74FF58071E34B9095E98A39B6BEA503F73DF3094AC7BB
        70A84267E9C517176126AD662709241633A922A7C7B6DADA6AAA046D78667305
        268F7262CED43CD1DFD7D72744525E6EBEA8F3A35B3B91207B148BA4900BA2BF
        F7246A8FBE81C68AB7E1717F8E60A07FE004596A9354ED43CA94EB6515AFDEF1
        10225F7E6500C2B1F9E00B7B11A442E5CE95D349FA6AF8FBC7D578776F0DD293
        6D9837CD85E21C7B8C0770531505C72B8FE160951FFB8EB5E317D795C26A3688
        EFFAC9039AC90346B007446D74E800B4EAF12ED2A084F24F9FC0E19D0FD07126
        8C289C80CC9C42C4C727C264B190D4EE4577671B6A2ACB9496A64A2A38827550
        B45504C2F6B30660F4983154A6A6215482634F59335E7AE7386E5B5A8C829CF4
        88CEEFEEF163F3AE5AEC3ED28C915909583AB708990E9B2E9DA9A009524D7FA2
        B61E6B5FA9C6772F29C2ACC92E212124492F87050992AE8870007FA9F1B83A09
        2650E8D41C5987233BEFC3658BAE47C1E81988A3F081DA4DC7B1D72B7492897E
        38C5DAD049697AEF071BD4C39F6E0D924794100815670540415121317ABC984C
        9F57C1C3EB8F62E6F834CC9EE40C258550D9A2E950B83D5EBCFB690B2A1A7A31
        362F1E178CB113F3EB977EE9FD3A54377B71F7F2221839DF8B6EFD55C240AA93
        2220E8E92E9C063FDF7613665C3815E3CE9B47F2F133684A2D5D37304CB0C713
        16630163215E7B7E8DBFAAE2F89ABB1FC46FCF0A80B1E3C69112CC129F9FDE74
        08D58D5DF8D9EAF3D0D5D5499E417129472B410881A490BBD7B505B1F6E54F51
        DBDC8D15978DC6F4F199B8F5FE7FE097D79E874BA615C644659F0881668C1831
        42AC7CF444590AB3B24AA56B6D5BB71853A64F2400AE20B722008235744DFF50
        63643B24E31868C6226C7CFE5EA5AAA2F2DEB306605C4909323333F179751BD6
        BEB41F77AE9882BC4C1BA53B0F329898224A501355A0DBDD2C5C3A233D43C4F2
        D64FEBF0E4EB87C933FA31262F01BFBD7586D008D100F47B19801602208F38CC
        10F98AA9A0BDBD4DBCE1FDC20F375E87E6BA9D98BBE0071859328B42C042E0F4
        0C0A011655560A8176ECD9B10E65FB7740096837DEBD164F9CB507A491E4FDD5
        13BB509CE7C0EA05E3A878F1EBE52BAD0AD725CCFABC47C0E9CFDDE6A6CF1AD2
        090084422448DFBFBAB512D98E20268FC925D2B2C7143CFD4207B4501ACCD501
        8852830C0003C95965EB4B97C39158899A1A0E0B1B720BC72133BB88004D12E2
        AABFAF5B48EAEA8A23683D5945FD0A129334B5A10E0FDFF920EE3C6300DE6200
        C68EC147653DD8BAAF8E56EF228A67234DB81FAD949F33D3D385215AD46E25E7
        6D91B6D2D3875CA3A6BA4AB8B2DD6E1F0857F046493F9AC9737272A91690A237
        4509004FBB2887D9033EDAB89218733766CDA6B1C8FB6938D21D92C844E11647
        7C939EAE21BF80EA11CAC46FBF09CDEBC51D04C0C3670CC033CF3D8DDC82B1F8
        F9534784EB5F31335FC4B9D7DB4F86B621D39505831CBB21C200300770A114DD
        CFADAEAE86D2631A79407C4C9C33A02DAD6EE4E6E4D27872E83C9D543C1ED601
        21005E5B0577C36E124040119501F9F9BCF7C87B875C5203627B802EE876EBE0
        5456927706892A14DC7DD74378E0AC0038D06046BBD78A5FFDF07CB119C20629
        34226F8A58ACD6502D102A8838A511DCFCD122F6F08070B1A0850C359B4D2476
        74D5188E02853C86C7E332598E143E7A2AF4077496B798CDD8B7653946155691
        A2243156AF1BCBF8737169B6B027F1E2E8631A2892468DE62D3568951578E8AC
        42E02F4F3D89AD47811F2D9F811CA72D54116B621393F704C4EE2E6F8AF246A1
        3052A295F009D6365B2D318286CFEB130098616400429B9B92D8FDA5FA22E023
        6D1F17497DA2917501BFCEF266123A87DEBF1DBDADBB31E75280A388C38039B2
        DFCBC0EB4070C666E7CBCD01AAAA815D3B054E37DCF5009E3C63001E7FF20904
        2CD9B866F10C318A142A08BD0433935366864B4C585F68DDD8F636DD6553D386
        16430D0D8D70389261B3D9A27A09345A3A3785947E0B4E8E687D6E1D5C5B80B7
        C452B163DD22F8FA8E826F3DB0EB8B387750DCDBD84374207A7B4184CA7CA37F
        B6C541E9EBC51A0A81DF9C55089C3F650A49D4DC88E8E1E6F5F9040019E92E92
        A4BA2B8615A1288688F51D915A60C00BC2D5A00EC040D5C77B82BCF3E3A2AA33
        9C0578DB8BBFF3747A8497381C0E7CB06131F25C47894380F27232D48DA1DB0C
        21F7E73D1C52F1F8E453A8C4AFFFF985004CBA46FE1D5DA940826C8A575D4B46
        8E1C89A450ED5D5D53252E2C264CC677D79A11F276C1F45CB8D8B20374E6C02C
        FCC2652904CC962100F4D3925C3AF5BB282D99A37B4EE82BE60D66FB4CAA3906
        CA619D083A3C9D22941CB4D4BB5EFF21E9800F318E441E297418693A94EE695C
        3DF6D913181CDE8E64FD74F02081DE28A274F81098B002532459FE24353D1971
        89A77E1A440A9A613B7E0169F204E45280311196971F8337A70C4A821BA7D39A
        AABA70C5B4AB71DDFC9FC6F4F30D938EF60E6464640A19AC1BAF6F2979DA1AD1
        E92E8349EA47D9EEFB61B3B691973111531890FB534481D787A84580D0DB4759
        A04507252141848A5ADF403AE00FC390E0A4D5D2AB29E9C9DF99B3788AE9CB26
        DF5D6B44D5A678DC75F71DB0C5EB31FCE8238FC254D88C8C52EF979D2EDAC7DB
        0FC1112CC62F57FE25A65FEC319255AC1EF56A90B8A4693F4E1C7C1ACDD5DB89
        2403C38E6732494274895B09A1C6BCCC1A8C53641A15A45B3643233086A6C149
        AB314A53E5A3B3164C924CF11A76BE7318FE5E726B0B0989B106A416E892B4AF
        4D4567930A636D1132025370F7BFDF1519E3D50DAF61DFF1EDE8CCDF09BB5346
        52B62C94B1AF4743CDCE60CC78D3A75C8063076B517BB00B0B47DD714AA0E4EE
        7720F7ED2095578292F32E4046F64872EF64CA047154FBFB29647AE069AD43C5
        E7FB71ECF04714A601CCBC5013C4C844CD24585D4D3AA0E2143A60C24AF96947
        6AD2CA4BBF3BC554D77548081B7F8F04A34583255912354EED6E15DD0D7AA0BA
        94A998943F0BAB56AF8C8CB16BE76EBCFBFE3B289737E92B6293903F5B82395E
        82AF5B8B19AFC03111EDF5FDD8F3DE713C76CB7B34BE21EAA6BA24E29C79A1AB
        653F0EEFB81D4B56DC89FC91E7D10114E40A859846BEAD05F5DA43227E9129D0
        0D19E8E9ECC2AB7FFD35FABA4F8AB061E6E741850E18C5A5F8303A80563F1BAA
        5C3DF3F249C6449701476B0E40F1D1C4ED34D984019CEA0880AE100023B5CB30
        ABF4525C3A6F6EE4FB6A4AB47F7DEE05549AB62008AF00A0E06249BC720B9224
        F075EAC7E6BAF261D192F0DEFA7D78E1DE5DA42B8A865DFDFD3BFE8B6CDD8139
        8B6E87EADD41C6377EB1AB50ED2F59E7A0A9AE0C1B5F7C94247050F001ABF09C
        3C5D0D0EAB0368F51F484E4EFCD779DF9B6ADAFBC91E341EEDA5C992F17609B9
        331888A842A59DD89FE6905AB6188B972CC6C48903CF0FB11EF8FDEF1E4067D6
        2E180B9A91902D45D738A8DBA59270D1017464C6E1A24BA762E3D31FE0B737BE
        880BC6CF1BD6A66307FF86FD5BEFC1CA5B7F4F5C43D414A8A45A807C5A250F00
        7301A74952A03231A0319F18DE89F7363D82A6DA3D983E5DF9721D50B20C2946
        AB5C3F73EE79715945436F606E7F731F5A1A3A70BA2D4B9986043527A6AFCD50
        8E56B9ECB4CEBF66DEEDB861E13D91CF1587D6E1A3376F839562BE74F6551851
        3C1949C929831EC4D06575636D39F6EF7E0B0DD54744011526C3C13AA0B5056B
        28047E2D4698788D613385D1FCECC2343A30363130A3D69D70D3455DC8284822
        D5E5279516447CB2F50B1F9AECFBA01876831373E7CE119FDF7883CAAF440FE2
        A6D70C3976F07827F6B7208E56F2F95FEC8A1CF3D9CEB568A9B89FCAD8008E7E
        2E5129CDF93D95529A037662392F95CEDD9D1DE8ED6A26C51D842B93C2AE40C3
        FE7DC0B4D2281D40D4F119E980C606B24BC6F577FF014FE900AC948E910F151B
        CD438DE19B3D24F3B1F0DAD994628C68EF72A3C7A3A738BBC30A4B5C6CB6644E
        AA797604AEBC7209C64F182FFA9818B7EE780F392BAB235B5BDC7A3ABDE8EFF2
        C364312021350E89D614B49C74E3834D87F0E27FEC41765ABE38AEA67C33DEDF
        B01A2440317A34CB6772E966DE39D6733B3F77416E2D34C088117AEEFFC7FBFA
        C6546EEE201D6017C7C5EA8089ABE417ED4E6945DA18C310005ACA14F134D645
        974DC1898E7DA8F8B0137DA118B63925E4941AC00F6975D568E8A85189A01331
        22300737DF7223E55EBDFC0D13E309F316181D3E248D90114FF9B87E2F557C94
        1E8D94165347CB281C9B85F4F822BCFDFC2EFC70C13D58F6AD9BC5F947F6FC09
        8777FE0A7DBD41216ED8C88C0C5DE5B1E1FCBC0439013A3AF554C72BCD1B4C3E
        3238101CA403488D6F796B900E6000AC09D20A7FDF20112DE42D30E592626415
        3851E1D933ACCB371F52D17E5C0FB6442D8738603AEEB9F7E79110091363BDBC
        133DF249D197522C2363426C0899640B8A534AB177FB61242B05F8E38FDF8800
        50B16F0D4A6728F8FC08EF215036090ECF1F6C6071B14875A8A09CBF68B1AE03
        783FA0AA4AD701A4183545C1BF11006B0500935799D65953D4657129B113F253
        DEEE6E56F1ED5533D1DED78463876A1020900C6609493912E2527577E6FCDE7C
        40677767B0042353A6E3B6DB6E8B19EBA1071F4655CF5EB4198F924092903151
        8639514247B506AF4715B93FCE21E3FCC953E06EE8C29EBF9763E9985FC062A4
        B4E62D83B1EB0591CA264ED24B5B5E6562722AA7799F81EF0A838851DF083946
        015D7698120245A7D188181DC0E0D0315AC571F9913B1F546F97E6CF9F6F694C
        7DF7455B9AB6D49E35E8B676AD4AEE6FC7C50BA6C1DDD180EAF293F0911B1A29
        665373E3604F89250DFEAE77DB5894B866E2AAA557C67CB761DD061C75EF84ED
        E263B0C41B0742ACB217DDED7A7D9F906A46C9F8713068666C7C661B8139FE44
        B252E4CE4D3AEC9A54743CC7EF55E5CE4EDDA51904369A733CAF36F3418787EF
        43EA861615EAE140A5444407E4E6E9FB053B3F22FEE937FD646BD9858F495CF2
        1EB3BEF6B42541BBCADB151B02EC3A1366E5A3784C21B1AB82D36995CFA7E2A2
        D24B70E1453363FA3FFA70273EDCBD1545ABDB4E797E780778FB96BD6A67BD72
        A83070D90385499F966625D7DC3A7F01A4AE2E5DCC34370FACAC081F1397C73A
        3F8CA058DFB3879F2805858D0E8E3B2485F93D7986DAE436DF7FA27BF16F1880
        1402E089F834EDAA94E20112F45491E46D5271A66D74E04A2C5AF41D4C3E7F72
        4CFF817D07B069D39B2837BD7646E315290BFEA538E9C85497BDEA16C2462A2C
        D4C92C933798251D04DEF830D2D4BBBAF515AE38CE4FA7EAE7AB611D20EB3A60
        2CE980EDDB11A86F32FFBE31F0FDFBA4254B96245725BCF994A6A957C5A70DA4
        288E753FA1C58C7D262DB362316EB9E52638D33262FADDADCDF8D39F1EC7C991
        AF9FD638BE4EE2860E0D0581B9374C707E36677C41CBB2E414CD78F4F30102E4
        0D4F91057C3A106163D9ED0B0AA8F6DFAFEB000E01D601EC05BB7643ADA983D2
        E54D9EEE0ECC2B670F883B61DDFC1355F35DA06972E8E10B492240B2554999E4
        1C6738AD09875BCAC145F8C9EDB723CB9515D3DFD8D48887D7AE45FBA44DA735
        0E2F4047B58A5181ABBE97673F30252BB9E2A7D3A612895131D350AF4B5B96B8
        9CDB3935724A4C4ED2DD9FF75FDE7B4F274406A3BB87AEDF48C2B98FC5A3D410
        50136EACEEBD7C4749498957184C20241A8D465330186476628B0D55E6F7AFF2
        4B1D0F9D91F5D043E0E69B6E125BD6D1ADB5B5157F7EFCF1D30E014B9224BC80
        00589265F9E03BF9E92DD751756860C6CF0BE9005B4807F003A40C0489415487
        36456DF1FC089EFE1D892F0F2DEEC741CDB2B1B5A7E4F55EE4F7C4C7C707F9EF
        8984CFAF59B3463E72E448028340B81A48571B8E4B3B96060C5D7FCC9F6D3CAD
        094726FEFE425CFB836BC5430FD18D1F7D7FF6B967E19BFBC6698DD3D3A2A1F5
        A88231FE2BAF70C56D5F9C97DE76FDFC2B3453D9117DFBFB8B74406AAA9EEABA
        7BD9DDA5DA8AE025B3FBFD49FDE88142002A26932918329EEF9D6991A00F81C0
        DB3A9CDB0C278CEF2C0B187A1E8BE685D369394D4BB07CF972582DB10F3E7A49
        96BDFCF2CBA8776D3CAD7124AA497A48838CF62DFD56BCB52ED565FEF86FAE4C
        CD74C10CC8BC51CC3A202604E2F45D615685870E017B3FE13FA9B0FD47BD77F1
        9F29A215FE2161A690280BAC5FBF5E7F7617C33C1F40E1C000C4559ADEFE7E50
        EE7DFC6C00E03A6070A1C41BA6AFBDB6F16C0028550DAA9A613C302EC952F51B
        4D557389FCD49C6CC8BC0BC7F7027C3E1D0C772BD4B636711FC5AFA8D6FBAA7A
        173E027187140AAF7A6F6F2F1B1F93CFBFC83A69E20AD32AC8CA73671302F3AF
        B8822AB658DD602475B2E5EDB7CF3804088089AA51E5FFAAD1E833669A3EFE96
        8CEE054639308D5C3A256C03194D394B3E1A548CAF7B83991BDA31AB9E57DC60
        3028C319FE650060C2358615940B5E3C23EBA193E0A9DA99EA80B18145238306
        83665215D52FCB9A995E15857E5B14354E6B37D8A59A547F30ADDD2717F70402
        014E84ECE66A63636360E1C2850A85F629C5CC170250B21A79B266288DEE2395
        2653696C30CA260395C904B02CF1AB815FF98E16FDA468A3A60AE7D7536AF809
        4FF11DBFF3182AF79DD262FE530349D79D7CDB716470D61B7EA351B32841D56B
        3468D6A055A56CA51299696CB0CFE753939292545EE9EAEAEAE0B66DDBF8D42F
        FD93D92F05E074CE25BE901D0E87ECF7FB0DE46646B3D9CCEF259A9C4C939368
        A2627CABD51A79CF2D680DC65CD7E83546264C9948A315D4F8958DECEBEB13AF
        34B6D6DDDDAD858DA5EB89D526D756CFC4E07F26005F3826B99D44194562703C
        1E8FE476BB65A7D329AE45C649C9C9C991F7FC4AC70937A56335222BADB9B959
        B3DBED1AF56BC78E1DD3E85C2D6428BE8AB1C3B5FF01F480E36F16CE94060000
        003D74455874636F6D6D656E74004D6F6E657920656D626C656D203634206672
        6F6D2049636F6E2047616C6C65727920687474703A2F2F69636F6E67616C2E63
        6F6D2F7E8A18850000002574455874646174653A63726561746500323031312D
        30382D32315431323A32363A31332D30363A3030B8F51CA50000002574455874
        646174653A6D6F6469667900323031312D30382D32315431323A32363A31332D
        30363A3030C9A8A4190000000049454E44AE426082}
    end
    object prbStatus: TRzProgressBar
      Left = 14
      Top = 210
      Width = 406
      Height = 6
      Anchors = [akLeft, akBottom]
      BarColor = 13479828
      BarColorStop = 13282190
      BarStyle = bsGradient
      BorderOuter = fsFlat
      BorderWidth = 0
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 13479828
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      InteriorOffset = 0
      ParentFont = False
      PartsComplete = 0
      Percent = 0
      ShowPercent = False
      ThemeAware = False
      TotalParts = 0
      Visible = False
    end
    object lblStatus: TLabel
      Left = 14
      Top = 195
      Width = 3
      Height = 13
      Anchors = [akLeft, akBottom]
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentFont = False
    end
    object lblVersion: TLabel
      Left = 176
      Top = 204
      Width = 243
      Height = 12
      Alignment = taRightJustify
      Anchors = [akRight, akBottom]
      AutoSize = False
      Caption = 'Version 1.0.0.0'
      Color = clWhite
      Font.Charset = ANSI_CHARSET
      Font.Color = 8675134
      Font.Height = -11
      Font.Name = 'Tahoma'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      WordWrap = True
    end
    object edUsername: TRzEdit
      Left = 189
      Top = 98
      Width = 121
      Height = 22
      Text = ''
      CharCase = ecUpperCase
      DisabledColor = 15327448
      FrameColor = 14272955
      FrameVisible = True
      FramingPreference = fpCustomFraming
      TabOnEnter = True
      TabOrder = 0
      OnChange = edUsernameChange
    end
    object edPassword: TRzEdit
      Left = 189
      Top = 125
      Width = 121
      Height = 22
      Text = ''
      DisabledColor = 15327448
      FrameColor = 14272955
      FrameVisible = True
      FramingPreference = fpCustomFraming
      PasswordChar = '*'
      TabOrder = 1
      OnKeyPress = edPasswordKeyPress
    end
    object pnlClose: TRzPanel
      Left = 227
      Top = 164
      Width = 50
      Height = 22
      Anchors = [akLeft, akBottom]
      BorderOuter = fsNone
      BorderColor = 14272955
      BorderWidth = 1
      Color = 15327448
      TabOrder = 2
      object btnClose: TRzShapeButton
        Left = 0
        Top = 0
        Width = 50
        Height = 22
        BorderStyle = bsNone
        Caption = 'Close'
        OnClick = btnCloseClick
      end
    end
    object pnlLogin: TRzPanel
      Left = 171
      Top = 164
      Width = 50
      Height = 22
      Anchors = [akLeft, akBottom]
      BorderOuter = fsNone
      BorderColor = 14272955
      BorderWidth = 1
      Color = 15327448
      TabOrder = 3
      object btnLogin: TRzShapeButton
        Left = 0
        Top = 0
        Width = 50
        Height = 22
        BorderStyle = bsNone
        Caption = 'Login'
        OnClick = btnLoginClick
      end
    end
  end
end
