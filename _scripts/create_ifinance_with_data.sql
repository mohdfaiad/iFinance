USE [master]
GO
/****** Object:  Database [iFinance]    Script Date: 20/02/2018 9:37:11 PM ******/
CREATE DATABASE [iFinance] ON  PRIMARY 
( NAME = N'FMS', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.DEVELOPMENT\MSSQL\DATA\iFinance.mdf' , SIZE = 5120KB , MAXSIZE = UNLIMITED, FILEGROWTH = 1024KB )
 LOG ON 
( NAME = N'FMS_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL12.DEVELOPMENT\MSSQL\DATA\iFinance_log.ldf' , SIZE = 3456KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
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
USE [iFinance]
GO
/****** Object:  UserDefinedFunction [dbo].[fxn_get_appv_method]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fxn_get_appv_method] 
(
	
)
RETURNS 
@appv_method TABLE 
(
	value char(1),
	display varchar(25)
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	insert @appv_method
	select 'S','Standard'
	union
	select 'T','Thru Text/SMS'
	union
	select 'C','Thru Call'

	RETURN 
END

GO
/****** Object:  UserDefinedFunction [dbo].[fxn_get_int_comp_method]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fxn_get_int_comp_method] 
(
	
)
RETURNS 
@methods TABLE 
(
	value char(1),
	display varchar(25)
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	insert @methods
	select 'F','Fixed'
	union
	select 'D','Diminishing'

	RETURN 
END

GO
/****** Object:  UserDefinedFunction [dbo].[fxn_get_parent_group]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fxn_get_parent_group] 
(

)
RETURNS 
@ParentGroup TABLE 
(
	-- Add the column definitions for the TABLE variable here
	grp_id char(8), 
	grp_name varchar(30),
	par_grp_id char(8),
	top_grp_id char(8)
)
AS
BEGIN
	declare @processgroup table (grp_id char(10))
	declare @tempgroup table (grp_id char(10))
	declare @cnt integer = 1

	-- insert the parent
	insert 
	  into @parentgroup
	select grp_id,
	       grp_name,
	       grp_id,
		   grp_id
	  from [Group] G
	 where isnull(G.par_grp_id,'') = ''

	-- start with the parent groups
	insert 
	  into @processgroup
	select grp_id 
	  from [Group] (nolock) 
	 where par_grp_id is null
    
	-- iterate until no more children remain
	while @cnt > 0
	begin
		  select @cnt = count(*) 
			from [Group] G (nolock)
		   where par_grp_id in (select grp_id from @processgroup)
			 and grp_id not in (select grp_id from @parentgroup)

		  if @cnt > 0 
		  begin
				insert into @tempgroup
				 select G.grp_id
				   from [Group] G 
			  left join @parentgroup P
					 on P.grp_id = G.grp_id
				  where G.par_grp_id in (select grp_id from @processgroup)
					and isnull(G.par_grp_id,'') <> ''

				 insert into @parentgroup
				 select G.grp_id,
				        G.grp_name,
				        G.par_grp_id,
						coalesce(P.par_grp_id,G.par_grp_id)
				   from [Group] G 
			  left join @parentgroup P
					 on P.grp_id = G.par_grp_id
				  where G.par_grp_id in (select grp_id from @processgroup)
					and isnull(G.par_grp_id,'') <> ''
		  end

		  delete @processgroup
		  
		  insert @processgroup
		  select *
		    from @tempgroup

		  delete @tempgroup
	end

	RETURN 
END

GO
/****** Object:  UserDefinedFunction [dbo].[fxn_get_pay_freq]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fxn_get_pay_freq] 
(
	
)
RETURNS 
@payment_frequency TABLE 
(
	value char(1),
	display varchar(25)
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	insert @payment_frequency
	select 'D','Daily'
	union
	select 'W','Weekly'
	union
	select 'M','Monthly'
	union
	select 'F','Semi-monthly'
	union
	select 'Y','Yearly'
	union
	select 'R','Semi-yearly'
	
	RETURN 
END

GO
/****** Object:  UserDefinedFunction [dbo].[fxn_get_recommendation]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[fxn_get_recommendation] 
(
	
)
RETURNS 
@recommendation TABLE 
(
	value int,
	display varchar(25)
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	insert @recommendation
	select 0,'Approve'
	union
	select 1,'Reject'
	
	RETURN 
END

GO
/****** Object:  UserDefinedFunction [dbo].[fxn_get_release_method]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[fxn_get_release_method] 
(
	
)
RETURNS 
@appv_method TABLE 
(
	value char(1),
	display varchar(25)
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	insert @appv_method
	select 'C','Cash'
	union
	select 'D','Card'
	
	RETURN 
END


GO
/****** Object:  UserDefinedFunction [dbo].[udf_format_currency]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udf_format_currency]
(
	@value decimal(10,2)
)
RETURNS varchar(12)
AS
BEGIN
	return case when isnull(@value,0) = 0 then '-' else convert(varchar,convert(money,@value),1) end
END

GO
/****** Object:  UserDefinedFunction [dbo].[udf_format_date]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[udf_format_date]
(
	@date datetime
)
RETURNS varchar(10)
AS
BEGIN
	return case when @date is null then '-' else convert(varchar(10),@date,101) end
END

GO
/****** Object:  Table [dbo].[AcctInfo]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[AcctInfo](
	[acct_no] [varchar](15) NOT NULL,
	[entity_id] [char](10) NOT NULL,
	[bank_id] [char](8) NOT NULL,
	[card_no] [varchar](15) NULL,
	[card_expiry] [datetime] NULL,
 CONSTRAINT [PK_AcctInfo] PRIMARY KEY CLUSTERED 
(
	[acct_no] ASC,
	[entity_id] ASC,
	[bank_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[AddressInfo]    Script Date: 20/02/2018 9:37:11 PM ******/
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
	[is_prov] [smallint] NOT NULL CONSTRAINT [DF_AddressInfo_is_prov]  DEFAULT ((0)),
 CONSTRAINT [PK_AddressInfo] PRIMARY KEY CLUSTERED 
(
	[entity_id] ASC,
	[is_prov] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Bank]    Script Date: 20/02/2018 9:37:11 PM ******/
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
	[loc_code] [char](3) NOT NULL,
 CONSTRAINT [PK_Bank] PRIMARY KEY CLUSTERED 
(
	[bank_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[BankWithdrawal]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[BankWithdrawal](
	[wd_id] [varchar](17) NOT NULL,
	[wd_date] [datetime] NOT NULL,
	[acct_no] [varchar](15) NOT NULL,
	[wd_amt] [decimal](10, 2) NOT NULL,
	[wd_status_id] [smallint] NOT NULL,
	[date_claimed] [datetime] NULL,
 CONSTRAINT [PK_BankWithdrawal] PRIMARY KEY CLUSTERED 
(
	[wd_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Check]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Check](
	[payment_id] [char](15) NOT NULL,
	[check_no] [varchar](15) NOT NULL,
	[check_amt] [decimal](10, 2) NOT NULL,
	[bank_code] [char](5) NOT NULL,
 CONSTRAINT [PK_Check] PRIMARY KEY CLUSTERED 
(
	[payment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Competitor]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Competitor](
	[comp_id] [char](8) NOT NULL,
	[comp_name] [varchar](30) NOT NULL,
	[loc_code] [char](3) NOT NULL,
 CONSTRAINT [PK_Competitor] PRIMARY KEY CLUSTERED 
(
	[comp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ContactInfo]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  Table [dbo].[EmplInfo]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EmplInfo](
	[entity_id] [char](10) NOT NULL,
	[emp_id] [char](8) NULL CONSTRAINT [DF_EmplInfo_empl_no]  DEFAULT ((0)),
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
/****** Object:  Table [dbo].[Employer]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Employer](
	[emp_id] [char](8) NOT NULL,
	[emp_name] [varchar](50) NOT NULL,
	[grp_id] [char](8) NOT NULL,
	[loc_code] [char](3) NOT NULL,
	[emp_add] [varchar](50) NULL,
 CONSTRAINT [PK_Employer] PRIMARY KEY CLUSTERED 
(
	[emp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Entity]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Entity](
	[entity_id] [char](10) NOT NULL,
	[entity_type] [char](2) NOT NULL CONSTRAINT [DF_Entity_entity_type]  DEFAULT ('CL'),
	[ref_entity_id] [char](10) NULL,
	[created_date] [datetime] NULL,
	[created_by] [varchar](12) NULL,
	[loc_code] [char](3) NOT NULL,
	[photo] [varchar](25) NULL,
 CONSTRAINT [PK_Entity] PRIMARY KEY CLUSTERED 
(
	[entity_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EntityGroup]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EntityGroup](
	[entity_id] [char](10) NOT NULL,
	[grp_id] [char](8) NOT NULL,
 CONSTRAINT [PK_EntityLoanClass] PRIMARY KEY CLUSTERED 
(
	[entity_id] ASC,
	[grp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ExpenseInfo]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  Table [dbo].[Group]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Group](
	[grp_id] [char](8) NOT NULL,
	[grp_name] [varchar](30) NOT NULL,
	[is_active] [tinyint] NOT NULL CONSTRAINT [DF_EmpGroup_is_active]  DEFAULT ((1)),
	[par_grp_id] [char](8) NULL,
	[loc_code] [char](3) NOT NULL,
 CONSTRAINT [PK_EmpGroup] PRIMARY KEY CLUSTERED 
(
	[grp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[GroupAttribute]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[GroupAttribute](
	[grp_id] [char](8) NOT NULL,
	[max_tot_amt] [decimal](10, 2) NOT NULL,
	[loan_type] [smallint] NOT NULL,
	[concurrent] [tinyint] NULL,
	[is_gov] [tinyint] NOT NULL CONSTRAINT [DF_GroupAttribute_is_gov]  DEFAULT ((0)),
	[ident_docs] [tinyint] NULL CONSTRAINT [DF_GroupAttribute_ident_docs]  DEFAULT ((0)),
 CONSTRAINT [PK_GroupAttribute] PRIMARY KEY CLUSTERED 
(
	[grp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[IdentityInfo]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  Table [dbo].[Interest]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Interest](
	[interest_id] [char](15) NOT NULL,
	[loan_id] [char](13) NOT NULL,
	[interest_date] [datetime] NOT NULL,
	[interest_amt] [decimal](10, 2) NOT NULL,
	[interest_src] [char](3) NOT NULL CONSTRAINT [DF_Interest_interest_src]  DEFAULT ('SYS'),
	[interest_status_id] [char](1) NOT NULL CONSTRAINT [DF_Interest_interest_status_id]  DEFAULT ('P'),
 CONSTRAINT [PK_Interest] PRIMARY KEY CLUSTERED 
(
	[interest_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Ledger]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Ledger](
	[posting_id] [varchar](15) NOT NULL,
	[loc_prefix] [varchar](15) NOT NULL,
	[ref_posting_id] [varchar](15) NULL,
	[debit_amt] [decimal](10, 2) NULL,
	[credit_amt] [decimal](10, 2) NULL,
	[event_object] [char](3) NOT NULL,
	[pk_event_object] [varchar](25) NOT NULL,
	[case_type] [char](3) NULL,
	[post_date] [datetime] NOT NULL,
	[value_date] [datetime] NOT NULL,
	[status_code] [char](3) NOT NULL CONSTRAINT [DF_Ledger_status_code]  DEFAULT ('OPN'),
 CONSTRAINT [PK_Ledger] PRIMARY KEY CLUSTERED 
(
	[posting_id] ASC,
	[loc_prefix] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Loan]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Loan](
	[loan_id] [char](13) NOT NULL,
	[date_appl] [datetime] NOT NULL,
	[amt_appl] [decimal](10, 2) NOT NULL,
	[des_term] [smallint] NOT NULL,
	[class_id] [int] NOT NULL,
	[purp_id] [int] NULL,
	[entity_id] [char](10) NOT NULL,
	[orig_branch] [char](3) NOT NULL,
	[status_id] [char](1) NOT NULL CONSTRAINT [DF_Loan_status_id]  DEFAULT ('P'),
	[created_date] [datetime] NOT NULL,
	[created_by] [varchar](12) NOT NULL,
	[loc_code] [char](3) NULL,
	[balance] [decimal](10, 2) NOT NULL CONSTRAINT [DF_Loan_balance]  DEFAULT ((0)),
	[last_trans_date] [datetime] NULL,
	[amort] [decimal](10, 2) NULL,
 CONSTRAINT [PK_Loan] PRIMARY KEY CLUSTERED 
(
	[loan_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoanAppv]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoanAppv](
	[loan_id] [char](13) NOT NULL,
	[amt_appv] [decimal](10, 2) NOT NULL,
	[date_appv] [datetime] NOT NULL,
	[appv_by] [varchar](12) NOT NULL,
	[terms] [smallint] NOT NULL,
	[appv_method] [char](1) NOT NULL,
	[remarks] [varchar](100) NULL,
	[created_date] [datetime] NOT NULL,
	[created_by] [varchar](12) NOT NULL,
 CONSTRAINT [PK_LoanAppv] PRIMARY KEY CLUSTERED 
(
	[loan_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoanAss]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoanAss](
	[loan_id] [char](13) NOT NULL,
	[rec_code] [tinyint] NOT NULL,
	[rec_amt] [decimal](10, 2) NULL,
	[date_ass] [datetime] NOT NULL,
	[ass_by] [varchar](12) NOT NULL,
	[capacity] [varchar](200) NULL,
	[character] [varchar](200) NULL,
	[capital] [varchar](200) NULL,
	[conditions] [varchar](200) NULL,
	[collateral] [varchar](200) NULL,
	[comaker] [varchar](200) NULL,
	[created_date] [datetime] NOT NULL,
	[created_by] [varchar](12) NOT NULL,
 CONSTRAINT [PK_LoanAss] PRIMARY KEY CLUSTERED 
(
	[loan_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoanAssFinInfo]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoanAssFinInfo](
	[loan_id] [char](13) NOT NULL,
	[comp_id] [char](8) NOT NULL,
	[mon_due] [decimal](10, 2) NOT NULL,
	[loan_bal] [decimal](10, 2) NOT NULL,
 CONSTRAINT [PK_LoanAssFinInfo] PRIMARY KEY CLUSTERED 
(
	[loan_id] ASC,
	[comp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoanAssMonExp]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoanAssMonExp](
	[loan_id] [char](13) NOT NULL,
	[exp_type] [char](2) NOT NULL,
	[monthly] [decimal](10, 2) NOT NULL,
 CONSTRAINT [PK_LoanAssMonExp] PRIMARY KEY CLUSTERED 
(
	[loan_id] ASC,
	[exp_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoanCancel]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoanCancel](
	[loan_id] [char](13) NOT NULL,
	[cancelled_date] [datetime] NOT NULL,
	[cancelled_by] [varchar](12) NOT NULL,
	[reason_id] [smallint] NOT NULL,
	[remarks] [varchar](100) NULL,
 CONSTRAINT [PK_LoanCancel] PRIMARY KEY CLUSTERED 
(
	[loan_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoanCharge]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoanCharge](
	[loan_id] [char](13) NOT NULL,
	[charge_type] [char](2) NOT NULL,
	[charge_amt] [decimal](10, 2) NULL,
 CONSTRAINT [PK_LoanCharge] PRIMARY KEY CLUSTERED 
(
	[loan_id] ASC,
	[charge_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoanClass]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoanClass](
	[class_id] [int] NOT NULL,
	[grp_id] [char](8) NOT NULL,
	[class_name] [varchar](25) NULL,
	[int_rate] [float] NOT NULL,
	[term] [tinyint] NULL,
	[comakers_min] [tinyint] NULL CONSTRAINT [DF_LoanClass_comakers]  DEFAULT ((0)),
	[comakers_max] [tinyint] NULL CONSTRAINT [DF_LoanClass_comakers_max]  DEFAULT ((0)),
	[int_comp_method] [char](1) NOT NULL,
	[max_loan] [decimal](10, 2) NULL,
	[valid_from] [datetime] NULL,
	[valid_until] [datetime] NULL,
	[loc_code] [char](3) NULL,
	[pay_freq] [char](1) NOT NULL CONSTRAINT [DF_LoanClass_pay_freq]  DEFAULT ('F'),
	[max_age] [tinyint] NULL,
	[is_scheduled] [bit] NOT NULL CONSTRAINT [DF_LoanClass_use_factor]  DEFAULT ((0)),
 CONSTRAINT [PK_LoanClass] PRIMARY KEY CLUSTERED 
(
	[class_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoanClassAdvance]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[LoanClassAdvance](
	[class_id] [int] NOT NULL,
	[int] [smallint] NULL CONSTRAINT [DF_LoanClassAdvance_int]  DEFAULT ((0)),
	[principal] [smallint] NULL CONSTRAINT [DF_LoanClassAdvance_principal]  DEFAULT ((0)),
	[advance_method] [smallint] NOT NULL CONSTRAINT [DF_LoanClassAdvance_advance_method]  DEFAULT ((0)),
	[include_principal] [bit] NOT NULL CONSTRAINT [DF_LoanClassAdvance_include_principal]  DEFAULT ((0)),
 CONSTRAINT [PK_LoanClassAdvance] PRIMARY KEY CLUSTERED 
(
	[class_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[LoanClassCharge]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoanClassCharge](
	[class_id] [int] NOT NULL,
	[charge_type] [char](2) NOT NULL,
	[charge_value] [decimal](8, 2) NOT NULL,
	[value_type] [tinyint] NOT NULL,
	[ratio_amt] [decimal](8, 2) NULL,
	[max_value] [decimal](8, 2) NULL,
	[max_value_type] [tinyint] NULL CONSTRAINT [DF_LoanClassCharge_max_value_type]  DEFAULT ((0)),
	[for_new] [tinyint] NOT NULL CONSTRAINT [DF_LoanClassCharge_for_new]  DEFAULT ((0)),
	[for_renew] [tinyint] NOT NULL CONSTRAINT [DF_LoanClassCharge_for_renew]  DEFAULT ((0)),
	[for_reloan] [tinyint] NOT NULL CONSTRAINT [DF_LoanClassCharge_for_reloan]  DEFAULT ((0)),
	[for_restructure] [tinyint] NOT NULL CONSTRAINT [DF_LoanClassCharge_for_restructure]  DEFAULT ((0)),
 CONSTRAINT [PK_LoanClassCharge] PRIMARY KEY CLUSTERED 
(
	[class_id] ASC,
	[charge_type] ASC,
	[for_new] ASC,
	[for_renew] ASC,
	[for_reloan] ASC,
	[for_restructure] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoanClose]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoanClose](
	[loan_id] [char](13) NOT NULL,
	[date_closed] [datetime] NOT NULL,
	[closed_by] [varchar](12) NOT NULL,
	[remarks] [varchar](100) NULL,
	[reason_id] [smallint] NOT NULL,
 CONSTRAINT [PK_LoanClose] PRIMARY KEY CLUSTERED 
(
	[loan_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoanComaker]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoanComaker](
	[loan_id] [char](13) NOT NULL,
	[entity_id] [char](10) NOT NULL,
 CONSTRAINT [PK_LoanComaker] PRIMARY KEY CLUSTERED 
(
	[loan_id] ASC,
	[entity_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoanReject]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoanReject](
	[loan_id] [char](13) NOT NULL,
	[date_rejected] [datetime] NOT NULL,
	[rejected_by] [varchar](12) NOT NULL,
	[reason_id] [smallint] NOT NULL,
	[remarks] [varchar](100) NULL,
 CONSTRAINT [PK_LoanDen] PRIMARY KEY CLUSTERED 
(
	[loan_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoanRelease]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoanRelease](
	[loan_id] [char](13) NOT NULL,
	[recipient] [char](10) NOT NULL,
	[rel_method] [char](1) NOT NULL,
	[rel_amt] [decimal](10, 2) NOT NULL,
	[date_rel] [datetime] NOT NULL,
	[rel_by] [varchar](12) NOT NULL,
	[loc_code] [char](3) NOT NULL,
 CONSTRAINT [PK_LoanRecipient] PRIMARY KEY CLUSTERED 
(
	[loan_id] ASC,
	[recipient] ASC,
	[rel_method] ASC,
	[loc_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Locked]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Locked](
	[event_object] [char](3) NULL,
	[pk_event_object] [char](15) NULL,
	[user_id] [varchar](12) NULL
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Payment]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Payment](
	[payment_id] [char](15) NOT NULL,
	[receipt_no] [char](10) NULL,
	[payment_date] [datetime] NOT NULL,
	[entity_id] [char](10) NOT NULL,
	[loc_code] [char](3) NOT NULL,
	[created_date] [datetime] NOT NULL,
	[created_by] [varchar](12) NOT NULL,
	[ref_no] [varchar](17) NOT NULL,
	[post_date] [datetime] NULL,
	[wd_id] [varchar](17) NULL,
	[is_advance] [bit] NULL CONSTRAINT [DF_Payment_is_advanced]  DEFAULT ((0)),
	[pmt_method] [tinyint] NOT NULL,
 CONSTRAINT [PK_Payment] PRIMARY KEY CLUSTERED 
(
	[payment_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PaymentDetail]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[PaymentDetail](
	[payment_id] [char](15) NOT NULL,
	[loan_id] [char](13) NOT NULL,
	[payment_amt] [decimal](10, 2) NOT NULL,
	[remarks] [varchar](10) NULL,
	[is_cancelled] [tinyint] NOT NULL CONSTRAINT [DF_PaymentDetail_is_cancelled]  DEFAULT ((0)),
	[payment_type] [char](3) NOT NULL,
	[balance] [decimal](10, 2) NULL,
 CONSTRAINT [PK_PaymentDetail_1] PRIMARY KEY CLUSTERED 
(
	[payment_id] ASC,
	[loan_id] ASC,
	[payment_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[PersonalInfo]    Script Date: 20/02/2018 9:37:11 PM ******/
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
	[oth_income] [varchar](50) NULL,
	[source_id] [int] NULL,
 CONSTRAINT [PK_PersonalInfo] PRIMARY KEY CLUSTERED 
(
	[entity_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RefInfo]    Script Date: 20/02/2018 9:37:11 PM ******/
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
	[educ_code] [char](1) NULL,
 CONSTRAINT [PK_RefInfo] PRIMARY KEY CLUSTERED 
(
	[entity_id] ASC,
	[ref_entity_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ReLoan]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[ReLoan](
	[loan_id] [char](13) NOT NULL,
	[new_loan_id] [char](13) NOT NULL,
	[payment_id] [char](15) NOT NULL,
	[is_restructured] [bit] NOT NULL,
 CONSTRAINT [PK_ReLoan] PRIMARY KEY CLUSTERED 
(
	[loan_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Sequence]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  Table [dbo].[T_AccountType]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_AccountType](
	[acct_type] [smallint] NOT NULL,
	[acct_type_name] [varchar](25) NULL,
	[acct_type_desc] [varchar](100) NULL,
 CONSTRAINT [PK_T_AccountType] PRIMARY KEY CLUSTERED 
(
	[acct_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Bank]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  Table [dbo].[T_ChargeType]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_ChargeType](
	[charge_type] [char](2) NOT NULL,
	[charge_name] [varchar](25) NOT NULL,
 CONSTRAINT [PK_T_ChargeType] PRIMARY KEY CLUSTERED 
(
	[charge_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Designation]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  Table [dbo].[T_EntityType]    Script Date: 20/02/2018 9:37:11 PM ******/
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
	[is_active] [smallint] NOT NULL CONSTRAINT [DF_T_Entity_is_valid]  DEFAULT ((1)),
	[is_client] [smallint] NOT NULL CONSTRAINT [DF_T_EntityType_is_client]  DEFAULT ((1)),
	[is_person] [smallint] NOT NULL CONSTRAINT [DF_T_EntityType_is_individual]  DEFAULT ((1)),
 CONSTRAINT [PK_T_Entity] PRIMARY KEY CLUSTERED 
(
	[entity_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_ExpenseType]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_ExpenseType](
	[exp_type] [char](2) NOT NULL,
	[exp_name] [varchar](30) NOT NULL,
	[exp_desc] [varchar](100) NULL,
 CONSTRAINT [PK_T_Expense] PRIMARY KEY CLUSTERED 
(
	[exp_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_IdentityType]    Script Date: 20/02/2018 9:37:11 PM ******/
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
	[has_expiry] [tinyint] NOT NULL CONSTRAINT [DF_T_IdentityType_has_expiry]  DEFAULT ((0)),
 CONSTRAINT [PK_T_IdentityType] PRIMARY KEY CLUSTERED 
(
	[ident_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_InfoSource]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_InfoSource](
	[source_id] [int] IDENTITY(1,1) NOT NULL,
	[source_name] [varchar](50) NOT NULL,
 CONSTRAINT [PK_T_InfoSource] PRIMARY KEY CLUSTERED 
(
	[source_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_LoanCancelReason]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_LoanCancelReason](
	[reason_id] [smallint] NOT NULL,
	[reason_name] [varchar](50) NOT NULL,
	[reason_desc] [varchar](100) NULL,
 CONSTRAINT [PK_T_LoanCancelReason] PRIMARY KEY CLUSTERED 
(
	[reason_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_LoanCloseReason]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_LoanCloseReason](
	[reason_id] [smallint] NOT NULL,
	[reason_name] [varchar](50) NULL,
	[reason_desc] [varchar](100) NULL,
	[is_system] [bit] NOT NULL CONSTRAINT [DF_T_LoanCloseReason_is_system]  DEFAULT ((0)),
	[is_auto_post] [bit] NOT NULL CONSTRAINT [DF_T_LoanCloseReason_is_sysgen]  DEFAULT ((0)),
 CONSTRAINT [PK_T_LoanCloseReason] PRIMARY KEY CLUSTERED 
(
	[reason_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_LoanRejectReason]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_LoanRejectReason](
	[reason_id] [smallint] NOT NULL,
	[reason_name] [varchar](50) NOT NULL,
	[reason_desc] [varchar](100) NULL,
 CONSTRAINT [PK_T_LoanRejectReason] PRIMARY KEY CLUSTERED 
(
	[reason_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_LoanStatus]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_LoanStatus](
	[status_id] [char](1) NOT NULL,
	[status_name] [varchar](30) NOT NULL,
	[status_desc] [varchar](100) NULL,
	[is_active] [tinyint] NOT NULL CONSTRAINT [DF_T_LoanStatus_is_active]  DEFAULT ((1)),
 CONSTRAINT [PK_T_LoanStatus] PRIMARY KEY CLUSTERED 
(
	[status_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_LoanType]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_LoanType](
	[loan_type] [smallint] NOT NULL,
	[acct_type] [smallint] NOT NULL,
	[loan_type_name] [varchar](25) NOT NULL,
	[loan_type_desc] [varchar](100) NULL,
	[max_concurrent] [tinyint] NOT NULL CONSTRAINT [DF_T_LoanType_max_concurrent]  DEFAULT ((0)),
	[max_tot_amt] [decimal](10, 2) NOT NULL CONSTRAINT [DF_T_LoanType_max_tot_amt]  DEFAULT ((0)),
	[ident_docs] [tinyint] NOT NULL CONSTRAINT [DF_T_LoanType_ident_docs]  DEFAULT ((0)),
 CONSTRAINT [PK_T_LoanType] PRIMARY KEY CLUSTERED 
(
	[loan_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_PaymentMethod]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_PaymentMethod](
	[pmt_method] [tinyint] NOT NULL,
	[pmt_method_name] [varchar](25) NOT NULL,
	[pmt_method_desc] [varchar](100) NULL,
	[pmt_charge] [decimal](8, 2) NULL,
 CONSTRAINT [PK_T_PaymentMethod] PRIMARY KEY CLUSTERED 
(
	[pmt_method] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Province]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Province](
	[area_code] [smallint] NOT NULL,
	[province] [varchar](30) NOT NULL,
 CONSTRAINT [PK_T_Province] PRIMARY KEY CLUSTERED 
(
	[area_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Purpose]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Purpose](
	[purp_id] [int] NOT NULL,
	[purpose] [varchar](25) NULL,
 CONSTRAINT [PK_T_Purpose] PRIMARY KEY CLUSTERED 
(
	[purp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_ReferenceType]    Script Date: 20/02/2018 9:37:11 PM ******/
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
	[is_family] [tinyint] NOT NULL CONSTRAINT [DF_T_ReferenceType_is_family]  DEFAULT ((0)),
	[max] [tinyint] NOT NULL CONSTRAINT [DF_T_ReferenceType_max]  DEFAULT ((0)),
 CONSTRAINT [PK_T_Reference] PRIMARY KEY CLUSTERED 
(
	[ref_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Town]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_Town](
	[post_code] [smallint] NOT NULL,
	[town] [varchar](25) NOT NULL,
	[area_code] [smallint] NOT NULL,
	[is_active] [tinyint] NOT NULL CONSTRAINT [DF_T_Town_is_active]  DEFAULT ((1)),
 CONSTRAINT [PK_T_Town] PRIMARY KEY CLUSTERED 
(
	[post_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
INSERT [dbo].[AddressInfo] ([entity_id], [st], [brgy], [post_code], [res_status], [landlord], [is_prov]) VALUES (N'1000-10001', NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[AddressInfo] ([entity_id], [st], [brgy], [post_code], [res_status], [landlord], [is_prov]) VALUES (N'1000-10001', NULL, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[AddressInfo] ([entity_id], [st], [brgy], [post_code], [res_status], [landlord], [is_prov]) VALUES (N'1000-10002', NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[AddressInfo] ([entity_id], [st], [brgy], [post_code], [res_status], [landlord], [is_prov]) VALUES (N'1000-10002', NULL, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[AddressInfo] ([entity_id], [st], [brgy], [post_code], [res_status], [landlord], [is_prov]) VALUES (N'1000-10003', NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[AddressInfo] ([entity_id], [st], [brgy], [post_code], [res_status], [landlord], [is_prov]) VALUES (N'1000-10003', NULL, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[AddressInfo] ([entity_id], [st], [brgy], [post_code], [res_status], [landlord], [is_prov]) VALUES (N'1000-10004', NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[AddressInfo] ([entity_id], [st], [brgy], [post_code], [res_status], [landlord], [is_prov]) VALUES (N'1000-10004', NULL, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[AddressInfo] ([entity_id], [st], [brgy], [post_code], [res_status], [landlord], [is_prov]) VALUES (N'1000-10005', NULL, NULL, NULL, NULL, NULL, 0)
INSERT [dbo].[AddressInfo] ([entity_id], [st], [brgy], [post_code], [res_status], [landlord], [is_prov]) VALUES (N'1000-10005', NULL, NULL, NULL, NULL, NULL, 1)
INSERT [dbo].[Bank] ([bank_id], [bank_code], [branch], [loc_code]) VALUES (N'1000-101', N'PNB  ', N'Dumaguete', N'DU ')
INSERT [dbo].[Bank] ([bank_id], [bank_code], [branch], [loc_code]) VALUES (N'1000-102', N'PNB  ', N'Bais City', N'DU ')
INSERT [dbo].[Bank] ([bank_id], [bank_code], [branch], [loc_code]) VALUES (N'1000-103', N'DBP  ', N'Bais', N'DU ')
INSERT [dbo].[Bank] ([bank_id], [bank_code], [branch], [loc_code]) VALUES (N'1000-104', N'BDO  ', N'Locsin St', N'DU ')
INSERT [dbo].[Bank] ([bank_id], [bank_code], [branch], [loc_code]) VALUES (N'1000-105', N'DBP  ', N'Dipolog', N'DU ')
INSERT [dbo].[Bank] ([bank_id], [bank_code], [branch], [loc_code]) VALUES (N'1000-106', N'MYB  ', N'National Highway', N'DU ')
INSERT [dbo].[Bank] ([bank_id], [bank_code], [branch], [loc_code]) VALUES (N'SVR-101 ', N'BDO  ', N'Robinsons', N'DU ')
INSERT [dbo].[Bank] ([bank_id], [bank_code], [branch], [loc_code]) VALUES (N'SVR-102 ', N'BDO  ', N'Perdices', N'DU ')
INSERT [dbo].[Bank] ([bank_id], [bank_code], [branch], [loc_code]) VALUES (N'SVR-103 ', N'BPI  ', N'San Jose St.', N'DU ')
INSERT [dbo].[Bank] ([bank_id], [bank_code], [branch], [loc_code]) VALUES (N'SVR-104 ', N'CHB  ', N'San Juan St', N'DU ')
INSERT [dbo].[Bank] ([bank_id], [bank_code], [branch], [loc_code]) VALUES (N'SVR-105 ', N'BDO  ', N'National Highway', N'DU ')
INSERT [dbo].[Bank] ([bank_id], [bank_code], [branch], [loc_code]) VALUES (N'SVR-106 ', N'LNB  ', N'Rizal Blvd', N'DU ')
INSERT [dbo].[Bank] ([bank_id], [bank_code], [branch], [loc_code]) VALUES (N'SVR-107 ', N'MYB  ', N'Legaspi St', N'DU ')
INSERT [dbo].[Bank] ([bank_id], [bank_code], [branch], [loc_code]) VALUES (N'SVR-108 ', N'DBP  ', N'Dumaguete Boulevard', N'DU ')
INSERT [dbo].[Competitor] ([comp_id], [comp_name], [loc_code]) VALUES (N'1000-104', N'ABC LENDING', N'DU ')
INSERT [dbo].[Competitor] ([comp_id], [comp_name], [loc_code]) VALUES (N'1000-105', N'CANDL INC', N'DU ')
INSERT [dbo].[Competitor] ([comp_id], [comp_name], [loc_code]) VALUES (N'1000-106', N'LBG LENDING', N'DU ')
INSERT [dbo].[Competitor] ([comp_id], [comp_name], [loc_code]) VALUES (N'1000-107', N'CRIME INC', N'SVR')
INSERT [dbo].[ContactInfo] ([entity_id], [email_add], [fb_acct], [mobile_no], [home_phone]) VALUES (N'1000-10001', NULL, NULL, NULL, NULL)
INSERT [dbo].[ContactInfo] ([entity_id], [email_add], [fb_acct], [mobile_no], [home_phone]) VALUES (N'1000-10002', NULL, NULL, NULL, NULL)
INSERT [dbo].[ContactInfo] ([entity_id], [email_add], [fb_acct], [mobile_no], [home_phone]) VALUES (N'1000-10003', NULL, NULL, NULL, NULL)
INSERT [dbo].[ContactInfo] ([entity_id], [email_add], [fb_acct], [mobile_no], [home_phone]) VALUES (N'1000-10004', NULL, NULL, NULL, NULL)
INSERT [dbo].[ContactInfo] ([entity_id], [email_add], [fb_acct], [mobile_no], [home_phone]) VALUES (N'1000-10005', NULL, NULL, NULL, NULL)
INSERT [dbo].[EmplInfo] ([entity_id], [emp_id], [emp_status], [date_from], [date_until], [gross_pay], [serv_len], [imm_head], [net_pay], [des_id]) VALUES (N'1000-10001', N'1000-101', NULL, NULL, NULL, CAST(0.00 AS Decimal(8, 2)), NULL, NULL, CAST(0.00 AS Decimal(8, 2)), NULL)
INSERT [dbo].[EmplInfo] ([entity_id], [emp_id], [emp_status], [date_from], [date_until], [gross_pay], [serv_len], [imm_head], [net_pay], [des_id]) VALUES (N'1000-10002', N'1000-101', NULL, NULL, NULL, CAST(0.00 AS Decimal(8, 2)), NULL, NULL, CAST(0.00 AS Decimal(8, 2)), NULL)
INSERT [dbo].[EmplInfo] ([entity_id], [emp_id], [emp_status], [date_from], [date_until], [gross_pay], [serv_len], [imm_head], [net_pay], [des_id]) VALUES (N'1000-10003', N'1000-103', NULL, NULL, NULL, CAST(0.00 AS Decimal(8, 2)), NULL, NULL, CAST(0.00 AS Decimal(8, 2)), NULL)
INSERT [dbo].[EmplInfo] ([entity_id], [emp_id], [emp_status], [date_from], [date_until], [gross_pay], [serv_len], [imm_head], [net_pay], [des_id]) VALUES (N'1000-10004', N'1000-102', NULL, NULL, NULL, CAST(0.00 AS Decimal(8, 2)), NULL, NULL, CAST(0.00 AS Decimal(8, 2)), NULL)
INSERT [dbo].[EmplInfo] ([entity_id], [emp_id], [emp_status], [date_from], [date_until], [gross_pay], [serv_len], [imm_head], [net_pay], [des_id]) VALUES (N'1000-10005', N'1000-102', NULL, NULL, NULL, CAST(0.00 AS Decimal(8, 2)), NULL, NULL, CAST(0.00 AS Decimal(8, 2)), NULL)
INSERT [dbo].[Employer] ([emp_id], [emp_name], [grp_id], [loc_code], [emp_add]) VALUES (N'1000-101', N'DIPOLOG ELEMENTARY SCHOOL', N'1000-101', N'SVR', NULL)
INSERT [dbo].[Employer] ([emp_id], [emp_name], [grp_id], [loc_code], [emp_add]) VALUES (N'1000-102', N'DIPOLOG HIGH SCHOOL', N'1000-101', N'SVR', NULL)
INSERT [dbo].[Employer] ([emp_id], [emp_name], [grp_id], [loc_code], [emp_add]) VALUES (N'1000-103', N'CHINA BANK', N'1000-102', N'DU ', N'Dumaguete City')
INSERT [dbo].[Entity] ([entity_id], [entity_type], [ref_entity_id], [created_date], [created_by], [loc_code], [photo]) VALUES (N'1000-10001', N'CL', NULL, CAST(N'2018-02-17 08:17:49.000' AS DateTime), N'141', N'DU ', N'')
INSERT [dbo].[Entity] ([entity_id], [entity_type], [ref_entity_id], [created_date], [created_by], [loc_code], [photo]) VALUES (N'1000-10002', N'CK', N'1000-10001', CAST(N'2018-02-17 08:18:27.000' AS DateTime), N'141', N'DU ', N'')
INSERT [dbo].[Entity] ([entity_id], [entity_type], [ref_entity_id], [created_date], [created_by], [loc_code], [photo]) VALUES (N'1000-10003', N'CK', NULL, CAST(N'2018-02-17 08:20:32.000' AS DateTime), N'141', N'DU ', N'')
INSERT [dbo].[Entity] ([entity_id], [entity_type], [ref_entity_id], [created_date], [created_by], [loc_code], [photo]) VALUES (N'1000-10004', N'CL', NULL, CAST(N'2018-02-19 20:25:01.000' AS DateTime), N'141', N'DU ', N'')
INSERT [dbo].[Entity] ([entity_id], [entity_type], [ref_entity_id], [created_date], [created_by], [loc_code], [photo]) VALUES (N'1000-10005', N'CL', NULL, CAST(N'2018-02-20 13:32:54.000' AS DateTime), N'141', N'DU ', N'')
INSERT [dbo].[EntityGroup] ([entity_id], [grp_id]) VALUES (N'1000-10005', N'1000-102')
INSERT [dbo].[Group] ([grp_id], [grp_name], [is_active], [par_grp_id], [loc_code]) VALUES (N'1000-101', N'DEPED', 1, NULL, N'DU ')
INSERT [dbo].[Group] ([grp_id], [grp_name], [is_active], [par_grp_id], [loc_code]) VALUES (N'1000-102', N'PRIVATE INSTITUTION', 1, NULL, N'DU ')
INSERT [dbo].[GroupAttribute] ([grp_id], [max_tot_amt], [loan_type], [concurrent], [is_gov], [ident_docs]) VALUES (N'1000-101', CAST(400000.00 AS Decimal(10, 2)), 101, 2, 1, 2)
INSERT [dbo].[GroupAttribute] ([grp_id], [max_tot_amt], [loan_type], [concurrent], [is_gov], [ident_docs]) VALUES (N'1000-102', CAST(200000.00 AS Decimal(10, 2)), 101, 2, 0, 2)
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000001 ', N'1000-10000001', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000002 ', N'1000-10000001', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000003 ', N'1000-10000001', CAST(N'2018-05-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000004 ', N'1000-10000001', CAST(N'2018-06-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000005 ', N'1000-10000001', CAST(N'2018-07-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000006 ', N'1000-10000001', CAST(N'2018-08-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000007 ', N'1000-10000001', CAST(N'2018-09-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000008 ', N'1000-10000001', CAST(N'2018-10-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000009 ', N'1000-10000001', CAST(N'2018-11-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000010 ', N'1000-10000001', CAST(N'2018-12-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000011 ', N'1000-10000001', CAST(N'2019-01-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000012 ', N'1000-10000001', CAST(N'2019-02-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000013 ', N'1000-10000001', CAST(N'2019-03-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000014 ', N'1000-10000001', CAST(N'2019-04-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000015 ', N'1000-10000001', CAST(N'2019-05-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000016 ', N'1000-10000001', CAST(N'2019-06-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000017 ', N'1000-10000001', CAST(N'2019-07-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000018 ', N'1000-10000001', CAST(N'2019-08-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000019 ', N'1000-10000001', CAST(N'2019-09-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000020 ', N'1000-10000001', CAST(N'2019-10-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000021 ', N'1000-10000001', CAST(N'2019-11-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000022 ', N'1000-10000001', CAST(N'2019-12-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000023 ', N'1000-10000001', CAST(N'2020-01-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000024 ', N'1000-10000001', CAST(N'2020-02-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000025 ', N'1000-10000001', CAST(N'2020-03-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000026 ', N'1000-10000001', CAST(N'2020-04-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000027 ', N'1000-10000001', CAST(N'2020-05-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000028 ', N'1000-10000001', CAST(N'2020-06-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000029 ', N'1000-10000001', CAST(N'2020-07-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000030 ', N'1000-10000001', CAST(N'2020-08-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000031 ', N'1000-10000001', CAST(N'2020-09-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000032 ', N'1000-10000001', CAST(N'2020-10-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000033 ', N'1000-10000001', CAST(N'2020-11-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000034 ', N'1000-10000001', CAST(N'2020-12-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000035 ', N'1000-10000001', CAST(N'2021-01-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000036 ', N'1000-10000001', CAST(N'2021-02-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000037 ', N'1000-10000001', CAST(N'2021-03-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000038 ', N'1000-10000001', CAST(N'2021-04-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000039 ', N'1000-10000001', CAST(N'2021-05-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000040 ', N'1000-10000001', CAST(N'2021-06-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000041 ', N'1000-10000001', CAST(N'2021-07-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000042 ', N'1000-10000001', CAST(N'2021-08-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000043 ', N'1000-10000001', CAST(N'2021-09-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000044 ', N'1000-10000001', CAST(N'2021-10-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000045 ', N'1000-10000001', CAST(N'2021-11-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000046 ', N'1000-10000001', CAST(N'2021-12-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000047 ', N'1000-10000001', CAST(N'2022-01-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000048 ', N'1000-10000001', CAST(N'2022-02-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000049 ', N'1000-10000001', CAST(N'2022-03-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000050 ', N'1000-10000001', CAST(N'2022-04-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000051 ', N'1000-10000001', CAST(N'2022-05-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000052 ', N'1000-10000001', CAST(N'2022-06-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000053 ', N'1000-10000001', CAST(N'2022-07-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000054 ', N'1000-10000001', CAST(N'2022-08-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000055 ', N'1000-10000001', CAST(N'2022-09-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000056 ', N'1000-10000001', CAST(N'2022-10-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000057 ', N'1000-10000001', CAST(N'2022-11-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000058 ', N'1000-10000001', CAST(N'2022-12-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000059 ', N'1000-10000001', CAST(N'2023-01-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000060 ', N'1000-10000001', CAST(N'2023-02-19 00:00:00.000' AS DateTime), CAST(3801.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000061 ', N'1000-10000002', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(2681.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000062 ', N'1000-10000002', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(2636.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000063 ', N'1000-10000002', CAST(N'2018-05-19 00:00:00.000' AS DateTime), CAST(2591.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000064 ', N'1000-10000002', CAST(N'2018-06-19 00:00:00.000' AS DateTime), CAST(2546.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000065 ', N'1000-10000002', CAST(N'2018-07-19 00:00:00.000' AS DateTime), CAST(2502.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000066 ', N'1000-10000002', CAST(N'2018-08-19 00:00:00.000' AS DateTime), CAST(2457.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000067 ', N'1000-10000002', CAST(N'2018-09-19 00:00:00.000' AS DateTime), CAST(2412.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000068 ', N'1000-10000002', CAST(N'2018-10-19 00:00:00.000' AS DateTime), CAST(2368.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000069 ', N'1000-10000002', CAST(N'2018-11-19 00:00:00.000' AS DateTime), CAST(2323.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000070 ', N'1000-10000002', CAST(N'2018-12-19 00:00:00.000' AS DateTime), CAST(2278.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000071 ', N'1000-10000002', CAST(N'2019-01-19 00:00:00.000' AS DateTime), CAST(2234.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000072 ', N'1000-10000002', CAST(N'2019-02-19 00:00:00.000' AS DateTime), CAST(2189.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000073 ', N'1000-10000002', CAST(N'2019-03-19 00:00:00.000' AS DateTime), CAST(2144.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000074 ', N'1000-10000002', CAST(N'2019-04-19 00:00:00.000' AS DateTime), CAST(2100.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000075 ', N'1000-10000002', CAST(N'2019-05-19 00:00:00.000' AS DateTime), CAST(2055.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000076 ', N'1000-10000002', CAST(N'2019-06-19 00:00:00.000' AS DateTime), CAST(2010.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000077 ', N'1000-10000002', CAST(N'2019-07-19 00:00:00.000' AS DateTime), CAST(1966.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000078 ', N'1000-10000002', CAST(N'2019-08-19 00:00:00.000' AS DateTime), CAST(1921.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000079 ', N'1000-10000002', CAST(N'2019-09-19 00:00:00.000' AS DateTime), CAST(1876.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000080 ', N'1000-10000002', CAST(N'2019-10-19 00:00:00.000' AS DateTime), CAST(1832.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000081 ', N'1000-10000002', CAST(N'2019-11-19 00:00:00.000' AS DateTime), CAST(1787.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000082 ', N'1000-10000002', CAST(N'2019-12-19 00:00:00.000' AS DateTime), CAST(1742.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000083 ', N'1000-10000002', CAST(N'2020-01-19 00:00:00.000' AS DateTime), CAST(1698.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000084 ', N'1000-10000002', CAST(N'2020-02-19 00:00:00.000' AS DateTime), CAST(1653.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000085 ', N'1000-10000002', CAST(N'2020-03-19 00:00:00.000' AS DateTime), CAST(1608.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000086 ', N'1000-10000002', CAST(N'2020-04-19 00:00:00.000' AS DateTime), CAST(1564.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000087 ', N'1000-10000002', CAST(N'2020-05-19 00:00:00.000' AS DateTime), CAST(1519.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000088 ', N'1000-10000002', CAST(N'2020-06-19 00:00:00.000' AS DateTime), CAST(1474.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000089 ', N'1000-10000002', CAST(N'2020-07-19 00:00:00.000' AS DateTime), CAST(1429.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000090 ', N'1000-10000002', CAST(N'2020-08-19 00:00:00.000' AS DateTime), CAST(1385.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000091 ', N'1000-10000002', CAST(N'2020-09-19 00:00:00.000' AS DateTime), CAST(1340.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000092 ', N'1000-10000002', CAST(N'2020-10-19 00:00:00.000' AS DateTime), CAST(1295.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000093 ', N'1000-10000002', CAST(N'2020-11-19 00:00:00.000' AS DateTime), CAST(1251.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000094 ', N'1000-10000002', CAST(N'2020-12-19 00:00:00.000' AS DateTime), CAST(1206.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000095 ', N'1000-10000002', CAST(N'2021-01-19 00:00:00.000' AS DateTime), CAST(1161.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000096 ', N'1000-10000002', CAST(N'2021-02-19 00:00:00.000' AS DateTime), CAST(1117.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000097 ', N'1000-10000002', CAST(N'2021-03-19 00:00:00.000' AS DateTime), CAST(1072.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000098 ', N'1000-10000002', CAST(N'2021-04-19 00:00:00.000' AS DateTime), CAST(1027.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000099 ', N'1000-10000002', CAST(N'2021-05-19 00:00:00.000' AS DateTime), CAST(983.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000100 ', N'1000-10000002', CAST(N'2021-06-19 00:00:00.000' AS DateTime), CAST(938.00 AS Decimal(10, 2)), N'SYS', N'P')
GO
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000101 ', N'1000-10000002', CAST(N'2021-07-19 00:00:00.000' AS DateTime), CAST(893.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000102 ', N'1000-10000002', CAST(N'2021-08-19 00:00:00.000' AS DateTime), CAST(849.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000103 ', N'1000-10000002', CAST(N'2021-09-19 00:00:00.000' AS DateTime), CAST(804.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000104 ', N'1000-10000002', CAST(N'2021-10-19 00:00:00.000' AS DateTime), CAST(759.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000105 ', N'1000-10000002', CAST(N'2021-11-19 00:00:00.000' AS DateTime), CAST(715.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000106 ', N'1000-10000002', CAST(N'2021-12-19 00:00:00.000' AS DateTime), CAST(670.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000107 ', N'1000-10000002', CAST(N'2022-01-19 00:00:00.000' AS DateTime), CAST(625.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000108 ', N'1000-10000002', CAST(N'2022-02-19 00:00:00.000' AS DateTime), CAST(581.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000109 ', N'1000-10000002', CAST(N'2022-03-19 00:00:00.000' AS DateTime), CAST(536.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000110 ', N'1000-10000002', CAST(N'2022-04-19 00:00:00.000' AS DateTime), CAST(491.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000111 ', N'1000-10000002', CAST(N'2022-05-19 00:00:00.000' AS DateTime), CAST(447.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000112 ', N'1000-10000002', CAST(N'2022-06-19 00:00:00.000' AS DateTime), CAST(402.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000113 ', N'1000-10000002', CAST(N'2022-07-19 00:00:00.000' AS DateTime), CAST(357.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000114 ', N'1000-10000002', CAST(N'2022-08-19 00:00:00.000' AS DateTime), CAST(312.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000115 ', N'1000-10000002', CAST(N'2022-09-19 00:00:00.000' AS DateTime), CAST(268.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000116 ', N'1000-10000002', CAST(N'2022-10-19 00:00:00.000' AS DateTime), CAST(223.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000117 ', N'1000-10000002', CAST(N'2022-11-19 00:00:00.000' AS DateTime), CAST(178.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000118 ', N'1000-10000002', CAST(N'2022-12-19 00:00:00.000' AS DateTime), CAST(134.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000119 ', N'1000-10000002', CAST(N'2023-01-19 00:00:00.000' AS DateTime), CAST(89.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000120 ', N'1000-10000002', CAST(N'2023-02-19 00:00:00.000' AS DateTime), CAST(44.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000121 ', N'1000-10000003', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(2801.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000122 ', N'1000-10000003', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(2744.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000123 ', N'1000-10000003', CAST(N'2018-05-19 00:00:00.000' AS DateTime), CAST(2688.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000124 ', N'1000-10000003', CAST(N'2018-06-19 00:00:00.000' AS DateTime), CAST(2632.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000125 ', N'1000-10000003', CAST(N'2018-07-19 00:00:00.000' AS DateTime), CAST(2576.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000126 ', N'1000-10000003', CAST(N'2018-08-19 00:00:00.000' AS DateTime), CAST(2520.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000127 ', N'1000-10000003', CAST(N'2018-09-19 00:00:00.000' AS DateTime), CAST(2464.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000128 ', N'1000-10000003', CAST(N'2018-10-19 00:00:00.000' AS DateTime), CAST(2408.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000129 ', N'1000-10000003', CAST(N'2018-11-19 00:00:00.000' AS DateTime), CAST(2352.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000130 ', N'1000-10000003', CAST(N'2018-12-19 00:00:00.000' AS DateTime), CAST(2296.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000131 ', N'1000-10000003', CAST(N'2019-01-19 00:00:00.000' AS DateTime), CAST(2240.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000132 ', N'1000-10000003', CAST(N'2019-02-19 00:00:00.000' AS DateTime), CAST(2184.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000133 ', N'1000-10000003', CAST(N'2019-03-19 00:00:00.000' AS DateTime), CAST(2128.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000134 ', N'1000-10000003', CAST(N'2019-04-19 00:00:00.000' AS DateTime), CAST(2072.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000135 ', N'1000-10000003', CAST(N'2019-05-19 00:00:00.000' AS DateTime), CAST(2016.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000136 ', N'1000-10000003', CAST(N'2019-06-19 00:00:00.000' AS DateTime), CAST(1960.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000137 ', N'1000-10000003', CAST(N'2019-07-19 00:00:00.000' AS DateTime), CAST(1904.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000138 ', N'1000-10000003', CAST(N'2019-08-19 00:00:00.000' AS DateTime), CAST(1848.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000139 ', N'1000-10000003', CAST(N'2019-09-19 00:00:00.000' AS DateTime), CAST(1792.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000140 ', N'1000-10000003', CAST(N'2019-10-19 00:00:00.000' AS DateTime), CAST(1736.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000141 ', N'1000-10000003', CAST(N'2019-11-19 00:00:00.000' AS DateTime), CAST(1680.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000142 ', N'1000-10000003', CAST(N'2019-12-19 00:00:00.000' AS DateTime), CAST(1624.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000143 ', N'1000-10000003', CAST(N'2020-01-19 00:00:00.000' AS DateTime), CAST(1568.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000144 ', N'1000-10000003', CAST(N'2020-02-19 00:00:00.000' AS DateTime), CAST(1512.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000145 ', N'1000-10000003', CAST(N'2020-03-19 00:00:00.000' AS DateTime), CAST(1456.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000146 ', N'1000-10000003', CAST(N'2020-04-19 00:00:00.000' AS DateTime), CAST(1400.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000147 ', N'1000-10000003', CAST(N'2020-05-19 00:00:00.000' AS DateTime), CAST(1343.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000148 ', N'1000-10000003', CAST(N'2020-06-19 00:00:00.000' AS DateTime), CAST(1287.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000149 ', N'1000-10000003', CAST(N'2020-07-19 00:00:00.000' AS DateTime), CAST(1231.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000150 ', N'1000-10000003', CAST(N'2020-08-19 00:00:00.000' AS DateTime), CAST(1175.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000151 ', N'1000-10000003', CAST(N'2020-09-19 00:00:00.000' AS DateTime), CAST(1119.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000152 ', N'1000-10000003', CAST(N'2020-10-19 00:00:00.000' AS DateTime), CAST(1063.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000153 ', N'1000-10000003', CAST(N'2020-11-19 00:00:00.000' AS DateTime), CAST(1007.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000154 ', N'1000-10000003', CAST(N'2020-12-19 00:00:00.000' AS DateTime), CAST(951.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000155 ', N'1000-10000003', CAST(N'2021-01-19 00:00:00.000' AS DateTime), CAST(895.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000156 ', N'1000-10000003', CAST(N'2021-02-19 00:00:00.000' AS DateTime), CAST(839.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000157 ', N'1000-10000003', CAST(N'2021-03-19 00:00:00.000' AS DateTime), CAST(783.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000158 ', N'1000-10000003', CAST(N'2021-04-19 00:00:00.000' AS DateTime), CAST(727.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000159 ', N'1000-10000003', CAST(N'2021-05-19 00:00:00.000' AS DateTime), CAST(671.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000160 ', N'1000-10000003', CAST(N'2021-06-19 00:00:00.000' AS DateTime), CAST(615.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000161 ', N'1000-10000003', CAST(N'2021-07-19 00:00:00.000' AS DateTime), CAST(559.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000162 ', N'1000-10000003', CAST(N'2021-08-19 00:00:00.000' AS DateTime), CAST(503.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000163 ', N'1000-10000003', CAST(N'2021-09-19 00:00:00.000' AS DateTime), CAST(447.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000164 ', N'1000-10000003', CAST(N'2021-10-19 00:00:00.000' AS DateTime), CAST(391.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000165 ', N'1000-10000003', CAST(N'2021-11-19 00:00:00.000' AS DateTime), CAST(335.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000166 ', N'1000-10000003', CAST(N'2021-12-19 00:00:00.000' AS DateTime), CAST(279.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000167 ', N'1000-10000003', CAST(N'2022-01-19 00:00:00.000' AS DateTime), CAST(223.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000168 ', N'1000-10000003', CAST(N'2022-02-19 00:00:00.000' AS DateTime), CAST(167.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000169 ', N'1000-10000003', CAST(N'2022-03-19 00:00:00.000' AS DateTime), CAST(111.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000170 ', N'1000-10000003', CAST(N'2022-04-19 00:00:00.000' AS DateTime), CAST(55.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000171 ', N'1000-10000004', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(1501.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000172 ', N'1000-10000004', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(1485.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000173 ', N'1000-10000004', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(1469.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000174 ', N'1000-10000004', CAST(N'2018-06-20 00:00:00.000' AS DateTime), CAST(1451.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000175 ', N'1000-10000004', CAST(N'2018-07-20 00:00:00.000' AS DateTime), CAST(1433.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000176 ', N'1000-10000004', CAST(N'2018-08-20 00:00:00.000' AS DateTime), CAST(1414.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000177 ', N'1000-10000004', CAST(N'2018-09-20 00:00:00.000' AS DateTime), CAST(1394.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000178 ', N'1000-10000004', CAST(N'2018-10-20 00:00:00.000' AS DateTime), CAST(1373.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000179 ', N'1000-10000004', CAST(N'2018-11-20 00:00:00.000' AS DateTime), CAST(1351.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000180 ', N'1000-10000004', CAST(N'2018-12-20 00:00:00.000' AS DateTime), CAST(1328.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000181 ', N'1000-10000004', CAST(N'2019-01-20 00:00:00.000' AS DateTime), CAST(1304.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000182 ', N'1000-10000004', CAST(N'2019-02-20 00:00:00.000' AS DateTime), CAST(1279.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000183 ', N'1000-10000004', CAST(N'2019-03-20 00:00:00.000' AS DateTime), CAST(1252.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000184 ', N'1000-10000004', CAST(N'2019-04-20 00:00:00.000' AS DateTime), CAST(1224.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000185 ', N'1000-10000004', CAST(N'2019-05-20 00:00:00.000' AS DateTime), CAST(1194.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000186 ', N'1000-10000004', CAST(N'2019-06-20 00:00:00.000' AS DateTime), CAST(1163.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000187 ', N'1000-10000004', CAST(N'2019-07-20 00:00:00.000' AS DateTime), CAST(1131.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000188 ', N'1000-10000004', CAST(N'2019-08-20 00:00:00.000' AS DateTime), CAST(1097.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000189 ', N'1000-10000004', CAST(N'2019-09-20 00:00:00.000' AS DateTime), CAST(1061.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000190 ', N'1000-10000004', CAST(N'2019-10-20 00:00:00.000' AS DateTime), CAST(1023.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000191 ', N'1000-10000004', CAST(N'2019-11-20 00:00:00.000' AS DateTime), CAST(984.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000192 ', N'1000-10000004', CAST(N'2019-12-20 00:00:00.000' AS DateTime), CAST(942.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000193 ', N'1000-10000004', CAST(N'2020-01-20 00:00:00.000' AS DateTime), CAST(899.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000194 ', N'1000-10000004', CAST(N'2020-02-20 00:00:00.000' AS DateTime), CAST(853.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000195 ', N'1000-10000004', CAST(N'2020-03-20 00:00:00.000' AS DateTime), CAST(805.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000196 ', N'1000-10000004', CAST(N'2020-04-20 00:00:00.000' AS DateTime), CAST(755.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000197 ', N'1000-10000004', CAST(N'2020-05-20 00:00:00.000' AS DateTime), CAST(702.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000198 ', N'1000-10000004', CAST(N'2020-06-20 00:00:00.000' AS DateTime), CAST(646.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000199 ', N'1000-10000004', CAST(N'2020-07-20 00:00:00.000' AS DateTime), CAST(588.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000200 ', N'1000-10000004', CAST(N'2020-08-20 00:00:00.000' AS DateTime), CAST(527.00 AS Decimal(10, 2)), N'SYS', N'P')
GO
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000201 ', N'1000-10000004', CAST(N'2020-09-20 00:00:00.000' AS DateTime), CAST(462.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000202 ', N'1000-10000004', CAST(N'2020-10-20 00:00:00.000' AS DateTime), CAST(395.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000203 ', N'1000-10000004', CAST(N'2020-11-20 00:00:00.000' AS DateTime), CAST(324.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000204 ', N'1000-10000004', CAST(N'2020-12-20 00:00:00.000' AS DateTime), CAST(250.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000205 ', N'1000-10000004', CAST(N'2021-01-20 00:00:00.000' AS DateTime), CAST(171.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000206 ', N'1000-10000004', CAST(N'2021-02-20 00:00:00.000' AS DateTime), CAST(89.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000207 ', N'1000-10000005', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(1251.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000208 ', N'1000-10000005', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(1209.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000209 ', N'1000-10000005', CAST(N'2018-05-20 00:00:00.000' AS DateTime), CAST(1167.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000210 ', N'1000-10000005', CAST(N'2018-06-20 00:00:00.000' AS DateTime), CAST(1125.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000211 ', N'1000-10000005', CAST(N'2018-07-20 00:00:00.000' AS DateTime), CAST(1084.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000212 ', N'1000-10000005', CAST(N'2018-08-20 00:00:00.000' AS DateTime), CAST(1042.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000213 ', N'1000-10000005', CAST(N'2018-09-20 00:00:00.000' AS DateTime), CAST(1000.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000214 ', N'1000-10000005', CAST(N'2018-10-20 00:00:00.000' AS DateTime), CAST(959.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000215 ', N'1000-10000005', CAST(N'2018-11-20 00:00:00.000' AS DateTime), CAST(917.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000216 ', N'1000-10000005', CAST(N'2018-12-20 00:00:00.000' AS DateTime), CAST(875.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000217 ', N'1000-10000005', CAST(N'2019-01-20 00:00:00.000' AS DateTime), CAST(834.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000218 ', N'1000-10000005', CAST(N'2019-02-20 00:00:00.000' AS DateTime), CAST(792.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000219 ', N'1000-10000005', CAST(N'2019-03-20 00:00:00.000' AS DateTime), CAST(750.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000220 ', N'1000-10000005', CAST(N'2019-04-20 00:00:00.000' AS DateTime), CAST(709.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000221 ', N'1000-10000005', CAST(N'2019-05-20 00:00:00.000' AS DateTime), CAST(667.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000222 ', N'1000-10000005', CAST(N'2019-06-20 00:00:00.000' AS DateTime), CAST(625.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000223 ', N'1000-10000005', CAST(N'2019-07-20 00:00:00.000' AS DateTime), CAST(584.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000224 ', N'1000-10000005', CAST(N'2019-08-20 00:00:00.000' AS DateTime), CAST(542.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000225 ', N'1000-10000005', CAST(N'2019-09-20 00:00:00.000' AS DateTime), CAST(500.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000226 ', N'1000-10000005', CAST(N'2019-10-20 00:00:00.000' AS DateTime), CAST(459.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000227 ', N'1000-10000005', CAST(N'2019-11-20 00:00:00.000' AS DateTime), CAST(417.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000228 ', N'1000-10000005', CAST(N'2019-12-20 00:00:00.000' AS DateTime), CAST(375.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000229 ', N'1000-10000005', CAST(N'2020-01-20 00:00:00.000' AS DateTime), CAST(334.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000230 ', N'1000-10000005', CAST(N'2020-02-20 00:00:00.000' AS DateTime), CAST(292.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000231 ', N'1000-10000005', CAST(N'2020-03-20 00:00:00.000' AS DateTime), CAST(250.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000232 ', N'1000-10000005', CAST(N'2020-04-20 00:00:00.000' AS DateTime), CAST(209.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000233 ', N'1000-10000005', CAST(N'2020-05-20 00:00:00.000' AS DateTime), CAST(167.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000234 ', N'1000-10000005', CAST(N'2020-06-20 00:00:00.000' AS DateTime), CAST(125.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000235 ', N'1000-10000005', CAST(N'2020-07-20 00:00:00.000' AS DateTime), CAST(84.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000236 ', N'1000-10000005', CAST(N'2020-08-20 00:00:00.000' AS DateTime), CAST(42.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000237 ', N'1000-10000007', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(1126.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000238 ', N'1000-10000007', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(1088.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000239 ', N'1000-10000007', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(1050.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000240 ', N'1000-10000007', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(1013.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000241 ', N'1000-10000007', CAST(N'2018-07-20 00:00:00.000' AS DateTime), CAST(975.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000242 ', N'1000-10000007', CAST(N'2018-08-20 00:00:00.000' AS DateTime), CAST(938.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000243 ', N'1000-10000007', CAST(N'2018-09-20 00:00:00.000' AS DateTime), CAST(900.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000244 ', N'1000-10000007', CAST(N'2018-10-20 00:00:00.000' AS DateTime), CAST(863.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000245 ', N'1000-10000007', CAST(N'2018-11-20 00:00:00.000' AS DateTime), CAST(825.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000246 ', N'1000-10000007', CAST(N'2018-12-20 00:00:00.000' AS DateTime), CAST(788.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000247 ', N'1000-10000007', CAST(N'2019-01-20 00:00:00.000' AS DateTime), CAST(750.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000248 ', N'1000-10000007', CAST(N'2019-02-20 00:00:00.000' AS DateTime), CAST(713.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000249 ', N'1000-10000007', CAST(N'2019-03-20 00:00:00.000' AS DateTime), CAST(675.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000250 ', N'1000-10000007', CAST(N'2019-04-20 00:00:00.000' AS DateTime), CAST(638.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000251 ', N'1000-10000007', CAST(N'2019-05-20 00:00:00.000' AS DateTime), CAST(600.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000252 ', N'1000-10000007', CAST(N'2019-06-20 00:00:00.000' AS DateTime), CAST(563.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000253 ', N'1000-10000007', CAST(N'2019-07-20 00:00:00.000' AS DateTime), CAST(525.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000254 ', N'1000-10000007', CAST(N'2019-08-20 00:00:00.000' AS DateTime), CAST(488.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000255 ', N'1000-10000007', CAST(N'2019-09-20 00:00:00.000' AS DateTime), CAST(450.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000256 ', N'1000-10000007', CAST(N'2019-10-20 00:00:00.000' AS DateTime), CAST(413.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000257 ', N'1000-10000007', CAST(N'2019-11-20 00:00:00.000' AS DateTime), CAST(375.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000258 ', N'1000-10000007', CAST(N'2019-12-20 00:00:00.000' AS DateTime), CAST(337.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000259 ', N'1000-10000007', CAST(N'2020-01-20 00:00:00.000' AS DateTime), CAST(300.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000260 ', N'1000-10000007', CAST(N'2020-02-20 00:00:00.000' AS DateTime), CAST(262.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000261 ', N'1000-10000007', CAST(N'2020-03-20 00:00:00.000' AS DateTime), CAST(225.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000262 ', N'1000-10000007', CAST(N'2020-04-20 00:00:00.000' AS DateTime), CAST(187.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000263 ', N'1000-10000007', CAST(N'2020-05-20 00:00:00.000' AS DateTime), CAST(150.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000264 ', N'1000-10000007', CAST(N'2020-06-20 00:00:00.000' AS DateTime), CAST(112.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000265 ', N'1000-10000007', CAST(N'2020-07-20 00:00:00.000' AS DateTime), CAST(75.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000266 ', N'1000-10000007', CAST(N'2020-08-20 00:00:00.000' AS DateTime), CAST(37.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000267 ', N'1000-10000008', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(738.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000268 ', N'1000-10000008', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(723.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000269 ', N'1000-10000008', CAST(N'2018-05-20 00:00:00.000' AS DateTime), CAST(707.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000270 ', N'1000-10000008', CAST(N'2018-06-20 00:00:00.000' AS DateTime), CAST(692.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000271 ', N'1000-10000008', CAST(N'2018-07-20 00:00:00.000' AS DateTime), CAST(677.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000272 ', N'1000-10000008', CAST(N'2018-08-20 00:00:00.000' AS DateTime), CAST(661.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000273 ', N'1000-10000008', CAST(N'2018-09-20 00:00:00.000' AS DateTime), CAST(646.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000274 ', N'1000-10000008', CAST(N'2018-10-20 00:00:00.000' AS DateTime), CAST(630.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000275 ', N'1000-10000008', CAST(N'2018-11-20 00:00:00.000' AS DateTime), CAST(615.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000276 ', N'1000-10000008', CAST(N'2018-12-20 00:00:00.000' AS DateTime), CAST(600.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000277 ', N'1000-10000008', CAST(N'2019-01-20 00:00:00.000' AS DateTime), CAST(584.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000278 ', N'1000-10000008', CAST(N'2019-02-20 00:00:00.000' AS DateTime), CAST(569.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000279 ', N'1000-10000008', CAST(N'2019-03-20 00:00:00.000' AS DateTime), CAST(554.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000280 ', N'1000-10000008', CAST(N'2019-04-20 00:00:00.000' AS DateTime), CAST(538.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000281 ', N'1000-10000008', CAST(N'2019-05-20 00:00:00.000' AS DateTime), CAST(523.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000282 ', N'1000-10000008', CAST(N'2019-06-20 00:00:00.000' AS DateTime), CAST(507.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000283 ', N'1000-10000008', CAST(N'2019-07-20 00:00:00.000' AS DateTime), CAST(492.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000284 ', N'1000-10000008', CAST(N'2019-08-20 00:00:00.000' AS DateTime), CAST(477.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000285 ', N'1000-10000008', CAST(N'2019-09-20 00:00:00.000' AS DateTime), CAST(461.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000286 ', N'1000-10000008', CAST(N'2019-10-20 00:00:00.000' AS DateTime), CAST(446.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000287 ', N'1000-10000008', CAST(N'2019-11-20 00:00:00.000' AS DateTime), CAST(431.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000288 ', N'1000-10000008', CAST(N'2019-12-20 00:00:00.000' AS DateTime), CAST(415.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000289 ', N'1000-10000008', CAST(N'2020-01-20 00:00:00.000' AS DateTime), CAST(400.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000290 ', N'1000-10000008', CAST(N'2020-02-20 00:00:00.000' AS DateTime), CAST(384.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000291 ', N'1000-10000008', CAST(N'2020-03-20 00:00:00.000' AS DateTime), CAST(369.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000292 ', N'1000-10000008', CAST(N'2020-04-20 00:00:00.000' AS DateTime), CAST(354.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000293 ', N'1000-10000008', CAST(N'2020-05-20 00:00:00.000' AS DateTime), CAST(338.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000294 ', N'1000-10000008', CAST(N'2020-06-20 00:00:00.000' AS DateTime), CAST(323.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000295 ', N'1000-10000008', CAST(N'2020-07-20 00:00:00.000' AS DateTime), CAST(308.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000296 ', N'1000-10000008', CAST(N'2020-08-20 00:00:00.000' AS DateTime), CAST(292.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000297 ', N'1000-10000008', CAST(N'2020-09-20 00:00:00.000' AS DateTime), CAST(277.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000298 ', N'1000-10000008', CAST(N'2020-10-20 00:00:00.000' AS DateTime), CAST(261.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000299 ', N'1000-10000008', CAST(N'2020-11-20 00:00:00.000' AS DateTime), CAST(246.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000300 ', N'1000-10000008', CAST(N'2020-12-20 00:00:00.000' AS DateTime), CAST(231.00 AS Decimal(10, 2)), N'SYS', N'P')
GO
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000301 ', N'1000-10000008', CAST(N'2021-01-20 00:00:00.000' AS DateTime), CAST(215.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000302 ', N'1000-10000008', CAST(N'2021-02-20 00:00:00.000' AS DateTime), CAST(200.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000303 ', N'1000-10000008', CAST(N'2021-03-20 00:00:00.000' AS DateTime), CAST(185.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000304 ', N'1000-10000008', CAST(N'2021-04-20 00:00:00.000' AS DateTime), CAST(169.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000305 ', N'1000-10000008', CAST(N'2021-05-20 00:00:00.000' AS DateTime), CAST(154.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000306 ', N'1000-10000008', CAST(N'2021-06-20 00:00:00.000' AS DateTime), CAST(138.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000307 ', N'1000-10000008', CAST(N'2021-07-20 00:00:00.000' AS DateTime), CAST(123.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000308 ', N'1000-10000008', CAST(N'2021-08-20 00:00:00.000' AS DateTime), CAST(108.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000309 ', N'1000-10000008', CAST(N'2021-09-20 00:00:00.000' AS DateTime), CAST(92.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000310 ', N'1000-10000008', CAST(N'2021-10-20 00:00:00.000' AS DateTime), CAST(77.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000311 ', N'1000-10000008', CAST(N'2021-11-20 00:00:00.000' AS DateTime), CAST(62.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000312 ', N'1000-10000008', CAST(N'2021-12-20 00:00:00.000' AS DateTime), CAST(46.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000313 ', N'1000-10000008', CAST(N'2022-01-20 00:00:00.000' AS DateTime), CAST(31.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000314 ', N'1000-10000008', CAST(N'2022-02-20 00:00:00.000' AS DateTime), CAST(15.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000315 ', N'1000-10000009', CAST(N'2018-03-20 00:00:00.000' AS DateTime), CAST(885.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000316 ', N'1000-10000009', CAST(N'2018-04-20 00:00:00.000' AS DateTime), CAST(862.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000317 ', N'1000-10000009', CAST(N'2018-05-20 00:00:00.000' AS DateTime), CAST(840.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000318 ', N'1000-10000009', CAST(N'2018-06-20 00:00:00.000' AS DateTime), CAST(818.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000319 ', N'1000-10000009', CAST(N'2018-07-20 00:00:00.000' AS DateTime), CAST(796.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000320 ', N'1000-10000009', CAST(N'2018-08-20 00:00:00.000' AS DateTime), CAST(774.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000321 ', N'1000-10000009', CAST(N'2018-09-20 00:00:00.000' AS DateTime), CAST(752.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000322 ', N'1000-10000009', CAST(N'2018-10-20 00:00:00.000' AS DateTime), CAST(730.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000323 ', N'1000-10000009', CAST(N'2018-11-20 00:00:00.000' AS DateTime), CAST(707.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000324 ', N'1000-10000009', CAST(N'2018-12-20 00:00:00.000' AS DateTime), CAST(685.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000325 ', N'1000-10000009', CAST(N'2019-01-20 00:00:00.000' AS DateTime), CAST(663.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000326 ', N'1000-10000009', CAST(N'2019-02-20 00:00:00.000' AS DateTime), CAST(641.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000327 ', N'1000-10000009', CAST(N'2019-03-20 00:00:00.000' AS DateTime), CAST(619.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000328 ', N'1000-10000009', CAST(N'2019-04-20 00:00:00.000' AS DateTime), CAST(597.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000329 ', N'1000-10000009', CAST(N'2019-05-20 00:00:00.000' AS DateTime), CAST(575.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000330 ', N'1000-10000009', CAST(N'2019-06-20 00:00:00.000' AS DateTime), CAST(553.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000331 ', N'1000-10000009', CAST(N'2019-07-20 00:00:00.000' AS DateTime), CAST(530.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000332 ', N'1000-10000009', CAST(N'2019-08-20 00:00:00.000' AS DateTime), CAST(508.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000333 ', N'1000-10000009', CAST(N'2019-09-20 00:00:00.000' AS DateTime), CAST(486.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000334 ', N'1000-10000009', CAST(N'2019-10-20 00:00:00.000' AS DateTime), CAST(464.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000335 ', N'1000-10000009', CAST(N'2019-11-20 00:00:00.000' AS DateTime), CAST(442.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000336 ', N'1000-10000009', CAST(N'2019-12-20 00:00:00.000' AS DateTime), CAST(420.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000337 ', N'1000-10000009', CAST(N'2020-01-20 00:00:00.000' AS DateTime), CAST(398.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000338 ', N'1000-10000009', CAST(N'2020-02-20 00:00:00.000' AS DateTime), CAST(376.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000339 ', N'1000-10000009', CAST(N'2020-03-20 00:00:00.000' AS DateTime), CAST(353.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000340 ', N'1000-10000009', CAST(N'2020-04-20 00:00:00.000' AS DateTime), CAST(331.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000341 ', N'1000-10000009', CAST(N'2020-05-20 00:00:00.000' AS DateTime), CAST(309.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000342 ', N'1000-10000009', CAST(N'2020-06-20 00:00:00.000' AS DateTime), CAST(287.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000343 ', N'1000-10000009', CAST(N'2020-07-20 00:00:00.000' AS DateTime), CAST(265.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000344 ', N'1000-10000009', CAST(N'2020-08-20 00:00:00.000' AS DateTime), CAST(243.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000345 ', N'1000-10000009', CAST(N'2020-09-20 00:00:00.000' AS DateTime), CAST(221.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000346 ', N'1000-10000009', CAST(N'2020-10-20 00:00:00.000' AS DateTime), CAST(199.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000347 ', N'1000-10000009', CAST(N'2020-11-20 00:00:00.000' AS DateTime), CAST(176.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000348 ', N'1000-10000009', CAST(N'2020-12-20 00:00:00.000' AS DateTime), CAST(154.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000349 ', N'1000-10000009', CAST(N'2021-01-20 00:00:00.000' AS DateTime), CAST(132.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000350 ', N'1000-10000009', CAST(N'2021-02-20 00:00:00.000' AS DateTime), CAST(110.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000351 ', N'1000-10000009', CAST(N'2021-03-20 00:00:00.000' AS DateTime), CAST(88.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000352 ', N'1000-10000009', CAST(N'2021-04-20 00:00:00.000' AS DateTime), CAST(66.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000353 ', N'1000-10000009', CAST(N'2021-05-20 00:00:00.000' AS DateTime), CAST(44.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000354 ', N'1000-10000009', CAST(N'2021-06-20 00:00:00.000' AS DateTime), CAST(22.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000355 ', N'1000-10000010', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(3601.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000356 ', N'1000-10000010', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(3540.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000357 ', N'1000-10000010', CAST(N'2018-05-20 00:00:00.000' AS DateTime), CAST(3480.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000358 ', N'1000-10000010', CAST(N'2018-06-20 00:00:00.000' AS DateTime), CAST(3420.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000359 ', N'1000-10000010', CAST(N'2018-07-20 00:00:00.000' AS DateTime), CAST(3360.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000360 ', N'1000-10000010', CAST(N'2018-08-20 00:00:00.000' AS DateTime), CAST(3300.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000361 ', N'1000-10000010', CAST(N'2018-09-20 00:00:00.000' AS DateTime), CAST(3240.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000362 ', N'1000-10000010', CAST(N'2018-10-20 00:00:00.000' AS DateTime), CAST(3180.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000363 ', N'1000-10000010', CAST(N'2018-11-20 00:00:00.000' AS DateTime), CAST(3120.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000364 ', N'1000-10000010', CAST(N'2018-12-20 00:00:00.000' AS DateTime), CAST(3060.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000365 ', N'1000-10000010', CAST(N'2019-01-20 00:00:00.000' AS DateTime), CAST(3000.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000366 ', N'1000-10000010', CAST(N'2019-02-20 00:00:00.000' AS DateTime), CAST(2940.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000367 ', N'1000-10000010', CAST(N'2019-03-20 00:00:00.000' AS DateTime), CAST(2880.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000368 ', N'1000-10000010', CAST(N'2019-04-20 00:00:00.000' AS DateTime), CAST(2820.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000369 ', N'1000-10000010', CAST(N'2019-05-20 00:00:00.000' AS DateTime), CAST(2760.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000370 ', N'1000-10000010', CAST(N'2019-06-20 00:00:00.000' AS DateTime), CAST(2700.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000371 ', N'1000-10000010', CAST(N'2019-07-20 00:00:00.000' AS DateTime), CAST(2640.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000372 ', N'1000-10000010', CAST(N'2019-08-20 00:00:00.000' AS DateTime), CAST(2580.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000373 ', N'1000-10000010', CAST(N'2019-09-20 00:00:00.000' AS DateTime), CAST(2520.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000374 ', N'1000-10000010', CAST(N'2019-10-20 00:00:00.000' AS DateTime), CAST(2460.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000375 ', N'1000-10000010', CAST(N'2019-11-20 00:00:00.000' AS DateTime), CAST(2400.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000376 ', N'1000-10000010', CAST(N'2019-12-20 00:00:00.000' AS DateTime), CAST(2340.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000377 ', N'1000-10000010', CAST(N'2020-01-20 00:00:00.000' AS DateTime), CAST(2280.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000378 ', N'1000-10000010', CAST(N'2020-02-20 00:00:00.000' AS DateTime), CAST(2220.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000379 ', N'1000-10000010', CAST(N'2020-03-20 00:00:00.000' AS DateTime), CAST(2160.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000380 ', N'1000-10000010', CAST(N'2020-04-20 00:00:00.000' AS DateTime), CAST(2100.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000381 ', N'1000-10000010', CAST(N'2020-05-20 00:00:00.000' AS DateTime), CAST(2039.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000382 ', N'1000-10000010', CAST(N'2020-06-20 00:00:00.000' AS DateTime), CAST(1979.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000383 ', N'1000-10000010', CAST(N'2020-07-20 00:00:00.000' AS DateTime), CAST(1919.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000384 ', N'1000-10000010', CAST(N'2020-08-20 00:00:00.000' AS DateTime), CAST(1859.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000385 ', N'1000-10000010', CAST(N'2020-09-20 00:00:00.000' AS DateTime), CAST(1799.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000386 ', N'1000-10000010', CAST(N'2020-10-20 00:00:00.000' AS DateTime), CAST(1739.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000387 ', N'1000-10000010', CAST(N'2020-11-20 00:00:00.000' AS DateTime), CAST(1679.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000388 ', N'1000-10000010', CAST(N'2020-12-20 00:00:00.000' AS DateTime), CAST(1619.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000389 ', N'1000-10000010', CAST(N'2021-01-20 00:00:00.000' AS DateTime), CAST(1559.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000390 ', N'1000-10000010', CAST(N'2021-02-20 00:00:00.000' AS DateTime), CAST(1499.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000391 ', N'1000-10000010', CAST(N'2021-03-20 00:00:00.000' AS DateTime), CAST(1439.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000392 ', N'1000-10000010', CAST(N'2021-04-20 00:00:00.000' AS DateTime), CAST(1379.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000393 ', N'1000-10000010', CAST(N'2021-05-20 00:00:00.000' AS DateTime), CAST(1319.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000394 ', N'1000-10000010', CAST(N'2021-06-20 00:00:00.000' AS DateTime), CAST(1259.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000395 ', N'1000-10000010', CAST(N'2021-07-20 00:00:00.000' AS DateTime), CAST(1199.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000396 ', N'1000-10000010', CAST(N'2021-08-20 00:00:00.000' AS DateTime), CAST(1139.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000397 ', N'1000-10000010', CAST(N'2021-09-20 00:00:00.000' AS DateTime), CAST(1079.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000398 ', N'1000-10000010', CAST(N'2021-10-20 00:00:00.000' AS DateTime), CAST(1019.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000399 ', N'1000-10000010', CAST(N'2021-11-20 00:00:00.000' AS DateTime), CAST(959.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000400 ', N'1000-10000010', CAST(N'2021-12-20 00:00:00.000' AS DateTime), CAST(899.00 AS Decimal(10, 2)), N'SYS', N'P')
GO
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000401 ', N'1000-10000010', CAST(N'2022-01-20 00:00:00.000' AS DateTime), CAST(839.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000402 ', N'1000-10000010', CAST(N'2022-02-20 00:00:00.000' AS DateTime), CAST(779.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000403 ', N'1000-10000010', CAST(N'2022-03-20 00:00:00.000' AS DateTime), CAST(719.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000404 ', N'1000-10000010', CAST(N'2022-04-20 00:00:00.000' AS DateTime), CAST(659.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000405 ', N'1000-10000010', CAST(N'2022-05-20 00:00:00.000' AS DateTime), CAST(599.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000406 ', N'1000-10000010', CAST(N'2022-06-20 00:00:00.000' AS DateTime), CAST(538.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000407 ', N'1000-10000010', CAST(N'2022-07-20 00:00:00.000' AS DateTime), CAST(478.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000408 ', N'1000-10000010', CAST(N'2022-08-20 00:00:00.000' AS DateTime), CAST(418.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000409 ', N'1000-10000010', CAST(N'2022-09-20 00:00:00.000' AS DateTime), CAST(358.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000410 ', N'1000-10000010', CAST(N'2022-10-20 00:00:00.000' AS DateTime), CAST(298.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000411 ', N'1000-10000010', CAST(N'2022-11-20 00:00:00.000' AS DateTime), CAST(238.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000412 ', N'1000-10000010', CAST(N'2022-12-20 00:00:00.000' AS DateTime), CAST(178.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000413 ', N'1000-10000010', CAST(N'2023-01-20 00:00:00.000' AS DateTime), CAST(118.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000414 ', N'1000-10000010', CAST(N'2023-02-20 00:00:00.000' AS DateTime), CAST(58.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000415 ', N'1000-10000011', CAST(N'2018-03-20 00:00:00.000' AS DateTime), CAST(1301.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000416 ', N'1000-10000011', CAST(N'2018-04-20 00:00:00.000' AS DateTime), CAST(1262.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000417 ', N'1000-10000011', CAST(N'2018-05-20 00:00:00.000' AS DateTime), CAST(1224.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000418 ', N'1000-10000011', CAST(N'2018-06-20 00:00:00.000' AS DateTime), CAST(1186.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000419 ', N'1000-10000011', CAST(N'2018-07-20 00:00:00.000' AS DateTime), CAST(1148.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000420 ', N'1000-10000011', CAST(N'2018-08-20 00:00:00.000' AS DateTime), CAST(1109.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000421 ', N'1000-10000011', CAST(N'2018-09-20 00:00:00.000' AS DateTime), CAST(1071.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000422 ', N'1000-10000011', CAST(N'2018-10-20 00:00:00.000' AS DateTime), CAST(1033.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000423 ', N'1000-10000011', CAST(N'2018-11-20 00:00:00.000' AS DateTime), CAST(995.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000424 ', N'1000-10000011', CAST(N'2018-12-20 00:00:00.000' AS DateTime), CAST(956.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000425 ', N'1000-10000011', CAST(N'2019-01-20 00:00:00.000' AS DateTime), CAST(918.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000426 ', N'1000-10000011', CAST(N'2019-02-20 00:00:00.000' AS DateTime), CAST(880.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000427 ', N'1000-10000011', CAST(N'2019-03-20 00:00:00.000' AS DateTime), CAST(842.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000428 ', N'1000-10000011', CAST(N'2019-04-20 00:00:00.000' AS DateTime), CAST(803.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000429 ', N'1000-10000011', CAST(N'2019-05-20 00:00:00.000' AS DateTime), CAST(765.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000430 ', N'1000-10000011', CAST(N'2019-06-20 00:00:00.000' AS DateTime), CAST(727.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000431 ', N'1000-10000011', CAST(N'2019-07-20 00:00:00.000' AS DateTime), CAST(689.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000432 ', N'1000-10000011', CAST(N'2019-08-20 00:00:00.000' AS DateTime), CAST(650.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000433 ', N'1000-10000011', CAST(N'2019-09-20 00:00:00.000' AS DateTime), CAST(612.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000434 ', N'1000-10000011', CAST(N'2019-10-20 00:00:00.000' AS DateTime), CAST(574.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000435 ', N'1000-10000011', CAST(N'2019-11-20 00:00:00.000' AS DateTime), CAST(536.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000436 ', N'1000-10000011', CAST(N'2019-12-20 00:00:00.000' AS DateTime), CAST(497.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000437 ', N'1000-10000011', CAST(N'2020-01-20 00:00:00.000' AS DateTime), CAST(459.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000438 ', N'1000-10000011', CAST(N'2020-02-20 00:00:00.000' AS DateTime), CAST(421.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000439 ', N'1000-10000011', CAST(N'2020-03-20 00:00:00.000' AS DateTime), CAST(383.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000440 ', N'1000-10000011', CAST(N'2020-04-20 00:00:00.000' AS DateTime), CAST(344.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000441 ', N'1000-10000011', CAST(N'2020-05-20 00:00:00.000' AS DateTime), CAST(306.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000442 ', N'1000-10000011', CAST(N'2020-06-20 00:00:00.000' AS DateTime), CAST(268.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000443 ', N'1000-10000011', CAST(N'2020-07-20 00:00:00.000' AS DateTime), CAST(230.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000444 ', N'1000-10000011', CAST(N'2020-08-20 00:00:00.000' AS DateTime), CAST(191.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000445 ', N'1000-10000011', CAST(N'2020-09-20 00:00:00.000' AS DateTime), CAST(153.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000446 ', N'1000-10000011', CAST(N'2020-10-20 00:00:00.000' AS DateTime), CAST(115.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000447 ', N'1000-10000011', CAST(N'2020-11-20 00:00:00.000' AS DateTime), CAST(77.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000448 ', N'1000-10000011', CAST(N'2020-12-20 00:00:00.000' AS DateTime), CAST(38.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000449 ', N'1000-10000012', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000450 ', N'1000-10000012', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000451 ', N'1000-10000012', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'T')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000452 ', N'1000-10000012', CAST(N'2018-06-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000453 ', N'1000-10000012', CAST(N'2018-07-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000454 ', N'1000-10000012', CAST(N'2018-08-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000455 ', N'1000-10000012', CAST(N'2018-09-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000456 ', N'1000-10000012', CAST(N'2018-10-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000457 ', N'1000-10000012', CAST(N'2018-11-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000458 ', N'1000-10000012', CAST(N'2018-12-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000459 ', N'1000-10000012', CAST(N'2019-01-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000460 ', N'1000-10000012', CAST(N'2019-02-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000461 ', N'1000-10000012', CAST(N'2019-03-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000462 ', N'1000-10000012', CAST(N'2019-04-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000463 ', N'1000-10000012', CAST(N'2019-05-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000464 ', N'1000-10000012', CAST(N'2019-06-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000465 ', N'1000-10000012', CAST(N'2019-07-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000466 ', N'1000-10000012', CAST(N'2019-08-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000467 ', N'1000-10000012', CAST(N'2019-09-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000468 ', N'1000-10000012', CAST(N'2019-10-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000469 ', N'1000-10000012', CAST(N'2019-11-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000470 ', N'1000-10000012', CAST(N'2019-12-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000471 ', N'1000-10000012', CAST(N'2020-01-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000472 ', N'1000-10000012', CAST(N'2020-02-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000473 ', N'1000-10000012', CAST(N'2020-03-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000474 ', N'1000-10000012', CAST(N'2020-04-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000475 ', N'1000-10000012', CAST(N'2020-05-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000476 ', N'1000-10000012', CAST(N'2020-06-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000477 ', N'1000-10000012', CAST(N'2020-07-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000478 ', N'1000-10000012', CAST(N'2020-08-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000479 ', N'1000-10000012', CAST(N'2020-09-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000480 ', N'1000-10000012', CAST(N'2020-10-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000481 ', N'1000-10000012', CAST(N'2020-11-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000482 ', N'1000-10000012', CAST(N'2020-12-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000483 ', N'1000-10000012', CAST(N'2021-01-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000484 ', N'1000-10000012', CAST(N'2021-02-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000485 ', N'1000-10000012', CAST(N'2021-03-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000486 ', N'1000-10000012', CAST(N'2021-04-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000487 ', N'1000-10000012', CAST(N'2021-05-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000488 ', N'1000-10000012', CAST(N'2021-06-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000489 ', N'1000-10000012', CAST(N'2021-07-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000490 ', N'1000-10000012', CAST(N'2021-08-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000491 ', N'1000-10000012', CAST(N'2021-09-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000492 ', N'1000-10000012', CAST(N'2021-10-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000493 ', N'1000-10000012', CAST(N'2021-11-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000494 ', N'1000-10000012', CAST(N'2021-12-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000495 ', N'1000-10000012', CAST(N'2022-01-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000496 ', N'1000-10000012', CAST(N'2022-02-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000497 ', N'1000-10000012', CAST(N'2022-03-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000498 ', N'1000-10000012', CAST(N'2022-04-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000499 ', N'1000-10000012', CAST(N'2022-05-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000500 ', N'1000-10000012', CAST(N'2022-06-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
GO
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000501 ', N'1000-10000012', CAST(N'2022-07-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000502 ', N'1000-10000012', CAST(N'2022-08-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000503 ', N'1000-10000012', CAST(N'2022-09-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000504 ', N'1000-10000012', CAST(N'2022-10-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000505 ', N'1000-10000012', CAST(N'2022-11-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000506 ', N'1000-10000012', CAST(N'2022-12-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000507 ', N'1000-10000012', CAST(N'2023-01-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Interest] ([interest_id], [loan_id], [interest_date], [interest_amt], [interest_src], [interest_status_id]) VALUES (N'1000-100000508 ', N'1000-10000012', CAST(N'2023-02-20 00:00:00.000' AS DateTime), CAST(7501.00 AS Decimal(10, 2)), N'SYS', N'P')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-1', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-10', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-100', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-101', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-102', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-103', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-104', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-105', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-106', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-107', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-108', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-109', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-11', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-110', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-111', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-112', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-113', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-114', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-115', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-116', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-117', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-118', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-119', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-12', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-120', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-121', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-122', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-123', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2023-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-124', N'1000', NULL, CAST(1097.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2023-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-125', N'1000', NULL, CAST(2681.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000061 ', N'ITS', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-126', N'1000', NULL, CAST(2636.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000062 ', N'ITS', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-127', N'1000', N'1000-65', NULL, CAST(1117.00 AS Decimal(10, 2)), N'PAY', N'1000-100000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-128', N'1000', N'1000-125', NULL, CAST(2681.00 AS Decimal(10, 2)), N'PAY', N'1000-100000003', N'ITS', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-129', N'1000', N'1000-66', NULL, CAST(1117.00 AS Decimal(10, 2)), N'PAY', N'1000-100000004', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-13', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-130', N'1000', N'1000-126', NULL, CAST(2636.00 AS Decimal(10, 2)), N'PAY', N'1000-100000004', N'ITS', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-131', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-132', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-133', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-134', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-135', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-136', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-137', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-138', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-139', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-14', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-140', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-141', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-142', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-143', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-144', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-145', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-146', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-147', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-148', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-149', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-15', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-150', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-151', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-152', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-153', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-154', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-155', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-156', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-157', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-158', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-159', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-16', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-160', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-161', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-162', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-163', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-164', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-165', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-166', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-167', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-168', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-169', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-17', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-170', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-171', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-172', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-173', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-174', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-175', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-176', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-177', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-178', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-179', N'1000', NULL, CAST(1401.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-18', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-180', N'1000', NULL, CAST(1351.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000003', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-181', N'1000', NULL, CAST(2801.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000121 ', N'ITS', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-182', N'1000', NULL, CAST(2744.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000122 ', N'ITS', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-183', N'1000', N'1000-131', NULL, CAST(1401.00 AS Decimal(10, 2)), N'PAY', N'1000-100000005', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-184', N'1000', N'1000-181', NULL, CAST(2801.00 AS Decimal(10, 2)), N'PAY', N'1000-100000005', N'ITS', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-185', N'1000', N'1000-132', NULL, CAST(1401.00 AS Decimal(10, 2)), N'PAY', N'1000-100000006', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-186', N'1000', N'1000-182', NULL, CAST(2744.00 AS Decimal(10, 2)), N'PAY', N'1000-100000006', N'ITS', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-187', N'1000', NULL, CAST(312.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-188', N'1000', NULL, CAST(328.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-189', N'1000', NULL, CAST(344.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
GO
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-19', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-190', N'1000', NULL, CAST(362.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-191', N'1000', NULL, CAST(380.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-192', N'1000', NULL, CAST(399.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-193', N'1000', NULL, CAST(419.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-194', N'1000', NULL, CAST(440.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-195', N'1000', NULL, CAST(462.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-196', N'1000', NULL, CAST(485.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-197', N'1000', NULL, CAST(509.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-198', N'1000', NULL, CAST(534.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-199', N'1000', NULL, CAST(561.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-2', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-20', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-200', N'1000', NULL, CAST(589.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-201', N'1000', NULL, CAST(619.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-202', N'1000', NULL, CAST(650.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-203', N'1000', NULL, CAST(682.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-204', N'1000', NULL, CAST(716.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-205', N'1000', NULL, CAST(752.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-206', N'1000', NULL, CAST(790.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-207', N'1000', NULL, CAST(829.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-208', N'1000', NULL, CAST(871.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-209', N'1000', NULL, CAST(914.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-21', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-210', N'1000', NULL, CAST(960.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-211', N'1000', NULL, CAST(1008.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-212', N'1000', NULL, CAST(1058.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-213', N'1000', NULL, CAST(1111.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-214', N'1000', NULL, CAST(1167.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-215', N'1000', NULL, CAST(1225.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-216', N'1000', NULL, CAST(1286.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-217', N'1000', NULL, CAST(1351.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-218', N'1000', NULL, CAST(1418.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-219', N'1000', NULL, CAST(1489.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-22', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-220', N'1000', NULL, CAST(1563.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-221', N'1000', NULL, CAST(1642.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-222', N'1000', NULL, CAST(1724.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000004', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-223', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000171 ', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-224', N'1000', NULL, CAST(1485.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000172 ', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-225', N'1000', NULL, CAST(1469.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000173 ', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-226', N'1000', N'1000-187', NULL, CAST(312.00 AS Decimal(10, 2)), N'PAY', N'1000-100000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-227', N'1000', N'1000-223', NULL, CAST(1501.00 AS Decimal(10, 2)), N'PAY', N'1000-100000007', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-228', N'1000', N'1000-188', NULL, CAST(328.00 AS Decimal(10, 2)), N'PAY', N'1000-100000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-229', N'1000', N'1000-224', NULL, CAST(1485.00 AS Decimal(10, 2)), N'PAY', N'1000-100000008', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-23', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-230', N'1000', N'1000-189', NULL, CAST(344.00 AS Decimal(10, 2)), N'PAY', N'1000-100000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-231', N'1000', N'1000-225', NULL, CAST(1469.00 AS Decimal(10, 2)), N'PAY', N'1000-100000009', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-232', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-233', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-234', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-235', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-236', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-237', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-238', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-239', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-24', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-240', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-241', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-242', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-243', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-244', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-245', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-246', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-247', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-248', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-249', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-25', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-250', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-251', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-252', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-253', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-254', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-255', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-256', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-257', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-258', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-259', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-26', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-260', N'1000', NULL, CAST(1667.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-261', N'1000', NULL, CAST(1657.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000005', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-262', N'1000', NULL, CAST(1251.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000207 ', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-263', N'1000', NULL, CAST(1209.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000208 ', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-264', N'1000', N'1000-262', NULL, CAST(1251.00 AS Decimal(10, 2)), N'PAY', N'1000-100000010', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-265', N'1000', N'1000-263', NULL, CAST(1209.00 AS Decimal(10, 2)), N'PAY', N'1000-100000011', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-266', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-267', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-268', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-269', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-27', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-270', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-271', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-272', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-273', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-274', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-275', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-276', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-277', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-278', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-279', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-04-01 00:00:00.000' AS DateTime), N'OPN')
GO
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-28', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-280', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-281', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-282', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-283', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-284', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-285', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-286', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-287', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-288', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-289', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-29', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-290', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-291', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-292', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-293', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-294', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-295', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000007', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-296', N'1000', NULL, CAST(1126.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000237 ', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-297', N'1000', NULL, CAST(1088.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000238 ', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-298', N'1000', NULL, CAST(1050.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000239 ', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-299', N'1000', NULL, CAST(1013.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000240 ', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-3', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-30', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-300', N'1000', N'1000-296', NULL, CAST(1126.00 AS Decimal(10, 2)), N'PAY', N'1000-100000012', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-301', N'1000', N'1000-297', NULL, CAST(1088.00 AS Decimal(10, 2)), N'PAY', N'1000-100000013', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-302', N'1000', N'1000-298', NULL, CAST(1050.00 AS Decimal(10, 2)), N'PAY', N'1000-100000014', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-303', N'1000', N'1000-299', NULL, CAST(1013.00 AS Decimal(10, 2)), N'PAY', N'1000-100000015', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-304', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-305', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-306', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-307', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-308', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-309', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-31', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-310', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-311', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-312', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-313', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-314', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-315', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-316', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-317', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-318', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-319', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-32', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-320', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-321', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-322', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-323', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-324', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-325', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-326', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-327', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-328', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-329', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-33', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-330', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-331', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-332', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-333', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-334', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-335', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-336', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-337', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-338', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-339', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-34', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-340', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-341', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-342', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-343', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-344', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-345', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-346', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-347', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-348', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-349', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-35', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-350', N'1000', NULL, CAST(1230.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-351', N'1000', NULL, CAST(1190.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000008', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-352', N'1000', NULL, CAST(738.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000267 ', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-353', N'1000', NULL, CAST(723.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000268 ', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-354', N'1000', N'1000-304', NULL, CAST(1230.00 AS Decimal(10, 2)), N'PAY', N'1000-100000016', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-355', N'1000', N'1000-352', NULL, CAST(738.00 AS Decimal(10, 2)), N'PAY', N'1000-100000016', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-356', N'1000', N'1000-305', NULL, CAST(1230.00 AS Decimal(10, 2)), N'PAY', N'1000-100000017', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-357', N'1000', N'1000-353', NULL, CAST(723.00 AS Decimal(10, 2)), N'PAY', N'1000-100000017', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-358', N'1000', NULL, CAST(3801.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000003 ', N'ITS', CAST(N'2018-06-20 00:00:00.000' AS DateTime), CAST(N'2018-05-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-359', N'1000', NULL, CAST(3801.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000004 ', N'ITS', CAST(N'2018-06-20 00:00:00.000' AS DateTime), CAST(N'2018-06-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-36', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-360', N'1000', NULL, CAST(2591.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000063 ', N'ITS', CAST(N'2018-06-20 00:00:00.000' AS DateTime), CAST(N'2018-05-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-361', N'1000', NULL, CAST(2546.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000064 ', N'ITS', CAST(N'2018-06-20 00:00:00.000' AS DateTime), CAST(N'2018-06-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-362', N'1000', NULL, CAST(2688.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000123 ', N'ITS', CAST(N'2018-06-20 00:00:00.000' AS DateTime), CAST(N'2018-05-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-363', N'1000', NULL, CAST(2632.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000124 ', N'ITS', CAST(N'2018-06-20 00:00:00.000' AS DateTime), CAST(N'2018-06-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-364', N'1000', NULL, CAST(1451.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000174 ', N'ITS', CAST(N'2018-06-20 00:00:00.000' AS DateTime), CAST(N'2018-06-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-365', N'1000', NULL, CAST(1167.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000209 ', N'ITS', CAST(N'2018-06-20 00:00:00.000' AS DateTime), CAST(N'2018-05-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-366', N'1000', NULL, CAST(1125.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000210 ', N'ITS', CAST(N'2018-06-20 00:00:00.000' AS DateTime), CAST(N'2018-06-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-367', N'1000', NULL, CAST(707.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000269 ', N'ITS', CAST(N'2018-06-20 00:00:00.000' AS DateTime), CAST(N'2018-05-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-368', N'1000', NULL, CAST(692.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000270 ', N'ITS', CAST(N'2018-06-20 00:00:00.000' AS DateTime), CAST(N'2018-06-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-369', N'1000', NULL, CAST(3801.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000005 ', N'ITS', CAST(N'2018-07-20 00:00:00.000' AS DateTime), CAST(N'2018-07-19 00:00:00.000' AS DateTime), N'OPN')
GO
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-37', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-370', N'1000', NULL, CAST(2502.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000065 ', N'ITS', CAST(N'2018-07-20 00:00:00.000' AS DateTime), CAST(N'2018-07-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-371', N'1000', NULL, CAST(2576.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000125 ', N'ITS', CAST(N'2018-07-20 00:00:00.000' AS DateTime), CAST(N'2018-07-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-372', N'1000', NULL, CAST(1433.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000175 ', N'ITS', CAST(N'2018-07-20 00:00:00.000' AS DateTime), CAST(N'2018-07-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-373', N'1000', NULL, CAST(1084.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000211 ', N'ITS', CAST(N'2018-07-20 00:00:00.000' AS DateTime), CAST(N'2018-07-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-374', N'1000', NULL, CAST(975.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000241 ', N'ITS', CAST(N'2018-07-20 00:00:00.000' AS DateTime), CAST(N'2018-07-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-375', N'1000', NULL, CAST(677.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000271 ', N'ITS', CAST(N'2018-07-20 00:00:00.000' AS DateTime), CAST(N'2018-07-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-376', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-377', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-378', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-379', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-38', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-380', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-381', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-382', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-383', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-384', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-385', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-386', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-387', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-388', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-389', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-39', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-390', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-391', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-392', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-393', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-394', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-395', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-396', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-397', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-398', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-399', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-4', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-40', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-400', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-401', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-402', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-403', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-404', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-405', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-406', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-407', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-408', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-409', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-41', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-410', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-411', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-412', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-413', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-414', N'1000', NULL, CAST(851.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-415', N'1000', NULL, CAST(811.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000009', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-416', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-417', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-418', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-419', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-42', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-420', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-421', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-422', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-423', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-424', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-425', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-426', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-427', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-428', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-429', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-43', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-430', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-431', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-432', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-433', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-434', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-435', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-436', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-437', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-438', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-439', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-44', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-440', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-441', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-442', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-443', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-444', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-445', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-446', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-447', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-448', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-449', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-45', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-450', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-451', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-452', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-453', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-454', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-455', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-456', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-457', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-458', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-459', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-10-01 00:00:00.000' AS DateTime), N'OPN')
GO
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-46', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-460', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-461', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-462', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-463', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-464', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-465', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-466', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-467', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-468', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-469', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-47', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-470', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-471', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-472', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-473', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-474', N'1000', NULL, CAST(1501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2023-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-475', N'1000', NULL, CAST(1441.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000010', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2023-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-476', N'1000', NULL, CAST(3601.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000355 ', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-477', N'1000', NULL, CAST(3540.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000356 ', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-478', N'1000', N'1000-416', NULL, CAST(1501.00 AS Decimal(10, 2)), N'PAY', N'1000-100000018', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-479', N'1000', N'1000-476', NULL, CAST(3601.00 AS Decimal(10, 2)), N'PAY', N'1000-100000018', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-48', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-480', N'1000', N'1000-417', NULL, CAST(1501.00 AS Decimal(10, 2)), N'PAY', N'1000-100000019', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-481', N'1000', N'1000-477', NULL, CAST(3540.00 AS Decimal(10, 2)), N'PAY', N'1000-100000019', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-482', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-483', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-484', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-485', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-486', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-487', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-488', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-489', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-49', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-490', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-491', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-492', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-493', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-494', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-495', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-496', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-497', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-498', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-499', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-5', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-50', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-500', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-501', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-502', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-503', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-504', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-505', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-506', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-507', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-508', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-509', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-51', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-510', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-511', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-512', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-513', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-514', N'1000', NULL, CAST(1471.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-515', N'1000', NULL, CAST(1457.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000011', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-516', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-517', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-518', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-519', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-52', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-520', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-521', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-522', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-523', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-524', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-525', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-526', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-527', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-528', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-529', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-53', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-530', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-531', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-532', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-533', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-534', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-535', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-536', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-537', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2019-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-538', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-539', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-54', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-540', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-541', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-542', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-543', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-544', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-545', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-546', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-547', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-548', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-549', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2020-12-01 00:00:00.000' AS DateTime), N'OPN')
GO
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-55', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-550', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-551', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-552', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-553', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-554', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-555', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-556', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-557', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-558', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-559', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-56', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-560', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-561', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2021-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-562', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-563', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-564', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-565', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-566', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-567', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-568', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-569', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-57', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-570', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-571', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-572', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-573', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2022-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-574', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2023-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-575', N'1000', NULL, CAST(2501.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000012', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2023-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-576', N'1000', NULL, CAST(7501.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000449 ', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-577', N'1000', NULL, CAST(7501.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000450 ', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-578', N'1000', NULL, CAST(7501.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000451 ', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-579', N'1000', N'1000-516', NULL, CAST(2501.00 AS Decimal(10, 2)), N'PAY', N'1000-100000020', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-58', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2022-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-580', N'1000', N'1000-576', NULL, CAST(7501.00 AS Decimal(10, 2)), N'PAY', N'1000-100000020', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-581', N'1000', N'1000-517', NULL, CAST(2501.00 AS Decimal(10, 2)), N'PAY', N'1000-100000021', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-582', N'1000', N'1000-577', NULL, CAST(7501.00 AS Decimal(10, 2)), N'PAY', N'1000-100000021', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-583', N'1000', N'1000-518', NULL, CAST(2501.00 AS Decimal(10, 2)), N'PAY', N'1000-100000022', N'PRC', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-584', N'1000', N'1000-578', NULL, CAST(7501.00 AS Decimal(10, 2)), N'PAY', N'1000-100000022', N'ITS', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-59', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2023-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-6', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-60', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2023-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-61', N'1000', NULL, CAST(3801.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000001 ', N'ITS', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-62', N'1000', NULL, CAST(3801.00 AS Decimal(10, 2)), NULL, N'ITR', N'1000-100000002 ', N'ITS', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-63', N'1000', N'1000-61', NULL, CAST(3801.00 AS Decimal(10, 2)), N'PAY', N'1000-100000001', N'ITS', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-64', N'1000', N'1000-62', NULL, CAST(3801.00 AS Decimal(10, 2)), N'PAY', N'1000-100000002', N'ITS', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-65', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-66', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-67', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-68', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-69', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-7', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-70', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-71', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-72', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-73', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-74', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-75', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-76', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-77', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-78', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-79', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-8', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-80', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-81', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-82', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-83', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-84', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-85', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-86', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2019-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-87', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-88', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-02-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-89', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-03-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-9', N'1000', NULL, CAST(1584.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000001', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2018-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-90', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-04-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-91', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-05-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-92', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-06-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-93', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-07-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-94', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-08-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-95', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-09-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-96', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-10-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-97', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-11-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-98', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2020-12-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Ledger] ([posting_id], [loc_prefix], [ref_posting_id], [debit_amt], [credit_amt], [event_object], [pk_event_object], [case_type], [post_date], [value_date], [status_code]) VALUES (N'1000-99', N'1000', NULL, CAST(1117.00 AS Decimal(10, 2)), NULL, N'LON', N'1000-10000002', N'PRC', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(N'2021-01-01 00:00:00.000' AS DateTime), N'OPN')
INSERT [dbo].[Loan] ([loan_id], [date_appl], [amt_appl], [des_term], [class_id], [purp_id], [entity_id], [orig_branch], [status_id], [created_date], [created_by], [loc_code], [balance], [last_trans_date], [amort]) VALUES (N'1000-10000001', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(95000.00 AS Decimal(10, 2)), 60, 1002, 105, N'1000-10001', N'DU ', N'R', CAST(N'2018-02-19 19:00:21.000' AS DateTime), N'141', NULL, CAST(95000.00 AS Decimal(10, 2)), NULL, NULL)
INSERT [dbo].[Loan] ([loan_id], [date_appl], [amt_appl], [des_term], [class_id], [purp_id], [entity_id], [orig_branch], [status_id], [created_date], [created_by], [loc_code], [balance], [last_trans_date], [amort]) VALUES (N'1000-10000002', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(67000.00 AS Decimal(10, 2)), 60, 1001, 105, N'1000-10001', N'DU ', N'R', CAST(N'2018-02-19 20:08:06.000' AS DateTime), N'141', NULL, CAST(67000.00 AS Decimal(10, 2)), NULL, NULL)
INSERT [dbo].[Loan] ([loan_id], [date_appl], [amt_appl], [des_term], [class_id], [purp_id], [entity_id], [orig_branch], [status_id], [created_date], [created_by], [loc_code], [balance], [last_trans_date], [amort]) VALUES (N'1000-10000003', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(80000.00 AS Decimal(10, 2)), 50, 1001, 105, N'1000-10004', N'DU ', N'R', CAST(N'2018-02-19 20:25:31.000' AS DateTime), N'141', NULL, CAST(70000.00 AS Decimal(10, 2)), NULL, NULL)
INSERT [dbo].[Loan] ([loan_id], [date_appl], [amt_appl], [des_term], [class_id], [purp_id], [entity_id], [orig_branch], [status_id], [created_date], [created_by], [loc_code], [balance], [last_trans_date], [amort]) VALUES (N'1000-10000004', CAST(N'2018-02-19 00:00:00.000' AS DateTime), CAST(30000.00 AS Decimal(10, 2)), 36, 1003, 105, N'1000-10004', N'DU ', N'R', CAST(N'2018-02-19 21:59:32.000' AS DateTime), N'141', NULL, CAST(30000.00 AS Decimal(10, 2)), NULL, NULL)
INSERT [dbo].[Loan] ([loan_id], [date_appl], [amt_appl], [des_term], [class_id], [purp_id], [entity_id], [orig_branch], [status_id], [created_date], [created_by], [loc_code], [balance], [last_trans_date], [amort]) VALUES (N'1000-10000005', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(50000.00 AS Decimal(10, 2)), 30, 1004, 105, N'1000-10004', N'DU ', N'R', CAST(N'2018-02-20 10:53:46.000' AS DateTime), N'141', NULL, CAST(50000.00 AS Decimal(10, 2)), NULL, NULL)
INSERT [dbo].[Loan] ([loan_id], [date_appl], [amt_appl], [des_term], [class_id], [purp_id], [entity_id], [orig_branch], [status_id], [created_date], [created_by], [loc_code], [balance], [last_trans_date], [amort]) VALUES (N'1000-10000006', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(80000.00 AS Decimal(10, 2)), 50, 1001, 105, N'1000-10002', N'DU ', N'A', CAST(N'2018-02-20 11:05:50.000' AS DateTime), N'141', NULL, CAST(0.00 AS Decimal(10, 2)), NULL, NULL)
INSERT [dbo].[Loan] ([loan_id], [date_appl], [amt_appl], [des_term], [class_id], [purp_id], [entity_id], [orig_branch], [status_id], [created_date], [created_by], [loc_code], [balance], [last_trans_date], [amort]) VALUES (N'1000-10000007', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(45000.00 AS Decimal(10, 2)), 30, 1004, 105, N'1000-10002', N'DU ', N'R', CAST(N'2018-02-20 11:24:37.000' AS DateTime), N'141', NULL, CAST(45000.00 AS Decimal(10, 2)), NULL, NULL)
INSERT [dbo].[Loan] ([loan_id], [date_appl], [amt_appl], [des_term], [class_id], [purp_id], [entity_id], [orig_branch], [status_id], [created_date], [created_by], [loc_code], [balance], [last_trans_date], [amort]) VALUES (N'1000-10000008', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(59000.00 AS Decimal(10, 2)), 48, 1005, 104, N'1000-10003', N'DU ', N'R', CAST(N'2018-02-20 11:28:18.000' AS DateTime), N'141', NULL, CAST(59000.00 AS Decimal(10, 2)), NULL, NULL)
INSERT [dbo].[Loan] ([loan_id], [date_appl], [amt_appl], [des_term], [class_id], [purp_id], [entity_id], [orig_branch], [status_id], [created_date], [created_by], [loc_code], [balance], [last_trans_date], [amort]) VALUES (N'1000-10000009', CAST(N'2018-07-20 00:00:00.000' AS DateTime), CAST(34000.00 AS Decimal(10, 2)), 40, 1006, 105, N'1000-10003', N'DU ', N'R', CAST(N'2018-02-20 12:14:46.000' AS DateTime), N'141', NULL, CAST(34000.00 AS Decimal(10, 2)), NULL, NULL)
INSERT [dbo].[Loan] ([loan_id], [date_appl], [amt_appl], [des_term], [class_id], [purp_id], [entity_id], [orig_branch], [status_id], [created_date], [created_by], [loc_code], [balance], [last_trans_date], [amort]) VALUES (N'1000-10000010', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(90000.00 AS Decimal(10, 2)), 60, 1001, 105, N'1000-10005', N'DU ', N'R', CAST(N'2018-02-20 13:33:32.000' AS DateTime), N'141', NULL, CAST(90000.00 AS Decimal(10, 2)), NULL, NULL)
INSERT [dbo].[Loan] ([loan_id], [date_appl], [amt_appl], [des_term], [class_id], [purp_id], [entity_id], [orig_branch], [status_id], [created_date], [created_by], [loc_code], [balance], [last_trans_date], [amort]) VALUES (N'1000-10000011', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(50000.00 AS Decimal(10, 2)), 34, 1006, 105, N'1000-10005', N'DU ', N'R', CAST(N'2018-02-20 13:35:56.000' AS DateTime), N'141', NULL, CAST(50000.00 AS Decimal(10, 2)), NULL, NULL)
INSERT [dbo].[Loan] ([loan_id], [date_appl], [amt_appl], [des_term], [class_id], [purp_id], [entity_id], [orig_branch], [status_id], [created_date], [created_by], [loc_code], [balance], [last_trans_date], [amort]) VALUES (N'1000-10000012', CAST(N'2018-02-20 00:00:00.000' AS DateTime), CAST(150000.00 AS Decimal(10, 2)), 60, 1007, 105, N'1000-10005', N'DU ', N'R', CAST(N'2018-02-20 14:10:04.000' AS DateTime), N'141', NULL, CAST(150000.00 AS Decimal(10, 2)), NULL, NULL)
INSERT [dbo].[LoanAppv] ([loan_id], [amt_appv], [date_appv], [appv_by], [terms], [appv_method], [remarks], [created_date], [created_by]) VALUES (N'1000-10000001', CAST(95000.00 AS Decimal(10, 2)), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'141', 60, N'C', NULL, CAST(N'2018-02-19 19:01:23.000' AS DateTime), N'141')
INSERT [dbo].[LoanAppv] ([loan_id], [amt_appv], [date_appv], [appv_by], [terms], [appv_method], [remarks], [created_date], [created_by]) VALUES (N'1000-10000002', CAST(67000.00 AS Decimal(10, 2)), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'141', 60, N'C', NULL, CAST(N'2018-02-19 20:08:34.000' AS DateTime), N'141')
INSERT [dbo].[LoanAppv] ([loan_id], [amt_appv], [date_appv], [appv_by], [terms], [appv_method], [remarks], [created_date], [created_by]) VALUES (N'1000-10000003', CAST(80000.00 AS Decimal(10, 2)), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'141', 50, N'C', NULL, CAST(N'2018-02-19 20:25:47.000' AS DateTime), N'141')
INSERT [dbo].[LoanAppv] ([loan_id], [amt_appv], [date_appv], [appv_by], [terms], [appv_method], [remarks], [created_date], [created_by]) VALUES (N'1000-10000004', CAST(30000.00 AS Decimal(10, 2)), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'141', 36, N'S', NULL, CAST(N'2018-02-19 21:59:44.000' AS DateTime), N'141')
INSERT [dbo].[LoanAppv] ([loan_id], [amt_appv], [date_appv], [appv_by], [terms], [appv_method], [remarks], [created_date], [created_by]) VALUES (N'1000-10000005', CAST(50000.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', 30, N'C', NULL, CAST(N'2018-02-20 10:54:06.000' AS DateTime), N'141')
INSERT [dbo].[LoanAppv] ([loan_id], [amt_appv], [date_appv], [appv_by], [terms], [appv_method], [remarks], [created_date], [created_by]) VALUES (N'1000-10000006', CAST(80000.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', 50, N'C', NULL, CAST(N'2018-02-20 11:06:02.000' AS DateTime), N'141')
INSERT [dbo].[LoanAppv] ([loan_id], [amt_appv], [date_appv], [appv_by], [terms], [appv_method], [remarks], [created_date], [created_by]) VALUES (N'1000-10000007', CAST(45000.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', 30, N'C', NULL, CAST(N'2018-02-20 11:24:48.000' AS DateTime), N'141')
INSERT [dbo].[LoanAppv] ([loan_id], [amt_appv], [date_appv], [appv_by], [terms], [appv_method], [remarks], [created_date], [created_by]) VALUES (N'1000-10000008', CAST(59000.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', 48, N'S', NULL, CAST(N'2018-02-20 11:28:54.000' AS DateTime), N'141')
INSERT [dbo].[LoanAppv] ([loan_id], [amt_appv], [date_appv], [appv_by], [terms], [appv_method], [remarks], [created_date], [created_by]) VALUES (N'1000-10000009', CAST(34000.00 AS Decimal(10, 2)), CAST(N'2018-07-20 00:00:00.000' AS DateTime), N'141', 40, N'C', NULL, CAST(N'2018-02-20 12:14:55.000' AS DateTime), N'141')
INSERT [dbo].[LoanAppv] ([loan_id], [amt_appv], [date_appv], [appv_by], [terms], [appv_method], [remarks], [created_date], [created_by]) VALUES (N'1000-10000010', CAST(90000.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', 60, N'C', NULL, CAST(N'2018-02-20 13:33:47.000' AS DateTime), N'141')
INSERT [dbo].[LoanAppv] ([loan_id], [amt_appv], [date_appv], [appv_by], [terms], [appv_method], [remarks], [created_date], [created_by]) VALUES (N'1000-10000011', CAST(50000.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', 34, N'C', NULL, CAST(N'2018-02-20 13:36:20.000' AS DateTime), N'141')
INSERT [dbo].[LoanAppv] ([loan_id], [amt_appv], [date_appv], [appv_by], [terms], [appv_method], [remarks], [created_date], [created_by]) VALUES (N'1000-10000012', CAST(150000.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', 60, N'C', NULL, CAST(N'2018-02-20 14:10:46.000' AS DateTime), N'141')
INSERT [dbo].[LoanAss] ([loan_id], [rec_code], [rec_amt], [date_ass], [ass_by], [capacity], [character], [capital], [conditions], [collateral], [comaker], [created_date], [created_by]) VALUES (N'1000-10000001', 0, CAST(95000.00 AS Decimal(10, 2)), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'141', NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-02-19 19:00:33.000' AS DateTime), N'141')
INSERT [dbo].[LoanAss] ([loan_id], [rec_code], [rec_amt], [date_ass], [ass_by], [capacity], [character], [capital], [conditions], [collateral], [comaker], [created_date], [created_by]) VALUES (N'1000-10000002', 0, CAST(67000.00 AS Decimal(10, 2)), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'141', NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-02-19 20:08:29.000' AS DateTime), N'141')
INSERT [dbo].[LoanAss] ([loan_id], [rec_code], [rec_amt], [date_ass], [ass_by], [capacity], [character], [capital], [conditions], [collateral], [comaker], [created_date], [created_by]) VALUES (N'1000-10000003', 0, CAST(80000.00 AS Decimal(10, 2)), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'141', NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-02-19 20:25:39.000' AS DateTime), N'141')
INSERT [dbo].[LoanAss] ([loan_id], [rec_code], [rec_amt], [date_ass], [ass_by], [capacity], [character], [capital], [conditions], [collateral], [comaker], [created_date], [created_by]) VALUES (N'1000-10000004', 0, CAST(30000.00 AS Decimal(10, 2)), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'141', NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-02-19 21:59:38.000' AS DateTime), N'141')
INSERT [dbo].[LoanAss] ([loan_id], [rec_code], [rec_amt], [date_ass], [ass_by], [capacity], [character], [capital], [conditions], [collateral], [comaker], [created_date], [created_by]) VALUES (N'1000-10000005', 0, CAST(50000.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-02-20 10:53:54.000' AS DateTime), N'141')
INSERT [dbo].[LoanAss] ([loan_id], [rec_code], [rec_amt], [date_ass], [ass_by], [capacity], [character], [capital], [conditions], [collateral], [comaker], [created_date], [created_by]) VALUES (N'1000-10000006', 0, CAST(80000.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-02-20 11:05:58.000' AS DateTime), N'141')
INSERT [dbo].[LoanAss] ([loan_id], [rec_code], [rec_amt], [date_ass], [ass_by], [capacity], [character], [capital], [conditions], [collateral], [comaker], [created_date], [created_by]) VALUES (N'1000-10000007', 0, CAST(45000.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-02-20 11:24:43.000' AS DateTime), N'141')
INSERT [dbo].[LoanAss] ([loan_id], [rec_code], [rec_amt], [date_ass], [ass_by], [capacity], [character], [capital], [conditions], [collateral], [comaker], [created_date], [created_by]) VALUES (N'1000-10000008', 0, CAST(59000.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-02-20 11:28:49.000' AS DateTime), N'141')
INSERT [dbo].[LoanAss] ([loan_id], [rec_code], [rec_amt], [date_ass], [ass_by], [capacity], [character], [capital], [conditions], [collateral], [comaker], [created_date], [created_by]) VALUES (N'1000-10000009', 0, CAST(34000.00 AS Decimal(10, 2)), CAST(N'2018-07-20 00:00:00.000' AS DateTime), N'141', NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-02-20 12:14:51.000' AS DateTime), N'141')
INSERT [dbo].[LoanAss] ([loan_id], [rec_code], [rec_amt], [date_ass], [ass_by], [capacity], [character], [capital], [conditions], [collateral], [comaker], [created_date], [created_by]) VALUES (N'1000-10000010', 0, CAST(90000.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-02-20 13:33:39.000' AS DateTime), N'141')
INSERT [dbo].[LoanAss] ([loan_id], [rec_code], [rec_amt], [date_ass], [ass_by], [capacity], [character], [capital], [conditions], [collateral], [comaker], [created_date], [created_by]) VALUES (N'1000-10000011', 0, CAST(50000.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-02-20 13:36:02.000' AS DateTime), N'141')
INSERT [dbo].[LoanAss] ([loan_id], [rec_code], [rec_amt], [date_ass], [ass_by], [capacity], [character], [capital], [conditions], [collateral], [comaker], [created_date], [created_by]) VALUES (N'1000-10000012', 0, CAST(150000.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', NULL, NULL, NULL, NULL, NULL, NULL, CAST(N'2018-02-20 14:10:41.000' AS DateTime), N'141')
INSERT [dbo].[LoanCharge] ([loan_id], [charge_type], [charge_amt]) VALUES (N'1000-10000001', N'DS', CAST(100.00 AS Decimal(10, 2)))
INSERT [dbo].[LoanCharge] ([loan_id], [charge_type], [charge_amt]) VALUES (N'1000-10000001', N'LP', CAST(456.00 AS Decimal(10, 2)))
INSERT [dbo].[LoanCharge] ([loan_id], [charge_type], [charge_amt]) VALUES (N'1000-10000002', N'DS', CAST(100.00 AS Decimal(10, 2)))
INSERT [dbo].[LoanCharge] ([loan_id], [charge_type], [charge_amt]) VALUES (N'1000-10000002', N'LP', CAST(321.60 AS Decimal(10, 2)))
INSERT [dbo].[LoanCharge] ([loan_id], [charge_type], [charge_amt]) VALUES (N'1000-10000003', N'DS', CAST(100.00 AS Decimal(10, 2)))
INSERT [dbo].[LoanCharge] ([loan_id], [charge_type], [charge_amt]) VALUES (N'1000-10000003', N'LP', CAST(336.00 AS Decimal(10, 2)))
INSERT [dbo].[LoanCharge] ([loan_id], [charge_type], [charge_amt]) VALUES (N'1000-10000004', N'DS', CAST(125.00 AS Decimal(10, 2)))
INSERT [dbo].[LoanCharge] ([loan_id], [charge_type], [charge_amt]) VALUES (N'1000-10000004', N'LP', CAST(24.00 AS Decimal(10, 2)))
INSERT [dbo].[LoanCharge] ([loan_id], [charge_type], [charge_amt]) VALUES (N'1000-10000004', N'SF', CAST(100.00 AS Decimal(10, 2)))
INSERT [dbo].[LoanCharge] ([loan_id], [charge_type], [charge_amt]) VALUES (N'1000-10000005', N'DS', CAST(100.00 AS Decimal(10, 2)))
INSERT [dbo].[LoanCharge] ([loan_id], [charge_type], [charge_amt]) VALUES (N'1000-10000005', N'LP', CAST(240.00 AS Decimal(10, 2)))
INSERT [dbo].[LoanCharge] ([loan_id], [charge_type], [charge_amt]) VALUES (N'1000-10000007', N'DS', CAST(100.00 AS Decimal(10, 2)))
INSERT [dbo].[LoanCharge] ([loan_id], [charge_type], [charge_amt]) VALUES (N'1000-10000007', N'LP', CAST(216.00 AS Decimal(10, 2)))
INSERT [dbo].[LoanCharge] ([loan_id], [charge_type], [charge_amt]) VALUES (N'1000-10000009', N'DS', CAST(125.00 AS Decimal(10, 2)))
INSERT [dbo].[LoanCharge] ([loan_id], [charge_type], [charge_amt]) VALUES (N'1000-10000010', N'DS', CAST(100.00 AS Decimal(10, 2)))
INSERT [dbo].[LoanCharge] ([loan_id], [charge_type], [charge_amt]) VALUES (N'1000-10000010', N'LP', CAST(432.00 AS Decimal(10, 2)))
INSERT [dbo].[LoanCharge] ([loan_id], [charge_type], [charge_amt]) VALUES (N'1000-10000011', N'DS', CAST(100.00 AS Decimal(10, 2)))
INSERT [dbo].[LoanCharge] ([loan_id], [charge_type], [charge_amt]) VALUES (N'1000-10000011', N'LP', CAST(240.00 AS Decimal(10, 2)))
INSERT [dbo].[LoanClass] ([class_id], [grp_id], [class_name], [int_rate], [term], [comakers_min], [comakers_max], [int_comp_method], [max_loan], [valid_from], [valid_until], [loc_code], [pay_freq], [max_age], [is_scheduled]) VALUES (1001, N'1000-101', N'DEPED 1', 4, 60, 2, 2, N'D', CAST(100000.00 AS Decimal(10, 2)), CAST(N'2018-02-01 00:00:00.000' AS DateTime), NULL, N'BOG', N'M', 60, 0)
INSERT [dbo].[LoanClass] ([class_id], [grp_id], [class_name], [int_rate], [term], [comakers_min], [comakers_max], [int_comp_method], [max_loan], [valid_from], [valid_until], [loc_code], [pay_freq], [max_age], [is_scheduled]) VALUES (1002, N'1000-101', N'DEPED 2', 5, 60, 1, 2, N'F', CAST(100000.00 AS Decimal(10, 2)), CAST(N'2018-02-01 00:00:00.000' AS DateTime), NULL, N'BOG', N'M', NULL, 0)
INSERT [dbo].[LoanClass] ([class_id], [grp_id], [class_name], [int_rate], [term], [comakers_min], [comakers_max], [int_comp_method], [max_loan], [valid_from], [valid_until], [loc_code], [pay_freq], [max_age], [is_scheduled]) VALUES (1003, N'1000-101', N'DEPED 3', 5, 36, 1, 2, N'D', CAST(45000.00 AS Decimal(10, 2)), CAST(N'2018-02-19 00:00:00.000' AS DateTime), NULL, N'BOG', N'M', 60, 1)
INSERT [dbo].[LoanClass] ([class_id], [grp_id], [class_name], [int_rate], [term], [comakers_min], [comakers_max], [int_comp_method], [max_loan], [valid_from], [valid_until], [loc_code], [pay_freq], [max_age], [is_scheduled]) VALUES (1004, N'1000-101', N'DEPED 4', 2.5, 30, 0, 0, N'D', CAST(50000.00 AS Decimal(10, 2)), CAST(N'2018-02-19 00:00:00.000' AS DateTime), NULL, N'BOG', N'M', NULL, 0)
INSERT [dbo].[LoanClass] ([class_id], [grp_id], [class_name], [int_rate], [term], [comakers_min], [comakers_max], [int_comp_method], [max_loan], [valid_from], [valid_until], [loc_code], [pay_freq], [max_age], [is_scheduled]) VALUES (1005, N'1000-102', N'PRIVATE 1', 1.25, 48, 1, 2, N'D', CAST(100000.00 AS Decimal(10, 2)), CAST(N'2018-02-19 00:00:00.000' AS DateTime), NULL, N'BOG', N'M', NULL, 0)
INSERT [dbo].[LoanClass] ([class_id], [grp_id], [class_name], [int_rate], [term], [comakers_min], [comakers_max], [int_comp_method], [max_loan], [valid_from], [valid_until], [loc_code], [pay_freq], [max_age], [is_scheduled]) VALUES (1006, N'1000-102', N'PRIVATE 2', 2.6, 48, 0, NULL, N'D', CAST(68000.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), NULL, N'BOG', N'M', NULL, 0)
INSERT [dbo].[LoanClass] ([class_id], [grp_id], [class_name], [int_rate], [term], [comakers_min], [comakers_max], [int_comp_method], [max_loan], [valid_from], [valid_until], [loc_code], [pay_freq], [max_age], [is_scheduled]) VALUES (1007, N'1000-102', N'PRIVATE 3', 5, 60, 0, 0, N'F', CAST(200000.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), NULL, N'BOG', N'M', NULL, 0)
INSERT [dbo].[LoanClassAdvance] ([class_id], [int], [principal], [advance_method], [include_principal]) VALUES (1001, 2, 2, 2, 1)
INSERT [dbo].[LoanClassAdvance] ([class_id], [int], [principal], [advance_method], [include_principal]) VALUES (1002, 2, 0, 2, 0)
INSERT [dbo].[LoanClassAdvance] ([class_id], [int], [principal], [advance_method], [include_principal]) VALUES (1003, 0, 0, 1, 1)
INSERT [dbo].[LoanClassAdvance] ([class_id], [int], [principal], [advance_method], [include_principal]) VALUES (1004, 0, 0, 1, 0)
INSERT [dbo].[LoanClassAdvance] ([class_id], [int], [principal], [advance_method], [include_principal]) VALUES (1005, 0, 0, 1, 1)
INSERT [dbo].[LoanClassAdvance] ([class_id], [int], [principal], [advance_method], [include_principal]) VALUES (1007, 3, 3, 2, 1)
INSERT [dbo].[LoanClassCharge] ([class_id], [charge_type], [charge_value], [value_type], [ratio_amt], [max_value], [max_value_type], [for_new], [for_renew], [for_reloan], [for_restructure]) VALUES (1001, N'DS', CAST(100.00 AS Decimal(8, 2)), 0, CAST(0.00 AS Decimal(8, 2)), CAST(0.00 AS Decimal(8, 2)), 0, 1, 1, 1, 1)
INSERT [dbo].[LoanClassCharge] ([class_id], [charge_type], [charge_value], [value_type], [ratio_amt], [max_value], [max_value_type], [for_new], [for_renew], [for_reloan], [for_restructure]) VALUES (1001, N'LP', CAST(1.00 AS Decimal(8, 2)), 2, CAST(5000.00 AS Decimal(8, 2)), CAST(24.00 AS Decimal(8, 2)), 0, 1, 1, 1, 1)
INSERT [dbo].[LoanClassCharge] ([class_id], [charge_type], [charge_value], [value_type], [ratio_amt], [max_value], [max_value_type], [for_new], [for_renew], [for_reloan], [for_restructure]) VALUES (1002, N'DS', CAST(50.00 AS Decimal(8, 2)), 0, CAST(0.00 AS Decimal(8, 2)), CAST(0.00 AS Decimal(8, 2)), 0, 1, 1, 1, 1)
INSERT [dbo].[LoanClassCharge] ([class_id], [charge_type], [charge_value], [value_type], [ratio_amt], [max_value], [max_value_type], [for_new], [for_renew], [for_reloan], [for_restructure]) VALUES (1003, N'DS', CAST(125.00 AS Decimal(8, 2)), 0, CAST(0.00 AS Decimal(8, 2)), CAST(0.00 AS Decimal(8, 2)), 0, 1, 1, 1, 1)
INSERT [dbo].[LoanClassCharge] ([class_id], [charge_type], [charge_value], [value_type], [ratio_amt], [max_value], [max_value_type], [for_new], [for_renew], [for_reloan], [for_restructure]) VALUES (1003, N'LP', CAST(1.00 AS Decimal(8, 2)), 2, CAST(1000.00 AS Decimal(8, 2)), CAST(24.00 AS Decimal(8, 2)), 1, 1, 1, 1, 1)
INSERT [dbo].[LoanClassCharge] ([class_id], [charge_type], [charge_value], [value_type], [ratio_amt], [max_value], [max_value_type], [for_new], [for_renew], [for_reloan], [for_restructure]) VALUES (1003, N'SF', CAST(100.00 AS Decimal(8, 2)), 0, CAST(0.00 AS Decimal(8, 2)), CAST(0.00 AS Decimal(8, 2)), 0, 1, 1, 1, 1)
INSERT [dbo].[LoanClassCharge] ([class_id], [charge_type], [charge_value], [value_type], [ratio_amt], [max_value], [max_value_type], [for_new], [for_renew], [for_reloan], [for_restructure]) VALUES (1004, N'DS', CAST(125.00 AS Decimal(8, 2)), 0, CAST(0.00 AS Decimal(8, 2)), CAST(0.00 AS Decimal(8, 2)), 0, 1, 1, 1, 1)
INSERT [dbo].[LoanClassCharge] ([class_id], [charge_type], [charge_value], [value_type], [ratio_amt], [max_value], [max_value_type], [for_new], [for_renew], [for_reloan], [for_restructure]) VALUES (1004, N'LP', CAST(2.00 AS Decimal(8, 2)), 2, CAST(1000.00 AS Decimal(8, 2)), CAST(1000.00 AS Decimal(8, 2)), 1, 1, 1, 1, 1)
INSERT [dbo].[LoanClassCharge] ([class_id], [charge_type], [charge_value], [value_type], [ratio_amt], [max_value], [max_value_type], [for_new], [for_renew], [for_reloan], [for_restructure]) VALUES (1006, N'DS', CAST(125.00 AS Decimal(8, 2)), 0, CAST(0.00 AS Decimal(8, 2)), CAST(0.00 AS Decimal(8, 2)), 0, 1, 1, 1, 1)
INSERT [dbo].[LoanClose] ([loan_id], [date_closed], [closed_by], [remarks], [reason_id]) VALUES (N'1000-10000001', CAST(N'2018-01-18 00:00:00.000' AS DateTime), N'141', N'test close', 201)
INSERT [dbo].[LoanComaker] ([loan_id], [entity_id]) VALUES (N'1000-10000002', N'1000-10002')
INSERT [dbo].[LoanComaker] ([loan_id], [entity_id]) VALUES (N'1000-10000002', N'1000-10003')
INSERT [dbo].[LoanComaker] ([loan_id], [entity_id]) VALUES (N'1000-10000003', N'1000-10001')
INSERT [dbo].[LoanComaker] ([loan_id], [entity_id]) VALUES (N'1000-10000003', N'1000-10002')
INSERT [dbo].[LoanComaker] ([loan_id], [entity_id]) VALUES (N'1000-10000004', N'1000-10001')
INSERT [dbo].[LoanComaker] ([loan_id], [entity_id]) VALUES (N'1000-10000006', N'1000-10003')
INSERT [dbo].[LoanComaker] ([loan_id], [entity_id]) VALUES (N'1000-10000006', N'1000-10004')
INSERT [dbo].[LoanComaker] ([loan_id], [entity_id]) VALUES (N'1000-10000008', N'1000-10001')
INSERT [dbo].[LoanComaker] ([loan_id], [entity_id]) VALUES (N'1000-10000008', N'1000-10002')
INSERT [dbo].[LoanComaker] ([loan_id], [entity_id]) VALUES (N'1000-10000010', N'1000-10003')
INSERT [dbo].[LoanComaker] ([loan_id], [entity_id]) VALUES (N'1000-10000010', N'1000-10004')
INSERT [dbo].[LoanRelease] ([loan_id], [recipient], [rel_method], [rel_amt], [date_rel], [rel_by], [loc_code]) VALUES (N'1000-10000001', N'1000-10001', N'C', CAST(86842.00 AS Decimal(10, 2)), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'141', N'DU ')
INSERT [dbo].[LoanRelease] ([loan_id], [recipient], [rel_method], [rel_amt], [date_rel], [rel_by], [loc_code]) VALUES (N'1000-10000002', N'1000-10001', N'C', CAST(59027.40 AS Decimal(10, 2)), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'141', N'DU ')
INSERT [dbo].[LoanRelease] ([loan_id], [recipient], [rel_method], [rel_amt], [date_rel], [rel_by], [loc_code]) VALUES (N'1000-10000003', N'1000-10004', N'C', CAST(61217.00 AS Decimal(10, 2)), CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'141', N'DU ')
INSERT [dbo].[LoanRelease] ([loan_id], [recipient], [rel_method], [rel_amt], [date_rel], [rel_by], [loc_code]) VALUES (N'1000-10000004', N'1000-10004', N'C', CAST(24312.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', N'DU ')
INSERT [dbo].[LoanRelease] ([loan_id], [recipient], [rel_method], [rel_amt], [date_rel], [rel_by], [loc_code]) VALUES (N'1000-10000005', N'1000-10004', N'C', CAST(47200.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', N'DU ')
INSERT [dbo].[LoanRelease] ([loan_id], [recipient], [rel_method], [rel_amt], [date_rel], [rel_by], [loc_code]) VALUES (N'1000-10000007', N'1000-10002', N'C', CAST(40407.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', N'DU ')
INSERT [dbo].[LoanRelease] ([loan_id], [recipient], [rel_method], [rel_amt], [date_rel], [rel_by], [loc_code]) VALUES (N'1000-10000008', N'1000-10003', N'C', CAST(55079.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', N'DU ')
INSERT [dbo].[LoanRelease] ([loan_id], [recipient], [rel_method], [rel_amt], [date_rel], [rel_by], [loc_code]) VALUES (N'1000-10000009', N'1000-10003', N'C', CAST(33875.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', N'DU ')
INSERT [dbo].[LoanRelease] ([loan_id], [recipient], [rel_method], [rel_amt], [date_rel], [rel_by], [loc_code]) VALUES (N'1000-10000010', N'1000-10005', N'C', CAST(79325.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', N'DU ')
INSERT [dbo].[LoanRelease] ([loan_id], [recipient], [rel_method], [rel_amt], [date_rel], [rel_by], [loc_code]) VALUES (N'1000-10000011', N'1000-10005', N'C', CAST(49660.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', N'DU ')
INSERT [dbo].[LoanRelease] ([loan_id], [recipient], [rel_method], [rel_amt], [date_rel], [rel_by], [loc_code]) VALUES (N'1000-10000012', N'1000-10005', N'C', CAST(119994.00 AS Decimal(10, 2)), CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'141', N'DU ')
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000001 ', NULL, CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'1000-10001', N'DU ', CAST(N'2018-02-19 19:02:20.000' AS DateTime), N'141', N'02192018190219672', CAST(N'2018-02-19 19:02:20.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000002 ', NULL, CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'1000-10001', N'DU ', CAST(N'2018-02-19 19:02:20.000' AS DateTime), N'141', N'02192018190219681', CAST(N'2018-02-19 19:02:20.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000003 ', NULL, CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'1000-10001', N'DU ', CAST(N'2018-02-19 20:10:01.000' AS DateTime), N'141', N'02192018201001164', CAST(N'2018-02-19 20:10:01.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000004 ', NULL, CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'1000-10001', N'DU ', CAST(N'2018-02-19 20:10:01.000' AS DateTime), N'141', N'02192018201001178', CAST(N'2018-02-19 20:10:01.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000005 ', NULL, CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'1000-10004', N'DU ', CAST(N'2018-02-19 20:26:24.000' AS DateTime), N'141', N'02192018202623575', CAST(N'2018-02-19 20:26:24.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000006 ', NULL, CAST(N'2018-02-19 00:00:00.000' AS DateTime), N'1000-10004', N'DU ', CAST(N'2018-02-19 20:26:24.000' AS DateTime), N'141', N'02192018202623591', CAST(N'2018-02-19 20:26:24.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000007 ', NULL, CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'1000-10004', N'DU ', CAST(N'2018-02-20 10:50:09.000' AS DateTime), N'141', N'02202018105008920', CAST(N'2018-02-20 10:50:09.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000008 ', NULL, CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'1000-10004', N'DU ', CAST(N'2018-02-20 10:50:09.000' AS DateTime), N'141', N'02202018105008936', CAST(N'2018-02-20 10:50:09.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000009 ', NULL, CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'1000-10004', N'DU ', CAST(N'2018-02-20 10:50:09.000' AS DateTime), N'141', N'02202018105008952', CAST(N'2018-02-20 10:50:09.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000010 ', NULL, CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'1000-10004', N'DU ', CAST(N'2018-02-20 10:54:30.000' AS DateTime), N'141', N'02202018105430187', CAST(N'2018-02-20 10:54:30.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000011 ', NULL, CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'1000-10004', N'DU ', CAST(N'2018-02-20 10:54:30.000' AS DateTime), N'141', N'02202018105430197', CAST(N'2018-02-20 10:54:30.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000012 ', NULL, CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'1000-10002', N'DU ', CAST(N'2018-02-20 11:25:10.000' AS DateTime), N'141', N'02202018112509946', CAST(N'2018-02-20 11:25:10.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000013 ', NULL, CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'1000-10002', N'DU ', CAST(N'2018-02-20 11:25:10.000' AS DateTime), N'141', N'02202018112509956', CAST(N'2018-02-20 11:25:10.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000014 ', NULL, CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'1000-10002', N'DU ', CAST(N'2018-02-20 11:25:10.000' AS DateTime), N'141', N'02202018112509966', CAST(N'2018-02-20 11:25:10.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000015 ', NULL, CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'1000-10002', N'DU ', CAST(N'2018-02-20 11:25:10.000' AS DateTime), N'141', N'02202018112509976', CAST(N'2018-02-20 11:25:10.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000016 ', NULL, CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'1000-10003', N'DU ', CAST(N'2018-02-20 11:29:05.000' AS DateTime), N'141', N'02202018112905054', CAST(N'2018-02-20 11:29:05.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000017 ', NULL, CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'1000-10003', N'DU ', CAST(N'2018-02-20 11:29:05.000' AS DateTime), N'141', N'02202018112905073', CAST(N'2018-02-20 11:29:05.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000018 ', NULL, CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'1000-10005', N'DU ', CAST(N'2018-02-20 13:35:02.000' AS DateTime), N'141', N'02202018133501925', CAST(N'2018-02-20 13:35:02.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000019 ', NULL, CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'1000-10005', N'DU ', CAST(N'2018-02-20 13:35:02.000' AS DateTime), N'141', N'02202018133501937', CAST(N'2018-02-20 13:35:02.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000020 ', NULL, CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'1000-10005', N'DU ', CAST(N'2018-02-20 14:19:27.000' AS DateTime), N'141', N'02202018141926980', CAST(N'2018-02-20 14:19:27.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000021 ', NULL, CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'1000-10005', N'DU ', CAST(N'2018-02-20 14:19:27.000' AS DateTime), N'141', N'02202018141926992', CAST(N'2018-02-20 14:19:27.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[Payment] ([payment_id], [receipt_no], [payment_date], [entity_id], [loc_code], [created_date], [created_by], [ref_no], [post_date], [wd_id], [is_advance], [pmt_method]) VALUES (N'1000-100000022 ', NULL, CAST(N'2018-02-20 00:00:00.000' AS DateTime), N'1000-10005', N'DU ', CAST(N'2018-02-20 14:19:27.000' AS DateTime), N'141', N'02202018141927004', CAST(N'2018-02-20 14:19:27.000' AS DateTime), NULL, 1, 1)
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000001 ', N'1000-10000001', CAST(3801.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000002 ', N'1000-10000001', CAST(3801.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000003 ', N'1000-10000002', CAST(2681.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000003 ', N'1000-10000002', CAST(1117.00 AS Decimal(10, 2)), NULL, 0, N'PRN', CAST(65883.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000004 ', N'1000-10000002', CAST(2636.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000004 ', N'1000-10000002', CAST(1117.00 AS Decimal(10, 2)), NULL, 0, N'PRN', CAST(64766.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000005 ', N'1000-10000003', CAST(2801.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000005 ', N'1000-10000003', CAST(1401.00 AS Decimal(10, 2)), NULL, 0, N'PRN', CAST(68599.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000006 ', N'1000-10000003', CAST(2744.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000006 ', N'1000-10000003', CAST(1401.00 AS Decimal(10, 2)), NULL, 0, N'PRN', CAST(67198.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000007 ', N'1000-10000004', CAST(1501.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000007 ', N'1000-10000004', CAST(312.00 AS Decimal(10, 2)), NULL, 0, N'PRN', CAST(29688.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000008 ', N'1000-10000004', CAST(1485.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000008 ', N'1000-10000004', CAST(328.00 AS Decimal(10, 2)), NULL, 0, N'PRN', CAST(29360.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000009 ', N'1000-10000004', CAST(1469.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000009 ', N'1000-10000004', CAST(344.00 AS Decimal(10, 2)), NULL, 0, N'PRN', CAST(29016.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000010 ', N'1000-10000005', CAST(1251.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000011 ', N'1000-10000005', CAST(1209.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000012 ', N'1000-10000007', CAST(1126.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000013 ', N'1000-10000007', CAST(1088.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000014 ', N'1000-10000007', CAST(1050.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000015 ', N'1000-10000007', CAST(1013.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000016 ', N'1000-10000008', CAST(738.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000016 ', N'1000-10000008', CAST(1230.00 AS Decimal(10, 2)), NULL, 0, N'PRN', CAST(57770.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000017 ', N'1000-10000008', CAST(723.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000017 ', N'1000-10000008', CAST(1230.00 AS Decimal(10, 2)), NULL, 0, N'PRN', CAST(56540.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000018 ', N'1000-10000010', CAST(3601.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000018 ', N'1000-10000010', CAST(1501.00 AS Decimal(10, 2)), NULL, 0, N'PRN', CAST(88499.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000019 ', N'1000-10000010', CAST(3540.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000019 ', N'1000-10000010', CAST(1501.00 AS Decimal(10, 2)), NULL, 0, N'PRN', CAST(86998.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000020 ', N'1000-10000012', CAST(7501.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000020 ', N'1000-10000012', CAST(2501.00 AS Decimal(10, 2)), NULL, 0, N'PRN', CAST(147499.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000021 ', N'1000-10000012', CAST(7501.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000021 ', N'1000-10000012', CAST(2501.00 AS Decimal(10, 2)), NULL, 0, N'PRN', CAST(144998.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000022 ', N'1000-10000012', CAST(7501.00 AS Decimal(10, 2)), NULL, 0, N'INT', CAST(0.00 AS Decimal(10, 2)))
INSERT [dbo].[PaymentDetail] ([payment_id], [loan_id], [payment_amt], [remarks], [is_cancelled], [payment_type], [balance]) VALUES (N'1000-100000022 ', N'1000-10000012', CAST(2501.00 AS Decimal(10, 2)), NULL, 0, N'PRN', CAST(142497.00 AS Decimal(10, 2)))
INSERT [dbo].[PersonalInfo] ([entity_id], [lastname], [firstname], [middlename], [birth_date], [gender], [civil_status], [photo], [oth_income], [source_id]) VALUES (N'1000-10001', N'GARCIA', N'BRYAN', N'TEVES', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[PersonalInfo] ([entity_id], [lastname], [firstname], [middlename], [birth_date], [gender], [civil_status], [photo], [oth_income], [source_id]) VALUES (N'1000-10002', N'GARCIA', N'CHARMAE', N'GO', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[PersonalInfo] ([entity_id], [lastname], [firstname], [middlename], [birth_date], [gender], [civil_status], [photo], [oth_income], [source_id]) VALUES (N'1000-10003', N'GARCIA', N'BREE', N'BAJAMUNDE', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[PersonalInfo] ([entity_id], [lastname], [firstname], [middlename], [birth_date], [gender], [civil_status], [photo], [oth_income], [source_id]) VALUES (N'1000-10004', N'DOE', N'JOHN', N'DEER', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[PersonalInfo] ([entity_id], [lastname], [firstname], [middlename], [birth_date], [gender], [civil_status], [photo], [oth_income], [source_id]) VALUES (N'1000-10005', N'DEER', N'JOHN', N'DOE', NULL, NULL, NULL, NULL, NULL, NULL)
INSERT [dbo].[Sequence] ([seq_object], [last_id]) VALUES (N'EML', 103)
INSERT [dbo].[Sequence] ([seq_object], [last_id]) VALUES (N'ENT', 10005)
INSERT [dbo].[Sequence] ([seq_object], [last_id]) VALUES (N'GRP', 102)
INSERT [dbo].[Sequence] ([seq_object], [last_id]) VALUES (N'ITS', 100000508)
INSERT [dbo].[Sequence] ([seq_object], [last_id]) VALUES (N'LDG', 584)
INSERT [dbo].[Sequence] ([seq_object], [last_id]) VALUES (N'LNC', 1007)
INSERT [dbo].[Sequence] ([seq_object], [last_id]) VALUES (N'LON', 10000012)
INSERT [dbo].[Sequence] ([seq_object], [last_id]) VALUES (N'PAY', 100000022)
INSERT [dbo].[T_AccountType] ([acct_type], [acct_type_name], [acct_type_desc]) VALUES (101, N'REGULAR', NULL)
INSERT [dbo].[T_Bank] ([bank_code], [bank_name]) VALUES (N'BDO  ', N'Banco De Oro')
INSERT [dbo].[T_Bank] ([bank_code], [bank_name]) VALUES (N'BPI  ', N'Bank of the Philippine Islands')
INSERT [dbo].[T_Bank] ([bank_code], [bank_name]) VALUES (N'CHB  ', N'China Bank')
INSERT [dbo].[T_Bank] ([bank_code], [bank_name]) VALUES (N'DBP  ', N'Development Bank of the Phils')
INSERT [dbo].[T_Bank] ([bank_code], [bank_name]) VALUES (N'LNB  ', N'Land Bank of the Phils')
INSERT [dbo].[T_Bank] ([bank_code], [bank_name]) VALUES (N'MB   ', N'Metrobank')
INSERT [dbo].[T_Bank] ([bank_code], [bank_name]) VALUES (N'MYB  ', N'Maybank')
INSERT [dbo].[T_Bank] ([bank_code], [bank_name]) VALUES (N'PNB  ', N'Philippine National Bank')
INSERT [dbo].[T_ChargeType] ([charge_type], [charge_name]) VALUES (N'BS', N'Bee fees')
INSERT [dbo].[T_ChargeType] ([charge_type], [charge_name]) VALUES (N'DS', N'Documentary stamp')
INSERT [dbo].[T_ChargeType] ([charge_type], [charge_name]) VALUES (N'LP', N'LPPP ')
INSERT [dbo].[T_ChargeType] ([charge_type], [charge_name]) VALUES (N'SB', N'Service fee 2')
INSERT [dbo].[T_ChargeType] ([charge_type], [charge_name]) VALUES (N'SF', N'Service fee')
INSERT [dbo].[T_Designation] ([des_id], [designation]) VALUES (101, N'PROFESSIONAL ATHLETE')
INSERT [dbo].[T_Designation] ([des_id], [designation]) VALUES (102, N'TEACHER 2')
INSERT [dbo].[T_Designation] ([des_id], [designation]) VALUES (103, N'TEACHER 3')
INSERT [dbo].[T_Designation] ([des_id], [designation]) VALUES (105, N'TEACHER 1')
INSERT [dbo].[T_Designation] ([des_id], [designation]) VALUES (106, N'MECHANIC 1')
INSERT [dbo].[T_Designation] ([des_id], [designation]) VALUES (107, N'CREDIT INVESTIGATOR')
INSERT [dbo].[T_Designation] ([des_id], [designation]) VALUES (108, N'MANAGER')
INSERT [dbo].[T_Designation] ([des_id], [designation]) VALUES (109, N'PRINCIPAL')
INSERT [dbo].[T_Designation] ([des_id], [designation]) VALUES (110, N'GENERAL MANAGER')
INSERT [dbo].[T_Designation] ([des_id], [designation]) VALUES (111, N'POLICE OFFICER')
INSERT [dbo].[T_Designation] ([des_id], [designation]) VALUES (112, N'GUIDANCE COUNSEL')
INSERT [dbo].[T_Designation] ([des_id], [designation]) VALUES (113, N'INVESTIGATOR')
INSERT [dbo].[T_EntityType] ([entity_type], [entity_name], [entity_desc], [is_active], [is_client], [is_person]) VALUES (N'CK', N'Comaker', NULL, 1, 0, 1)
INSERT [dbo].[T_EntityType] ([entity_type], [entity_name], [entity_desc], [is_active], [is_client], [is_person]) VALUES (N'CL', N'Client', NULL, 1, 1, 1)
INSERT [dbo].[T_EntityType] ([entity_type], [entity_name], [entity_desc], [is_active], [is_client], [is_person]) VALUES (N'IH', N'Immediate head', NULL, 1, 0, 1)
INSERT [dbo].[T_EntityType] ([entity_type], [entity_name], [entity_desc], [is_active], [is_client], [is_person]) VALUES (N'LL', N'Landlord', NULL, 1, 0, 1)
INSERT [dbo].[T_EntityType] ([entity_type], [entity_name], [entity_desc], [is_active], [is_client], [is_person]) VALUES (N'RF', N'Reference', NULL, 1, 0, 1)
INSERT [dbo].[T_EntityType] ([entity_type], [entity_name], [entity_desc], [is_active], [is_client], [is_person]) VALUES (N'RP', N'Recipeint', NULL, 1, 0, 1)
INSERT [dbo].[T_ExpenseType] ([exp_type], [exp_name], [exp_desc]) VALUES (N'CL', N'Clothing', NULL)
INSERT [dbo].[T_ExpenseType] ([exp_type], [exp_name], [exp_desc]) VALUES (N'CM', N'Communication', NULL)
INSERT [dbo].[T_ExpenseType] ([exp_type], [exp_name], [exp_desc]) VALUES (N'EC', N'Electricity', NULL)
INSERT [dbo].[T_ExpenseType] ([exp_type], [exp_name], [exp_desc]) VALUES (N'FD', N'Food', NULL)
INSERT [dbo].[T_ExpenseType] ([exp_type], [exp_name], [exp_desc]) VALUES (N'OT', N'Others', NULL)
INSERT [dbo].[T_ExpenseType] ([exp_type], [exp_name], [exp_desc]) VALUES (N'RN', N'Rent', NULL)
INSERT [dbo].[T_ExpenseType] ([exp_type], [exp_name], [exp_desc]) VALUES (N'TR', N'Transportation', NULL)
INSERT [dbo].[T_ExpenseType] ([exp_type], [exp_name], [exp_desc]) VALUES (N'TU', N'Tuition', NULL)
INSERT [dbo].[T_ExpenseType] ([exp_type], [exp_name], [exp_desc]) VALUES (N'WT', N'Water', NULL)
INSERT [dbo].[T_IdentityType] ([ident_type], [ident_name], [ident_desc], [has_expiry]) VALUES (N'DL', N'Driver''s licence', NULL, 1)
INSERT [dbo].[T_IdentityType] ([ident_type], [ident_name], [ident_desc], [has_expiry]) VALUES (N'GS', N'GSIS', NULL, 1)
INSERT [dbo].[T_IdentityType] ([ident_type], [ident_name], [ident_desc], [has_expiry]) VALUES (N'PR', N'PRC', NULL, 1)
INSERT [dbo].[T_IdentityType] ([ident_type], [ident_name], [ident_desc], [has_expiry]) VALUES (N'PS', N'Postal ID', NULL, 1)
INSERT [dbo].[T_IdentityType] ([ident_type], [ident_name], [ident_desc], [has_expiry]) VALUES (N'SS', N'SSS', NULL, 0)
INSERT [dbo].[T_IdentityType] ([ident_type], [ident_name], [ident_desc], [has_expiry]) VALUES (N'TN', N'TIN', NULL, 0)
SET IDENTITY_INSERT [dbo].[T_InfoSource] ON 

INSERT [dbo].[T_InfoSource] ([source_id], [source_name]) VALUES (1, N'Google')
INSERT [dbo].[T_InfoSource] ([source_id], [source_name]) VALUES (2, N'Facebook')
INSERT [dbo].[T_InfoSource] ([source_id], [source_name]) VALUES (3, N'AdSense')
INSERT [dbo].[T_InfoSource] ([source_id], [source_name]) VALUES (4, N'Co-employee')
SET IDENTITY_INSERT [dbo].[T_InfoSource] OFF
INSERT [dbo].[T_LoanCancelReason] ([reason_id], [reason_name], [reason_desc]) VALUES (0, N'Unable to assess client', NULL)
INSERT [dbo].[T_LoanCancelReason] ([reason_id], [reason_name], [reason_desc]) VALUES (101, N'Cancelled by client', NULL)
INSERT [dbo].[T_LoanCancelReason] ([reason_id], [reason_name], [reason_desc]) VALUES (102, N'Erroneous entry', NULL)
INSERT [dbo].[T_LoanCloseReason] ([reason_id], [reason_name], [reason_desc], [is_system], [is_auto_post]) VALUES (201, N'Litigation', NULL, 0, 0)
INSERT [dbo].[T_LoanRejectReason] ([reason_id], [reason_name], [reason_desc]) VALUES (1, N'Too many expenses', NULL)
INSERT [dbo].[T_LoanRejectReason] ([reason_id], [reason_name], [reason_desc]) VALUES (2, N'Bad credit rating', NULL)
INSERT [dbo].[T_LoanRejectReason] ([reason_id], [reason_name], [reason_desc]) VALUES (101, N'Too many loans', NULL)
INSERT [dbo].[T_LoanRejectReason] ([reason_id], [reason_name], [reason_desc]) VALUES (102, N'Unemployed', NULL)
INSERT [dbo].[T_LoanStatus] ([status_id], [status_name], [status_desc], [is_active]) VALUES (N'A', N'Approved', NULL, 1)
INSERT [dbo].[T_LoanStatus] ([status_id], [status_name], [status_desc], [is_active]) VALUES (N'C', N'Cancelled', NULL, 1)
INSERT [dbo].[T_LoanStatus] ([status_id], [status_name], [status_desc], [is_active]) VALUES (N'F', N'Fully-paid/Closed', NULL, 1)
INSERT [dbo].[T_LoanStatus] ([status_id], [status_name], [status_desc], [is_active]) VALUES (N'J', N'Rejected', NULL, 1)
INSERT [dbo].[T_LoanStatus] ([status_id], [status_name], [status_desc], [is_active]) VALUES (N'P', N'Pending', NULL, 1)
INSERT [dbo].[T_LoanStatus] ([status_id], [status_name], [status_desc], [is_active]) VALUES (N'R', N'Active', NULL, 1)
INSERT [dbo].[T_LoanStatus] ([status_id], [status_name], [status_desc], [is_active]) VALUES (N'S', N'Assessed', NULL, 1)
INSERT [dbo].[T_LoanType] ([loan_type], [acct_type], [loan_type_name], [loan_type_desc], [max_concurrent], [max_tot_amt], [ident_docs]) VALUES (101, 101, N'SALARY', NULL, 0, CAST(0.00 AS Decimal(10, 2)), 0)
INSERT [dbo].[T_PaymentMethod] ([pmt_method], [pmt_method_name], [pmt_method_desc], [pmt_charge]) VALUES (1, N'Cash', N'Cash', NULL)
INSERT [dbo].[T_PaymentMethod] ([pmt_method], [pmt_method_name], [pmt_method_desc], [pmt_charge]) VALUES (2, N'Check', N'Check', NULL)
INSERT [dbo].[T_PaymentMethod] ([pmt_method], [pmt_method_name], [pmt_method_desc], [pmt_charge]) VALUES (3, N'Bank withdrawal', N'ATM', CAST(10.00 AS Decimal(8, 2)))
INSERT [dbo].[T_Province] ([area_code], [province]) VALUES (34, N'Negros Occidental')
INSERT [dbo].[T_Province] ([area_code], [province]) VALUES (35, N'Negros Oriental')
INSERT [dbo].[T_Province] ([area_code], [province]) VALUES (38, N'Bohol')
INSERT [dbo].[T_Province] ([area_code], [province]) VALUES (62, N'Zamboanga del Sur')
INSERT [dbo].[T_Province] ([area_code], [province]) VALUES (65, N'Zamboanga del Norte')
INSERT [dbo].[T_Province] ([area_code], [province]) VALUES (88, N'Misamis Or/Occ')
INSERT [dbo].[T_Purpose] ([purp_id], [purpose]) VALUES (101, N'TUITION')
INSERT [dbo].[T_Purpose] ([purp_id], [purpose]) VALUES (102, N'SHOPPING')
INSERT [dbo].[T_Purpose] ([purp_id], [purpose]) VALUES (103, N'VACATION')
INSERT [dbo].[T_Purpose] ([purp_id], [purpose]) VALUES (104, N'MEDICAL')
INSERT [dbo].[T_Purpose] ([purp_id], [purpose]) VALUES (105, N'HOUSE RENOVATION')
INSERT [dbo].[T_Purpose] ([purp_id], [purpose]) VALUES (106, N'NBA LEAGUE PASS')
INSERT [dbo].[T_ReferenceType] ([ref_type], [ref_name], [ref_desc], [is_family], [max]) VALUES (N'CE', N'Co-employee', NULL, 0, 0)
INSERT [dbo].[T_ReferenceType] ([ref_type], [ref_name], [ref_desc], [is_family], [max]) VALUES (N'CH', N'Child', NULL, 1, 0)
INSERT [dbo].[T_ReferenceType] ([ref_type], [ref_name], [ref_desc], [is_family], [max]) VALUES (N'FD', N'Friend', NULL, 0, 0)
INSERT [dbo].[T_ReferenceType] ([ref_type], [ref_name], [ref_desc], [is_family], [max]) VALUES (N'IL', N'In-law', NULL, 1, 0)
INSERT [dbo].[T_ReferenceType] ([ref_type], [ref_name], [ref_desc], [is_family], [max]) VALUES (N'NB', N'Neighbour', NULL, 0, 0)
INSERT [dbo].[T_ReferenceType] ([ref_type], [ref_name], [ref_desc], [is_family], [max]) VALUES (N'OT', N'Others', NULL, 0, 0)
INSERT [dbo].[T_ReferenceType] ([ref_type], [ref_name], [ref_desc], [is_family], [max]) VALUES (N'PR', N'Parent', NULL, 1, 0)
INSERT [dbo].[T_ReferenceType] ([ref_type], [ref_name], [ref_desc], [is_family], [max]) VALUES (N'RV', N'Relative', NULL, 1, 0)
INSERT [dbo].[T_ReferenceType] ([ref_type], [ref_name], [ref_desc], [is_family], [max]) VALUES (N'SB', N'Sibling', NULL, 1, 0)
INSERT [dbo].[T_ReferenceType] ([ref_type], [ref_name], [ref_desc], [is_family], [max]) VALUES (N'SP', N'Spouse', NULL, 1, 1)
INSERT [dbo].[T_ReferenceType] ([ref_type], [ref_name], [ref_desc], [is_family], [max]) VALUES (N'UK', N'Unknown', NULL, 0, 0)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6100, N'Bacolod City', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6101, N'Bago City', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6102, N'Pulupandan', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6103, N'Villadolid', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6104, N'San Enrique', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6105, N'Pontevedra', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6106, N'Hinigaran', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6107, N'Binalbagan', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6108, N'Himamaylan', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6109, N'Ilog', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6110, N'Candoni', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6111, N'Kabankalan', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6112, N'Kauayan', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6113, N'Sipalay', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6114, N'Hinoba-ari', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6115, N'Talisay', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6116, N'Silay City', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6117, N'Silay Hawaiian Central', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6118, N'Enrique Magalona', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6119, N'Victorias', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6120, N'Manapla', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6121, N'Cadiz City', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6122, N'Sagay', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6123, N'Paraiso (Fabrica)', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6124, N'Escalante', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6125, N'Toboso', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6126, N'Calatrava', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6127, N'San Carlos City', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6128, N'Isabela', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6129, N'Murcia', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6130, N'La Carlota City', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6131, N'La Castillana', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6132, N'Moises Padilla', 34, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6200, N'Dumaguete City', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6201, N'Sibulan', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6202, N'San Jose', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6203, N'Amian', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6204, N'Tanjay', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6205, N'Pamplona', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6206, N'Bais City', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6208, N'Mabinay', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6209, N'Bindoy', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6210, N'Ayungon', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6211, N'Tayasan', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6212, N'Jimalalud', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6213, N'La Libertad', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6214, N'Guihulngan', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6215, N'Valencia', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6216, N'Bacung', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6217, N'Dauin', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6218, N'Zamboanguita', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6219, N'Siaton', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6220, N'Sta. Catalina', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6221, N'Bayawan', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6222, N'Basay', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6223, N'Canlaon City', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (6224, N'Valle Hermoso', 35, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7000, N'Zamboanga City', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7001, N'Ipil', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7002, N'Reseller Lim', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7003, N'Titay', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7004, N'Naga', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7005, N'Kabasalan', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7006, N'Siay', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7007, N'Imelda', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7008, N'Payao', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7009, N'Buug', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7010, N'Mabuhay', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7011, N'Bayog', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7012, N'Talusan', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7013, N'Kumalarang', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7014, N'Lakewood', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7015, N'Dumalinao', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7016, N'Pagadian City', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7017, N'Labangan', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7018, N'Tungawan', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7019, N'Tukuran', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7020, N'Aurora', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7021, N'Midsalip', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7022, N'Don Mariano Marcos', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7023, N'Molave', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7024, N'Ramon Magsaysay', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7025, N'Tambulig', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7026, N'Mahayag', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7027, N'Josefina', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7028, N'Dumingag', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7029, N'San Miguel', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7030, N'Dinas', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7031, N'San Pablo', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7032, N'Dimataling', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7033, N'Pitogo', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7034, N'Tabina', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7035, N'Margo Sa Tubig', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7036, N'Vicencio Sagun', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7037, N'Lapuyan', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7038, N'Malangas', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7039, N'Diplahan', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7040, N'Alicia', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7041, N'Olutanga', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7042, N'Guipos', 62, 1)
GO
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7043, N'Tigbad', 62, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7100, N'Dipolog City', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7101, N'Dapitan City', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7102, N'Roxas', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7103, N'Sibutad', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7104, N'Rizal', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7105, N'Pinan', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7106, N'Polanco', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7107, N'Mutia', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7108, N'Gutalac', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7109, N'Katipunan', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7110, N'Manukan', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7111, N'Jose Dalman (Ponot)', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7113, N'Siayan', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7114, N'Salug', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7115, N'Liloy', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7116, N'Tampilisan', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7117, N'Labason', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7119, N'La Libertad', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7120, N'Siocon', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7121, N'Siraway', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7122, N'Sibuco', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7123, N'Baliguian', 65, 1)
INSERT [dbo].[T_Town] ([post_code], [town], [area_code], [is_active]) VALUES (7124, N'Kalawit', 65, 1)
ALTER TABLE [dbo].[BankWithdrawal] ADD  CONSTRAINT [DF_BankWithdrawal_wd_status_id]  DEFAULT ((0)) FOR [wd_status_id]
GO
ALTER TABLE [dbo].[RefInfo] ADD  CONSTRAINT [DF_RefInfo_ref_type]  DEFAULT ('UK') FOR [ref_type]
GO
ALTER TABLE [dbo].[RefInfo] ADD  CONSTRAINT [DF_RefInfo_is_dependent]  DEFAULT ((0)) FOR [is_dependent]
GO
ALTER TABLE [dbo].[RefInfo] ADD  CONSTRAINT [DF_RefInfo_is_student]  DEFAULT ((0)) FOR [is_student]
GO
ALTER TABLE [dbo].[ReLoan] ADD  CONSTRAINT [DF_ReLoan_is_restructured]  DEFAULT ((0)) FOR [is_restructured]
GO
ALTER TABLE [dbo].[AcctInfo]  WITH CHECK ADD  CONSTRAINT [FK_AcctInfo_Bank] FOREIGN KEY([bank_id])
REFERENCES [dbo].[Bank] ([bank_id])
GO
ALTER TABLE [dbo].[AcctInfo] CHECK CONSTRAINT [FK_AcctInfo_Bank]
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
ALTER TABLE [dbo].[BankWithdrawal]  WITH CHECK ADD  CONSTRAINT [FK_BankWithdrawal_BankWithdrawal] FOREIGN KEY([wd_id])
REFERENCES [dbo].[BankWithdrawal] ([wd_id])
GO
ALTER TABLE [dbo].[BankWithdrawal] CHECK CONSTRAINT [FK_BankWithdrawal_BankWithdrawal]
GO
ALTER TABLE [dbo].[Check]  WITH CHECK ADD  CONSTRAINT [FK_Check_Payment] FOREIGN KEY([payment_id])
REFERENCES [dbo].[Payment] ([payment_id])
GO
ALTER TABLE [dbo].[Check] CHECK CONSTRAINT [FK_Check_Payment]
GO
ALTER TABLE [dbo].[Check]  WITH CHECK ADD  CONSTRAINT [FK_Check_T_Bank] FOREIGN KEY([bank_code])
REFERENCES [dbo].[T_Bank] ([bank_code])
GO
ALTER TABLE [dbo].[Check] CHECK CONSTRAINT [FK_Check_T_Bank]
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
ALTER TABLE [dbo].[EntityGroup]  WITH CHECK ADD  CONSTRAINT [FK_EntityGroup_Group] FOREIGN KEY([grp_id])
REFERENCES [dbo].[Group] ([grp_id])
GO
ALTER TABLE [dbo].[EntityGroup] CHECK CONSTRAINT [FK_EntityGroup_Group]
GO
ALTER TABLE [dbo].[EntityGroup]  WITH CHECK ADD  CONSTRAINT [FK_EntityLoanClass_Entity] FOREIGN KEY([entity_id])
REFERENCES [dbo].[Entity] ([entity_id])
GO
ALTER TABLE [dbo].[EntityGroup] CHECK CONSTRAINT [FK_EntityLoanClass_Entity]
GO
ALTER TABLE [dbo].[ExpenseInfo]  WITH CHECK ADD  CONSTRAINT [FK_ExpenseInfo_Loan] FOREIGN KEY([loan_id])
REFERENCES [dbo].[Loan] ([loan_id])
GO
ALTER TABLE [dbo].[ExpenseInfo] CHECK CONSTRAINT [FK_ExpenseInfo_Loan]
GO
ALTER TABLE [dbo].[GroupAttribute]  WITH CHECK ADD  CONSTRAINT [FK_GroupAttribute_Group] FOREIGN KEY([grp_id])
REFERENCES [dbo].[Group] ([grp_id])
GO
ALTER TABLE [dbo].[GroupAttribute] CHECK CONSTRAINT [FK_GroupAttribute_Group]
GO
ALTER TABLE [dbo].[GroupAttribute]  WITH CHECK ADD  CONSTRAINT [FK_GroupAttribute_T_LoanType] FOREIGN KEY([loan_type])
REFERENCES [dbo].[T_LoanType] ([loan_type])
GO
ALTER TABLE [dbo].[GroupAttribute] CHECK CONSTRAINT [FK_GroupAttribute_T_LoanType]
GO
ALTER TABLE [dbo].[IdentityInfo]  WITH CHECK ADD  CONSTRAINT [FK_IdentityInfo_Entity] FOREIGN KEY([entity_id])
REFERENCES [dbo].[Entity] ([entity_id])
GO
ALTER TABLE [dbo].[IdentityInfo] CHECK CONSTRAINT [FK_IdentityInfo_Entity]
GO
ALTER TABLE [dbo].[Interest]  WITH CHECK ADD  CONSTRAINT [FK_Interest_Loan] FOREIGN KEY([loan_id])
REFERENCES [dbo].[Loan] ([loan_id])
GO
ALTER TABLE [dbo].[Interest] CHECK CONSTRAINT [FK_Interest_Loan]
GO
ALTER TABLE [dbo].[Loan]  WITH CHECK ADD  CONSTRAINT [FK_Loan_T_Purpose] FOREIGN KEY([purp_id])
REFERENCES [dbo].[T_Purpose] ([purp_id])
GO
ALTER TABLE [dbo].[Loan] CHECK CONSTRAINT [FK_Loan_T_Purpose]
GO
ALTER TABLE [dbo].[LoanAppv]  WITH CHECK ADD  CONSTRAINT [FK_LoanAppv_Loan] FOREIGN KEY([loan_id])
REFERENCES [dbo].[Loan] ([loan_id])
GO
ALTER TABLE [dbo].[LoanAppv] CHECK CONSTRAINT [FK_LoanAppv_Loan]
GO
ALTER TABLE [dbo].[LoanAss]  WITH CHECK ADD  CONSTRAINT [FK_LoanAss_Loan] FOREIGN KEY([loan_id])
REFERENCES [dbo].[Loan] ([loan_id])
GO
ALTER TABLE [dbo].[LoanAss] CHECK CONSTRAINT [FK_LoanAss_Loan]
GO
ALTER TABLE [dbo].[LoanAssFinInfo]  WITH CHECK ADD  CONSTRAINT [FK_LoanAssFinInfo_Competitor] FOREIGN KEY([comp_id])
REFERENCES [dbo].[Competitor] ([comp_id])
GO
ALTER TABLE [dbo].[LoanAssFinInfo] CHECK CONSTRAINT [FK_LoanAssFinInfo_Competitor]
GO
ALTER TABLE [dbo].[LoanAssFinInfo]  WITH CHECK ADD  CONSTRAINT [FK_LoanAssFinInfo_Loan] FOREIGN KEY([loan_id])
REFERENCES [dbo].[Loan] ([loan_id])
GO
ALTER TABLE [dbo].[LoanAssFinInfo] CHECK CONSTRAINT [FK_LoanAssFinInfo_Loan]
GO
ALTER TABLE [dbo].[LoanAssMonExp]  WITH CHECK ADD  CONSTRAINT [FK_LoanAssMonExp_Loan] FOREIGN KEY([loan_id])
REFERENCES [dbo].[Loan] ([loan_id])
GO
ALTER TABLE [dbo].[LoanAssMonExp] CHECK CONSTRAINT [FK_LoanAssMonExp_Loan]
GO
ALTER TABLE [dbo].[LoanAssMonExp]  WITH CHECK ADD  CONSTRAINT [FK_LoanAssMonExp_T_ExpenseType] FOREIGN KEY([exp_type])
REFERENCES [dbo].[T_ExpenseType] ([exp_type])
GO
ALTER TABLE [dbo].[LoanAssMonExp] CHECK CONSTRAINT [FK_LoanAssMonExp_T_ExpenseType]
GO
ALTER TABLE [dbo].[LoanCancel]  WITH CHECK ADD  CONSTRAINT [FK_LoanCancel_Loan] FOREIGN KEY([loan_id])
REFERENCES [dbo].[Loan] ([loan_id])
GO
ALTER TABLE [dbo].[LoanCancel] CHECK CONSTRAINT [FK_LoanCancel_Loan]
GO
ALTER TABLE [dbo].[LoanCancel]  WITH CHECK ADD  CONSTRAINT [FK_LoanCancel_T_LoanCancelReason] FOREIGN KEY([reason_id])
REFERENCES [dbo].[T_LoanCancelReason] ([reason_id])
GO
ALTER TABLE [dbo].[LoanCancel] CHECK CONSTRAINT [FK_LoanCancel_T_LoanCancelReason]
GO
ALTER TABLE [dbo].[LoanCharge]  WITH CHECK ADD  CONSTRAINT [FK_LoanCharge_Loan] FOREIGN KEY([loan_id])
REFERENCES [dbo].[Loan] ([loan_id])
GO
ALTER TABLE [dbo].[LoanCharge] CHECK CONSTRAINT [FK_LoanCharge_Loan]
GO
ALTER TABLE [dbo].[LoanCharge]  WITH CHECK ADD  CONSTRAINT [FK_LoanCharge_T_ChargeType1] FOREIGN KEY([charge_type])
REFERENCES [dbo].[T_ChargeType] ([charge_type])
GO
ALTER TABLE [dbo].[LoanCharge] CHECK CONSTRAINT [FK_LoanCharge_T_ChargeType1]
GO
ALTER TABLE [dbo].[LoanClassAdvance]  WITH CHECK ADD  CONSTRAINT [FK_LoanClassAdvance_LoanClass] FOREIGN KEY([class_id])
REFERENCES [dbo].[LoanClass] ([class_id])
GO
ALTER TABLE [dbo].[LoanClassAdvance] CHECK CONSTRAINT [FK_LoanClassAdvance_LoanClass]
GO
ALTER TABLE [dbo].[LoanClassCharge]  WITH CHECK ADD  CONSTRAINT [FK_LoanCharge_T_ChargeType] FOREIGN KEY([charge_type])
REFERENCES [dbo].[T_ChargeType] ([charge_type])
GO
ALTER TABLE [dbo].[LoanClassCharge] CHECK CONSTRAINT [FK_LoanCharge_T_ChargeType]
GO
ALTER TABLE [dbo].[LoanClassCharge]  WITH CHECK ADD  CONSTRAINT [FK_LoanClassCharge_LoanClass] FOREIGN KEY([class_id])
REFERENCES [dbo].[LoanClass] ([class_id])
GO
ALTER TABLE [dbo].[LoanClassCharge] CHECK CONSTRAINT [FK_LoanClassCharge_LoanClass]
GO
ALTER TABLE [dbo].[LoanClose]  WITH CHECK ADD  CONSTRAINT [FK_LoanClose_T_LoanCloseReason] FOREIGN KEY([reason_id])
REFERENCES [dbo].[T_LoanCloseReason] ([reason_id])
GO
ALTER TABLE [dbo].[LoanClose] CHECK CONSTRAINT [FK_LoanClose_T_LoanCloseReason]
GO
ALTER TABLE [dbo].[LoanComaker]  WITH CHECK ADD  CONSTRAINT [FK_LoanComaker_Loan] FOREIGN KEY([loan_id])
REFERENCES [dbo].[Loan] ([loan_id])
GO
ALTER TABLE [dbo].[LoanComaker] CHECK CONSTRAINT [FK_LoanComaker_Loan]
GO
ALTER TABLE [dbo].[LoanReject]  WITH CHECK ADD  CONSTRAINT [FK_LoanReject_Loan] FOREIGN KEY([loan_id])
REFERENCES [dbo].[Loan] ([loan_id])
GO
ALTER TABLE [dbo].[LoanReject] CHECK CONSTRAINT [FK_LoanReject_Loan]
GO
ALTER TABLE [dbo].[LoanReject]  WITH CHECK ADD  CONSTRAINT [FK_LoanReject_T_LoanRejectReason] FOREIGN KEY([reason_id])
REFERENCES [dbo].[T_LoanRejectReason] ([reason_id])
GO
ALTER TABLE [dbo].[LoanReject] CHECK CONSTRAINT [FK_LoanReject_T_LoanRejectReason]
GO
ALTER TABLE [dbo].[Payment]  WITH CHECK ADD  CONSTRAINT [FK_Payment_BankWithdrawal] FOREIGN KEY([wd_id])
REFERENCES [dbo].[BankWithdrawal] ([wd_id])
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [FK_Payment_BankWithdrawal]
GO
ALTER TABLE [dbo].[Payment]  WITH CHECK ADD  CONSTRAINT [FK_Payment_Entity] FOREIGN KEY([entity_id])
REFERENCES [dbo].[Entity] ([entity_id])
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [FK_Payment_Entity]
GO
ALTER TABLE [dbo].[Payment]  WITH CHECK ADD  CONSTRAINT [FK_Payment_T_PaymentMethod] FOREIGN KEY([pmt_method])
REFERENCES [dbo].[T_PaymentMethod] ([pmt_method])
GO
ALTER TABLE [dbo].[Payment] CHECK CONSTRAINT [FK_Payment_T_PaymentMethod]
GO
ALTER TABLE [dbo].[PaymentDetail]  WITH CHECK ADD  CONSTRAINT [FK_PaymentDetail_Loan] FOREIGN KEY([loan_id])
REFERENCES [dbo].[Loan] ([loan_id])
GO
ALTER TABLE [dbo].[PaymentDetail] CHECK CONSTRAINT [FK_PaymentDetail_Loan]
GO
ALTER TABLE [dbo].[PaymentDetail]  WITH CHECK ADD  CONSTRAINT [FK_PaymentDetail_Payment] FOREIGN KEY([payment_id])
REFERENCES [dbo].[Payment] ([payment_id])
GO
ALTER TABLE [dbo].[PaymentDetail] CHECK CONSTRAINT [FK_PaymentDetail_Payment]
GO
ALTER TABLE [dbo].[PersonalInfo]  WITH CHECK ADD  CONSTRAINT [FK_PersonalInfo_Client] FOREIGN KEY([entity_id])
REFERENCES [dbo].[Entity] ([entity_id])
GO
ALTER TABLE [dbo].[PersonalInfo] CHECK CONSTRAINT [FK_PersonalInfo_Client]
GO
ALTER TABLE [dbo].[PersonalInfo]  WITH CHECK ADD  CONSTRAINT [FK_PersonalInfo_T_InfoSource] FOREIGN KEY([source_id])
REFERENCES [dbo].[T_InfoSource] ([source_id])
GO
ALTER TABLE [dbo].[PersonalInfo] CHECK CONSTRAINT [FK_PersonalInfo_T_InfoSource]
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
ALTER TABLE [dbo].[T_LoanType]  WITH CHECK ADD  CONSTRAINT [FK_T_LoanType_T_AccountType] FOREIGN KEY([acct_type])
REFERENCES [dbo].[T_AccountType] ([acct_type])
GO
ALTER TABLE [dbo].[T_LoanType] CHECK CONSTRAINT [FK_T_LoanType_T_AccountType]
GO
ALTER TABLE [dbo].[T_Town]  WITH CHECK ADD  CONSTRAINT [FK_T_Town_T_Province] FOREIGN KEY([area_code])
REFERENCES [dbo].[T_Province] ([area_code])
GO
ALTER TABLE [dbo].[T_Town] CHECK CONSTRAINT [FK_T_Town_T_Province]
GO
/****** Object:  StoredProcedure [dbo].[sp_acc_post_ledger]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_acc_post_ledger]
AS
BEGIN
	select *
	  from Ledger L (nolock)
	 where L.event_object is null
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_acct_info]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_cl_get_acct_info]
	@entity_id char(10)
AS
BEGIN
	select A.*,
	       B.bank_code,
		   B.branch,
		   (T.bank_name + isnull(' - ' + B.branch,'')) bank_name,
		   dbo.udf_format_date(A.card_expiry) card_expiry_f,
		   (T.bank_code + isnull(' - ' + A.acct_no,'')) bank_details
	  from AcctInfo (nolock) A
 left join Bank (nolock) B
        on B.bank_id = A.bank_id
 left join T_Bank (nolock) T
        on T.bank_code = B.bank_code
	 where entity_id = @entity_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_address_info_pres]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_cl_get_address_info_prov]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_cl_get_contact_info]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_cl_get_empl_info]    Script Date: 20/02/2018 9:37:11 PM ******/
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
		   G.grp_name,
		   (P.lastname + ', ' + P.firstname) imm_head_name
	  from EmplInfo (nolock) I
 left join Employer (nolock) E
	    on E.emp_id = I.emp_id 
 left join PersonalInfo (nolock) P
	    on P.entity_id = I.imm_head
 left join [Group] (nolock) G
        on G.grp_id = E.grp_id
	 where I.entity_id = @entity_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_entity]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_cl_get_groups]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_cl_get_groups]
	@entity_id varchar(10)
AS
BEGIN
	declare @client_groups table
	(
		group_id char(8)
	)

	-- group where employer belongs
	insert @client_groups
	select grp_id
	  from EmplInfo E (nolock)
	  join Employer Y (nolock)
	    on Y.emp_id = E.emp_id
	 where E.entity_id = @entity_id

	-- other groups
	insert @client_groups
	select grp_id
	  from EntityGroup E (nolock)
	 where E.entity_id = @entity_id

	-- result
	select G.grp_id,
	       G.grp_name,
		   E.emp_id
	  from [Group] G (nolock)
      join @client_groups C
        on C.group_id = G.grp_id
 left join Employer E (nolock)
        on E.grp_id = G.grp_id
  order by grp_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_ident_info]    Script Date: 20/02/2018 9:37:11 PM ******/
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
		   isnull(I.exp_date,getdate()) expiry,
		   dbo.udf_format_date(exp_date) exp_date_f
	  from IdentityInfo (nolock) I
	  join T_IdentityType T (nolock)
	    on T.ident_type = I.ident_type
	 where entity_id = @entity_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_loan_class_access]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_cl_get_loan_class_access]
	@entity_id char(10)
AS
BEGIN
	declare @class_access table
	(
		class_id int
	)
	-- add class id from EntityLoanClass
	insert into @class_access
	select class_id
	  from EntityLoanClass E (nolock)
	 where E.entity_id = @entity_id

	-- add class id from LoanClass
	insert into @class_access
	select class_id
	  from LoanClass (nolock) C
	 where C.grp_id = (select M.grp_id 
	                     from EmplInfo E (nolock) 
						 join Employer M (nolock)
						   on M.emp_id = E.emp_id
						where E.entity_id = @entity_id)
	
	-- return
	select C.*,
	       dbo.udf_format_currency(C.int_rate) int_rate_f,
	       dbo.udf_format_currency(C.max_loan) max_loan_f,
	       G.grp_name,
	       -- T.loan_type_name,
		   M.display as comp_method
	  from LoanClass (nolock) C
	  -- join T_LoanType (nolock) T
	  --   on T.loan_type = C.loan_type
	  join dbo.fxn_get_int_comp_method () M
	    on M.value = C.int_comp_method
	  join [Group] (nolock) G
	    on G.grp_id = C.grp_id
	 where C.class_id in (select class_id from @class_access)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_loan_class_avail]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_cl_get_loan_class_avail]
	@entity_id char(10)
AS
BEGIN
	declare @class_access table
	(
		class_id int
	)
	-- add class id from EntityLoanClass
	insert into @class_access
	select class_id
	  from EntityLoanClass E (nolock)
	 where E.entity_id = @entity_id

	-- add class id from LoanClass
	insert into @class_access
	select class_id
	  from LoanClass (nolock) C
	 where C.grp_id = (select M.grp_id 
	                     from EmplInfo E (nolock) 
						 join Employer M (nolock)
						   on M.emp_id = E.emp_id
						where E.entity_id = @entity_id)
	
	-- return
	select C.*,
	       dbo.udf_format_currency(C.int_rate) int_rate_f,
	       dbo.udf_format_currency(C.max_loan) max_loan_f,
	       G.grp_name,
	       --T.loan_type_name,
		   M.display as comp_method
	  from LoanClass (nolock) C
	  --join T_LoanType (nolock) T
	  --  on T.loan_type = C.loan_type
	  join dbo.fxn_get_int_comp_method () M
	    on M.value = C.int_comp_method
	  join [Group] (nolock) G
	    on G.grp_id = C.grp_id
	 where C.class_id not in (select class_id from @class_access)

END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_loans]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_cl_get_loans]
	@entity_id char(10),
	@status char(1) = null
AS
BEGIN
	select L.*,
	       C.class_name,
		   dbo.udf_format_currency(C.int_rate) as class_int,
	       S.status_name,
		   M.display as appv_method_name,
		   dbo.udf_format_date(L.date_appl) date_appl_f,
		   dbo.udf_format_date(V.date_appv) date_appv_f,
		   dbo.udf_format_currency(L.amt_appl) amt_appl_f,
		   dbo.udf_format_currency(V.amt_appv) amt_appv_f,
		   dbo.udf_format_currency(L.balance) balance_f,
		   T.loan_type_name,
		   Y.acct_type_name,
		   C.int_comp_method,
		   C.is_scheduled,
		   coalesce(L.last_trans_date,V.date_appv) last_transaction_date,
		   C.int_rate,
		   R.rel_amt,
		   V.terms,
		   -- payments regular
		   (select count(1) 
		      from PaymentDetail D (nolock) 
			  join Payment P (nolock) 
			    on P.payment_id = D.payment_id 
			 where D.loan_id = L.loan_id
			   and isnull(P.is_advance,0) = 0) payments,
		   -- payments advance
		   (select count(1) 
		      from PaymentDetail D (nolock) 
			  join Payment P (nolock) 
			    on P.payment_id = D.payment_id 
			 where D.loan_id = L.loan_id
			   and isnull(P.is_advance,0) = 1) payments_advance
	  from Loan L (nolock)
	  join LoanClass C (nolock)
	    on C.class_id = L.class_id
	  join T_LoanStatus S (nolock)
	    on L.status_id = S.status_id
 left join LoanAppv V (nolock)
        on V.loan_id = L.loan_id
 left join LoanRelease R
        on R.loan_id = L.loan_id
 left join dbo.fxn_get_appv_method() M
	    on M.value = V.appv_method
	  join dbo.fxn_get_parent_group() P
	    on P.grp_id = C.grp_id
	  join GroupAttribute A (nolock)
	    on A.grp_id = P.top_grp_id
	  join T_LoanType T (nolock)
	    on T.loan_type = A.loan_type 
	  join T_AccountType Y (nolock)
	    on Y.acct_type = T.acct_type
	 where L.entity_id = @entity_id
	   and (isnull(@status,'') = '' or L.status_id = @status)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_loans_comakers]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_cl_get_loans_comakers]
	@entity_id char(10)
AS
BEGIN
	select C.*,
	       (P.lastname + ', ' + P.firstname) name
	  from LoanComaker C (nolock)
	  join PersonalInfo P (nolock)
	    on P.entity_id = C.entity_id
	 where exists (select 1
	                 from Loan L (nolock)
					where L.entity_id = @entity_id)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_personal_info]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_cl_get_ref_address_info]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[sp_cl_get_ref_address_info]
	@entity_id char(10)
AS
BEGIN
	select *
	  from AddressInfo A (nolock)
	 where A.entity_id 
	    in (select ref_entity_id
		      from RefInfo R (nolock)
			 where R.entity_id = @entity_id)
	   and isnull(A.is_prov,0) = 0
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_ref_contact_info]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

Create PROCEDURE [dbo].[sp_cl_get_ref_contact_info]
	@entity_id char(10)
AS
BEGIN
	select *
	  from ContactInfo C (nolock)
	 where C.entity_id 
	    in (select ref_entity_id
		      from RefInfo R (nolock)
			 where R.entity_id = @entity_id)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_ref_info]    Script Date: 20/02/2018 9:37:11 PM ******/
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
	 where R.entity_id = @entity_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_ref_personal_info]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_cl_get_ref_personal_info]
	@entity_id char(10)
AS
BEGIN
	select *
	  from PersonalInfo P (nolock)
	 where P.entity_id 
	    in (select ref_entity_id
		      from RefInfo R (nolock)
			 where R.entity_id = @entity_id)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_acct_type]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_acct_type]
AS
BEGIN
	select *
	  from T_AccountType T (nolock)
  order by acct_type_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_appv_method]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_appv_method]	
AS
BEGIN
	select * 
	  from dbo.fxn_get_appv_method()
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_banks]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_banks]
AS
BEGIN
	select bank_id,
	       (rtrim(bank_code) + ' - ' + branch) bank_name
	  from Bank B (nolock)
  order by bank_name

END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_cancel_reason]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_cancel_reason]
AS
BEGIN
	select R.reason_id,
	       R.reason_name
	  from T_LoanCancelReason R (nolock)
  order by R.reason_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_charge_type]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_charge_type]
AS
BEGIN
	select *
	  from T_ChargeType (nolock)
  order by charge_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_civil_status]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_close_reason]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_close_reason]
AS
BEGIN
	select R.reason_id,
	       R.reason_name
	  from T_LoanCloseReason R (nolock)
	 where isnull(is_auto_post,0) = 0
  order by R.reason_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_competitors]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_competitors]
AS
BEGIN
	select *
	  from Competitor C (nolock)
  order by comp_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_education_code]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[sp_dd_get_education_code]
AS
BEGIN
	declare @temp_educ_code table(
		value char(1),
		display varchar(12)
	)
	
	insert @temp_educ_code
	select 'E','Elementary'
	union
	select 'H','High School'
	union
	select 'C','College'
	union
	select 'O','Others'
	
	select * 
	  from @temp_educ_code
END


GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_employment_status]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_exp_type]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_exp_type]
AS
BEGIN
	select exp_type,
	       exp_name
	  from T_ExpenseType E (nolock)
  order by E.exp_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_gender]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_group]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_group]
AS
BEGIN
	select grp_id,
	       grp_name,
		   loc_code,
		   par_grp_id,
		   is_active
	  from [Group] G (nolock)
  order by grp_name

END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_ident_type]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_info_sources]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_info_sources]
AS
BEGIN
	select *
	  from T_InfoSource (nolock)
  order by source_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_int_comp_method]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_int_comp_method]
AS
BEGIN
	select *
	  from dbo.fxn_get_int_comp_method()
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_loan_class]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_loan_class]
	@entity_id char(10),
	@new_loan smallint
AS
BEGIN
    declare @dt datetime 
	declare @class_access table
	(
		class_id int
	)
	
	set @dt = getdate()

	-- add class id from EntityLoanClass
	if isnull(@new_loan,1) = 1
	begin
		/*insert into @class_access
		select E.class_id
		  from EntityLoanClass E (nolock)
		  join LoanClass C (nolock)
		    on C.class_id = E.class_id
		 where E.entity_id = @entity_id
		   and (
			   ((C.valid_until is null) and (@dt >= C.valid_from))
			or ((C.valid_until is not null) and (@dt between C.valid_from and C.valid_until))
			   )*/

		insert into @class_access
		select C.class_id
		  from EntityGroup E (nolock)
		  join LoanClass C (nolock)
		    on C.grp_id = E.grp_id
		 where E.entity_id = @entity_id
		   and (
			   ((C.valid_until is null) and (@dt >= C.valid_from))
			or ((C.valid_until is not null) and (@dt between C.valid_from and C.valid_until))
			   )

		-- add class id from LoanClass
		insert into @class_access
		select class_id
		  from LoanClass (nolock) C
		 where C.grp_id = (select M.grp_id 
							 from EmplInfo E (nolock) 
							 join Employer M (nolock)
							   on M.emp_id = E.emp_id
							where E.entity_id = @entity_id)
		  and (
			  ((C.valid_until is null) and (@dt >= C.valid_from))
		   or ((C.valid_until is not null) and (@dt between C.valid_from and C.valid_until))
			  )
	end
	else
	begin
		insert into @class_access
		select class_id
		  from LoanClass (nolock) C
	end

	-- return
	select L.*,
	       T.loan_type_name,
	       (L.class_name + ' - ' + case L.int_comp_method when 'F' then 'Fixed' else 'Diminishing' end + case L.is_scheduled when 1 then ' **' else '' end) class_name_method,
		   T.max_concurrent,
		   T.max_tot_amt max_loantype_amount,
		   T.ident_docs,
	       (case when isnull(L.comakers_max,0) = 0 and isnull(L.comakers_min,0) = 0 then 'No comakers required' 
			else case when L.comakers_min = L.comakers_max then cast(L.comakers_min as varchar) + ' required'
				 else cast(L.comakers_min as varchar) + ' - ' + cast(L.comakers_max as varchar) + ' required' 
				 end
			end) comakers_desc,
		   G.grp_name,
		   A.max_tot_amt max_group_amount,
		   A.loan_type,
		   A.concurrent
	  from LoanClass L (nolock)
	  join dbo.fxn_get_parent_group() G 
	    on G.grp_id = L.grp_id
	  join GroupAttribute A (nolock)
	    on A.grp_id = G.top_grp_id
	  join T_LoanType T (nolock)
	    on T.loan_type = A.loan_type
     where L.class_id in (select * from @class_access)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_loan_status]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_loan_status]
	@status_id char(1) = ''
AS
BEGIN
	declare @loan_status table
	(
		status_id char(1),
		status_name varchar(30)
	)

	if isnull(@status_id,'') = ''
		insert into @loan_status select status_id, status_name from T_LoanStatus S (nolock) where status_id = 'P'
	else if isnull(@status_id,'') = 'P'
		insert into @loan_status select status_id, status_name from T_LoanStatus S (nolock) where status_id in ('P','A','C')
	else if isnull(@status_id,'') = 'A'
		insert into @loan_status select status_id, status_name from T_LoanStatus S (nolock) where status_id in ('A','R','C')
	else if isnull(@status_id,'') = 'R'
		insert into @loan_status select status_id, status_name from T_LoanStatus S (nolock) where status_id in ('R')
	select *
      from @loan_status
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_loan_type]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_loan_type]
AS
BEGIN
	select loan_type,
	       loan_type_name,
		   max_tot_amt,
		   max_concurrent
	  from T_LoanType (nolock)
  order by loan_type_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_payment_frequency]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_payment_frequency]
AS
BEGIN
	select *
	  from dbo.fxn_get_pay_freq()
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_payment_methods]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_dd_get_payment_methods]
AS
BEGIN
	select *,
	       dbo.udf_format_currency(pmt_charge) charge
	  from T_PaymentMethod (nolock)
  order by pmt_method_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_purpose]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_purpose]
AS
BEGIN
	select purp_id,
	       purpose
	  from T_Purpose (nolock)
  order by purpose

END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_recommendation]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_recommendation]
AS
BEGIN
	select *
	  from dbo.fxn_get_recommendation()
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_ref_type]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_reject_reason]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_reject_reason]
AS
BEGIN
	select R.reason_id,
	       R.reason_name
	  from T_LoanRejectReason R (nolock)
  order by R.reason_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_release_method]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_release_method]
AS
BEGIN
	select *
	  from dbo.fxn_get_release_method()
  order by display
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_residence_status]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_towns]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_towns]
AS
BEGIN
	select post_code,
	       (town + ', ' + province) town
	  from T_Town T (nolock)
	  join T_Province P (nolock)
	    on P.area_code = T.area_code 
  order by town 
END

GO
/****** Object:  StoredProcedure [dbo].[sp_gen_id]    Script Date: 20/02/2018 9:37:11 PM ******/
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
				 when @seq_object = 'BNK' then 101  -- bank
				 when @seq_object = 'DSG' then 101 -- designation
				 when @seq_object = 'LNC' then 1001 -- loan class
				 when @seq_object = 'LON' then 10000001 -- loan
				 when @seq_object = 'CMP' then 101 -- competitor
				 when @seq_object = 'PRP' then 101 -- purpose
				 when @seq_object = 'ACT' then 101 -- account type
				 when @seq_object = 'LNT' then 101 -- loan type
				 when @seq_object = 'LCR' then 201 -- loan cancellation reason
				 when @seq_object = 'LRR' then 201 -- loan rejection reason
				 when @seq_object = 'LSR' then 201 -- loan closure reason
				 when @seq_object = 'PAY' then 100000001 -- payment
				 when @seq_object = 'LDG' then 1 -- ledger
				 when @seq_object = 'ITS' then 100000001 -- interest
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
/****** Object:  StoredProcedure [dbo].[sp_get_acct_types]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_acct_types]
AS
BEGIN
	select *
	  from T_AccountType T (nolock)
  order by T.acct_type_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_bank_branches]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_get_banks]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_get_clients]    Script Date: 20/02/2018 9:37:11 PM ******/
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
	        @where varchar(500),
			@order varchar(100) = ' order by name'

	set @sql = 'select (case when E.entity_type = ''CL'' then E.entity_id when isnull(active_loans,0) > 0 then E.entity_id else ''*****'' end) display_id,
					   E.entity_id,
					   (P.lastname + '', '' + P.firstname + '' '' + substring(isnull(P.middlename,''''),1,1)) name,
					   P.lastname,
					   P.firstname,
					   P.middlename,
					   C.acct_no,
					   C.card_no
				  from Entity E (nolock)
				  join PersonalInfo P (nolock)
					on P.entity_id = E.entity_id 
			 left join AcctInfo C (nolock)
			        on C.entity_id = P.entity_id
			 left join #ActiveLoans A
			        on A.entity_id = E.entity_id'

	 -- get active loans
	 select count(*) active_loans,
	        entity_id
	   into #ActiveLoans
	   from Loan L (nolock)
	  where L.status_id = 'R'
   group by entity_id

	 -- where clause
	 select @where = (
						case when @filter_type = 0 then 
								  case when @non_clients = 0 then ' where E.entity_type = ''CL''' 
								  else '' end

						     when @filter_type = 1 then 
								  case when @non_clients = 0 then ' where isnull(active_loans,0) > 0' 
								  else ' where isnull(active_loans,0) >= 0'  end

							 when @filter_type = 2 then 
								  case when @non_clients = 0 then ' where cast(created_date as date) = cast(getdate() as date) and E.entity_type = ''CL'''
								  else ' where cast(created_date as date) = cast(getdate() as date)' end

							 else ''
						end

					 )

	set @sql = @sql + @where + @order
	
	execute(@sql)

	drop table #ActiveLoans

END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_comakers]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_comakers]
AS
BEGIN
	-- filter types
	-- 0 = all
	-- 1 = pending = P
	-- 2 = assessed = S
	-- 3 = approved = A
	-- 4 = active / released = R
	-- 5 = cancelled = C
	-- 6 = denied / rejected = J

	-- get current comakers
	select count(1) comakered_loans,
	       C.entity_id
	  into #Comakers
	  from Loan L (nolock)
	  join LoanComaker C (nolock)
	    on L.loan_id = C.loan_id
     where L.status_id in ('R','A','P','S')
  group by C.entity_id
	       
	select E.entity_id,
	       (P.lastname + ', ' + P.firstname + ' ' + substring(isnull(P.middlename,''),1,1)) name,
		   P.lastname,
		   P.firstname,
		   P.middlename,
		   isnull(C.comakered_loans,0) comakered_loans
	  from Entity E (nolock)
	  join PersonalInfo P (nolock)
	    on P.entity_id = E.entity_id
 left join #Comakers C (nolock)
        on C.entity_id = E.entity_id
  order by name

  drop table #Comakers
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_competitors]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_competitors]
AS
BEGIN
	select *
	  from Competitor C (nolock)
  order by comp_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_designations]    Script Date: 20/02/2018 9:37:11 PM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_get_duplicate_name]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_duplicate_name]
    @lastname varchar(50),
	@firstname varchar(50),
	@middlename varchar(50)
AS
BEGIN
	-- this procedure is developed to detect POTENTIAL duplicates
	-- returns a list of the potential duplicates
	declare @name varchar(100)

	set @name = @lastname + ', ' + @firstname

	-- get active loans
	 select count(*) active_loans,
	        entity_id
	   into #ActiveLoans
	   from Loan L (nolock)
	  where L.status_id = 'R'
   group by entity_id

	select (P.lastname + ', ' + P.firstname + isnull(' ' + P.middlename,'')) name,
	       (case when E.entity_type = 'CL' then E.entity_id when isnull(active_loans,0) > 0 then E.entity_id else '*****' end) display_id,
		   P.entity_id 
	  from PersonalInfo P (nolock)
	  join Entity E (nolock)
	    on E.entity_id = P.entity_id
 left join #ActiveLoans A
	    on A.entity_id = E.entity_id
	 where (soundex(@lastname) = soundex(P.lastname)
	   and (soundex(@firstname) = soundex(P.firstname))
	   and (soundex(@middlename) = soundex(P.middlename)))

	   --or (difference(@name,P.lastname + ', ' + P.firstname) in (3,4))
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_employers]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_employers]
AS
BEGIN
	select E.*,
	       G.grp_name
	  from Employer E (nolock)
	  join [Group] G (nolock)
	    on G.grp_id = E.grp_id
  order by E.emp_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_entities]    Script Date: 20/02/2018 9:37:11 PM ******/
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
     -- where isnull(@entity_type,'') = '' 
	 --   or E.entity_type = @entity_type
  order by name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_group_attributes]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_get_group_attributes]
AS
BEGIN
	select *
	  from GroupAttribute A (nolock)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_groups]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_groups]	
AS
BEGIN
	select *
	  from [Group] (nolock) G
  order by par_grp_id, grp_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_info_sources]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_info_sources]
AS
BEGIN
	select *
	  from T_InfoSource (nolock)
  order by source_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_loan_cancel_reasons]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_loan_cancel_reasons]
AS
BEGIN
	select *
	  from T_LoanCancelReason C (nolock)
  order by C.reason_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_loan_class]    Script Date: 20/02/2018 9:37:11 PM ******/
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
	select C.*,
	       dbo.udf_format_currency(C.int_rate) int_rate_f,
	       dbo.udf_format_currency(C.max_loan) max_loan_f,
	       G.grp_name,
		   A.loan_type,
	       T.loan_type_name,
		   T.max_concurrent,
		   T.max_tot_amt,
		   M.display as comp_method
	  from LoanClass (nolock) C
	  join dbo.fxn_get_int_comp_method () M
	    on M.value = C.int_comp_method
	  join [Group] (nolock) G
	    on G.grp_id = C.grp_id
 left join GroupAttribute A
	    on A.grp_id = G.grp_id
 left join T_LoanType (nolock) T
	    on T.loan_type = A.loan_type
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_loan_class_advance_payment]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_loan_class_advance_payment]
	@class_id int
AS
BEGIN
	select *
	  from LoanClassAdvance (nolock)
	 where class_id = @class_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_loan_class_charge_types]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
CREATE PROCEDURE [dbo].[sp_get_loan_class_charge_types]
AS
BEGIN
	select *
	  from T_ChargeType (nolock)
  order by charge_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_loan_class_charges]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_loan_class_charges]
	@class_id int
AS
BEGIN
	select C.*,
	       T.charge_name,
		   (dbo.udf_format_currency(C.charge_value) + (case when C.value_type = 1 then '%' else '' end)) charge_value_f,
		   (dbo.udf_format_currency(C.ratio_amt)) ratio_amt_f,
		   (dbo.udf_format_currency(C.max_value)) max_value_f,
		   (case when isnull(for_new,0) = 0 then 'No' else 'Yes' end) for_new_f,
		   (case when isnull(for_renew,0) = 0 then 'No' else 'Yes' end) for_renew_f,
		   (case when isnull(for_restructure,0) = 0 then 'No' else 'Yes' end) for_restructure_f,
		   (case when isnull(for_reloan,0) = 0 then 'No' else 'Yes' end) for_reloan_f
	  from LoanClassCharge C (nolock)
	  join T_ChargeType T (nolock)
	    on T.charge_type = C.charge_type
	 where C.class_id = @class_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_loan_clients]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_loan_clients]
AS
BEGIN
	declare @cd datetime

	set @cd = getdate()

	select P.entity_id,
	       (P.lastname + ', ' + P.firstname + ' ' + substring(isnull(P.middlename,''),1,1)) name,
		   Y.emp_id,
		   Y.emp_name,
		   Y.grp_id,
		   Y.emp_add,
		   G.grp_name,
		   (isnull(D.st + ' ','') + isnull(brgy,'')) client_addr,
		   (case when dateadd(year, datediff (year, P.birth_date, @cd), P.birth_date) > @cd
			then datediff (year, P.birth_date, @cd) - 1
			else datediff (year, P.birth_date, @cd)
			end) age,
			E.net_pay,
			(
				select count(*) 
				  from IdentityInfo I (nolock)
				 where I.entity_id = P.entity_id
				   and isnull(I.exp_date,getdate()) >= getdate()

			) valid_ident_docs
	  from PersonalInfo P (nolock)
 left join AddressInfo D (nolock)
        on D.entity_id = P.entity_id
	   and isnull(is_prov,0) = 0
 left join EmplInfo E (nolock)
        on E.entity_id = P.entity_id
 left join Employer Y (nolock)
        on E.emp_id = Y.emp_id
 left join [Group] G (nolock)
        on G.grp_id = Y.grp_id
  order by P.lastname, P.firstname
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_loan_close_reasons]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_loan_close_reasons]
AS
BEGIN
	select *
	  from T_LoanCloseReason C (nolock)
  order by C.reason_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_loan_reject_reasons]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_loan_reject_reasons]
AS
BEGIN
	select *
	  from T_LoanRejectReason R (nolock)
  order by R.reason_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_loan_types]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_loan_types]
AS
BEGIN
	select *,
	       A.acct_type_name
	  from T_LoanType T (nolock)
	  join T_AccountType A (nolock)
	    on A.acct_type = T.acct_type
  order by T.loan_type_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_loans]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_loans]
	@filter_type int = 0
AS
BEGIN
	-- filter types
	-- 0 = all
	-- 1 = pending = P
	-- 2 = assessed = S
	-- 3 = approved = A
	-- 4 = active / released = R
	-- 5 = cancelled = C
	-- 6 = denied / rejected = J
	-- 7 = closed = X

	declare @sql varchar(max),
	        @where varchar(500),
			@order varchar(100) = ' order by name'

	set @sql = 'declare @cd datetime

				set @cd = getdate()
	
				select L.*,
	                   dbo.udf_format_date(date_appl) date_appl_f,
					   dbo.udf_format_date(date_appv) date_appv_f,
	                   dbo.udf_format_currency(amt_appl) amt_appl_f,
					   dbo.udf_format_currency(amt_appv) amt_appv_f,
					   dbo.udf_format_currency(balance) balance_f,
					   (P.lastname + '', '' + P.firstname + '' '' + substring(isnull(P.middlename,''''),1,1)) name,
                       C.class_name,
					   Y.emp_id,
		               Y.emp_name,
		               Y.grp_id,
		               Y.emp_add,
		               (isnull(D.st + '' '','''') + isnull(brgy,'''')) client_addr,
					   (
							case when dateadd(year, datediff (year, P.birth_date, @cd), P.birth_date) > @cd
							then datediff (year, P.birth_date, @cd) - 1
							else datediff (year, P.birth_date, @cd)
							end
					   ) age,
					   E.net_pay,
					   (
							select count(*) 
							  from IdentityInfo I (nolock)
							 where I.entity_id = P.entity_id
							   and isnull(I.exp_date,getdate()) >= getdate()

					   ) valid_ident_docs
				  from Loan L (nolock)
				  join PersonalInfo P (nolock)
					on P.entity_id = L.entity_id 
			 left join AddressInfo D (nolock)
                    on D.entity_id = P.entity_id
				   and isnull(D.is_prov,0) = 0
             left join EmplInfo E (nolock)
                    on E.entity_id = P.entity_id
             left join Employer Y (nolock)
                    on E.emp_id = Y.emp_id
				  join LoanClass C (nolock)
				    on C.class_id = L.class_id 
			 left join LoanAppv A (nolock)
			        on A.loan_id = L.loan_id '

	 -- where clause
	 select @where = (
						case when @filter_type = 0 then '' 
						     when @filter_type = 1 then ' where L.status_id = ''P'''
							 when @filter_type = 2 then ' where L.status_id = ''S'''
							 when @filter_type = 3 then ' where L.status_id = ''A'''
							 when @filter_type = 4 then ' where L.status_id = ''R'''
							 when @filter_type = 5 then ' where L.status_id = ''C'''
							 when @filter_type = 6 then ' where L.status_id = ''J'''
							 when @filter_type = 7 then ' where L.status_id = ''X'''
							 else ''
						end

					 )

	set @sql = @sql + @where + @order
	
	execute(@sql)

END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_purpose]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_purpose]
AS
BEGIN
	select *
	  from T_Purpose (nolock)
  order by purpose
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_advance_payment]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_advance_payment]
	@loan_id char(13)
AS
BEGIN
	select D.payment_id,
	       D.payment_amt,
	       D.payment_type
	  from PaymentDetail D (nolock)
	  join Payment P (nolock)
	    on P.payment_id = D.payment_id
	 where D.loan_id = @loan_id
  order by D.payment_id, 
           D.payment_type

  -- !!! WARNING Don't tinker with the sorting
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_alerts]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_alerts]
	@entity_id char(10),
	@loan_id char(13) -- exclude from the select
AS
BEGIN
	declare @ids int,
			@expired_ids int,
			@pending_loans int,
			@approved_loans int,
			@active_loans int

	declare @alerts table
	(
		alert varchar(100)
	)

	-- pending = P
	-- assessed = S
	-- approved = A
	-- active / released = R
	-- cancelled = C
	-- denied / rejected = J

	-- get identity docs
	select @ids = count(*)
	  from IdentityInfo I (nolock)
	 where I.entity_id = @entity_id

	-- find expired identity docs
	select @expired_ids = count(*)
	  from IdentityInfo I (nolock)
	 where I.entity_id = @entity_id
	   and isnull(I.exp_date,getdate()) < getdate()

	-- find loans
    -- only include pending, approved and active
	select loan_id, status_id
	  into #Loan
	  from Loan (nolock)
	 where entity_id = @entity_id
	   and status_id in ('P','A','R')
	   and loan_id <> @loan_id

	select count(*) as total, status_id
	  into #LoanStatusTotal
	  from #Loan
  group by status_id

	-- identity docs
	if isnull(@ids,0) < 2 insert into @alerts select 'Applicant has not submitted the required number of identity documents.' as alert

	-- expired identity docs
	if isnull(@expired_ids,0) > 0 insert into @alerts select 'Applicant has expired identity documents.' as alert
	
	-- pending loans
	set @pending_loans = (select total from #LoanStatusTotal where status_id = 'P')
	if isnull(@pending_loans,0) > 0 insert into @alerts select 'Applicant has ' + cast(@pending_loans as varchar) + 
	case when @pending_loans = 1 then ' pending loan.' else ' pending loans.' end as alert

	-- approved loans
	set @approved_loans = (select total from #LoanStatusTotal where status_id = 'A')
	if isnull(@approved_loans,0) > 0 insert into @alerts select 'Applicant has ' + cast(@approved_loans as varchar) + 
	case when @approved_loans = 1 then ' approved loan.' else ' approved loans.' end as alert

	-- active/released loans
	set @active_loans = (select total from #LoanStatusTotal where status_id = 'R')
	if isnull(@active_loans,0) > 0 insert into @alerts select 'Applicant has ' + cast(@active_loans as varchar) + 
	case when @active_loans = 1 then ' active loan.' else ' active loans.' end as alert

	select *
	  from @alerts

	drop table #Loan
	drop table #LoanStatusTotal

END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_client_loans]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_client_loans]
	@entity_id char(10)
AS
BEGIN
	-- pending = P
	-- assessed = S
	-- approved = A
	-- active / released = R
	-- cancelled = C
	-- denied / rejected = J

	select loan_id,
		   class_id,
		   (case status_id 
				when 'P' then amt_appl -- set balance to amount applied when status is PENDING
				else balance
		   end) balance
	  from Loan L (nolock)
	 where L.entity_id = @entity_id
	   and L.status_id in ('P','S','A','R')
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_fin_info]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_fin_info]	
	@loan_id char(13)
AS
BEGIN
	select A.*,
	       C.comp_name,
		   dbo.udf_format_currency(A.mon_due) mon_due_f,
		   dbo.udf_format_currency(A.loan_bal) loan_bal_f   
	  from LoanAssFinInfo A (nolock)
	  join Competitor C (nolock)
	    on C.comp_id = A.comp_id
	 where A.loan_id = @loan_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_interests]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_interests]
	@loan_id char(15)
AS
BEGIN
	select *
	  from Interest (nolock)
	 where loan_id = @loan_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_ledger]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_ledger]
	@loan_id char(13),
	@as_of_date datetime
AS
BEGIN
	declare @Ledger table 
	(
		due datetime,
		document_no char(25),
		debit_amt_p decimal(10,2),
		credit_amt_p decimal(10,2),
		balance_p decimal(10,2),
		debit_amt_i decimal(10,2),
		credit_amt_i  decimal(10,2),
		balance_i decimal(10,2),
		sort_order smallint
	)

	declare @release_date datetime

	-- get release date
	select @release_date = date_rel 
	  from LoanRelease (nolock) 
	 where loan_id = @loan_id

	-- get everything related to the loan
	-- payment, interest, penalty, etc..

	-- principal
	select *
	  into #Principal
	  from Ledger (nolock)
	 where event_object = 'LON'
	   and pk_event_object = @loan_id
	   and case_type = 'PRC'
	   and value_date <= @as_of_date

	-- interest
	select *
	  into #Interest
	  from Interest (nolock)
	 where loan_id = @loan_id
	   and interest_status_id = 'T'
	   and interest_date <= @as_of_date
  order by interest_date

	-- all payments
	select P.payment_id,
	       P.payment_date,
		   P.pmt_method,
		   P.receipt_no,
	       D.payment_amt,
		   D.payment_type,
		   D.balance,
		   P.is_advance
	  into #Payment
	  from Payment P (nolock)
	  join PaymentDetail (nolock) D
	    on D.payment_id = P.payment_id
     where D.loan_id = @loan_id
       and isnull(D.is_cancelled,0) = 0
	   and P.payment_date <= @as_of_date

	-- ***** construct the return query
	-- release amount
	insert into @Ledger
	select date_rel,
	       @loan_id,
		   0,
		   0,
		   -- released amount // note: released amount is the net proceeds
		   rel_amt + 
		   isnull((select sum(charge_amt) from LoanCharge LC (nolock) where LC.loan_id = @loan_id),0) + 
		   isnull((select sum(payment_amt) from #Payment P where isnull(P.is_advance,0) = 1),0), 
		   -- released amount
		   0,
		   0,
		   0,
		   1 sort_order       
	  from LoanRelease (nolock)
	 where loan_id = @loan_id

	-- principal with or without corresponding interest, with or without payment.. do not include advance payment
	insert into @Ledger
	select P.value_date,
		   rtrim(coalesce(PP.receipt_no,PN.receipt_no)) + (case isnull(PP.pmt_method,PN.pmt_method) when 3 then '*' else '' end),
		   isnull(P.debit_amt,0),
		   isnull(PP.payment_amt,0),
		   isnull(PP.balance,0),
		   isnull(I.interest_amt,0),
		   isnull(PN.payment_amt,0),
		   isnull(PN.balance,0),
		   1 sort_order
	   from #Principal P
  left join #Interest I
         on I.interest_date = P.value_date
  left join #Payment PP
         on PP.payment_date = P.value_date
		and PP.payment_type = 'PRN' 
		-- and PP.is_advance = 0
  left join #Payment PN
         on PN.payment_date = I.interest_date
		and PN.payment_type = 'INT'
		-- and PN.is_advance = 0
	  where P.value_date > @release_date

	-- advance payment
	insert into @Ledger
	select PN.payment_date,
		   rtrim(coalesce(P.receipt_no,PN.receipt_no)),
		   P.payment_amt,
		   P.payment_amt,
		   P.balance,
		   PN.payment_amt,
		   PN.payment_amt,
		   0,
		   2 sort_order
	   from #Payment PN
  left join #Payment P
         on PN.payment_id = P.payment_id
		and P.payment_type = 'PRN'
	  where PN.payment_type = 'INT' 
	    and PN.payment_date = @release_date

	-- interest without principal, with or without payment
	insert into @Ledger
	select I.interest_date,
	       rtrim(PN.receipt_no)  + (case PN.pmt_method when 1 then '*' else '' end),
	       0,
		   isnull(PP.payment_amt,0),
		   isnull(PP.balance,0),
		   isnull(I.interest_amt,0),
		   isnull(PN.payment_amt,0),
		   isnull(PN.balance,0),
		   2
	  from #Interest I
 left join #Payment PN
         on PN.payment_date = I.interest_date
		and PN.payment_type = 'INT'
 left join #Payment PP
         on PP.payment_date = I.interest_date
		and PP.payment_type = 'PRN' 
	  where I.interest_date not in (select due from @Ledger)

	-- unscheduled payments
	-- can include payments for fixed accounts or diminishing scheduled
	-- these accounts are posted on the first day of each month
	insert into @Ledger
	select PP.payment_date,
	       rtrim(PP.receipt_no)  + (case PP.pmt_method when 1 then '*' else '' end),
	       0,
		   isnull(PP.payment_amt,0),
		   isnull(PP.balance,0),
		   0,
		   isnull(PN.payment_amt,0),
		   isnull(PN.balance,0),
		   2
	  from #Payment PP
 left join #Payment PN
         on PN.payment_id = PP.payment_id
		and PN.payment_type = 'INT' 
	  where PP.payment_date not in (select due from @Ledger)
	    and PP.payment_type = 'PRN'

	--  select * from #Principal
	--  select * from #Interest
	--  select * from #Payment

	-- result
	select *
	  from @Ledger
  order by due,
	       sort_order

	drop table #Interest
	drop table #Principal
	drop table #Payment

END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_loan]
	@loan_id char(13)
AS
BEGIN
	select *
	  from Loan (nolock) L
	 where L.loan_id = @loan_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan_appv]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_loan_appv]
	@loan_id char(13)
AS
BEGIN
	select A.*,
	       dbo.udf_format_currency(amt_appv) amt_appv_f,
		   dbo.udf_format_date(date_appv) date_appv_f,
	       M.display as method_name
	  from LoanAppv (nolock) A
	  join dbo.fxn_get_appv_method() M
	    on M.value = A.appv_method
	 where A.loan_id = @loan_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan_ass]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_loan_ass]
	@loan_id char(13)
AS
BEGIN
	select *,
	       dbo.udf_format_date(date_ass) date_ass_f,
		   dbo.udf_format_currency(rec_amt) rec_amt_f,
		   R.display recommendation
	  from LoanAss (nolock) A
	  join dbo.fxn_get_recommendation() R
	    on R.value = A.rec_code
	 where A.loan_id = @loan_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan_cancel]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_loan_cancel]
	@loan_id char(13)
AS
BEGIN
	select C.*,
	       dbo.udf_format_date(cancelled_date) cancelled_date_f,
	       R.reason_name
	  from LoanCancel (nolock) C
	  join T_LoanCancelReason R (nolock)
	    on R.reason_id = C.reason_id
	 where C.loan_id = @loan_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan_charges]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_loan_charges]
	@loan_id char(13)
AS
BEGIN
	select C.*,
	       charge_name,
	       dbo.udf_format_currency(charge_amt) charge_amt_f
	  from LoanCharge C (nolock)
	  join T_ChargeType T (nolock)
	    on T.charge_type = C.charge_type
	 where C.loan_id = @loan_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan_class_advance]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_loan_class_advance]
	@entity_id char(10)
AS
BEGIN
	declare @class_access table
	(
		class_id int
	)

	-- add class id from EntityLoanClass
	/*insert into @class_access
	select class_id
	  from EntityLoanClass E (nolock)
	 where E.entity_id = @entity_id*/

	-- add class id from LoanClass
	insert into @class_access
	select class_id
	  from LoanClass (nolock) C
	 where C.grp_id = (select M.grp_id 
	                     from EmplInfo E (nolock) 
						 join Employer M (nolock)
						   on M.emp_id = E.emp_id
						where E.entity_id = @entity_id)

	-- add class id from EntityGroup
	insert into @class_access
	select C.class_id
	  from EntityGroup E (nolock)
	  join LoanClass C (nolock)
		on C.grp_id = E.grp_id
	 where E.entity_id = @entity_id

	-- return
	select A.*
	  from LoanClassAdvance A (nolock)
	 where A.class_id in (select * from @class_access)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan_class_charges]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_loan_class_charges]
	@entity_id char(10)
AS
BEGIN
	declare @class_access table
	(
		class_id int
	)

	-- add class id from EntityLoanClass
	/*insert into @class_access
	select class_id
	  from EntityLoanClass E (nolock)
	 where E.entity_id = @entity_id*/

	-- add class id from LoanClass
	insert into @class_access
	select class_id
	  from LoanClass (nolock) C
	 where C.grp_id = (select M.grp_id 
	                     from EmplInfo E (nolock) 
						 join Employer M (nolock)
						   on M.emp_id = E.emp_id
						where E.entity_id = @entity_id)

	-- return
	select C.*,
	       T.charge_name
	  from LoanClassCharge C (nolock)
	  join T_ChargeType T (nolock)
	    on T.charge_type = C.charge_type
	 where C.class_id in (select * from @class_access)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan_close]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_loan_close]
	@loan_id char(13)
AS
BEGIN
	select C.*,
	       dbo.udf_format_date(date_closed) date_closed_f,
	       R.reason_name
	  from LoanClose (nolock) C
	  join T_LoanCloseReason R (nolock)
	    on R.reason_id = C.reason_id
	 where C.loan_id = @loan_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan_comakers]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_loan_comakers]
	@loan_id char(13)
AS
BEGIN
	select C.*,
	       (P.lastname + ', ' + P.firstname) name
	  from LoanComaker C (nolock)
	  join PersonalInfo P (nolock)
	    on P.entity_id = C.entity_id
	 where loan_id = @loan_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan_reject]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_loan_reject]
	@loan_id char(13)
AS
BEGIN
	select J.*,
	       dbo.udf_format_date(date_rejected) date_rejected_f,
	       R.reason_name
	  from LoanReject (nolock) J
	  join T_LoanRejectReason R (nolock)
	    on R.reason_id = J.reason_id
	 where J.loan_id = @loan_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan_release]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_loan_release]
	@loan_id char(13)
AS
BEGIN
	select R.*,
	       dbo.udf_format_currency(R.rel_amt) rel_amt_f,
		   dbo.udf_format_date(date_rel) date_rel_f,
	       M.display method_name,
		   (P.lastname + ', ' + P.firstname) as recipient_name
	  from LoanRelease (nolock) R
	  join dbo.fxn_get_release_method() M
	    on R.rel_method = M.value
	  join PersonalInfo P
	    on P.entity_id = R.recipient
	 where R.loan_id = @loan_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_mon_exp]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_mon_exp]
	@loan_id char(13)
AS
BEGIN
	select M.*,
	       E.exp_name,
		   dbo.udf_format_currency(M.monthly) monthly_f
	  from LoanAssMonExp M (nolock)
	  join T_ExpenseType E (nolock)
	    on E.exp_type = M.exp_type
	 where M.loan_id = @loan_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_payment_due]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_payment_due]
	@loan_id char(13)
AS
BEGIN
	declare @payments smallint

	-- loan detail
	select *
	  into #Loan
	  from Loan (nolock)

    -- get interest
	select I.*
	  into #Int
	  from Interest I (nolock)
	 where I.loan_id = @loan_id

	-- ** retrieve OPN ledger records
	-- this is for payment posting
	-- open principal
	select L.posting_id,
	       L.value_date,
		   L.post_date,
		   L.case_type,
		   L.debit_amt,
		   L.pk_event_object,
		   L.event_object,
		   L.status_code
	  into #Principal 
	  from Ledger (nolock) L
	 where L.event_object = 'LON'
	   and L.status_code = 'OPN'
	   and L.pk_event_object = @loan_id

	-- get interest posted in Ledger
	select L.posting_id,
	       L.value_date,
		   L.post_date,
		   L.case_type,
		   L.debit_amt,
		   L.pk_event_object,
		   L.event_object,
		   L.status_code
	  into #Interest 
	  from Ledger (nolock) L
	  join #Int I
	    on I.interest_id = L.pk_event_object
	 where L.event_object = 'ITR'
	   and L.status_code = 'OPN'

	-- retrieve all payments made to the OPN records
	-- retrieved for balance purposes
	select sum(credit_amt) amount_paid,
		   ref_posting_id
	  into #Payment
	  from Ledger (nolock) L
	 where L.event_object = 'PAY'
	   and L.status_code <> 'CNL'
	   and ((L.ref_posting_id in (select posting_id from #Principal P))
	        or (L.ref_posting_id in (select posting_id from #Interest P)))
  group by ref_posting_id

	-- return query
	select R.*, isnull(@payments,0) payments
	  from (
				select P.posting_id,
					   P.value_date,
					   P.post_date,
					   P.case_type,
					   (P.debit_amt - isnull(Y.amount_paid,0)) payment_due,
					   P.pk_event_object,
					   P.event_object,
					   P.status_code,
					   (case when isnull(Y.amount_paid,0) = 0 then 0 else 1 end) has_partial 
				  from #Principal P
			 left join #Payment Y
					on Y.ref_posting_id = P.posting_id

				union

				select I.posting_id,
					   I.value_date,
					   I.post_date,
					   I.case_type,
					   (I.debit_amt - isnull(P.amount_paid,0)) payment_due,
					   I.pk_event_object,
					   I.event_object,
					   I.status_code,
					   (case when isnull(P.amount_paid,0) = 0 then 0 else 1 end) has_partial 
				  from #Interest I
			 left join #Payment P
					on P.ref_posting_id = I.posting_id

				/*union

				-- unposted (pending) interest
				-- specifically for fixed or diminishing loans using factor rate

				select '' posting_id,
					   I.interest_date,
					   getdate() post_date,
					   'ITS',
					   I.interest_amt payment_due,
					   I.interest_id,
					   'ITR',
					   'OPN',
					   1 has_partial 
				  from #Int I
				  join #Loan L
				    on L.loan_id = I.loan_id
				  join LoanClass LC (nolock)
				    on LC.class_id = L.class_id
				 where I.interest_status_id = 'P'
				   and LC.int_comp_method = 'F'*/

			) R
	order by value_date

	drop table #Principal
	drop table #Interest
	drop table #Int
	drop table #Payment
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_payment_schedule]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_payment_schedule]
	@entity_id char(10)
AS
BEGIN
	-- get active loans
	select L.loan_id
	  into #Loans
	  from Loan L (nolock)
	 where L.entity_id = @entity_id
	   and L.status_id = 'R'

	-- get interests
	select interest_id
	  into #Interest
	  from Interest (nolock)
	 where loan_id in (select A.loan_id from #Loans A)

	-- retrieve OPN ledger records
	-- this is for payment posting
	 select L.posting_id,
			L.value_date,
			L.post_date,
			L.case_type,
			L.debit_amt,
			L.credit_amt,
			L.event_object,
			L.pk_event_object, 
			L.status_code
	   from Ledger (nolock) L
	  where ((L.event_object = 'LON'
		and L.pk_event_object in (select A.loan_id from #Loans A))
		 or (L.event_object = 'ITR'
		and L.pk_event_object in (select I.interest_id from #Interest I)))
		and L.status_code = 'OPN'
   order by L.value_date,
            L.post_date

	drop table #Loans
	drop table #Interest
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_scheduled_interest]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_ln_get_scheduled_interest]
	@date datetime,
	@loan_id char(13) = null
AS
BEGIN
	select I.*
	  from Interest I (nolock)
	 where interest_date <= @date
	   and interest_status_id = 'P' 
	   and (isnull(@loan_id,'') = '' or I.loan_id = @loan_id)

	/*select I.*
	  from Interest I (nolock)
	  join Loan L (nolock)
	    on L.loan_id = I.loan_id
	  join LoanClass C (nolock)
	    on C.class_id = L.class_id
	 where interest_date <= @date
	   and interest_status_id = 'P'
	   and L.status_id = 'R'
	   and (C.int_comp_method = 'D' and isnull(C.use_factor_rate,0) = 0)

	union

	-- fixed or diminishing accounts but using factor rate
	select I.*
	  from Interest I (nolock)
	  join Loan L (nolock)
	    on L.loan_id = I.loan_id
	  join LoanClass C (nolock)
	    on C.class_id = L.class_id
	 where year(interest_date) = year(@date)
	   and month(interest_date) = month(@date)
	   and interest_status_id = 'P'
	   and L.status_id = 'R'
	   and (C.int_comp_method = 'F' 
	    or (C.int_comp_method = 'D' and isnull(C.use_factor_rate,0) = 1))*/

END

GO
/****** Object:  StoredProcedure [dbo].[sp_pmt_get_interests]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_pmt_get_interests]
	@entity_id char(10)
AS
BEGIN
	select L.loan_id
	  into #Loans
	  from Loan L (nolock)
	 where L.entity_id = @entity_id
	   and L.status_id = 'R'

	select *
	  from Interest (nolock)
	 where loan_id in (select L.loan_id from #Loans L)

    drop table #Loans
END

GO
/****** Object:  StoredProcedure [dbo].[sp_pmt_get_loans]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_pmt_get_loans]
	@entity_id char(10)
AS
BEGIN
	select L.loan_id,
	       L.balance,
		   L.status_id,
		   L.last_trans_date
	  from Loan L (nolock)
	 where L.entity_id = @entity_id
	   and L.status_id = 'R'
END

GO
/****** Object:  StoredProcedure [dbo].[sp_pmt_get_payment]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
CREATE PROCEDURE [dbo].[sp_pmt_get_payment]
	@payment_id char(15)
AS
BEGIN
	select *
	  from Payment P (nolock)
	 where payment_id = @payment_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_pmt_get_payment_detail]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
CREATE PROCEDURE [dbo].[sp_pmt_get_payment_detail]
	@payment_id char(15)
AS
BEGIN
    select *
	  into #Ledger
	  from Ledger L (nolock)
	 where event_object = 'PAY'
	   and pk_event_object = @payment_id

	select D.*,
	       T.loan_type_name,
		   Y.acct_type_name,
		   L.Balance
	  from PaymentDetail D (nolock)
	  join Loan L (nolock)
	    on L.loan_id = D.loan_id
      join LoanClass C (nolock)
	    on C.class_id = L.class_id
	  join dbo.fxn_get_parent_group() P
	    on P.grp_id = C.grp_id
	  join GroupAttribute A (nolock)
	    on A.grp_id = P.top_grp_id
	  join T_LoanType T (nolock)
	    on T.loan_type = A.loan_type 
	  join T_AccountType Y (nolock)
	    on Y.acct_type = T.acct_type
	 where payment_id = @payment_id
  order by D.loan_id

  drop table #ledger
END

GO
/****** Object:  StoredProcedure [dbo].[sp_pmt_get_payments]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_pmt_get_payments]
	@from_date datetime,
	@until_date datetime
AS
BEGIN
	-- payment head
	select *
	  into #payment
	  from Payment P (nolock)
	 where P.payment_date between @from_date and @until_date

	-- payment detail
	select payment_id,
	       payment_amt
	  into #paymentdetail
	  from PaymentDetail D (nolock)
	 where D.payment_id in (select P.payment_id from #payment P)

	-- result
	select P.*,
	       (F.lastname + ', ' + F.firstname) name,
	       (

				select sum(payment_amt)
				  from #paymentdetail D
				 where D.payment_id = P.payment_id

		   ) total_amount
	  from #payment P
	  join PersonalInfo F (nolock)
	    on F.entity_id = P.entity_id

	drop table #payment
	drop table #paymentdetail
END

GO
/****** Object:  StoredProcedure [dbo].[sp_pmt_get_withdrawals]    Script Date: 20/02/2018 9:37:11 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_pmt_get_withdrawals]
AS
BEGIN
	select B.*,
	       P.entity_id,
	       (P.lastname + ', ' + P.firstname) client,
		   A.card_no,
		   dbo.udf_format_date(wd_date) wd_date_f,
	       dbo.udf_format_currency(wd_amt) wd_amt_f
	  from BankWithdrawal B (nolock)
	  join AcctInfo A (nolock)
	    on A.acct_no = B.acct_no
	  join PersonalInfo P (nolock)
	    on A.entity_id = P.entity_id
 left join Payment Y
        on Y.wd_id = B.wd_id
	 where isnull(Y.wd_id,'') = ''
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
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Source of interest posting. Either system-generated (SYS) or due to payment posting (PAY)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Interest', @level2type=N'COLUMN',@level2name=N'interest_src'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Posting status. P = Pending, T = Posted' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Interest', @level2type=N'COLUMN',@level2name=N'interest_status_id'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Original value date' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Ledger', @level2type=N'COLUMN',@level2name=N'value_date'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Amount applied.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Loan', @level2type=N'COLUMN',@level2name=N'amt_appl'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Desired term.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Loan', @level2type=N'COLUMN',@level2name=N'des_term'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Branch of origin. Where the application originated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Loan', @level2type=N'COLUMN',@level2name=N'orig_branch'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Recommendation code. Can either be ''0'' approve application or ''1'' reject application' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoanAss', @level2type=N'COLUMN',@level2name=N'rec_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Applicable to diminishing accounts only' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoanClass', @level2type=N'COLUMN',@level2name=N'is_scheduled'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Number of months to deduct. 0 means months to be determined upon release' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoanClassAdvance', @level2type=N'COLUMN',@level2name=N'int'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Number of months to deduct. 0 means months to be determined upon release' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'LoanClassAdvance', @level2type=N'COLUMN',@level2name=N'principal'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Education code.. i.e. Elementary, High School, College, Others' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefInfo', @level2type=N'COLUMN',@level2name=N'educ_code'
GO
USE [master]
GO
ALTER DATABASE [iFinance] SET  READ_WRITE 
GO
