USE [master]
GO
/****** Object:  Database [iFinance]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_cl_get_acct_info]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_cl_get_address_info_pres]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_cl_get_address_info_prov]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_cl_get_contact_info]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_cl_get_empl_info]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_cl_get_entity]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_cl_get_ident_info]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_cl_get_loan_class_access]    Script Date: 1/02/2017 12:15:57 AM ******/
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
	       T.loan_name,
		   M.display as comp_method,
		   A.acct_name
	  from LoanClass (nolock) C
	  join T_LoanType (nolock) T
	    on T.loan_type = C.loan_type
	  join dbo.fxn_get_int_comp_method () M
	    on M.value = C.int_comp_method
	  join [Group] (nolock) G
	    on G.grp_id = C.grp_id
	  join T_AccountType A (nolock)
	    on A.acct_type = C.acct_type
	 where C.class_id in (select class_id from @class_access)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_loan_class_avail]    Script Date: 1/02/2017 12:15:57 AM ******/
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
	       T.loan_name,
		   M.display as comp_method,
		   A.acct_name
	  from LoanClass (nolock) C
	  join T_LoanType (nolock) T
	    on T.loan_type = C.loan_type
	  join dbo.fxn_get_int_comp_method () M
	    on M.value = C.int_comp_method
	  join [Group] (nolock) G
	    on G.grp_id = C.grp_id
	  join T_AccountType A (nolock)
	    on A.acct_type = C.acct_type
	 where C.class_id not in (select class_id from @class_access)

END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_loans]    Script Date: 1/02/2017 12:15:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_cl_get_loans]
	@entity_id char(10)
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
		   dbo.udf_format_currency(V.amt_appv) amt_appv_f
	  from Loan L (nolock)
	  join LoanClass C (nolock)
	    on C.class_id = L.class_id
	  join T_LoanStatus S (nolock)
	    on L.status_id = S.status_id
 left join LoanAppv V (nolock)
        on V.loan_id = L.loan_id
 left join dbo.fxn_get_appv_method() M
	    on M.value = V.appv_method
	 where L.entity_id = @entity_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_cl_get_loans_comakers]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_cl_get_personal_info]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_cl_get_ref_address_info]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_cl_get_ref_contact_info]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_cl_get_ref_info]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_cl_get_ref_personal_info]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_acct_type]    Script Date: 1/02/2017 12:15:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_acct_type]
AS
BEGIN
	select acct_type,
	       acct_name
	  from T_AccountType T (nolock)
  order by acct_name
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_appv_method]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_cancel_reason]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_charge_type]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_civil_status]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_competitors]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_education_code]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_employment_status]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_exp_type]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_gender]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_group]    Script Date: 1/02/2017 12:15:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_group]
AS
BEGIN
	select grp_id,
	       grp_name
	  from [Group] G (nolock)
  order by grp_name

END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_ident_type]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_int_comp_method]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_loan_class]    Script Date: 1/02/2017 12:15:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_dd_get_loan_class]
	@entity_id char(10),
	@new_loan smallint
AS
BEGIN
	declare @class_access table
	(
		class_id int
	)
	
	-- add class id from EntityLoanClass
	if isnull(@new_loan,1) = 1
	begin
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
	end
	else
	begin
		insert into @class_access
		select class_id
		  from LoanClass (nolock) C
	end

	-- return
	select *,
	       (case when L.comakers = 0 then 'No comakers required' else cast(L.comakers as varchar) + ' required' end) comakers_desc
	  from LoanClass L (nolock)
     where L.class_id in (select * from @class_access)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_dd_get_loan_status]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_loan_type]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_payment_frequency]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_ref_type]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_reject_reason]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_release_method]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_residence_status]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_dd_get_towns]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_gen_id]    Script Date: 1/02/2017 12:15:57 AM ******/
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
				 when @seq_object = 'LNC' then 1001 -- loan class
				 when @seq_object = 'LON' then 10000001 -- loan
				 when @seq_object = 'CMP' then 101 -- competitor
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
/****** Object:  StoredProcedure [dbo].[sp_get_bank_branches]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_get_banks]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_get_clients]    Script Date: 1/02/2017 12:15:57 AM ******/
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
					   P.middlename
				  from Entity E (nolock)
				  join PersonalInfo P (nolock)
					on P.entity_id = E.entity_id 
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
								  case when @non_clients = 0 then ' where created_date = cast(getdate() as date) and E.entity_type = ''CL'''
								  else ' where created_date = cast(getdate() as date)' end

							 else ''
						end

					 )

	set @sql = @sql + @where + @order
	
	execute(@sql)

	drop table #ActiveLoans

END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_comakers]    Script Date: 1/02/2017 12:15:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_comakers]
AS
BEGIN
	-- get current comakers
	select count(1) comakered_loans,
	       C.entity_id
	  into #Comakers
	  from Loan L (nolock)
	  join LoanComaker C (nolock)
	    on L.loan_id = C.loan_id
     where L.status_id in ('R','A','P')
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
/****** Object:  StoredProcedure [dbo].[sp_get_competitors]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_get_designations]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_get_employers]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_get_entities]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_get_groups]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_get_loan_class]    Script Date: 1/02/2017 12:15:57 AM ******/
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
	       T.loan_name,
		   M.display as comp_method,
		   A.acct_name
	  from LoanClass (nolock) C
	  join T_LoanType (nolock) T
	    on T.loan_type = C.loan_type
	  join dbo.fxn_get_int_comp_method () M
	    on M.value = C.int_comp_method
	  join [Group] (nolock) G
	    on G.grp_id = C.grp_id
	  join T_AccountType A (nolock)
	    on A.acct_type = C.acct_type
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_loan_class_charges]    Script Date: 1/02/2017 12:15:57 AM ******/
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
		   (dbo.udf_format_currency(C.charge_value) + (case when C.value_type = 0 then '' else '%' end)) charge_value_f
	  from LoanClassCharge C (nolock)
	  join T_ChargeType T (nolock)
	    on T.charge_type = C.charge_type
	 where C.class_id = @class_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_loan_clients]    Script Date: 1/02/2017 12:15:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_get_loan_clients]
AS
BEGIN
	select P.entity_id,
	       (P.lastname + ', ' + P.firstname) name,
		   Y.emp_id,
		   Y.emp_name,
		   Y.grp_id,
		   Y.emp_add,
		   (isnull(D.st + ' ','') + isnull(brgy,'')) client_addr  
	  from PersonalInfo P (nolock)
 left join AddressInfo D (nolock)
        on D.entity_id = P.entity_id
	   and isnull(is_prov,0) = 0
 left join EmplInfo E (nolock)
        on E.entity_id = P.entity_id
 left join Employer Y (nolock)
        on E.emp_id = Y.emp_id
  order by P.lastname, P.firstname
END

GO
/****** Object:  StoredProcedure [dbo].[sp_get_loans]    Script Date: 1/02/2017 12:15:57 AM ******/
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
	-- 1 = pending
	-- 2 = assessed
	-- 3 = approved
	-- 4 = active / released
	-- 5 = cancelled
	-- 6 = denied / rejected

	declare @sql varchar(max),
	        @where varchar(500),
			@order varchar(100) = ' order by name'

	set @sql = 'select L.*,
	                   dbo.udf_format_date(date_appl) date_appl_f,
					   dbo.udf_format_date(date_appv) date_appv_f,
	                   dbo.udf_format_currency(amt_appl) amt_appl_f,
					   dbo.udf_format_currency(amt_appv) amt_appv_f,
					   (P.lastname + '', '' + P.firstname + '' '' + substring(isnull(P.middlename,''''),1,1)) name,
                       C.class_name,
					   Y.emp_id,
		               Y.emp_name,
		               Y.grp_id,
		               Y.emp_add,
		               (isnull(D.st + '' '','''') + isnull(brgy,'''')) client_addr
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
							 when @filter_type = 5 then ' where L.status_id in (''C'', ''X'')'
							 when @filter_type = 6 then ' where L.status_id = ''D'''
							 else ''
						end

					 )

	set @sql = @sql + @where + @order
	
	execute(@sql)

END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_alerts]    Script Date: 1/02/2017 12:15:57 AM ******/
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
	if isnull(@ids,0) < 2 insert into @alerts select 'Client has not submitted the required number of identity documents.' as alert

	-- expired identity docs
	if isnull(@expired_ids,0) > 0 insert into @alerts select 'Client has expired identity documents.' as alert
	
	-- pending loans
	set @pending_loans = (select total from #LoanStatusTotal where status_id = 'P')
	if isnull(@pending_loans,0) > 0 insert into @alerts select 'Client has ' + cast(@pending_loans as varchar) + 
	case when @pending_loans = 1 then ' pending loan.' else ' pending loans.' end as alert

	-- approved loans
	set @approved_loans = (select total from #LoanStatusTotal where status_id = 'A')
	if isnull(@approved_loans,0) > 0 insert into @alerts select 'Client has ' + cast(@approved_loans as varchar) + 
	case when @approved_loans = 1 then ' approved loan.' else ' approved loans.' end as alert

	-- active/released loans
	set @active_loans = (select total from #LoanStatusTotal where status_id = 'R')
	if isnull(@active_loans,0) > 0 insert into @alerts select 'Client has ' + cast(@active_loans as varchar) + 
	case when @active_loans = 1 then ' active loan.' else ' active loans.' end as alert

	select *
	  from @alerts

	drop table #Loan
	drop table #LoanStatusTotal

END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_fin_info]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan_appv]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan_ass]    Script Date: 1/02/2017 12:15:57 AM ******/
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
		   dbo.udf_format_currency(rec_amt) rec_amt_f
	  from LoanAss (nolock) A
	 where A.loan_id = @loan_id
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan_cancel]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan_charges]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan_class_charges]    Script Date: 1/02/2017 12:15:57 AM ******/
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
	       T.charge_name
	  from LoanClassCharge C (nolock)
	  join T_ChargeType T (nolock)
	    on T.charge_type = C.charge_type
	 where C.class_id in (select * from @class_access)
END

GO
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan_comakers]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan_reject]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_ln_get_loan_release]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  StoredProcedure [dbo].[sp_ln_get_mon_exp]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[fxn_get_appv_method]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[fxn_get_int_comp_method]    Script Date: 1/02/2017 12:15:57 AM ******/
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
	union
	select 'S','Diminishing - Scheduled'

	RETURN 
END

GO
/****** Object:  UserDefinedFunction [dbo].[fxn_get_pay_freq]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[fxn_get_release_method]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[udf_format_currency]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  UserDefinedFunction [dbo].[udf_format_date]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[AcctInfo]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[AddressInfo]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[Bank]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[Competitor]    Script Date: 1/02/2017 12:15:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Competitor](
	[comp_id] [smallint] NOT NULL,
	[comp_name] [varchar](30) NOT NULL,
 CONSTRAINT [PK_Competitor] PRIMARY KEY CLUSTERED 
(
	[comp_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ContactInfo]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[EmplInfo]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[Employer]    Script Date: 1/02/2017 12:15:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[Employer](
	[emp_id] [char](8) NOT NULL,
	[emp_name] [varchar](50) NOT NULL,
	[grp_id] [smallint] NOT NULL,
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
/****** Object:  Table [dbo].[Entity]    Script Date: 1/02/2017 12:15:57 AM ******/
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
	[created_date] [datetime] NULL,
	[created_by] [varchar](12) NULL,
 CONSTRAINT [PK_Entity] PRIMARY KEY CLUSTERED 
(
	[entity_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[EntityLoanClass]    Script Date: 1/02/2017 12:15:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[EntityLoanClass](
	[entity_id] [char](10) NOT NULL,
	[class_id] [int] NOT NULL,
 CONSTRAINT [PK_EntityLoanClass] PRIMARY KEY CLUSTERED 
(
	[entity_id] ASC,
	[class_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[ExpenseInfo]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[Group]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[IdentityInfo]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[Loan]    Script Date: 1/02/2017 12:15:57 AM ******/
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
	[purpose] [varchar](20) NULL,
	[entity_id] [char](10) NOT NULL,
	[orig_branch] [char](3) NOT NULL,
	[status_id] [char](1) NOT NULL,
	[created_date] [datetime] NOT NULL,
	[created_by] [varchar](12) NOT NULL,
 CONSTRAINT [PK_Loan] PRIMARY KEY CLUSTERED 
(
	[loan_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoanAppv]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[LoanAss]    Script Date: 1/02/2017 12:15:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoanAss](
	[loan_id] [char](13) NOT NULL,
	[rec_amt] [decimal](10, 2) NOT NULL,
	[date_ass] [datetime] NOT NULL,
	[ass_by] [varchar](12) NOT NULL,
	[remarks] [varchar](100) NULL,
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
/****** Object:  Table [dbo].[LoanAssFinInfo]    Script Date: 1/02/2017 12:15:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoanAssFinInfo](
	[loan_id] [char](13) NOT NULL,
	[comp_id] [smallint] NOT NULL,
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
/****** Object:  Table [dbo].[LoanAssMonExp]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[LoanCancel]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[LoanCharge]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[LoanClass]    Script Date: 1/02/2017 12:15:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoanClass](
	[class_id] [int] NOT NULL,
	[grp_id] [smallint] NOT NULL,
	[class_name] [varchar](25) NULL,
	[int_rate] [float] NOT NULL,
	[term] [tinyint] NULL,
	[loan_type] [char](2) NOT NULL,
	[acct_type] [char](1) NOT NULL,
	[comakers] [tinyint] NULL,
	[int_comp_method] [char](1) NOT NULL,
	[max_loan] [decimal](10, 2) NULL,
	[valid_from] [datetime] NULL,
	[valid_until] [datetime] NULL,
	[loc_code] [char](3) NULL,
	[pay_freq] [char](1) NOT NULL,
	[max_concurrent] [tinyint] NOT NULL,
 CONSTRAINT [PK_LoanClass] PRIMARY KEY CLUSTERED 
(
	[class_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoanClassCharge]    Script Date: 1/02/2017 12:15:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[LoanClassCharge](
	[class_id] [int] NOT NULL,
	[charge_type] [char](2) NOT NULL,
	[charge_value] [decimal](10, 2) NOT NULL,
	[value_type] [tinyint] NOT NULL,
 CONSTRAINT [PK_LoanClassCharge] PRIMARY KEY CLUSTERED 
(
	[class_id] ASC,
	[charge_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[LoanComaker]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[LoanReject]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[LoanRelease]    Script Date: 1/02/2017 12:15:57 AM ******/
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
 CONSTRAINT [PK_LoanRecipient] PRIMARY KEY CLUSTERED 
(
	[loan_id] ASC,
	[recipient] ASC,
	[rel_method] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[Locked]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[PersonalInfo]    Script Date: 1/02/2017 12:15:57 AM ******/
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
 CONSTRAINT [PK_PersonalInfo] PRIMARY KEY CLUSTERED 
(
	[entity_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[RefInfo]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[Sequence]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[SysDef]    Script Date: 1/02/2017 12:15:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[SysDef](
	[def_type] [char](3) NOT NULL,
	[def_code] [char](3) NOT NULL,
	[def_name] [varchar](25) NOT NULL,
	[def_description] [varchar](100) NULL,
	[is_active] [tinyint] NOT NULL,
 CONSTRAINT [PK_SysDef] PRIMARY KEY CLUSTERED 
(
	[def_type] ASC,
	[def_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_AccountType]    Script Date: 1/02/2017 12:15:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_AccountType](
	[acct_type] [char](1) NOT NULL,
	[acct_name] [varchar](25) NULL,
	[acct_desc] [varchar](100) NULL,
	[par_acct_type] [char](3) NULL,
 CONSTRAINT [PK_T_AccountType] PRIMARY KEY CLUSTERED 
(
	[acct_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_Bank]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[T_ChargeType]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[T_Designation]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[T_EntityType]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[T_ExpenseType]    Script Date: 1/02/2017 12:15:57 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[T_ExpenseType](
	[exp_type] [char](2) NOT NULL,
	[exp_name] [varchar](25) NOT NULL,
	[exp_desc] [varchar](100) NULL,
 CONSTRAINT [PK_T_Expense] PRIMARY KEY CLUSTERED 
(
	[exp_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_IdentityType]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[T_LoanCancelReason]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[T_LoanRejectReason]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[T_LoanStatus]    Script Date: 1/02/2017 12:15:57 AM ******/
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
	[is_active] [tinyint] NOT NULL,
 CONSTRAINT [PK_T_LoanStatus] PRIMARY KEY CLUSTERED 
(
	[status_id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
/****** Object:  Table [dbo].[T_LoanType]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[T_Province]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[T_ReferenceType]    Script Date: 1/02/2017 12:15:57 AM ******/
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
/****** Object:  Table [dbo].[T_Town]    Script Date: 1/02/2017 12:15:57 AM ******/
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
	[is_active] [tinyint] NOT NULL,
 CONSTRAINT [PK_T_Town] PRIMARY KEY CLUSTERED 
(
	[post_code] ASC
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
ALTER TABLE [dbo].[Loan] ADD  CONSTRAINT [DF_Loan_status_id]  DEFAULT ('P') FOR [status_id]
GO
ALTER TABLE [dbo].[LoanClass] ADD  CONSTRAINT [DF_LoanClass_comakers]  DEFAULT ((0)) FOR [comakers]
GO
ALTER TABLE [dbo].[LoanClass] ADD  CONSTRAINT [DF_LoanClass_pay_freq]  DEFAULT ('F') FOR [pay_freq]
GO
ALTER TABLE [dbo].[LoanClass] ADD  CONSTRAINT [DF_LoanClass_max_concurrent]  DEFAULT ((0)) FOR [max_concurrent]
GO
ALTER TABLE [dbo].[RefInfo] ADD  CONSTRAINT [DF_RefInfo_ref_type]  DEFAULT ('UK') FOR [ref_type]
GO
ALTER TABLE [dbo].[RefInfo] ADD  CONSTRAINT [DF_RefInfo_is_dependent]  DEFAULT ((0)) FOR [is_dependent]
GO
ALTER TABLE [dbo].[RefInfo] ADD  CONSTRAINT [DF_RefInfo_is_student]  DEFAULT ((0)) FOR [is_student]
GO
ALTER TABLE [dbo].[SysDef] ADD  CONSTRAINT [DF_SysDef_is_active]  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[T_EntityType] ADD  CONSTRAINT [DF_T_Entity_is_valid]  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[T_EntityType] ADD  CONSTRAINT [DF_T_EntityType_is_client]  DEFAULT ((1)) FOR [is_client]
GO
ALTER TABLE [dbo].[T_EntityType] ADD  CONSTRAINT [DF_T_EntityType_is_individual]  DEFAULT ((1)) FOR [is_person]
GO
ALTER TABLE [dbo].[T_IdentityType] ADD  CONSTRAINT [DF_T_IdentityType_has_expiry]  DEFAULT ((0)) FOR [has_expiry]
GO
ALTER TABLE [dbo].[T_LoanStatus] ADD  CONSTRAINT [DF_T_LoanStatus_is_active]  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[T_LoanType] ADD  CONSTRAINT [DF_T_LoanType_is_active]  DEFAULT ((1)) FOR [is_active]
GO
ALTER TABLE [dbo].[T_LoanType] ADD  CONSTRAINT [DF_T_LoanType_co_makers]  DEFAULT ((0)) FOR [co_makers]
GO
ALTER TABLE [dbo].[T_ReferenceType] ADD  CONSTRAINT [DF_T_ReferenceType_is_family]  DEFAULT ((0)) FOR [is_family]
GO
ALTER TABLE [dbo].[T_ReferenceType] ADD  CONSTRAINT [DF_T_ReferenceType_max]  DEFAULT ((0)) FOR [max]
GO
ALTER TABLE [dbo].[T_Town] ADD  CONSTRAINT [DF_T_Town_is_active]  DEFAULT ((1)) FOR [is_active]
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
ALTER TABLE [dbo].[EntityLoanClass]  WITH CHECK ADD  CONSTRAINT [FK_EntityLoanClass_Entity] FOREIGN KEY([entity_id])
REFERENCES [dbo].[Entity] ([entity_id])
GO
ALTER TABLE [dbo].[EntityLoanClass] CHECK CONSTRAINT [FK_EntityLoanClass_Entity]
GO
ALTER TABLE [dbo].[EntityLoanClass]  WITH CHECK ADD  CONSTRAINT [FK_EntityLoanClass_LoanClass] FOREIGN KEY([class_id])
REFERENCES [dbo].[LoanClass] ([class_id])
GO
ALTER TABLE [dbo].[EntityLoanClass] CHECK CONSTRAINT [FK_EntityLoanClass_LoanClass]
GO
ALTER TABLE [dbo].[ExpenseInfo]  WITH CHECK ADD  CONSTRAINT [FK_ExpenseInfo_Loan] FOREIGN KEY([loan_id])
REFERENCES [dbo].[Loan] ([loan_id])
GO
ALTER TABLE [dbo].[ExpenseInfo] CHECK CONSTRAINT [FK_ExpenseInfo_Loan]
GO
ALTER TABLE [dbo].[IdentityInfo]  WITH CHECK ADD  CONSTRAINT [FK_IdentityInfo_Entity] FOREIGN KEY([entity_id])
REFERENCES [dbo].[Entity] ([entity_id])
GO
ALTER TABLE [dbo].[IdentityInfo] CHECK CONSTRAINT [FK_IdentityInfo_Entity]
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
ALTER TABLE [dbo].[LoanClass]  WITH CHECK ADD  CONSTRAINT [FK_LoanClass_T_LoanType] FOREIGN KEY([loan_type])
REFERENCES [dbo].[T_LoanType] ([loan_type])
GO
ALTER TABLE [dbo].[LoanClass] CHECK CONSTRAINT [FK_LoanClass_T_LoanType]
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
ALTER TABLE [dbo].[T_Town]  WITH CHECK ADD  CONSTRAINT [FK_T_Town_T_Province] FOREIGN KEY([area_code])
REFERENCES [dbo].[T_Province] ([area_code])
GO
ALTER TABLE [dbo].[T_Town] CHECK CONSTRAINT [FK_T_Town_T_Province]
GO
/****** Object:  Trigger [dbo].[tr_set_expiry]    Script Date: 1/02/2017 12:15:57 AM ******/
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
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Branch of origin. Where the application originated.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Loan', @level2type=N'COLUMN',@level2name=N'orig_branch'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Education code.. i.e. Elementary, High School, College, Others' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RefInfo', @level2type=N'COLUMN',@level2name=N'educ_code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Number of co-makers required.' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'T_LoanType', @level2type=N'COLUMN',@level2name=N'co_makers'
GO
USE [master]
GO
ALTER DATABASE [iFinance] SET  READ_WRITE 
GO
