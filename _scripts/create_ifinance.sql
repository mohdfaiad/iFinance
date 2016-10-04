USE [master]
GO
/****** Object:  Database [iFinance]    Script Date: 5/10/2016 12:47:42 AM ******/
CREATE DATABASE [iFinance]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'FMS', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL11.DEVELOPMENT\MSSQL\DATA\FMS.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'FMS_log', FILENAME = N'c:\Program Files\Microsoft SQL Server\MSSQL11.DEVELOPMENT\MSSQL\DATA\FMS_log.ldf' , SIZE = 3456KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
GO
ALTER DATABASE [iFinance] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [iFinance].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [iFinance] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [iFinance] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [iFinance] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [iFinance] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [iFinance] SET ARITHABORT OFF 
GO
ALTER DATABASE [iFinance] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [iFinance] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [iFinance] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [iFinance] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [iFinance] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [iFinance] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [iFinance] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [iFinance] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [iFinance] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [iFinance] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [iFinance] SET  DISABLE_BROKER 
GO
ALTER DATABASE [iFinance] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [iFinance] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [iFinance] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [iFinance] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [iFinance] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [iFinance] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [iFinance] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [iFinance] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [iFinance] SET  MULTI_USER 
GO
ALTER DATABASE [iFinance] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [iFinance] SET DB_CHAINING OFF 
GO
ALTER DATABASE [iFinance] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [iFinance] SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
USE [iFinance]
GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_acct_info]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_cl_get_acct_info]
	@entity_id char(10)
AS
BEGIN
	select A.*,
	       B.*,
		   T.bank_name bank_name
	  from AcctInfo (nolock) A
 left join Bank (nolock) B
        on B.bank_id = A.bank_id
 left join T_Bank (nolock) T
        on T.bank_code = B.bank_code
	 where entity_id = @entity_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_address_info_pres]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_cl_get_address_info_pres]
	@entity_id char(10)
AS
BEGIN
	select A.*,
	       (select P.lastname + ', ' + P.firstname from PersonalInfo P (nolock) where P.entity_id = A.landlord) landlord_name,
		   (select mobile_no from ContactInfo C (nolock) where C.entity_id = A.landlord) landlord_mobile,
		   (select home_phone from ContactInfo C (nolock) where C.entity_id = A.landlord) landlord_homephone
	  from AddressInfo (nolock) A
	 where A.entity_id = @entity_id
	   and isnull(is_prov,0) = 0
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_address_info_prov]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[sp_cl_get_address_info_prov]
	@entity_id char(10)
AS
BEGIN
	select A.*,
	       (select P.lastname + ', ' + P.firstname from PersonalInfo P (nolock) where P.entity_id = A.landlord) landlord_name,
		   (select mobile_no from ContactInfo C (nolock) where C.entity_id = A.landlord) landlord_mobile,
		   (select home_phone from ContactInfo C (nolock) where C.entity_id = A.landlord) landlord_homephone
	  from AddressInfo (nolock) A
	 where A.entity_id = @entity_id
	   and isnull(is_prov,0) = 1
END


GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_contact_info]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_cl_get_contact_info]
	@entity_id char(10)
AS
BEGIN
	select *
	  from ContactInfo (nolock)
	 where entity_id = @entity_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_empl_info]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_cl_get_empl_info]
	@entity_id char(10)
AS
BEGIN
	select I.*,
	       E.emp_name,
		   E.emp_add,
		   E.grp_id,
		   (P.lastname + ', ' + P.firstname) imm_head_name
	  from EmplInfo (nolock) I
 left join Employer (nolock) E
	    on E.emp_id = I.emp_id 
 left join PersonalInfo (nolock) P
	    on P.entity_id = I.imm_head
	 where I.entity_id = @entity_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_entity]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_cl_get_entity]
	@entity_id char(10)
AS
BEGIN
	select E.*,
	       (select P.lastname + ', ' + P.firstname from PersonalInfo P (nolock) where P.entity_id = E.ref_entity_id) referee
	  from Entity (nolock) E
	 where E.entity_id = @entity_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_ident_info]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_cl_get_ident_info]
	@entity_id char(10)
AS
BEGIN
	select I.*,
	       T.ident_name,
	       T.has_expiry,
		   isnull(exp_date,getdate()) exp_date_computed
	  from IdentityInfo (nolock) I
	  join T_IdentityType T (nolock)
	    on T.ident_type = I.ident_type
	 where entity_id = @entity_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_personal_info]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_cl_get_personal_info]
	@entity_id char(10)
AS
BEGIN
	select *
	  from PersonalInfo (nolock)
	 where entity_id = @entity_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_ref_info]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_cl_get_ref_info]
	@entity_id char(10)
AS
BEGIN
	select R.*,
	       (P.lastname + ', ' + P.firstname) name,
		   T.ref_name,
		   T.is_family
	  from RefInfo (nolock) R
	  join PersonalInfo (nolock) P
	    on R.ref_entity_id = P.entity_id
	  join T_ReferenceType (nolock) T
	    on T.ref_type = R.ref_type
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_civil_status]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_dd_get_civil_status]
AS
BEGIN
	declare @temp_civil_status table(
		value char(1),
		display varchar(12)
	)
	
	insert @temp_civil_status
	select 'S','Single'
	union
	select 'M','Married'
	union
	select 'P','Separated'
	union
	select 'W','Widowed'
	union
	select 'A','Annulled'
	
	select * 
	  from @temp_civil_status
END


GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_employment_status]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_dd_get_employment_status]
AS
BEGIN
	declare @temp_employement_status table(
		value char(1),
		display varchar(20)
	)
	
	insert @temp_employement_status
	select 'R','Regular/Permanent'
	union
	select 'C','Contractual'
	union
	select 'M','Commission-based'
	
	select * 
	  from @temp_employement_status
END


GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_gender]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_dd_get_gender]
AS
BEGIN
	declare @temp_gender table(
		value char(1),
		display varchar(12)
	)
	
	insert @temp_gender
	select 'M','Male'
	union
	select 'F','Female'
	
	select * 
	  from @temp_gender
END


GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_ident_type]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_ident_type]
AS
BEGIN
	select *
	  from T_IdentityType I (nolock)
  order by I.ident_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_loan_type]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_loan_type]
AS
BEGIN
	select *
	  from T_LoanType (nolock)
	 where isnull(is_active,0) = 1
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_ref_type]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_ref_type]
AS
BEGIN
	select *
	  from T_ReferenceType (nolock)
  order by ref_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_residence_status]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_residence_status]
AS
BEGIN
	declare @temp_residence_status table(
		value char(1),
		display varchar(20)
	)
	
	insert @temp_residence_status
	select 'O','Owned'
	union
	select 'L','Living with parents'
	union
	select 'M','Mortgaged'
	union
	select 'R','Rented'
	
	select * 
	  from @temp_residence_status
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_towns]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_towns]
AS
BEGIN
	select post_code,
	       town
	  from T_Town (nolock)
  order by town 
END

GO
/****** Object:  StoredProcedure [dbo].[sp_gen_id]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_gen_id]
(
	@seq_object char(3)
)
as
begin
	set xact_abort on

	declare @id int

	select @id = last_id + 1
	  from dbo.Sequence (nolock)
	 where seq_object = @seq_object
	 
	 if isnull(@id,0) = 0 
	 begin
	    select @id = 
			case when @seq_object = 'ENT' then 10001 -- entity
				 when @seq_object = 'GRP' then 101   -- group
				 when @seq_object = 'EML' then 101   -- employer
				 when @seq_object = 'BNK' then  101  -- bank
				 when @seq_object = 'DSG' then 101 -- designation
				 else 0
			end

		insert into Sequence values (@seq_object, @id)

	 end
	 else
	 begin
		-- update the ID
		update Sequence
		   set last_id = @id
		 where seq_object = @seq_object
	 end

	 set xact_abort off

	 select last_id
	   from Sequence
	  where seq_object = @seq_object  
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_bank_branches]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_bank_branches]
AS
BEGIN
	select *,
	       (select bank_name from T_Bank T (nolock) where T.bank_code = B.bank_code) bank_name
	  from Bank (nolock) B 
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_banks]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_get_banks]
as
BEGIN
	select *
	  from T_Bank (nolock) B
  order by B.bank_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_clients]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_clients]
	@filter_type int = 0,
	@non_clients int = 0
AS
BEGIN
	-- filter types
	-- 0 = all
	-- 1 = active
	-- 2 = recent

	declare @sql varchar(max),
	        @where varchar(max),
			@order varchar(100) = ' order by name'

	set @sql = 'select E.entity_id,
					   (P.lastname + '', '' + P.firstname + '' '' + substring(isnull(P.middlename,''''),1,1)) name,
					   P.lastname,
					   P.firstname,
					   P.middlename
				  from Entity E (nolock)
				  join PersonalInfo P (nolock)
					on P.entity_id = E.entity_id '

	 -- get active loans
	 select count(*) active_loans,
	        entity_id
	   into #ActiveLoans
	   from Loan L (nolock)
   group by entity_id

	 -- where clause
	 select @where = (
						case when @filter_type = 0 then '' 
						     when @filter_type = 1 then ' where exists (select * from #ActiveLoans A where A.entity_id = E.entity_id)' 
							 when @filter_type = 2 then ' where created_date = cast(getdate() as date)'
							 else ''
						end

					 )

	set @sql = @sql + @where + @order
	
	execute(@sql)

	drop table #ActiveLoans

END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_designations]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_designations]
AS
BEGIN
	select *
	  from T_Designation (nolock)
  order by designation
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_employers]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_employers]
AS
BEGIN
	select *
	  from Employer E (nolock)
  order by E.emp_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_entities]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_entities]
	@entity_type char(2) = 'CL'
AS
BEGIN
	select E.entity_id,
	       (P.lastname + ', ' + P.firstname + ' ' + substring(isnull(P.middlename,''),1,1)) name,
		   P.lastname,
		   P.firstname,
		   P.middlename,
		   C.mobile_no,
		   C.home_phone
	  from Entity E (nolock)
	  join PersonalInfo P (nolock)
	    on P.entity_id = E.entity_id
 left join ContactInfo C (nolock)
        on C.entity_id = E.entity_id
     where isnull(@entity_type,'') = '' 
	    or E.entity_type = @entity_type
  order by name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_groups]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_groups]	
AS
BEGIN
	select *
	  from [Group] (nolock) G
  order by G.grp_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_loan_class]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_loan_class]
AS
BEGIN
	select *
	  from LoanClass (nolock)
END

GO
/****** Object:  UserDefinedFunction [dbo].[fn_get_empl_no]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fn_get_empl_no] 
(
	@entity_id char(9)
)
RETURNS int
AS
BEGIN
    declare @empl_no int

	select @empl_no = max(empl_no)
	  from EmplInfo (nolock)
	 where entity_id = @entity_id

	return isnull(@empl_no,0) + 1

END

GO
/****** Object:  Table [dbo].[AcctInfo]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AcctInfo](
	[acct_no] [varchar](15) NULL,
	[entity_id] [char](10) NOT NULL,
	[bank_id] [char](8) NULL,
	[card_no] [varchar](15) NULL,
 CONSTRAINT [PK_AcctInfo] PRIMARY KEY CLUSTERED 
(
	[entity_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AddressInfo]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AddressInfo](
	[entity_id] [char](10) NOT NULL,
	[st] [varchar](50) NULL,
	[brgy] [varchar](50) NULL,
	[post_code] [smallint] NULL,
	[res_status] [char](1) NULL,
	[landlord] [char](10) NULL,
	[is_prov] [smallint] NOT NULL,
 CONSTRAINT [PK_AddressInfo] PRIMARY KEY CLUSTERED 
(
	[entity_id] ASC,
	[is_prov] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Bank]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Bank](
	[bank_id] [char](8) NOT NULL,
	[bank_code] [char](5) NOT NULL,
	[branch] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Bank] PRIMARY KEY CLUSTERED 
(
	[bank_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ContactInfo]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ContactInfo](
	[entity_id] [char](10) NOT NULL,
	[email_add] [varchar](30) NULL,
	[fb_acct] [varchar](50) NULL,
	[mobile_no] [char](12) NULL,
	[home_phone] [char](12) NULL,
 CONSTRAINT [PK_ContactInfo] PRIMARY KEY CLUSTERED 
(
	[entity_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EmplInfo]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmplInfo](
	[entity_id] [char](10) NOT NULL,
	[emp_id] [char](8) NULL,
	[emp_status] [char](1) NULL,
	[date_from] [date] NULL,
	[date_until] [date] NULL,
	[gross_pay] [decimal](8, 2) NULL,
	[serv_len] [smallint] NULL,
	[imm_head] [char](10) NULL,
	[net_pay] [decimal](8, 2) NULL,
	[des_id] [int] NULL,
 CONSTRAINT [PK_EmplInfo] PRIMARY KEY CLUSTERED 
(
	[entity_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Employer]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Employer](
	[emp_id] [char](8) NOT NULL,
	[emp_name] [varchar](50) NOT NULL,
	[grp_id] [smallint] NULL,
	[loc_code] [char](3) NULL,
	[emp_add] [varchar](50) NULL,
 CONSTRAINT [PK_Employer] PRIMARY KEY CLUSTERED 
(
	[emp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Entity]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Entity](
	[entity_id] [char](10) NOT NULL,
	[entity_type] [char](2) NOT NULL,
	[ref_entity_id] [char](10) NULL,
	[created_date] [date] NULL,
	[created_by] [varchar](12) NULL,
 CONSTRAINT [PK_Entity] PRIMARY KEY CLUSTERED 
(
	[entity_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ExpenseInfo]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ExpenseInfo](
	[loan_id] [char](13) NOT NULL,
	[expense_type] [char](3) NOT NULL,
	[amount] [decimal](8, 2) NOT NULL,
 CONSTRAINT [PK_ExpenseInfo] PRIMARY KEY CLUSTERED 
(
	[loan_id] ASC,
	[expense_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Group]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Group](
	[grp_id] [smallint] NOT NULL,
	[grp_name] [varchar](25) NOT NULL,
	[is_gov] [tinyint] NOT NULL,
	[is_active] [tinyint] NOT NULL,
	[par_grp_id] [smallint] NULL,
 CONSTRAINT [PK_EmpGroup] PRIMARY KEY CLUSTERED 
(
	[grp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IdentityInfo]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[IdentityInfo](
	[entity_id] [char](10) NOT NULL,
	[ident_type] [char](2) NOT NULL,
	[ident_no] [varchar](15) NOT NULL,
	[exp_date] [datetime] NULL,
 CONSTRAINT [PK_IdentityInfo] PRIMARY KEY CLUSTERED 
(
	[entity_id] ASC,
	[ident_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Loan]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Loan](
	[loan_id] [char](13) NOT NULL,
	[amt_appl] [decimal](10, 2) NOT NULL,
	[des_term] [smallint] NOT NULL,
	[purpose] [varchar](20) NOT NULL,
	[entity_id] [char](10) NOT NULL,
	[amt_appv] [decimal](10, 2) NULL,
	[date_appl] [date] NOT NULL,
	[loan_type] [char](2) NOT NULL,
	[int] [float] NOT NULL,
	[terms] [smallint] NOT NULL,
	[date_appv] [date] NULL,
	[date_rel] [date] NULL,
	[rel_branch] [char](3) NULL,
	[orig_branch] [char](3) NOT NULL,
 CONSTRAINT [PK_Loan] PRIMARY KEY CLUSTERED 
(
	[loan_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoanClass]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoanClass](
	[class_id] [int] NOT NULL,
	[class_name] [varchar](25) NOT NULL,
	[int_rate] [float] NOT NULL,
	[term] [tinyint] NULL,
	[loan_type] [char](2) NOT NULL,
	[valid_from] [datetime] NOT NULL,
	[valid_until] [datetime] NULL,
 CONSTRAINT [PK_LoanClass] PRIMARY KEY CLUSTERED 
(
	[class_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoanClassGroup]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoanClassGroup](
	[class_id] [int] NOT NULL,
	[grp_id] [smallint] NOT NULL,
 CONSTRAINT [PK_LoanClassGroup] PRIMARY KEY CLUSTERED 
(
	[class_id] ASC,
	[grp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LoanClassLoc]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoanClassLoc](
	[class_id] [int] NOT NULL,
	[loc_code] [char](3) NOT NULL,
 CONSTRAINT [PK_LoanClassLoc] PRIMARY KEY CLUSTERED 
(
	[class_id] ASC,
	[loc_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PersonalInfo]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PersonalInfo](
	[entity_id] [char](10) NOT NULL,
	[lastname] [varchar](50) NOT NULL,
	[firstname] [varchar](50) NOT NULL,
	[middlename] [varchar](50) NULL,
	[birth_date] [datetime] NULL,
	[gender] [char](1) NULL,
	[civil_status] [char](1) NULL,
	[photo] [varchar](25) NULL,
 CONSTRAINT [PK_PersonalInfo] PRIMARY KEY CLUSTERED 
(
	[entity_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RefInfo]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[RefInfo](
	[entity_id] [char](10) NOT NULL,
	[ref_entity_id] [char](10) NOT NULL,
	[ref_type] [char](2) NOT NULL,
	[is_dependent] [tinyint] NOT NULL,
	[is_student] [tinyint] NOT NULL,
 CONSTRAINT [PK_RefInfo] PRIMARY KEY CLUSTERED 
(
	[entity_id] ASC,
	[ref_entity_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Sequence]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Sequence](
	[seq_object] [char](3) NOT NULL,
	[last_id] [int] NOT NULL,
 CONSTRAINT [PK_Sequence] PRIMARY KEY CLUSTERED 
(
	[seq_object] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Bank]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Bank](
	[bank_code] [char](5) NOT NULL,
	[bank_name] [varchar](30) NOT NULL,
 CONSTRAINT [PK_T_Bank_1] PRIMARY KEY CLUSTERED 
(
	[bank_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Designation]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Designation](
	[des_id] [int] NOT NULL,
	[designation] [varchar](25) NULL,
 CONSTRAINT [PK_T_Designation] PRIMARY KEY CLUSTERED 
(
	[des_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_EntityType]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_EntityType](
	[entity_type] [char](2) NOT NULL,
	[entity_name] [varchar](25) NOT NULL,
	[entity_desc] [varchar](100) NULL,
	[is_active] [smallint] NOT NULL,
	[is_client] [smallint] NOT NULL,
	[is_person] [smallint] NOT NULL,
 CONSTRAINT [PK_T_Entity] PRIMARY KEY CLUSTERED 
(
	[entity_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_ExpenseType]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_ExpenseType](
	[expense_type] [char](3) NOT NULL,
	[expense_name] [varchar](25) NOT NULL,
	[expense_desc] [varchar](100) NULL,
 CONSTRAINT [PK_T_Expense] PRIMARY KEY CLUSTERED 
(
	[expense_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_IdentityType]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_IdentityType](
	[ident_type] [char](2) NOT NULL,
	[ident_name] [varchar](25) NOT NULL,
	[ident_desc] [varchar](100) NULL,
	[has_expiry] [tinyint] NOT NULL,
 CONSTRAINT [PK_T_IdentityType] PRIMARY KEY CLUSTERED 
(
	[ident_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_LoanType]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_LoanType](
	[loan_type] [char](2) NOT NULL,
	[loan_name] [varchar](25) NULL,
	[int] [float] NULL,
	[max_term] [smallint] NULL,
	[max_loan] [float] NULL,
	[is_active] [smallint] NULL,
	[co_makers] [tinyint] NULL,
 CONSTRAINT [PK_T_LoanType] PRIMARY KEY CLUSTERED 
(
	[loan_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_ReferenceType]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_ReferenceType](
	[ref_type] [char](2) NOT NULL,
	[ref_name] [varchar](25) NOT NULL,
	[ref_desc] [varchar](100) NULL,
	[is_family] [tinyint] NOT NULL,
	[max] [tinyint] NOT NULL,
 CONSTRAINT [PK_T_Reference] PRIMARY KEY CLUSTERED 
(
	[ref_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Town]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Town](
	[post_code] [smallint] NOT NULL,
	[town] [varchar](25) NULL,
 CONSTRAINT [PK_T_Town] PRIMARY KEY CLUSTERED 
(
	[post_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Term]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Term](
	[term_id] [int] NOT NULL,
	[loan_type] [char](2) NOT NULL,
	[int] [float] NOT NULL,
	[period] [smallint] NOT NULL,
	[grp_id] [int] NOT NULL,
 CONSTRAINT [PK_Term] PRIMARY KEY CLUSTERED 
(
	[term_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [dbo].[AddressInfo] ADD  CONSTRAINT [DF_AddressInfo_is_prov]  DEFAULT ((0)) FOR [is_prov]
GO
ALTER TABLE [dbo].[EmplInfo] ADD  CONSTRAINT [DF_EmplInfo_empl_no]  DEFAULT ((0)) FOR [emp_id]
GO
ALTER TABLE [dbo].[Entity] ADD  CONSTRAINT [DF_Entity_entity_type]  DEFAULT ('CL') FOR [entity_type]
GO
ALTER TABLE [dbo].[Group] ADD  CONSTRAINT [DF_EmpGroup_is_gov]  DEFAULT ((1)) FOR [is_gov]
GO
ALTER TABLE [dbo].[Group] ADD  CONSTRAINT [DF_EmpGroup_is_active]  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[RefInfo] ADD  CONSTRAINT [DF_RefInfo_is_dependent]  DEFAULT ((0)) FOR [is_dependent]
GO
ALTER TABLE [dbo].[RefInfo] ADD  CONSTRAINT [DF_RefInfo_is_student]  DEFAULT ((0)) FOR [is_student]
GO
ALTER TABLE [dbo].[T_EntityType] ADD  CONSTRAINT [DF_T_Entity_is_valid]  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[T_EntityType] ADD  CONSTRAINT [DF_T_EntityType_is_client]  DEFAULT ((1)) FOR [is_client]
GO
ALTER TABLE [dbo].[T_EntityType] ADD  CONSTRAINT [DF_T_EntityType_is_individual]  DEFAULT ((1)) FOR [is_person]
GO
ALTER TABLE [dbo].[T_IdentityType] ADD  CONSTRAINT [DF_T_IdentityType_has_expiry]  DEFAULT ((0)) FOR [has_expiry]
GO
ALTER TABLE [dbo].[T_LoanType] ADD  CONSTRAINT [DF_T_LoanType_is_active]  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[T_LoanType] ADD  CONSTRAINT [DF_T_LoanType_co_makers]  DEFAULT ((0)) FOR [co_makers]
GO
ALTER TABLE [dbo].[T_ReferenceType] ADD  CONSTRAINT [DF_T_ReferenceType_is_family]  DEFAULT ((0)) FOR [is_family]
GO
ALTER TABLE [dbo].[T_ReferenceType] ADD  CONSTRAINT [DF_T_ReferenceType_max]  DEFAULT ((0)) FOR [max]
GO
ALTER TABLE [dbo].[AcctInfo]  WITH CHECK ADD  CONSTRAINT [FK_AcctInfo_Bank] FOREIGN KEY([bank_id])
REFERENCES [dbo].[Bank] ([bank_id])
GO
ALTER TABLE [dbo].[AcctInfo] CHECK CONSTRAINT [FK_AcctInfo_Bank]
GO
ALTER TABLE [dbo].[AcctInfo]  WITH CHECK ADD  CONSTRAINT [FK_AcctInfo_Entity] FOREIGN KEY([entity_id])
REFERENCES [dbo].[Entity] ([entity_id])
GO
ALTER TABLE [dbo].[AcctInfo] CHECK CONSTRAINT [FK_AcctInfo_Entity]
GO
ALTER TABLE [dbo].[AddressInfo]  WITH CHECK ADD  CONSTRAINT [FK_AddressInfo_Entity] FOREIGN KEY([entity_id])
REFERENCES [dbo].[Entity] ([entity_id])
GO
ALTER TABLE [dbo].[AddressInfo] CHECK CONSTRAINT [FK_AddressInfo_Entity]
GO
ALTER TABLE [dbo].[AddressInfo]  WITH CHECK ADD  CONSTRAINT [FK_AddressInfo_Landlord] FOREIGN KEY([landlord])
REFERENCES [dbo].[Entity] ([entity_id])
GO
ALTER TABLE [dbo].[AddressInfo] CHECK CONSTRAINT [FK_AddressInfo_Landlord]
GO
ALTER TABLE [dbo].[AddressInfo]  WITH CHECK ADD  CONSTRAINT [FK_AddressInfo_T_Town] FOREIGN KEY([post_code])
REFERENCES [dbo].[T_Town] ([post_code])
GO
ALTER TABLE [dbo].[AddressInfo] CHECK CONSTRAINT [FK_AddressInfo_T_Town]
GO
ALTER TABLE [dbo].[Bank]  WITH CHECK ADD  CONSTRAINT [FK_Bank_T_Bank] FOREIGN KEY([bank_code])
REFERENCES [dbo].[T_Bank] ([bank_code])
GO
ALTER TABLE [dbo].[Bank] CHECK CONSTRAINT [FK_Bank_T_Bank]
GO
ALTER TABLE [dbo].[ContactInfo]  WITH CHECK ADD  CONSTRAINT [FK_ContactInfo_Entity] FOREIGN KEY([entity_id])
REFERENCES [dbo].[Entity] ([entity_id])
GO
ALTER TABLE [dbo].[ContactInfo] CHECK CONSTRAINT [FK_ContactInfo_Entity]
GO
ALTER TABLE [dbo].[EmplInfo]  WITH CHECK ADD  CONSTRAINT [FK_EmplInfo_Employer] FOREIGN KEY([emp_id])
REFERENCES [dbo].[Employer] ([emp_id])
GO
ALTER TABLE [dbo].[EmplInfo] CHECK CONSTRAINT [FK_EmplInfo_Employer]
GO
ALTER TABLE [dbo].[EmplInfo]  WITH CHECK ADD  CONSTRAINT [FK_EmplInfo_Entity] FOREIGN KEY([entity_id])
REFERENCES [dbo].[Entity] ([entity_id])
GO
ALTER TABLE [dbo].[EmplInfo] CHECK CONSTRAINT [FK_EmplInfo_Entity]
GO
ALTER TABLE [dbo].[EmplInfo]  WITH CHECK ADD  CONSTRAINT [FK_EmplInfo_ImmHead] FOREIGN KEY([imm_head])
REFERENCES [dbo].[Entity] ([entity_id])
GO
ALTER TABLE [dbo].[EmplInfo] CHECK CONSTRAINT [FK_EmplInfo_ImmHead]
GO
ALTER TABLE [dbo].[EmplInfo]  WITH CHECK ADD  CONSTRAINT [FK_EmplInfo_T_Designation] FOREIGN KEY([des_id])
REFERENCES [dbo].[T_Designation] ([des_id])
GO
ALTER TABLE [dbo].[EmplInfo] CHECK CONSTRAINT [FK_EmplInfo_T_Designation]
GO
ALTER TABLE [dbo].[Entity]  WITH CHECK ADD  CONSTRAINT [FK_Entity_T_EntityType] FOREIGN KEY([entity_type])
REFERENCES [dbo].[T_EntityType] ([entity_type])
GO
ALTER TABLE [dbo].[Entity] CHECK CONSTRAINT [FK_Entity_T_EntityType]
GO
ALTER TABLE [dbo].[ExpenseInfo]  WITH CHECK ADD  CONSTRAINT [FK_ExpenseInfo_Loan] FOREIGN KEY([loan_id])
REFERENCES [dbo].[Loan] ([loan_id])
GO
ALTER TABLE [dbo].[ExpenseInfo] CHECK CONSTRAINT [FK_ExpenseInfo_Loan]
GO
ALTER TABLE [dbo].[ExpenseInfo]  WITH CHECK ADD  CONSTRAINT [FK_ExpenseInfo_T_ExpenseType] FOREIGN KEY([expense_type])
REFERENCES [dbo].[T_ExpenseType] ([expense_type])
GO
ALTER TABLE [dbo].[ExpenseInfo] CHECK CONSTRAINT [FK_ExpenseInfo_T_ExpenseType]
GO
ALTER TABLE [dbo].[IdentityInfo]  WITH CHECK ADD  CONSTRAINT [FK_IdentityInfo_Entity] FOREIGN KEY([entity_id])
REFERENCES [dbo].[Entity] ([entity_id])
GO
ALTER TABLE [dbo].[IdentityInfo] CHECK CONSTRAINT [FK_IdentityInfo_Entity]
GO
ALTER TABLE [dbo].[Loan]  WITH CHECK ADD  CONSTRAINT [FK_Loan_Entity] FOREIGN KEY([entity_id])
REFERENCES [dbo].[Entity] ([entity_id])
GO
ALTER TABLE [dbo].[Loan] CHECK CONSTRAINT [FK_Loan_Entity]
GO
ALTER TABLE [dbo].[Loan]  WITH CHECK ADD  CONSTRAINT [FK_Loan_T_LoanType] FOREIGN KEY([loan_type])
REFERENCES [dbo].[T_LoanType] ([loan_type])
GO
ALTER TABLE [dbo].[Loan] CHECK CONSTRAINT [FK_Loan_T_LoanType]
GO
ALTER TABLE [dbo].[LoanClass]  WITH CHECK ADD  CONSTRAINT [FK_LoanClass_T_LoanType] FOREIGN KEY([loan_type])
REFERENCES [dbo].[T_LoanType] ([loan_type])
GO
ALTER TABLE [dbo].[LoanClass] CHECK CONSTRAINT [FK_LoanClass_T_LoanType]
GO
ALTER TABLE [dbo].[LoanClassGroup]  WITH CHECK ADD  CONSTRAINT [FK_LoanClassGroup_Group] FOREIGN KEY([grp_id])
REFERENCES [dbo].[Group] ([grp_id])
GO
ALTER TABLE [dbo].[LoanClassGroup] CHECK CONSTRAINT [FK_LoanClassGroup_Group]
GO
ALTER TABLE [dbo].[LoanClassGroup]  WITH CHECK ADD  CONSTRAINT [FK_LoanClassGroup_LoanClass] FOREIGN KEY([class_id])
REFERENCES [dbo].[LoanClass] ([class_id])
GO
ALTER TABLE [dbo].[LoanClassGroup] CHECK CONSTRAINT [FK_LoanClassGroup_LoanClass]
GO
ALTER TABLE [dbo].[LoanClassLoc]  WITH CHECK ADD  CONSTRAINT [FK_LoanClassLoc_LoanClass] FOREIGN KEY([class_id])
REFERENCES [dbo].[LoanClass] ([class_id])
GO
ALTER TABLE [dbo].[LoanClassLoc] CHECK CONSTRAINT [FK_LoanClassLoc_LoanClass]
GO
ALTER TABLE [dbo].[PersonalInfo]  WITH CHECK ADD  CONSTRAINT [FK_PersonalInfo_Client] FOREIGN KEY([entity_id])
REFERENCES [dbo].[Entity] ([entity_id])
GO
ALTER TABLE [dbo].[PersonalInfo] CHECK CONSTRAINT [FK_PersonalInfo_Client]
GO
ALTER TABLE [dbo].[RefInfo]  WITH CHECK ADD  CONSTRAINT [FK_RefInfo_Entity] FOREIGN KEY([entity_id])
REFERENCES [dbo].[Entity] ([entity_id])
GO
ALTER TABLE [dbo].[RefInfo] CHECK CONSTRAINT [FK_RefInfo_Entity]
GO
ALTER TABLE [dbo].[RefInfo]  WITH CHECK ADD  CONSTRAINT [FK_RefInfo_EntityRef] FOREIGN KEY([ref_entity_id])
REFERENCES [dbo].[Entity] ([entity_id])
GO
ALTER TABLE [dbo].[RefInfo] CHECK CONSTRAINT [FK_RefInfo_EntityRef]
GO
ALTER TABLE [dbo].[RefInfo]  WITH CHECK ADD  CONSTRAINT [FK_RefInfo_T_ReferenceType] FOREIGN KEY([ref_type])
REFERENCES [dbo].[T_ReferenceType] ([ref_type])
GO
ALTER TABLE [dbo].[RefInfo] CHECK CONSTRAINT [FK_RefInfo_T_ReferenceType]
GO
ALTER TABLE [dbo].[Term]  WITH CHECK ADD  CONSTRAINT [FK_Term_T_LoanType] FOREIGN KEY([loan_type])
REFERENCES [dbo].[T_LoanType] ([loan_type])
GO
ALTER TABLE [dbo].[Term] CHECK CONSTRAINT [FK_Term_T_LoanType]
GO
/****** Object:  Trigger [dbo].[tr_set_expiry]    Script Date: 5/10/2016 12:47:42 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TRIGGER [dbo].[tr_set_expiry]
   ON  [dbo].[IdentityInfo]
   AFTER INSERT,UPDATE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @entity_id char(9),
	        @ident_type char(2),
	        @has_expiry tinyint

    select @entity_id = entity_id,
	       @ident_type = ident_type
	  from inserted

	select @has_expiry = has_expiry
	  from T_IdentityType (nolock)
	 where ident_type = @ident_type

	if isnull(@has_expiry,0) = 0
	  update IdentityInfo
	     set exp_date = null
	   where entity_id = @entity_id
	     and ident_type = @ident_type

END

GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Residence status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AddressInfo', @level2type=N'COLUMN',@level2name=N'res_status'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Landlord of the rented property. Value is from the entity_id field of the Entity table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'AddressInfo', @level2type=N'COLUMN',@level2name=N'landlord'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Immediate head. Value is the entity_id field from the Entity table.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'EmplInfo', @level2type=N'COLUMN',@level2name=N'imm_head'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Driver''s license.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IdentityInfo', @level2type=N'COLUMN',@level2name=N'ident_no'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Amount applied.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Loan', @level2type=N'COLUMN',@level2name=N'amt_appl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Desired term.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Loan', @level2type=N'COLUMN',@level2name=N'des_term'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date approved.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Loan', @level2type=N'COLUMN',@level2name=N'date_appv'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date released.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Loan', @level2type=N'COLUMN',@level2name=N'date_rel'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Releasing branch. Loans can be released in another branch.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Loan', @level2type=N'COLUMN',@level2name=N'rel_branch'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Branch of origin. Where the application originated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Loan', @level2type=N'COLUMN',@level2name=N'orig_branch'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Number of co-makers required.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_LoanType', @level2type=N'COLUMN',@level2name=N'co_makers'
GO
USE [master]
GO
ALTER DATABASE [iFinance] SET  READ_WRITE 
GO
