-- Create version tracking table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[DBVersion]') AND type in (N'U'))
BEGIN
    CREATE TABLE DBVersion (
        VersionID INT IDENTITY(1,1) PRIMARY KEY,
        VersionNumber DECIMAL(10,2) NOT NULL,
        AppliedDate DATETIME DEFAULT GETDATE(),
        Description NVARCHAR(500)
    )
END
GO

-- Suppress row count messages
SET NOCOUNT ON
GO

-- ============================================================
-- Script: Change Num_Serial from BIGINT to DECIMAL(21,0)
-- Table: Tss_InvEntrance_Dt
-- Description: Only alters the column if it's currently BIGINT
-- ============================================================

IF EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'dbo' 
        AND TABLE_NAME = 'Tss_InvEntrance_Dt' 
        AND COLUMN_NAME = 'Num_Serial'
        AND DATA_TYPE = 'bigint'
)
BEGIN
    -- Check if the column has a default constraint and drop it if exists
    DECLARE @DefaultConstraintName NVARCHAR(128)
    
    SELECT @DefaultConstraintName = dc.name
    FROM sys.default_constraints dc
    INNER JOIN sys.columns c ON dc.parent_column_id = c.column_id
    INNER JOIN sys.objects o ON dc.parent_object_id = o.object_id
    WHERE o.name = 'Tss_InvEntrance_Dt' AND c.name = 'Num_Serial'
    
    IF @DefaultConstraintName IS NOT NULL
    BEGIN
        DECLARE @DropConstraintSQL NVARCHAR(MAX)
        SET @DropConstraintSQL = 'ALTER TABLE dbo.Tss_InvEntrance_Dt DROP CONSTRAINT ' + QUOTENAME(@DefaultConstraintName)
        EXEC sp_executesql @DropConstraintSQL
    END
    
    -- Change column from BIGINT to DECIMAL(21,0)
    ALTER TABLE dbo.Tss_InvEntrance_Dt 
    ALTER COLUMN Num_Serial DECIMAL(21,0) NULL
END
ELSE IF EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'dbo' 
        AND TABLE_NAME = 'Tss_InvEntrance_Dt' 
        AND COLUMN_NAME = 'Num_Serial'
        AND DATA_TYPE = 'decimal'
        AND NUMERIC_PRECISION = 21
        AND NUMERIC_SCALE = 0
)
BEGIN
    PRINT 'Num_Serial is already DECIMAL(21,0). No action needed.'
END
ELSE
BEGIN
    PRINT 'Num_Serial is either not BIGINT or column does not exist.'
END

GO

-- ============================================================
-- Script: Change Num_Serial from BIGINT to DECIMAL(21,0)
-- Table: Tss_InvOutGo_Dt
-- Description: Only alters the column if it's currently BIGINT
-- ============================================================

IF EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'dbo' 
        AND TABLE_NAME = 'Tss_InvOutGo_Dt' 
        AND COLUMN_NAME = 'Num_Serial'
        AND DATA_TYPE = 'bigint'
)
BEGIN
    -- Check if the column has a default constraint and drop it if exists
    DECLARE @DefaultConstraintName NVARCHAR(128)
    
    SELECT @DefaultConstraintName = dc.name
    FROM sys.default_constraints dc
    INNER JOIN sys.columns c ON dc.parent_column_id = c.column_id
    INNER JOIN sys.objects o ON dc.parent_object_id = o.object_id
    WHERE o.name = 'Tss_InvOutGo_Dt' AND c.name = 'Num_Serial'
    
    IF @DefaultConstraintName IS NOT NULL
    BEGIN
        DECLARE @DropConstraintSQL NVARCHAR(MAX)
        SET @DropConstraintSQL = 'ALTER TABLE dbo.Tss_InvOutGo_Dt DROP CONSTRAINT ' + QUOTENAME(@DefaultConstraintName)
        EXEC sp_executesql @DropConstraintSQL
    END
    
    -- Change column from BIGINT to DECIMAL(21,0)
    ALTER TABLE dbo.Tss_InvOutGo_Dt 
    ALTER COLUMN Num_Serial DECIMAL(21,0) NULL
END
ELSE IF EXISTS (
    SELECT 1 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = 'dbo' 
        AND TABLE_NAME = 'Tss_InvOutGo_Dt' 
        AND COLUMN_NAME = 'Num_Serial'
        AND DATA_TYPE = 'decimal'
        AND NUMERIC_PRECISION = 21
        AND NUMERIC_SCALE = 0
)
BEGIN
    PRINT 'Num_Serial is already DECIMAL(21,0). No action needed.'
END
ELSE
BEGIN
    PRINT 'Num_Serial is either not BIGINT or column does not exist.'
END

GO

-- Add Tss_SalInvoice_Hd if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Tss_SalInvoice_Hd' AND COLUMN_NAME = 'Sta_ContIsLaminate')
BEGIN
    ALTER TABLE dbo.Tss_SalInvoice_Hd ADD Sta_ContIsLaminate smallint NULL
END
GO

-- Add Sta_SayadiReg if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Tss_RapReceivedCheque' AND COLUMN_NAME = 'Sta_SayadiReg')
BEGIN
    ALTER TABLE dbo.Tss_RapReceivedCheque ADD Sta_SayadiReg smallint NULL
END
GO

-- Add Des_RecCheqOurSayadiNationalCode if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Tss_RapReceivedCheque' AND COLUMN_NAME = 'Des_RecCheqOurSayadiNationalCode')
BEGIN
    ALTER TABLE dbo.Tss_RapReceivedCheque ADD Des_RecCheqOurSayadiNationalCode varchar(500) NULL
END
GO

-- Add Dat_SayadiRegDate if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Tss_RapReceivedCheque' AND COLUMN_NAME = 'Dat_SayadiRegDate')
BEGIN
    ALTER TABLE dbo.Tss_RapReceivedCheque ADD Dat_SayadiRegDate varchar(10) NULL
END
GO

-- Add Sta_IsChecqueElectronic if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Tss_RapReceivedCheque' AND COLUMN_NAME = 'Sta_IsChecqueElectronic')
BEGIN
    ALTER TABLE dbo.Tss_RapReceivedCheque ADD Sta_IsChecqueElectronic smallint NULL
END
GO

-- Add Des_RecCheqOurSayadiNationalCode if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Tss_RapReceivedCheque' AND COLUMN_NAME = 'Des_ReceivedChequeSayadiNationalCode')
BEGIN
    ALTER TABLE dbo.Tss_RapReceivedCheque ADD Des_ReceivedChequeSayadiNationalCode varchar(500) NULL
END
GO

-- Add Dat_SayadiRegDate if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Tss_RapReceivedCheque' AND COLUMN_NAME = 'Des_ReceivedChequeSayadiCode')
BEGIN
    ALTER TABLE dbo.Tss_RapReceivedCheque ADD Des_ReceivedChequeSayadiCode varchar(10) NULL
END
GO

-- Add Num_OverStartTime if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Tss_EmpOverTimeAllowDoc' AND COLUMN_NAME = 'Num_OverStartTime')
BEGIN
    ALTER TABLE dbo.Tss_EmpOverTimeAllowDoc ADD Num_OverStartTime int NULL
END
GO

-- Add Num_OverEndTime if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA = 'dbo' AND TABLE_NAME = 'Tss_EmpOverTimeAllowDoc' AND COLUMN_NAME = 'Num_OverEndTime')
BEGIN
    ALTER TABLE dbo.Tss_EmpOverTimeAllowDoc ADD Num_OverEndTime int NULL
END
GO
-- Rest of your procedures...

alter PROCEDURE Tss_RapUntReceivedCheque_HdVStp  
(  
   @InternalWhere VarChar(8000)='',  
   @Where VarChar(8000)='',  
   @Order VarChar(8000)='',
	@FromDate varchar(10)='1399/09/01' , 
	@ToDate varchar(10)='1399/12/29',
	@Flg Smallint=0,
   @SiUser numeric=1  
) AS   

Declare
	@Adate char(10),
	@Des_StdUserToBdsCondition varchar(8000),
	@SqlTxt Varchar(8000),
    @TodayShamsi NVARCHAR(10),
    @ThirtyDaysAgoShamsi NVARCHAR(10)

SET @TodayShamsi = dbo.Tss_MiladyToShamsiPar(GetDate())
SET @ThirtyDaysAgoShamsi = dbo.Tss_MiladyToShamsiPar(DATEADD(DAY, - 7, GETDATE()))

--Set @Adate = dbo.Tss_MiladyToShamsiPar(DATEADD(d,-1,GetDate()))
Set @Adate = dbo.Tss_MiladyToShamsiPar(GetDate())
if dbo.Tss_StdFindSubLoc(0)='Caspian'
Begin
	if dbo.Tss_StdFindIfUserIsInGroup(@SiUser,'Sal') = 1
		Set @InternalWhere = 'Dat_RapReceivedChequeRegDate>''1398/01/23'''
	else
		Set @InternalWhere = ''
End
Else
Begin
		Set @InternalWhere = ''
End

If @InternalWhere<>'' 
		Set @Where=' Where (Dat_RapReceivedChequeRegDate BETWEEN ''' + @ThirtyDaysAgoShamsi + ''' AND ''' + @TodayShamsi + '''' + ')'

    
/*
SELECT     
	@Des_StdUserToBdsCondition = Tss_StdUserToBds.Des_StdUserToBdsCondition
FROM         
	Tss_StdUserToBds INNER JOIN
   Tss_StdSystemUsers ON Tss_StdUserToBds.SiStdSystemUsers = Tss_StdSystemUsers.SiStdSystemUsers
WHERE     
	(Tss_StdSystemUsers.SiPubPersonsSpec = @SiUser) and 
	(Tss_StdUserToBds.Sta_HdDt = 0) and
	(Isnull(Des_StdUserToBdsCondition,'')<>'')

If Isnull(@Des_StdUserToBdsCondition,'')=''
Begin*/

If @Where<>''    
   Set @Where=' Where '+@Where  
Else
--   Set @Where=' Where left(Dat_RapReceivedChequeRegDate,12)='+''''+left(@Adate,12)+''''
   Set @Where=' Where left(Dat_RapReceivedChequeRegDate,12)>=''1402/01/01'''
/*
End
Else
Begin
	If @Where<>''    
	   Set @Where=' Where '+@Des_StdUserToBdsCondition+' and '+@Where  
	Else
	   Set @Where=' Where '+@Des_StdUserToBdsCondition+' and Dat_RapReceivedChequeRegDate>'+''''+@Adate+''''
End */
/*Declare @SqlTxt Varchar(8000)

If @InternalWhere<>''   
   Set @InternalWhere=' Where '+@InternalWhere  
If @Where<>''   
   Set @Where=' Where '+@Where  */
If @Order<>''   
   Set @Order=' Order By '+@Order
Else
   Set @Order=' Order By Dat_RapReceivedChequeRegDate desc'


  
set @SqlTxt =  
'Select distinct * From   
(  
   Select * From 
   (  
SELECT        
	RecChq.SiRapReceivedCheque, RecChq.SiRapCashDefine, RecChq.SiPubPersonsSpec, RecChq.SiPubCustomCodes, RecChq.Cod_RapReceivedChequeCode, RecChq.Des_RapReceivedChequeDesc, 
	RecChq.Cod_RapReceivedChqBankCode, RecChq.Des_RapReceivedChqBankName, RecChq.Cod_RapReceivedChqBankAccNo, RecChq.Des_RapReceivedChqSeriCode, RecChq.Cod_RapReceivedChequeSerial, 
	RecChq.Num_RapReceivedChequeAmount, RecChq.Sta_RapReceivedChequeState, RecChq.StmRapReceivedCheque, RecChq.Sta_ChekRecieptMainOrNot, RecChq.Des_RapReceivedChequeRecieptDesc, 
	pPers.Cod_PubPersonCode, pPers.Des_PubPersonName1, pPers.Des_PubPersonName2, pPers.Des_FullName, RapCash.Cod_RapCashDefCode, RapCash.Des_RapCashDefDesc, BankTp.Cod_CustomCodesCode, 
	BankTp.Des_CustomCodesDesc, ISNULL
	((SELECT        COUNT(SiVchDtForRecCheck) AS Expr1
	FROM            Tss_RapRecievedChequeRef AS Ref
	WHERE        (SiRapReceivedCheque = RecChq.SiRapReceivedCheque) AND (SiVchDtForRecCheck IS NOT NULL)), 0) AS VochCount,
	(SELECT        ISNULL(COUNT(ISNULL(SiRapRecChequeToBank, 0)), 0) AS Expr1
	FROM            Tss_RapRecChequeToBank
	WHERE        (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) AS ToBankCount, RecChq.Dat_RapReceivedChequeCngDate, RecChq.Dat_RapReceivedChequeRegDate, 
	LEFT(RecChq.Dat_RapReceivedChequeRegDate, 4) AS Dat_RapReceivedChequeRegDateYear, SUBSTRING(RecChq.Dat_RapReceivedChequeRegDate, 6, 2) AS Dat_RapReceivedChequeRegDateMonth, 
	RecChq.Dat_RapReceivedChequeEndDate, LEFT(RecChq.Dat_RapReceivedChequeEndDate, 4) AS Dat_RapReceivedChequeEndDateYear, SUBSTRING(RecChq.Dat_RapReceivedChequeEndDate, 6, 2) 
	AS Dat_RapReceivedChequeEndDateMonth, RecChq.Dat_RapReceivedChequeVosoolDate, LEFT(RecChq.Dat_RapReceivedChequeVosoolDate, 4) AS Dat_RapReceivedChequeVosoolDateYear, 
	SUBSTRING(RecChq.Dat_RapReceivedChequeVosoolDate, 6, 2) AS Dat_RapReceivedChequeVosoolDateMonth, RecChq.Dat_RapReceivedChequeBargashtDate, LEFT(RecChq.Dat_RapReceivedChequeBargashtDate, 4) 
	AS Dat_RapReceivedChequeBargashtDateYear, SUBSTRING(RecChq.Dat_RapReceivedChequeBargashtDate, 6, 2) AS Dat_RapReceivedChequeBargashtDateMonth, RecChq.Dat_RapReceivedChequeCancelDate, 
	RecChq.Dat_RapReceivedChequeToPerDate, LEFT(RecChq.Dat_RapReceivedChequeToPerDate, 4) AS Dat_RapReceivedChequeToPerDateYear, SUBSTRING(RecChq.Dat_RapReceivedChequeToPerDate, 6, 2) 
	AS Dat_RapReceivedChequeToPerDateMonth, RecChq.Dat_RapReceivedChequeToBankDate, LEFT(RecChq.Dat_RapReceivedChequeToBankDate, 4) AS Dat_RapReceivedChequeToBankDateYear, 
	SUBSTRING(RecChq.Dat_RapReceivedChequeToBankDate, 6, 2) AS Dat_RapReceivedChequeToBankDateMonth, RecChq.Dat_RapReceivedChequeHoghughiDate, LEFT(RecChq.Dat_RapReceivedChequeHoghughiDate, 4) 
	AS Dat_RapReceivedChequeHoghughiDateYear, SUBSTRING(RecChq.Dat_RapReceivedChequeHoghughiDate, 6, 2) AS Dat_RapReceivedChequeHoghughiDateMonth, RecChq.SiPubSubLocations, 
	Tss_PubSubLocations.Cod_SubLocCode, Tss_PubSubLocations.Des_SubLocName, RecChq.Dat_RapReceivedChequeToAgainDate, RecChq.Sta_ConcurrentChek, Tss_RapRecCheckGhabzRep1Vw.GirandehCode, 
	Tss_RapRecCheckGhabzRep1Vw.GirandehDesc,
	(SELECT top 1 SiVchDtForRecCheck FROM Tss_RapRecievedChequeRef WHERE (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) as SiVchDtForRecCheck,
	(SELECT top 1 SiVchDtForChekToBank FROM Tss_RapRecievedChequeRef WHERE (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) as SiVchDtForChekToBank,
	(SELECT top 1 SiVchDtForChekToPer FROM Tss_RapRecievedChequeRef WHERE (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) as SiVchDtForChekToPer,
	(SELECT top 1 SiVchDtForVosool FROM Tss_RapRecievedChequeRef WHERE (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) as SiVchDtForVosool,
	(SELECT top 1 SiVchDtForBargasht FROM Tss_RapRecievedChequeRef WHERE (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) as SiVchDtForBargasht,
	(SELECT top 1 SiVchDtForTazmini FROM Tss_RapRecievedChequeRef WHERE (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) as SiVchDtForTazmini,
	(SELECT top 1 SiVchDtForEsterdad FROM Tss_RapRecievedChequeRef WHERE (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) as SiVchDtForEsterdad,
	(SELECT top 1 SiVchDtForCashierBargasht FROM Tss_RapRecievedChequeRef WHERE (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) as SiVchDtForCashierBargasht,
	(SELECT SUM(Num_RapRecievedChequeRefAmount) FROM Tss_RapRecievedChequeRef WHERE (SiRapReceivedCheque = RecChq.SiRapReceivedCheque)) SumRow,
	RecChq.SiRapBehalfDefineHd, 
	RecChq.SiRapRecievedChequeRef_RefrenceHd, 
	Tss_RapBehalfDefine.Cod_RapBehalfCode, 
	Tss_RapBehalfDefine.Des_RapBehalfDesc,      
	RecChq.Dat_EsterdadToCashier, 
	RecChq.Dat_EsterdadToPer,
	RecChq.Sta_CalcInReturnRep,
	pPers.RelatedSalerName, 
	pPers.RelatedSalerCode,
    RecChq.Des_ReceivedChequeSayadiCode,
    RecChq.Des_ReceivedChequeSayadiNationalCode,
    RecChq.Sta_IsChecqueElectronic,
    RecChq.Sta_SayadiReg,
    RecChq.Des_RecCheqOurSayadiNationalCode,
    RecChq.Dat_SayadiRegDate
FROM         
	Tss_RapBehalfDefine RIGHT OUTER JOIN
	Tss_RapReceivedCheque RecChq INNER JOIN
	Tss_RapCashDefine RapCash ON RecChq.SiRapCashDefine = RapCash.SiRapCashDefine INNER JOIN
	Tss_PubPersonsViw pPers ON RecChq.SiPubPersonsSpec = pPers.SiPubPersonsSpec ON 
	Tss_RapBehalfDefine.SiRapBehalfDefine = RecChq.SiRapBehalfDefineHd LEFT OUTER JOIN
	Tss_RapRecCheckGhabzRep1Vw ON RecChq.SiRapReceivedCheque = Tss_RapRecCheckGhabzRep1Vw.SiRapReceivedCheque LEFT OUTER JOIN
	Tss_PubSubLocations ON RecChq.SiPubSubLocations = Tss_PubSubLocations.SiPubSubLocations LEFT OUTER JOIN
	Tss_PubCustomCodes BankTp ON RecChq.SiPubCustomCodes = BankTp.SiPubCustomCodes'

if @Where<>''
	Set @Where = @Where + ' and  (SiPubSubLocations in (SELECT DISTINCT 
		Tss_AccFinancePeriodToPlace.SiPubSubLocations
	FROM         
		Tss_AccUserToFinancePeriodAndPlace INNER JOIN
		Tss_AccFinancePeriodToPlace ON 
		Tss_AccUserToFinancePeriodAndPlace.SiAccFinancePeriodToPlace = Tss_AccFinancePeriodToPlace.SiAccFinancePeriodToPlace
	WHERE     
		(Tss_AccUserToFinancePeriodAndPlace.SiPubPersonsSpec = '+convert(varchar,@SiUser)+')))'
else
	Set @Where = @Where + ' where  (SiPubSubLocations in  (SELECT DISTINCT 
		Tss_AccFinancePeriodToPlace.SiPubSubLocations
	FROM         
		Tss_AccUserToFinancePeriodAndPlace INNER JOIN
		Tss_AccFinancePeriodToPlace ON 
		Tss_AccUserToFinancePeriodAndPlace.SiAccFinancePeriodToPlace = Tss_AccFinancePeriodToPlace.SiAccFinancePeriodToPlace
	WHERE     
		(Tss_AccUserToFinancePeriodAndPlace.SiPubPersonsSpec = @'+convert(varchar,@SiUser)+')))'

/*
if @Flg = 0 
	Set @SqlTxt = @SqlTxt +char(10)+ ' where (RecChq.Dat_RapReceivedChequeRegDate between '+''''+@FromDate+''''+' and '+''''+@ToDate+''''+')'
if @Flg = 1 
	Set @SqlTxt = @SqlTxt +char(10)+ ' where (RecChq.Dat_RapReceivedChequeEndDate between '+''''+@FromDate+''''+' and '+''''+@ToDate+''''+')'
if @Flg = 2 
	Set @SqlTxt = @SqlTxt +char(10)+ ' where (RecChq.Dat_RapReceivedChequeVosoolDate between '+''''+@FromDate+''''+' and '+''''+@ToDate+''''+')'
if @Flg = 3 
	Set @SqlTxt = @SqlTxt +char(10)+ ' where (RecChq.Dat_RapReceivedChequeToBankDate between '+''''+@FromDate+''''+' and '+''''+@ToDate+''''+')'
if @Flg = 4 
	Set @SqlTxt = @SqlTxt +char(10)+ ' where (RecChq.Dat_RapReceivedChequeToPerDate between '+''''+@FromDate+''''+' and '+''''+@ToDate+''''+')'
if @Flg = 5 
	Set @SqlTxt = @SqlTxt +char(10)+ ' where (RecChq.Dat_RapReceivedChequeBargashtDate between '+''''+@FromDate+''''+' and '+''''+@ToDate+''''+')'
*/
Set @SqlTxt = @SqlTxt +'  ) Ccc  '+@InternalWhere+') CalcSel ' + @Where + @Order

print @SqlTxt 

Exec(@SqlTxt)


GO

alter PROCEDURE Tss_RapUntReceivedCheque_HdIudStp 
(
    @Err_Code INT OUTPUT,
    @SiRapReceivedCheque NUMERIC OUTPUT,
    @SiRapCashDefine NUMERIC=NULL,
    @SiPubPersonsSpec NUMERIC=NULL,
    @SiPubCustomCodes NUMERIC=NULL,
    @Cod_RapReceivedChqBankCode VARCHAR(50)='',
    @Des_RapReceivedChqBankName VARCHAR(200)='',
    @Cod_RapReceivedChqBankAccNo VARCHAR(50)='',
    @Des_RapReceivedChqSeriCode VARCHAR(50)='',
    @Cod_RapReceivedChequeCode VARCHAR(50)='',
    @Des_RapReceivedChequeDesc VARCHAR(500)='',
    @Dat_RapReceivedChequeRegDate VARCHAR(10)='',
    @Cod_RapReceivedChequeSerial VARCHAR(50)='',
    @Dat_RapReceivedChequeEndDate VARCHAR(10)='',
    @Num_RapReceivedChequeAmount NUMERIC=NULL,
    @Sta_RapReceivedChequeState SMALLINT=0,
    @Sta_ChekRecieptMainOrNot SMALLINT=0,
    @Dat_RapReceivedChequeCngDate VARCHAR(10)='',
    @Dat_RapReceivedChequeVosoolDate VARCHAR(10)='',
    @Dat_RapReceivedChequeBargashtDate VARCHAR(10)='',
    @Dat_RapReceivedChequeCancelDate VARCHAR(10)='',
    @Dat_RapReceivedChequeToPerDate VARCHAR(10)='',
    @Dat_RapReceivedChequeToBankDate VARCHAR(10)='',
    @Dat_RapReceivedChequeHoghughiDate VARCHAR(10)='',
    @Des_RapReceivedChequeRecieptDesc VARCHAR(1500)='',
    @Dat_RapReceivedChequeToAgainDate VARCHAR(10)='',
    @Dat_EsterdadToPer VARCHAR(10)='',
    @Dat_EsterdadToCashier VARCHAR(10)='',
    @Sta_ConcurrentChek SMALLINT=0,
    @SiPubSubLocations NUMERIC=1,
    @SiRapBehalfDefineHd NUMERIC=0,
    @SiRapRecievedChequeRef_RefrenceHd NUMERIC=0,
    @Sta_CalcInReturnRep SMALLINT=0,
    @Des_ReceivedChequeSayadiCode VARCHAR(50)='',
    @Sta_IsChecqueElectronic SMALLINT=0,
    @Des_ReceivedChequeSayadiNationalCode VARCHAR(50)='',
    @Sta_SayadiReg smallint=0,
    @Des_RecCheqOurSayadiNationalCode varchar(500)='',
    @Dat_SayadiRegDate varchar(10)='',
    @StmRapReceivedCheque TIMESTAMP=0,
    @SiUser NUMERIC,
    @FlgInsUpdDel SMALLINT
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- Automatically rollback on error
    
    DECLARE @TransactionCount INT = @@TRANCOUNT;
    
    IF @FlgInsUpdDel = 0 -- INSERT
    BEGIN
        BEGIN TRY
            IF @TransactionCount = 0
                BEGIN TRANSACTION;
            
            SET @Err_Code = 0;
            
            -- Handle code generation with transaction isolation
            IF ISNULL(@Cod_RapReceivedChequeCode, '') = ''
            BEGIN
                -- Use UPDLOCK to prevent race conditions
                SELECT @Cod_RapReceivedChequeCode = MAX(CONVERT(NUMERIC, Cod_RapReceivedChequeCode)) + 1
                FROM Tss_RapReceivedCheque WITH (UPDLOCK, HOLDLOCK)
                WHERE (SiPubSubLocations = @SiPubSubLocations) 
                    AND (Sta_ChekRecieptMainOrNot = @Sta_ChekRecieptMainOrNot)
                    AND (LEFT(Dat_RapReceivedChequeRegDate, 4) = LEFT(@Dat_RapReceivedChequeRegDate, 4))
                    AND (Cod_RapReceivedChequeCode <> '');
            END
            
            IF @Cod_RapReceivedChequeCode IS NULL OR @Cod_RapReceivedChequeCode = ''
                SET @Cod_RapReceivedChequeCode = '1'; -- Default value
            
            INSERT INTO dbo.Tss_RapReceivedCheque(
                SiRapCashDefine, SiPubPersonsSpec, Cod_RapReceivedChequeCode, 
                Des_RapReceivedChequeDesc, Dat_RapReceivedChequeRegDate, 
                Cod_RapReceivedChequeSerial, Dat_RapReceivedChequeEndDate, 
                Num_RapReceivedChequeAmount, Sta_RapReceivedChequeState, 
                Sta_ChekRecieptMainOrNot, Dat_RapReceivedChequeCngDate, 
                SiPubCustomCodes, Cod_RapReceivedChqBankCode, 
                Des_RapReceivedChqBankName, Cod_RapReceivedChqBankAccNo, 
                Des_RapReceivedChqSeriCode, Dat_RapReceivedChequeVosoolDate,
                Dat_RapReceivedChequeBargashtDate, Dat_RapReceivedChequeCancelDate, 
                Dat_RapReceivedChequeToPerDate, Dat_RapReceivedChequeToBankDate, 
                Dat_RapReceivedChequeHoghughiDate, Dat_RapReceivedChequeToAgainDate, 
                Dat_EsterdadToPer, Dat_EsterdadToCashier, 
                Des_RapReceivedChequeRecieptDesc, SiPubSubLocations, 
                Sta_ConcurrentChek, SiRapBehalfDefineHd, 
                SiRapRecievedChequeRef_RefrenceHd, Sta_CalcInReturnRep, 
                Des_ReceivedChequeSayadiCode, Des_ReceivedChequeSayadiNationalCode, 
                Sta_IsChecqueElectronic,
                Sta_SayadiReg, 
                Des_RecCheqOurSayadiNationalCode,
                Dat_SayadiRegDate
            )
            VALUES(
                @SiRapCashDefine, @SiPubPersonsSpec, @Cod_RapReceivedChequeCode, 
                @Des_RapReceivedChequeDesc, @Dat_RapReceivedChequeRegDate, 
                @Cod_RapReceivedChequeSerial, @Dat_RapReceivedChequeEndDate, 
                @Num_RapReceivedChequeAmount, @Sta_RapReceivedChequeState, 
                @Sta_ChekRecieptMainOrNot, @Dat_RapReceivedChequeCngDate, 
                @SiPubCustomCodes, @Cod_RapReceivedChqBankCode, 
                @Des_RapReceivedChqBankName, @Cod_RapReceivedChqBankAccNo, 
                @Des_RapReceivedChqSeriCode, @Dat_RapReceivedChequeVosoolDate, 
                @Dat_RapReceivedChequeBargashtDate, @Dat_RapReceivedChequeCancelDate, 
                @Dat_RapReceivedChequeToPerDate, @Dat_RapReceivedChequeToBankDate, 
                @Dat_RapReceivedChequeHoghughiDate, @Dat_RapReceivedChequeToAgainDate, 
                @Dat_EsterdadToPer, @Dat_EsterdadToCashier, 
                @Des_RapReceivedChequeRecieptDesc, @SiPubSubLocations, 
                @Sta_ConcurrentChek, @SiRapBehalfDefineHd, 
                @SiRapRecievedChequeRef_RefrenceHd, @Sta_CalcInReturnRep, 
                @Des_ReceivedChequeSayadiCode, @Des_ReceivedChequeSayadiNationalCode, 
                @Sta_IsChecqueElectronic,
                @Sta_SayadiReg, 
                @Des_RecCheqOurSayadiNationalCode,
                @Dat_SayadiRegDate
            );
            
            SET @SiRapReceivedCheque = SCOPE_IDENTITY();

            IF ISNULL(@SiRapReceivedCheque, 0) <> 0
            BEGIN
                -- FIXED: Changed last parameter from 1 to 0 for INSERT mode
                EXEC dbo.Tss_RapUntReceivedCheque_DtIudStp 
                    0, 
                    0, 
                    @SiRapReceivedCheque, 
                    @SiRapBehalfDefineHd, 
                    @SiRapRecievedChequeRef_RefrenceHd, 
                    @Num_RapReceivedChequeAmount, 
                    0, 
                    @SiUser, 
                    0; -- INSERT mode = 0
                
                IF @Err_Code <> 0
                    RAISERROR('Error in detail insert', 16, 1);
            END
            
            IF ISNULL(@SiRapReceivedCheque, 0) = 0
            BEGIN
                SET @SiRapReceivedCheque = 0;
                SET @Err_Code = 400;
                RAISERROR('Insert failed', 16, 1);
            END
            
            IF @TransactionCount = 0
                COMMIT TRANSACTION;
            
        END TRY
        BEGIN CATCH
            IF @TransactionCount = 0 AND XACT_STATE() <> 0
                ROLLBACK TRANSACTION;
            
            SET @Err_Code = ERROR_NUMBER();
            SET @SiRapReceivedCheque = 0;
            
            -- Re-throw error for client
            DECLARE @ErrorMsg NVARCHAR(4000) = ERROR_MESSAGE();
            RAISERROR(@ErrorMsg, 16, 1);
        END CATCH
    END
    
    IF @FlgInsUpdDel = 1 -- UPDATE
    BEGIN
        BEGIN TRY
            IF @TransactionCount = 0
                BEGIN TRANSACTION;
            
            SET @Err_Code = 0;
            
            DECLARE @CurrentStmRapReceivedCheque INT;
            DECLARE @RowCount INT;
            
            -- Check if record exists with proper locking
            SELECT @CurrentStmRapReceivedCheque = StmRapReceivedCheque 
            FROM dbo.Tss_RapReceivedCheque WITH (UPDLOCK, ROWLOCK) 
            WHERE SiRapReceivedCheque = @SiRapReceivedCheque;
            
            IF @CurrentStmRapReceivedCheque IS NULL
            BEGIN
                SET @Err_Code = 402; -- Record not found
                RAISERROR('Record not found', 16, 1);
            END
            ELSE IF @CurrentStmRapReceivedCheque <> @StmRapReceivedCheque
            BEGIN
                SET @Err_Code = 403; -- Concurrency conflict
                RAISERROR('Concurrent modification detected', 16, 1);
            END
            ELSE
            BEGIN
                -- Update main record
                UPDATE dbo.Tss_RapReceivedCheque
                SET 
                    SiRapCashDefine = @SiRapCashDefine,
                    SiPubPersonsSpec = @SiPubPersonsSpec,
                    Cod_RapReceivedChequeCode = @Cod_RapReceivedChequeCode,
                    Des_RapReceivedChequeDesc = @Des_RapReceivedChequeDesc,
                    Dat_RapReceivedChequeRegDate = @Dat_RapReceivedChequeRegDate,
                    Cod_RapReceivedChequeSerial = @Cod_RapReceivedChequeSerial,
                    Dat_RapReceivedChequeEndDate = @Dat_RapReceivedChequeEndDate,
                    Num_RapReceivedChequeAmount = @Num_RapReceivedChequeAmount,
                    Sta_RapReceivedChequeState = @Sta_RapReceivedChequeState,
                    Sta_ChekRecieptMainOrNot = @Sta_ChekRecieptMainOrNot,
                    Dat_RapReceivedChequeCngDate = GETDATE(),
                    SiPubCustomCodes = @SiPubCustomCodes,
                    Cod_RapReceivedChqBankCode = @Cod_RapReceivedChqBankCode,
                    Des_RapReceivedChqBankName = @Des_RapReceivedChqBankName,
                    Cod_RapReceivedChqBankAccNo = @Cod_RapReceivedChqBankAccNo,
                    Des_RapReceivedChqSeriCode = @Des_RapReceivedChqSeriCode,
                    Dat_RapReceivedChequeVosoolDate = @Dat_RapReceivedChequeVosoolDate,
                    Dat_RapReceivedChequeBargashtDate = @Dat_RapReceivedChequeBargashtDate,
                    Dat_RapReceivedChequeCancelDate = @Dat_RapReceivedChequeCancelDate,
                    Dat_RapReceivedChequeToPerDate = @Dat_RapReceivedChequeToPerDate,
                    Dat_RapReceivedChequeToBankDate = @Dat_RapReceivedChequeToBankDate,
                    Dat_RapReceivedChequeHoghughiDate = @Dat_RapReceivedChequeHoghughiDate,
                    Dat_RapReceivedChequeToAgainDate = @Dat_RapReceivedChequeToAgainDate,
                    Dat_EsterdadToPer = @Dat_EsterdadToPer,
                    Dat_EsterdadToCashier = @Dat_EsterdadToCashier,
                    Des_RapReceivedChequeRecieptDesc = @Des_RapReceivedChequeRecieptDesc,
                    SiPubSubLocations = @SiPubSubLocations,
                    Sta_ConcurrentChek = @Sta_ConcurrentChek,
                    SiRapBehalfDefineHd = @SiRapBehalfDefineHd,
                    SiRapRecievedChequeRef_RefrenceHd = @SiRapRecievedChequeRef_RefrenceHd,
                    Sta_CalcInReturnRep = @Sta_CalcInReturnRep,
                    Des_ReceivedChequeSayadiCode = @Des_ReceivedChequeSayadiCode,
                    Des_ReceivedChequeSayadiNationalCode = @Des_ReceivedChequeSayadiNationalCode,
                    Sta_IsChecqueElectronic = @Sta_IsChecqueElectronic,
                    Sta_SayadiReg=@Sta_SayadiReg, 
                    Des_RecCheqOurSayadiNationalCode=@Des_RecCheqOurSayadiNationalCode,
                    Dat_SayadiRegDate=@Dat_SayadiRegDate
                WHERE SiRapReceivedCheque = @SiRapReceivedCheque
                    AND StmRapReceivedCheque = @StmRapReceivedCheque;
                
                -- Call detail procedure after successful update

                SELECT @RowCount = COUNT(*)
                FROM Tss_RapRecievedChequeRef
                WHERE SiRapReceivedCheque = @SiRapReceivedCheque

                IF @RowCount = 1 
                BEGIN
                    DECLARE 
                        @SiRapRecievedChequeRef NUMERIC,
                        @StmRapRecievedChequeRef TimeStamp

                    SET @SiRapRecievedChequeRef = 0;
                
                    SELECT TOP 1 
                        @SiRapRecievedChequeRef = SiRapRecievedChequeRef, 
                        @StmRapRecievedChequeRef = StmRapRecievedChequeRef 
                    FROM 
                        dbo.Tss_RapRecievedChequeRef 
                    WHERE 
                        SiRapReceivedCheque = @SiRapReceivedCheque;
            
                    IF ISNULL(@SiRapReceivedCheque, 0) <> 0
                    BEGIN
                        EXEC dbo.Tss_RapUntReceivedCheque_DtIudStp 
                            0, 
                            @SiRapRecievedChequeRef, 
                            @SiRapReceivedCheque, 
                            @SiRapBehalfDefineHd, 
                            @SiRapRecievedChequeRef_RefrenceHd, 
                            @Num_RapReceivedChequeAmount, 
                            @StmRapRecievedChequeRef, 
                            @SiUser, 
                            1;
                END
                
                    IF @Err_Code <> 0
                        RAISERROR('Error in detail update', 16, 1);
                END  -- Added this END for the IF block
            END  -- Added this END for the ELSE block
            
            IF @TransactionCount = 0
                COMMIT TRANSACTION;
            
        END TRY
        BEGIN CATCH
            IF @TransactionCount = 0 AND XACT_STATE() <> 0
                ROLLBACK TRANSACTION;
            
            SET @Err_Code = ERROR_NUMBER();
            
            DECLARE @ErrorMsg2 NVARCHAR(4000) = ERROR_MESSAGE();
            RAISERROR(@ErrorMsg2, 16, 1);
        END CATCH
    END
    
    IF @FlgInsUpdDel = 2 -- DELETE
    BEGIN
        BEGIN TRY
            IF @TransactionCount = 0
                BEGIN TRANSACTION;
            
            SET @Err_Code = 0;
            
            -- Check existence and timestamp
            IF EXISTS (
                SELECT 1 
                FROM dbo.Tss_RapReceivedCheque WITH (UPDLOCK, ROWLOCK)
                WHERE SiRapReceivedCheque = @SiRapReceivedCheque 
                    AND StmRapReceivedCheque = @StmRapReceivedCheque
            )
            BEGIN
                -- You might want to add a soft delete flag instead of hard delete
                -- Or check for referential integrity first
                
                DELETE FROM dbo.Tss_RapReceivedCheque
                WHERE SiRapReceivedCheque = @SiRapReceivedCheque
                    AND StmRapReceivedCheque = @StmRapReceivedCheque;
                
                SET @Err_Code = @@ERROR;
                
                IF @Err_Code <> 0
                BEGIN
                    SET @Err_Code = 4000;
                    RAISERROR('Delete failed', 16, 1);
                END
                
                -- Optionally, also delete related detail records
                -- EXEC dbo.Tss_RapUntReceivedCheque_DtIudStp ... with FlgInsUpdDel = 2
            END
            ELSE
            BEGIN
                SET @Err_Code = 4000; -- Record not found or timestamp mismatch
                RAISERROR('Record not found or concurrency conflict', 16, 1);
            END
            
            IF @TransactionCount = 0
                COMMIT TRANSACTION;
            
        END TRY
        BEGIN CATCH
            IF @TransactionCount = 0 AND XACT_STATE() <> 0
                ROLLBACK TRANSACTION;
            
            SET @Err_Code = ERROR_NUMBER();
            
            DECLARE @ErrorMsg3 NVARCHAR(4000) = ERROR_MESSAGE();
            RAISERROR(@ErrorMsg3, 16, 1);
        END CATCH
    END
END


GO



alter PROCEDURE Tss_RapUntReceivedCheque_DtVStp  
(  
   @InternalWhere VarChar(8000)='',  
   @Where VarChar(8000)='',  
   @Order VarChar(8000)=''  
) AS   
If @InternalWhere<>''   
   Set @InternalWhere=' Where '+@InternalWhere  
If @Where<>''   
   Set @Where=' Where '+@Where  
If @Order<>''   
   Set @Order=' Order By '+@Order  
Exec(  
   'Select * From   
   (  
   Select * From (  
      SELECT     rRCR.SiRapRecievedChequeRef, rRCR.SiRapReceivedCheque, rRCR.SiRapBehalfDefine, rRCR.SiVchDtForRecCheck, rRCR.SiVchDtForChekToBank, 
                      rRCR.SiVchDtForChekToPer, rRCR.SiVchDtForVosool, rRCR.SiVchDtForBargasht, rRCR.SiVchDtForEsterdad, rRCR.SiVchDtForTazmini, rRCR.SiVchDtForCashierBargasht,
                      rRCR.Num_RapRecievedChequeRefAmount, 
                      rRCR.SiRapRecievedChequeRef_Refrence, rRCR.StmRapRecievedChequeRef, rBD.Cod_RapBehalfCode, rBD.Des_RapBehalfDesc, 
                      VochDt.Num_VDetRow, VochDt.SiAccVoucher_Hd, Tss_AccVoucher_Dt_1.SiAccVoucher_Hd AS SiVchChekToBank, 
                      Tss_AccVoucher_Dt_2.SiAccVoucher_Hd AS SiVchChekToPer, Tss_AccVoucher_Dt_3.SiAccVoucher_Hd AS SiVchVosool, 
                      Tss_AccVoucher_Dt_4.SiAccVoucher_Hd AS SiVchBargasht, Tss_AccVoucher_Dt_1.Num_VDetRow AS VchRowToBank, 
                      Tss_AccVoucher_Dt_2.Num_VDetRow AS VchRowToPer, Tss_AccVoucher_Dt_3.Num_VDetRow AS VchRowVosool, 
                      Tss_AccVoucher_Dt_4.Num_VDetRow AS VshRowBargasht
FROM         dbo.Tss_AccVoucher_Dt VochDt RIGHT OUTER JOIN
                      dbo.Tss_AccVoucher_Dt Tss_AccVoucher_Dt_4 RIGHT OUTER JOIN
                      dbo.Tss_RapRecievedChequeRef rRCR INNER JOIN
                      dbo.Tss_RapBehalfDefine rBD ON rRCR.SiRapBehalfDefine = rBD.SiRapBehalfDefine ON 
                      Tss_AccVoucher_Dt_4.SiAccVoucher_Dt = rRCR.SiVchDtForBargasht LEFT OUTER JOIN
                      dbo.Tss_AccVoucher_Dt Tss_AccVoucher_Dt_3 ON rRCR.SiVchDtForVosool = Tss_AccVoucher_Dt_3.SiAccVoucher_Dt LEFT OUTER JOIN
                      dbo.Tss_AccVoucher_Dt Tss_AccVoucher_Dt_2 ON rRCR.SiVchDtForChekToPer = Tss_AccVoucher_Dt_2.SiAccVoucher_Dt LEFT OUTER JOIN
                      dbo.Tss_AccVoucher_Dt Tss_AccVoucher_Dt_1 ON rRCR.SiVchDtForChekToBank = Tss_AccVoucher_Dt_1.SiAccVoucher_Dt ON 
                      VochDt.SiAccVoucher_Dt = rRCR.SiVchDtForRecCheck
         ) Ccc  '+@InternalWhere+'  
         ) CalcSel ' + @Where + @Order  
)



GO

alter Procedure dbo.Tss_EmpUntOverTimeAllowDocIudStp
(
	@Err_Code Int OutPut,
	@SiEmpOverTimeAllowDoc Numeric OutPut,
	@SiPubPersonsSpec varchar(8000)='6,11',
	@Dat_OverTimeDocStartDate varchar(10)='',
	@Dat_OverTimeDocEndedDate varchar(10)='',
	@Num_ValidOverBeforDoc int=0,
	@Num_ValidOverAfterDoc int=0,
	@Num_ValidOverInHoliday int=0,
	@Num_OverStartTime int=0,
	@Num_OverEndTime int=0,
	@StmEmpOverTimeAllowDoc TimeStamp=0,
	@DesWorkStart varchar(50)='',
	@DesWorkEnd varchar(50)='',
	@SiUser Numeric,
	@FlgInsUpdDel SmallInt
) As
If @FlgInsUpdDel=0
Begin
	declare 
		@PerTable table (SiPer numeric)
	declare 
		@SiSelected numeric
	Insert Into @PerTable
	(SiPer)
	select distinct SiSel from dbo.Tss_StdStringSiFindUdf(@SiPubPersonsSpec) order by SiSel
	while exists(select SiPer from @PerTable)
	Begin
		Select top 1 @SiSelected=SiPer from @PerTable order by SiPer

		-------------------------------------------------------------------------------------------------
		-- NEW: if a record already exists for this person with the same
		-- SiPubPersonsSpec (=@SiSelected), Dat_OverTimeDocStartDate,
		-- Dat_OverTimeDocEndedDate, Num_ValidOverBeforDoc, Num_ValidOverAfterDoc,
		-- Num_ValidOverInHoliday, Num_OverStartTime and Num_OverEndTime, skip
		-- inserting a duplicate for this person and move on to the next one.
		-------------------------------------------------------------------------------------------------
		if exists
		(
			select 1
			from dbo.Tss_EmpOverTimeAllowDoc
			where	SiPubPersonsSpec			= @SiSelected
				and	Dat_OverTimeDocStartDate	= @Dat_OverTimeDocStartDate
				and	Dat_OverTimeDocEndedDate	= @Dat_OverTimeDocEndedDate
				and	Num_ValidOverBeforDoc		= @Num_ValidOverBeforDoc
				and	Num_ValidOverAfterDoc		= @Num_ValidOverAfterDoc
				and	Num_ValidOverInHoliday		= @Num_ValidOverInHoliday
				and	Num_OverStartTime			= @Num_OverStartTime
				and	Num_OverEndTime				= @Num_OverEndTime
		)
		Begin
			Delete From @PerTable where SiPer=@SiSelected
			Continue
		End
		-------------------------------------------------------------------------------------------------

		Insert Into dbo.Tss_EmpOverTimeAllowDoc
		(
			SiPubPersonsSpec,
			Dat_OverTimeDocStartDate,
			Dat_OverTimeDocEndedDate,
			Num_ValidOverBeforDoc,
			Num_ValidOverAfterDoc,
			Num_ValidOverInHoliday,
			Num_OverStartTime,
			Num_OverEndTime
		)
		Values
		(
			@SiSelected,
			@Dat_OverTimeDocStartDate,
			@Dat_OverTimeDocEndedDate,
			@Num_ValidOverBeforDoc,
			@Num_ValidOverAfterDoc,
			@Num_ValidOverInHoliday,
			@Num_OverStartTime,
			@Num_OverEndTime
		)
		Set @SiEmpOverTimeAllowDoc=Scope_Identity
()
		If IsNull(@SiEmpOverTimeAllowDoc,0)=0
		Begin
			Set @SiEmpOverTimeAllowDoc=0
			
			Set @Err_Code=400
		End
	
		Delete From @PerTable where SiPer=@SiSelected
	End
End
If @FlgInsUpdDel=1
Begin
	Set @Err_Code=0
	If Exists(
	Select StmEmpOverTimeAllowDoc From dbo.Tss_EmpOverTimeAllowDoc
	Where (SiEmpOverTimeAllowDoc=@SiEmpOverTimeAllowDoc) And (StmEmpOverTimeAllowDoc=@StmEmpOverTimeAllowDoc))
	Begin
		Update dbo.Tss_EmpOverTimeAllowDoc Set
			SiPubPersonsSpec=convert(numeric,@SiPubPersonsSpec),
			Dat_OverTimeDocStartDate=@Dat_OverTimeDocStartDate,
			Dat_OverTimeDocEndedDate=@Dat_OverTimeDocEndedDate,
			Num_ValidOverBeforDoc=@Num_ValidOverBeforDoc,
			Num_ValidOverAfterDoc=@Num_ValidOverAfterDoc,
			Num_ValidOverInHoliday=@Num_ValidOverInHoliday
		Where (SiEmpOverTimeAllowDoc=@SiEmpOverTimeAllowDoc)
		Set @Err_Code=@@Error
		If @Err_Code<>0
			Set @Err_Code=401
		Return
	End
	ELse
		Set @Err_Code=402
End
If @FlgInsUpdDel=2
Begin
	Set @Err_Code=0
	If Exists(
	Select StmEmpOverTimeAllowDoc From dbo.Tss_EmpOverTimeAllowDoc
	Where (SiEmpOverTimeAllowDoc=@SiEmpOverTimeAllowDoc) And (StmEmpOverTimeAllowDoc=@StmEmpOverTimeAllowDoc))
	Begin
		Delete From dbo.Tss_EmpOverTimeAllowDoc
		Where (SiEmpOverTimeAllowDoc=@SiEmpOverTimeAllowDoc)
		Set @Err_Code=@@Error
		If @Err_Code<>0
			Set @Err_Code=4000
	End
	Else
		Set @Err_Code=4001
	Return
End

GO

alter Procedure Tss_EmpUntDutyDocsIudStp
(
	@Err_Code Int OutPut,
	@SiEmpDutyDocs Numeric OutPut,
	@SiEmpDutyTypes numeric=null,
	@SiPubPersonsSpec numeric=null,
	@Num_DutyDocNumber numeric=0,
	@Dat_DutyStartDate varchar(10)='',
	@Dat_DutyEndedDate varchar(10)='',
	@Dat_DutyRequestDate varchar(10)='',
	@Des_DutyDesc varchar(8000)='',
	@Sta_DutyAcceptStat smallint=1,
	@Sta_DutyRegStat smallint=1,
	@Num_DutyStartTime int=0,
	@Num_DutyEndedTime int=0,
	@Num_OverDutyNormal int=0,
	@Num_OverDutyHoliday int=0,
	@StmEmpDutyDocs TimeStamp=0,
	@SiUser Numeric,
	@FlgInsUpdDel SmallInt
) As

If @FlgInsUpdDel=0
Begin
-------------------------------------------------------------------------------------------------
-- NEW: if a record already exists with the same SiEmpDutyTypes, SiPubPersonsSpec,
-- Dat_DutyStartDate, Dat_DutyEndedDate, Dat_DutyRequestDate, Sta_DutyAcceptStat,
-- Sta_DutyRegStat, Num_DutyStartTime, Num_DutyEndedTime, Num_OverDutyNormal and
-- Num_OverDutyHoliday, skip the insert (and the duty-calc population that
-- depends on it) instead of creating a duplicate row.
-------------------------------------------------------------------------------------------------
If Exists
(
	select 1
	from dbo.Tss_EmpDutyDocs
	where	SiEmpDutyTypes		= @SiEmpDutyTypes
		and	SiPubPersonsSpec	= @SiPubPersonsSpec
		and	Dat_DutyStartDate	= @Dat_DutyStartDate
		and	Dat_DutyEndedDate	= @Dat_DutyEndedDate
		and	Dat_DutyRequestDate	= @Dat_DutyRequestDate
		and	Sta_DutyAcceptStat	= @Sta_DutyAcceptStat
		and	Sta_DutyRegStat		= @Sta_DutyRegStat
		and	Num_DutyStartTime	= @Num_DutyStartTime
		and	Num_DutyEndedTime	= @Num_DutyEndedTime
		and	Num_OverDutyNormal	= @Num_OverDutyNormal
		and	Num_OverDutyHoliday	= @Num_OverDutyHoliday
)
Begin
	Set @SiEmpDutyDocs=0
	Return
End
-------------------------------------------------------------------------------------------------

if exists(select 1 from dbo.Tss_EmpDutyDocs)
	select @Num_DutyDocNumber=isnull(Max(Num_DutyDocNumber),0)+1 from dbo.Tss_EmpDutyDocs
Else
	Set @Num_DutyDocNumber=1
 
	Insert Into dbo.Tss_EmpDutyDocs
	(
		SiEmpDutyTypes,
		SiPubPersonsSpec,
		Num_DutyDocNumber,
		Dat_DutyStartDate,
		Dat_DutyEndedDate,
		Num_DutyStartTime,
		Num_DutyEndedTime,
		Num_OverDutyNormal,
		Num_OverDutyHoliday,
		Dat_DutyRequestDate,
		Des_DutyDesc,
		Sta_DutyAcceptStat,
		Sta_DutyRegStat
	)
	Values
	(
		@SiEmpDutyTypes,
		@SiPubPersonsSpec,
		@Num_DutyDocNumber,
		@Dat_DutyStartDate,
		@Dat_DutyEndedDate,
		@Num_DutyStartTime,
		@Num_DutyEndedTime,
		@Num_OverDutyNormal,
		@Num_OverDutyHoliday,
		@Dat_DutyRequestDate,
		@Des_DutyDesc,
		@Sta_DutyAcceptStat,
		@Sta_DutyRegStat
	)

	Set @SiEmpDutyDocs=Scope_Identity()

------------------------------------------------درج در محاسبه ماموريت------------------------------------------------------
	Declare 
		@SiGenDate numeric,
		@DutyDate VarChar(10),
		@NumEndOfDay Numeric, 
		@NumStartOfDay Numeric,
		@Sta_WorkDayState SmallInt
	Declare DutyDates Cursor For
	SELECT SiGenDates,Dat_GenShamsiDate FROM Tss_GenDates 
	WHERE (Dat_GenShamsiDate BETWEEN @Dat_DutyStartDate AND @Dat_DutyEndedDate)
	Order By Dat_GenShamsiDate
	Open DutyDates
	Fetch Next From DutyDates
	into @SiGenDate,@DutyDate
	
	While @@Fetch_Status=0
	Begin
----------------------------- Start Of While Begin------------------------------
		If @Dat_DutyStartDate<@Dat_DutyEndedDate	 
      Begin	
		--------------------Start Of @DutyDate=@Dat_DutyStartDate Begin---------
			If @DutyDate=@Dat_DutyStartDate
				Begin
					SELECT @NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
					FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
					Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
					From dbo.Tss_EmpDutyDocs
					Where SiEmpDutyDocs = @SiEmpDutyDocs
					
					Insert Into dbo.Tss_EmpDutyCalc
						(
						SiEmpDutyDocs, 
						Dat_DutyDate, 
						Num_DutyUsedMin,
						Num_DutyOverMin
						)
						Values
						(
						@SiEmpDutyDocs,
						@DutyDate,
						@NumEndOfDay-@Num_DutyStartTime,
						@Num_OverDutyNormal*60+@Num_OverDutyHoliday*60
						)
				End
				else
				If (@DutyDate>@Dat_DutyStartDate) And (@DutyDate<@Dat_DutyEndedDate)
					Begin
						SELECT @NumStartOfDay=Num_WorkGroupStartTime,@NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
						FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
						Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
						From dbo.Tss_EmpDutyDocs
						Where SiEmpDutyDocs = @SiEmpDutyDocs
						
						Insert Into dbo.Tss_EmpDutyCalc
						(
						SiEmpDutyDocs, 
						Dat_DutyDate, 
						Num_DutyUsedMin,
						Num_DutyOverMin
						)
						Values
						(
						@SiEmpDutyDocs,
						@DutyDate,
						@NumEndOfDay-@NumStartOfDay,
						0
						)
					End
					else
					If (@DutyDate=@Dat_DutyEndedDate)
						Begin
							SELECT @NumStartOfDay=Num_WorkGroupStartTime,@Sta_WorkDayState=Sta_WorkDayState
							FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
							Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
							From dbo.Tss_EmpDutyDocs
							Where SiEmpDutyDocs = @SiEmpDutyDocs
							
							Insert Into dbo.Tss_EmpDutyCalc
								(
								SiEmpDutyDocs, 
								Dat_DutyDate, 
								Num_DutyUsedMin,
								Num_DutyOverMin
								)
								Values
								(
								@SiEmpDutyDocs,
								@DutyDate,
								@Num_DutyEndedTime-@NumStartOfDay,
								0
								)
						End
			-----------------End Of @DutyDate=@Dat_DutyStartDate Begin---------
      End
		Else
			If (@Dat_DutyStartDate=@Dat_DutyEndedDate)	
				Begin
					SELECT @NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
					FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
					Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
					From dbo.Tss_EmpDutyDocs
					Where SiEmpDutyDocs = @SiEmpDutyDocs
					--If @Sta_WorkDayState=0
					Insert Into dbo.Tss_EmpDutyCalc
						(
						SiEmpDutyDocs, 
						Dat_DutyDate, 
						Num_DutyUsedMin,
						Num_DutyOverMin
						)
						Values
						(
						@SiEmpDutyDocs,
						@DutyDate,
						@Num_DutyEndedTime-@Num_DutyStartTime,
						0
						)
				End
		Fetch Next From DutyDates
		Into @SiGenDate,@DutyDate
----------------------------- End Of While Begin------------------------------
	End
--End
	Close DutyDates
	Deallocate DutyDates

------------------------------------------------درج در محاسبه ماموريت------------------------------------------------------

	If IsNull(@SiEmpDutyDocs,0)=0
	Begin
		Set @SiEmpDutyDocs=0
		Set @Err_Code=400
	End
	Return
End
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
If @FlgInsUpdDel=1
Begin
	Set @Err_Code=0
	If Exists(
	Select StmEmpDutyDocs From dbo.Tss_EmpDutyDocs
	Where (SiEmpDutyDocs=@SiEmpDutyDocs) And (StmEmpDutyDocs=@StmEmpDutyDocs))
	Begin
		Update dbo.Tss_EmpDutyDocs Set
			SiEmpDutyTypes=@SiEmpDutyTypes,
			SiPubPersonsSpec=@SiPubPersonsSpec,
			Num_DutyDocNumber=@Num_DutyDocNumber,
			Dat_DutyStartDate=@Dat_DutyStartDate,
			Dat_DutyEndedDate=@Dat_DutyEndedDate,
			Dat_DutyRequestDate=@Dat_DutyRequestDate,
			Des_DutyDesc=@Des_DutyDesc,
			Sta_DutyAcceptStat=@Sta_DutyAcceptStat,
			Sta_DutyRegStat=@Sta_DutyRegStat,
			Num_DutyStartTime=@Num_DutyStartTime,
			Num_DutyEndedTime=@Num_DutyEndedTime,
			Num_OverDutyNormal=@Num_OverDutyNormal,
			Num_OverDutyHoliday=@Num_OverDutyHoliday
		Where (SiEmpDutyDocs=@SiEmpDutyDocs)

------------------------------------------------درج در محاسبه ماموريت-------------------------------------
	Declare DutyDates Cursor For
	SELECT SiGenDates,Dat_GenShamsiDate FROM Tss_GenDates 
	WHERE (Dat_GenShamsiDate BETWEEN @Dat_DutyStartDate AND @Dat_DutyEndedDate)
	Order By Dat_GenShamsiDate
	Open DutyDates
	Fetch Next From DutyDates
	into @SiGenDate,@DutyDate
	
	While @@Fetch_Status=0
	Begin
		If @Dat_DutyStartDate<@Dat_DutyEndedDate	 
		Begin	
			If @DutyDate=@Dat_DutyStartDate
				Begin
					SELECT @NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
					FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
					Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
					From dbo.Tss_EmpDutyDocs
					Where SiEmpDutyDocs = @SiEmpDutyDocs

					if exists(SELECT 1 FROM Tss_EmpDutyCalc WHERE (SiEmpDutyDocs = @SiEmpDutyDocs))
					Update dbo.Tss_EmpDutyCalc Set
						SiEmpDutyDocs=@SiEmpDutyDocs, 
						Dat_DutyDate=@DutyDate, 
						Num_DutyUsedMin=@NumEndOfDay-@Num_DutyStartTime,
						Num_DutyOverMin=@Num_OverDutyNormal*60+@Num_OverDutyHoliday*60
					Where Dat_DutyDate=@DutyDate And SiEmpDutyDocs=@SiEmpDutyDocs
					Else
					Begin
						SELECT @NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
						FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
						Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
						From dbo.Tss_EmpDutyDocs
						Where SiEmpDutyDocs = @SiEmpDutyDocs
						
						Insert Into dbo.Tss_EmpDutyCalc
							(
							SiEmpDutyDocs, 
							Dat_DutyDate, 
							Num_DutyUsedMin,
							Num_DutyOverMin
							)
							Values
							(
							@SiEmpDutyDocs,
							@DutyDate,
							@NumEndOfDay-@Num_DutyStartTime,
							@Num_OverDutyNormal*60+@Num_OverDutyHoliday*60
							)
					End
				End
				else
				If (@DutyDate>@Dat_DutyStartDate) And (@DutyDate<@Dat_DutyEndedDate)
					Begin
						SELECT @NumStartOfDay=Num_WorkGroupStartTime,@NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
						FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
						Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
						From dbo.Tss_EmpDutyDocs
						Where SiEmpDutyDocs = @SiEmpDutyDocs
						
						if exists(SELECT 1 FROM Tss_EmpDutyCalc WHERE (SiEmpDutyDocs = @SiEmpDutyDocs))
						Update dbo.Tss_EmpDutyCalc Set
							SiEmpDutyDocs=@SiEmpDutyDocs, 
							Dat_DutyDate=@DutyDate, 
							Num_DutyUsedMin=@NumEndOfDay-@NumStartOfDay,
							Num_DutyOverMin=0
						Where Dat_DutyDate=@DutyDate And SiEmpDutyDocs=@SiEmpDutyDocs
						Else
						Begin
							SELECT @NumStartOfDay=Num_WorkGroupStartTime,@NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
							FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
							Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
							From dbo.Tss_EmpDutyDocs
							Where SiEmpDutyDocs = @SiEmpDutyDocs
							
							Insert Into dbo.Tss_EmpDutyCalc
							(
							SiEmpDutyDocs, 
							Dat_DutyDate, 
							Num_DutyUsedMin,
							Num_DutyOverMin
							)
							Values
							(
							@SiEmpDutyDocs,
							@DutyDate,
							@NumEndOfDay-@NumStartOfDay,
							0
							)
						End

					End
					else
					If (@DutyDate=@Dat_DutyEndedDate)
						Begin
							SELECT @NumStartOfDay=Num_WorkGroupStartTime,@Sta_WorkDayState=Sta_WorkDayState
							FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
							Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
							From dbo.Tss_EmpDutyDocs
							Where SiEmpDutyDocs = @SiEmpDutyDocs
							
							if exists(SELECT 1 FROM Tss_EmpDutyCalc WHERE (SiEmpDutyDocs = @SiEmpDutyDocs))
							Update dbo.Tss_EmpDutyCalc Set
								SiEmpDutyDocs=@SiEmpDutyDocs, 
								Dat_DutyDate=@DutyDate, 
								Num_DutyUsedMin=@Num_DutyEndedTime-@NumStartOfDay,
								Num_DutyOverMin=0
							Where Dat_DutyDate=@DutyDate And SiEmpDutyDocs=@SiEmpDutyDocs
							Else
							Begin
								SELECT @NumStartOfDay=Num_WorkGroupStartTime,@Sta_WorkDayState=Sta_WorkDayState
								FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
								Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
								From dbo.Tss_EmpDutyDocs
								Where SiEmpDutyDocs = @SiEmpDutyDocs
								
								Insert Into dbo.Tss_EmpDutyCalc
									(
									SiEmpDutyDocs, 
									Dat_DutyDate, 
									Num_DutyUsedMin,
									Num_DutyOverMin
									)
									Values
									(
									@SiEmpDutyDocs,
									@DutyDate,
									@Num_DutyEndedTime-@NumStartOfDay,
									0
									)
							End

						End
		End
		Else 
		If (@Dat_DutyStartDate=@Dat_DutyEndedDate) 
			Begin
				SELECT @NumStartOfDay=Num_WorkGroupStartTime,@Sta_WorkDayState=Sta_WorkDayState
				FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
				Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
				From dbo.Tss_EmpDutyDocs
				Where SiEmpDutyDocs = @SiEmpDutyDocs
				
				if exists(SELECT SiEmpDutyDocs FROM Tss_EmpDutyCalc WHERE (SiEmpDutyDocs = @SiEmpDutyDocs))
				Update dbo.Tss_EmpDutyCalc Set
					SiEmpDutyDocs=@SiEmpDutyDocs, 
					Dat_DutyDate=@DutyDate, 
					Num_DutyUsedMin=@Num_DutyEndedTime-@Num_DutyStartTime,
					Num_DutyOverMin=0
				Where Dat_DutyDate=@DutyDate And SiEmpDutyDocs=@SiEmpDutyDocs
				Else
				Begin
					SELECT @NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
					FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
					Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
					From dbo.Tss_EmpDutyDocs
					Where SiEmpDutyDocs = @SiEmpDutyDocs
					--If @Sta_WorkDayState=0
					Insert Into dbo.Tss_EmpDutyCalc
						(
						SiEmpDutyDocs, 
						Dat_DutyDate, 
						Num_DutyUsedMin,
						Num_DutyOverMin
						)
						Values
						(
						@SiEmpDutyDocs,
						@DutyDate,
						@Num_DutyEndedTime-@Num_DutyStartTime,
						0
						)
				End
			End
	Fetch Next From DutyDates
	Into @SiGenDate,@DutyDate
	End
	Close DutyDates
	Deallocate DutyDates

------------------------------------------------درج در محاسبه ماموريت-------------------------------------
		Set @Err_Code=@@Error
		If @Err_Code<>0
			Set @Err_Code=401
		Return
	End
	ELse
		Set @Err_Code=402
End
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
If @FlgInsUpdDel=2
Begin
	Set @Err_Code=0
	If Exists(
	Select StmEmpDutyDocs From dbo.Tss_EmpDutyDocs
	Where (SiEmpDutyDocs=@SiEmpDutyDocs) And (StmEmpDutyDocs=@StmEmpDutyDocs))
	Begin

				delete from dbo.Tss_EmpDutyCalc 
				Where  SiEmpDutyDocs=@SiEmpDutyDocs
		Delete From dbo.Tss_EmpDutyDocs
		Where (SiEmpDutyDocs=@SiEmpDutyDocs)
------------------------------------------------حذف محاسبه ماموريت-------------------------------------
Declare DutyDates Cursor For
	SELECT SiGenDates,Dat_GenShamsiDate FROM Tss_GenDates 
	WHERE (Dat_GenShamsiDate BETWEEN @Dat_DutyStartDate AND @Dat_DutyEndedDate)
	Order By Dat_GenShamsiDate
	Open DutyDates
	Fetch Next From DutyDates
	into @SiGenDate,@DutyDate
	
	While @@Fetch_Status=0
	Begin
		If @Dat_DutyStartDate<@Dat_DutyEndedDate
		Begin
			If @DutyDate=@Dat_DutyStartDate
			Begin
				SELECT @NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
				FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate)
				
				delete from dbo.Tss_EmpDutyCalc 
				Where  SiEmpDutyDocs=@SiEmpDutyDocs
			End
			else
			If (@DutyDate>@Dat_DutyStartDate) And (@DutyDate<@Dat_DutyEndedDate)
			Begin
				SELECT @NumStartOfDay=Num_WorkGroupStartTime,@NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
				FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate)
				
				delete from dbo.Tss_EmpDutyCalc 
				Where  SiEmpDutyDocs=@SiEmpDutyDocs
				End
				else
			If (@DutyDate=@Dat_DutyEndedDate)
			Begin
				SELECT @NumStartOfDay=Num_WorkGroupStartTime,@Sta_WorkDayState=Sta_WorkDayState
				FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate)
				
				delete from dbo.Tss_EmpDutyCalc 
				Where  SiEmpDutyDocs=@SiEmpDutyDocs
			End
			Fetch Next From DutyDates
			Into @SiGenDate,@DutyDate
		End
		Else
		If @Dat_DutyStartDate=@Dat_DutyEndedDate
		Begin
			SELECT @NumStartOfDay=Num_WorkGroupStartTime,@Sta_WorkDayState=Sta_WorkDayState
			FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate)
			
			delete from dbo.Tss_EmpDutyCalc 
			Where  SiEmpDutyDocs=@SiEmpDutyDocs
		End
	Fetch Next From DutyDates
	into @SiGenDate,@DutyDate

	End
	Close DutyDates
	Deallocate DutyDates

------------------------------------------------حذف محاسبه ماموريت-------------------------------------
		Set @Err_Code=@@Error
		If @Err_Code<>0
			Set @Err_Code=4000
	End
	Else
		Set @Err_Code=4001
	Return
End

GO

alter Procedure Tss_EmpUntLeaveDocsIudStp
(
	@Err_Code Int=0 OutPut,
	@SiEmpLeaveDocs Numeric=0 OutPut,
	@SiEmpLeaveTypes numeric=6,
	@SiPubPersonsSpec varchar(8000)='1217',
	@Cod_LeaveDocNumber varchar(50)='10702',
	@Dat_LeaveStartDate varchar(10)='1390/07/01',
	@Dat_LevaEndedDate varchar(10)='1390/07/05',
	@Dat_LeaveRequstDate varchar(10)='1390/07/01',
	@Sta_LeaveDocAcceptStat smallint=1,
	@Sta_LeaveDocRegStat smallint=0,
	@Num_LeaveStartTime int=0,
	@Num_LeaveEndedTime int=0,
	@DesWorkStart varchar(500)='',
	@DesWorkEnd varchar(500)='',
	@StmEmpLeaveDocs TimeStamp=0,
	@SiUser Numeric=1,
	@FlgInsUpdDel SmallInt=1
) As
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------

If @FlgInsUpdDel=0
Begin
declare 
	@PerTable table (SiPer numeric)
declare 
	@SiSelected numeric
Insert Into @PerTable
(SiPer)
select distinct SiSel from dbo.Tss_StdStringSiFindUdf(@SiPubPersonsSpec) order by SiSel
	while exists(select SiPer from @PerTable)
	Begin
		Select top 1 @SiSelected=SiPer from @PerTable order by SiPer

		-------------------------------------------------------------------------------------------------
		-- NEW: if a record already exists for this person with the same
		-- SiEmpLeaveTypes, SiPubPersonsSpec (=@SiSelected), Dat_LeaveStartDate,
		-- Dat_LevaEndedDate, Dat_LeaveRequstDate, Num_LeaveStartTime and
		-- Num_LeaveEndedTime, skip inserting a duplicate for this person and
		-- move on to the next one in @PerTable.
		-------------------------------------------------------------------------------------------------
		if exists
		(
			select 1
			from dbo.Tss_EmpLeaveDocs
			where	SiEmpLeaveTypes		= @SiEmpLeaveTypes
				and	SiPubPersonsSpec	= @SiSelected
				and	Dat_LeaveStartDate	= @Dat_LeaveStartDate
				and	Dat_LevaEndedDate	= @Dat_LevaEndedDate
				and	Dat_LeaveRequstDate	= @Dat_LeaveRequstDate
				and	Num_LeaveStartTime	= @Num_LeaveStartTime
				and	Num_LeaveEndedTime	= @Num_LeaveEndedTime
		)
		Begin
			Delete From @PerTable where SiPer=@SiSelected
			Continue
		End
		-------------------------------------------------------------------------------------------------

--		select @Cod_LeaveDocNumber=isnull(Max(Convert(Int,Cod_LeaveDocNumber)),0)+1 from dbo.Tss_EmpLeaveDocs

		if exists(select 1 from dbo.Tss_EmpLeaveDocs)
			select @Cod_LeaveDocNumber=isnull(Max(Convert(Int,Cod_LeaveDocNumber)),0)+1 from dbo.Tss_EmpLeaveDocs
		Else
			Set @Cod_LeaveDocNumber=1

			Insert Into dbo.Tss_EmpLeaveDocs
			(
				SiEmpLeaveTypes,
				SiPubPersonsSpec,
				Cod_LeaveDocNumber,
				Dat_LeaveStartDate,
				Dat_LevaEndedDate,
				Dat_LeaveRequstDate,
				Sta_LeaveDocAcceptStat,
				Sta_LeaveDocRegStat,
				Num_LeaveStartTime,
				Num_LeaveEndedTime
			)
			Values
			(
				@SiEmpLeaveTypes,
				@SiSelected,
				@Cod_LeaveDocNumber,
				@Dat_LeaveStartDate,
				@Dat_LevaEndedDate,
				@Dat_LeaveRequstDate,
				@Sta_LeaveDocAcceptStat,
				@Sta_LeaveDocRegStat,
				@Num_LeaveStartTime,
				@Num_LeaveEndedTime
			)
			Set @SiEmpLeaveDocs=Scope_Identity()
---------------------------------------------------------------------------------------------------------------------------------------
		if Exists
		(
		SELECT     
			Tss_EmpLeaveTypes.SiEmpLeaveTypes
		FROM         
			Tss_EmpLeaveTypes
		WHERE     
			(Tss_EmpLeaveTypes.Sta_LeaveTypeWorkCalc = 0) and (Tss_EmpLeaveTypes.SiEmpLeaveTypes=@SiEmpLeaveTypes)
		)
		Begin
			Declare @SiGenDates numeric
			Declare mm cursor for 
			SELECT     
				SiGenDates
			FROM         
				Tss_GenDates
			WHERE     
				(Dat_GenShamsiDate between @Dat_LeaveStartDate and @Dat_LevaEndedDate)
			open mm

			Fetch next from mm into @SiGenDates
			
			while @@Fetch_status=0 
			Begin
				UPDATE    
					Tss_EmpWorkDailyCalc
				SET              
					Sta_IsEstelaji = 1
				WHERE     
					(SiGenDates = @SiGenDates) and
					(SiPubPersonsSpec = @SiSelected)
				Fetch next from mm into @SiGenDates
			End
			Close mm
			Deallocate mm
		End
		Else
		Begin
			Declare nn cursor for 
			SELECT     
				SiGenDates
			FROM         
				Tss_GenDates
			WHERE     
				(Dat_GenShamsiDate between @Dat_LeaveStartDate and @Dat_LevaEndedDate)

			open nn

			Fetch next from nn into @SiGenDates
			
			while @@Fetch_status=0 
			Begin
				UPDATE    
					Tss_EmpWorkDailyCalc
				SET              
					Sta_IsEstelaji = 0
				WHERE     
					(SiGenDates = @SiGenDates) and
					(SiPubPersonsSpec = @SiSelected)
				Fetch next from nn into @SiGenDates
			End
			Close nn
			Deallocate nn
		End
---------------------------------------------------------------------------------------------------------------------------------------
		------------------------------------------------درج در محاسبه مرخصي------------------------------------------------------
			Declare 
				@SiGenDate numeric,
				@LeaveDate VarChar(10),
				@NumEndOfDay Numeric, 
				@NumStartOfDay Numeric,
				@Sta_WorkDayState SmallInt,
				@LeaveAmt numeric,
				@SiEmpWorkGroups numeric

			set @LeaveAmt=0			

			Declare LeaveDates Cursor For
				SELECT SiGenDates,Dat_GenShamsiDate FROM Tss_GenDates 
				WHERE (Dat_GenShamsiDate BETWEEN @Dat_LeaveStartDate AND @Dat_LevaEndedDate)
				Order By Dat_GenShamsiDate

			Open LeaveDates

			Fetch Next From LeaveDates	into 
				@SiGenDate,
				@LeaveDate

				print 'من اينجاممممممممممممممممم'
			
			While @@Fetch_Status=0
			Begin
				select @SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@LeaveDate,convert(numeric,@SiSelected))
				SELECT @Sta_WorkDayState=Sta_WorkDayState FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) AND (SiEmpWorkGroups = @SiEmpWorkGroups)
				Select @LeaveAmt = dbo.Tss_EmpFindLeaveAmt(@SiEmpLeaveDocs , @SiSelected , @LeaveDate )
				if isnull(@LeaveAmt,0)>0
				Begin
					if exists(SELECT SiEmpLeaveCalc FROM Tss_EmpLeaveCalc WHERE (SiEmpLeaveDocs  = @SiEmpLeaveDocs ) and (Dat_LeaveDate=@LeaveDate))
					Begin
						If (@Sta_WorkDayState = 0)
						Update dbo.Tss_EmpLeaveCalc Set
							SiEmpLeaveDocs=@SiEmpLeaveDocs, 
							Dat_LeaveDate=@LeaveDate, 
							Num_LeaveUsedMin=@LeaveAmt
						Where Dat_LeaveDate=@LeaveDate And SiEmpLeaveDocs=@SiEmpLeaveDocs
						else
						Update dbo.Tss_EmpLeaveCalc Set
							SiEmpLeaveDocs=@SiEmpLeaveDocs, 
							Dat_LeaveDate=@LeaveDate, 
							Num_LeaveUsedMin=0
						Where Dat_LeaveDate=@LeaveDate And SiEmpLeaveDocs=@SiEmpLeaveDocs
					End
					Else					
					Insert Into dbo.Tss_EmpLeaveCalc
						(SiEmpLeaveDocs,Dat_LeaveDate,Num_LeaveUsedMin) Values (@SiEmpLeaveDocs,@LeaveDate,@LeaveAmt)
				End
				Fetch Next From LeaveDates
				Into @SiGenDate,@LeaveDate
			End
			Close LeaveDates
			Deallocate LeaveDates
		
		------------------------------------------------درج در محاسبه مرخصي------------------------------------------------------
			If IsNull(@SiEmpLeaveDocs,0)=0
			Begin
				Set @SiEmpLeaveDocs=0
				Set @Err_Code=400
			End
			
		Delete From @PerTable where SiPer=@SiSelected
	End
End
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
If @FlgInsUpdDel=1
Begin
	Set @Err_Code=0
	If Exists(
	Select StmEmpLeaveDocs From dbo.Tss_EmpLeaveDocs
	Where (SiEmpLeaveDocs=@SiEmpLeaveDocs)) -- And (StmEmpLeaveDocs=@StmEmpLeaveDocs))
	Begin
		Update dbo.Tss_EmpLeaveDocs Set
			SiEmpLeaveTypes=@SiEmpLeaveTypes,
			SiPubPersonsSpec=convert(numeric,@SiPubPersonsSpec),
			Cod_LeaveDocNumber=@Cod_LeaveDocNumber,
			Dat_LeaveStartDate=@Dat_LeaveStartDate,
			Dat_LevaEndedDate=@Dat_LevaEndedDate,
			Dat_LeaveRequstDate=@Dat_LeaveRequstDate,
			Sta_LeaveDocAcceptStat=@Sta_LeaveDocAcceptStat,
			Sta_LeaveDocRegStat=@Sta_LeaveDocRegStat,
			Num_LeaveStartTime=@Num_LeaveStartTime,
			Num_LeaveEndedTime=@Num_LeaveEndedTime
		Where (SiEmpLeaveDocs=@SiEmpLeaveDocs)

---------------------------------------------------------------------------------------------------------------------------------------
/*		if Exists
		(
		SELECT     
			Tss_EmpLeaveTypes.SiEmpLeaveTypes
		FROM         
			Tss_EmpLeaveTypes
		WHERE     
			(Tss_EmpLeaveTypes.Sta_LeaveTypeWorkCalc = 0) and (Tss_EmpLeaveTypes.SiEmpLeaveTypes=@SiEmpLeaveTypes)
		)
		Begin
--print 'ok'
			Declare mm cursor for 
			SELECT     
				SiGenDates
			FROM         
				Tss_GenDates
			WHERE     
				(Dat_GenShamsiDate between @Dat_LeaveStartDate and @Dat_LevaEndedDate)

			open mm

			Fetch next from mm into @SiGenDates
			
			while @@Fetch_status=0 
			Begin
				UPDATE    
					Tss_EmpWorkDailyCalc
				SET              
					Sta_IsEstelaji = 1
				WHERE     
					(SiGenDates = @SiGenDates) and
					(SiPubPersonsSpec = convert(numeric,@SiPubPersonsSpec))
				Fetch next from mm into @SiGenDates
			End
			Close mm
			Deallocate mm
		End
		Else
		Begin
print 'ok'
			Declare nn cursor for 
			SELECT     
				SiGenDates
			FROM         
				Tss_GenDates
			WHERE     
				(Dat_GenShamsiDate between @Dat_LeaveStartDate and @Dat_LevaEndedDate)

			open nn

			Fetch next from nn into @SiGenDates
			
			while @@Fetch_status=0 
			Begin
				UPDATE    
					Tss_EmpWorkDailyCalc
				SET              
					Sta_IsEstelaji = 0
				WHERE     
					(SiGenDates = @SiGenDates) and
					(SiPubPersonsSpec = convert(numeric,@SiPubPersonsSpec))
				Fetch next from nn into @SiGenDates
			End
			Close nn
			Deallocate nn
		End*/
---------------------------------------------------------------------------------------------------------------------------------------
		------------------------------------------------درج در محاسبه مرخصي------------------------------------------------------
			set @LeaveAmt=0			

			Declare LeaveDates Cursor For
				SELECT SiGenDates,Dat_GenShamsiDate FROM Tss_GenDates 
				WHERE (Dat_GenShamsiDate BETWEEN @Dat_LeaveStartDate AND @Dat_LevaEndedDate)
				Order By Dat_GenShamsiDate

			Open LeaveDates

			Fetch Next From LeaveDates	into 
				@SiGenDate,
				@LeaveDate
			
			While @@Fetch_Status=0
			Begin
				select @SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@LeaveDate,convert(numeric,@SiPubPersonsSpec))
				SELECT @Sta_WorkDayState=Sta_WorkDayState FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) AND (SiEmpWorkGroups = @SiEmpWorkGroups)
				Select @LeaveAmt = dbo.Tss_EmpFindLeaveAmt(@SiEmpLeaveDocs , convert(numeric,@SiPubPersonsSpec) , @LeaveDate )
				if isnull(@LeaveAmt,0)>0
				Begin
					if exists(SELECT SiEmpLeaveCalc FROM Tss_EmpLeaveCalc WHERE (SiEmpLeaveDocs  = @SiEmpLeaveDocs ) and (Dat_LeaveDate=@LeaveDate))
					Begin
						If (@Sta_WorkDayState = 0)
						Update dbo.Tss_EmpLeaveCalc Set
							SiEmpLeaveDocs=@SiEmpLeaveDocs, 
							Dat_LeaveDate=@LeaveDate, 
							Num_LeaveUsedMin=@LeaveAmt
						Where Dat_LeaveDate=@LeaveDate And SiEmpLeaveDocs=@SiEmpLeaveDocs
						else
						Update dbo.Tss_EmpLeaveCalc Set
							SiEmpLeaveDocs=@SiEmpLeaveDocs, 
							Dat_LeaveDate=@LeaveDate, 
							Num_LeaveUsedMin=0
						Where Dat_LeaveDate=@LeaveDate And SiEmpLeaveDocs=@SiEmpLeaveDocs
					End
					Else					
					Insert Into dbo.Tss_EmpLeaveCalc
						(SiEmpLeaveDocs,Dat_LeaveDate,Num_LeaveUsedMin) Values (@SiEmpLeaveDocs,@LeaveDate,@LeaveAmt)
				End
				Fetch Next From LeaveDates
				Into @SiGenDate,@LeaveDate
			End
			Close LeaveDates
			Deallocate LeaveDates
		------------------------------------------------درج در محاسبه مرخصي------------------------------------------------------
		Set @Err_Code=@@Error
		If @Err_Code<>0
			Set @Err_Code=401
		Return
	End
	ELse
		Set @Err_Code=402
End
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
If @FlgInsUpdDel=2
Begin
	Set @Err_Code=0
	If Exists(
	Select StmEmpLeaveDocs From dbo.Tss_EmpLeaveDocs
	Where (SiEmpLeaveDocs=@SiEmpLeaveDocs) And (StmEmpLeaveDocs=@StmEmpLeaveDocs))
	Begin

				delete from dbo.Tss_EmpLeaveCalc 
				Where  SiEmpLeaveDocs=@SiEmpLeaveDocs
		Delete From dbo.Tss_EmpLeaveDocs
		Where (SiEmpLeaveDocs=@SiEmpLeaveDocs)
------------------------------------------------حذف محاسبه مرخصي-------------------------------------
	Declare LeaveDates Cursor For
	SELECT SiGenDates,Dat_GenShamsiDate FROM Tss_GenDates 
	WHERE (Dat_GenShamsiDate BETWEEN @Dat_LeaveStartDate AND @Dat_LevaEndedDate)
	Order By Dat_GenShamsiDate
	Open LeaveDates
	Fetch Next From LeaveDates
	into @SiGenDate,@LeaveDate
	
	While @@Fetch_Status=0
	Begin
		If @Dat_LeaveStartDate<@Dat_LevaEndedDate
		Begin
			If @LeaveDate=@Dat_LeaveStartDate
			Begin
				SELECT @NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
				FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate)
				If (@Sta_WorkDayState = 0)
				delete from dbo.Tss_EmpLeaveCalc 
				Where  SiEmpLeaveDocs=@SiEmpLeaveDocs
			End
			else
			If (@LeaveDate>@Dat_LeaveStartDate) And (@LeaveDate<@Dat_LevaEndedDate)
			Begin
				SELECT @NumStartOfDay=Num_WorkGroupStartTime,@NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
				FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate)
				If (@Sta_WorkDayState = 0)
				delete from dbo.Tss_EmpLeaveCalc 
				Where  SiEmpLeaveDocs=@SiEmpLeaveDocs
				End
				else
			If (@LeaveDate=@Dat_LevaEndedDate)
			Begin
				SELECT @NumStartOfDay=Num_WorkGroupStartTime,@Sta_WorkDayState=Sta_WorkDayState
				FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate)
				If (@Sta_WorkDayState = 0)
				delete from dbo.Tss_EmpLeaveCalc 
				Where  SiEmpLeaveDocs=@SiEmpLeaveDocs
			End
			Fetch Next From LeaveDates
			Into @SiGenDate,@LeaveDate
		End
		Else
		If @Dat_LeaveStartDate=@Dat_LevaEndedDate
		Begin
			SELECT @NumStartOfDay=Num_WorkGroupStartTime,@Sta_WorkDayState=Sta_WorkDayState
			FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate)
			If (@Sta_WorkDayState = 0)
			delete from dbo.Tss_EmpLeaveCalc 
			Where  SiEmpLeaveDocs=@SiEmpLeaveDocs
		End
	Fetch Next From LeaveDates
	into @SiGenDate,@LeaveDate

	End
	Close LeaveDates
	Deallocate LeaveDates

------------------------------------------------حذف محاسبه مرخصي-------------------------------------
		Set @Err_Code=@@Error
		If @Err_Code<>0
			Set @Err_Code=4000
	End
	Else
		Set @Err_Code=4001
	Return
End

GO

alter Procedure Tss_EmpUntDutyDocsIudStp
(
	@Err_Code Int OutPut,
	@SiEmpDutyDocs Numeric OutPut,
	@SiEmpDutyTypes numeric=null,
	@SiPubPersonsSpec numeric=null,
	@Num_DutyDocNumber numeric=0,
	@Dat_DutyStartDate varchar(10)='',
	@Dat_DutyEndedDate varchar(10)='',
	@Dat_DutyRequestDate varchar(10)='',
	@Des_DutyDesc varchar(8000)='',
	@Sta_DutyAcceptStat smallint=1,
	@Sta_DutyRegStat smallint=1,
	@Num_DutyStartTime int=0,
	@Num_DutyEndedTime int=0,
	@Num_OverDutyNormal int=0,
	@Num_OverDutyHoliday int=0,
	@StmEmpDutyDocs TimeStamp=0,
	@SiUser Numeric,
	@FlgInsUpdDel SmallInt
) As

If @FlgInsUpdDel=0
Begin
-------------------------------------------------------------------------------------------------
-- NEW: if a record already exists with the same SiEmpDutyTypes, SiPubPersonsSpec,
-- Dat_DutyStartDate, Dat_DutyEndedDate, Dat_DutyRequestDate, Sta_DutyAcceptStat,
-- Sta_DutyRegStat, Num_DutyStartTime, Num_DutyEndedTime, Num_OverDutyNormal and
-- Num_OverDutyHoliday, skip the insert (and the duty-calc population that
-- depends on it) instead of creating a duplicate row.
-------------------------------------------------------------------------------------------------
If Exists
(
	select 1
	from dbo.Tss_EmpDutyDocs
	where	SiEmpDutyTypes		= @SiEmpDutyTypes
		and	SiPubPersonsSpec	= @SiPubPersonsSpec
		and	Dat_DutyStartDate	= @Dat_DutyStartDate
		and	Dat_DutyEndedDate	= @Dat_DutyEndedDate
		and	Dat_DutyRequestDate	= @Dat_DutyRequestDate
		and	Sta_DutyAcceptStat	= @Sta_DutyAcceptStat
		and	Sta_DutyRegStat		= @Sta_DutyRegStat
		and	Num_DutyStartTime	= @Num_DutyStartTime
		and	Num_DutyEndedTime	= @Num_DutyEndedTime
		and	Num_OverDutyNormal	= @Num_OverDutyNormal
		and	Num_OverDutyHoliday	= @Num_OverDutyHoliday
)
Begin
	Set @SiEmpDutyDocs=0
	Return
End
-------------------------------------------------------------------------------------------------

if exists(select 1 from dbo.Tss_EmpDutyDocs)
	select @Num_DutyDocNumber=isnull(Max(Num_DutyDocNumber),0)+1 from dbo.Tss_EmpDutyDocs
Else
	Set @Num_DutyDocNumber=1
 
	Insert Into dbo.Tss_EmpDutyDocs
	(
		SiEmpDutyTypes,
		SiPubPersonsSpec,
		Num_DutyDocNumber,
		Dat_DutyStartDate,
		Dat_DutyEndedDate,
		Num_DutyStartTime,
		Num_DutyEndedTime,
		Num_OverDutyNormal,
		Num_OverDutyHoliday,
		Dat_DutyRequestDate,
		Des_DutyDesc,
		Sta_DutyAcceptStat,
		Sta_DutyRegStat
	)
	Values
	(
		@SiEmpDutyTypes,
		@SiPubPersonsSpec,
		@Num_DutyDocNumber,
		@Dat_DutyStartDate,
		@Dat_DutyEndedDate,
		@Num_DutyStartTime,
		@Num_DutyEndedTime,
		@Num_OverDutyNormal,
		@Num_OverDutyHoliday,
		@Dat_DutyRequestDate,
		@Des_DutyDesc,
		@Sta_DutyAcceptStat,
		@Sta_DutyRegStat
	)

	Set @SiEmpDutyDocs=Scope_Identity()

------------------------------------------------درج در محاسبه ماموريت------------------------------------------------------
	Declare 
		@SiGenDate numeric,
		@DutyDate VarChar(10),
		@NumEndOfDay Numeric, 
		@NumStartOfDay Numeric,
		@Sta_WorkDayState SmallInt
	Declare DutyDates Cursor For
	SELECT SiGenDates,Dat_GenShamsiDate FROM Tss_GenDates 
	WHERE (Dat_GenShamsiDate BETWEEN @Dat_DutyStartDate AND @Dat_DutyEndedDate)
	Order By Dat_GenShamsiDate
	Open DutyDates
	Fetch Next From DutyDates
	into @SiGenDate,@DutyDate
	
	While @@Fetch_Status=0
	Begin
----------------------------- Start Of While Begin------------------------------
		If @Dat_DutyStartDate<@Dat_DutyEndedDate	 
      Begin	
		--------------------Start Of @DutyDate=@Dat_DutyStartDate Begin---------
			If @DutyDate=@Dat_DutyStartDate
				Begin
					SELECT @NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
					FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
					Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
					From dbo.Tss_EmpDutyDocs
					Where SiEmpDutyDocs = @SiEmpDutyDocs
					
					Insert Into dbo.Tss_EmpDutyCalc
						(
						SiEmpDutyDocs, 
						Dat_DutyDate, 
						Num_DutyUsedMin,
						Num_DutyOverMin
						)
						Values
						(
						@SiEmpDutyDocs,
						@DutyDate,
						@NumEndOfDay-@Num_DutyStartTime,
						@Num_OverDutyNormal*60+@Num_OverDutyHoliday*60
						)
				End
				else
				If (@DutyDate>@Dat_DutyStartDate) And (@DutyDate<@Dat_DutyEndedDate)
					Begin
						SELECT @NumStartOfDay=Num_WorkGroupStartTime,@NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
						FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
						Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
						From dbo.Tss_EmpDutyDocs
						Where SiEmpDutyDocs = @SiEmpDutyDocs
						
						Insert Into dbo.Tss_EmpDutyCalc
						(
						SiEmpDutyDocs, 
						Dat_DutyDate, 
						Num_DutyUsedMin,
						Num_DutyOverMin
						)
						Values
						(
						@SiEmpDutyDocs,
						@DutyDate,
						@NumEndOfDay-@NumStartOfDay,
						0
						)
					End
					else
					If (@DutyDate=@Dat_DutyEndedDate)
						Begin
							SELECT @NumStartOfDay=Num_WorkGroupStartTime,@Sta_WorkDayState=Sta_WorkDayState
							FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
							Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
							From dbo.Tss_EmpDutyDocs
							Where SiEmpDutyDocs = @SiEmpDutyDocs
							
							Insert Into dbo.Tss_EmpDutyCalc
								(
								SiEmpDutyDocs, 
								Dat_DutyDate, 
								Num_DutyUsedMin,
								Num_DutyOverMin
								)
								Values
								(
								@SiEmpDutyDocs,
								@DutyDate,
								@Num_DutyEndedTime-@NumStartOfDay,
								0
								)
						End
			-----------------End Of @DutyDate=@Dat_DutyStartDate Begin---------
      End
		Else
			If (@Dat_DutyStartDate=@Dat_DutyEndedDate)	
				Begin
					SELECT @NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
					FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
					Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
					From dbo.Tss_EmpDutyDocs
					Where SiEmpDutyDocs = @SiEmpDutyDocs
					--If @Sta_WorkDayState=0
					Insert Into dbo.Tss_EmpDutyCalc
						(
						SiEmpDutyDocs, 
						Dat_DutyDate, 
						Num_DutyUsedMin,
						Num_DutyOverMin
						)
						Values
						(
						@SiEmpDutyDocs,
						@DutyDate,
						@Num_DutyEndedTime-@Num_DutyStartTime,
						0
						)
				End
		Fetch Next From DutyDates
		Into @SiGenDate,@DutyDate
----------------------------- End Of While Begin------------------------------
	End
--End
	Close DutyDates
	Deallocate DutyDates

------------------------------------------------درج در محاسبه ماموريت------------------------------------------------------

	If IsNull(@SiEmpDutyDocs,0)=0
	Begin
		Set @SiEmpDutyDocs=0
		Set @Err_Code=400
	End
	Return
End
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
If @FlgInsUpdDel=1
Begin
	Set @Err_Code=0
	If Exists(
	Select StmEmpDutyDocs From dbo.Tss_EmpDutyDocs
	Where (SiEmpDutyDocs=@SiEmpDutyDocs) And (StmEmpDutyDocs=@StmEmpDutyDocs))
	Begin
		Update dbo.Tss_EmpDutyDocs Set
			SiEmpDutyTypes=@SiEmpDutyTypes,
			SiPubPersonsSpec=@SiPubPersonsSpec,
			Num_DutyDocNumber=@Num_DutyDocNumber,
			Dat_DutyStartDate=@Dat_DutyStartDate,
			Dat_DutyEndedDate=@Dat_DutyEndedDate,
			Dat_DutyRequestDate=@Dat_DutyRequestDate,
			Des_DutyDesc=@Des_DutyDesc,
			Sta_DutyAcceptStat=@Sta_DutyAcceptStat,
			Sta_DutyRegStat=@Sta_DutyRegStat,
			Num_DutyStartTime=@Num_DutyStartTime,
			Num_DutyEndedTime=@Num_DutyEndedTime,
			Num_OverDutyNormal=@Num_OverDutyNormal,
			Num_OverDutyHoliday=@Num_OverDutyHoliday
		Where (SiEmpDutyDocs=@SiEmpDutyDocs)

------------------------------------------------درج در محاسبه ماموريت-------------------------------------
	Declare DutyDates Cursor For
	SELECT SiGenDates,Dat_GenShamsiDate FROM Tss_GenDates 
	WHERE (Dat_GenShamsiDate BETWEEN @Dat_DutyStartDate AND @Dat_DutyEndedDate)
	Order By Dat_GenShamsiDate
	Open DutyDates
	Fetch Next From DutyDates
	into @SiGenDate,@DutyDate
	
	While @@Fetch_Status=0
	Begin
		If @Dat_DutyStartDate<@Dat_DutyEndedDate	 
		Begin	
			If @DutyDate=@Dat_DutyStartDate
				Begin
					SELECT @NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
					FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
					Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
					From dbo.Tss_EmpDutyDocs
					Where SiEmpDutyDocs = @SiEmpDutyDocs

					if exists(SELECT 1 FROM Tss_EmpDutyCalc WHERE (SiEmpDutyDocs = @SiEmpDutyDocs))
					Update dbo.Tss_EmpDutyCalc Set
						SiEmpDutyDocs=@SiEmpDutyDocs, 
						Dat_DutyDate=@DutyDate, 
						Num_DutyUsedMin=@NumEndOfDay-@Num_DutyStartTime,
						Num_DutyOverMin=@Num_OverDutyNormal*60+@Num_OverDutyHoliday*60
					Where Dat_DutyDate=@DutyDate And SiEmpDutyDocs=@SiEmpDutyDocs
					Else
					Begin
						SELECT @NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
						FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
						Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
						From dbo.Tss_EmpDutyDocs
						Where SiEmpDutyDocs = @SiEmpDutyDocs
						
						Insert Into dbo.Tss_EmpDutyCalc
							(
							SiEmpDutyDocs, 
							Dat_DutyDate, 
							Num_DutyUsedMin,
							Num_DutyOverMin
							)
							Values
							(
							@SiEmpDutyDocs,
							@DutyDate,
							@NumEndOfDay-@Num_DutyStartTime,
							@Num_OverDutyNormal*60+@Num_OverDutyHoliday*60
							)
					End
				End
				else
				If (@DutyDate>@Dat_DutyStartDate) And (@DutyDate<@Dat_DutyEndedDate)
					Begin
						SELECT @NumStartOfDay=Num_WorkGroupStartTime,@NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
						FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
						Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
						From dbo.Tss_EmpDutyDocs
						Where SiEmpDutyDocs = @SiEmpDutyDocs
						
						if exists(SELECT 1 FROM Tss_EmpDutyCalc WHERE (SiEmpDutyDocs = @SiEmpDutyDocs))
						Update dbo.Tss_EmpDutyCalc Set
							SiEmpDutyDocs=@SiEmpDutyDocs, 
							Dat_DutyDate=@DutyDate, 
							Num_DutyUsedMin=@NumEndOfDay-@NumStartOfDay,
							Num_DutyOverMin=0
						Where Dat_DutyDate=@DutyDate And SiEmpDutyDocs=@SiEmpDutyDocs
						Else
						Begin
							SELECT @NumStartOfDay=Num_WorkGroupStartTime,@NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
							FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
							Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
							From dbo.Tss_EmpDutyDocs
							Where SiEmpDutyDocs = @SiEmpDutyDocs
							
							Insert Into dbo.Tss_EmpDutyCalc
							(
							SiEmpDutyDocs, 
							Dat_DutyDate, 
							Num_DutyUsedMin,
							Num_DutyOverMin
							)
							Values
							(
							@SiEmpDutyDocs,
							@DutyDate,
							@NumEndOfDay-@NumStartOfDay,
							0
							)
						End

					End
					else
					If (@DutyDate=@Dat_DutyEndedDate)
						Begin
							SELECT @NumStartOfDay=Num_WorkGroupStartTime,@Sta_WorkDayState=Sta_WorkDayState
							FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
							Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
							From dbo.Tss_EmpDutyDocs
							Where SiEmpDutyDocs = @SiEmpDutyDocs
							
							if exists(SELECT 1 FROM Tss_EmpDutyCalc WHERE (SiEmpDutyDocs = @SiEmpDutyDocs))
							Update dbo.Tss_EmpDutyCalc Set
								SiEmpDutyDocs=@SiEmpDutyDocs, 
								Dat_DutyDate=@DutyDate, 
								Num_DutyUsedMin=@Num_DutyEndedTime-@NumStartOfDay,
								Num_DutyOverMin=0
							Where Dat_DutyDate=@DutyDate And SiEmpDutyDocs=@SiEmpDutyDocs
							Else
							Begin
								SELECT @NumStartOfDay=Num_WorkGroupStartTime,@Sta_WorkDayState=Sta_WorkDayState
								FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
								Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
								From dbo.Tss_EmpDutyDocs
								Where SiEmpDutyDocs = @SiEmpDutyDocs
								
								Insert Into dbo.Tss_EmpDutyCalc
									(
									SiEmpDutyDocs, 
									Dat_DutyDate, 
									Num_DutyUsedMin,
									Num_DutyOverMin
									)
									Values
									(
									@SiEmpDutyDocs,
									@DutyDate,
									@Num_DutyEndedTime-@NumStartOfDay,
									0
									)
							End

						End
		End
		Else 
		If (@Dat_DutyStartDate=@Dat_DutyEndedDate) 
			Begin
				SELECT @NumStartOfDay=Num_WorkGroupStartTime,@Sta_WorkDayState=Sta_WorkDayState
				FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
				Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
				From dbo.Tss_EmpDutyDocs
				Where SiEmpDutyDocs = @SiEmpDutyDocs
				
				if exists(SELECT SiEmpDutyDocs FROM Tss_EmpDutyCalc WHERE (SiEmpDutyDocs = @SiEmpDutyDocs))
				Update dbo.Tss_EmpDutyCalc Set
					SiEmpDutyDocs=@SiEmpDutyDocs, 
					Dat_DutyDate=@DutyDate, 
					Num_DutyUsedMin=@Num_DutyEndedTime-@Num_DutyStartTime,
					Num_DutyOverMin=0
				Where Dat_DutyDate=@DutyDate And SiEmpDutyDocs=@SiEmpDutyDocs
				Else
				Begin
					SELECT @NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
					FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@DutyDate,@SiPubPersonsSpec))
					Select @Num_OverDutyNormal= Num_OverDutyNormal,@Num_OverDutyHoliday= Num_OverDutyHoliday 
					From dbo.Tss_EmpDutyDocs
					Where SiEmpDutyDocs = @SiEmpDutyDocs
					--If @Sta_WorkDayState=0
					Insert Into dbo.Tss_EmpDutyCalc
						(
						SiEmpDutyDocs, 
						Dat_DutyDate, 
						Num_DutyUsedMin,
						Num_DutyOverMin
						)
						Values
						(
						@SiEmpDutyDocs,
						@DutyDate,
						@Num_DutyEndedTime-@Num_DutyStartTime,
						0
						)
				End
			End
	Fetch Next From DutyDates
	Into @SiGenDate,@DutyDate
	End
	Close DutyDates
	Deallocate DutyDates

------------------------------------------------درج در محاسبه ماموريت-------------------------------------
		Set @Err_Code=@@Error
		If @Err_Code<>0
			Set @Err_Code=401
		Return
	End
	ELse
		Set @Err_Code=402
End
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------
If @FlgInsUpdDel=2
Begin
	Set @Err_Code=0
	If Exists(
	Select StmEmpDutyDocs From dbo.Tss_EmpDutyDocs
	Where (SiEmpDutyDocs=@SiEmpDutyDocs) And (StmEmpDutyDocs=@StmEmpDutyDocs))
	Begin

				delete from dbo.Tss_EmpDutyCalc 
				Where  SiEmpDutyDocs=@SiEmpDutyDocs
		Delete From dbo.Tss_EmpDutyDocs
		Where (SiEmpDutyDocs=@SiEmpDutyDocs)
------------------------------------------------حذف محاسبه ماموريت-------------------------------------
Declare DutyDates Cursor For
	SELECT SiGenDates,Dat_GenShamsiDate FROM Tss_GenDates 
	WHERE (Dat_GenShamsiDate BETWEEN @Dat_DutyStartDate AND @Dat_DutyEndedDate)
	Order By Dat_GenShamsiDate
	Open DutyDates
	Fetch Next From DutyDates
	into @SiGenDate,@DutyDate
	
	While @@Fetch_Status=0
	Begin
		If @Dat_DutyStartDate<@Dat_DutyEndedDate
		Begin
			If @DutyDate=@Dat_DutyStartDate
			Begin
				SELECT @NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
				FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate)
				
				delete from dbo.Tss_EmpDutyCalc 
				Where  SiEmpDutyDocs=@SiEmpDutyDocs
			End
			else
			If (@DutyDate>@Dat_DutyStartDate) And (@DutyDate<@Dat_DutyEndedDate)
			Begin
				SELECT @NumStartOfDay=Num_WorkGroupStartTime,@NumEndOfDay=(Num_WorkGroupStartTime+Num_WorkGroupLenTime),@Sta_WorkDayState=Sta_WorkDayState
				FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate)
				
				delete from dbo.Tss_EmpDutyCalc 
				Where  SiEmpDutyDocs=@SiEmpDutyDocs
				End
				else
			If (@DutyDate=@Dat_DutyEndedDate)
			Begin
				SELECT @NumStartOfDay=Num_WorkGroupStartTime,@Sta_WorkDayState=Sta_WorkDayState
				FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate)
				
				delete from dbo.Tss_EmpDutyCalc 
				Where  SiEmpDutyDocs=@SiEmpDutyDocs
			End
			Fetch Next From DutyDates
			Into @SiGenDate,@DutyDate
		End
		Else
		If @Dat_DutyStartDate=@Dat_DutyEndedDate
		Begin
			SELECT @NumStartOfDay=Num_WorkGroupStartTime,@Sta_WorkDayState=Sta_WorkDayState
			FROM Tss_EmpWorkTime	WHERE (SiGenDates = @SiGenDate)
			
			delete from dbo.Tss_EmpDutyCalc 
			Where  SiEmpDutyDocs=@SiEmpDutyDocs
		End
	Fetch Next From DutyDates
	into @SiGenDate,@DutyDate

	End
	Close DutyDates
	Deallocate DutyDates

------------------------------------------------حذف محاسبه ماموريت-------------------------------------
		Set @Err_Code=@@Error
		If @Err_Code<>0
			Set @Err_Code=4000
	End
	Else
		Set @Err_Code=4001
	Return
End

GO

alter Procedure dbo.Tss_EmpUntOverTimeAllowDocIudStp
(
	@Err_Code Int OutPut,
	@SiEmpOverTimeAllowDoc Numeric OutPut,
	@SiPubPersonsSpec varchar(8000)='6,11',
	@Dat_OverTimeDocStartDate varchar(10)='',
	@Dat_OverTimeDocEndedDate varchar(10)='',
	@Num_ValidOverBeforDoc int=0,
	@Num_ValidOverAfterDoc int=0,
	@Num_ValidOverInHoliday int=0,
	@Num_OverStartTime int=0,
	@Num_OverEndTime int=0,
	@StmEmpOverTimeAllowDoc TimeStamp=0,
	@DesWorkStart varchar(50)='',
	@DesWorkEnd varchar(50)='',
	@SiUser Numeric,
	@FlgInsUpdDel SmallInt
) As
If @FlgInsUpdDel=0
Begin
	declare 
		@PerTable table (SiPer numeric)
	declare 
		@SiSelected numeric
	Insert Into @PerTable
	(SiPer)
	select distinct SiSel from dbo.Tss_StdStringSiFindUdf(@SiPubPersonsSpec) order by SiSel
	while exists(select SiPer from @PerTable)
	Begin
		Select top 1 @SiSelected=SiPer from @PerTable order by SiPer

		-------------------------------------------------------------------------------------------------
		-- NEW: if a record already exists for this person with the same
		-- SiPubPersonsSpec (=@SiSelected), Dat_OverTimeDocStartDate,
		-- Dat_OverTimeDocEndedDate, Num_ValidOverBeforDoc, Num_ValidOverAfterDoc,
		-- Num_ValidOverInHoliday, Num_OverStartTime and Num_OverEndTime, skip
		-- inserting a duplicate for this person and move on to the next one.
		-------------------------------------------------------------------------------------------------
		if exists
		(
			select 1
			from dbo.Tss_EmpOverTimeAllowDoc
			where	SiPubPersonsSpec			= @SiSelected
				and	Dat_OverTimeDocStartDate	= @Dat_OverTimeDocStartDate
				and	Dat_OverTimeDocEndedDate	= @Dat_OverTimeDocEndedDate
				and	Num_ValidOverBeforDoc		= @Num_ValidOverBeforDoc
				and	Num_ValidOverAfterDoc		= @Num_ValidOverAfterDoc
				and	Num_ValidOverInHoliday		= @Num_ValidOverInHoliday
				and	Num_OverStartTime			= @Num_OverStartTime
				and	Num_OverEndTime				= @Num_OverEndTime
		)
		Begin
			Delete From @PerTable where SiPer=@SiSelected
			Continue
		End
		-------------------------------------------------------------------------------------------------

		Insert Into dbo.Tss_EmpOverTimeAllowDoc
		(
			SiPubPersonsSpec,
			Dat_OverTimeDocStartDate,
			Dat_OverTimeDocEndedDate,
			Num_ValidOverBeforDoc,
			Num_ValidOverAfterDoc,
			Num_ValidOverInHoliday,
			Num_OverStartTime,
			Num_OverEndTime
		)
		Values
		(
			@SiSelected,
			@Dat_OverTimeDocStartDate,
			@Dat_OverTimeDocEndedDate,
			@Num_ValidOverBeforDoc,
			@Num_ValidOverAfterDoc,
			@Num_ValidOverInHoliday,
			@Num_OverStartTime,
			@Num_OverEndTime
		)
		Set @SiEmpOverTimeAllowDoc=Scope_Identity()

		If IsNull(@SiEmpOverTimeAllowDoc,0)=0
		Begin
			Set @SiEmpOverTimeAllowDoc=0
			
			Set @Err_Code=400
		End
		Else
		Begin
			------------------------------------------------درج در محاسبه اضافه‌كاري------------------------------------------------------
			-- NEW: work out, from this person's work-time record on the
			-- overtime date, how many minutes of the requested overtime
			-- window [@Num_OverStartTime, @Num_OverEndTime] fall before
			-- work starts, after work ends, or (when the day is not a
			-- normal work day, i.e. Sta_WorkDayState <> 0) the whole
			-- window counts as holiday overtime.
			--------------------------------------------------------------------------------------------------------------------------
			Declare 
				@SiGenDate numeric,
				@SiEmpWorkGroups numeric,
				@Sta_WorkDayState smallint,
				@NumWorkStart numeric,
				@NumWorkEnd numeric,
				@CalcValidOverBeforDoc int,
				@CalcValidOverAfterDoc int,
				@CalcValidOverInHoliday int

			Select @SiGenDate = SiGenDates
			From dbo.Tss_GenDates
			Where Dat_GenShamsiDate = @Dat_OverTimeDocStartDate

			Select @SiEmpWorkGroups = dbo.Tss_EmpFindWorkGroupSi_Udf(@Dat_OverTimeDocStartDate, @SiSelected)

			Select
				@Sta_WorkDayState = Sta_WorkDayState,
				@NumWorkStart = Num_WorkGroupStartTime,
				@NumWorkEnd = Num_WorkGroupStartTime + Num_WorkGroupLenTime
			From dbo.Tss_EmpWorkTime
			Where (SiGenDates = @SiGenDate) and (SiEmpWorkGroups = @SiEmpWorkGroups)

			If IsNull(@Sta_WorkDayState,0) <> 0
			Begin
				-- not a normal work day: the whole requested window is holiday overtime
				Set @CalcValidOverInHoliday = @Num_OverEndTime - @Num_OverStartTime
				Set @CalcValidOverBeforDoc = 0
				Set @CalcValidOverAfterDoc = 0
			End
			Else
			Begin
				Set @CalcValidOverInHoliday = 0

				-- minutes of the requested window that fall before work start
				Set @CalcValidOverBeforDoc =
					Case When @Num_OverStartTime < @NumWorkStart
						Then (Case When @Num_OverEndTime < @NumWorkStart Then @Num_OverEndTime Else @NumWorkStart End) - @Num_OverStartTime
						Else 0
					End

				-- minutes of the requested window that fall after work end
				Set @CalcValidOverAfterDoc =
					Case When @Num_OverEndTime > @NumWorkEnd
						Then @Num_OverEndTime - (Case When @Num_OverStartTime > @NumWorkEnd Then @Num_OverStartTime Else @NumWorkEnd End)
						Else 0
					End
			End

			Update dbo.Tss_EmpOverTimeAllowDoc Set
				Num_ValidOverBeforDoc = @CalcValidOverBeforDoc,
				Num_ValidOverAfterDoc = @CalcValidOverAfterDoc,
				Num_ValidOverInHoliday = @CalcValidOverInHoliday
			Where SiEmpOverTimeAllowDoc = @SiEmpOverTimeAllowDoc
			------------------------------------------------درج در محاسبه اضافه‌كاري------------------------------------------------------
		End
	
		Delete From @PerTable where SiPer=@SiSelected
	End
End
If @FlgInsUpdDel=1
Begin
	Set @Err_Code=0
	If Exists(
	Select StmEmpOverTimeAllowDoc From dbo.Tss_EmpOverTimeAllowDoc
	Where (SiEmpOverTimeAllowDoc=@SiEmpOverTimeAllowDoc) And (StmEmpOverTimeAllowDoc=@StmEmpOverTimeAllowDoc))
	Begin
		Update dbo.Tss_EmpOverTimeAllowDoc Set
			SiPubPersonsSpec=convert(numeric,@SiPubPersonsSpec),
			Dat_OverTimeDocStartDate=@Dat_OverTimeDocStartDate,
			Dat_OverTimeDocEndedDate=@Dat_OverTimeDocEndedDate,
			Num_ValidOverBeforDoc=@Num_ValidOverBeforDoc,
			Num_ValidOverAfterDoc=@Num_ValidOverAfterDoc,
			Num_ValidOverInHoliday=@Num_ValidOverInHoliday
		Where (SiEmpOverTimeAllowDoc=@SiEmpOverTimeAllowDoc)
		Set @Err_Code=@@Error
		If @Err_Code<>0
			Set @Err_Code=401
		Return
	End
	ELse
		Set @Err_Code=402
End
If @FlgInsUpdDel=2
Begin
	Set @Err_Code=0
	If Exists(
	Select StmEmpOverTimeAllowDoc From dbo.Tss_EmpOverTimeAllowDoc
	Where (SiEmpOverTimeAllowDoc=@SiEmpOverTimeAllowDoc) And (StmEmpOverTimeAllowDoc=@StmEmpOverTimeAllowDoc))
	Begin
		Delete From dbo.Tss_EmpOverTimeAllowDoc
		Where (SiEmpOverTimeAllowDoc=@SiEmpOverTimeAllowDoc)
		Set @Err_Code=@@Error
		If @Err_Code<>0
			Set @Err_Code=4000
	End
	Else
		Set @Err_Code=4001
	Return
End

GO

alter PROCEDURE Tss_EmpUntOverTimeAllowDocVStp
(
	@InternalWhere VarChar(8000)='',
	@Where VarChar(8000)='',
	@Order VarChar(8000)=''
) AS 
Declare
	@Adate char(10)

Set @Adate = dbo.Tss_MiladyToShamsiPar(GetDate())

If @InternalWhere<>''   
   Set @InternalWhere=' Where '+@InternalWhere  
/*
If @Where<>''    
   Set @Where=' Where '+@Where  
*/

If @Where<>''    
   Set @Where=' Where '+@Where  
else
	Set @Where = ' Where left(Dat_OverTimeDocStartDate,4)='+''''+left(@ADate,4)+''''


--Else
  --- Set @Where=' Where left(Dat_OverTimeDocEndedDate,4)='+''''+left(@Adate,4)+''''

print @Where

If @Order<>'' 
	Set @Order=' Order By '+@Order
Else
	Set @Order=' Order By Dat_OverTimeDocStartDate Desc'
Exec(
	'Select * From 
	(
	SELECT     
		dbo.Tss_EmpOverTimeAllowDoc.SiEmpOverTimeAllowDoc, 
		convert(varchar,dbo.Tss_EmpOverTimeAllowDoc.SiPubPersonsSpec) SiPubPersonsSpec, 
		dbo.Tss_EmpOverTimeAllowDoc.Dat_OverTimeDocStartDate, 
		dbo.Tss_EmpOverTimeAllowDoc.Dat_OverTimeDocEndedDate, 
		dbo.Tss_EmpOverTimeAllowDoc.Num_ValidOverBeforDoc, 
		dbo.Tss_EmpOverTimeAllowDoc.Num_ValidOverAfterDoc, 
		dbo.Tss_EmpOverTimeAllowDoc.Num_ValidOverInHoliday, 
		dbo.Tss_EmpOverTimeAllowDoc.StmEmpOverTimeAllowDoc, 
		dbo.Tss_EmpOverTimeAllowDoc.Num_OverStartTime, 
		dbo.Tss_EmpOverTimeAllowDoc.Num_OverEndTime, 
		dbo.Tss_PubPersonsViw.Cod_PubPersonCode, 
		dbo.Tss_PubPersonsViw.Des_FullName,
		Tss_PubPersonsViw.Sta_PubPersonsGroup,
		dbo.Tss_StdStaLabelsUdf(1068,Tss_PubPersonsViw.Sta_PubPersonsGroup) Sta_PubPersonsGroupDes

	FROM         
		dbo.Tss_EmpOverTimeAllowDoc INNER JOIN
      dbo.Tss_PubPersonsViw ON dbo.Tss_EmpOverTimeAllowDoc.SiPubPersonsSpec = dbo.Tss_PubPersonsViw.SiPubPersonsSpec'+@InternalWhere+'
	) CalcSel ' + @Where + @Order
)

GO

alter PROCEDURE Tss_EmpUntWorkTime_DtVStp
(
   @InternalWhere VarChar(8000)='',
   @Where VarChar(8000)='',
   @Order VarChar(8000)=''
) AS 
If @InternalWhere<>'' 
   Set @InternalWhere=' Where '+@InternalWhere
If @Where<>'' 
   Set @Where=' Where '+@Where
If @Order<>'' 
   Set @Order=' Order By '+@Order
Exec(
   'Select * From 
   (
   Select * From (
  SELECT     
    Tss_EmpWorkTime.SiEmpWorkTime,
    Tss_EmpWorkTime.SiGenDates, 
    Tss_EmpWorkTime.SiEmpWorkGroups, 
    Tss_EmpWorkTime.Sta_WorkDayState, 
    Tss_EmpWorkTime.Num_WorkGroupStartTime, 
    Tss_EmpWorkTime.Num_WorkGroupLenTime, 
    dbo.Tss_StdMinToStr24_Udf(Tss_EmpWorkTime.Num_WorkGroupStartTime) Num_WorkGroupStartTimeDesc,
    dbo.Tss_StdMinToStr24_Udf(Tss_EmpWorkTime.Num_WorkGroupLenTime) Num_WorkGroupLenTimeDesc,
    Tss_EmpWorkTime.Num_RelaxTime1, 
    Tss_EmpWorkTime.Num_RelaxLenTime1, 
    Tss_EmpWorkTime.Num_RelaxTime2, 
    Tss_EmpWorkTime.Num_RelaxLenTime2, 
    Tss_EmpWorkTime.Num_RelaxTime3, 
    Tss_EmpWorkTime.Num_RelaxLenTime3, 
    Tss_EmpWorkTime.StmEmpWorkTime, 
    Tss_EmpWorkTime.Num_SpecStartDayTime, 
    Tss_EmpWorkTime.Num_SpecEndedDayTime, 
    Tss_EmpWorkGroups.Cod_WorkGroupCode, 
    Tss_EmpWorkGroups.Des_WorkGroupName, 
    Tss_GenDates.Num_GenDayNo, 
    Tss_GenDates.Dat_GenShamsiDate, 
    dbo.Tss_EmpDayNameByDayNoUdf(Tss_GenDates.Num_GenDayNo) as DayName
FROM         
    Tss_EmpWorkTime INNER JOIN
    Tss_EmpWorkGroups ON Tss_EmpWorkTime.SiEmpWorkGroups = Tss_EmpWorkGroups.SiEmpWorkGroups INNER JOIN
    Tss_GenDates ON Tss_EmpWorkTime.SiGenDates = Tss_GenDates.SiGenDates) Ccc '
 +@InternalWhere+'
   ) CalcSel ' + @Where + @Order
)

GO

alter PROCEDURE Tss_EmpUntLeaveDocsVStp
(
   @InternalWhere VarChar(8000)='',
   @Where VarChar(8000)='',
   @Order VarChar(8000)='',
   @User Varchar(50)='mh'
) 

AS 

declare
	@ADate varchar(10) ,
    @TodayShamsi NVARCHAR(10),
    @ThirtyDaysAgoShamsi NVARCHAR(10)

SET @TodayShamsi = dbo.Tss_MiladyToShamsiPar(GetDate())
SET @ThirtyDaysAgoShamsi = dbo.Tss_MiladyToShamsiPar(DATEADD(DAY, - 30, GETDATE()))

	Set @ADate = dbo.Tss_StdMildi2ShamsiUdf(GETDATE())

If @InternalWhere<>'' 
   Set @InternalWhere=' Where '+@InternalWhere

If @Where<>'' 
   Set @Where=' Where '+@Where
else
    Set @Where = ' Where (Dat_LeaveRequstDate BETWEEN ''' + @ThirtyDaysAgoShamsi + ''' AND ''' + @TodayShamsi + '''' + ')'

If @Order<>'' 
   Set @Order=' Order By '+@Order
else
   Set @Order=' Order By SiEmpLeaveDocs'

   

if dbo.Tss_StdFindSubLoc(0)='Caspian' or dbo.Tss_StdFindSubLoc(0)='delta'
Begin
	Exec(
	   'Select top 2000 *,	   ROW_NUMBER() OVER (ORDER BY SiEmpLeaveDocs) AS RowNum,
dbo.Tss_StdMinToStr_Udf(LeaveDurationTime) LeaveDuration From 
	   (
	   Select * From (
		SELECT     
			--		dbo.Tss_EmpLeaveDocs.Num_LeaveMinutes,
			dbo.Tss_EmpLeaveDocs.SiEmpLeaveDocs, 
			dbo.Tss_EmpLeaveDocs.SiEmpLeaveTypes, 
			convert(varchar,dbo.Tss_EmpLeaveDocs.SiPubPersonsSpec) SiPubPersonsSpec, 
			dbo.Tss_EmpLeaveDocs.Cod_LeaveDocNumber, 
			dbo.Tss_EmpLeaveDocs.Dat_LeaveStartDate, 
			dbo.Tss_EmpLeaveDocs.Dat_LevaEndedDate, 
			dbo.Tss_EmpLeaveDocs.Num_LeaveStartTime,
			dbo.Tss_EmpLeaveDocs.Num_LeaveEndedTime,
			(
			SELECT
				SUM(Num_LeaveUsedMin)
			FROM 
				Tss_EmpLeaveCalc
			GROUP BY 
				SiEmpLeaveDocs
			HAVING        
				(SiEmpLeaveDocs = dbo.Tss_EmpLeaveDocs.SiEmpLeaveDocs)
			) LeaveDurationTime,
			dbo.Tss_EmpLeaveDocs.Dat_LeaveRequstDate, 
			dbo.Tss_EmpLeaveDocs.Sta_LeaveDocAcceptStat, 
			dbo.Tss_EmpLeaveDocs.Sta_LeaveDocRegStat, 
			dbo.Tss_EmpLeaveDocs.StmEmpLeaveDocs, 
			dbo.Tss_EmpLeaveTypes.Cod_LeaveTypeCOde, 
			dbo.Tss_EmpLeaveTypes.Des_LeaveTypeName, 
			dbo.Tss_PubPersonsSpec.Cod_PubPersonCode, 
			dbo.Tss_PubPersonsSpec.Des_PubPersonName1, 
			dbo.Tss_PubPersonsSpec.Des_PubPersonName2,
			Ltrim(Rtrim(IsNull(Des_PubPersonName1,Space(0))))+Space(1)+Ltrim(Rtrim(IsNull(Des_PubPersonName2,Space(0)))) Des_FullName,
			Tss_PubPersonsSpec.Sta_PubPersonsGroup,
			dbo.Tss_StdStaLabelsUdf(1068,Tss_PubPersonsSpec.Sta_PubPersonsGroup) Sta_PubPersonsGroupDes,
			'''' day,  
			'''' Des_WorkGroupName,
			'''' Num_WorkGroupStartTime,
			'''' Num_WorkGroupEndTime,
			dbo.Tss_EmpFindWorkGroupDayType_Udf(dbo.Tss_EmpLeaveDocs.Dat_LeaveRequstDate,dbo.Tss_EmpFindWorkGroupSi_Udf(dbo.Tss_EmpLeaveDocs.Dat_LeaveRequstDate,dbo.Tss_EmpLeaveDocs.SiPubPersonsSpec)) as DayType
		FROM            
			Tss_EmpLeaveDocs INNER JOIN
			Tss_EmpLeaveTypes ON Tss_EmpLeaveDocs.SiEmpLeaveTypes = Tss_EmpLeaveTypes.SiEmpLeaveTypes INNER JOIN
			Tss_PubPersonsSpec ON Tss_EmpLeaveDocs.SiPubPersonsSpec = Tss_PubPersonsSpec.SiPubPersonsSpec INNER JOIN
			Tss_GenDates ON Tss_EmpLeaveDocs.Dat_LeaveRequstDate = Tss_GenDates.Dat_GenShamsiDate
	   ) Ccc '+@InternalWhere+'
	   ) CalcSel ' + @Where + @Order
	)
End
else
Begin
	Exec(
	   'Select 
	   ROW_NUMBER() OVER (ORDER BY SiEmpLeaveDocs) AS RowNum,
	   *
	   From
	   (
	   Select * From (
		SELECT   
		
			dbo.Tss_EmpLeaveDocs.SiEmpLeaveDocs, 
			dbo.Tss_EmpLeaveDocs.SiEmpLeaveTypes, 
			convert(varchar,dbo.Tss_EmpLeaveDocs.SiPubPersonsSpec) SiPubPersonsSpec, 
			dbo.Tss_EmpLeaveDocs.Cod_LeaveDocNumber, 
			dbo.Tss_EmpLeaveDocs.Dat_LeaveStartDate, 
			dbo.Tss_EmpLeaveDocs.Dat_LevaEndedDate, 
			dbo.Tss_EmpLeaveDocs.Num_LeaveStartTime,
			dbo.Tss_EmpLeaveDocs.Num_LeaveEndedTime,
			dbo.Tss_EmpLeaveDocs.Dat_LeaveRequstDate, 
			dbo.Tss_EmpLeaveDocs.Sta_LeaveDocAcceptStat, 
			dbo.Tss_EmpLeaveDocs.Sta_LeaveDocRegStat, 
			dbo.Tss_EmpLeaveDocs.StmEmpLeaveDocs, 
			dbo.Tss_EmpLeaveTypes.Cod_LeaveTypeCOde, 
			dbo.Tss_EmpLeaveTypes.Des_LeaveTypeName, 
			dbo.Tss_PubPersonsSpec.Cod_PubPersonCode, 
			dbo.Tss_PubPersonsSpec.Des_PubPersonName1, 
			dbo.Tss_PubPersonsSpec.Des_PubPersonName2,
			Tss_PubPersonsSpec.Sta_PubPersonsGroup,
			Ltrim(Rtrim(IsNull(Des_PubPersonName1,Space(0))))+Space(1)+Ltrim(Rtrim(IsNull(Des_PubPersonName2,Space(0)))) Des_FullName,
			(
			SELECT
				SUM(Num_LeaveUsedMin)
			FROM 
				Tss_EmpLeaveCalc
			GROUP BY 
				SiEmpLeaveDocs
			HAVING        
				(SiEmpLeaveDocs = dbo.Tss_EmpLeaveDocs.SiEmpLeaveDocs)
			) LeaveDurationTime,
			dbo.Tss_StdStaLabelsUdf(1068,Tss_PubPersonsSpec.Sta_PubPersonsGroup) Sta_PubPersonsGroupDes,
			dbo.Tss_EmpFindDayOfWeekStr_Udf(dbo.Tss_GenDates.Num_GenDayNo) day,  
			dbo.Tss_EmpFindWorkGroupName_Udf(dbo.Tss_EmpLeaveDocs.Dat_LeaveRequstDate,dbo.Tss_EmpLeaveDocs.SiPubPersonsSpec,dbo.Tss_EmpLeaveDocs.Dat_LeaveRequstDate) Des_WorkGroupName,
			'''' Num_WorkGroupStartTime,
			'''' Num_WorkGroupEndTime,
			'''' as DayType
			--dbo.Tss_StdMinToStr24_Udf(dbo.Tss_EmpFindWorkGroupStartTime_Udf(dbo.Tss_EmpLeaveDocs.Dat_LeaveRequstDate,dbo.Tss_EmpFindWorkGroupSiForDaily_Udf(dbo.Tss_EmpLeaveDocs.Dat_LeaveRequstDate,dbo.Tss_EmpLeaveDocs.SiPubPersonsSpec))) Num_WorkGroupStartTime,






			--dbo.Tss_StdMinToStr24_Udf(dbo.Tss_EmpFindWorkGroupEndTime_Udf(dbo.Tss_EmpLeaveDocs.Dat_LeaveRequstDate,dbo.Tss_EmpFindWorkGroupSiForDaily_Udf(dbo.Tss_EmpLeaveDocs.Dat_LeaveRequstDate,dbo.Tss_EmpLeaveDocs.SiPubPersonsSpec))) Num_WorkGroupEndTime,
			--dbo.Tss_EmpFindWorkGroupDayType_Udf(dbo.Tss_EmpLeaveDocs.Dat_LeaveRequstDate,dbo.Tss_EmpFindWorkGroupSi_Udf(dbo.Tss_EmpLeaveDocs.Dat_LeaveRequstDate,dbo.Tss_EmpLeaveDocs.SiPubPersonsSpec)) as DayType
		FROM            
			Tss_EmpLeaveDocs INNER JOIN
			Tss_EmpLeaveTypes ON Tss_EmpLeaveDocs.SiEmpLeaveTypes = Tss_EmpLeaveTypes.SiEmpLeaveTypes INNER JOIN
			Tss_PubPersonsSpec ON Tss_EmpLeaveDocs.SiPubPersonsSpec = Tss_PubPersonsSpec.SiPubPersonsSpec INNER JOIN
			Tss_GenDates ON Tss_EmpLeaveDocs.Dat_LeaveRequstDate = Tss_GenDates.Dat_GenShamsiDate
	   ) Ccc '+@InternalWhere+'
	   ) CalcSel ' + @Where + @Order
	)
End

GO

-- First, check if SayadiReg already exists
IF NOT EXISTS (
    SELECT 1 
    FROM Tss_PubCustomCodes 
    WHERE SiPubCustomDataType = 26 
      AND Des_CustomCodesDesc = 'SayadiReg'
)
BEGIN
    -- Find the last code in the group
    DECLARE @LastCode INT;

    SELECT @LastCode = ISNULL(MAX(CONVERT(NUMERIC, Cod_CustomCodesCode)), 0)
    FROM Tss_PubCustomCodes
    WHERE SiPubCustomDataType = 26;

    -- Add new record for SayadiReg
    INSERT INTO Tss_PubCustomCodes (
        SiPubCustomDataType,
        Cod_CustomCodesCode,
        Des_CustomCodesDesc,
        SiPubCostCenter,
        ProgSuspendCustName,
        ProgSuspendMazroof,
        ProgSuspendProgMandeh,
        ProgSuspendDes,
        Sta_PubCustomCodesState,
        Sta_EffectiveOnTax,
        Sta_Enabled,
        Sta_AddOrSubtract,
        DatToSuspend,
        Des_PmAdditonalDesc,
        Sta_IssueAutoDoc,
        Cod_SrvTaxEquiCode,
        Des_SrvTaxEquiDesc
    )
    VALUES (
        26,                          -- SiPubCustomDataType
        @LastCode + 1,              -- Cod_CustomCodesCode
        'SayadiReg',               -- Des_CustomCodesDesc (Sayadi Registration)
        NULL,                       -- SiPubCostCenter
        0,                          -- ProgSuspendCustName
        0,                          -- ProgSuspendMazroof
        0,                          -- ProgSuspendProgMandeh
        N'',                        -- ProgSuspendDes
        0,                          -- Sta_PubCustomCodesState
        0,                          -- Sta_EffectiveOnTax
        1,                          -- Sta_Enabled
        0,                          -- Sta_AddOrSubtract
        NULL,                       -- DatToSuspend
        N'',                        -- Des_PmAdditonalDesc
        0,                          -- Sta_IssueAutoDoc
        NULL,                       -- Cod_SrvTaxEquiCode
        NULL                        -- Des_SrvTaxEquiDesc
    );
    
    PRINT 'Record inserted successfully.';
END
ELSE
BEGIN
    PRINT 'Record with Description "SayadiReg" already exists for SiPubCustomDataType=26.';
END

GO

alter PROCEDURE Tss_SalUntInvoice_DtVStp2
(
   @InternalWhere VarChar(8000)='',
   @Where VarChar(8000)='',
   @Order VarChar(8000)=''
) AS 

Set arithabort ON
Set concat_null_yields_null ON
Set ansi_nulls ON
Set ansi_null_dflt_on ON
Set ansi_padding ON
Set ansi_warnings ON
Set quoted_identifier ON


If @InternalWhere<>'' 
   Set @InternalWhere=' Where '+@InternalWhere
If @Where<>'' 
   Set @Where=' Where '+@Where
If @Order<>'' 
   Set @Order=' Order By '+@Order
Exec(
'Select * From 
(
   Select * From 
   (
SELECT
    Tsid.Num_CommisionFee,
    Tsid.Sta_IsCommisionPercent,
    Tsid.Sta_IsCommisionArea,
    Tsid.Num_CustomerTarkibiWidth, 
    Tsid.Sta_HasDesign, Tsid.Num_GdsPalleteFee, 
    Tsid.Num_FeeHaml, 
    Tsid.SiSalInvoice_Dt, 
    Tsid.Num_NoOfPrintingSides, 
    Tsid.Num_WidthPert, 
    Tsid.Num_LengthPert, 
    Tsid.SiPubCustomCodesColor1, 
    Tsid.SiPubCustomCodesColor2, 
    Tsid.SiPubCustomCodesColor3, 
    Tsid.SiPubCustomCodesColo4, 
    Tsid.SiSalInvoice_Hd, 
    Tsid.SiPrcGoodsType, 
    Tsid.SiPrcFlutType, 
    Tsid.SiPubGoods, 
    Tsid.SiPubGoodsClassify, 
    Tsid.Num_SalInvoiceDetRow, 
    Tsid.Num_GdsAmountNo, 
    Tsid.Num_ColoringRate, 
    Tsid.Num_GdsArea, 
    Tsid.Num_GdsFee, 
    Tsid.Num_GdsBalancFee, 
    Tsid.Num_GdsBalancFee * Tsid.Num_GdsAmountNo AS RowPrice, 
    Tsid.Num_SampleInnerLength, 
    Tsid.Num_SampleInnerWidth, 
    Tsid.Num_SampleInnerHeigth, 
    Tsid.Num_SampleHoleNo, 
    Tsid.Num_SampleMasrafCoefOfBox, 
    Tsid.Sta_HasMangene, 
    Tsid.Sta_IsLipStick, 
    Tsid.Num_GdsColorFee, 
    Tsid.Num_GdsDieFee, 
    Tsid.Num_FeeAdjust, Tsid.StmSalInvoice_Dt, Tsid.SiPrcKelisheSpec, 
    Tsid.Num_GoodsLength, 
    Tsid.Num_GoodsWidth, 
    (convert(numeric,Tsid.Num_GoodsLength)*convert(numeric,Tsid.Num_GoodsWidth))/1000000 as VaraghArea,
    Tsid.Num_GoodsUnitWeight, ROUND(Tsid.Num_GoodsUnitWeight * Tsid.Num_GdsAmountNo / 1000, 0) AS Tonage, Color1.Cod_CustomCodesCode AS cCol1, 
    Color1.Des_CustomCodesDesc AS nCol1, 
    Color2.Cod_CustomCodesCode AS cCol2, Color2.Des_CustomCodesDesc AS nCol2, Color3.Cod_CustomCodesCode AS cCol3, Color3.Des_CustomCodesDesc AS nCol3, 
    Color4.Cod_CustomCodesCode AS cCol4, 
    Color4.Des_CustomCodesDesc AS nCol4, Tpgt.Cod_PrcGoodsTypeCode, Tpgt.Des_PrcGoodsTypeDesc, Tss_PrcFlutType.Cod_FlutTypeCode,
    Tss_PrcFlutType.Des_FlutTypeName, Tss_PubGoods.Cod_PubGoodsCode, 
    Tss_PubGoods.Des_PubGoodsDesc, Tss_PubGoodsClassify.Cod_GoodsClassCode AS Code_Jens, Tss_PubGoodsClassify.Des_GoodsClassDesc AS Name_Jens, 
    Tss_PrcKelisheSpec.Cod_KelisheSpecCode, 
    Tss_PrcKelisheSpec.Des_KelisheSpecDesc, Tsid.SiPrcDieSpec, Tss_PrcDieSpec.Cod_DieSpecCode, 
    Tss_PrcDieSpec.Des_DieSpecDesc+'+''''+' - '+''''+'+convert(varchar,Tss_PrcDieSpec.Num_NoGdsInDie)+'+''''+' تايي '+''''+' as Des_DieSpecDesc,
    Tsid.Sta_Cyan, Tsid.Sta_Magenta, Tsid.Sta_Yellow, Tsid.Sta_Black, Tsid.Sta_HasVerni, Tsid.Num_VaraghCreaseAmt, 
    Tsid.Sta_HoleSide, Tsid.Sta_CatchSide, Tsid.Sta_PrintArm, Tsid.Sta_PackType, 
    Tsid.Num_OneMeterSheetPrice, Tsid.Num_OneMeterBoxPrice, Tsid.SiPubCustomCodes, Tsid.Cod_SampleGdsCode, 
    Mazroof.Cod_CustomCodesCode AS CodMazDt, Mazroof.Des_CustomCodesDesc AS DesMazDt, 
    Tsid.Sta_EttesalType, Tsid.Sta_HasGooshvareh, Tsid.Num_UpDoorOpenSize, Tsid.Num_DownDoorOpenSize, 
    Tsid.Num_SampleOuterLength, Tsid.Num_SampleOuterWidth, Tsid.Num_SampleOuterHeigth, 
    Tsid.Num_VaraghUpDoorAmt, Tsid.Num_VaraghDownDoorAmt, Tsid.Sta_IsDoubleCrease, 
    Tsid.Sta_ShowJens, Tsid.Sta_ShowJensBrief, Tsid.Sta_HighSensibility, Tsid.Num_ContLabChasbConst, Tsid.Sta_OuterPrint, 
    Tsid.SiInvBuyReq_Dt, Tss_InvBuyReq_Dt.Num_BuyReqN, Tss_InvBuyReq_Dt.Cod_BuyReqDtCode, Tss_InvBuyReq_Hd.Cod_BuyReqHdCode, 
    Tss_InvBuyReq_Hd.Dat_BuyReqHdDate, Tss_InvBuyReq_Hd.SiInvBuyReq_Hd, 
    Tsid.Num_GdsInWidthBuyReq, Tsid.Num_GdsInLengthBuyReq, Tpgt.Sta_TipOfGoodsType, Tsid.Tss_SalInvoice_DtRegTime, 
    Tsid.Tss_SalInvoice_DtEditTime, Tsid.Tss_SalInvoice_DtRegisterer, Tsid.Tss_SalInvoice_DtEditor, 
    Registerer.Cod_PubPersonCode AS CodRegisterer, Registerer.Des_FullName AS DesRegisterer, 
    Editor.Cod_PubPersonCode AS CodEditor, Editor.Des_FullName AS DesEditor, Tsid.SiPubCustomCodesColor5, 
    Tsid.SiPubCustomCodesColor6, Color5.Cod_CustomCodesCode AS cCol5, Color5.Des_CustomCodesDesc AS nCol5, 
    Color6.Cod_CustomCodesCode AS cCol6, Color6.Des_CustomCodesDesc AS nCol6, Tsid.Num_NoInPallete, 
    Tsid.SiSalInvoiceDtCopiedFrom, Tsid.Sta_IsFeeAdjustPercent, Tsid.Num_GdsFeeRounder, Tsid.Sta_CellophaneType, 
    Tsid.Sta_MatteOrGlossy, Tsid.Num_GdsLaminateFee, Tsid.SiPubGoodsClassifyCardBox, 
    Tss_PubGoodsClassifyCardBox.Cod_GoodsClassCode AS Cod_GoodsClassCodeCardBox, Tss_PubGoodsClassifyCardBox.Des_GoodsClassDesc AS Des_GoodsClassDescCardBox, 
    Tpgt.Sta_LaminateType, 
    Tsid.SiSalInvoice_DtCombinee, Tss_PubGoodsViw.Des_PubGoodsDesc AS CombineeeGdsDes, Tss_PubGoodsViw.Cod_PubGoodsCode AS CombineeeGdsCod, 
    Tss_SalInvoiceGoodsViw.Cod_SaleAgreement2 CombineeeContNo,
    Tsid.LamDieLen, Tsid.LamDieWid, Tsid.LamDieNo, 
    Tsid.LamCardBoardLen, 
    Tsid.LamCardBoardWid, 
    Tsid.LamCardBoardLen*Tsid.LamCardBoardWid/1000000 as LamCardBoardArea,
    Tsid.LamCardBoardFee, 
    Tsid.LamCalcPert, Tsid.LamCorrugRoleWid, Tsid.LamCorrugPert, Tsid.LamLaminateFee, Tsid.LamDieFee, Tsid.LamSiHamlGeoPlace, Tsid.LamPrintType, Tsid.LamPrintTypeS, 
    Tsid.LamPrintTypeG, Tsid.LamPrintTypeP1, Tsid.LamPrintTypeP2, 
    Tsid.LamPrintTypeP3, Tsid.LamPrintTypeP4, Tsid.LamJointNo, Tsid.LamJointAuto, Tsid.LamJointSemiAuto, Tsid.LamJointHand, Tsid.LamJointTwoPiece, 
    Tsid.LamJointLockBottom, Tsid.LamJointFourPoint, Tsid.LamJointPunch, 
    Tsid.LamPackNo, Tsid.LamPackStrap, Tsid.LamPackStrapBaGuard, Tsid.LamPackShrink, Tsid.LamPackMotherBox, Tsid.LamPackNylon, Tsid.LamPackPallete, 
    Tsid.LamBelongZinkPrice, Tsid.LamBelongDiePrice, 
    Tsid.LamBelongKelishePrice, Tsid.LamBelongHandlePrice, Tsid.LamBelongTalcPrice, Tsid.LamBelongCardBoardUnitFee, Tsid.LamBelongSheetUnitFee, 
    Tsid.LamBelongPrintUnitFee, Tsid.LamBelongColorUnitFee, 
    Tsid.LamBelongCoverUnitFee, Tsid.LamBelongLaminateUnitFee, Tsid.LamBelongJointUnitFee, Tsid.LamBelongPackUnitFee, Tsid.LamBelongTransportUnitFee, 
    Tsid.LamOtherCosts, Tsid.LamCalcBelongCosts, Tsid.LamBelongCosts, 
    Tss_PubGeoPlac.Cod_GeoPlaceCode, Tss_PubGeoPlac.Des_GeoPlaceName, Tss_PubGeoPlac.Num_L3VaraghTransFee, Tss_PubGeoPlac.Num_L3BoxTransFee, Tss_PubGeoPlac.Num_L5VaraghTransFee, 
    Tss_PubGeoPlac.Num_L5BoxTransFee,
    Tsid.LamCoverLen,
    Tsid.LamCoverWid,
    Tsid.LamCoverLen*Tsid.LamCoverWid/1000000 as LamCoverArea,
    Tsid.LamCoverGlassy ,
    Tsid.LamCoverMatt ,
    Tsid.LamCoverMetallize ,
    Tsid.LamCoverVerni ,
    Tsid.LamCoverUV,
    Tsid.LamDesc,
    Tsid.Num_ActualFeeAdjust,
    Tpgt.Sta_DieOrNot,
    $0.0 as FactoredAmt,
    Tsid.LamHandJointNo, 
    Tsid.LamSemiAutoJointNo, 
    Tsid.LamTwoPieceJointNo, 
    Tsid.LamLockBottomJointNo, 
    Tsid.LamFourPointJointNo, 
    Tsid.LamAutoJointNo, 
    Tsid.LamStrapWithGuardNo, 
    Tsid.LamShrinkNo, 
    Tsid.LamMotherBoxNo, 
    Tsid.LamNylonNo, 
    Tsid.SiPrcPackagingTypes, 
    Tss_PrcPackagingTypes.Cod_PackagingTypesCode,
    Tss_PrcPackagingTypes.Des_PackagingTypesDesc,
    Tss_PrcPackagingTypes.Num_PackagingTypesCost, 
    Tss_PrcPackagingTypes.Sta_PackagingType,
    dbo.Tss_StdStaLabelsUdf(1134,Tss_PrcPackagingTypes.Sta_PackagingType) Sta_PackagingTypeDes
FROM            
    Tss_PrcPackagingTypes RIGHT OUTER JOIN
    Tss_SalInvoice_Dt AS Tsid ON Tss_PrcPackagingTypes.SiPrcPackagingTypes = Tsid.SiPrcPackagingTypes LEFT OUTER JOIN
    Tss_PubGeoPlac ON Tsid.LamSiHamlGeoPlace = Tss_PubGeoPlac.SiPubGeoPlac LEFT OUTER JOIN
    Tss_PubGoodsViw INNER JOIN
    Tss_SalInvoiceGoodsViw ON Tss_PubGoodsViw.SiPubGoods = Tss_SalInvoiceGoodsViw.SiPubGoods ON Tsid.SiSalInvoice_DtCombinee = Tss_SalInvoiceGoodsViw.SiSalInvoice_Dt LEFT OUTER JOIN
    Tss_PubGoodsClassify AS Tss_PubGoodsClassifyCardBox ON Tsid.SiPubGoodsClassifyCardBox = Tss_PubGoodsClassifyCardBox.SiPubGoodsClassify LEFT OUTER JOIN
    Tss_PubGoodsClassify ON Tsid.SiPubGoodsClassify = Tss_PubGoodsClassify.SiPubGoodsClassify LEFT OUTER JOIN
    Tss_PubCustomCodes AS Color6 ON Tsid.SiPubCustomCodesColor6 = Color6.SiPubCustomCodes LEFT OUTER JOIN
    Tss_PubCustomCodes AS Color1 ON Tsid.SiPubCustomCodesColor1 = Color1.SiPubCustomCodes LEFT OUTER JOIN
    Tss_PubCustomCodes AS Color4 ON Tsid.SiPubCustomCodesColo4 = Color4.SiPubCustomCodes LEFT OUTER JOIN
    Tss_PubCustomCodes AS Color2 ON Tsid.SiPubCustomCodesColor2 = Color2.SiPubCustomCodes LEFT OUTER JOIN
    Tss_PubCustomCodes AS Color5 ON Tsid.SiPubCustomCodesColor5 = Color5.SiPubCustomCodes LEFT OUTER JOIN
    Tss_PubCustomCodes AS Mazroof ON Tsid.SiPubCustomCodes = Mazroof.SiPubCustomCodes LEFT OUTER JOIN
    Tss_PubCustomCodes AS Color3 ON Tsid.SiPubCustomCodesColor3 = Color3.SiPubCustomCodes LEFT OUTER JOIN
    Tss_PubPersonsViw AS Editor ON Tsid.Tss_SalInvoice_DtEditor = Editor.SiPubPersonsSpec LEFT OUTER JOIN
    Tss_PubPersonsViw AS Registerer ON Tsid.Tss_SalInvoice_DtRegisterer = Registerer.SiPubPersonsSpec LEFT OUTER JOIN
    Tss_InvBuyReq_Dt INNER JOIN
    Tss_InvBuyReq_Hd ON Tss_InvBuyReq_Dt.SiInvBuyReq_Hd = Tss_InvBuyReq_Hd.SiInvBuyReq_Hd ON Tsid.SiInvBuyReq_Dt = Tss_InvBuyReq_Dt.SiInvBuyReq_Dt LEFT OUTER JOIN
    Tss_PrcGoodsType AS Tpgt ON Tsid.SiPrcGoodsType = Tpgt.SiPrcGoodsType LEFT OUTER JOIN
    Tss_PrcFlutType ON Tsid.SiPrcFlutType = Tss_PrcFlutType.SiPrcFlutType LEFT OUTER JOIN
    Tss_PrcDieSpec ON Tsid.SiPrcDieSpec = Tss_PrcDieSpec.SiPrcDieSpec LEFT OUTER JOIN
    Tss_PrcKelisheSpec ON Tsid.SiPrcKelisheSpec = Tss_PrcKelisheSpec.SiPrcKelisheSpec LEFT OUTER JOIN
    Tss_PubGoods ON Tsid.SiPubGoods = Tss_PubGoods.SiPubGoods


) Ccc '+@InternalWhere+'
) CalcSel ' + @Where + @Order)

GO
ALTER PROC Tss_StdUserShortCuts
(
    @SiUser NUMERIC = 1
)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @IsAdmin BIT = 0;
    
    -- Check if the user is an admin
    SELECT @IsAdmin = CASE WHEN Sta_UserManagerState = 1 THEN 1 ELSE 0 END
    FROM Tss_StdSystemUsers
    WHERE SiPubPersonsSpec = @SiUser;

    ;WITH AccessibleLeaves AS
    (
        -- Step 1: find leaf items the user actually has view rights on
        SELECT DISTINCT
            Tss_StdSystemMenuItems.SiStdSystemMenuItems
        FROM Tss_StdUserAccsessRight
            INNER JOIN Tss_StdSystemUsers 
                ON Tss_StdUserAccsessRight.SiStdSystemUsers = Tss_StdSystemUsers.SiStdSystemUsers
            INNER JOIN Tss_StdSystemMenuItems
                ON Tss_StdUserAccsessRight.SiStdSystemMenuItems = Tss_StdSystemMenuItems.SiStdSystemMenuItems
        WHERE
            Tss_StdSystemMenuItems.Num_SysMenuClass = 0
            AND Tss_StdSystemMenuItems.Sta_SystemMenuLeaf = 1     -- only actual leaves/shortcuts
            AND Tss_StdUserAccsessRight.Sta_UarCanView = 1        -- BIT: 1 = TRUE
            AND Tss_StdSystemUsers.SiPubPersonsSpec = @SiUser
            AND EXISTS (
                SELECT 1 
                FROM Tss_PubPersonsSpec p
                WHERE p.SiPubPersonsSpec = Tss_StdSystemUsers.SiPubPersonsSpec
            )
    ),
    TreeCTE AS
    (
        -- Anchor: the accessible leaf items themselves (or ALL leaves if admin)
        SELECT
            m.SiStdSystemMenuItems,
            m.SiStdSystemsList,
            m.SiStdSystemMenuItemsF,
            m.Cod_SysMenuItemCode,
            m.Des_SysMenuItemDesc,
            m.Des_SysMenuItemMethodName,
            m.Num_SequenceNumber,
            m.Num_SystemMenuLevel,
            m.Sta_SystemMenuLeaf
        FROM Tss_StdSystemMenuItems m
        WHERE 
            m.Num_SysMenuClass = 0
            AND m.Sta_SystemMenuLeaf = 1
            AND (
                @IsAdmin = 1  -- If admin, show ALL leaves
                OR EXISTS (
                    SELECT 1 
                    FROM AccessibleLeaves al
                    WHERE al.SiStdSystemMenuItems = m.SiStdSystemMenuItems
                )
            )

        UNION ALL

        -- Recursive: walk up the tree to pull in every ancestor (parent, grandparent, ... root)
        SELECT
            p.SiStdSystemMenuItems,
            p.SiStdSystemsList,
            p.SiStdSystemMenuItemsF,
            p.Cod_SysMenuItemCode,
            p.Des_SysMenuItemDesc,
            p.Des_SysMenuItemMethodName,
            p.Num_SequenceNumber,
            p.Num_SystemMenuLevel,
            p.Sta_SystemMenuLeaf
        FROM Tss_StdSystemMenuItems p
            INNER JOIN TreeCTE t
                ON p.SiStdSystemMenuItems = t.SiStdSystemMenuItemsF
        WHERE p.Num_SysMenuClass = 0
    )
    SELECT DISTINCT
        SiStdSystemMenuItems,
        SiStdSystemsList,
        SiStdSystemMenuItemsF,
        Cod_SysMenuItemCode,
        Des_SysMenuItemDesc,
        Des_SysMenuItemMethodName,
        Num_SequenceNumber,
        Num_SystemMenuLevel,
        Sta_SystemMenuLeaf
    FROM TreeCTE
    ORDER BY 
        Num_SystemMenuLevel, 
        Num_SequenceNumber
    OPTION (MAXRECURSION 100);
END

GO

alter PROCEDURE Tss_SalUntInvoice_HdVStp2  
(    
   @InternalWhere VARCHAR(8000) = '',   
   @Where VARCHAR(8000) = '',   
   @Order VARCHAR(8000) = '',
   @SiUser NUMERIC = 2   
) 
AS     

SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_NULL_DFLT_ON ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET QUOTED_IDENTIFIER ON

SET @InternalWhere = ISNULL(@InternalWhere,'')
SET @Where = ISNULL(@Where,'')
SET @Order = ISNULL(@Order,'')

DECLARE 
    @SaleMali NVARCHAR(4),
    @Cod_AccFinancePeriod NVARCHAR(50),
    @Sql VARCHAR(8000),
    @Adate NVARCHAR(7),
    @BossApp SMALLINT

SELECT @BossApp = dbo.Tss_StdFindIfUserIsInGroup(@SiUser,'BossApp')
PRINT @Where
PRINT @BossApp
PRINT @SiUser

IF @Where = 'Request'     
   SET @Where = ' WHERE Dat_SalReqToContractDate = '''''
ELSE
BEGIN
    IF NOT EXISTS
    (
        SELECT Tss_PubCustomCodes.Des_CustomCodesDesc, Tss_StdSystemUsers.SiPubPersonsSpec
        FROM Tss_StdSystemUserTogrps 
        INNER JOIN Tss_PubCustomCodes ON Tss_StdSystemUserTogrps.SiPubCustomCodes = Tss_PubCustomCodes.SiPubCustomCodes 
        INNER JOIN Tss_StdSystemUsers ON Tss_StdSystemUserTogrps.SiStdSystemUsers = Tss_StdSystemUsers.SiStdSystemUsers
        WHERE (Tss_PubCustomCodes.Des_CustomCodesDesc = 'SaleApprover') 
          AND (Tss_StdSystemUsers.SiPubPersonsSpec = @SiUser)
    )
    BEGIN
        PRINT 'inja'
        IF @InternalWhere <> ''     
           SET @InternalWhere = ' WHERE ' + @InternalWhere    
        IF ((@Where <> '') AND (@Where <> 'Request')) AND (@BossApp <> 1) AND (@SiUser <> 2626)     
           SET @Where = ' WHERE (SiSaler = ' + CONVERT(VARCHAR,@SiUser) + ') AND ' + @Where  
        IF ((@Where <> '') AND (@Where <> 'Request')) AND (@BossApp <> 1) AND (@SiUser = 2626)    
           SET @Where = ' WHERE ((SiSaler = ' + CONVERT(VARCHAR,@SiUser) + ') OR (SiSaler = 8)) AND ' + @Where  
        IF ((@Where <> '') AND (@Where <> 'Request')) AND (@BossApp = 1)     
            SET @Where = ' WHERE ' + @Where 
        IF (@Where = '')
        BEGIN
            IF (dbo.Tss_StdFindSubLoc(0) = 'Nekoo') OR (dbo.Tss_StdFindSubLoc(0) = 'aeen') OR (dbo.Tss_StdFindSubLoc(0) = 'Delta')
            BEGIN
                SET @Adate = LEFT(dbo.Tss_MiladyToShamsiPar(GETDATE()),4)
                IF (@BossApp <> 1) AND (@SiUser <> 2626)
                    SET @Where = ' WHERE (SiSaler = ' + CONVERT(VARCHAR,@SiUser) + ') AND LEFT(Dat_SalReqToContractDate,4) = ''' + @Adate + ''''
                IF (@BossApp <> 1) AND (@SiUser = 2626)
                    SET @Where = ' WHERE ((SiSaler = ' + CONVERT(VARCHAR,@SiUser) + ') OR (SiSaler = 8)) AND LEFT(Dat_SalReqToContractDate,4) = ''' + @Adate + ''''
                IF (@BossApp = 1)
                    SET @Where = ' WHERE LEFT(Dat_SalReqToContractDate,4) = ''' + @Adate + ''''
            END
            ELSE
            BEGIN
                SET @Adate = LEFT(dbo.Tss_MiladyToShamsiPar(GETDATE()),4)
                IF (@BossApp <> 1) AND (@SiUser <> 2626)
                    SET @Where = ' WHERE (SiSaler = ' + CONVERT(VARCHAR,@SiUser) + ') AND LEFT(Dat_SalReqToContractDate,4) = ''' + @Adate + ''''
                IF (@BossApp <> 1) AND (@SiUser = 2626)
                    SET @Where = ' WHERE ((SiSaler = ' + CONVERT(VARCHAR,@SiUser) + ') OR (SiSaler = 8)) AND LEFT(Dat_SalReqToContractDate,4) = ''' + @Adate + ''''
                IF (@BossApp = 1)
                    SET @Where = '' -- This was missing in the original code
            END
        END
    END
    ELSE
    BEGIN
        IF @InternalWhere <> ''     
           SET @InternalWhere = ' WHERE ' + @InternalWhere    
        IF (@Where <> '') AND (@Where <> 'Request')     
           SET @Where = ' WHERE ' + @Where  
        ELSE
        BEGIN
            IF (dbo.Tss_StdFindSubLoc(0) = 'Nekoo') OR (dbo.Tss_StdFindSubLoc(0) = 'aeen') OR (dbo.Tss_StdFindSubLoc(0) = 'Delta')
            BEGIN
                SET @Adate = LEFT(dbo.Tss_MiladyToShamsiPar(GETDATE()),4)
                SET @Where = ' WHERE LEFT(Dat_SalReqToContractDate,4) = ''' + @Adate + ''''
            END
            ELSE
            BEGIN
                SET @Adate = LEFT(dbo.Tss_MiladyToShamsiPar(GETDATE()),4)
                SET @Where = ' WHERE LEFT(Dat_SalReqToContractDate,4) = ''' + @Adate + ''''
            END
        END
    END
END
If @Order<>''     
   Set @Order=' Order By '+@Order 
Else
	Set @Order='ORDER BY Dat_SalReqToContractDate desc, Cod_SaleAgreement2 desc '
--	Set @Order='ORDER BY Dat_SalReqToContractDate desc, dbo.Tss_StdFindSumOfLettersAsccii(Cod_SaleAgreement2) desc '


SET @Sql =  
'Select * From  
   (  
	SELECT    
		IvcHd.Sta_ErsalStatus, 
		dbo.Tss_StdStaLabelsUdf(1126, IvcHd.Sta_ContractStatus) AS DesSta_ErsalStatus, 
		IvcHd.Sta_DiscountState, 
		dbo.Tss_SalInvoicePriceUdf(3, IvcHd.SiSalInvoice_Hd) AS TotalRow, 
		dbo.Tss_SalInvoicePriceUdf(1, IvcHd.SiSalInvoice_Hd) AS SrvPrc, 
		dbo.Tss_SalInvoicePriceUdf(2, IvcHd.SiSalInvoice_Hd) AS AllPrc, 
		IvcHd.SiSalInvoice_Hd,
		IvcHd.SiSalTypeOfSales,
		IvcHd.SiPubCustomCodes, 
		IvcHd.SiPubPersonsSpec, 
		IvcHd.Cod_SaleAgreement, 
		IvcHd.Cod_SaleAgreementChange,
		IvcHd.Des_SaleAgreementDesc, 
		IvcHd.Dat_SaleRequestRegDate,
		IvcHd.Num_SaleAgreementPriority,
		IvcHd.Cod_LetterNo, 
		IvcHd.Num_PreRecieveAmount, 
		IvcHd.Num_DiscountAmount,
		IvcHd.Dat_SalReqToContractDate, 
		IvcHd.Des_HeaderDesc, 
		IvcHd.Des_EndDocDesc,
		IvcHd.Sta_Kosoorat, 
		IvcHd.Num_ProductionTelorance, 
		IvcHd.Sta_ContractStatus, 
		dbo.Tss_StdStaLabelsUdf(1076, IvcHd.Sta_ContractStatus) AS DesSta_ContractStatus, 
		dbo.Tss_StdStaLabelsUdf(1077, IvcHd.Sta_ForProdOrSale) AS DesSta_ForProdOrSale, 
		IvcHd.Sta_ContractFormStatus, 
		dbo.Tss_StdStaLabelsUdf(1075, IvcHd.Sta_ContractFormStatus) AS Des_ContractFormStatus, 
		IvcHd.StmSalInvoice_Hd,
		IvcHd.Sta_TransportState, 
		IvcHd.Sta_ForProdOrSale,
		IvcHd.Sta_MainOrNot, 
		dbo.Tss_StdStaLabelsUdf(1081, IvcHd.Sta_MainOrNot) AS Des_MainOrNot, 
		IvcHd.Cod_SaleAgreement2, 
		pMazroof.Cod_CustomCodesCode AS cMazrof, 
		pMazroof.Des_CustomCodesDesc AS pMazrof, 
		pCust.Cod_PubPersonCode, 
		pCust.Des_FullName AS TpFullName,
		pSenf.Cod_CustomCodesCode AS cSenf, 
		pSenf.Des_CustomCodesDesc AS pSenf, 
		pCust.Des_FullName + SPACE(2) + ISNULL(pSenf.Des_CustomCodesDesc, SPACE(0)) AS Tp_NewFullName, 
		SalType.Cod_SalTypeCode, 
		SalType.Des_SalTypeDesc, 
		IvcHd.Des_SalInvoiceChangeDesc, 
		IvcHd.Des_SalInvoiceChangeDescOld, 
		IvcHd.Dat_SalConfirmOfProdDate,
		IvcHd.SiSalInvoiceRepeat_Hd,
		Tss_SalInvoice_Hd_1.Cod_SaleAgreement2 AS Cod_SaleAgreement2Repeat, 
		Tss_SalInvoice_Hd_1.Dat_SaleRequestRegDate AS Dat_SaleRequestRegDateRepeat, 
		IvcHd.SiPubPersonsSpecEditor, 
		Tss_PubPersonsViw_1.Cod_PubPersonCode AS Cod_PubPersonCodeEditor, 
		Tss_PubPersonsViw_1.Des_FullName AS Des_FullNameEditor, 
		Tss_PubSubLocations.Cod_SubLocCode, 
		Tss_PubSubLocations.Des_SubLocName, 
		Tss_PubSubLocations.SiPubSubLocations, 
		IvcHd.Dat_ApprovedForProd, 
		Saler.SiPubPersonsSpec AS SiSaler, 
		Saler.Cod_PubPersonCode AS CodSaler, 
		Saler.Des_FullName AS DesSaler, 
		pCust.SiPerRelatedSaler, 
		IvcHd.Tss_SalInvoice_HdRegTime,
		IvcHd.Tss_SalInvoice_HdEditTime,
		IvcHd.Tss_SalInvoice_HdRegisterer,
		IvcHd.Tss_SalInvoice_HdEditor,
		Registerer.Cod_PubPersonCode AS CodRegisterer, 
		Registerer.Des_FullName AS DesRegisterer, 
		Editor.Cod_PubPersonCode AS CodEditor, 
		Editor.Des_FullName AS DesEditor, 
		IvcHd.Sta_Branch, 
		IvcHd.Sta_CurrencyType, 
		dbo.Tss_StdStaLabelsUdf(1125, IvcHd.Sta_CurrencyType) AS Sta_CurrencyTypeDes, 
		IvcHd.Num_CurrencyRate
	FROM            
		Tss_SalInvoice_Hd AS IvcHd 
		INNER JOIN Tss_PubPersonsViw AS pCust ON IvcHd.SiPubPersonsSpec = pCust.SiPubPersonsSpec 
		LEFT OUTER JOIN Tss_PubPersonsViw AS Editor ON IvcHd.Tss_SalInvoice_HdEditor = Editor.SiPubPersonsSpec 
		LEFT OUTER JOIN Tss_PubPersonsViw AS Registerer ON IvcHd.Tss_SalInvoice_HdRegisterer = Registerer.SiPubPersonsSpec 
		LEFT OUTER JOIN Tss_PubPersonsViw AS Saler ON pCust.SiPerRelatedSaler = Saler.SiPubPersonsSpec 
		LEFT OUTER JOIN Tss_PubSubLocations ON IvcHd.SiPubSubLocations = Tss_PubSubLocations.SiPubSubLocations 
		LEFT OUTER JOIN Tss_PubPersonsViw AS Tss_PubPersonsViw_1 ON IvcHd.SiPubPersonsSpecEditor = Tss_PubPersonsViw_1.SiPubPersonsSpec 
		LEFT OUTER JOIN Tss_SalInvoice_Hd AS Tss_SalInvoice_Hd_1 ON IvcHd.SiSalInvoiceRepeat_Hd = Tss_SalInvoice_Hd_1.SiSalInvoice_Hd 
		LEFT OUTER JOIN Tss_PubCustomCodes AS pSenf ON pCust.SiPubCustomCodesCoActivity = pSenf.SiPubCustomCodes 
		LEFT OUTER JOIN Tss_PubCustomCodes AS pMazroof ON IvcHd.SiPubCustomCodes = pMazroof.SiPubCustomCodes 
		LEFT OUTER JOIN Tss_SalTypeOfSales AS SalType ON IvcHd.SiSalTypeOfSales = SalType.SiSalTypeOfSales 
	WHERE     
		(isnull(IvcHd.Sta_ContIsLaminate,0) = 1)
   ) CalcSel ' + @Where + SPACE(1) + @Order

EXEC(@Sql)

go

alter PROCEDURE Tss_SalUntInvoice_DtVStp2
(
   @InternalWhere VarChar(8000)='',
   @Where VarChar(8000)='',
   @Order VarChar(8000)=''
) AS 

Set arithabort ON
Set concat_null_yields_null ON
Set ansi_nulls ON
Set ansi_null_dflt_on ON
Set ansi_padding ON
Set ansi_warnings ON
Set quoted_identifier ON


If @InternalWhere<>'' 
   Set @InternalWhere=' Where '+@InternalWhere
If @Where<>'' 
   Set @Where=' Where '+@Where
If @Order<>'' 
   Set @Order=' Order By '+@Order
Exec(
'Select * From 
(
   Select * From 
   (
SELECT
    Tsid.Num_CommisionFee,
    Tsid.Sta_IsCommisionPercent,
    Tsid.Sta_IsCommisionArea,
    Tsid.Num_CustomerTarkibiWidth, 
    Tsid.Sta_HasDesign, Tsid.Num_GdsPalleteFee, 
    Tsid.Num_FeeHaml, 
    Tsid.SiSalInvoice_Dt, 
    Tsid.Num_NoOfPrintingSides, 
    Tsid.Num_WidthPert, 
    Tsid.Num_LengthPert, 
    Tsid.SiPubCustomCodesColor1, 
    Tsid.SiPubCustomCodesColor2, 
    Tsid.SiPubCustomCodesColor3, 
    Tsid.SiPubCustomCodesColo4, 
    Tsid.SiSalInvoice_Hd, 
    Tsid.SiPrcGoodsType, 
    Tsid.SiPrcFlutType, 
    Tsid.SiPubGoods, 
    Tsid.SiPubGoodsClassify, 
    Tsid.Num_SalInvoiceDetRow, 
    Tsid.Num_GdsAmountNo, 
    Tsid.Num_ColoringRate, 
    Tsid.Num_GdsArea, 
    Tsid.Num_GdsFee, 
    Tsid.Num_GdsBalancFee, 
    Tsid.Num_GdsBalancFee * Tsid.Num_GdsAmountNo AS RowPrice, 
    Tsid.Num_SampleInnerLength, 
    Tsid.Num_SampleInnerWidth, 
    Tsid.Num_SampleInnerHeigth, 
    Tsid.Num_SampleHoleNo, 
    Tsid.Num_SampleMasrafCoefOfBox, 
    Tsid.Sta_HasMangene, 
    Tsid.Sta_IsLipStick, 
    Tsid.Num_GdsColorFee, 
    Tsid.Num_GdsDieFee, 
    Tsid.Num_FeeAdjust, Tsid.StmSalInvoice_Dt, Tsid.SiPrcKelisheSpec, 
    Tsid.Num_GoodsLength, 
    Tsid.Num_GoodsWidth, 
    (convert(numeric,Tsid.Num_GoodsLength)*convert(numeric,Tsid.Num_GoodsWidth))/1000000 as VaraghArea,
    Tsid.Num_GoodsUnitWeight, ROUND(Tsid.Num_GoodsUnitWeight * Tsid.Num_GdsAmountNo / 1000, 0) AS Tonage, Color1.Cod_CustomCodesCode AS cCol1, 
    Color1.Des_CustomCodesDesc AS nCol1, 
    Color2.Cod_CustomCodesCode AS cCol2, Color2.Des_CustomCodesDesc AS nCol2, Color3.Cod_CustomCodesCode AS cCol3, Color3.Des_CustomCodesDesc AS nCol3, 
    Color4.Cod_CustomCodesCode AS cCol4, 
    Color4.Des_CustomCodesDesc AS nCol4, Tpgt.Cod_PrcGoodsTypeCode, Tpgt.Des_PrcGoodsTypeDesc, Tss_PrcFlutType.Cod_FlutTypeCode,
    Tss_PrcFlutType.Des_FlutTypeName, Tss_PubGoods.Cod_PubGoodsCode, 
    Tss_PubGoods.Des_PubGoodsDesc, Tss_PubGoodsClassify.Cod_GoodsClassCode AS Code_Jens, Tss_PubGoodsClassify.Des_GoodsClassDesc AS Name_Jens, 
    Tss_PrcKelisheSpec.Cod_KelisheSpecCode, 
    Tss_PrcKelisheSpec.Des_KelisheSpecDesc, Tsid.SiPrcDieSpec, Tss_PrcDieSpec.Cod_DieSpecCode, 
    Tss_PrcDieSpec.Des_DieSpecDesc+'+''''+' - '+''''+'+convert(varchar,Tss_PrcDieSpec.Num_NoGdsInDie)+'+''''+' تايي '+''''+' as Des_DieSpecDesc,
    Tsid.Sta_Cyan, Tsid.Sta_Magenta, Tsid.Sta_Yellow, Tsid.Sta_Black, Tsid.Sta_HasVerni, Tsid.Num_VaraghCreaseAmt, 
    Tsid.Sta_HoleSide, Tsid.Sta_CatchSide, Tsid.Sta_PrintArm, Tsid.Sta_PackType, 
    Tsid.Num_OneMeterSheetPrice, Tsid.Num_OneMeterBoxPrice, Tsid.SiPubCustomCodes, Tsid.Cod_SampleGdsCode, 
    Mazroof.Cod_CustomCodesCode AS CodMazDt, Mazroof.Des_CustomCodesDesc AS DesMazDt, 
    Tsid.Sta_EttesalType, Tsid.Sta_HasGooshvareh, Tsid.Num_UpDoorOpenSize, Tsid.Num_DownDoorOpenSize, 
    Tsid.Num_SampleOuterLength, Tsid.Num_SampleOuterWidth, Tsid.Num_SampleOuterHeigth, 
    Tsid.Num_VaraghUpDoorAmt, Tsid.Num_VaraghDownDoorAmt, Tsid.Sta_IsDoubleCrease, 
    Tsid.Sta_ShowJens, Tsid.Sta_ShowJensBrief, Tsid.Sta_HighSensibility, Tsid.Num_ContLabChasbConst, Tsid.Sta_OuterPrint, 
    Tsid.SiInvBuyReq_Dt, Tss_InvBuyReq_Dt.Num_BuyReqN, Tss_InvBuyReq_Dt.Cod_BuyReqDtCode, Tss_InvBuyReq_Hd.Cod_BuyReqHdCode, 
    Tss_InvBuyReq_Hd.Dat_BuyReqHdDate, Tss_InvBuyReq_Hd.SiInvBuyReq_Hd, 
    Tsid.Num_GdsInWidthBuyReq, Tsid.Num_GdsInLengthBuyReq, Tpgt.Sta_TipOfGoodsType, Tsid.Tss_SalInvoice_DtRegTime, 
    Tsid.Tss_SalInvoice_DtEditTime, Tsid.Tss_SalInvoice_DtRegisterer, Tsid.Tss_SalInvoice_DtEditor, 
    Registerer.Cod_PubPersonCode AS CodRegisterer, Registerer.Des_FullName AS DesRegisterer, 
    Editor.Cod_PubPersonCode AS CodEditor, Editor.Des_FullName AS DesEditor, Tsid.SiPubCustomCodesColor5, 
    Tsid.SiPubCustomCodesColor6, Color5.Cod_CustomCodesCode AS cCol5, Color5.Des_CustomCodesDesc AS nCol5, 
    Color6.Cod_CustomCodesCode AS cCol6, Color6.Des_CustomCodesDesc AS nCol6, Tsid.Num_NoInPallete, 
    Tsid.SiSalInvoiceDtCopiedFrom, Tsid.Sta_IsFeeAdjustPercent, Tsid.Num_GdsFeeRounder, Tsid.Sta_CellophaneType, 
    Tsid.Sta_MatteOrGlossy, Tsid.Num_GdsLaminateFee, Tsid.SiPubGoodsClassifyCardBox, 
    Tss_PubGoodsClassifyCardBox.Cod_GoodsClassCode AS Cod_GoodsClassCodeCardBox, Tss_PubGoodsClassifyCardBox.Des_GoodsClassDesc AS Des_GoodsClassDescCardBox, 
    Tpgt.Sta_LaminateType, 
    Tsid.SiSalInvoice_DtCombinee, Tss_PubGoodsViw.Des_PubGoodsDesc AS CombineeeGdsDes, Tss_PubGoodsViw.Cod_PubGoodsCode AS CombineeeGdsCod, 
    Tss_SalInvoiceGoodsViw.Cod_SaleAgreement2 CombineeeContNo,
    Tsid.LamDieLen, Tsid.LamDieWid, Tsid.LamDieNo, 
    Tsid.LamCardBoardLen, 
    Tsid.LamCardBoardWid, 
    Tsid.LamCardBoardLen*Tsid.LamCardBoardWid/1000000 as LamCardBoardArea,
    Tsid.LamCardBoardFee, 
    Tsid.LamCalcPert, Tsid.LamCorrugRoleWid, Tsid.LamCorrugPert, Tsid.LamLaminateFee, Tsid.LamDieFee, Tsid.LamSiHamlGeoPlace, Tsid.LamPrintType, Tsid.LamPrintTypeS, 
    Tsid.LamPrintTypeG, Tsid.LamPrintTypeP1, Tsid.LamPrintTypeP2, 
    Tsid.LamPrintTypeP3, Tsid.LamPrintTypeP4, Tsid.LamJointNo, Tsid.LamJointAuto, Tsid.LamJointSemiAuto, Tsid.LamJointHand, Tsid.LamJointTwoPiece, 
    Tsid.LamJointLockBottom, Tsid.LamJointFourPoint, Tsid.LamJointPunch, 
    Tsid.LamPackNo, Tsid.LamPackStrap, Tsid.LamPackStrapBaGuard, Tsid.LamPackShrink, Tsid.LamPackMotherBox, Tsid.LamPackNylon, Tsid.LamPackPallete, 
    Tsid.LamBelongZinkPrice, Tsid.LamBelongDiePrice, 
    Tsid.LamBelongKelishePrice, Tsid.LamBelongHandlePrice, Tsid.LamBelongTalcPrice, Tsid.LamBelongCardBoardUnitFee, Tsid.LamBelongSheetUnitFee, 
    Tsid.LamBelongPrintUnitFee, Tsid.LamBelongColorUnitFee, 
    Tsid.LamBelongCoverUnitFee, Tsid.LamBelongLaminateUnitFee, Tsid.LamBelongJointUnitFee, Tsid.LamBelongPackUnitFee, Tsid.LamBelongTransportUnitFee, 
    Tsid.LamOtherCosts, Tsid.LamCalcBelongCosts, Tsid.LamBelongCosts, 
    Tss_PubGeoPlac.Cod_GeoPlaceCode, Tss_PubGeoPlac.Des_GeoPlaceName, Tss_PubGeoPlac.Num_L3VaraghTransFee, Tss_PubGeoPlac.Num_L3BoxTransFee, Tss_PubGeoPlac.Num_L5VaraghTransFee, 
    Tss_PubGeoPlac.Num_L5BoxTransFee,
    Tsid.LamCoverLen,
    Tsid.LamCoverWid,
    Tsid.LamCoverLen*Tsid.LamCoverWid/1000000 as LamCoverArea,
    Tsid.LamCoverGlassy ,
    Tsid.LamCoverMatt ,
    Tsid.LamCoverMetallize ,
    Tsid.LamCoverVerni ,
    Tsid.LamCoverUV,
    Tsid.LamDesc,
    Tsid.Num_ActualFeeAdjust,
    Tpgt.Sta_DieOrNot,
    $0.0 as FactoredAmt,
    Tsid.LamHandJointNo, 
    Tsid.LamSemiAutoJointNo, 
    Tsid.LamTwoPieceJointNo, 
    Tsid.LamLockBottomJointNo, 
    Tsid.LamFourPointJointNo, 
    Tsid.LamAutoJointNo, 
    Tsid.LamStrapWithGuardNo, 
    Tsid.LamShrinkNo, 
    Tsid.LamMotherBoxNo, 
    Tsid.LamNylonNo, 
    Tsid.SiPrcPackagingTypes, 
    Tss_PrcPackagingTypes.Cod_PackagingTypesCode,
    Tss_PrcPackagingTypes.Des_PackagingTypesDesc,
    Tss_PrcPackagingTypes.Num_PackagingTypesCost, 
    Tss_PrcPackagingTypes.Sta_PackagingType,
    dbo.Tss_StdStaLabelsUdf(1134,Tss_PrcPackagingTypes.Sta_PackagingType) Sta_PackagingTypeDes
FROM            
    Tss_PrcPackagingTypes RIGHT OUTER JOIN
    Tss_SalInvoice_Dt AS Tsid ON Tss_PrcPackagingTypes.SiPrcPackagingTypes = Tsid.SiPrcPackagingTypes LEFT OUTER JOIN
    Tss_PubGeoPlac ON Tsid.LamSiHamlGeoPlace = Tss_PubGeoPlac.SiPubGeoPlac LEFT OUTER JOIN
    Tss_PubGoodsViw INNER JOIN
    Tss_SalInvoiceGoodsViw ON Tss_PubGoodsViw.SiPubGoods = Tss_SalInvoiceGoodsViw.SiPubGoods ON Tsid.SiSalInvoice_DtCombinee = Tss_SalInvoiceGoodsViw.SiSalInvoice_Dt LEFT OUTER JOIN
    Tss_PubGoodsClassify AS Tss_PubGoodsClassifyCardBox ON Tsid.SiPubGoodsClassifyCardBox = Tss_PubGoodsClassifyCardBox.SiPubGoodsClassify LEFT OUTER JOIN
    Tss_PubGoodsClassify ON Tsid.SiPubGoodsClassify = Tss_PubGoodsClassify.SiPubGoodsClassify LEFT OUTER JOIN
    Tss_PubCustomCodes AS Color6 ON Tsid.SiPubCustomCodesColor6 = Color6.SiPubCustomCodes LEFT OUTER JOIN
    Tss_PubCustomCodes AS Color1 ON Tsid.SiPubCustomCodesColor1 = Color1.SiPubCustomCodes LEFT OUTER JOIN
    Tss_PubCustomCodes AS Color4 ON Tsid.SiPubCustomCodesColo4 = Color4.SiPubCustomCodes LEFT OUTER JOIN
    Tss_PubCustomCodes AS Color2 ON Tsid.SiPubCustomCodesColor2 = Color2.SiPubCustomCodes LEFT OUTER JOIN
    Tss_PubCustomCodes AS Color5 ON Tsid.SiPubCustomCodesColor5 = Color5.SiPubCustomCodes LEFT OUTER JOIN
    Tss_PubCustomCodes AS Mazroof ON Tsid.SiPubCustomCodes = Mazroof.SiPubCustomCodes LEFT OUTER JOIN
    Tss_PubCustomCodes AS Color3 ON Tsid.SiPubCustomCodesColor3 = Color3.SiPubCustomCodes LEFT OUTER JOIN
    Tss_PubPersonsViw AS Editor ON Tsid.Tss_SalInvoice_DtEditor = Editor.SiPubPersonsSpec LEFT OUTER JOIN
    Tss_PubPersonsViw AS Registerer ON Tsid.Tss_SalInvoice_DtRegisterer = Registerer.SiPubPersonsSpec LEFT OUTER JOIN
    Tss_InvBuyReq_Dt INNER JOIN
    Tss_InvBuyReq_Hd ON Tss_InvBuyReq_Dt.SiInvBuyReq_Hd = Tss_InvBuyReq_Hd.SiInvBuyReq_Hd ON Tsid.SiInvBuyReq_Dt = Tss_InvBuyReq_Dt.SiInvBuyReq_Dt LEFT OUTER JOIN
    Tss_PrcGoodsType AS Tpgt ON Tsid.SiPrcGoodsType = Tpgt.SiPrcGoodsType LEFT OUTER JOIN
    Tss_PrcFlutType ON Tsid.SiPrcFlutType = Tss_PrcFlutType.SiPrcFlutType LEFT OUTER JOIN
    Tss_PrcDieSpec ON Tsid.SiPrcDieSpec = Tss_PrcDieSpec.SiPrcDieSpec LEFT OUTER JOIN
    Tss_PrcKelisheSpec ON Tsid.SiPrcKelisheSpec = Tss_PrcKelisheSpec.SiPrcKelisheSpec LEFT OUTER JOIN
    Tss_PubGoods ON Tsid.SiPubGoods = Tss_PubGoods.SiPubGoods


) Ccc '+@InternalWhere+'
) CalcSel ' + @Where + @Order)


go

alter PROCEDURE Tss_SalUntInvoice_HdVStp  
(    
   @InternalWhere VarChar(8000)='',   
   @Where VarChar(8000)='',   
   @Order VarChar(8000)='',
   @SenderForm smallint=0,
   @SiUser Numeric=2   
) 
AS     

Set arithabort ON
Set concat_null_yields_null ON
Set ansi_nulls ON
Set ansi_null_dflt_on ON
Set ansi_padding ON
Set ansi_warnings ON
Set quoted_identifier ON


set @InternalWhere = isnull(@InternalWhere,'')
set @Where = isnull(@Where,'')
set @Order = isnull(@Order,'')

Declare 
	@SaleMali nvarchar(4),
	@Cod_AccFinancePeriod nvarchar(50),
	@Sql varchar(8000),
	@Adate nvarchar(7),
	@BossApp smallint,
	@CurrentMonth nvarchar(7),
	@HasCurrentMonthData bit = 0


-- NEW: Get current month and check if it has data
SET @CurrentMonth = left(dbo.Tss_MiladyToShamsiPar(GetDate()),7)

-- Check if current month has ANY invoice data (simplified check)
IF EXISTS (SELECT 1 FROM Tss_SalInvoice_Hd WHERE (Sta_ContractStatus = 9) and LEFT(Dat_SaleRequestRegDate,7) = @CurrentMonth)
   OR EXISTS (SELECT 1 FROM Tss_SalInvoice_Hd WHERE (Sta_ContractStatus <> 9) and LEFT(Dat_SalReqToContractDate,7) = @CurrentMonth)
    SET @HasCurrentMonthData = 1

IF @HasCurrentMonthData = 1
    SET @Adate = @CurrentMonth
ELSE
BEGIN
    -- Find the most recent month that has data
	if @SenderForm = 1
		SELECT TOP 1 @Adate = LEFT(Dat_SaleRequestRegDate,7)
		FROM Tss_SalInvoice_Hd
		WHERE (Sta_ContractStatus = 9) and LEFT(Dat_SaleRequestRegDate,7) IS NOT NULL
		ORDER BY LEFT(Dat_SaleRequestRegDate,7) DESC

 	if @SenderForm = 0
		SELECT TOP 1 @Adate = LEFT(Dat_SalReqToContractDate,7)
		FROM Tss_SalInvoice_Hd
		WHERE (Sta_ContractStatus <> 9) and LEFT(Dat_SalReqToContractDate,7) IS NOT NULL
		ORDER BY LEFT(Dat_SalReqToContractDate,7) DESC

    IF @Adate IS NULL
        SET @Adate = @CurrentMonth
END

Select @BossApp = dbo.Tss_StdFindIfUserIsInGroup(@SiUser,'BossApp')

If @Order<>''     
   Set @Order=' Order By '+@Order 
Else
begin
	If @SenderForm=1
		Set @Order='ORDER BY Dat_SaleRequestRegDate desc, isnull(Dat_SalReqToContractDate,'''') desc, isnull(Cod_SaleAgreement2,'''') desc '

	If @SenderForm=0
		Set @Order='ORDER BY isnull(Dat_SalReqToContractDate,'''') desc, isnull(Cod_SaleAgreement2,'''') desc '
end

--	Set @Order='ORDER BY Dat_SalReqToContractDate desc, dbo.Tss_StdFindSumOfLettersAsccii(Cod_SaleAgreement2) desc '


if dbo.Tss_StdFindIfUserIsInGroup(@SiUser,'SaleApprover') <> 1
BEGIN

	If (@Where='')
		Set @Where=' Where left(Dat_SaleRequestRegDate,7)='+''''+@Adate+''''	
	else
	begin
		If @SenderForm = 1
		Begin
			if (@BossApp <> 1)
			Begin
				if (@Where  = 'Sta_ContractStatus = 9')
					Set @Where = 'Where (Sta_ContractStatus = 9) And left(Dat_SaleRequestRegDate,7)='+''''+@Adate+''''+ ' And ' + @Where
				Else
					Set @Where = 'Where (Sta_ContractStatus = 9) And ' + @Where
			End
			Else
			Begin
				if (@Where  = 'Sta_ContractStatus = 9')
					Set @Where = 'Where (SiSaler ='+convert(varchar,@SiUser)+') and  (Sta_ContractStatus = 9) And left(Dat_SaleRequestRegDate,7)='+''''+@Adate+''''+ ' And ' + @Where
				Else
					Set @Where = 'Where (Sta_ContractStatus = 9) And ' + @Where
			End
		End

		If @SenderForm = 0
		Begin
			if (@BossApp <> 1)
			Begin
				if (@Where  = 'Sta_ContractStatus <> 9')
					Set @Where = 'Where (Sta_ContractStatus <> 9) And left(Dat_SalReqToContractDate,7)='+''''+@Adate+''''+ ' And ' + @Where
				Else
					Set @Where = 'Where (Sta_ContractStatus <> 9) And ' + @Where
			End
			Else
			Begin
				if (@Where  = 'Sta_ContractStatus <> 9')
					Set @Where = 'Where (SiSaler ='+convert(varchar,@SiUser)+') and  (Sta_ContractStatus <> 9) And left(Dat_SalReqToContractDate,7)='+''''+@Adate+''''+ ' And ' + @Where
				Else
					Set @Where = 'Where (Sta_ContractStatus <> 9) And ' + @Where
			End
		End
	end
END
Else
Begin
	If (@Where='')
		Set @Where=' Where left(Dat_SaleRequestRegDate,7)='+''''+@Adate+''''	
	else
	begin
		If @SenderForm = 1
		Begin
			if (@Where  = 'Sta_ContractStatus = 9')
				Set @Where = 'Where (Sta_ContractStatus = 9) And left(Dat_SaleRequestRegDate,7)='+''''+@Adate+''''+ ' And ' + @Where
			Else
				Set @Where = 'Where (Sta_ContractStatus = 9) And ' + @Where
		End

		If @SenderForm = 0
		Begin
			if (@Where  = 'Sta_ContractStatus <> 9')
				Set @Where = 'Where (Sta_ContractStatus <> 9) And left(Dat_SalReqToContractDate,7)='+''''+@Adate+''''+ ' And ' + @Where
			Else
				Set @Where = 'Where (Sta_ContractStatus <> 9) And ' + @Where
		End
	end
End
	


Set @Sql=  
'Select * From  
   (  
	SELECT    
		IvcHd.Sta_ErsalStatus, 
		dbo.Tss_StdStaLabelsUdf(1126, IvcHd.Sta_ContractStatus) AS DesSta_ErsalStatus, 
		IvcHd.Sta_DiscountState, 
		dbo.Tss_SalInvoicePriceUdf(3, IvcHd.SiSalInvoice_Hd) AS TotalRow, 
		dbo.Tss_SalInvoicePriceUdf(1, IvcHd.SiSalInvoice_Hd) AS SrvPrc, 
		dbo.Tss_SalInvoicePriceUdf(2, IvcHd.SiSalInvoice_Hd) AS AllPrc, 
		IvcHd.SiSalInvoice_Hd, 
		IvcHd.SiSalTypeOfSales, 
		IvcHd.SiPubCustomCodes, 
		IvcHd.SiPubPersonsSpec, 
		IvcHd.Cod_SaleAgreement, 
		IvcHd.Cod_SaleAgreementChange, 
		IvcHd.Des_SaleAgreementDesc, 
		IvcHd.Dat_SaleRequestRegDate, 
		IvcHd.Num_SaleAgreementPriority, 
		IvcHd.Cod_LetterNo, 
		IvcHd.Num_PreRecieveAmount, 
		IvcHd.Num_DiscountAmount, 
		IvcHd.Dat_SalReqToContractDate, 
		IvcHd.Des_HeaderDesc, 
		IvcHd.Des_EndDocDesc, 
		IvcHd.Sta_Kosoorat, 
		IvcHd.Num_ProductionTelorance, 
		IvcHd.Sta_ContractStatus, 
		dbo.Tss_StdStaLabelsUdf(1076, IvcHd.Sta_ContractStatus) AS DesSta_ContractStatus, 
		dbo.Tss_StdStaLabelsUdf(1077, IvcHd.Sta_ForProdOrSale) AS DesSta_ForProdOrSale, 
		IvcHd.Sta_ContractFormStatus, 
		dbo.Tss_StdStaLabelsUdf(1075, IvcHd.Sta_ContractFormStatus) AS Des_ContractFormStatus, 
		IvcHd.StmSalInvoice_Hd, 
		IvcHd.Sta_TransportState, 
		IvcHd.Sta_ForProdOrSale, 
		IvcHd.Sta_MainOrNot, 
		dbo.Tss_StdStaLabelsUdf(1081, IvcHd.Sta_MainOrNot) AS Des_MainOrNot, 
		IvcHd.Cod_SaleAgreement2, 
		pMazroof.Cod_CustomCodesCode AS cMazrof, 
		pMazroof.Des_CustomCodesDesc AS pMazrof, 
		pCust.Cod_PubPersonCode, 
		pCust.Des_FullName AS TpFullName, 
		pSenf.Cod_CustomCodesCode AS cSenf, 
		pSenf.Des_CustomCodesDesc AS pSenf, 
		pCust.Des_FullName + SPACE(2) + ISNULL(pSenf.Des_CustomCodesDesc, SPACE(0)) AS Tp_NewFullName, 
		SalType.Cod_SalTypeCode, 
		SalType.Des_SalTypeDesc, 
		IvcHd.Des_SalInvoiceChangeDesc, 
		IvcHd.Des_SalInvoiceChangeDescOld, 
		IvcHd.Dat_SalConfirmOfProdDate, 
		IvcHd.SiSalInvoiceRepeat_Hd, 
		Tss_SalInvoice_Hd_1.Cod_SaleAgreement2 AS Cod_SaleAgreement2Repeat, 
		Tss_SalInvoice_Hd_1.Dat_SaleRequestRegDate AS Dat_SaleRequestRegDateRepeat, 
		IvcHd.SiPubPersonsSpecEditor, 
		Tss_PubPersonsViw_1.Cod_PubPersonCode AS Cod_PubPersonCodeEditor, 
		Tss_PubPersonsViw_1.Des_FullName AS Des_FullNameEditor,
		Tss_PubSubLocations.Cod_SubLocCode, 
		Tss_PubSubLocations.Des_SubLocName, 
		Tss_PubSubLocations.SiPubSubLocations, 
		IvcHd.Dat_ApprovedForProd, 
		Saler.SiPubPersonsSpec AS SiSaler, 
		Saler.Cod_PubPersonCode AS CodSaler, 
		Saler.Des_FullName AS DesSaler, 
		pCust.SiPerRelatedSaler, 
		IvcHd.Tss_SalInvoice_HdRegTime, 
		IvcHd.Tss_SalInvoice_HdEditTime, 
		IvcHd.Tss_SalInvoice_HdRegisterer, 
		IvcHd.Tss_SalInvoice_HdEditor, 
		Registerer.Cod_PubPersonCode AS CodRegisterer, 
		Registerer.Des_FullName AS DesRegisterer, 
		Editor.Cod_PubPersonCode AS CodEditor,
		Editor.Des_FullName AS DesEditor, 
		IvcHd.Sta_Branch, 
		IvcHd.Sta_CurrencyType, 
		dbo.Tss_StdStaLabelsUdf(1125,IvcHd.Sta_CurrencyType) as Sta_CurrencyTypeDes, 
		IvcHd.Num_CurrencyRate,
		isnull((SELECT TOP 1 Tss_PrcGoodsType.Sta_LaminateType FROM Tss_SalInvoice_Dt INNER JOIN Tss_PrcGoodsType ON Tss_SalInvoice_Dt.SiPrcGoodsType = Tss_PrcGoodsType.SiPrcGoodsType 
		where (Tss_SalInvoice_Dt.SiSalInvoice_Hd = IvcHd.SiSalInvoice_Hd)),10) as Sta_LaminateType,
		IvcHd.Num_CreditDays
	FROM            
		Tss_SalInvoice_Hd AS IvcHd INNER JOIN
		Tss_PubPersonsViw AS pCust ON IvcHd.SiPubPersonsSpec = pCust.SiPubPersonsSpec LEFT OUTER JOIN
		Tss_PubPersonsViw AS Editor ON IvcHd.Tss_SalInvoice_HdEditor = Editor.SiPubPersonsSpec LEFT OUTER JOIN
		Tss_PubPersonsViw AS Registerer ON IvcHd.Tss_SalInvoice_HdRegisterer = Registerer.SiPubPersonsSpec LEFT OUTER JOIN
		Tss_PubPersonsViw AS Saler ON pCust.SiPerRelatedSaler = Saler.SiPubPersonsSpec LEFT OUTER JOIN
		Tss_PubSubLocations ON IvcHd.SiPubSubLocations = Tss_PubSubLocations.SiPubSubLocations LEFT OUTER JOIN
		Tss_PubPersonsViw AS Tss_PubPersonsViw_1 ON IvcHd.SiPubPersonsSpecEditor = Tss_PubPersonsViw_1.SiPubPersonsSpec LEFT OUTER JOIN
		Tss_SalInvoice_Hd AS Tss_SalInvoice_Hd_1 ON IvcHd.SiSalInvoiceRepeat_Hd = Tss_SalInvoice_Hd_1.SiSalInvoice_Hd LEFT OUTER JOIN
		Tss_PubCustomCodes AS pSenf ON pCust.SiPubCustomCodesCoActivity = pSenf.SiPubCustomCodes LEFT OUTER JOIN
		Tss_PubCustomCodes AS pMazroof ON IvcHd.SiPubCustomCodes = pMazroof.SiPubCustomCodes LEFT OUTER JOIN
		Tss_SalTypeOfSales AS SalType ON IvcHd.SiSalTypeOfSales = SalType.SiSalTypeOfSales 
	where 
		(Isnull(IvcHd.Sta_ContIsLaminate,0) = 0)
	'+@InternalWhere+'
	) CalcSel ' + @Where + space(1)+@Order

Exec(@Sql)

go

alter   PROCEDURE dbo.Tss_SalUntInvoice_DtVStp
(
    @InternalWhere VARCHAR(8000) = '',
    @Where         VARCHAR(8000) = '',
    @Order         VARCHAR(8000) = ''
)
AS
BEGIN
    SET NOCOUNT ON;
    SET ARITHABORT ON;
    SET CONCAT_NULL_YIELDS_NULL ON;
    SET ANSI_NULLS ON;
    SET ANSI_NULL_DFLT_ON ON;
    SET ANSI_PADDING ON;
    SET ANSI_WARNINGS ON;
    SET QUOTED_IDENTIFIER ON;

    DECLARE @Sql          NVARCHAR(MAX);
    DECLARE @OrderClause  NVARCHAR(MAX);
    DECLARE @SalInvoiceHd INT = NULL;
    DECLARE @Trimmed      VARCHAR(8000) = LTRIM(RTRIM(@InternalWhere));

    -- Strip one layer of surrounding parentheses, e.g. '(SiSalInvoice_Hd=10044)'
    IF LEFT(@Trimmed, 1) = '(' AND RIGHT(@Trimmed, 1) = ')'
        SET @Trimmed = SUBSTRING(@Trimmed, 2, LEN(@Trimmed) - 2);

    -- Fast path: "give me the lines for one invoice" is the dominant call pattern.
    -- Detect it and bind a real, typed parameter so SQL Server can seek and
    -- reuse a cached plan, instead of scanning + recompiling every call.
	IF @Trimmed LIKE 'SiSalInvoice_Hd=%'
	   AND @Where = ''
	   AND ISNUMERIC(SUBSTRING(@Trimmed, 17, 8000)) = 1
	BEGIN
		SET @SalInvoiceHd = CONVERT(INT, SUBSTRING(@Trimmed, 17, 8000));
	END;

    SET @OrderClause = CASE
                            WHEN @Order <> '' THEN N' ORDER BY ' + @Order
                            ELSE N' ORDER BY Num_SalInvoiceDetRow'
                        END;

    IF @SalInvoiceHd IS NOT NULL
    BEGIN
        ------------------------------------------------------------------
        -- FAST PATH: qualified column, real parameter, index-seekable,
        -- plan-cacheable.
        ------------------------------------------------------------------
        SET @Sql = N'
        SELECT
            Tsid.Sta_PrintFeeArea, Tsid.Num_CommisionFee, Tsid.Sta_IsCommisionPercent,
            Tsid.Sta_IsCommisionArea, Tsid.Des_RowDesc, Tsid.Num_CustomerTarkibiWidth,
            Tsid.Sta_HasDesign, Tsid.Num_GdsPalleteFee, Tsid.Num_FeeHaml, Tsid.SiSalInvoice_Dt,
            Tsid.Num_NoOfPrintingSides, Tsid.Num_WidthPert, Tsid.Num_LengthPert,
            Tsid.SiPubCustomCodesColor1, Tsid.SiPubCustomCodesColor2, Tsid.SiPubCustomCodesColor3,
            Tsid.SiPubCustomCodesColo4, Tsid.SiSalInvoice_Hd, Tsid.SiPrcGoodsType, Tsid.SiPrcFlutType,
            Tsid.SiPubGoods, Tsid.SiPubGoodsClassify, Tsid.Num_SalInvoiceDetRow, Tsid.Num_GdsAmountNo,
            Tsid.Num_ColoringRate, Tsid.Num_GdsArea, Tsid.Num_GdsFee, Tsid.Num_GdsBalancFee,
            Tsid.Num_GdsBalancFee * Tsid.Num_GdsAmountNo               AS RowPrice,
            Tsid.Num_SampleInnerLength, Tsid.Num_SampleInnerWidth, Tsid.Num_SampleInnerHeigth,
            Tsid.Num_SampleHoleNo, Tsid.Num_SampleMasrafCoefOfBox, Tsid.Sta_HasMangene,
            Tsid.Sta_IsLipStick, Tsid.Num_GdsColorFee, Tsid.Num_GdsDieFee, Tsid.Num_FeeAdjust,
            Tsid.StmSalInvoice_Dt, Tsid.SiPrcKelisheSpec, Tsid.Num_GoodsLength, Tsid.Num_GoodsWidth,
            Tsid.Num_GoodsUnitWeight,
            ROUND(Tsid.Num_GoodsUnitWeight * Tsid.Num_GdsAmountNo / 1000, 0) AS Tonage,
            Color1.Cod_CustomCodesCode AS cCol1, Color1.Des_CustomCodesDesc AS nCol1,
            Color2.Cod_CustomCodesCode AS cCol2, Color2.Des_CustomCodesDesc AS nCol2,
            Color3.Cod_CustomCodesCode AS cCol3, Color3.Des_CustomCodesDesc AS nCol3,
            Color4.Cod_CustomCodesCode AS cCol4, Color4.Des_CustomCodesDesc AS nCol4,
            Tpgt.Cod_PrcGoodsTypeCode, Tpgt.Des_PrcGoodsTypeDesc,
            Tss_PrcFlutType.Cod_FlutTypeCode, Tss_PrcFlutType.Des_FlutTypeName,
            Tss_PubGoods.Cod_PubGoodsCode, Tss_PubGoods.Des_PubGoodsDesc,
            Tss_PubGoodsClassify.Cod_GoodsClassCode AS Code_Jens,
            Tss_PubGoodsClassify.Des_GoodsClassDesc AS Name_Jens,
            Tss_PrcKelisheSpec.Cod_KelisheSpecCode, Tss_PrcKelisheSpec.Des_KelisheSpecDesc,
Tsid.SiPrcDieSpec, Tss_PrcDieSpec.Cod_DieSpecCode,
            Tss_PrcDieSpec.Des_DieSpecDesc + N'' - '' + CONVERT(VARCHAR, Tss_PrcDieSpec.Num_NoGdsInDie) + N'' تايي '' AS Des_DieSpecDesc,
            Tsid.Sta_Cyan, Tsid.Sta_Magenta, Tsid.Sta_Yellow, Tsid.Sta_Black, Tsid.Sta_HasVerni,
            Tsid.Num_VaraghCreaseAmt, Tsid.Sta_HoleSide, Tsid.Sta_CatchSide, Tsid.Sta_PrintArm,
            Tsid.Sta_PackType, Tsid.Num_OneMeterSheetPrice, Tsid.Num_OneMeterBoxPrice,
            Tsid.SiPubCustomCodes, Tsid.Cod_SampleGdsCode,
            Mazroof.Cod_CustomCodesCode AS CodMazDt, Mazroof.Des_CustomCodesDesc AS DesMazDt,
            Tsid.Sta_EttesalType, Tsid.Sta_HasGooshvareh, Tsid.Num_UpDoorOpenSize, Tsid.Num_DownDoorOpenSize,
            Tsid.Num_SampleOuterLength, Tsid.Num_SampleOuterWidth, Tsid.Num_SampleOuterHeigth,
            Tsid.Num_VaraghUpDoorAmt, Tsid.Num_VaraghDownDoorAmt, Tsid.Sta_IsDoubleCrease,
            Tsid.Sta_ShowJens, Tsid.Sta_ShowJensBrief, Tsid.Sta_HighSensibility, Tsid.Num_ContLabChasbConst,
            Tsid.Sta_OuterPrint, Tsid.SiInvBuyReq_Dt, Tss_InvBuyReq_Dt.Num_BuyReqN,
            Tss_InvBuyReq_Dt.Cod_BuyReqDtCode, Tss_InvBuyReq_Hd.Cod_BuyReqHdCode,
            Tss_InvBuyReq_Hd.Dat_BuyReqHdDate, Tss_InvBuyReq_Hd.SiInvBuyReq_Hd,
            Tsid.Num_GdsInWidthBuyReq, Tsid.Num_GdsInLengthBuyReq, Tpgt.Sta_TipOfGoodsType,
            Tsid.Tss_SalInvoice_DtRegTime, Tsid.Tss_SalInvoice_DtEditTime,
            Tsid.Tss_SalInvoice_DtRegisterer, Tsid.Tss_SalInvoice_DtEditor,
            Registerer.Cod_PubPersonCode AS CodRegisterer, Registerer.Des_FullName AS DesRegisterer,
            Editor.Cod_PubPersonCode AS CodEditor, Editor.Des_FullName AS DesEditor,
            Tsid.SiPubCustomCodesColor5, Tsid.SiPubCustomCodesColor6,
            Color5.Cod_CustomCodesCode AS cCol5, Color5.Des_CustomCodesDesc AS nCol5,
            Color6.Cod_CustomCodesCode AS cCol6, Color6.Des_CustomCodesDesc AS nCol6,
            Tsid.Num_NoInPallete, Tsid.SiSalInvoiceDtCopiedFrom, Tsid.Sta_IsFeeAdjustPercent,
            Tsid.Num_GdsFeeRounder, Tsid.Sta_CellophaneType, Tsid.Sta_MatteOrGlossy,
            Tsid.Num_GdsLaminateFee, Tsid.SiPubGoodsClassifyCardBox,
            Tss_PubGoodsClassifyCardBox.Cod_GoodsClassCode AS Cod_GoodsClassCodeCardBox,
            Tss_PubGoodsClassifyCardBox.Des_GoodsClassDesc AS Des_GoodsClassDescCardBox,
            Tpgt.Sta_LaminateType, Tsid.SiSalInvoice_DtCombinee,
            Tss_PubGoodsViw.Des_PubGoodsDesc AS CombineeeGdsDes,
            Tss_PubGoodsViw.Cod_PubGoodsCode AS CombineeeGdsCod,
            Tss_SalInvoiceGoodsViw.Cod_SaleAgreement2 AS CombineeeContNo, Tpgt.Sta_DieOrNot,
              (
                SELECT ISNULL(SUM(Tss_SalFactor_Dt.Num_FactDetGoodsNo), 0)
                FROM Tss_SalFactor_Dt
                INNER JOIN Tss_SalFactor_Hd 
                ON Tss_SalFactor_Dt.SiSalFactor_Hd = Tss_SalFactor_Hd.SiSalFactor_Hd
                WHERE 
                Tss_SalFactor_Dt.SiPubGoods = Tsid.SiPubGoods
                AND Tss_SalFactor_Dt.SiSalInvoice_HdRow = Tsid.SiSalInvoice_Hd
                AND Tss_SalFactor_Hd.Sta_FactorHdState = 0
                ) AS FactoredAmt,
            Tsid.SiPrcPackagingTypes, Tss_PrcPackagingTypes.Cod_PackagingTypesCode,
            Tss_PrcPackagingTypes.Des_PackagingTypesDesc, Tss_PrcPackagingTypes.Num_PackagingTypesCost,
            Tss_PrcPackagingTypes.Sta_PackagingType, Tsid.Num_NoInVehicle, Tsid.SiInvVehicles,
            Tss_InvVehicles.Cod_VehicleCode, Tss_InvVehicles.Des_VehicleDesc
        FROM Tss_SalInvoice_Dt AS Tsid
            LEFT OUTER JOIN Tss_PrcPackagingTypes ON Tsid.SiPrcPackagingTypes = Tss_PrcPackagingTypes.SiPrcPackagingTypes
            LEFT OUTER JOIN Tss_SalInvoiceGoodsViw ON Tsid.SiSalInvoice_DtCombinee = Tss_SalInvoiceGoodsViw.SiSalInvoice_Dt
            LEFT OUTER JOIN Tss_PubGoodsViw ON Tss_SalInvoiceGoodsViw.SiPubGoods = Tss_PubGoodsViw.SiPubGoods
            LEFT OUTER JOIN Tss_PubGoodsClassify AS Tss_PubGoodsClassifyCardBox ON Tsid.SiPubGoodsClassifyCardBox = Tss_PubGoodsClassifyCardBox.SiPubGoodsClassify
            LEFT OUTER JOIN Tss_PubGoodsClassify ON Tsid.SiPubGoodsClassify = Tss_PubGoodsClassify.SiPubGoodsClassify
            LEFT OUTER JOIN Tss_PubCustomCodes AS Color6 ON Tsid.SiPubCustomCodesColor6 = Color6.SiPubCustomCodes
            LEFT OUTER JOIN Tss_PubCustomCodes AS Color5 ON Tsid.SiPubCustomCodesColor5 = Color5.SiPubCustomCodes
            LEFT OUTER JOIN Tss_PubPersonsViw AS Editor ON Tsid.Tss_SalInvoice_DtEditor = Editor.SiPubPersonsSpec
            LEFT OUTER JOIN Tss_PubPersonsViw AS Registerer ON Tsid.Tss_SalInvoice_DtRegisterer = Registerer.SiPubPersonsSpec
            LEFT OUTER JOIN Tss_InvBuyReq_Dt ON Tsid.SiInvBuyReq_Dt = Tss_InvBuyReq_Dt.SiInvBuyReq_Dt
            LEFT OUTER JOIN Tss_InvBuyReq_Hd ON Tss_InvBuyReq_Dt.SiInvBuyReq_Hd = Tss_InvBuyReq_Hd.SiInvBuyReq_Hd
            LEFT OUTER JOIN Tss_PubCustomCodes AS Mazroof ON Tsid.SiPubCustomCodes = Mazroof.SiPubCustomCodes
            LEFT OUTER JOIN Tss_PrcGoodsType AS Tpgt ON Tsid.SiPrcGoodsType = Tpgt.SiPrcGoodsType
            LEFT OUTER JOIN Tss_PrcFlutType ON Tsid.SiPrcFlutType = Tss_PrcFlutType.SiPrcFlutType
            LEFT OUTER JOIN Tss_PrcDieSpec ON Tsid.SiPrcDieSpec = Tss_PrcDieSpec.SiPrcDieSpec
            LEFT OUTER JOIN Tss_PrcKelisheSpec ON Tsid.SiPrcKelisheSpec = Tss_PrcKelisheSpec.SiPrcKelisheSpec
            LEFT OUTER JOIN Tss_PubGoods ON Tsid.SiPubGoods = Tss_PubGoods.SiPubGoods
            LEFT OUTER JOIN Tss_PubCustomCodes AS Color1 ON Tsid.SiPubCustomCodesColor1 = Color1.SiPubCustomCodes
            LEFT OUTER JOIN Tss_PubCustomCodes AS Color2 ON Tsid.SiPubCustomCodesColor2 = Color2.SiPubCustomCodes
            LEFT OUTER JOIN Tss_PubCustomCodes AS Color3 ON Tsid.SiPubCustomCodesColor3 = Color3.SiPubCustomCodes
            LEFT OUTER JOIN Tss_PubCustomCodes AS Color4 ON Tsid.SiPubCustomCodesColo4 = Color4.SiPubCustomCodes
            LEFT OUTER JOIN Tss_InvVehicles ON Tsid.SiInvVehicles = Tss_InvVehicles.SiInvVehicles
        WHERE Tsid.SiSalInvoice_Hd = @SalInvoiceHdParam'
        + @OrderClause;

        EXEC sp_executesql @Sql, N'@SalInvoiceHdParam INT', @SalInvoiceHdParam = @SalInvoiceHd;
    END
    ELSE
    BEGIN
        ------------------------------------------------------------------
        -- GENERIC PATH: arbitrary/legacy filter text from callers.
        -- Must stay wrapped in ONE derived table so @InternalWhere/@Where
        -- only ever "see" the flattened, uniquely-named SELECT list --
        -- never the raw joined tables, where column names like
        -- SiSalInvoice_Hd exist on more than one table and would be
        -- ambiguous if referenced unqualified.
        ------------------------------------------------------------------
        DECLARE @InnerWhere NVARCHAR(MAX) = N'';

        IF @InternalWhere <> ''
            SET @InnerWhere = N' WHERE ' + @InternalWhere;

        IF @Where <> ''
            SET @InnerWhere = @InnerWhere
                               + CASE WHEN @InnerWhere = '' THEN N' WHERE ' ELSE N' AND ' END
                               + @Where;

        SET @Sql = N'
        SELECT * FROM
        (
            SELECT
                Tsid.Sta_PrintFeeArea, Tsid.Num_CommisionFee, Tsid.Sta_IsCommisionPercent,
                Tsid.Sta_IsCommisionArea, Tsid.Des_RowDesc, Tsid.Num_CustomerTarkibiWidth,
                Tsid.Sta_HasDesign, Tsid.Num_GdsPalleteFee, Tsid.Num_FeeHaml, Tsid.SiSalInvoice_Dt,
                Tsid.Num_NoOfPrintingSides, Tsid.Num_WidthPert, Tsid.Num_LengthPert,
                Tsid.SiPubCustomCodesColor1, Tsid.SiPubCustomCodesColor2, Tsid.SiPubCustomCodesColor3,
                Tsid.SiPubCustomCodesColo4, Tsid.SiSalInvoice_Hd, Tsid.SiPrcGoodsType, Tsid.SiPrcFlutType,
                Tsid.SiPubGoods, Tsid.SiPubGoodsClassify, Tsid.Num_SalInvoiceDetRow, Tsid.Num_GdsAmountNo,
               Tsid.Num_ColoringRate, Tsid.Num_GdsArea, Tsid.Num_GdsFee, Tsid.Num_GdsBalancFee,
                Tsid.Num_GdsBalancFee * Tsid.Num_GdsAmountNo               AS RowPrice,
                Tsid.Num_SampleInnerLength, Tsid.Num_SampleInnerWidth, Tsid.Num_SampleInnerHeigth,
                Tsid.Num_SampleHoleNo, Tsid.Num_SampleMasrafCoefOfBox, Tsid.Sta_HasMangene,
                Tsid.Sta_IsLipStick, Tsid.Num_GdsColorFee, Tsid.Num_GdsDieFee, Tsid.Num_FeeAdjust,
                Tsid.StmSalInvoice_Dt, Tsid.SiPrcKelisheSpec, Tsid.Num_GoodsLength, Tsid.Num_GoodsWidth,
                Tsid.Num_GoodsUnitWeight,
                ROUND(Tsid.Num_GoodsUnitWeight * Tsid.Num_GdsAmountNo / 1000, 0) AS Tonage,
                Color1.Cod_CustomCodesCode AS cCol1, Color1.Des_CustomCodesDesc AS nCol1,
                Color2.Cod_CustomCodesCode AS cCol2, Color2.Des_CustomCodesDesc AS nCol2,
                Color3.Cod_CustomCodesCode AS cCol3, Color3.Des_CustomCodesDesc AS nCol3,
                Color4.Cod_CustomCodesCode AS cCol4, Color4.Des_CustomCodesDesc AS nCol4,
                Tpgt.Cod_PrcGoodsTypeCode, Tpgt.Des_PrcGoodsTypeDesc,
                Tss_PrcFlutType.Cod_FlutTypeCode, Tss_PrcFlutType.Des_FlutTypeName,
                Tss_PubGoods.Cod_PubGoodsCode, Tss_PubGoods.Des_PubGoodsDesc,
                Tss_PubGoodsClassify.Cod_GoodsClassCode AS Code_Jens,
                Tss_PubGoodsClassify.Des_GoodsClassDesc AS Name_Jens,
                Tss_PrcKelisheSpec.Cod_KelisheSpecCode, Tss_PrcKelisheSpec.Des_KelisheSpecDesc,
                Tsid.SiPrcDieSpec, Tss_PrcDieSpec.Cod_DieSpecCode,
                Tss_PrcDieSpec.Des_DieSpecDesc + N'' - '' + CONVERT(VARCHAR, Tss_PrcDieSpec.Num_NoGdsInDie) + N'' تايي '' AS Des_DieSpecDesc,
                Tsid.Sta_Cyan, Tsid.Sta_Magenta, Tsid.Sta_Yellow, Tsid.Sta_Black, Tsid.Sta_HasVerni,
                Tsid.Num_VaraghCreaseAmt, Tsid.Sta_HoleSide, Tsid.Sta_CatchSide, Tsid.Sta_PrintArm,
                Tsid.Sta_PackType, Tsid.Num_OneMeterSheetPrice, Tsid.Num_OneMeterBoxPrice,
                Tsid.SiPubCustomCodes, Tsid.Cod_SampleGdsCode,
                Mazroof.Cod_CustomCodesCode AS CodMazDt, Mazroof.Des_CustomCodesDesc AS DesMazDt,
                Tsid.Sta_EttesalType, Tsid.Sta_HasGooshvareh, Tsid.Num_UpDoorOpenSize, Tsid.Num_DownDoorOpenSize,
                Tsid.Num_SampleOuterLength, Tsid.Num_SampleOuterWidth, Tsid.Num_SampleOuterHeigth,
                Tsid.Num_VaraghUpDoorAmt, Tsid.Num_VaraghDownDoorAmt, Tsid.Sta_IsDoubleCrease,
                Tsid.Sta_ShowJens, Tsid.Sta_ShowJensBrief, Tsid.Sta_HighSensibility, Tsid.Num_ContLabChasbConst,
                Tsid.Sta_OuterPrint, Tsid.SiInvBuyReq_Dt, Tss_InvBuyReq_Dt.Num_BuyReqN,
                Tss_InvBuyReq_Dt.Cod_BuyReqDtCode, Tss_InvBuyReq_Hd.Cod_BuyReqHdCode,
                Tss_InvBuyReq_Hd.Dat_BuyReqHdDate, Tss_InvBuyReq_Hd.SiInvBuyReq_Hd,
                Tsid.Num_GdsInWidthBuyReq, Tsid.Num_GdsInLengthBuyReq, Tpgt.Sta_TipOfGoodsType,
                Tsid.Tss_SalInvoice_DtRegTime, Tsid.Tss_SalInvoice_DtEditTime,
                Tsid.Tss_SalInvoice_DtRegisterer, Tsid.Tss_SalInvoice_DtEditor,
                Registerer.Cod_PubPersonCode AS CodRegisterer, Registerer.Des_FullName AS DesRegisterer,
                Editor.Cod_PubPersonCode AS CodEditor, Editor.Des_FullName AS DesEditor,
                Tsid.SiPubCustomCodesColor5, Tsid.SiPubCustomCodesColor6,
                Color5.Cod_CustomCodesCode AS cCol5, Color5.Des_CustomCodesDesc AS nCol5,
                Color6.Cod_CustomCodesCode AS cCol6, Color6.Des_CustomCodesDesc AS nCol6,
                Tsid.Num_NoInPallete, Tsid.SiSalInvoiceDtCopiedFrom, Tsid.Sta_IsFeeAdjustPercent,
                Tsid.Num_GdsFeeRounder, Tsid.Sta_CellophaneType, Tsid.Sta_MatteOrGlossy,
                Tsid.Num_GdsLaminateFee, Tsid.SiPubGoodsClassifyCardBox,
                Tss_PubGoodsClassifyCardBox.Cod_GoodsClassCode AS Cod_GoodsClassCodeCardBox,
                Tss_PubGoodsClassifyCardBox.Des_GoodsClassDesc AS Des_GoodsClassDescCardBox,
                Tpgt.Sta_LaminateType, Tsid.SiSalInvoice_DtCombinee,
                Tss_PubGoodsViw.Des_PubGoodsDesc AS CombineeeGdsDes,
                Tss_PubGoodsViw.Cod_PubGoodsCode AS CombineeeGdsCod,
                Tss_SalInvoiceGoodsViw.Cod_SaleAgreement2 AS CombineeeContNo, Tpgt.Sta_DieOrNot,
                (
                SELECT ISNULL(SUM(Tss_SalFactor_Dt.Num_FactDetGoodsNo), 0)
                FROM Tss_SalFactor_Dt
                INNER JOIN Tss_SalFactor_Hd 
                ON Tss_SalFactor_Dt.SiSalFactor_Hd = Tss_SalFactor_Hd.SiSalFactor_Hd
                WHERE 
                Tss_SalFactor_Dt.SiPubGoods = Tsid.SiPubGoods
                AND Tss_SalFactor_Dt.SiSalInvoice_HdRow = Tsid.SiSalInvoice_Hd
                AND Tss_SalFactor_Hd.Sta_FactorHdState = 0
                ) AS FactoredAmt,
                Tsid.SiPrcPackagingTypes, Tss_PrcPackagingTypes.Cod_PackagingTypesCode,
                Tss_PrcPackagingTypes.Des_PackagingTypesDesc, Tss_PrcPackagingTypes.Num_PackagingTypesCost,
                Tss_PrcPackagingTypes.Sta_PackagingType, Tsid.Num_NoInVehicle, Tsid.SiInvVehicles,
                Tss_InvVehicles.Cod_VehicleCode, Tss_InvVehicles.Des_VehicleDesc
            FROM Tss_SalInvoice_Dt AS Tsid
                LEFT OUTER JOIN Tss_PrcPackagingTypes ON Tsid.SiPrcPackagingTypes = Tss_PrcPackagingTypes.SiPrcPackagingTypes
                LEFT OUTER JOIN Tss_SalInvoiceGoodsViw ON Tsid.SiSalInvoice_DtCombinee = Tss_SalInvoiceGoodsViw.SiSalInvoice_Dt
                LEFT OUTER JOIN Tss_PubGoodsViw ON Tss_SalInvoiceGoodsViw.SiPubGoods = Tss_PubGoodsViw.SiPubGoods
                LEFT OUTER JOIN Tss_PubGoodsClassify AS Tss_PubGoodsClassifyCardBox ON Tsid.SiPubGoodsClassifyCardBox = Tss_PubGoodsClassifyCardBox.SiPubGoodsClassify
                LEFT OUTER JOIN Tss_PubGoodsClassify ON Tsid.SiPubGoodsClassify = Tss_PubGoodsClassify.SiPubGoodsClassify
                LEFT OUTER JOIN Tss_PubCustomCodes AS Color6 ON Tsid.SiPubCustomCodesColor6 = Color6.SiPubCustomCodes
                LEFT OUTER JOIN Tss_PubCustomCodes AS Color5 ON Tsid.SiPubCustomCodesColor5 = Color5.SiPubCustomCodes
                LEFT OUTER JOIN Tss_PubPersonsViw AS Editor ON Tsid.Tss_SalInvoice_DtEditor = Editor.SiPubPersonsSpec
                LEFT OUTER JOIN Tss_PubPersonsViw AS Registerer ON Tsid.Tss_SalInvoice_DtRegisterer = Registerer.SiPubPersonsSpec
                LEFT OUTER JOIN Tss_InvBuyReq_Dt ON Tsid.SiInvBuyReq_Dt = Tss_InvBuyReq_Dt.SiInvBuyReq_Dt
                LEFT OUTER JOIN Tss_InvBuyReq_Hd ON Tss_InvBuyReq_Dt.SiInvBuyReq_Hd = Tss_InvBuyReq_Hd.SiInvBuyReq_Hd
                LEFT OUTER JOIN Tss_PubCustomCodes AS Mazroof ON Tsid.SiPubCustomCodes = Mazroof.SiPubCustomCodes
                LEFT OUTER JOIN Tss_PrcGoodsType AS Tpgt ON Tsid.SiPrcGoodsType = Tpgt.SiPrcGoodsType
                LEFT OUTER JOIN Tss_PrcFlutType ON Tsid.SiPrcFlutType = Tss_PrcFlutType.SiPrcFlutType
                LEFT OUTER JOIN Tss_PrcDieSpec ON Tsid.SiPrcDieSpec = Tss_PrcDieSpec.SiPrcDieSpec
                LEFT OUTER JOIN Tss_PrcKelisheSpec ON Tsid.SiPrcKelisheSpec = Tss_PrcKelisheSpec.SiPrcKelisheSpec
                LEFT OUTER JOIN Tss_PubGoods ON Tsid.SiPubGoods = Tss_PubGoods.SiPubGoods
                LEFT OUTER JOIN Tss_PubCustomCodes AS Color1 ON Tsid.SiPubCustomCodesColor1 = Color1.SiPubCustomCodes
                LEFT OUTER JOIN Tss_PubCustomCodes AS Color2 ON Tsid.SiPubCustomCodesColor2 = Color2.SiPubCustomCodes
                LEFT OUTER JOIN Tss_PubCustomCodes AS Color3 ON Tsid.SiPubCustomCodesColor3 = Color3.SiPubCustomCodes
                LEFT OUTER JOIN Tss_PubCustomCodes AS Color4 ON Tsid.SiPubCustomCodesColo4 = Color4.SiPubCustomCodes
                LEFT OUTER JOIN Tss_InvVehicles ON Tsid.SiInvVehicles = Tss_InvVehicles.SiInvVehicles
        ) AS Ccc'
        + @InnerWhere
        + @OrderClause;

PRINT 'Generated SQL:';
DECLARE @i INT = 1;
WHILE @i <= LEN(@Sql)
BEGIN
    PRINT SUBSTRING(@Sql, @i, 4000);
    SET @i = @i + 4000;
END;
PRINT '----------------------------------------';

        EXEC sp_executesql @Sql;
    END
END
go

alter Procedure Tss_SalUntInvoice_HdIudStp  
(  
	@Err_Code Int OutPut,  
	@SiSalInvoice_Hd Numeric OutPut,  
	@SiSalTypeOfSales numeric=null,  
	@SiPubCustomCodes numeric=null,  
	@SiPubPersonsSpec numeric=null, 
	@SiPubPersonsSpecEditor numeric=null,
	@SiSalInvoiceRepeat_Hd numeric=null,
	@Cod_SaleAgreement varchar(50)='',  
	@Cod_SaleAgreement2 varchar(50)='',  
	@Cod_SaleAgreementChange varchar(1)='A',  
	@Des_SaleAgreementDesc varchar(500)='',
	@Des_SalInvoiceChangeDesc varchar(8000)='', 
	@Des_SalInvoiceChangeDescOld varchar(8000)='',
	@Num_SaleAgreementPriority int=0,  
	@Cod_LetterNo varchar(50)='',  
	@Num_PreRecieveAmount int=0,  
	@Num_DiscountAmount numeric=0,  
	@Dat_SalReqToContractDate varchar(10)='',  
	@Des_HeaderDesc varchar(500)='',  
	@Des_EndDocDesc varchar(500)='',  
	@Sta_Kosoorat smallint=0,  
	@Num_ProductionTelorance decimal(5,3)=0,  
	@Sta_ContractStatus smallint=0,  
	@Sta_ContractFormStatus smallint=0,  
	@Sta_TransportState smallint=0,  
	@Sta_ForProdOrSale smallint=0,
	@Sta_MainOrNot smallint=0,
	@Dat_SalConfirmOfProdDate varchar(10)='',
	@Dat_SaleRequestRegDate  varchar(10)='',
	@SiPubSubLocations numeric=null,
	@Dat_ApprovedForProd varchar(10)='',
	@Sta_Branch smallint=0,
	@Sta_DiscountState smallint=0,  
	@Sta_CurrencyType smallint=0,  
	@Num_CurrencyRate numeric=0,
	@Num_CreditDays int=0,
	@Sta_ErsalStatus smallint=0,
	@Sta_ContIsLaminate smallint=null,
	@StmSalInvoice_Hd TimeStamp=0,  
	@SiUser Numeric,  
	@FlgInsUpdDel SmallInt  
) As 

if dbo.Tss_StdFindSubLoc(0)='Persa'
	Set @Sta_ContractStatus = 8
if isnull(@SiPubSubLocations,0)=0
SELECT     
	@SiPubSubLocations = SiPubSubLocations
FROM         
	Tss_PubSubLocations
WHERE     
	(Sta_IsDefaultCompany = 1)
 
Declare
	--@Dat_SaleRequestRegDate varchar(10),
	@Sta_IsLegalCompany smallint

SELECT     
	@Sta_IsLegalCompany = Sta_IsLegalCompany
FROM         
	Tss_PubSubLocations
WHERE     
	(SiPubSubLocations = @SiPubSubLocations)

If (@FlgInsUpdDel<>1)  and (@FlgInsUpdDel<>2) 
begin

	if (@Sta_ContractStatus <> 9)
	Begin
		If (@FlgInsUpdDel=0) AND 
			Not Exists (SELECT SiSalInvoice_Hd FROM Tss_SalInvoice_Hd WHERE 
			(Cod_SaleAgreement2 = @Cod_SaleAgreement2) AND (Sta_MainOrNot = @Sta_MainOrNot))
		Begin 
	--		select * from SiSalInvoice_Hd
	--		Select @Cod_SaleAgreement = @@ROWCOUNT + 1
	--SELECT @Cod_SaleAgreement = COUNT(SiSalInvoice_Hd) FROM Tss_SalInvoice_Hd
			Select @Cod_SaleAgreement= Convert(VarChar(50),IsNull(Max(Convert(int,Cod_SaleAgreement)),0)+1) From dbo.Tss_SalInvoice_Hd
			Set @Dat_SaleRequestRegDate=@Dat_SalReqToContractDate
			Set @Num_SaleAgreementPriority=0
			Set @Num_ProductionTelorance=0
		--	Set @Sta_ContractStatus=0
			Set @Sta_ContractFormStatus=1
		--	Set @Sta_ForProdOrSale=1
			Insert Into dbo.Tss_SalInvoice_Hd  
			(  
				SiSalTypeOfSales,  
				SiPubCustomCodes,  
				SiPubPersonsSpec,  
				SiPubPersonsSpecEditor,
				SiSalInvoiceRepeat_Hd,
				Cod_SaleAgreement,
				Cod_SaleAgreement2,
				Cod_SaleAgreementChange,  
				Des_SaleAgreementDesc,
				Des_SalInvoiceChangeDesc,
				Des_SalInvoiceChangeDescOld,  
				Dat_SaleRequestRegDate,  
				Num_SaleAgreementPriority,  
				Num_PreRecieveAmount,  
				Num_DiscountAmount,  
				Dat_SalReqToContractDate,  
				Des_HeaderDesc,  
				Des_EndDocDesc,  
				Sta_Kosoorat,  
				Num_ProductionTelorance,  
				Sta_ContractStatus,  
				Sta_ContractFormStatus,  
				Sta_TransportState,
				Sta_ForProdOrSale,
				Sta_MainOrNot,
				Dat_SalConfirmOfProdDate,
				Cod_LetterNo,
				SiPubSubLocations,
				Dat_ApprovedForProd,
				Sta_Branch,
				Sta_DiscountState,  
				Num_CurrencyRate,
				Sta_CurrencyType,
				Sta_ErsalStatus,
				Num_CreditDays,
				Sta_ContIsLaminate
			)  
			Values  
			(  
				@SiSalTypeOfSales,  
				@SiPubCustomCodes,  
				@SiPubPersonsSpec,
				@SiUser,
				@SiSalInvoiceRepeat_Hd,  
				@Cod_SaleAgreement,
				@Cod_SaleAgreement2,
				@Cod_SaleAgreementChange,  
				@Des_SaleAgreementDesc,  
				@Des_SalInvoiceChangeDesc,
				@Des_SalInvoiceChangeDescOld,  
				@Dat_SaleRequestRegDate,  
				@Num_SaleAgreementPriority,  
				@Num_PreRecieveAmount,  
				@Num_DiscountAmount,  
				@Dat_SalReqToContractDate,  
				@Des_HeaderDesc,  
				@Des_EndDocDesc,  
				@Sta_Kosoorat,  
				@Num_ProductionTelorance,  
				@Sta_ContractStatus,  
				@Sta_ContractFormStatus,  
				@Sta_TransportState,
				@Sta_ForProdOrSale,
				@Sta_MainOrNot,
				@Dat_SalConfirmOfProdDate,
				@Cod_LetterNo,
				@SiPubSubLocations,
				@Dat_ApprovedForProd,
				@Sta_Branch,
				@Sta_DiscountState,  
				@Num_CurrencyRate,
				@Sta_CurrencyType,
				@Sta_ErsalStatus,
				@Num_CreditDays,
				0
			)  
			Set @SiSalInvoice_Hd=Scope_Identity()  
	
	--	If IsNull(@SiSalInvoice_Hd,0)>0
	--	Exec dbo.Tss_StdUpdateTabelLog @SiUser, 'Tss_SalInvoice_Hd', @SiSalInvoice_Hd, 'SiSalInvoice_Hd', @FlgInsUpdDel 
		/*	If (IsNull(@SiSalInvoice_Hd,0) <> 0) and (@Sta_IsLegalCompany = 1)
			Begin  
				exec Tss_SalUntServiceInvoiceIudStp
					0,  
					0,  
					1614,  
					@SiSalInvoice_Hd,  
					0,  
					0,  
					1,  
					1
			End
		*/
			If (IsNull(@Sta_TransportState,0) <> 0)
			Begin  
				exec Tss_SalUntServiceInvoiceIudStp
					0,  
					0,  
					312,  
					@SiSalInvoice_Hd,  
					0,  
					0,  
					1,  
					1
			End
	
			If IsNull(@SiSalInvoice_Hd,0)=0  
			Begin  
				Set @SiSalInvoice_Hd=0  
				Set @Err_Code=400  
			End  
			Return  
		End 
		else
			If (@FlgInsUpdDel=0) AND 
				Exists (SELECT SiSalInvoice_Hd FROM Tss_SalInvoice_Hd WHERE 
				(Cod_SaleAgreement2 = @Cod_SaleAgreement2) AND (Sta_MainOrNot = @Sta_MainOrNot)) and (@Sta_ContractStatus <> 9)
			Begin
				Set @Err_Code=40032062  
				Return
			End
	End
	else
	Begin
		If (@FlgInsUpdDel=0) 
		Begin 
			Select @Cod_SaleAgreement= Convert(VarChar(50),IsNull(Max(Convert(int,Cod_SaleAgreement)),0)+1) From dbo.Tss_SalInvoice_Hd
			--Set @Dat_SaleRequestRegDate=@Dat_SalReqToContractDate
			Set @Num_SaleAgreementPriority=0
			Set @Num_ProductionTelorance=0
		--	Set @Sta_ContractStatus=0
			Set @Sta_ContractFormStatus=1
		--	Set @Sta_ForProdOrSale=1
			Insert Into dbo.Tss_SalInvoice_Hd  
			(  
				SiSalTypeOfSales,  
				SiPubCustomCodes,  
				SiPubPersonsSpec,  
				SiPubPersonsSpecEditor,
				SiSalInvoiceRepeat_Hd,
				Cod_SaleAgreement,
				Cod_SaleAgreement2,
				Cod_SaleAgreementChange,  
				Des_SaleAgreementDesc,
				Des_SalInvoiceChangeDesc,
				Des_SalInvoiceChangeDescOld,  
				Dat_SaleRequestRegDate,  
				Num_SaleAgreementPriority,  
				Num_PreRecieveAmount,  
				Num_DiscountAmount,  
				Dat_SalReqToContractDate,  
				Des_HeaderDesc,  
				Des_EndDocDesc,  
				Sta_Kosoorat,  
				Num_ProductionTelorance,  
				Sta_ContractStatus,  
				Sta_ContractFormStatus,  
				Sta_TransportState,
				Sta_ForProdOrSale,
				Sta_MainOrNot,
				Dat_SalConfirmOfProdDate,
				Cod_LetterNo,
				SiPubSubLocations,
				Dat_ApprovedForProd,
				Sta_Branch,
				Sta_DiscountState,  
				Num_CurrencyRate,
				Sta_CurrencyType,
				Sta_ErsalStatus,
				Num_CreditDays,
				Sta_ContIsLaminate
			)  
			Values  
			(  
				@SiSalTypeOfSales,  
				@SiPubCustomCodes,  
				@SiPubPersonsSpec,
				@SiUser,
				@SiSalInvoiceRepeat_Hd,  
				@Cod_SaleAgreement,
				@Cod_SaleAgreement2,
				@Cod_SaleAgreementChange,  
				@Des_SaleAgreementDesc,  
				@Des_SalInvoiceChangeDesc,
				@Des_SalInvoiceChangeDescOld,  
				@Dat_SaleRequestRegDate,  
				@Num_SaleAgreementPriority,  
				@Num_PreRecieveAmount,  
				@Num_DiscountAmount,  
				@Dat_SalReqToContractDate,  
				@Des_HeaderDesc,  
				@Des_EndDocDesc,  
				@Sta_Kosoorat,  
				@Num_ProductionTelorance,  
				@Sta_ContractStatus,  
				@Sta_ContractFormStatus,  
				@Sta_TransportState,
				@Sta_ForProdOrSale,
				@Sta_MainOrNot,
				@Dat_SalConfirmOfProdDate,
				@Cod_LetterNo,
				@SiPubSubLocations,
				@Dat_ApprovedForProd,
				@Sta_Branch,
				@Sta_DiscountState,  
				@Num_CurrencyRate,
				@Sta_CurrencyType,
				@Sta_ErsalStatus,
				@Num_CreditDays,
				0
			)  
			Set @SiSalInvoice_Hd=Scope_Identity()  
	
	--	If IsNull(@SiSalInvoice_Hd,0)>0
	--	Exec dbo.Tss_StdUpdateTabelLog @SiUser, 'Tss_SalInvoice_Hd', @SiSalInvoice_Hd, 'SiSalInvoice_Hd', @FlgInsUpdDel 
		/*	If (IsNull(@SiSalInvoice_Hd,0) <> 0) and (@Sta_IsLegalCompany = 1)
			Begin  
				exec Tss_SalUntServiceInvoiceIudStp
					0,  
					0,  
					1614,  
					@SiSalInvoice_Hd,  
					0,  
					0,  
					1,  
					1
			End
		*/
			If (IsNull(@Sta_TransportState,0) <> 0)
			Begin  
				exec Tss_SalUntServiceInvoiceIudStp
					0,  
					0,  
					312,  
					@SiSalInvoice_Hd,  
					0,  
					0,  
					1,  
					1
			End
	
			If IsNull(@SiSalInvoice_Hd,0)=0  
			Begin  
				Set @SiSalInvoice_Hd=0  
				Set @Err_Code=400  
			End  
			Return  
		End 
		else
			If (@FlgInsUpdDel=0) AND 
				Exists (SELECT SiSalInvoice_Hd FROM Tss_SalInvoice_Hd WHERE 
				(Cod_SaleAgreement2 = @Cod_SaleAgreement2) AND (Sta_MainOrNot = @Sta_MainOrNot)) and (@Sta_ContractStatus <> 9)
			Begin
				Set @Err_Code=40032062  
				Return
			End
	End
end

If (@FlgInsUpdDel=1)  
Begin
	Declare
		@Flg Int
	Set @Err_Code=0  
	If Exists(  
	Select StmSalInvoice_Hd From dbo.Tss_SalInvoice_Hd  
	Where (SiSalInvoice_Hd=@SiSalInvoice_Hd) And (StmSalInvoice_Hd=@StmSalInvoice_Hd))  
	Begin  
--		Select @Flg=Sta_ContractStatus, @Sta_ForProdOrSale=Sta_ForProdOrSale From dbo.Tss_SalInvoice_Hd Where (SiSalInvoice_Hd=@SiSalInvoice_Hd)
--		If @Sta_ForProdOrSale=1 And @Sta_ContractStatus=1
--			Set @Sta_ContractStatus=@Flg
		Update dbo.Tss_SalInvoice_Hd Set  
			SiSalTypeOfSales=@SiSalTypeOfSales,
			SiPubCustomCodes=@SiPubCustomCodes,  
			SiPubPersonsSpec=@SiPubPersonsSpec,
			SiPubPersonsSpecEditor=@SiUser,
			SiSalInvoiceRepeat_Hd=@SiSalInvoiceRepeat_Hd,  
			Cod_SaleAgreement2=@Cod_SaleAgreement2,
			Cod_SaleAgreementChange=@Cod_SaleAgreementChange,
			Des_SaleAgreementDesc=@Des_SaleAgreementDesc,  
			Des_SalInvoiceChangeDesc=@Des_SalInvoiceChangeDesc,
			Des_SalInvoiceChangeDescOld=@Des_SalInvoiceChangeDescOld,  
			Num_SaleAgreementPriority=@Num_SaleAgreementPriority,  
			Num_PreRecieveAmount=@Num_PreRecieveAmount,  
			Num_DiscountAmount=@Num_DiscountAmount,  
			Dat_SalReqToContractDate=@Dat_SalReqToContractDate,  
			Des_HeaderDesc=@Des_HeaderDesc,  
			Des_EndDocDesc=@Des_EndDocDesc,  
			Sta_Kosoorat=@Sta_Kosoorat,  
			Num_ProductionTelorance=@Num_ProductionTelorance,  
			Sta_ContractStatus=@Sta_ContractStatus,  
			Sta_TransportState=@Sta_TransportState,  
			Sta_ForProdOrSale=@Sta_ForProdOrSale,
			Sta_MainOrNot=@Sta_MainOrNot,
			Dat_SalConfirmOfProdDate=@Dat_SalConfirmOfProdDate,
			Cod_LetterNo=@Cod_LetterNo,
			SiPubSubLocations=@SiPubSubLocations,
			Dat_ApprovedForProd=@Dat_ApprovedForProd,
			Sta_Branch=@Sta_Branch,
			Sta_DiscountState=@Sta_DiscountState,
			Num_CurrencyRate=@Num_CurrencyRate,
			Sta_CurrencyType=@Sta_CurrencyType,
			Sta_ErsalStatus=@Sta_ErsalStatus,
			Num_CreditDays=@Num_CreditDays,
			Dat_SaleRequestRegDate=@Dat_SaleRequestRegDate,
			Sta_ContIsLaminate=0
		Where (SiSalInvoice_Hd=@SiSalInvoice_Hd)  

--		Exec dbo.Tss_StdUpdateTabelLog @SiUser, 'Tss_SalInvoice_Hd', @SiSalInvoice_Hd, 'SiSalInvoice_Hd', @FlgInsUpdDel 

		Set @Err_Code=@@Error  
		If @Err_Code<>0  
			Set @Err_Code=401  
		Return  
	End  
	ELse  
		Set @Err_Code=402  
End 
/*else
	Begin
		Set @Err_Code=40032062  
		Return
	End
*/ 
If @FlgInsUpdDel=2  
Begin  
	Set @Err_Code=0  
	If Exists(  
		Select StmSalInvoice_Hd From dbo.Tss_SalInvoice_Hd  
		Where (SiSalInvoice_Hd=@SiSalInvoice_Hd) And (StmSalInvoice_Hd=@StmSalInvoice_Hd))  
	Begin  
		Delete From dbo.Tss_SalInvoice_Hd Where (SiSalInvoice_Hd=@SiSalInvoice_Hd)  
		Set @Err_Code=@@Error  
		If @Err_Code<>0  
			Set @Err_Code=4000  
	End  
	Else  
	begin	
		Set @Err_Code=4000  
		Return  
	End
End
go

alter   Procedure Tss_SalUntInvoice_HdIudStp2  
(  
	@Err_Code Int OutPut,  
	@SiSalInvoice_Hd Numeric OutPut,  
	@SiSalTypeOfSales numeric=null,  
	@SiPubCustomCodes numeric=null,  
	@SiPubPersonsSpec numeric=null, 
	@SiPubPersonsSpecEditor numeric=null,
	@SiSalInvoiceRepeat_Hd numeric=null,
	@Cod_SaleAgreement varchar(50)='',  
	@Cod_SaleAgreement2 varchar(50)='',  
	@Cod_SaleAgreementChange varchar(1)='A',  
	@Des_SaleAgreementDesc varchar(500)='',
	@Des_SalInvoiceChangeDesc varchar(8000)='', 
	@Des_SalInvoiceChangeDescOld varchar(8000)='',
	@Num_SaleAgreementPriority int=0,  
	@Cod_LetterNo varchar(50)='',  
	@Num_PreRecieveAmount int=0,  
	@Num_DiscountAmount numeric=0,  
	@Dat_SalReqToContractDate varchar(10)='',  
	@Des_HeaderDesc varchar(500)='',  
	@Des_EndDocDesc varchar(500)='',  
	@Sta_Kosoorat smallint=0,  
	@Num_ProductionTelorance decimal(5,3)=0,  
	@Sta_ContractStatus smallint=0,  
	@Sta_ContractFormStatus smallint=0,  
	@Sta_TransportState smallint=0,  
	@Sta_ForProdOrSale smallint=0,
	@Sta_MainOrNot smallint=0,
	@Dat_SalConfirmOfProdDate varchar(10)='',
	@Dat_SaleRequestRegDate  varchar(10)='',
	@SiPubSubLocations numeric=null,
	@Dat_ApprovedForProd varchar(10)='',
	@Sta_Branch smallint=0,
	@Sta_DiscountState smallint=0,  
	@Sta_CurrencyType smallint=0,  
	@Num_CurrencyRate numeric=0,
	@Num_CreditDays int=0,
	@Sta_ErsalStatus smallint=0,
	@Sta_ContIsLaminate smallint=null,
	@StmSalInvoice_Hd TimeStamp=0,  
	@SiUser Numeric,  
	@FlgInsUpdDel SmallInt  
) As 

if dbo.Tss_StdFindSubLoc(0)='Persa'
	Set @Sta_ContractStatus = 8
if isnull(@SiPubSubLocations,0)=0
SELECT     
	@SiPubSubLocations = SiPubSubLocations
FROM         
	Tss_PubSubLocations
WHERE     
	(Sta_IsDefaultCompany = 1)
 
Declare
	--@Dat_SaleRequestRegDate varchar(10),
	@Sta_IsLegalCompany smallint

SELECT     
	@Sta_IsLegalCompany = Sta_IsLegalCompany
FROM         
	Tss_PubSubLocations
WHERE     
	(SiPubSubLocations = @SiPubSubLocations)

If (@FlgInsUpdDel<>1)  and (@FlgInsUpdDel<>2) 
begin

	if (@Sta_ContractStatus <> 9)
	Begin

		If (@FlgInsUpdDel=0) AND 
			Not Exists (SELECT SiSalInvoice_Hd FROM Tss_SalInvoice_Hd WHERE 
			(Cod_SaleAgreement2 = @Cod_SaleAgreement2) AND (Sta_MainOrNot = @Sta_MainOrNot))
		Begin 
	--		select * from SiSalInvoice_Hd
	--		Select @Cod_SaleAgreement = @@ROWCOUNT + 1
	--SELECT @Cod_SaleAgreement = COUNT(SiSalInvoice_Hd) FROM Tss_SalInvoice_Hd
			Select @Cod_SaleAgreement= Convert(VarChar(50),IsNull(Max(Convert(int,Cod_SaleAgreement)),0)+1) From dbo.Tss_SalInvoice_Hd
			Set @Dat_SaleRequestRegDate=@Dat_SalReqToContractDate
			Set @Num_SaleAgreementPriority=0
			Set @Num_ProductionTelorance=0
		--	Set @Sta_ContractStatus=0
			Set @Sta_ContractFormStatus=1
		--	Set @Sta_ForProdOrSale=1
			Insert Into dbo.Tss_SalInvoice_Hd  
			(  
				SiSalTypeOfSales,  

				SiPubCustomCodes,  
				SiPubPersonsSpec,  
				SiPubPersonsSpecEditor,
				SiSalInvoiceRepeat_Hd,
				Cod_SaleAgreement,
				Cod_SaleAgreement2,
				Cod_SaleAgreementChange,  
				Des_SaleAgreementDesc,
				Des_SalInvoiceChangeDesc,
				Des_SalInvoiceChangeDescOld,  
				Dat_SaleRequestRegDate,  
				Num_SaleAgreementPriority,  
				Num_PreRecieveAmount,  
				Num_DiscountAmount,  
				Dat_SalReqToContractDate,  
				Des_HeaderDesc,  
				Des_EndDocDesc,  
				Sta_Kosoorat,  
				Num_ProductionTelorance,  
				Sta_ContractStatus,  
				Sta_ContractFormStatus,  
				Sta_TransportState,
				Sta_ForProdOrSale,
				Sta_MainOrNot,
				Dat_SalConfirmOfProdDate,
				Cod_LetterNo,
				SiPubSubLocations,
				Dat_ApprovedForProd,
				Sta_Branch,
				Sta_DiscountState,  
				Num_CurrencyRate,
				Sta_CurrencyType,
				Sta_ErsalStatus,
				Num_CreditDays,
				Sta_ContIsLaminate
			)  
			Values  
			(  
				@SiSalTypeOfSales,  
				@SiPubCustomCodes,  
				@SiPubPersonsSpec,
				@SiUser,
				@SiSalInvoiceRepeat_Hd,  
				@Cod_SaleAgreement,
				@Cod_SaleAgreement2,
				@Cod_SaleAgreementChange,  
				@Des_SaleAgreementDesc,  
				@Des_SalInvoiceChangeDesc,
				@Des_SalInvoiceChangeDescOld,  
				@Dat_SaleRequestRegDate,  
				@Num_SaleAgreementPriority,  
				@Num_PreRecieveAmount,  
				@Num_DiscountAmount,  
				@Dat_SalReqToContractDate,  
				@Des_HeaderDesc,  
				@Des_EndDocDesc,  
				@Sta_Kosoorat,  
				@Num_ProductionTelorance,  
				@Sta_ContractStatus,  
				@Sta_ContractFormStatus,  
				@Sta_TransportState,
				@Sta_ForProdOrSale,
				@Sta_MainOrNot,
				@Dat_SalConfirmOfProdDate,
				@Cod_LetterNo,
				@SiPubSubLocations,
				@Dat_ApprovedForProd,
				@Sta_Branch,
				@Sta_DiscountState,  
				@Num_CurrencyRate,
				@Sta_CurrencyType,
				@Sta_ErsalStatus,
				@Num_CreditDays,
				1
			)  
			Set @SiSalInvoice_Hd=Scope_Identity()  
	
	--	If IsNull(@SiSalInvoice_Hd,0)>0
	--	Exec dbo.Tss_StdUpdateTabelLog @SiUser, 'Tss_SalInvoice_Hd', @SiSalInvoice_Hd, 'SiSalInvoice_Hd', @FlgInsUpdDel 
		/*	If (IsNull(@SiSalInvoice_Hd,0) <> 0) and (@Sta_IsLegalCompany = 1)
			Begin  
				exec Tss_SalUntServiceInvoiceIudStp
					0,  
					0,  
					1614,  
					@SiSalInvoice_Hd,  
					0,  
					0,  
					1,  
					1
			End
		*/
			If (IsNull(@Sta_TransportState,0) <> 0)
			Begin  
				exec Tss_SalUntServiceInvoiceIudStp
					0,  
					0,  
					312,  
					@SiSalInvoice_Hd,  
					0,  
					0,  
					1,  
					1
			End
	
			If IsNull(@SiSalInvoice_Hd,0)=0  
			Begin  
				Set @SiSalInvoice_Hd=0  
				Set @Err_Code=400  
			End  
			Return  
		End 
		else
			If (@FlgInsUpdDel=0) AND 
				Exists (SELECT SiSalInvoice_Hd FROM Tss_SalInvoice_Hd WHERE 
				(Cod_SaleAgreement2 = @Cod_SaleAgreement2) AND (Sta_MainOrNot = @Sta_MainOrNot)) and (@Sta_ContractStatus <> 9)
			Begin
				Set @Err_Code=40032062  
				Return
			End
	End
	else
	Begin
		If (@FlgInsUpdDel=0) 
		Begin 
			Select @Cod_SaleAgreement= Convert(VarChar(50),IsNull(Max(Convert(int,Cod_SaleAgreement)),0)+1) From dbo.Tss_SalInvoice_Hd
			--Set @Dat_SaleRequestRegDate=@Dat_SalReqToContractDate
			Set @Num_SaleAgreementPriority=0
			Set @Num_ProductionTelorance=0
		--	Set @Sta_ContractStatus=0
			Set @Sta_ContractFormStatus=1
		--	Set @Sta_ForProdOrSale=1
			Insert Into dbo.Tss_SalInvoice_Hd  
			(  
				SiSalTypeOfSales,  
				SiPubCustomCodes,  
				SiPubPersonsSpec,  
				SiPubPersonsSpecEditor,
				SiSalInvoiceRepeat_Hd,
				Cod_SaleAgreement,
				Cod_SaleAgreement2,
				Cod_SaleAgreementChange,  
				Des_SaleAgreementDesc,
				Des_SalInvoiceChangeDesc,
				Des_SalInvoiceChangeDescOld,  
				Dat_SaleRequestRegDate,  
				Num_SaleAgreementPriority,  
				Num_PreRecieveAmount,  
				Num_DiscountAmount,  
				Dat_SalReqToContractDate,  
				Des_HeaderDesc,  
				Des_EndDocDesc,  
				Sta_Kosoorat,  
				Num_ProductionTelorance,  
				Sta_ContractStatus,  
				Sta_ContractFormStatus,  
				Sta_TransportState,
				Sta_ForProdOrSale,
				Sta_MainOrNot,
				Dat_SalConfirmOfProdDate,
				Cod_LetterNo,
				SiPubSubLocations,
				Dat_ApprovedForProd,
				Sta_Branch,	
				Sta_DiscountState,  
				Num_CurrencyRate,
				Sta_CurrencyType,
				Sta_ErsalStatus,
				Num_CreditDays,
				Sta_ContIsLaminate
			)  
			Values  
			(  
				@SiSalTypeOfSales,  
				@SiPubCustomCodes,  
				@SiPubPersonsSpec,
				@SiUser,
				@SiSalInvoiceRepeat_Hd,  
				@Cod_SaleAgreement,
				@Cod_SaleAgreement2,
				@Cod_SaleAgreementChange,  
				@Des_SaleAgreementDesc,  
				@Des_SalInvoiceChangeDesc,
				@Des_SalInvoiceChangeDescOld,  
				@Dat_SaleRequestRegDate,  
				@Num_SaleAgreementPriority,  
				@Num_PreRecieveAmount,  
				@Num_DiscountAmount,  
				@Dat_SalReqToContractDate,  
				@Des_HeaderDesc,  
				@Des_EndDocDesc,  
				@Sta_Kosoorat,  
				@Num_ProductionTelorance,  
				@Sta_ContractStatus,  
				@Sta_ContractFormStatus,  
				@Sta_TransportState,
				@Sta_ForProdOrSale,
				@Sta_MainOrNot,
				@Dat_SalConfirmOfProdDate,
				@Cod_LetterNo,
				@SiPubSubLocations,
				@Dat_ApprovedForProd,
				@Sta_Branch,
				@Sta_DiscountState,  
				@Num_CurrencyRate,
				@Sta_CurrencyType,
				@Sta_ErsalStatus,
				@Num_CreditDays,
				1
			)  
			Set @SiSalInvoice_Hd=Scope_Identity()  
	
	--	If IsNull(@SiSalInvoice_Hd,0)>0
	--	Exec dbo.Tss_StdUpdateTabelLog @SiUser, 'Tss_SalInvoice_Hd', @SiSalInvoice_Hd, 'SiSalInvoice_Hd', @FlgInsUpdDel 
	
	/*	If (IsNull(@SiSalInvoice_Hd,0) <> 0) and (@Sta_IsLegalCompany = 1)
			Begin  
				exec Tss_SalUntServiceInvoiceIudStp
					0,  
					0,  
					1614,  
					@SiSalInvoice_Hd,  
					0,  
					0,  
					1,  
					1
			End
		*/
			If (IsNull(@Sta_TransportState,0) <> 0)
			Begin  
				exec Tss_SalUntServiceInvoiceIudStp
					0,  
					0,  
					312,  
					@SiSalInvoice_Hd,  
					0,  
					0,  
					1,  
					1
			End
	
			If IsNull(@SiSalInvoice_Hd,0)=0  
			Begin  
				Set @SiSalInvoice_Hd=0  
				Set @Err_Code=400  
			End  
			Return  
		End 
		else
			If (@FlgInsUpdDel=0) AND 
				Exists (SELECT SiSalInvoice_Hd FROM Tss_SalInvoice_Hd WHERE 
				(Cod_SaleAgreement2 = @Cod_SaleAgreement2) AND (Sta_MainOrNot = @Sta_MainOrNot)) and (@Sta_ContractStatus <> 9)
			Begin
				Set @Err_Code=40032062  
				Return
			End
	End
end

If (@FlgInsUpdDel=1)  
Begin
	Declare
		@Flg Int
	Set @Err_Code=0  
	If Exists(  
	Select StmSalInvoice_Hd From dbo.Tss_SalInvoice_Hd  
	Where (SiSalInvoice_Hd=@SiSalInvoice_Hd) And (StmSalInvoice_Hd=@StmSalInvoice_Hd))  
	Begin  
--		Select @Flg=Sta_ContractStatus, @Sta_ForProdOrSale=Sta_ForProdOrSale From dbo.Tss_SalInvoice_Hd Where (SiSalInvoice_Hd=@SiSalInvoice_Hd)
--		If @Sta_ForProdOrSale=1 And @Sta_ContractStatus=1
--			Set @Sta_ContractStatus=@Flg
		Update dbo.Tss_SalInvoice_Hd Set  
			SiSalTypeOfSales=@SiSalTypeOfSales,
			SiPubCustomCodes=@SiPubCustomCodes,  
			SiPubPersonsSpec=@SiPubPersonsSpec,
			SiPubPersonsSpecEditor=@SiUser,
			SiSalInvoiceRepeat_Hd=@SiSalInvoiceRepeat_Hd,  
			Cod_SaleAgreement2=@Cod_SaleAgreement2,
			Cod_SaleAgreementChange=@Cod_SaleAgreementChange,
			Des_SaleAgreementDesc=@Des_SaleAgreementDesc,  
			Des_SalInvoiceChangeDesc=@Des_SalInvoiceChangeDesc,
			Des_SalInvoiceChangeDescOld=@Des_SalInvoiceChangeDescOld,  
			Num_SaleAgreementPriority=@Num_SaleAgreementPriority,  
			Num_PreRecieveAmount=@Num_PreRecieveAmount,  
			Num_DiscountAmount=@Num_DiscountAmount,  
			Dat_SalReqToContractDate=@Dat_SalReqToContractDate,  
			Des_HeaderDesc=@Des_HeaderDesc,  
			Des_EndDocDesc=@Des_EndDocDesc,  
			Sta_Kosoorat=@Sta_Kosoorat,  
			Num_ProductionTelorance=@Num_ProductionTelorance,  
			Sta_ContractStatus=@Sta_ContractStatus,  
			Sta_TransportState=@Sta_TransportState,  
			Sta_ForProdOrSale=@Sta_ForProdOrSale,
			Sta_MainOrNot=@Sta_MainOrNot,
			Dat_SalConfirmOfProdDate=@Dat_SalConfirmOfProdDate,
			Cod_LetterNo=@Cod_LetterNo,
			SiPubSubLocations=@SiPubSubLocations,
			Dat_ApprovedForProd=@Dat_ApprovedForProd,
			Sta_Branch=@Sta_Branch,
			Sta_DiscountState=@Sta_DiscountState,
			Num_CurrencyRate=@Num_CurrencyRate,
			Sta_CurrencyType=@Sta_CurrencyType,
			Sta_ErsalStatus=@Sta_ErsalStatus,
			Num_CreditDays=@Num_CreditDays,
			Dat_SaleRequestRegDate=@Dat_SaleRequestRegDate,
			Sta_ContIsLaminate=1

		Where (SiSalInvoice_Hd=@SiSalInvoice_Hd)  

--		Exec dbo.Tss_StdUpdateTabelLog @SiUser, 'Tss_SalInvoice_Hd', @SiSalInvoice_Hd, 'SiSalInvoice_Hd', @FlgInsUpdDel 

		Set @Err_Code=@@Error  
		If @Err_Code<>0  
			Set @Err_Code=401  
		Return  
	End  
	ELse  
		Set @Err_Code=402  
End 
/*else
	Begin
		Set @Err_Code=40032062  
		Return
	End
*/ 
If @FlgInsUpdDel=2  
Begin  
	Set @Err_Code=0  
	If Exists(  
		Select StmSalInvoice_Hd From dbo.Tss_SalInvoice_Hd  
		Where (SiSalInvoice_Hd=@SiSalInvoice_Hd) And (StmSalInvoice_Hd=@StmSalInvoice_Hd))  
	Begin  
		Delete From dbo.Tss_SalInvoice_Hd Where (SiSalInvoice_Hd=@SiSalInvoice_Hd)  
		Set @Err_Code=@@Error  
		If @Err_Code<>0  
			Set @Err_Code=4000  
	End  
	Else  
	begin	
		Set @Err_Code=4000  
		Return  

	End
End
go

alter PROCEDURE Tss_SalUntFactorsAllDataRepVStp
(  
   @InternalWhere VarChar(8000)='',
   @Where VarChar(8000)='',
   @Order VarChar(8000)='',
   @SiSelected VarChar(8000)='0',
   @FlgSelected SmallInt=0,
   @FlgMoadianFacts smallint=1,
   @StartDate varchar(10)='1404/01/01',
   @EndDate Varchar(10)='1404/12/29'
) AS
If @InternalWhere<>''
   Set @InternalWhere=' Where '+@InternalWhere
If @Where<>''
   Set @Where=' Where '+@Where

If @Order<>''
   Set @Order=' Order By '+@Order
else
   Set @Order=' Order By Dat_FactorDate,Cod_FactorCode '

Declare
   @SqlTxt varchar(MAX),
   @SqlTxt1 varchar(MAX),
   @TblName varchar(MAX)


Set @TblName='dbo.tRep'+Replace(NewId(),'-','')

--if exists (select * from dbo.sysobjects where id = object_name(N'##TempSalAllRep') and OBJECTPROPERTY(id, N'IsUserTable') = 1)
 --  drop table ##TempSalAllRep


Set @SqlTxt=
'
SELECT  distinct   
	Tss_SalFactor_Hd.Sta_SentToCust,
	dbo.Tss_StdDaysIncUdf(Tss_SalFactor_Hd.Dat_FactorDate, 	ISNULL(Tss_SalInvoice_HdViw.Num_CreditDays, 60)) AS AfterCreditEndDate, 
	Tss_SalFactor_Dt.SiSalFactor_Dt, 
	Tss_SalFactor_Dt.SiPubGoods, 
	dbo.Tss_StdStaLabelsUdf(1059,dbo.Tss_SalFindGoodsTypeState(Tss_SalFactor_Dt.SiPubGoods)) GoodsTip,
	Tss_SalFactor_Dt.SiSalFactor_Hd, 
	Tss_SalFactor_Dt.Num_FactDetRowNo, 
	Tss_SalFactor_Dt.Des_FactDetDesc, 
	Tss_SalFactor_Dt.Num_FactDetGoodsNo, 
	Tss_SalFactor_Dt.Num_FactDetGoodsFee, 
	Tss_SalFactor_Dt.Sta_FactSrvOrGds, 
	Tss_SalFactor_Dt.SiPubCustomCodes, 
	--Tss_SalFactor_Dt.Num_AddedValueRow as Num_AddedTax,
	--Tss_SalFactor_Hd.Num_AddedValue as Num_AddedTax,
	Tss_SalFactor_Dt.Num_AddedTax, 
	Tss_SalFactor_Dt.Num_RowDiscount, 
	Tss_SalFactor_Dt.Tss_SalFactor_DtRegTime, 
	Tss_SalFactor_Dt.Tss_SalFactor_DtEditTime, 
	Tss_SalFactor_Dt.Tss_SalFactor_DtRegisterer, 
	Tss_SalFactor_Dt.Tss_SalFactor_DtEditor, 
	Tss_SalFactor_Hd.Cod_FactorCode, 
	Tss_SalFactor_Hd.Des_FactorDesc, 
	Tss_SalFactor_Hd.Dat_FactorDate, 
	SubString(Tss_SalFactor_Hd.Dat_FactorDate,1,4) FactorYear,
	SubString(Tss_SalFactor_Hd.Dat_FactorDate,6,2) FactorMonth,
	Tss_SalFactor_Hd.Num_FactorPreRecieveAmount, 
	Tss_SalFactor_Hd.Num_FactorDiscountAmount, 
	Tss_SalFactor_Hd.SiAccVoucher_Dt, 
	Tss_SalFactor_Hd.Sta_FactorHdState, 
	Tss_SalFactor_Hd.SiPubPersonsSpec, 
	Tss_SalFactor_Hd.SiPubSubLocations, 
	Tss_SalFactor_Hd.Sta_InvoiceCodePrint, 
	Tss_SalFactor_Hd.Num_Karmozd, 
	Tss_SalFactor_Hd.Sta_HasKarmozd, 
	Tss_SalFactor_Hd.Sta_JensPrint, 
	Tss_SalFactor_Hd.Num_FactorDiscountAmount2, 
	Tss_SalFactor_Hd.Sta_TaxCalc, 
	Tss_SalFactor_Hd.Tss_SalFactor_HdRegTime, 
	Tss_SalFactor_Hd.Tss_SalFactor_HdEditTime, 
	Tss_SalFactor_Hd.Tss_SalFactor_HdRegisterer, 
	Tss_SalFactor_Hd.Tss_SalFactor_HdEditor, 
	Cust.Cod_PubPersonCode, 
	ltrim(rtrim(isnull(Cust.Des_PubPersonName1,'''')))+ltrim(rtrim(isnull(Cust.Des_PubPersonName2,''''))) as Des_FullName, 
	Cust.Des_PersonAddress, 
	Cust.Des_PersonPhons, 
	Cust.Des_Person_FaxNo, 
	Cust.Des_PersEmailAddress, 
	Cust.Des_PersPostalCode, 
	Cust.Des_PersWebSiteAddress, 
	Cust.Cod_PersEconomicCode, 
	Cust.Des_OrgManagerName, 
	Cust.Dat_OrgRegisterDate, 
	Cust.Cod_OrgRegisterNo, 
	Cust.Des_PersonAnbarAddress, 
	Cust.Des_CoAndOrgNationalCode, 
	Tss_PubSubLocations.Cod_SubLocCode, 
	Tss_PubSubLocations.Des_SubLocName, 
	Tss_AccVoucher_Hd.SiAccVoucher_Hd, 
	Tss_AccVoucher_Hd.Dat_VhedDate, 
	Saler.Cod_PubPersonCode AS CodSaler, 
	Saler.Des_FullName AS DesSaler, 
	Gds.Cod_PubGoodsCode, 
	Gds.Des_PubGoodsDesc, 
	Srv.Cod_CustomCodesCode, 
	Srv.Des_CustomCodesDesc, 
	Tss_SalInvoice_HdViw.Cod_SaleAgreement, 
	Tss_SalInvoice_HdViw.Cod_SaleAgreement2, 
	Tss_SalInvoice_HdViw.Dat_SalReqToContractDate, 
	Tss_SalInvoice_HdViw.Sta_ContractStatus, 
	Tss_SalInvoice_HdViw.Sta_MainOrNot, 
	Tss_SalInvoice_HdViw.Des_CustomCodesDesc AS Mazroof, 
	Tss_SalInvoice_HdViw.Des_SaleAgreementDesc, 
	Tss_SalInvoice_HdViw.Cod_PubPersonCode AS CodeContCust, 
	Tss_SalInvoice_HdViw.Des_FullName AS DesContCust, 
	Tss_SalInvoice_HdViw.Cod_SaleAgreementChange, 
	dbo.Tss_PrcDeliRecipCodes(Tss_SalFactor_Hd.SiSalFactor_Hd) AS ResCode,
	(SELECT        
		SUM(Tss_InvOutGo_Dt.Num_InvExtDetailGdsAmount)
	FROM            
	Tss_InvOutGo_Dt INNER JOIN
	Tss_InvOutGo_Hd ON Tss_InvOutGo_Dt.SiInvOutGo_Hd = Tss_InvOutGo_Hd.SiInvOutGo_Hd INNER JOIN
	Tss_SalGdsRecieptToFactor ON Tss_InvOutGo_Hd.SiInvOutGo_Hd = Tss_SalGdsRecieptToFactor.SiInvOutGo_Hd
	WHERE        
		(Tss_InvOutGo_Dt.SiInvOutGo_Hd = Tss_SalGdsRecieptToFactor.SiInvOutGo_Hd) AND (Tss_SalGdsRecieptToFactor.SiSalFactor_Hd = Tss_SalFactor_Dt.SiSalFactor_Hd) AND (Tss_InvOutGo_Dt.SiPubGoods = Tss_SalFactor_Dt.SiPubGoods)
		) ResidShodeh,
	(SELECT Tss_SalInvoice_Dt.Num_OneMeterSheetPrice FROM Tss_SalInvoice_Dt WHERE (Tss_SalInvoice_Dt.SiSalInvoice_Hd=Tss_SalFactor_Dt.SiSalInvoice_HdRow) AND (Tss_SalInvoice_Dt.SiPubGoods = Tss_SalFactor_Dt.SiPubGoods)) FeeOneMeterVaragh,
	(SELECT Tss_SalInvoice_Dt.Num_OneMeterBoxPrice FROM	Tss_SalInvoice_Dt WHERE	(Tss_SalInvoice_Dt.SiSalInvoice_Hd=Tss_SalFactor_Dt.SiSalInvoice_HdRow) AND (Tss_SalInvoice_Dt.SiPubGoods = Tss_SalFactor_Dt.SiPubGoods)) FeeOneMeterBox,
	Tss_SalFactor_Dt.Num_FactDetGoodsNo*Tss_SalFactor_Dt.Num_FactDetGoodsFee AS TotalRow, 
	--dbo.Tss_SalFactorPriceUdf(3, Tss_SalFactor_Hd.SiSalFactor_Hd, NULL) AS TotalRow, 
	$0.0 AS SrvPrc, 
	$0.0 AS AllPrc, 
	$0.0 AS KeliSaleSrvPrc, 
	$0.0 AS HamlSrvPrc, 
	$0.0 AS GhalebProdSrvPrc, 
	$0.0 AS ZincFilmSrvPrc, 
	$0.0 AS ZincChapKeliSrvPrc, 
	$0.0 AS KeliSakhtSrvPrc, 
	$0.0 AS Shahrdari2SrvPrc, 
	$0.0 AS ArzeshAf2SrvPrc, 
	$0.0 AS ArzeshAf4SrvPrc, 
	$0.0 AS HamloBarbariSrvPrc, 
	$0.0 AS TarahiSrvPrc, 
	$0.0 AS AlalTarrahiPrc, 
	$0.0 AS AlalSakhteGhalebPrc, 
	$0.0 AS HaftDarsadeAlalKeliPrc, 
	$0.0 AS MakharejeTaghribiTarhshakhtKeliPrc, 
	$0.0 AS KasreMAliatPrc, 
	$0.0 AS HazinehTarahiSrvPrc,	
	dbo.Tss_SalFindGdsGramage(Tss_SalFactor_Dt.SiPubGoods) as OneGdsGramage,
	dbo.Tss_SalFindGdsGramage(Tss_SalFactor_Dt.SiPubGoods)*Tss_SalFactor_Dt.Num_FactDetGoodsNo as FactorWeight,
	dbo.Tss_SalFindGdsFlutType(Tss_SalFactor_Dt.SiPubGoods) GdsFluteType,
	len(dbo.Tss_SalFindGdsFlutType(Tss_SalFactor_Dt.SiPubGoods)) GdsFluteTypeLen,
	dbo.Tss_SalFindGdsArea(Tss_SalFactor_Dt.SiPubGoods) as OneGdsArea,
	dbo.Tss_SalFindGdsArea(Tss_SalFactor_Dt.SiPubGoods)*Tss_SalFactor_Dt.Num_FactDetGoodsNo as FactorArea,
	dbo.Tss_SalFindAddedCostsForContract(Tss_SalInvoice_HdViw.SiSalInvoice_Hd,Tss_SalFactor_Dt.SiPubGoods,0)*Tss_SalFactor_Dt.Num_FactDetGoodsNo as ColorCost,
	dbo.Tss_SalFindAddedCostsForContract(Tss_SalInvoice_HdViw.SiSalInvoice_Hd,Tss_SalFactor_Dt.SiPubGoods,1)*Tss_SalFactor_Dt.Num_FactDetGoodsNo as HamlCost,
	dbo.Tss_SalFindAddedCostsForContract(Tss_SalInvoice_HdViw.SiSalInvoice_Hd,Tss_SalFactor_Dt.SiPubGoods,2)*Tss_SalFactor_Dt.Num_FactDetGoodsNo as PalleteCost,
	(SELECT top 1 Num_GdsFee FROM Tss_SalInvoice_Dt WHERE (SiSalInvoice_Hd = Tss_SalFactor_Hd.SiSalInvoice_Hd) AND (SiPubGoods = Tss_SalFactor_Dt.SiPubGoods)) as Num_GdsFee,
	(SELECT top 1 Num_FeeAdjust FROM Tss_SalInvoice_Dt WHERE (SiSalInvoice_Hd = Tss_SalFactor_Hd.SiSalInvoice_Hd) AND (SiPubGoods = Tss_SalFactor_Dt.SiPubGoods)) as Num_FeeAdjust, 
	(SELECT top 1 Num_FeeAdjust FROM Tss_SalInvoice_Dt WHERE (SiSalInvoice_Hd = Tss_SalFactor_Hd.SiSalInvoice_Hd) AND (SiPubGoods = Tss_SalFactor_Dt.SiPubGoods))*Tss_SalFactor_Dt.Num_FactDetGoodsNo as TotalDiscount, 
	Tss_SalTypeOfSales.Cod_SalTypeCode, 
	Tss_SalTypeOfSales.Des_SalTypeDesc,
	Tss_SalInvoice_HdViw.Cod_LetterNo,
    Tss_SalFactor_Hd.irtaxid,
    Tss_SalFactor_Hd.Taxid,
    Tss_SalFactor_Hd.referenceNumber,
    Tss_SalFactor_Hd.uid,
    Tss_SalFactor_Hd.Sta_FactorType,
    Tss_SalFactor_Hd.Sta_CurrencyType,
    Tss_SalFactor_Hd.Num_CurrencyRate,
    Tss_SalFactor_Hd.CottageNo,
    Tss_SalFactor_Hd.CottageDate,
    Tss_SalFactor_Hd.Num_CottageTotWeight,
    Tss_SalFactor_Hd.CustomsCode,
    Tss_SalFactor_Hd.SiSalFactor_HdRef,
    RefFactor.Cod_FactorCode AS RefFactorCde, 
    RefFactor.Dat_FactorDate AS RefFactorDate,
	dbo.HexToDec(SUBSTRING(Tss_SalFactor_Hd.taxid, 12, 10)) AS Taxdecimal_value,
	RefFactor.Dat_FactorDate as FactorDateRef,
	RefFactor.Cod_FactorCode as FactorCodeRef,	
	Tss_SalFactor_Hd.Sta_TaxFalg,
	Tss_SalFactor_Hd.Sta_TasviehType,
	dbo.Tss_StdStaLabelsUdf(1131, Tss_SalFactor_Hd.Sta_TasviehType) as Sta_TasviehTypeDesc,
	isnull((Select Des_RowDesc From dbo.Tss_SalInvoice_Dt Where (SiSalInvoice_Hd = Tss_SalFactor_Hd.SiSalInvoice_Hd) and (SiPubGoods = Tss_SalFactor_Dt.SiPubGoods)),'''') ContDes_RowDesc  
	into  
		'+@TblName+'

FROM  Tss_SalFactor_Hd AS RefFactor RIGHT OUTER JOIN
                         Tss_SalFactor_Dt INNER JOIN
                         Tss_SalFactor_Hd AS Tss_SalFactor_Hd ON Tss_SalFactor_Dt.SiSalFactor_Hd = Tss_SalFactor_Hd.SiSalFactor_Hd INNER JOIN
                         Tss_PubPersonsSpec AS Cust ON Tss_SalFactor_Hd.SiPubPersonsSpec = Cust.SiPubPersonsSpec INNER JOIN
                         Tss_PubSubLocations ON Tss_SalFactor_Hd.SiPubSubLocations = Tss_PubSubLocations.SiPubSubLocations ON RefFactor.SiSalFactor_Hd = Tss_SalFactor_Hd.SiSalFactor_HdRef LEFT OUTER JOIN
                         Tss_SalGdsRecieptToFactor AS Tss_SalGdsRecieptToFactor_1 ON Tss_SalFactor_Hd.SiSalFactor_Hd = Tss_SalGdsRecieptToFactor_1.SiSalFactor_Hd LEFT OUTER JOIN
                         Tss_SalTypeOfSales ON Tss_SalFactor_Hd.SiSalTypeOfFactor = Tss_SalTypeOfSales.SiSalTypeOfSales LEFT OUTER JOIN
                         Tss_PubPersonsViw AS Saler ON Cust.SiPerRelatedSaler = Saler.SiPubPersonsSpec LEFT OUTER JOIN
                         Tss_SalInvoice_HdViw ON Tss_SalFactor_Hd.SiSalInvoice_Hd = Tss_SalInvoice_HdViw.SiSalInvoice_Hd LEFT OUTER JOIN
                         Tss_AccVoucher_Hd INNER JOIN
                         Tss_AccVoucher_Dt ON Tss_AccVoucher_Hd.SiAccVoucher_Hd = Tss_AccVoucher_Dt.SiAccVoucher_Hd ON Tss_SalFactor_Hd.SiAccVoucher_Dt = Tss_AccVoucher_Dt.SiAccVoucher_Dt LEFT OUTER JOIN
                         Tss_PubCustomCodesViw AS Srv ON Tss_SalFactor_Dt.SiPubCustomCodes = Srv.SiPubCustomDataType LEFT OUTER JOIN
                         Tss_PubGoodsViw AS Gds ON Tss_SalFactor_Dt.SiPubGoods = Gds.SiPubGoods'

if (isnull(@startdate,'')<>'') and (isnull(@EndDate,'')<>'')
Set @SqlTxt= @SqlTxt +
' where	Tss_SalFactor_Hd.Dat_FactorDate between '+''''+@StartDate+''''+' and '+''''+@EndDate+''''+''

if isnull(@FlgMoadianFacts,0)=0
    Set @SqlTxt= @SqlTxt + ' and  Tss_SalFactor_Hd.SiSalFactor_Hd not in (SELECT SiSalFactor_HdRef FROM Tss_SalFactor_Hd WHERE (Sta_FactorHdState = 2)) '

print @SqlTxt

If isnull(@SiSelected,0)>0
Begin
   If @FlgSelected=0
      Exec (@SqlTxt+' and Tss_SalFactor_Hd.SiSalInvoice_Hd in ('+@SiSelected+')')
   If @FlgSelected=1
      Exec (@SqlTxt+' and Tss_SalFactor_Hd.SiPubPersonsSpec in ('+@SiSelected+')')
   If @FlgSelected=2
      Exec (@SqlTxt+' and Tss_SalFactor_Dt.SiPubGoods in ('+@SiSelected+')')
End
Else
   Exec (@SqlTxt)

print 'Select * From
(
   Select * From
   (
   SELECT  *  FROM '+@TblName+' ) Ccc  '+@InternalWhere+'
) CalcSel ' + @Where + @Order

Exec(
'Select * From
(
   Select * From
 (
   SELECT  *  FROM '+@TblName+' ) Ccc  '+@InternalWhere+'
) CalcSel ' + @Where + @Order)


IF OBJECT_ID(@TblName, 'U') IS NOT NULL
begin
	Set @SqlTxt1='Drop Table '+@TblName
	Exec(@SqlTxt1)
end

GO

alter Procedure Tss_RapPayedChequePardakhtiVchRegStp
(
	@RapType SmallInt=0,
   @SiAccFinancePeriod Numeric=Null, 
   @SiPubSubLocations Numeric=Null,
   @Des_VhedDesc VarChar(500)='',
   @Des_VhedDescDet VarChar(500)='',
   @SiResid VarChar(8000)='',
	@SiResidDet Numeric=Null,
	@SiTafBed Numeric=Null,
	@SiTafBes Numeric=Null,
   @SiAccCodeBookBed Numeric=Null,
   @SiAccCodeBookBes Numeric=Null,
	@UserIP varchar(50),
	@WindosUser varchar(200),
	@SiUser numeric
)
as

Declare
   @Dat_VhedDate VarChar(10),
   @SiAccVoucher_Hd Numeric,
   @SiAccVoucher_Dt Numeric,
   @SiAccVoucherType Numeric,
   @SiTbl Int,
	@SiResidRap Numeric, 
	@SiPersBed Numeric, 
	@SiPersBes Numeric, 
	@DatRegister VarChar(10),
	@CodSerial Varchar(50), 
	@DatEndDate VarChar(10),
	@CodParaSanad VarChar(2),
	@Err_Code Int,
	@SiTbl2 int, 
	@SiAccBed Numeric, 
	@SiAccBes Numeric, 
	@BabatDesc VarChar(500),
	@SiChqRef Numeric,
	@GbzAmount Numeric, 
	@SiRef Numeric,
	@RefState SmallInt,
   @SiAccFinancePeriodToPlace Numeric,
   @Det_Row Int,
   @Des_VdetDesc Varchar(5000),
	@AllAmount Numeric,
	@PerNameBed VarChar(500),
	@PerNameBes VarChar(500),
	@Sta_TafType1 smallint,
	@SiVchDtBes Numeric,
	@Sta_RapPayedChequeState smallint


SELECT @Sta_TafType1=Sta_TafType1 FROM dbo.Tss_AccCodeBook WHERE (SiAccCodeBook = @SiAccCodeBookBed)

SELECT 
	@SiAccFinancePeriodToPlace=SiAccFinancePeriodToPlace
FROM
	dbo.Tss_AccFinancePeriodToPlace
WHERE     
	(SiAccFinancePeriod = @SiAccFinancePeriod) AND 
	(SiPubSubLocations = @SiPubSubLocations)

If @RapType=0
	Set @CodParaSanad='12'

SELECT @SiAccVoucherType=SiAccVoucherType FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup = 5)

If IsNull(@SiAccVoucherType,0)=0
Begin
	Set @Err_Code=1
	Return
End
Declare
   @TempVchTbl Table 
	(
		SiTbl int identity(1,1), 
		SiResidRap Numeric, 
		SiPersBed Numeric, 
		SiPersBes Numeric, 
		DatRegister VarChar(10),
		CodSerial Varchar(50), 
		DatEndDate VarChar(10),
		Sta_RapPayedChequeState smallint
	)

Declare
   @TempVchTbl2 Table 
	(
		SiTbl2 int identity(1,1), 
		SiAccBed Numeric, 
		SiAccBes Numeric, 
		BabatDesc VarChar(500),
		SiChqRef Numeric,
		GbzAmount Numeric, 
		SiRef Numeric,
		RefState SmallInt
	)

Insert Into @TempVchTbl
(
	SiResidRap,
	SiPersBed,
	SiPersBes,
	DatRegister,
	CodSerial,
	DatEndDate,
	Sta_RapPayedChequeState
)
SELECT     
	dbo.Tss_RapPayedCheque.SiRapPayedCheque, 
	dbo.Tss_RapChequesDefine.SiPubPersonsSpec SiPerBed,
	dbo.Tss_RapPayedCheque.SiPubPersonsSpec AS SiPerBes, 
	dbo.Tss_RapPayedCheque.Dat_RapPayedChequeRegDate, 
	dbo.Tss_RapPayedCheque.Cod_RapPayedChequeSerial, 
	dbo.Tss_RapPayedCheque.Dat_RapPayedChequeEndDate,
	dbo.Tss_RapPayedCheque.Sta_RapPayedChequeState
FROM         
	dbo.Tss_RapPayedCheque INNER JOIN dbo.Tss_RapChequesDefine ON 
	dbo.Tss_RapPayedCheque.SiRapChequesDefine = dbo.Tss_RapChequesDefine.SiRapChequesDefine INNER JOIN
	dbo.Tss_PubPersonsSpec ON dbo.Tss_RapChequesDefine.SiPubPersonsSpec = dbo.Tss_PubPersonsSpec.SiPubPersonsSpec
WHERE     
	(dbo.Tss_RapPayedCheque.SiRapPayedCheque IN (SELECT SiSel FROM dbo.Tss_StdStringSiFindUdf(@SiResid) Tss_StdStringSiFindUdf))

select * from @TempVchTbl

if @Sta_TafType1=0
Begin
	While Exists(Select Top 1 SiTbl From @TempVchTbl)
	Begin
		Set @AllAmount=0
		Select Top 1
			@SiTbl=SiTbl,
			@SiResidRap=SiResidRap,
			@SiPersBed=SiPersBed,
			@SiPersBes=SiPersBes,
			@DatRegister=DatRegister,
			@CodSerial=CodSerial,
			@DatEndDate=DatEndDate,
			@Sta_RapPayedChequeState=Sta_RapPayedChequeState
		From @TempVchTbl
		Set @SiPersBed=@SiTafBed
		Set @SiAccVoucher_Hd=0
		Set @Dat_VhedDate=@DatRegister
		SELECT @SiAccVoucher_Hd=SiAccVoucher_Hd FROM dbo.Tss_AccVoucher_Hd
		Where
			(SiAccVoucherType=@SiAccVoucherType) And
			(Dat_VhedDate=@DatRegister) And
			(SiAccFinancePeriodToPlace=@SiAccFinancePeriodToPlace)
		Set @SiAccVoucher_Hd=IsNull(@SiAccVoucher_Hd,0)
		If @SiAccVoucher_Hd=0
		Begin
			Exec dbo.Tss_AccVouchHedRegStp
			   @SiAccFinancePeriodToPlace,
				@SiAccVoucherType,
			   @Dat_VhedDate,
			   @Des_VhedDesc,
				@SiAccVoucher_Hd  OutPut
			If IsNull(@SiAccVoucher_Hd,0)=0
				Exec dbo.Tss_StdInsertLogData @SiAccVoucher_Hd,'Tss_AccVoucher_Hd',@UserIP,@WindosUser,0,@SiUser
			If IsNull(@SiAccVoucher_Hd,0)=0
			Begin
				Set @Err_Code=2
				Return
			End
		End
	   Select @Det_Row=Max(IsNull(Num_VDetRow,0))+1 FROM Tss_AccVoucher_Dt WHERE (SiAccVoucher_Hd = @SiAccVoucher_Hd) 
		if isnull(@Det_Row,0)=0
			Set @Det_Row=1
		Insert Into  @TempVchTbl2
		(
			SiAccBed,
			SiAccBes,
			BabatDesc,
			SiChqRef,
			GbzAmount,
			SiRef,
			RefState
		)
		SELECT     
			Behalf.SiAccCodeBookBehalfBed, 
			Behalf.SiAccCodeBookBehalfBes, 
			Behalf.Des_RapBehalfDesc, 
			ChqPayRef.SiRapPayedChequeRef, 
			ChqPayRef.Num_RapPayedChequeRefAmount, 
			ChqPayRef.SiRapPayedChequeRef_Refrence,
			RefDef.Sta_RapRefrenceDefType
		FROM         
			Tss_RapBehalfDefine Behalf INNER JOIN Tss_RapPayedChequeRef ChqPayRef ON 
			Behalf.SiRapBehalfDefine = ChqPayRef.SiRapBehalfDefine LEFT OUTER JOIN Tss_RapRefrenceDefine RefDef ON 
			Behalf.SiRapRefrenceDefine = RefDef.SiRapRefrenceDefine
		WHERE
			(ChqPayRef.SiRapPayedCheque=@SiResidRap)

		SELECT @GbzAmount=Num_RapPayedChequeRefAmount FROM Tss_RapPayedChequeRef WHERE (SiRapPayedChequeRef = @SiResidDet)	

		if @SiAccCodeBookBed>0 
			Set @SiAccBed=@SiAccCodeBookBed
		if @SiAccCodeBookBes>0 
			Set @SiAccBes=@SiAccCodeBookBes

		SELECT     @PerNameBed=Des_FullName
		FROM         Tss_PubPersonsViw
		WHERE     (SiPubPersonsSpec = @SiPersBed)

		SELECT     @PerNameBes=Des_FullName
		FROM         Tss_PubPersonsViw
		WHERE     (SiPubPersonsSpec = @SiPersBes)

		Set @SiPersBes=@SiTafBes
		
		if Exists (SELECT SiAccVoucher_Dt FROM Tss_RapPayedChequeRef WHERE (SiRapPayedCheque = @SiResid) And (SiAccVoucher_Dt is not null) )
			Select @SiVchDtBes=SiAccVoucher_Dt From dbo.Tss_AccVoucher_Dt where SiAccVoucher_Dt in 
			(SELECT SiAccVoucher_Dt FROM Tss_RapPayedChequeRef WHERE (SiRapPayedCheque = @SiResid)) and 
			(Num_VdetCreditAmount>0) and (Num_VdetAmount>0)
		if Not Exists (SELECT SiAccVoucher_Dt FROM Tss_RapPayedChequeRef WHERE (SiRapPayedCheque = @SiResid) And (SiAccVoucher_Dt is not null) )
		Begin
			Set @Des_VdetDesc=' صدور چک شماره  '+@CodSerial+' به تاریخ سررسید '+@DatEndDate + ' '+@Des_VhedDescDet
			--Set @Des_VdetDesc=@Des_VhedDescDet
			Insert Into  dbo.Tss_AccVoucher_Dt
			(
	         SiAccCodeBook, 
	         SiPubPersonsSpec1, 
	         SiAccVoucher_Hd, 
	         Num_VDetRow, 
	         Des_VdetDesc, 
	         Dat_AccVoucherDetDate, 
	         Sta_VdetDebtOrCredit, 
	         Num_VdetDebtAmount, 
	         Num_VdetCreditAmount, 
	         Num_VdetAmount,
				SiRelatedSenderSerial,
				Des_RelatedTableSender
			)
			Values
			(
	         @SiAccBed, 
	         @SiTafBed, 
	         @SiAccVoucher_Hd, 
	         @Det_Row, 
	         @Des_VdetDesc, 
	         @DatRegister, 
	         0, 
	         @GbzAmount, 
	         0, 
	         @GbzAmount,
				@SiResidRap,
				'Tss_RapPayedCheque'
			)

	      Set @SiAccVoucher_Dt=Scope_Identity()
			Exec dbo.Tss_StdInsertLogData @SiAccVoucher_Dt,'Tss_AccVoucher_Dt',@UserIP,@WindosUser,0,@SiUser
			
		  if @Sta_RapPayedChequeState =0 
	      Update dbo.Tss_RapPayedChequeRef Set SiAccVoucher_Dt=@SiAccVoucher_Dt Where (SiRapPayedCheque=@SiResidRap)

		  if @Sta_RapPayedChequeState =1 
	      Update dbo.Tss_RapPayedChequeRef Set SiVchDtForBardasht=@SiAccVoucher_Dt Where (SiRapPayedCheque=@SiResidRap)

	      Set @Det_Row=@Det_Row+1

			Delete From @TempVchTbl2 Where (SiTbl2=@SiTbl2)

			Set @Des_VdetDesc=' صدور چک شماره  '+@CodSerial+' به تاریخ سررسید '+@DatEndDate + ' '+@Des_VhedDescDet

			Insert Into  dbo.Tss_AccVoucher_Dt
			(
		      SiAccCodeBook, 
		      SiPubPersonsSpec1, 
		      SiAccVoucher_Hd, 
		      Num_VDetRow, 
		      Des_VdetDesc, 
		      Dat_AccVoucherDetDate, 
		      Sta_VdetDebtOrCredit, 
		      Num_VdetDebtAmount, 
		      Num_VdetCreditAmount, 
		      Num_VdetAmount,
				SiRelatedSenderSerial,
				Des_RelatedTableSender
			)
			Values
			(
		      @SiAccBes, 
		      @SiTafBes, 
		      @SiAccVoucher_Hd, 
		      @Det_Row, 
		      @Des_VdetDesc, 
		      @DatRegister, 
		      1, 
		      0, 
		    	@GbzAmount, 
		      @GbzAmount,
				@SiResidRap,
				'Tss_RapPayedCheque'
			)
	      Set @SiAccVoucher_Dt=Scope_Identity()
			Exec dbo.Tss_StdInsertLogData @SiAccVoucher_Dt,'Tss_AccVoucher_Dt',@UserIP,@WindosUser,0,@SiUser

		  if @Sta_RapPayedChequeState =0 
	      Update dbo.Tss_RapPayedChequeRef Set SiAccVoucher_Dt=@SiAccVoucher_Dt Where (SiRapPayedCheque=@SiResidRap)

		  if @Sta_RapPayedChequeState =1 
	      Update dbo.Tss_RapPayedChequeRef Set SiVchDtForBardasht=@SiAccVoucher_Dt Where (SiRapPayedCheque=@SiResidRap)

		End
		Else
		Begin
			Set @Des_VdetDesc=' صدور چک شماره  '+@CodSerial+' به تاریخ سررسید '+@DatEndDate + ' '+@Des_VhedDescDet
--			Set @Des_VdetDesc=@Des_VhedDescDet
			Insert Into  dbo.Tss_AccVoucher_Dt
			(
	         SiAccCodeBook, 
	         SiPubPersonsSpec1, 
	         SiAccVoucher_Hd, 
	         Num_VDetRow, 
	         Des_VdetDesc, 
	         Dat_AccVoucherDetDate, 
	         Sta_VdetDebtOrCredit, 
	         Num_VdetDebtAmount, 
	         Num_VdetCreditAmount, 
	         Num_VdetAmount,
				SiRelatedSenderSerial,
				Des_RelatedTableSender
			)
			Values
			(
	         @SiAccBed, 
	         @SiTafBed, 
	         @SiAccVoucher_Hd, 
	         @Det_Row, 
	         @Des_VdetDesc, 
	         @DatRegister, 
	         0, 
	         @GbzAmount, 
	         0, 
	         @GbzAmount,
				@SiResidRap,
				'Tss_RapPayedCheque'
			)

	      Set @SiAccVoucher_Dt=Scope_Identity()
			Exec dbo.Tss_StdInsertLogData @SiAccVoucher_Dt,'Tss_AccVoucher_Dt',@UserIP,@WindosUser,0,@SiUser

		  if @Sta_RapPayedChequeState =0 
	      Update dbo.Tss_RapPayedChequeRef Set SiAccVoucher_Dt=@SiAccVoucher_Dt Where (SiRapPayedCheque=@SiResidRap)

		  if @Sta_RapPayedChequeState =1 
	      Update dbo.Tss_RapPayedChequeRef Set SiVchDtForBardasht=@SiAccVoucher_Dt Where (SiRapPayedCheque=@SiResidRap)


	      Set @Det_Row=@Det_Row+1

			Delete From @TempVchTbl2 Where (SiTbl2=@SiTbl2)
			--Set @Des_VdetDesc=' پرداخت چک شماره '+@CodSerial+' به '+@PerNameBes+ ' بابت '+@Des_VhedDescDet

			Update dbo.Tss_AccVoucher_Dt 
			Set Num_VdetCreditAmount=Num_VdetCreditAmount+@GbzAmount , Num_VdetAmount=Num_VdetAmount+@GbzAmount
			Where SiAccVoucher_Dt=@SiVchDtBes
		End
		Delete From @TempVchTbl Where (SiTbl=@SiTbl)
	End
	Delete @TempVchTbl
	Delete @TempVchTbl2
End	



if @Sta_TafType1=1
Begin
	While Exists(Select Top 1 SiTbl From @TempVchTbl)
	Begin
		Set @AllAmount=0
		Select Top 1
			@SiTbl=SiTbl,
			@SiResidRap=SiResidRap,
			@SiPersBed=SiPersBed,
			@SiPersBes=SiPersBes,
			@DatRegister=DatRegister,
			@CodSerial=CodSerial,
			@DatEndDate=DatEndDate,
			@Sta_RapPayedChequeState=Sta_RapPayedChequeState
		From @TempVchTbl
		Set @SiPersBed=@SiTafBed
		Set @SiAccVoucher_Hd=0
		Set @Dat_VhedDate=@DatRegister
		SELECT @SiAccVoucher_Hd=SiAccVoucher_Hd FROM dbo.Tss_AccVoucher_Hd
		Where
			(SiAccVoucherType=@SiAccVoucherType) And
			(Dat_VhedDate=@DatRegister) And
			(SiAccFinancePeriodToPlace=@SiAccFinancePeriodToPlace)
		Set @SiAccVoucher_Hd=IsNull(@SiAccVoucher_Hd,0)
		If @SiAccVoucher_Hd=0
		Begin
			Exec dbo.Tss_AccVouchHedRegStp
			   @SiAccFinancePeriodToPlace,
				@SiAccVoucherType,
			   @Dat_VhedDate,
			   @Des_VhedDesc,
				@SiAccVoucher_Hd  OutPut
			If not IsNull(@SiAccVoucher_Hd,0)=0
				Exec dbo.Tss_StdInsertLogData @SiAccVoucher_Hd,'Tss_AccVoucher_Hd',@UserIP,@WindosUser,0,@SiUser
			If IsNull(@SiAccVoucher_Hd,0)=0
			Begin
				Set @Err_Code=2
				Return
			End
		End
	   Select @Det_Row=Max(IsNull(Num_VDetRow,0))+1 FROM Tss_AccVoucher_Dt WHERE (SiAccVoucher_Hd = @SiAccVoucher_Hd) 
		if isnull(@Det_Row,0)=0
			Set @Det_Row=1
		Insert Into  @TempVchTbl2
		(
			SiAccBed,
			SiAccBes,
			BabatDesc,
			SiChqRef,
			GbzAmount,
			SiRef,
			RefState
		)
		SELECT     
			Behalf.SiAccCodeBookBehalfBed, 
			Behalf.SiAccCodeBookBehalfBes, 
			Behalf.Des_RapBehalfDesc, 
			ChqPayRef.SiRapPayedChequeRef, 
			ChqPayRef.Num_RapPayedChequeRefAmount, 
			ChqPayRef.SiRapPayedChequeRef_Refrence,
			RefDef.Sta_RapRefrenceDefType
		FROM         
			Tss_RapBehalfDefine Behalf INNER JOIN Tss_RapPayedChequeRef ChqPayRef ON 
			Behalf.SiRapBehalfDefine = ChqPayRef.SiRapBehalfDefine LEFT OUTER JOIN Tss_RapRefrenceDefine RefDef ON 
			Behalf.SiRapRefrenceDefine = RefDef.SiRapRefrenceDefine
		WHERE
			(ChqPayRef.SiRapPayedCheque=@SiResidRap)

		SELECT @GbzAmount=Num_RapPayedChequeRefAmount FROM Tss_RapPayedChequeRef WHERE (SiRapPayedChequeRef = @SiResidDet)	

		if @SiAccCodeBookBed>0 
			Set @SiAccBed=@SiAccCodeBookBed
		if @SiAccCodeBookBes>0 
			Set @SiAccBes=@SiAccCodeBookBes

		SELECT     @PerNameBed=Des_FullName
		FROM         Tss_PubPersonsViw
		WHERE     (SiPubPersonsSpec = @SiPersBed)

		SELECT     @PerNameBes=Des_FullName
		FROM         Tss_PubPersonsViw
		WHERE     (SiPubPersonsSpec = @SiPersBes)

		Set @SiPersBes=@SiTafBes

		if Exists (SELECT SiAccVoucher_Dt FROM Tss_RapPayedChequeRef WHERE (SiRapPayedCheque = @SiResid) And (SiAccVoucher_Dt is not null) )
			Select @SiVchDtBes=SiAccVoucher_Dt From dbo.Tss_AccVoucher_Dt where SiAccVoucher_Dt in 
			(SELECT SiAccVoucher_Dt FROM Tss_RapPayedChequeRef WHERE (SiRapPayedCheque = @SiResid)) and 
			(Num_VdetCreditAmount>0) and (Num_VdetAmount>0)
		if Not Exists (SELECT SiAccVoucher_Dt FROM Tss_RapPayedChequeRef WHERE (SiRapPayedCheque = @SiResid) And (SiAccVoucher_Dt is not null) )
		Begin
			Set @Des_VdetDesc=' صدور چک شماره  '+@CodSerial+' به تاریخ سررسید '+@DatEndDate + ' '+@Des_VhedDescDet
--			Set @Des_VdetDesc= @Des_VhedDescDet
			Insert Into  dbo.Tss_AccVoucher_Dt
			(
	         SiAccCodeBook, 
	         SiPubPersonsSpec1, 
	         SiAccVoucher_Hd, 
	         Num_VDetRow, 
	         Des_VdetDesc, 
	         Dat_AccVoucherDetDate, 
	         Sta_VdetDebtOrCredit, 
	         Num_VdetDebtAmount, 
	         Num_VdetCreditAmount, 
	         Num_VdetAmount,
				SiRelatedSenderSerial,
				Des_RelatedTableSender
			)
			Values
			(
	         @SiAccBed, 
	         @SiTafBed, 
	         @SiAccVoucher_Hd, 
	         @Det_Row, 
	         @Des_VdetDesc, 
	         @DatRegister, 
	         0, 
	         @GbzAmount, 
	         0, 
	         @GbzAmount,
				@SiResidRap,
				'Tss_RapPayedCheque'
			)
	      Set @SiAccVoucher_Dt=Scope_Identity()
			Exec dbo.Tss_StdInsertLogData @SiAccVoucher_Dt,'Tss_AccVoucher_Dt',@UserIP,@WindosUser,0,@SiUser

		  if @Sta_RapPayedChequeState =0 
	      Update dbo.Tss_RapPayedChequeRef Set SiAccVoucher_Dt=@SiAccVoucher_Dt Where (SiRapPayedCheque=@SiResidRap)

		  if @Sta_RapPayedChequeState =1 
	      Update dbo.Tss_RapPayedChequeRef Set SiVchDtForBardasht=@SiAccVoucher_Dt Where (SiRapPayedCheque=@SiResidRap)

	      Set @Det_Row=@Det_Row+1

			Delete From @TempVchTbl2 Where (SiTbl2=@SiTbl2)

			Set @Des_VdetDesc=' صدور چک شماره  '+@CodSerial+' به تاریخ سررسید '+@DatEndDate + ' '+' در وجه '+@PerNameBed + ' '+@Des_VhedDescDet

			Insert Into  dbo.Tss_AccVoucher_Dt
			(
		      SiAccCodeBook, 
		      SiPubPersonsSpec1, 
		      SiAccVoucher_Hd, 
		      Num_VDetRow, 
		      Des_VdetDesc, 
		      Dat_AccVoucherDetDate, 
		      Sta_VdetDebtOrCredit, 
		      Num_VdetDebtAmount, 
		      Num_VdetCreditAmount, 
		      Num_VdetAmount,
				SiRelatedSenderSerial,
				Des_RelatedTableSender
			)
			Values
			(
		      @SiAccBes, 
		      @SiTafBes, 
		      @SiAccVoucher_Hd, 
		      @Det_Row, 
		      @Des_VdetDesc, 
		      @DatRegister, 
		      1, 
		      0, 
		    	@GbzAmount, 
		      @GbzAmount,
				@SiResidRap,
				'Tss_RapPayedCheque'
			)

	      Set @SiAccVoucher_Dt=Scope_Identity()
			Exec dbo.Tss_StdInsertLogData @SiAccVoucher_Dt,'Tss_AccVoucher_Dt',@UserIP,@WindosUser,0,@SiUser

		  if @Sta_RapPayedChequeState =0 
	      Update dbo.Tss_RapPayedChequeRef Set SiAccVoucher_Dt=@SiAccVoucher_Dt Where (SiRapPayedCheque=@SiResidRap)

		  if @Sta_RapPayedChequeState =1 
	      Update dbo.Tss_RapPayedChequeRef Set SiVchDtForBardasht=@SiAccVoucher_Dt Where (SiRapPayedCheque=@SiResidRap)
		End
		Else
		Begin
			Set @Des_VdetDesc=' صدور چک شماره  '+@CodSerial+' به تاریخ سررسید '+@DatEndDate + ' '+@Des_VhedDescDet
--			Set @Des_VdetDesc= @Des_VhedDescDet
			Insert Into  dbo.Tss_AccVoucher_Dt
			(
	         SiAccCodeBook, 
	         SiPubPersonsSpec1, 
	         SiAccVoucher_Hd, 
	         Num_VDetRow, 
	         Des_VdetDesc, 
	         Dat_AccVoucherDetDate, 
	         Sta_VdetDebtOrCredit, 
	         Num_VdetDebtAmount, 
	         Num_VdetCreditAmount, 
	         Num_VdetAmount,
				SiRelatedSenderSerial,
				Des_RelatedTableSender
			)
			Values
			(
	         @SiAccBed, 
	         @SiTafBed, 
	         @SiAccVoucher_Hd, 
	         @Det_Row, 
	         @Des_VdetDesc, 
	         @DatRegister, 
	         0, 
	         @GbzAmount, 
	         0, 
	         @GbzAmount,
				@SiResidRap,
				'Tss_RapPayedCheque'
			)

	      Set @SiAccVoucher_Dt=Scope_Identity()
			Exec dbo.Tss_StdInsertLogData @SiAccVoucher_Dt,'Tss_AccVoucher_Dt',@UserIP,@WindosUser,0,@SiUser

		  if @Sta_RapPayedChequeState =0 
	      Update dbo.Tss_RapPayedChequeRef Set SiAccVoucher_Dt=@SiAccVoucher_Dt Where (SiRapPayedCheque=@SiResidRap)

		  if @Sta_RapPayedChequeState =1 
	      Update dbo.Tss_RapPayedChequeRef Set SiVchDtForBardasht=@SiAccVoucher_Dt Where (SiRapPayedCheque=@SiResidRap)

	      Set @Det_Row=@Det_Row+1

			Delete From @TempVchTbl2 Where (SiTbl2=@SiTbl2)
			--Set @Des_VdetDesc=' پرداخت چک شماره '+@CodSerial+' به '+@PerNameBes+ ' بابت '+@Des_VhedDescDet

			Update dbo.Tss_AccVoucher_Dt 
			Set Num_VdetCreditAmount=Num_VdetCreditAmount+@GbzAmount , Num_VdetAmount=Num_VdetAmount+@GbzAmount
			Where SiAccVoucher_Dt=@SiVchDtBes
		End
		Delete From @TempVchTbl Where (SiTbl=@SiTbl)
	End
	Delete @TempVchTbl
	Delete @TempVchTbl2
End	
	
	
if @Sta_TafType1=2
Begin
	While Exists(Select Top 1 SiTbl From @TempVchTbl)
	Begin
		Set @AllAmount=0
		Select Top 1
			@SiTbl=SiTbl,
			@SiResidRap=SiResidRap,
			@SiPersBed=SiPersBed,
			@SiPersBes=SiPersBes,
			@DatRegister=DatRegister,
			@CodSerial=CodSerial,
			@DatEndDate=DatEndDate
		From @TempVchTbl
		Set @SiPersBed=@SiTafBed
		Set @SiAccVoucher_Hd=0
		Set @Dat_VhedDate=@DatRegister
		SELECT @SiAccVoucher_Hd=SiAccVoucher_Hd FROM dbo.Tss_AccVoucher_Hd
		Where
			(SiAccVoucherType=@SiAccVoucherType) And
			(Dat_VhedDate=@DatRegister) And
			(SiAccFinancePeriodToPlace=@SiAccFinancePeriodToPlace)
		Set @SiAccVoucher_Hd=IsNull(@SiAccVoucher_Hd,0)
		If @SiAccVoucher_Hd=0
		Begin
			Exec dbo.Tss_AccVouchHedRegStp
			   @SiAccFinancePeriodToPlace,
				@SiAccVoucherType,
			   @Dat_VhedDate,
			   @Des_VhedDesc,
				@SiAccVoucher_Hd  OutPut
			If not IsNull(@SiAccVoucher_Hd,0)=0
				Exec dbo.Tss_StdInsertLogData @SiAccVoucher_Hd,'Tss_AccVoucher_Hd',@UserIP,@WindosUser,0,@SiUser
			If IsNull(@SiAccVoucher_Hd,0)=0
			Begin
				Set @Err_Code=2
				Return
			End
		End
	   Select @Det_Row=Max(IsNull(Num_VDetRow,0))+1 FROM Tss_AccVoucher_Dt WHERE (SiAccVoucher_Hd = @SiAccVoucher_Hd) 
		if isnull(@Det_Row,0)=0
			Set @Det_Row=1
		Insert Into  @TempVchTbl2
		(
			SiAccBed,
			SiAccBes,
			BabatDesc,
			SiChqRef,
			GbzAmount,
			SiRef,
			RefState
		)
		SELECT     
			Behalf.SiAccCodeBookBehalfBed, 
			Behalf.SiAccCodeBookBehalfBes, 
			Behalf.Des_RapBehalfDesc, 
			ChqPayRef.SiRapPayedChequeRef, 
			ChqPayRef.Num_RapPayedChequeRefAmount, 
			ChqPayRef.SiRapPayedChequeRef_Refrence,
			RefDef.Sta_RapRefrenceDefType
		FROM         
			Tss_RapBehalfDefine Behalf INNER JOIN Tss_RapPayedChequeRef ChqPayRef ON 
			Behalf.SiRapBehalfDefine = ChqPayRef.SiRapBehalfDefine LEFT OUTER JOIN Tss_RapRefrenceDefine RefDef ON 
			Behalf.SiRapRefrenceDefine = RefDef.SiRapRefrenceDefine
		WHERE
			(ChqPayRef.SiRapPayedCheque=@SiResidRap)
	
		SELECT @GbzAmount=Num_RapPayedChequeRefAmount FROM Tss_RapPayedChequeRef WHERE (SiRapPayedChequeRef = @SiResidDet)	

		if @SiAccCodeBookBed>0 
			Set @SiAccBed=@SiAccCodeBookBed
		if @SiAccCodeBookBes>0 
			Set @SiAccBes=@SiAccCodeBookBes

		SELECT @PerNameBed=Des_CostCenterName
		FROM Tss_PubCostCenter
		WHERE (SiPubCostCenter = @SiTafBed)

		SELECT     @PerNameBes=Des_FullName
		FROM         Tss_PubPersonsViw
		WHERE     (SiPubPersonsSpec = @SiPersBes)

		Set @SiPersBes=@SiTafBes

		if Exists (SELECT SiAccVoucher_Dt FROM Tss_RapPayedChequeRef WHERE (SiRapPayedCheque = @SiResid) And (SiAccVoucher_Dt is not null) )
			Select @SiVchDtBes=SiAccVoucher_Dt From dbo.Tss_AccVoucher_Dt where SiAccVoucher_Dt in 
			(SELECT SiAccVoucher_Dt FROM Tss_RapPayedChequeRef WHERE (SiRapPayedCheque = @SiResid)) and 
			(Num_VdetCreditAmount>0) and (Num_VdetAmount>0)
	
		if Not Exists (SELECT SiAccVoucher_Dt FROM Tss_RapPayedChequeRef WHERE (SiRapPayedCheque = @SiResid) And (SiAccVoucher_Dt is not null) )
		Begin
			--' صدور چک شماره  '+@CodSerial+' جهت مرکز هزينه '+@PerNameBed+' ' +
			Set @Des_VdetDesc=' صدور چک شماره  '+@CodSerial+' به تاریخ سررسید '+@DatEndDate + ' '+@Des_VhedDescDet
--			Set @Des_VdetDesc=@Des_VhedDescDet
			Insert Into  dbo.Tss_AccVoucher_Dt
			(
	         SiAccCodeBook, 
	         SiPubCostCenter1, 
	         SiAccVoucher_Hd, 
	         Num_VDetRow, 
	         Des_VdetDesc, 
	         Dat_AccVoucherDetDate, 
	         Sta_VdetDebtOrCredit, 
	         Num_VdetDebtAmount, 
	         Num_VdetCreditAmount, 
	         Num_VdetAmount,
				SiRelatedSenderSerial,
				Des_RelatedTableSender
			)
			Values
			(
	         @SiAccBed, 
	         @SiTafBed, 
	         @SiAccVoucher_Hd, 
	         @Det_Row, 
	         @Des_VdetDesc, 
	         @DatRegister, 
	         0, 
	         @GbzAmount, 
	         0, 
	         @GbzAmount,
				@SiResidRap,
				'Tss_RapPayedCheque'
			)
	      Set @SiAccVoucher_Dt=Scope_Identity()
			Exec dbo.Tss_StdInsertLogData @SiAccVoucher_Dt,'Tss_AccVoucher_Dt',@UserIP,@WindosUser,0,@SiUser

		  if @Sta_RapPayedChequeState =0 
	      Update dbo.Tss_RapPayedChequeRef Set SiAccVoucher_Dt=@SiAccVoucher_Dt Where (SiRapPayedCheque=@SiResidRap)

		  if @Sta_RapPayedChequeState =1 
	      Update dbo.Tss_RapPayedChequeRef Set SiVchDtForBardasht=@SiAccVoucher_Dt Where (SiRapPayedCheque=@SiResidRap)

	      Set @Det_Row=@Det_Row+1

			Delete From @TempVchTbl2 Where (SiTbl2=@SiTbl2)
		--End
		if @PerNameBes = 'عمومي'
			Set @Des_VdetDesc=' صدور چک شماره  '+@CodSerial+' به تاریخ سررسید '+@DatEndDate + ' '+@Des_VhedDescDet
		else
			Set @Des_VdetDesc=' صدور چک شماره  '+@CodSerial++' در وجه '+@PerNameBes+' به تاریخ سررسید '+@DatEndDate + ' '+@Des_VhedDescDet

			Insert Into  dbo.Tss_AccVoucher_Dt
			(
		      SiAccCodeBook, 
		      SiPubPersonsSpec1, 
		      SiAccVoucher_Hd, 
		      Num_VDetRow, 
		      Des_VdetDesc, 
		      Dat_AccVoucherDetDate, 
		      Sta_VdetDebtOrCredit, 
		      Num_VdetDebtAmount, 
		      Num_VdetCreditAmount, 
		      Num_VdetAmount,
				SiRelatedSenderSerial,
				Des_RelatedTableSender
			)
			Values
			(
		      @SiAccBes, 
		      @SiTafBes, 
		      @SiAccVoucher_Hd, 
		      @Det_Row, 
		      @Des_VdetDesc, 
		      @DatRegister, 
		      1, 
		      0, 
		      @GbzAmount, 
		      @GbzAmount,
				@SiResidRap,
				'Tss_RapPayedCheque'
			)

	      Set @SiAccVoucher_Dt=Scope_Identity()
			Exec dbo.Tss_StdInsertLogData @SiAccVoucher_Dt,'Tss_AccVoucher_Dt',@UserIP,@WindosUser,0,@SiUser

		  if @Sta_RapPayedChequeState =0 
	      Update dbo.Tss_RapPayedChequeRef Set SiAccVoucher_Dt=@SiAccVoucher_Dt Where (SiRapPayedCheque=@SiResidRap)

		  if @Sta_RapPayedChequeState =1 
	      Update dbo.Tss_RapPayedChequeRef Set SiVchDtForBardasht=@SiAccVoucher_Dt Where (SiRapPayedCheque=@SiResidRap)
	End
	Else
	Begin
		Set @Des_VdetDesc=' صدور چک شماره  '+@CodSerial+' به تاریخ سررسید '+@DatEndDate + ' '+@Des_VhedDescDet
		Insert Into  dbo.Tss_AccVoucher_Dt
		(
         SiAccCodeBook, 
         SiPubCostCenter1, 
         SiAccVoucher_Hd, 
         Num_VDetRow, 
         Des_VdetDesc, 
         Dat_AccVoucherDetDate, 
         Sta_VdetDebtOrCredit, 
         Num_VdetDebtAmount, 
         Num_VdetCreditAmount, 
         Num_VdetAmount,
			SiRelatedSenderSerial,
			Des_RelatedTableSender
		)
		Values
		(
         @SiAccBed, 
         @SiTafBed, 
         @SiAccVoucher_Hd, 
         @Det_Row, 
         @Des_VdetDesc, 
         @DatRegister, 
         0, 
         @GbzAmount, 
         0, 
         @GbzAmount,
			@SiResidRap,
			'Tss_RapPayedCheque'
		)

      Set @SiAccVoucher_Dt=Scope_Identity()
		Exec dbo.Tss_StdInsertLogData @SiAccVoucher_Dt,'Tss_AccVoucher_Dt',@UserIP,@WindosUser,0,@SiUser

		  if @Sta_RapPayedChequeState =0 
	      Update dbo.Tss_RapPayedChequeRef Set SiAccVoucher_Dt=@SiAccVoucher_Dt Where (SiRapPayedCheque=@SiResidRap)

		  if @Sta_RapPayedChequeState =1 
	      Update dbo.Tss_RapPayedChequeRef Set SiVchDtForBardasht=@SiAccVoucher_Dt Where (SiRapPayedCheque=@SiResidRap)

      Set @Det_Row=@Det_Row+1

		Delete From @TempVchTbl2 Where (SiTbl2=@SiTbl2)
		--Set @Des_VdetDesc=' پرداخت چک شماره  '+@CodSerial+' به '+@PerNameBes+ ' بابت '+@Des_VhedDescDet

		Update dbo.Tss_AccVoucher_Dt 
			Set Num_VdetCreditAmount=Num_VdetCreditAmount+@GbzAmount , Num_VdetAmount=Num_VdetAmount+@GbzAmount
			Where SiAccVoucher_Dt=@SiVchDtBes
	End
		Delete From @TempVchTbl Where (SiTbl=@SiTbl)
	End
	Delete @TempVchTbl
	Delete @TempVchTbl2
End

GO

alter proc Tss_RapFrmRecievedChequeRepRStpAll
(
    @SiPubSubLocations numeric=0,
    @SiRapCashDefine numeric=0,
    @SiPubPersonsSpec numeric=0,
    @GhabzNo varchar(50)='',
    @RegDate varchar(10)='1404/01/01',
    @RegDate2 varchar(10)='1404/12/29',
    @UsanceDate varchar(10)='',
    @UsanceDate2 varchar(10)='',
    @Dat_RapReceivedChequeVosoolDate varchar(10)='',
    @Dat_RapReceivedChequeVosoolDate2 varchar(10)='',
    @Dat_RapReceivedChequeBargashtDate varchar(10)='',
    @Dat_RapReceivedChequeBargashtDate2 varchar(10)='',
    @Dat_RapReceivedChequeToPerDate varchar(10)='',
    @Dat_RapReceivedChequeToPerDate2 varchar(10)='',
    @Dat_RapReceivedChequeToBankDate varchar(10)='',
    @Dat_RapReceivedChequeToBankDate2 varchar(10)='',
    @Dat_RapReceivedChequeHoghughiDate varchar(10)='',
    @Dat_RapReceivedChequeHoghughiDate2 varchar(10)='',
    @Dat_RapReceivedChequeCancelDate varchar(10)='',
    @Dat_RapReceivedChequeCancelDate2 varchar(10)='',
    @Dat_EsterdadToPer varchar(10)='',
    @Dat_EsterdadToPer2 varchar(10)='',
    @Dat_EsterdadToCashier varchar(10)='',
    @Dat_EsterdadToCashier2 varchar(10)='',
    @Dat_RapReceivedChequeToAgainDate varchar(10)='',
    @Dat_RapReceivedChequeToAgainDate2 varchar(10)='',
    @Sta_ChekRecieptMainOrNot SmallInt=0,
    @Sta_RapReceivedChequeState varchar(500)='1',
    @SiCheks varchar(8000)='',
    @StaDateFilter SmallInt=0,
    @SiUser numeric=1,
    @SiToPer varchar(1000)='',
    @SiRelatedPer varchar(1000)='',
    @SayadiRegistered char(1)='0',
    @NotSayadiRegistered char(1)='0',
    @IsElectronic char(1)='0',
	@StaSumPers smallint=0
)
as

declare    
    @SayadiSql varchar(1000)

    if @SayadiRegistered='1' and @NotSayadiRegistered = '0'
        Set @SayadiSql = 'AND (isnull(cheks1.Des_ReceivedChequeSayadiNationalCode,''0'')>''0'')'

    if @SayadiRegistered='0' and @NotSayadiRegistered = '1'
        Set @SayadiSql = 'AND (isnull(cheks1.Des_ReceivedChequeSayadiNationalCode,''0'')=''0'')'

    if @SayadiRegistered='1' and @NotSayadiRegistered = '1'
        Set @SayadiSql = ''

    if @SayadiRegistered='0' and @NotSayadiRegistered = '0'
        Set @SayadiSql = ''

    if @IsElectronic='1' 
        Set @SayadiSql = 'AND (isnull(cheks1.Sta_IsChecqueElectronic,''0'')=''1'')'

if @GhabzNo=''
Begin
	Declare
		@SqlText varchar(8000),
		@Whr varchar(8000)
	
	-- Check if aggregation is needed
	IF @StaSumPers = 1
	BEGIN
		Set @SqlText =
		'SELECT 
			CAST(NULL AS varchar(50)) AS GhabzNo,
			CAST(NULL AS varchar(200)) AS BankName,
			cheks1.GiverCode,
			cheks1.GiverName,
			CAST(NULL AS varchar(1)) AS RecieverCode,
			CAST(NULL AS varchar(1)) AS RecieverName,
			CAST(NULL AS varchar(10)) AS RegDate,
			CAST(NULL AS varchar(10)) AS UsanceDate,
			SUM(cheks1.ChequeAmount) AS ChequeAmount,
			CAST(NULL AS varchar(50)) AS BankBranchCode,
			CAST(NULL AS varchar(50)) AS ChequeSerial,
			CAST(NULL AS varchar(500)) AS Tozihat,
			CAST(NULL AS varchar(1500)) AS RecieptTozih,
			CAST(NULL AS smallint) AS Sta_ChekRecieptMainOrNot,
			CAST(NULL AS numeric(18,0)) AS SiRapReceivedCheque,
			CAST(NULL AS varchar(50)) AS ContractNo,
			CAST(NULL AS numeric(18,0)) AS SiPubPersonsSpec,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeCngDate,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeVosoolDate,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeBargashtDate,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeCancelDate,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeToPerDate,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeToBankDate,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeHoghughiDate,
			CAST(NULL AS numeric(18,0)) AS SiPubSubLocations,
			CAST(NULL AS smallint) AS Sta_RapReceivedChequeState,
			CAST(NULL AS numeric(18,0)) AS SiRapCashDefine,
			CAST(NULL AS numeric(18,0)) AS SiPubCustomCodes,
			CAST(NULL AS varchar(50)) AS Cod_PubPersonCode,
			CAST(NULL AS varchar(401)) AS Des_FullName,
			CAST(NULL AS varchar(50)) AS GirandehCode,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeToAgainDate,
			CAST(NULL AS varchar(50)) AS Dat_EsterdadToPer,
			CAST(NULL AS varchar(50)) AS Dat_EsterdadToCashier,
			CAST(NULL AS varchar(401)) AS GirandehDesc,
			CAST(NULL AS varchar(50)) AS Des_ReceivedChequeSayadiCode,
			CAST(NULL AS varchar(50)) AS Des_ReceivedChequeSayadiNationalCode,
			CAST(NULL AS smallint) AS Sta_IsChecqueElectronic
		FROM         
			Tss_RapRecCheckGhabzRep1Vw cheks1 LEFT OUTER JOIN
			Tss_RapRecCheckGhabzRep2Vw cheks2 ON cheks1.SiRapReceivedCheque = cheks2.SiRapReceivedCheque
		'
	END
	ELSE
	BEGIN
		Set @SqlText =
		'select * from (SELECT   distinct  
			cheks1.GhabzNo, 
			cheks1.BankName, 
			cheks1.GiverCode, 
			cheks1.GiverName, 
			'''' RecieverCode, 
			'''' RecieverName, 
			cheks1.RegDate, 
			cheks1.UsanceDate, 
			cheks1.ChequeAmount, 
			cheks1.BankBranchCode, 
			cheks1.ChequeSerial, 
			cheks1.Tozihat, 
			cheks1.RecieptTozih, 
			cheks1.Sta_ChekRecieptMainOrNot, 
			cheks1.SiRapReceivedCheque, 
			cheks2.Cod_SaleAgreement AS ContractNo, 
			cheks1.SiPubPersonsSpec, 
			cheks1.Dat_RapReceivedChequeCngDate, 
			cheks1.Dat_RapReceivedChequeVosoolDate, 
			cheks1.Dat_RapReceivedChequeBargashtDate, 
			cheks1.Dat_RapReceivedChequeCancelDate, 
			cheks1.Dat_RapReceivedChequeToPerDate, 
			cheks1.Dat_RapReceivedChequeToBankDate, 
			cheks1.Dat_RapReceivedChequeHoghughiDate,
			cheks1.SiPubSubLocations, 
			cheks1.Sta_RapReceivedChequeState, 
			cheks1.SiRapCashDefine, 
			cheks1.SiPubCustomCodes, 
			cheks1.Cod_PubPersonCode, 
			cheks1.Des_FullName, 
			cheks1.GirandehCode, 
			cheks1.Dat_RapReceivedChequeToAgainDate, 
			cheks1.Dat_EsterdadToPer, 
			cheks1.Dat_EsterdadToCashier, 
			cheks1.GirandehDesc,
			cheks1.Des_ReceivedChequeSayadiCode,
			cheks1.Des_ReceivedChequeSayadiNationalCode,
			cheks1.Sta_IsChecqueElectronic
		FROM         
			Tss_RapRecCheckGhabzRep1Vw cheks1 LEFT OUTER JOIN
			Tss_RapRecCheckGhabzRep2Vw cheks2 ON cheks1.SiRapReceivedCheque = cheks2.SiRapReceivedCheque
		'
	END

	Set @Whr = ''

	if isnull(@SiPubSubLocations,0)<>0	
	Begin
		Set @Whr = ' WHERE     
				     (cheks1.SiPubSubLocations = '+convert(varchar,@SiPubSubLocations)+') '
		if isnull(@SiPubPersonsSpec,0)<>0 
		Set @Whr = @Whr + ' AND  (cheks1.SiPubPersonsSpec = '+convert(varchar,@SiPubPersonsSpec)+') '
	End	 
	Else
	Begin
		if isnull(@SiPubPersonsSpec,0)<>0 
			Set @Whr = @Whr + ' Where  (cheks1.SiPubPersonsSpec = '+convert(varchar,@SiPubPersonsSpec)+') '
		Else
			Set @Whr = @Whr + ' Where '
	End

	if @SiToPer<>''
	Begin
	if isnull(@Whr,'') <> ' Where '
		Set @Whr = @Whr + ' AND (cheks1.SiRapReceivedCheque in (SELECT SiRapReceivedCheque FROM Tss_RapRecChequeToBank WHERE (SiPubPersonsSpec IN (SELECT Sisel FROM dbo.Tss_StdStringSiFindUdf('+''''+@SiToPer+''''+')))))'
	Else
		Set @Whr = @Whr + ' (cheks1.SiRapReceivedCheque in (SELECT SiRapReceivedCheque FROM Tss_RapRecChequeToBank WHERE (SiPubPersonsSpec IN (SELECT Sisel FROM dbo.Tss_StdStringSiFindUdf('+''''+@SiToPer+''''+')))))'
	End

	if @SiRelatedPer<>''
	Begin
	if isnull(@Whr,'') <> ' Where '
		Set @Whr = @Whr + ' AND (cheks1.SiPerRelatedSaler in  (SELECT Sisel FROM dbo.Tss_StdStringSiFindUdf('+''''+@SiRelatedPer+''''+')))'
	Else
		Set @Whr = @Whr + ' (cheks1.SiPerRelatedSaler in  (SELECT Sisel FROM dbo.Tss_StdStringSiFindUdf('+''''+@SiRelatedPer+''''+')))'
	End

	if (@Sta_RapReceivedChequeState<>'') and (@Sta_RapReceivedChequeState<>'1')
	Begin
	if isnull(@Whr,'') <> ' Where '
		Set @Whr = @Whr + ' AND (cheks1.Sta_RapReceivedChequeState in (Select Sisel from dbo.Tss_StdStringSiFindUdf('+''''+@Sta_RapReceivedChequeState+''''+')))'
	Else
		Set @Whr = @Whr + '  (cheks1.Sta_RapReceivedChequeState in (Select Sisel from dbo.Tss_StdStringSiFindUdf('+''''+@Sta_RapReceivedChequeState+''''+')))'
	End
	else

IF (@Sta_RapReceivedChequeState = '1')
BEGIN
    DECLARE @Condition NVARCHAR(MAX)

    SET @Condition = 
        'cheks1.RegDate BETWEEN ''' + @RegDate + ''' AND ''' + @RegDate2 + ''' ' +
        'AND (' +
            '(ISNULL(cheks1.Dat_RapReceivedChequeToPerDate, '''') <> '''' AND ' +
             'cheks1.Dat_RapReceivedChequeToPerDate NOT BETWEEN ''' + @RegDate + ''' AND ''' + @RegDate2 + ''') ' +
            'OR ' +
            '(ISNULL(cheks1.Dat_RapReceivedChequeToBankDate, '''') <> '''' AND ' +
             'cheks1.Dat_RapReceivedChequeToBankDate NOT BETWEEN ''' + @RegDate + ''' AND ''' + @RegDate2 + ''') ' +
            'OR ' +
            '(ISNULL(cheks1.Dat_RapReceivedChequeBargashtDate, '''') BETWEEN ''' + @RegDate + ''' AND ''' + @RegDate2 + ''') ' +
            'OR ' +
            '(ISNULL(cheks1.Dat_RapReceivedChequeToAgainDate, '''') BETWEEN ''' + @RegDate + ''' AND ''' + @RegDate2 + ''')' +
        ')'

    IF ISNULL(@Whr, '') <> ' Where '
        SET @Whr = @Whr + ' AND ' + @Condition
    ELSE
        SET @Whr = ' Where ' + @Condition
END

	if @SiCheks<>''
		Set @Whr = @Whr + ' AND (cheks1.SiRapReceivedCheque in (Select SiSel From dbo.Tss_StdStringSiFindUdf('+''''+@SiCheks+''''+')))'

	if @StaDateFilter=0
	Begin
	if isnull(@Whr,'') <> ' Where '
					Set @Whr = @Whr + ' AND (cheks1.RegDate BETWEEN '+''''+@RegDate+''''+' AND '+''''+@RegDate2+''''+')'
			Else
					Set @Whr = @Whr + ' (cheks1.RegDate BETWEEN '+''''+@RegDate+''''+' AND '+''''+@RegDate2+''''+')'
	End

	if @StaDateFilter=1
	Begin
	if isnull(@Whr,'') <> ' Where '
					Set @Whr = @Whr + ' AND (cheks1.UsanceDate BETWEEN '+''''+@RegDate+''''+' AND '+''''+@RegDate2+''''+')'
			Else
					Set @Whr = @Whr + ' (cheks1.UsanceDate BETWEEN '+''''+@RegDate+''''+' AND '+''''+@RegDate2+''''+')'
	End

	if @StaDateFilter=2
	Begin
	if isnull(@Whr,'') <> ' Where '
					Set @Whr = @Whr + ' AND (cheks1.Dat_RapReceivedChequeVosoolDate BETWEEN '+''''+@RegDate+''''+' AND '+''''+@RegDate2+''''+')'
			Else
					Set @Whr = @Whr + ' (cheks1.Dat_RapReceivedChequeVosoolDate BETWEEN '+''''+@RegDate+''''+' AND '+''''+@RegDate2+''''+')'
	End

	if @StaDateFilter=3
	Begin
	if isnull(@Whr,'') <> ' Where '
					Set @Whr = @Whr + ' AND (cheks1.Dat_RapReceivedChequeBargashtDate BETWEEN '+''''+@RegDate+''''+' AND '+''''+@RegDate2+''''+')'
			Else
					Set @Whr = @Whr + ' (cheks1.Dat_RapReceivedChequeBargashtDate BETWEEN '+''''+@RegDate+''''+' AND '+''''+@RegDate2+''''+')'
	End

	if @StaDateFilter=4
	Begin
	if isnull(@Whr,'') <> ' Where '
					Set @Whr = @Whr + ' AND (cheks1.Dat_RapReceivedChequeToPerDate BETWEEN '+''''+@RegDate+''''+' AND '+''''+@RegDate2+''''+')'
			Else
					Set @Whr = @Whr + ' (cheks1.Dat_RapReceivedChequeToPerDate BETWEEN '+''''+@RegDate+''''+' AND '+''''+@RegDate2+''''+')'
	End

	if @StaDateFilter=5
	Begin
	if isnull(@Whr,'') <> ' Where '
					Set @Whr = @Whr + ' AND (cheks1.Dat_RapReceivedChequeToBankDate BETWEEN '+''''+@RegDate+''''+' AND '+''''+@RegDate2+''''+')'
			Else
					Set @Whr = @Whr + ' (cheks1.Dat_RapReceivedChequeToBankDate BETWEEN '+''''+@RegDate+''''+' AND '+''''+@RegDate2+''''+')'
	End

	if @StaDateFilter=6
	Begin
	if isnull(@Whr,'') <> ' Where '
					Set @Whr = @Whr + ' AND (cheks1.Dat_RapReceivedChequeToAgainDate BETWEEN '+''''+@RegDate+''''+' AND '+''''+@RegDate2+''''+')'
			Else
					Set @Whr = @Whr + ' (cheks1.Dat_RapReceivedChequeToAgainDate BETWEEN '+''''+@RegDate+''''+' AND '+''''+@RegDate2+''''+')'
	End

	if @StaDateFilter=7
	Begin
	if isnull(@Whr,'') <> ' Where '
					Set @Whr = @Whr + ' AND (cheks1.Dat_EsterdadToPer BETWEEN '+''''+@RegDate+''''+' AND '+''''+@RegDate2+''''+')'
			Else
					Set @Whr = @Whr + ' (cheks1.Dat_EsterdadToPer BETWEEN '+''''+@RegDate+''''+' AND '+''''+@RegDate2+''''+')'
	End

	if @StaDateFilter=8
	Begin
	if isnull(@Whr,'') <> ' Where '
					Set @Whr = @Whr + ' AND (cheks1.Dat_EsterdadToCashier BETWEEN '+''''+@RegDate+''''+' AND '+''''+@RegDate2+''''+')'
			Else
					Set @Whr = @Whr + ' (cheks1.Dat_EsterdadToCashier BETWEEN '+''''+@RegDate+''''+' AND '+''''+@RegDate2+''''+')'
	End

    if @SayadiSql <> ''
        Set @Whr = @Whr + @SayadiSql

	-- Handle ORDER BY for aggregation
	IF @StaSumPers = 1
	BEGIN
		-- Add GROUP BY for GiverCode and GiverName
		Set @SqlText = @SqlText + @Whr + ' GROUP BY cheks1.GiverCode, cheks1.GiverName ORDER BY cheks1.GiverName'
	END
	ELSE
	BEGIN
		if @Sta_ChekRecieptMainOrNot = 0	
			Set @SqlText = @SqlText + @Whr + ') ccc order by UsanceDate'
		
		if @Sta_ChekRecieptMainOrNot = 1	
			Set @SqlText = @SqlText + @Whr + ') ccc order by Dat_RapReceivedChequeVosoolDate'

		if @Sta_ChekRecieptMainOrNot = 2	
			Set @SqlText = @SqlText + @Whr + ') ccc order by Dat_RapReceivedChequeBargashtDate'

		if @Sta_ChekRecieptMainOrNot = 3	
			Set @SqlText = @SqlText + @Whr + ') ccc order by Dat_RapReceivedChequeToPerDate'

		if @Sta_ChekRecieptMainOrNot = 4	
			Set @SqlText = @SqlText + @Whr + ') ccc order by Dat_RapReceivedChequeToBankDate'

		if @Sta_ChekRecieptMainOrNot = 5	
			Set @SqlText = @SqlText + @Whr + ') ccc order by Dat_RapReceivedChequeToAgainDate'

		if @Sta_ChekRecieptMainOrNot = 6	
			Set @SqlText = @SqlText + @Whr + ') ccc order by Dat_EsterdadToPer'

		if @Sta_ChekRecieptMainOrNot = 7	
			Set @SqlText = @SqlText + @Whr + ') ccc order by Dat_EsterdadToCashier'

		if @Sta_ChekRecieptMainOrNot = 8	
			Set @SqlText = @SqlText + @Whr + ') ccc order by RegDate'
	END

    if @SayadiSql <> ''
        
if @Whr<>''
	Set @Whr = @Whr + ' and  (SiPubSubLocations in  (SELECT DISTINCT 
		Tss_AccFinancePeriodToPlace.SiPubSubLocations
	FROM         
		Tss_AccUserToFinancePeriodAndPlace INNER JOIN
		Tss_AccFinancePeriodToPlace ON 
		Tss_AccUserToFinancePeriodAndPlace.SiAccFinancePeriodToPlace = Tss_AccFinancePeriodToPlace.SiAccFinancePeriodToPlace
	WHERE     
		(Tss_AccUserToFinancePeriodAndPlace.SiPubPersonsSpec = '+convert(varchar,@SiUser)+')))'
else
	Set @Whr = @Whr + ' where  (SiPubSubLocations in  (SELECT DISTINCT 
		Tss_AccFinancePeriodToPlace.SiPubSubLocations
	FROM         
		Tss_AccUserToFinancePeriodAndPlace INNER JOIN
		Tss_AccFinancePeriodToPlace ON 
		Tss_AccUserToFinancePeriodAndPlace.SiAccFinancePeriodToPlace = Tss_AccFinancePeriodToPlace.SiAccFinancePeriodToPlace
	WHERE     
		(Tss_AccUserToFinancePeriodAndPlace.SiPubPersonsSpec = @'+convert(varchar,@SiUser)+')))'
		
	print @SqlText
	
	exec(@SqlText)
End
Else
Begin
	-- Handle the ELSE block when @GhabzNo is not empty
	IF @StaSumPers = 1
	BEGIN
		SELECT 
			CAST(NULL AS varchar(50)) AS GhabzNo,
			CAST(NULL AS varchar(200)) AS BankName,
			cheks1.GiverCode,
			cheks1.GiverName,
			CAST(NULL AS varchar(1)) AS RecieverCode,
			CAST(NULL AS varchar(1)) AS RecieverName,
			CAST(NULL AS varchar(10)) AS RegDate,
			CAST(NULL AS varchar(10)) AS UsanceDate,
			SUM(cheks1.ChequeAmount) AS ChequeAmount,
			CAST(NULL AS varchar(50)) AS BankBranchCode,
			CAST(NULL AS varchar(50)) AS ChequeSerial,
			CAST(NULL AS varchar(500)) AS Tozihat,
			CAST(NULL AS varchar(1500)) AS RecieptTozih,
			CAST(NULL AS smallint) AS Sta_ChekRecieptMainOrNot,
			CAST(NULL AS numeric(18,0)) AS SiRapReceivedCheque,
			CAST(NULL AS varchar(50)) AS ContractNo,
			CAST(NULL AS numeric(18,0)) AS SiPubPersonsSpec,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeCngDate,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeVosoolDate,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeBargashtDate,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeCancelDate,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeToPerDate,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeToBankDate,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeHoghughiDate,
			CAST(NULL AS numeric(18,0)) AS SiPubSubLocations,
			CAST(NULL AS smallint) AS Sta_RapReceivedChequeState,
			CAST(NULL AS numeric(18,0)) AS SiRapCashDefine,
			CAST(NULL AS numeric(18,0)) AS SiPubCustomCodes,
			CAST(NULL AS varchar(50)) AS Cod_PubPersonCode,
			CAST(NULL AS varchar(401)) AS Des_FullName,
			CAST(NULL AS varchar(50)) AS GirandehCode,
			CAST(NULL AS varchar(10)) AS Dat_RapReceivedChequeToAgainDate,
			CAST(NULL AS varchar(50)) AS Dat_EsterdadToPer,
			CAST(NULL AS varchar(50)) AS Dat_EsterdadToCashier,
			CAST(NULL AS varchar(401)) AS GirandehDesc,
			CAST(NULL AS varchar(50)) AS Des_ReceivedChequeSayadiCode,
			CAST(NULL AS varchar(50)) AS Des_ReceivedChequeSayadiNationalCode,
			CAST(NULL AS smallint) AS Sta_IsChecqueElectronic
		FROM         
			Tss_RapRecCheckGhabzRep1Vw cheks1 LEFT OUTER JOIN
			Tss_RapRecCheckGhabzRep2Vw cheks2 ON cheks1.SiRapReceivedCheque = cheks2.SiRapReceivedCheque
		WHERE   
			(cheks1.Sta_CheckToBankState <> 4) and
			(cheks1.Sta_CheckToBankState <> 3) and 	
			(cheks1.GhabzNo = @GhabzNo) and
			(cheks1.Sta_ChekRecieptMainOrNot = @Sta_ChekRecieptMainOrNot )
		GROUP BY cheks1.GiverCode, cheks1.GiverName
		ORDER BY cheks1.GiverName
	END
	ELSE
	BEGIN
		SELECT    distinct 
			cheks1.GhabzNo, 
			cheks1.BankName, 
			'' GiverCode, 
			'' GiverName, 
			cheks1.RecieverCode, 
			cheks1.RecieverName, 
			cheks1.RegDate, 
			cheks1.UsanceDate, 
			cheks1.ChequeAmount, 
			cheks1.BankBranchCode, 
			cheks1.ChequeSerial, 
			cheks1.Tozihat, 
			cheks1.RecieptTozih, 
			cheks1.Sta_ChekRecieptMainOrNot, 
			cheks1.SiRapReceivedCheque, 
			cheks2.Cod_SaleAgreement AS ContractNo, 
			cheks1.SiPubPersonsSpec, 
			cheks1.Dat_RapReceivedChequeCngDate, 
			cheks1.Dat_RapReceivedChequeVosoolDate, 
			cheks1.Dat_RapReceivedChequeBargashtDate, 
			cheks1.Dat_RapReceivedChequeCancelDate, 
			cheks1.Dat_RapReceivedChequeToPerDate, 
			cheks1.Dat_RapReceivedChequeToBankDate, 
			cheks1.Dat_RapReceivedChequeHoghughiDate, 
			cheks1.SiPubSubLocations, 
			cheks1.Sta_RapReceivedChequeState, 
			cheks1.SiRapCashDefine, 
			cheks1.SiPubCustomCodes, 
			cheks1.Cod_PubPersonCode, 
			cheks1.Des_FullName,
			cheks1.GirandehCode, 
			cheks1.GirandehDesc,
			cheks1.Dat_EsterdadToCashier,
			cheks1.Dat_EsterdadToPer,
			cheks1.Des_ReceivedChequeSayadiCode,
			cheks1.Des_ReceivedChequeSayadiNationalCode,
			cheks1.Dat_RapReceivedChequeToAgainDate,
			cheks1.Sta_IsChecqueElectronic
		FROM         
			Tss_RapRecCheckGhabzRep1Vw cheks1 LEFT OUTER JOIN
			Tss_RapRecCheckGhabzRep2Vw cheks2 ON cheks1.SiRapReceivedCheque = cheks2.SiRapReceivedCheque
		WHERE   
			(cheks1.Sta_CheckToBankState <> 4) and
			(cheks1.Sta_CheckToBankState <> 3) and 	
			(cheks1.GhabzNo = @GhabzNo) and
			(cheks1.Sta_ChekRecieptMainOrNot = @Sta_ChekRecieptMainOrNot )
	END
End

GO
alter PROCEDURE Tss_SalUntFactor_HdVStp  
(      
   @InternalWhere VarChar(8000)='',    
   @Where VarChar(8000)='',    
   @Order VarChar(8000)='',
	@SiUser Numeric=1,
	@RowCount numeric=300
) 

AS    

Set arithabort ON
Set concat_null_yields_null ON
Set ansi_nulls ON
Set ansi_null_dflt_on ON
Set ansi_padding ON
Set ansi_warnings ON
Set quoted_identifier ON


Declare
	@Des_StdUserToBdsCondition varchar(8000)

set @InternalWhere = isnull(@InternalWhere,'')
set @Where = isnull(@Where,'')
set @Order = isnull(@Order,'')

Declare 
	@SaleMali nvarchar(4),
	@Cod_AccFinancePeriod nvarchar(50),
	@Sql varchar(8000),
	@Adate nvarchar(10)

if (dbo.Tss_StdFindSubLoc(0)='zarin') or (dbo.Tss_StdFindSubLoc(0)='delta')
	Set @Adate = dbo.Tss_MiladyToShamsiPar(DATEADD(d,-3,GetDate()))
else
begin
	Set @Adate = dbo.Tss_MiladyToShamsiPar(GetDate())
	Set @Adate = left(@Adate,4)+'/01/01'
end

if Not exists
(
SELECT        Tss_PubCustomCodes.Des_CustomCodesDesc, Tss_StdSystemUsers.SiPubPersonsSpec
FROM            Tss_StdSystemUserTogrps INNER JOIN
                         Tss_PubCustomCodes ON Tss_StdSystemUserTogrps.SiPubCustomCodes = Tss_PubCustomCodes.SiPubCustomCodes INNER JOIN
                         Tss_StdSystemUsers ON Tss_StdSystemUserTogrps.SiStdSystemUsers = Tss_StdSystemUsers.SiStdSystemUsers
WHERE        (Tss_PubCustomCodes.Des_CustomCodesDesc = 'SaleApprover') AND (Tss_StdSystemUsers.SiPubPersonsSpec = @SiUser)
)
Begin
	If @Where<>''     
	   Set @Where=' Where (SiSaler ='+convert(varchar,@SiUser)+') and '+@Where  
	Else
	Begin
		---Set @Adate = left(dbo.Tss_MiladyToShamsiPar(GetDate()),7)
	
		Select @Cod_AccFinancePeriod=Max(Convert(numeric,Cod_AccFinancePeriod)) From dbo.Tss_AccFinancePeriod
		Select @SaleMali=Left(Dat_AccFinancePriodStart,4) From dbo.Tss_AccFinancePeriod where Cod_AccFinancePeriod=@Cod_AccFinancePeriod
	
		Set @Where=' Where (SiSaler ='+convert(varchar,@SiUser)+') and (Dat_FactorDate>='+''''+@Adate+''''+')'
	
		--set @StDate=''
		--set @EnDate=''
		
		--if (@StDate='') or (isnull(@StDate,'')='')
		--	Set 	@StDate= @SaleMali+'/01/01'    
		--if (@EnDate='') or (isnull(@EnDate,'')='')
		--	Set 	@EnDate=  @SaleMali+'/12/30'
		--Set 	@StDate= '1390/01/01'    
		--Set 	@EnDate= '1390/12/30'
	End
	If @InternalWhere<>''     
	Begin
	   Set @InternalWhere=' Where '+@InternalWhere 
		Set @Where= ''   
	End
End
Else
Begin
	If @Where<>''     
	   Set @Where=' Where '+@Where  
	Else
	Begin
		--Set @Adate = left(dbo.Tss_MiladyToShamsiPar(GetDate()),7)
	
		Select @Cod_AccFinancePeriod=Max(Convert(numeric,Cod_AccFinancePeriod)) From dbo.Tss_AccFinancePeriod
		Select @SaleMali=Left(Dat_AccFinancePriodStart,4) From dbo.Tss_AccFinancePeriod where Cod_AccFinancePeriod=@Cod_AccFinancePeriod
	
		Set @Where=' Where (Dat_FactorDate>='+''''+@Adate+''''+')'
	
		--set @StDate=''
		--set @EnDate=''
		
		--if (@StDate='') or (isnull(@StDate,'')='')
		--	Set 	@StDate= @SaleMali+'/01/01'    
		--if (@EnDate='') or (isnull(@EnDate,'')='')
		--	Set 	@EnDate=  @SaleMali+'/12/30'
		--Set 	@StDate= '1390/01/01'    
		--Set 	@EnDate= '1390/12/30'
	End
	If @InternalWhere<>''     
	Begin
	   Set @InternalWhere=' Where '+@InternalWhere 
		Set @Where= ''   
	End
End

if dbo.Tss_StdFindSubLoc(0)<>'aeen' 
begin
	If @Order<>''     
	   Set @Order=' Order By '+@Order 
	Else
		SET @Order = ' ORDER BY Dat_FactorDate DESC,
               CASE WHEN ISNUMERIC(Cod_FactorCode) = 1 
                    THEN CONVERT(numeric, Cod_FactorCode) 
                    ELSE NULL END DESC';


end
else
begin
	If @Order<>''     
	   Set @Order=' Order By '+@Order --+' OFFSET '+convert(varchar,@RowCount)+' ROWS FETCH NEXT '+convert(varchar,@RowCount)+' ROWS ONLY '
	Else
		Set @Order=' ORDER BY convert(numeric,ltrim(rtrim(Cod_FactorCode))) '--++' OFFSET '+convert(varchar,@RowCount)+' ROWS FETCH NEXT '+convert(varchar,@RowCount)+' ROWS ONLY '
end

Exec(    
'Select * From    
(    
   Select *,
   ContFactDiff=
   case when FactorNo>0 then Num_GdsBalancFee-FactorFee 
   else 0 end
From    
   (    
   SELECT    
		FactHd.Sta_SentToCust,
		FactHd.Sta_TasviehType,
		FactHd.Sta_CurrencyType,
		FactHd.Num_CurrencyRate, 
		FactHd.Num_CottageTotWeight, 
		FactHd.Sta_FactorType,
		FactHd.CottageNo, 
		FactHd.CottageDate, 
		FactHd.CustomsCode, 
		FactHd.CustomLicenseNo,
		FactHd.SiSalFactor_Hd, 
		FactHd.SiSalTypeOfFactor, 
		FactHd.Num_Karmozd, 
		FactHd.Sta_HasKarmozd,
		FactHd.Sta_SecondGdsDesc,
		FactHd.Sta_FactorHdState, 
		FactHd.SiSalInvoice_Hd, 
		FactHd.Cod_FactorCode, 
		FactHd.Dat_FactorDate, 
		FactHd.Num_FactorPreRecieveAmount, 
		FactHd.Num_FactorDiscountAmount, 
		FactHd.SiAccVoucher_Dt, 
		FactHd.StmSalFactor_Hd, 
		VchDt.SiAccVoucher_Hd, 
		VchDt.Num_VDetRow, 
		IvcHd.Cod_SaleAgreement, 
		IvcHd.Des_SaleAgreementDesc, 
		IvcHd.Dat_SaleRequestRegDate, 
		IvcHd.Dat_SalReqToContractDate, 
		IvcHd.Cod_SaleAgreement2, 
		IvcHd.Sta_MainOrNot, 
		IvcHd.Sta_ForProdOrSale, 
		dbo.Tss_StdStaLabelsUdf(1081, IvcHd.Sta_MainOrNot) AS Des_MainOrNot,
		Cod_PubPersonCode= 
		Case When Isnull(FactHd.SiSalInvoice_Hd,0)<>0 then pPers.Cod_PubPersonCode else pPersNoCont.Cod_PubPersonCode End,
		Des_FullName= 
		Case When Isnull(FactHd.SiSalInvoice_Hd,0)<>0 then pPers.Des_FullName else pPersNoCont.Des_FullName End,
		dbo.Tss_SalFactorPriceUdf(3, FactHd.SiSalFactor_Hd, NULL) AS TotalRow, 
		dbo.Tss_SalFactorPriceUdf(1, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS SrvPrc, 
		dbo.Tss_SalFactorPriceUdf(2, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS AllPrc, 
		dbo.Tss_SalFactorPriceUdf(18, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS ArzeshAf4SrvPrc, 
/*		dbo.Tss_SalFactorPriceUdf(10, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS KeliSaleSrvPrc, 
		dbo.Tss_SalFactorPriceUdf(11, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS HamlSrvPrc, 
		dbo.Tss_SalFactorPriceUdf(12, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS GhalebProdSrvPrc, 
		dbo.Tss_SalFactorPriceUdf(13, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS ZincFilmSrvPrc, 
		dbo.Tss_SalFactorPriceUdf(14, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS ZincChapKeliSrvPrc, 
		dbo.Tss_SalFactorPriceUdf(15, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS KeliSakhtSrvPrc, 
		dbo.Tss_SalFactorPriceUdf(16, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS Shahrdari2SrvPrc, 
		dbo.Tss_SalFactorPriceUdf(17, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS ArzeshAf2SrvPrc, 
		dbo.Tss_SalFactorPriceUdf(19, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS HamloBarbariSrvPrc, 
		dbo.Tss_SalFactorPriceUdf(20, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS TarahiSrvPrc, 
		dbo.Tss_SalFactorPriceUdf(21, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS AlalTarrahiPrc, 
		dbo.Tss_SalFactorPriceUdf(22, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS AlalSakhteGhalebPrc, 
		dbo.Tss_SalFactorPriceUdf(23, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS HaftDarsadeAlalKeliPrc, 
		dbo.Tss_SalFactorPriceUdf(24, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS MakharejeTaghribiTarhshakhtKeliPrc, 
		dbo.Tss_SalFactorPriceUdf(25, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS KasreMAliatPrc, 
		dbo.Tss_SalFactorPriceUdf(26, FactHd.SiSalFactor_Hd, FactHd.SiSalInvoice_Hd) AS HazinehTarahiSrvPrc, */
		FactHd.Des_FactorDesc, 
		IvcHd.Cod_SaleAgreementChange, 
		FactHd.SiPubPersonsSpec, 
		pPersNoCont.Cod_PubPersonCode AS CodPerson, 
		pPersNoCont.Des_FullName AS DesPerson, 
		pPers.Cod_PersEconomicCode, 
		pPers.Des_PersonAddress, 
		Tss_PubSubLocations.Cod_SubLocCode, 
      Tss_PubSubLocations.Des_SubLocName,
		Tss_PubSubLocations.SiPubSubLocations,
		Tss_PubSubLocations.Sta_IsLegalCompany,
		FactHd.Sta_InvoiceCodePrint, 
		FactHd.Sta_JensPrint, 
		pPers.Des_CoAndOrgNationalCode,
		Tss_PubSubLocations.Cod_OrgRegisterNo,
		FactHd.Sta_TaxCalc, 
		Registerer.Cod_PubPersonCode AS CodRegisterer, 
		Registerer.Des_FullName AS DesRegisterer, 
		Editor.Cod_PubPersonCode AS CodEditor, 
		Editor.Des_FullName AS DesEditor, 
		FactHd.Tss_SalFactor_HdRegTime, 
      FactHd.Tss_SalFactor_HdEditTime, 
		--pPers.SiPerRelatedSaler as SiSaler,
		dbo.Tss_PubFindRelatedSalerSi(FactHd.SiPubPersonsSpec)  as SiSaler,
		FactHd.Num_AddedValue, 
		Tss_PubPersonsViw.Cod_PubPersonCode CodRelatedPer, 
        Tss_PubPersonsViw.Des_FullName DesRelatedPer,
		isnull((SELECT top 1 isnull(Num_FeeAdjust,0) FROM Tss_SalInvoice_Dt WHERE (SiSalInvoice_Hd = FactHd.SiSalInvoice_Hd)),0) FeeAdjust, 
		isnull((SELECT top 1 isnull(Num_GdsBalancFee,0) FROM Tss_SalInvoice_Dt WHERE (SiSalInvoice_Hd = FactHd.SiSalInvoice_Hd)),0) Num_GdsBalancFee, 
		isnull((SELECT top 1 Num_FactDetGoodsNo FROM Tss_SalFactor_Dt WHERE (SiSalFactor_Hd = FactHd.SiSalFactor_Hd)),0) FactorNo,
		isnull((SELECT top 1 Num_FactDetGoodsFee FROM Tss_SalFactor_Dt WHERE (SiSalFactor_Hd = FactHd.SiSalFactor_Hd)),0) FactorFee,
		Tss_SalTypeOfSales.Cod_SalTypeCode, Tss_SalTypeOfSales.Des_SalTypeDesc,
		FactHd.irtaxid,
		FactHd.Taxid,
		FactHd.Sta_TaxFalg,
		FactHd.referenceNumber,
		FactHd.uid, 
		FactorRef.Cod_FactorCode AS FactorCodeRef, 
		FactorRef.Dat_FactorDate AS FactorDateRef, FactHd.SiSalFactor_HdRef,
		dbo.HexToDec(SUBSTRING(FactHd.taxid, 12, 10)) AS Taxdecimal_value
FROM            Tss_PubSubLocations RIGHT OUTER JOIN
                         Tss_SalFactor_Hd AS FactorRef RIGHT OUTER JOIN
                         Tss_SalFactor_Hd AS FactHd ON FactorRef.SiSalFactor_Hd = FactHd.SiSalFactor_HdRef LEFT OUTER JOIN
                         Tss_SalTypeOfSales ON FactHd.SiSalTypeOfFactor = Tss_SalTypeOfSales.SiSalTypeOfSales LEFT OUTER JOIN
                         Tss_PubPersonsViw AS Editor ON FactHd.Tss_SalFactor_HdEditor = Editor.SiPubPersonsSpec LEFT OUTER JOIN
                         Tss_PubPersonsViw AS Registerer ON FactHd.Tss_SalFactor_HdRegisterer = Registerer.SiPubPersonsSpec ON Tss_PubSubLocations.SiPubSubLocations = FactHd.SiPubSubLocations LEFT OUTER JOIN
                         Tss_PubPersonsViw AS pPersNoCont ON FactHd.SiPubPersonsSpec = pPersNoCont.SiPubPersonsSpec LEFT OUTER JOIN
                         Tss_PubPersonsViw RIGHT OUTER JOIN
                         Tss_PubPersonsViw AS pPers INNER JOIN
                         Tss_SalInvoice_Hd AS IvcHd ON pPers.SiPubPersonsSpec = IvcHd.SiPubPersonsSpec ON Tss_PubPersonsViw.SiPubPersonsSpec = pPers.SiPerRelatedSaler ON 
                         FactHd.SiSalInvoice_Hd = IvcHd.SiSalInvoice_Hd LEFT OUTER JOIN
            Tss_AccVoucher_Dt AS VchDt ON FactHd.SiAccVoucher_Dt = VchDt.SiAccVoucher_Dt
   ) Ccc  '+@InternalWhere+'    
) CalcSel ' + @Where + @Order)

GO

alter PROCEDURE Tss_InvUntGdsMoroorRoleSerialsVStp
(  
   @InternalWhere VarChar(8000)='',  
   @Where VarChar(8000)='',  
   @Order VarChar(8000)='',
   @SiInvInventory Numeric=12,
	@Date varchar(10)='1401/09/23',
	@NumCoef2Weight numeric=0,
   @SiPubGoods VarChar(8000)='',
	@SiUser numeric=532
) AS 

  
If @InternalWhere<>''   
   Set @InternalWhere=' Where '+@InternalWhere  


If @Where<>''   
   Set @Where=' Where '+@Where  
else
   Set @Where=''


If @Order<>''   
   Set @Order=' Order By '+@Order 
else   
   Set @Order=' '+@Order 


Declare
	@SqlTxt VarChar(8000),
	@SqlTxt2 VarChar(8000),
	@SubLocId varchar(500),
	@SaleMaliStartDate varchar(10),
	@Sta_PubPersonsGroup smallint,
	@IsInvAdmin smallint

Select @IsInvAdmin = dbo.Tss_StdFindIfUserIsInGroup(@SiUser,'InvAdmin')

create table #Temp 
(
Num_Serial decimal(21,0),
moj1In numeric, 
moj1Out numeric, 
mojIn numeric, 
mojOut numeric, 
SiPubGoods numeric,
Cod_PubGoodsCode varchar(50), 
Des_PubGoodsDesc nvarchar(2000), 
StaInOut int, 
SiInvInventory numeric,
SiCust numeric
)

SELECT     
	@Sta_PubPersonsGroup = Sta_PubPersonsGroup
FROM         
	Tss_PubPersonsSpec
WHERE     
	(SiPubPersonsSpec = @SiUser)

Set @SubLocId = dbo.Tss_StdFindSubLoc(0)

Set @SaleMaliStartDate = Left(@Date,4)+'/01/01'



if (@Sta_PubPersonsGroup = 8) and (@IsInvAdmin = 0)
Begin
	if @SiPubGoods<>''
	begin
		Set @SqlTxt=
		'insert into #Temp 
		SELECT     
			xx.Num_Serial,
			Sum(xx.Num_InvEntDetailGdsAmount) as moj1In,
			0 moj1Out,
			Sum(xx.Num_InvEntDetailGdsAmount2) as mojIn, 
			0 as mojOut, 
			xx.SiPubGoods,
			(SELECT top 1 Cod_PubGoodsCode FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) as Cod_PubGoodsCode,
			(SELECT top 1 Des_PubGoodsDesc FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) as Des_PubGoodsDesc,
			0,
			Tss_InvEntrance_Hd.SiInvInventory,
			0 as SiCust
		FROM        Tss_InvEntrance_Dt xx INNER JOIN
							  Tss_InvEntrance_Hd ON xx.SiInvEntrance_Hd = Tss_InvEntrance_Hd.SiInvEntrance_Hd
		WHERE    
			(xx.SiPubGoods in (Select SiSel from dbo.Tss_StdStringSiFindUdf('+''''+@SiPubGoods+''''+')))  AND 
			(Tss_InvEntrance_Hd.Dat_InvEnterDate >=  '+''''+@SaleMaliStartDate+''''+') AND
			(Tss_InvEntrance_Hd.Sta_InvEntBranch = 1) AND
		   (Tss_InvEntrance_Hd.SiInvInventory = '+convert(varchar,@SiInvInventory)+')
		GROUP BY xx.Num_Serial, xx.SiPubGoods, Tss_InvEntrance_Hd.SiInvInventory'

		Set @SqlTxt2=
		'insert into #Temp 
		SELECT     
			xx.Num_Serial, 
			0 as moj1In, 
			Sum(xx.Num_InvExtDetailGdsAmount) as moj1Out, 
			0 AS MojIn, 
			SUM(xx.Num_InvExtDetailGdsAmount2) AS MojOu, 
			xx.SiPubGoods,
            (SELECT top 1 Cod_PubGoodsCode FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) AS Cod_PubGoodsCode,
			(SELECT top 1 Des_PubGoodsDesc FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) as Des_PubGoodsDesc,
			1 StaInOut,
			Tss_InvOutGo_Hd.SiInvInventory,
			0 as SiCust
		FROM         Tss_InvOutGo_Dt xx INNER JOIN
                      Tss_InvOutGo_Hd ON xx.SiInvOutGo_Hd = Tss_InvOutGo_Hd.SiInvOutGo_Hd
		WHERE     
			(xx.SiPubGoods in (Select SiSel from dbo.Tss_StdStringSiFindUdf('+''''+@SiPubGoods+''''+')))  AND 
			(Tss_InvOutGo_Hd.Dat_InvExitDate >=  '+''''+@SaleMaliStartDate+''''+') AND
			(Tss_InvOutGo_Hd.Sta_InvOutBranch = 1) AND
		    (Tss_InvOutGo_Hd.SiInvInventory = '+convert(varchar,@SiInvInventory)+')
		GROUP BY xx.Num_Serial, xx.SiPubGoods, Tss_InvOutGo_Hd.SiInvInventory'

		exec(@sqltxt)
		exec(@sqltxt2)
		--select * from #Temp
	end

	
	if @SiPubGoods=''
	begin
		Set @SqlTxt=
		'insert into #Temp 
		SELECT     
			xx.Num_Serial,
			Sum(xx.Num_InvEntDetailGdsAmount) as moj1In,
			0 moj1Out,
			Sum(xx.Num_InvEntDetailGdsAmount2) as mojIn, 
			0 as mojOut, 
			xx.SiPubGoods,
			(SELECT top 1 Cod_PubGoodsCode FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) as Cod_PubGoodsCode,
			(SELECT top 1 Des_PubGoodsDesc FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) as Des_PubGoodsDesc,
			0,
			Tss_InvEntrance_Hd.SiInvInventory,
			0 as SiCust
		FROM        Tss_InvEntrance_Dt xx INNER JOIN
							  Tss_InvEntrance_Hd ON xx.SiInvEntrance_Hd = Tss_InvEntrance_Hd.SiInvEntrance_Hd
		WHERE    
			--(xx.SiPubGoods in (Select SiSel from dbo.Tss_StdStringSiFindUdf('+''''+@SiPubGoods+''''+')))  AND 
			(Tss_InvEntrance_Hd.Dat_InvEnterDate >=  '+''''+@SaleMaliStartDate+''''+') AND
			(Tss_InvEntrance_Hd.Sta_InvEntBranch = 1) AND
		   (Tss_InvEntrance_Hd.SiInvInventory = '+convert(varchar,@SiInvInventory)+')
		GROUP BY xx.Num_Serial, xx.SiPubGoods, Tss_InvEntrance_Hd.SiInvInventory'

		Set @SqlTxt2=
		'insert into #Temp 
		SELECT     
			xx.Num_Serial, 
			0 as moj1In, 
			Sum(xx.Num_InvExtDetailGdsAmount) as moj1Out, 
			0 AS MojIn, 
			SUM(xx.Num_InvExtDetailGdsAmount2) AS MojOu, 
			xx.SiPubGoods,
            (SELECT top 1 Cod_PubGoodsCode FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) AS Cod_PubGoodsCode,
			(SELECT top 1 Des_PubGoodsDesc FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) as Des_PubGoodsDesc,
			1 StaInOut,
			Tss_InvOutGo_Hd.SiInvInventory,
			0 as SiCust
		FROM         Tss_InvOutGo_Dt xx INNER JOIN
            Tss_InvOutGo_Hd ON xx.SiInvOutGo_Hd = Tss_InvOutGo_Hd.SiInvOutGo_Hd
		WHERE     
			--(xx.SiPubGoods in (Select SiSel from dbo.Tss_StdStringSiFindUdf('+''''+@SiPubGoods+''''+')))  AND 
			(Tss_InvOutGo_Hd.Dat_InvExitDate >=  '+''''+@SaleMaliStartDate+''''+') AND
			(Tss_InvOutGo_Hd.Sta_InvOutBranch = 1) AND
		    (Tss_InvOutGo_Hd.SiInvInventory = '+convert(varchar,@SiInvInventory)+')
		GROUP BY xx.Num_Serial, xx.SiPubGoods, Tss_InvOutGo_Hd.SiInvInventory'

		exec(@sqltxt)
		exec(@sqltxt2)
		--select * from #Temp
	end
End

if (@Sta_PubPersonsGroup <> 8) and (@IsInvAdmin = 0)
Begin
	if @SiPubGoods<>''
	begin
		Set @SqlTxt=
		'insert into #Temp 
		SELECT     
			xx.Num_Serial,
			Sum(xx.Num_InvEntDetailGdsAmount) as moj1In,
			0 moj1Out,
			Sum(xx.Num_InvEntDetailGdsAmount2) as mojIn, 
			0 as mojOut, 
			xx.SiPubGoods,
			(SELECT top 1 Cod_PubGoodsCode FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) as Cod_PubGoodsCode,
			(SELECT top 1 Des_PubGoodsDesc FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) as Des_PubGoodsDesc,
			0,
			Tss_InvEntrance_Hd.SiInvInventory,
			0 as SiCust
		FROM        Tss_InvEntrance_Dt xx INNER JOIN
							  Tss_InvEntrance_Hd ON xx.SiInvEntrance_Hd = Tss_InvEntrance_Hd.SiInvEntrance_Hd
		WHERE    
			(xx.SiPubGoods in (Select SiSel from dbo.Tss_StdStringSiFindUdf('+''''+@SiPubGoods+''''+')))  AND 
			(Tss_InvEntrance_Hd.Dat_InvEnterDate >=  '+''''+@SaleMaliStartDate+''''+') AND
			(Tss_InvEntrance_Hd.Sta_InvEntBranch = 0) AND
		   (Tss_InvEntrance_Hd.SiInvInventory = 12)
		GROUP BY xx.Num_Serial, xx.SiPubGoods, Tss_InvEntrance_Hd.SiInvInventory'

		Set @SqlTxt2=
		'insert into #Temp 
		SELECT     
			xx.Num_Serial, 
			0 as moj1In, 
			Sum(xx.Num_InvExtDetailGdsAmount) as moj1Out, 
			0 AS MojIn, 
			SUM(xx.Num_InvExtDetailGdsAmount2) AS MojOu, 
			xx.SiPubGoods,
            (SELECT top 1 Cod_PubGoodsCode FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) AS Cod_PubGoodsCode,
			(SELECT top 1 Des_PubGoodsDesc FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) as Des_PubGoodsDesc,
			1 StaInOut,
			Tss_InvOutGo_Hd.SiInvInventory,
			0 as SiCust
		FROM         Tss_InvOutGo_Dt xx INNER JOIN
                      Tss_InvOutGo_Hd ON xx.SiInvOutGo_Hd = Tss_InvOutGo_Hd.SiInvOutGo_Hd
		WHERE     
			(xx.SiPubGoods in (Select SiSel from dbo.Tss_StdStringSiFindUdf('+''''+@SiPubGoods+''''+')))  AND 
			(Tss_InvOutGo_Hd.Dat_InvExitDate >=  '+''''+@SaleMaliStartDate+''''+') AND
			(Tss_InvOutGo_Hd.Sta_InvOutBranch = 0) AND
		    (Tss_InvOutGo_Hd.SiInvInventory = 12)
		GROUP BY xx.Num_Serial, xx.SiPubGoods, Tss_InvOutGo_Hd.SiInvInventory'

		exec(@sqltxt)
		exec(@sqltxt2)
		--select * from #Temp
	end
	

	if @SiPubGoods=''
	begin
		Set @SqlTxt=
		'insert into #Temp 
		SELECT     
			xx.Num_Serial,
			Sum(xx.Num_InvEntDetailGdsAmount) as moj1In,
			0 moj1Out,
			Sum(xx.Num_InvEntDetailGdsAmount2) as mojIn, 
			0 as mojOut, 
			xx.SiPubGoods,
			(SELECT top 1 Cod_PubGoodsCode FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) as Cod_PubGoodsCode,
			(SELECT top 1 Des_PubGoodsDesc FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) as Des_PubGoodsDesc,
			0,
			Tss_InvEntrance_Hd.SiInvInventory,
			0 as SiCust
		FROM        Tss_InvEntrance_Dt xx INNER JOIN
							  Tss_InvEntrance_Hd ON xx.SiInvEntrance_Hd = Tss_InvEntrance_Hd.SiInvEntrance_Hd
		WHERE    
			--(xx.SiPubGoods in (Select SiSel from dbo.Tss_StdStringSiFindUdf('+''''+@SiPubGoods+''''+')))  AND 
			(Tss_InvEntrance_Hd.Dat_InvEnterDate >=  '+''''+@SaleMaliStartDate+''''+') AND
			(Tss_InvEntrance_Hd.Sta_InvEntBranch = 0) AND
		   (Tss_InvEntrance_Hd.SiInvInventory = 12)
		GROUP BY xx.Num_Serial, xx.SiPubGoods, Tss_InvEntrance_Hd.SiInvInventory '

		Set @SqlTxt2=
		'insert into #Temp 
		SELECT     
			xx.Num_Serial, 
			0 as moj1In, 
			Sum(xx.Num_InvExtDetailGdsAmount) as moj1Out, 
			0 AS MojIn, 
			SUM(xx.Num_InvExtDetailGdsAmount2) AS MojOu, 
			xx.SiPubGoods,
            (SELECT top 1 Cod_PubGoodsCode FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) AS Cod_PubGoodsCode,
			(SELECT top 1 Des_PubGoodsDesc FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) as Des_PubGoodsDesc,
			1 StaInOut,
			Tss_InvOutGo_Hd.SiInvInventory,
			0 as SiCust
		FROM         Tss_InvOutGo_Dt xx INNER JOIN
                      Tss_InvOutGo_Hd ON xx.SiInvOutGo_Hd = Tss_InvOutGo_Hd.SiInvOutGo_Hd
		WHERE     
			--(xx.SiPubGoods in (Select SiSel from dbo.Tss_StdStringSiFindUdf('+''''+@SiPubGoods+''''+')))  AND 
			(Tss_InvOutGo_Hd.Dat_InvExitDate >=  '+''''+@SaleMaliStartDate+''''+') AND
			(Tss_InvOutGo_Hd.Sta_InvOutBranch = 0) AND
		    (Tss_InvOutGo_Hd.SiInvInventory = 12)
		GROUP BY xx.Num_Serial, xx.SiPubGoods, Tss_InvOutGo_Hd.SiInvInventory'

		exec(@sqltxt)
		exec(@sqltxt2)
		--select * from #Temp
	end

		

End

if (@IsInvAdmin = 1)
Begin
	if @SiPubGoods<>''
	Begin
		Set @SqlTxt=
		'insert into #Temp 
		SELECT     
			xx.Num_Serial,
			Sum(xx.Num_InvEntDetailGdsAmount) as moj1In,
			0 moj1Out,
			Sum(xx.Num_InvEntDetailGdsAmount2) as mojIn, 
			0 as mojOut, 
			xx.SiPubGoods,
			(SELECT top 1 Cod_PubGoodsCode FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) as Cod_PubGoodsCode,
			(SELECT top 1 Des_PubGoodsDesc FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) as Des_PubGoodsDesc,
			0,
			Tss_InvEntrance_Hd.SiInvInventory,
			0 as SiCust
		FROM        Tss_InvEntrance_Dt xx INNER JOIN
							  Tss_InvEntrance_Hd ON xx.SiInvEntrance_Hd = Tss_InvEntrance_Hd.SiInvEntrance_Hd
		WHERE    
			(xx.SiPubGoods in (Select SiSel from dbo.Tss_StdStringSiFindUdf('+''''+@SiPubGoods+''''+')))  AND 
			(Tss_InvEntrance_Hd.Dat_InvEnterDate >=  '+''''+@SaleMaliStartDate+''''+') AND
		   (Tss_InvEntrance_Hd.SiInvInventory = '+convert(varchar,@SiInvInventory)+')
		GROUP BY xx.Num_Serial, xx.SiPubGoods, Tss_InvEntrance_Hd.SiInvInventory
		having Sum(xx.Num_InvEntDetailGdsAmount)>0 

		union all
		
		SELECT     
			xx.Num_Serial, 
			0 as moj1In, 
			Sum(xx.Num_InvExtDetailGdsAmount) as moj1Out, 
			0 AS MojIn, 
			SUM(xx.Num_InvExtDetailGdsAmount2) AS MojOu, 
			xx.SiPubGoods,
            (SELECT top 1 Cod_PubGoodsCode FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) AS Cod_PubGoodsCode,
			(SELECT top 1 Des_PubGoodsDesc FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) as Des_PubGoodsDesc,
			1,
			Tss_InvOutGo_Hd.SiInvInventory,
			0 as SiCust
		FROM         Tss_InvOutGo_Dt xx INNER JOIN
                      Tss_InvOutGo_Hd ON xx.SiInvOutGo_Hd = Tss_InvOutGo_Hd.SiInvOutGo_Hd
		WHERE     
			(xx.SiPubGoods in (Select SiSel from dbo.Tss_StdStringSiFindUdf('+''''+@SiPubGoods+''''+')))  AND 
			(Tss_InvOutGo_Hd.Dat_InvExitDate >=  '+''''+@SaleMaliStartDate+''''+') AND
		    (Tss_InvOutGo_Hd.SiInvInventory = '+convert(varchar,@SiInvInventory)+')
		GROUP BY xx.Num_Serial, xx.SiPubGoods, Tss_InvOutGo_Hd.SiInvInventory
		having Sum(xx.Num_InvExtDetailGdsAmount)>0 '
		
		exec(@sqltxt)
		--select * from #Temp
	end
	
	if @SiPubGoods=''
	Begin
		Set @SqlTxt=
		'insert into #Temp 
		SELECT     
			xx.Num_Serial,
			Sum(xx.Num_InvEntDetailGdsAmount) as moj1In,
			0 moj1Out,
			Sum(xx.Num_InvEntDetailGdsAmount2) as mojIn, 
			0 as mojOut, 
			xx.SiPubGoods,
			(SELECT top 1 Cod_PubGoodsCode FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) as Cod_PubGoodsCode,
			(SELECT top 1 Des_PubGoodsDesc FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) as Des_PubGoodsDesc,
			0 StaInOut,
			Tss_InvEntrance_Hd.SiInvInventory,
			0 as SiCust
		FROM Tss_InvEntrance_Dt xx INNER JOIN
							  Tss_InvEntrance_Hd ON xx.SiInvEntrance_Hd = Tss_InvEntrance_Hd.SiInvEntrance_Hd
		WHERE    
			--(xx.SiPubGoods in (Select SiSel from dbo.Tss_StdStringSiFindUdf('+''''+@SiPubGoods+''''+')))  AND 
			(Tss_InvEntrance_Hd.Dat_InvEnterDate >=  '+''''+@SaleMaliStartDate+''''+') AND
		   (Tss_InvEntrance_Hd.SiInvInventory = '+convert(varchar,@SiInvInventory)+')
		GROUP BY xx.Num_Serial, xx.SiPubGoods, Tss_InvEntrance_Hd.SiInvInventory
		having Sum(xx.Num_InvEntDetailGdsAmount)>0 

		union all

		SELECT     
			xx.Num_Serial, 
			0 as moj1In, 
			Sum(xx.Num_InvExtDetailGdsAmount) as moj1Out, 
			0 AS MojIn, 
			SUM(xx.Num_InvExtDetailGdsAmount2) AS MojOu, 
			xx.SiPubGoods,
            (SELECT top 1 Cod_PubGoodsCode FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) AS Cod_PubGoodsCode,
			(SELECT top 1 Des_PubGoodsDesc FROM Tss_PubGoodsViw WHERE (SiPubGoods = xx.SiPubGoods)) as Des_PubGoodsDesc,
			1 StaInOut,
			Tss_InvOutGo_Hd.SiInvInventory,
			0 as SiCust
		FROM         Tss_InvOutGo_Dt xx INNER JOIN
                      Tss_InvOutGo_Hd ON xx.SiInvOutGo_Hd = Tss_InvOutGo_Hd.SiInvOutGo_Hd
		WHERE     
			(Tss_InvOutGo_Hd.Dat_InvExitDate >=  '+''''+@SaleMaliStartDate+''''+') AND
		    (Tss_InvOutGo_Hd.SiInvInventory = '+convert(varchar,@SiInvInventory)+')
		GROUP BY xx.Num_Serial, xx.SiPubGoods, Tss_InvOutGo_Hd.SiInvInventory
		having Sum(xx.Num_InvExtDetailGdsAmount)>0 '

		exec(@sqltxt)
--		exec(@sqltxt2)
		--select * from #Temp
	end
End

--select * from #Temp where Num_Serial='5721080462'

Set @SqlTxt = '
Select
	Num_Serial,
	SummojW, 
	SumMojRole,
	Cod_PubGoodsCode,
	SiPubGoods,
	Des_PubGoodsDesc,
	SiInvInventory,
	CAST(0.0 AS NUMERIC(18, 2)) sicust,
	CAST(0.0 AS NUMERIC(18, 2)) SiCustCode,
	'''' SiCustDesc,
	CAST(0.0 AS NUMERIC(18, 2)) GdsArea,
	CAST(0.0 AS NUMERIC(18, 2)) MojoodiArea,
	CAST(0.0 AS NUMERIC(18, 2)) as GdsGramage,
	CAST(0.0 AS NUMERIC(18, 2)) as Gramage,
	'''' DeliDate,
	'''' as GdsFlute,
	'''' UnitSpec1,
	'''' UnitSpec2,
	CAST(0.0 AS NUMERIC(18, 2)) OrderPoint,
	CAST(0.0 AS NUMERIC(18, 2)) OrderPoint2,
	CAST(0.0 AS NUMERIC(18, 2)) Num_FirstOfPeriodSupply,
	CAST(0.0 AS NUMERIC(18, 2)) sumVaredeh,
	CAST(0.0 AS NUMERIC(18, 2)) sumSadereh,
	CAST(0.0 AS NUMERIC(18, 2)) MojoodiBase,
	CAST(0.0 AS NUMERIC(18, 2)) MojoodiSecond,
	'''' MazContBuyReq,
	CAST(0.0 AS NUMERIC(18, 2))  SiRelatedSaler,
	'''' GdsType,
	'''' ContCod,
	'''' CustDesc,
	'''' CustCode,
	'''' Rang,
	'''' arz,
	'''' Jens,
	'''' Grouh,
	'''' CodeContBuyReq,
	'''' CustContBuyReq,
	'''' ContDesc,
	'''' RelatedSaler,
	'''' LastSanadCode,
	'''' LastSanadDate,
	'''' DiffBetweenLastAndBuy,
	CAST(0.0 AS NUMERIC(18, 2)) LastSanadAmt,
	'''' SanadType,
	'''' LastGdsBuyDate,
	CAST(0.0 AS NUMERIC(18, 2)) MojoodiTonage

From
(
Select
	*
From
(
select 
	Num_Serial,
	Sum(moj1In)-Sum(moj1Out) SummojW, 
	Sum(MojIn) -Sum(MojOut) SumMojRole,
	Cod_PubGoodsCode,
	SiPubGoods,
	Des_PubGoodsDesc,
	SiInvInventory
from 
	#Temp 
group by
	Num_Serial, 
	Cod_PubGoodsCode, 
	SiPubGoods, 
	Des_PubGoodsDesc, 
	SiInvInventory
having 
	(Sum(moj1In)-Sum(moj1Out)>0) '


print   @SqlTxt+'
   ) Ccc '+@InternalWhere+'
) CalcSel  ' + @Where + @Order

--Exec('select * from #Temp')

Exec(
   @SqlTxt+'
   ) Ccc  '+@InternalWhere+'
) CalcSel  ' + @Where + @Order)

GO

alter Procedure Tss_PurUntInvoice_DtIudStp
(
	@Err_Code Int OutPut,
	@SiPurInvoice_Dt Numeric OutPut,
	@SiPubGoods numeric=null,
	@SiPurInvoice_Hd numeric,
	@SiPubCustomCodes numeric=null,
	@Cod_PurInvoiceDtCode varchar(50)='',
	@Des_PurInvoiceDtDesc varchar(500)='',
	@Num_PurInvoiceDtGoodsAmt decimal(30,4)=0,
	@Num_PurInvoiceDtGoodsFee numeric=0,
	@Num_PurInvoiceDtServiceNo decimal(30,4)=0,
	@Num_PurInvoiceDtServiceFee numeric=0,
	@Num_PurInvoiceDtGoodsFeeNonCalc decimal(34,18)=0,
	@Num_PurInvoiceDtdiscountAmt numeric=0,
	@Num_PurInvoiceDtTotalAmt numeric=0,
	@Sta_BuyServiceOrGds smallint=null,
	@SiInvEntrance_Dt numeric=0,
	@Num_PurInvoiceDtAddedTax decimal(34,18)=0,
	@Num_VaraghFee decimal(30,4)=0,
	@SiPubCostCenter numeric=null,
	@SiPurPurchOrder_Dt numeric=null,
	@StmPurInvoice_Dt TimeStamp=0,
	@SiUser Numeric,
	@FlgInsUpdDel SmallInt
) As

Set arithabort ON
Set concat_null_yields_null ON
Set ansi_nulls ON
Set ansi_null_dflt_on ON
Set ansi_padding ON
Set ansi_warnings ON
Set quoted_identifier ON

declare
	@SiInvEntrance_Hd numeric,
	@Num_InvEntDetailGdsAmount decimal(30,4)

if isnull(@Cod_PurInvoiceDtCode,'')=''
	SELECT    
		@Cod_PurInvoiceDtCode = Convert(varchar,Isnull(Max(Convert(numeric,isnull(Cod_PurInvoiceDtCode,0))),0)+1)
	FROM         
		Tss_PurInvoice_Dt
	Where
		SiPurInvoice_Hd = @SiPurInvoice_Hd

Select 
	@SiInvEntrance_Hd = SiInvEntrance_Hd,
	@Num_InvEntDetailGdsAmount = isnull(Num_InvEntDetailGdsAmount,0) 
from 
	dbo.Tss_InvEntrance_Dt 
where 
	SiInvEntrance_Dt = @SiInvEntrance_Dt

If
@FlgInsUpdDel=0
Begin
	Insert Into dbo.Tss_PurInvoice_Dt
	(
		SiPubGoods,
		SiPurInvoice_Hd,
		SiPubCustomCodes,
		Cod_PurInvoiceDtCode,
		Des_PurInvoiceDtDesc,
		Num_PurInvoiceDtGoodsAmt,
--		Num_PurInvoiceDtGoodsFee,
--		Num_PurInvoiceDtdiscountAmt,
		Num_PurInvoiceDtTotalAmt,
		Num_PurInvoiceDtServiceNo,
--		Num_PurInvoiceDtServiceFee,
		Sta_BuyServiceOrGds,
		SiInvEntrance_Dt,		
		Num_PurInvoiceDtAddedTax,
		SiPubCostCenter,
		Num_PurInvoiceDtGoodsFeeNonCalc,
		SiPurPurchOrder_Dt
	)
	Values
	(
		@SiPubGoods,
		@SiPurInvoice_Hd,
		@SiPubCustomCodes,
		@Cod_PurInvoiceDtCode,
		@Des_PurInvoiceDtDesc,
		@Num_PurInvoiceDtGoodsAmt,
--		@Num_PurInvoiceDtGoodsFee,
--		@Num_PurInvoiceDtdiscountAmt,
		@Num_PurInvoiceDtTotalAmt,
		@Num_PurInvoiceDtServiceNo,
--		@Num_PurInvoiceDtServiceFee,
		@Sta_BuyServiceOrGds,
		@SiInvEntrance_Dt,		
		@Num_PurInvoiceDtAddedTax,
		@SiPubCostCenter,
		@Num_PurInvoiceDtGoodsFeeNonCalc,
		@SiPurPurchOrder_Dt
	)
		if @Num_PurInvoiceDtGoodsAmt=@Num_InvEntDetailGdsAmount
		UPDATE    
			Tss_InvEntrance_Dt
		SET              
			Num_InvEntDetailRialFee = @Num_PurInvoiceDtGoodsFeeNonCalc,
			Num_TaxFee = @Num_PurInvoiceDtAddedTax/@Num_PurInvoiceDtGoodsAmt,
			Num_VaredehRialiAmt = (round(((isnull(@Num_PurInvoiceDtGoodsFeeNonCalc,0) + isnull(Num_TransportCostFee,0) + isnull(@Num_PurInvoiceDtAddedTax/@Num_PurInvoiceDtGoodsAmt,0)) * @Num_InvEntDetailGdsAmount),0))
		WHERE 
			(SiInvEntrance_Dt = @SiInvEntrance_Dt)

		if @Num_PurInvoiceDtGoodsAmt>@Num_InvEntDetailGdsAmount
		UPDATE    
			Tss_InvEntrance_Dt
		SET              
			Num_InvEntDetailRialFee = @Num_PurInvoiceDtGoodsFeeNonCalc,
			Num_TaxFee = @Num_PurInvoiceDtAddedTax/@Num_PurInvoiceDtGoodsAmt, 
			Num_VaredehRialiAmt = (round(((isnull(@Num_PurInvoiceDtGoodsFeeNonCalc,0) + isnull(Num_TransportCostFee,0) + isnull(@Num_PurInvoiceDtAddedTax/@Num_PurInvoiceDtGoodsAmt,0)) * @Num_InvEntDetailGdsAmount),0))
		WHERE 
			(SiInvEntrance_Hd = @SiInvEntrance_Hd) and
			(SiPubGoods = @SiPubGoods)

	Set @SiPurInvoice_Dt=Scope_Identity()
	If IsNull(@SiPurInvoice_Dt,0)=0
	Begin
		Set @SiPurInvoice_Dt=0
		Set @Err_Code=400
	End
	Return
End

If @FlgInsUpdDel=1
Begin
	Set @Err_Code=0
	If Exists(
	Select StmPurInvoice_Dt From dbo.Tss_PurInvoice_Dt
	Where (SiPurInvoice_Dt=@SiPurInvoice_Dt) And (StmPurInvoice_Dt=@StmPurInvoice_Dt))
	Begin
		print 'amadam dakhel'
		Update dbo.Tss_PurInvoice_Dt Set
			SiPubGoods=@SiPubGoods,
			SiPurInvoice_Hd=@SiPurInvoice_Hd,
			SiPubCustomCodes=@SiPubCustomCodes,
			Cod_PurInvoiceDtCode=@Cod_PurInvoiceDtCode,
			Des_PurInvoiceDtDesc=@Des_PurInvoiceDtDesc,
			Num_PurInvoiceDtGoodsAmt=@Num_PurInvoiceDtGoodsAmt,
--			Num_PurInvoiceDtGoodsFee=@Num_PurInvoiceDtGoodsFee,
--			Num_PurInvoiceDtdiscountAmt=@Num_PurInvoiceDtdiscountAmt,
			Num_PurInvoiceDtTotalAmt=@Num_PurInvoiceDtTotalAmt,
			Num_PurInvoiceDtServiceNo=@Num_PurInvoiceDtServiceNo,
--			Num_PurInvoiceDtServiceFee=@Num_PurInvoiceDtServiceFee,
			Sta_BuyServiceOrGds=@Sta_BuyServiceOrGds,
			SiInvEntrance_Dt=@SiInvEntrance_Dt,			
			Num_PurInvoiceDtAddedTax=@Num_PurInvoiceDtAddedTax,
			SiPubCostCenter=@SiPubCostCenter,
			Num_PurInvoiceDtGoodsFeeNonCalc=@Num_PurInvoiceDtGoodsFeeNonCalc,
			SiPurPurchOrder_Dt=@SiPurPurchOrder_Dt
		Where (SiPurInvoice_Dt=@SiPurInvoice_Dt)

		if @Num_PurInvoiceDtGoodsAmt=@Num_InvEntDetailGdsAmount
		UPDATE    
			Tss_InvEntrance_Dt
		SET              
			Num_InvEntDetailRialFee = @Num_PurInvoiceDtGoodsFeeNonCalc,
			Num_TaxFee = @Num_PurInvoiceDtAddedTax/@Num_PurInvoiceDtGoodsAmt,
			Num_VaredehRialiAmt = (round(((isnull(@Num_PurInvoiceDtGoodsFeeNonCalc,0) + isnull(Num_TransportCostFee,0) + isnull(@Num_PurInvoiceDtAddedTax/@Num_PurInvoiceDtGoodsAmt,0)) * @Num_InvEntDetailGdsAmount),0))
		WHERE 
			(SiInvEntrance_Dt = @SiInvEntrance_Dt)

		if @Num_PurInvoiceDtGoodsAmt>@Num_InvEntDetailGdsAmount
		UPDATE    
			Tss_InvEntrance_Dt
		SET              
			Num_InvEntDetailRialFee = @Num_PurInvoiceDtGoodsFeeNonCalc,
			Num_TaxFee = @Num_PurInvoiceDtAddedTax/@Num_PurInvoiceDtGoodsAmt, 
			Num_VaredehRialiAmt = (round(((isnull(@Num_PurInvoiceDtGoodsFeeNonCalc,0) + isnull(Num_TransportCostFee,0) + isnull(@Num_PurInvoiceDtAddedTax/@Num_PurInvoiceDtGoodsAmt,0)) * @Num_InvEntDetailGdsAmount),0))
		WHERE 
			(SiInvEntrance_Hd = @SiInvEntrance_Hd) and
			(SiPubGoods = @SiPubGoods)

		Set @Err_Code=@@Error
		If @Err_Code<>0
			Set @Err_Code=401
		Return
	End
	ELse
		Set @Err_Code=402
End

If @FlgInsUpdDel=2
Begin
	Set @Err_Code=0
	If 
Exists(
	Select StmPurInvoice_Dt From dbo.Tss_PurInvoice_Dt
	Where (SiPurInvoice_Dt=@SiPurInvoice_Dt) And (StmPurInvoice_Dt=@StmPurInvoice_Dt))
	Begin

		Delete From dbo.Tss_PurInvoice_Dt
		Where (SiPurInvoice_Dt=@SiPurInvoice_Dt)

		if @Num_PurInvoiceDtGoodsAmt=@Num_InvEntDetailGdsAmount
		UPDATE    
			Tss_InvEntrance_Dt
		SET              
			Num_InvEntDetailRialFee = 0,
			Num_TaxFee = 0,
			Num_VaredehRialiAmt = 0
		WHERE 
			(SiInvEntrance_Dt = @SiInvEntrance_Dt)

		if @Num_PurInvoiceDtGoodsAmt>@Num_InvEntDetailGdsAmount
		UPDATE    
			Tss_InvEntrance_Dt
		SET              
			Num_InvEntDetailRialFee = 0,
			Num_TaxFee = 0,
			Num_VaredehRialiAmt = 0
		WHERE 
			(SiInvEntrance_Hd = @SiInvEntrance_Hd) and
			(SiPubGoods=@SiPubGoods)

		Set @Err_Code=@@Error
	
	If @Err_Code<>0
			Set @Err_Code=4000
	End
	Else
		Set @Err_Code=4001
	Return
End

Go

alter proc Tss_InvPaperVaredehRepDtStp
(
	@SiInvEntrance_Hd Numeric=235
)
As

DECLARE 
	@RialiAmt NUMERIC, @WeightSum NUMERIC, @RoleNoSum NUMERIC, @Des_InvEntDetailDesc varchar(500), @Des_PubUnitDesc varchar(50), @Cod_PubGoodsCode varchar(50), 
	@Des_PubGoodsDesc varchar(500), @SiInvEntranceHd NUMERIC, @SiPubGoods numeric, @Gramage numeric, @Width numeric  ,
	@Des_BarnamehNo varchar(500),
	@Des_HavalehNo varchar(500),
	@Des_VehicleNo varchar(500),
	@Num_ResidOriginWeight NUMERIC,
	@Num_FactoryBascule NUMERIC,
	@Num_BasculeDiff NUMERIC,
	@Num_TransportCost NUMERIC,
	@Cod_invEntDetailCode varchar(50),
	@Num_Serial Decimal(21,0)
Declare 
	@TempTable table 
	(RialiAmt numeric, WeightSum NUMERIC, RoleNoSum NUMERIC, Des_InvEntDetailDesc varchar(500), Des_PubUnitDesc varchar(50), Cod_PubGoodsCode varchar(50), 
	Des_PubGoodsDesc varchar(500), SiInvEntranceHd NUMERIC, SiPubGoods numeric, DesPubGoodsDesc varchar(500),Gramage numeric, Width numeric,
	Des_BarnamehNo varchar(500),
	Des_HavalehNo varchar(500),
	Des_VehicleNo varchar(500),
	Num_ResidOriginWeight NUMERIC,
	Num_FactoryBascule NUMERIC,
	Num_BasculeDiff NUMERIC,
	Num_TransportCost NUMERIC,
	Cod_invEntDetailCode varchar(50),
	Num_Serial Decimal(21,0)
	)

SELECT     
	@Des_BarnamehNo = Des_BarnamehNo, 
	@Des_HavalehNo = Des_HavalehNo, 
	@Des_VehicleNo = Des_VehicleNo, 
	@Num_ResidOriginWeight = Num_ResidOriginWeight, 
	@Num_FactoryBascule = Num_FactoryBascule, 
	@Num_BasculeDiff = Num_BasculeDiff, 
	@Num_TransportCost = Num_TransportCost
FROM         
	Tss_InvEntrance_Hd
WHERE     
	(SiInvEntrance_Hd = @SiInvEntrance_Hd)

Declare 
	@DesPubGoodsDesc1 varchar(50),
	@DesPubGoodsDesc2 varchar(50),
	@DesPubGoodsDesc3 varchar(50),
	@DesPubGoodsDesc4 varchar(50),
	@DesPubGoodsDesc varchar(50)

Set	@DesPubGoodsDesc1 = ''
Set	@DesPubGoodsDesc2 = ''
Set	@DesPubGoodsDesc3 = ''
Set	@DesPubGoodsDesc4 = ''
Set	@DesPubGoodsDesc = ''

if dbo.Tss_StdFindSubLoc(0)<>'zarin'
DECLARE EntranceDt CURSOR FOR 
SELECT
	SUM(dbo.Tss_InvEntrance_Dt.Num_VaredehRialiAmt) As RialiAmt,     
	SUM(dbo.Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount) AS WeightSum, 
	SUM(dbo.Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount2) AS RoleNoSum, 
	dbo.Tss_InvEntrance_Dt.Des_InvEntDetailDesc, 
	dbo.Tss_PubUnitSpecs.Des_PubUnitDesc, 
	dbo.Tss_PubGoods.Cod_PubGoodsCode, 
	dbo.Tss_PubGoods.Des_PubGoodsDesc, 
	dbo.Tss_InvEntrance_Dt.SiInvEntrance_Hd, 
	dbo.Tss_InvEntrance_Dt.SiPubGoods,
	dbo.Tss_InvEntrance_Dt.Cod_invEntDetailCode,
	dbo.Tss_InvEntrance_Dt.Num_Serial
FROM         
	dbo.Tss_InvEntrance_Dt INNER JOIN dbo.Tss_PubGoods ON 
	dbo.Tss_InvEntrance_Dt.SiPubGoods = dbo.Tss_PubGoods.SiPubGoods LEFT OUTER JOIN dbo.Tss_PubUnitSpecs ON 
	dbo.Tss_PubGoods.SiPubUnitSpecs1 = dbo.Tss_PubUnitSpecs.SiPubUnitSpecs
GROUP BY 
	dbo.Tss_InvEntrance_Dt.Des_InvEntDetailDesc, dbo.Tss_PubUnitSpecs.Des_PubUnitDesc, dbo.Tss_PubGoods.Cod_PubGoodsCode, 
    dbo.Tss_PubGoods.Des_PubGoodsDesc, dbo.Tss_InvEntrance_Dt.SiInvEntrance_Hd, dbo.Tss_InvEntrance_Dt.SiPubGoods,
    dbo.Tss_InvEntrance_Dt.Cod_invEntDetailCode, dbo.Tss_InvEntrance_Dt.Num_Serial
HAVING      
	(dbo.Tss_InvEntrance_Dt.SiInvEntrance_Hd = @SiInvEntrance_Hd)
order by
	dbo.Tss_InvEntrance_Dt.Cod_invEntDetailCode
else
DECLARE EntranceDt CURSOR FOR 
SELECT
	SUM(dbo.Tss_InvEntrance_Dt.Num_VaredehRialiAmt) As RialiAmt,     
	SUM(dbo.Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount) AS WeightSum, 
	SUM(dbo.Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount2) AS RoleNoSum, 
	dbo.Tss_InvEntrance_Dt.Des_InvEntDetailDesc, 
	dbo.Tss_PubUnitSpecs.Des_PubUnitDesc, 
	dbo.Tss_PubGoods.Cod_PubGoodsCode, 
	dbo.Tss_PubGoods.Des_PubGoodsDesc, 
	dbo.Tss_InvEntrance_Dt.SiInvEntrance_Hd, 
	dbo.Tss_InvEntrance_Dt.SiPubGoods,
	'' as Cod_invEntDetailCode,
	0 as Num_Serial
FROM         
	dbo.Tss_InvEntrance_Dt INNER JOIN dbo.Tss_PubGoods ON 
	dbo.Tss_InvEntrance_Dt.SiPubGoods = dbo.Tss_PubGoods.SiPubGoods LEFT OUTER JOIN dbo.Tss_PubUnitSpecs ON 
	dbo.Tss_PubGoods.SiPubUnitSpecs1 = dbo.Tss_PubUnitSpecs.SiPubUnitSpecs
GROUP BY 
	dbo.Tss_InvEntrance_Dt.Des_InvEntDetailDesc, dbo.Tss_PubUnitSpecs.Des_PubUnitDesc, dbo.Tss_PubGoods.Cod_PubGoodsCode, 
    dbo.Tss_PubGoods.Des_PubGoodsDesc, dbo.Tss_InvEntrance_Dt.SiInvEntrance_Hd, dbo.Tss_InvEntrance_Dt.SiPubGoods
HAVING      
	(dbo.Tss_InvEntrance_Dt.SiInvEntrance_Hd = @SiInvEntrance_Hd)

OPEN EntranceDt

FETCH NEXT FROM EntranceDt 
INTO @RialiAmt, @WeightSum , @RoleNoSum , @Des_InvEntDetailDesc ,@Des_PubUnitDesc , @Cod_PubGoodsCode , @Des_PubGoodsDesc , @SiInvEntranceHd, @SiPubGoods, @Cod_invEntDetailCode, @Num_Serial  
WHILE @@FETCH_STATUS = 0
BEGIN
	SELECT     @DesPubGoodsDesc1=isnull(ltrim(rtrim(dbo.Tss_PubTechSpecsToGoods.Des_TechSpecValue)),'')
	FROM         dbo.Tss_PubTechSpecsToGoods INNER JOIN
	                      dbo.Tss_PubCustomCodes ON dbo.Tss_PubTechSpecsToGoods.SiPubCustomCodes = dbo.Tss_PubCustomCodes.SiPubCustomCodes
	WHERE     (dbo.Tss_PubTechSpecsToGoods.SiPubGoods = @SiPubGoods) AND (dbo.Tss_PubTechSpecsToGoods.SiPubCustomCodes = 238)
	
	SELECT     @DesPubGoodsDesc2=isnull(ltrim(rtrim(dbo.Tss_PubTechSpecsToGoods.Des_TechSpecValue)),'')
	FROM         dbo.Tss_PubTechSpecsToGoods INNER JOIN
	                      dbo.Tss_PubCustomCodes ON dbo.Tss_PubTechSpecsToGoods.SiPubCustomCodes = dbo.Tss_PubCustomCodes.SiPubCustomCodes
	WHERE     (dbo.Tss_PubTechSpecsToGoods.SiPubGoods = @SiPubGoods) AND (dbo.Tss_PubTechSpecsToGoods.SiPubCustomCodes = 1528)
	
	SELECT     @DesPubGoodsDesc3=isnull(ltrim(rtrim(dbo.Tss_PubTechSpecsToGoods.Des_TechSpecValue)),'')
	FROM         dbo.Tss_PubTechSpecsToGoods INNER JOIN
	              dbo.Tss_PubCustomCodes ON dbo.Tss_PubTechSpecsToGoods.SiPubCustomCodes = dbo.Tss_PubCustomCodes.SiPubCustomCodes
	WHERE     (dbo.Tss_PubTechSpecsToGoods.SiPubGoods = @SiPubGoods) AND (dbo.Tss_PubTechSpecsToGoods.SiPubCustomCodes = 1298)
	
	SELECT     @DesPubGoodsDesc4=isnull(ltrim(rtrim(dbo.Tss_PubTechSpecsToGoods.Des_TechSpecValue)),'')
	FROM         dbo.Tss_PubTechSpecsToGoods INNER JOIN
	                      dbo.Tss_PubCustomCodes ON dbo.Tss_PubTechSpecsToGoods.SiPubCustomCodes = dbo.Tss_PubCustomCodes.SiPubCustomCodes
	WHERE     (dbo.Tss_PubTechSpecsToGoods.SiPubGoods = @SiPubGoods) AND (dbo.Tss_PubTechSpecsToGoods.SiPubCustomCodes = 1299)	

print 'ok'
	Set @DesPubGoodsDesc=isnull(@DesPubGoodsDesc2,'')+' '+isnull(@Des_PubGoodsDesc,'')+' '+isnull(@DesPubGoodsDesc1,'')
	if isnull(@DesPubGoodsDesc3,'')<>''
		Set @Gramage=convert(numeric,@DesPubGoodsDesc3)
	Else
		Set @Gramage=0

	if isnull(@DesPubGoodsDesc4,'')<>''
		Set @Width=  convert(numeric,@DesPubGoodsDesc4)
	Else
		Set @Width= 0
print 'ok'

	insert into @TempTable 
	(
	RialiAmt,
	WeightSum, 
	RoleNoSum, 
	Des_InvEntDetailDesc, 
	Des_PubUnitDesc, 
	Cod_PubGoodsCode, 
	Des_PubGoodsDesc, 
	SiInvEntranceHd, 
	SiPubGoods, 
	DesPubGoodsDesc,
	Gramage, 
	Width,
	Des_BarnamehNo,
	Des_HavalehNo,
	Des_VehicleNo,
	Num_ResidOriginWeight,
	Num_FactoryBascule,
	Num_BasculeDiff,
	Num_TransportCost,
	Cod_invEntDetailCode,
	Num_Serial
	)	
	values
	(
	@RialiAmt,
	@WeightSum, 
	@RoleNoSum, 
	@Des_InvEntDetailDesc,
	@Des_PubUnitDesc, 
	@Cod_PubGoodsCode, 
	@Des_PubGoodsDesc, 
	@SiInvEntranceHd, 
	@SiPubGoods,
	@DesPubGoodsDesc,
	@Gramage, 
	@Width, 
	@Des_BarnamehNo,
	@Des_HavalehNo,
	@Des_VehicleNo,
	@Num_ResidOriginWeight,
	@Num_FactoryBascule,
	@Num_BasculeDiff,
	@Num_TransportCost,
	@Cod_invEntDetailCode,
	@Num_Serial
	)
   FETCH NEXT FROM EntranceDt 
	INTO @RialiAmt, @WeightSum , @RoleNoSum , @Des_InvEntDetailDesc ,@Des_PubUnitDesc , @Cod_PubGoodsCode , @Des_PubGoodsDesc , @SiInvEntranceHd, @SiPubGoods, @Cod_invEntDetailCode, @Num_Serial  
END

CLOSE EntranceDt
DEALLOCATE EntranceDt

if dbo.Tss_StdFindSubLoc(0)<>'zarin'
select 
	RialiAmt,
	WeightSum, 
	RoleNoSum, 
	Des_InvEntDetailDesc, 
	Des_PubUnitDesc, 
	Cod_PubGoodsCode , 
	Des_PubGoodsDesc , 
	SiInvEntranceHd , 
	SiPubGoods , 
	DesPubGoodsDesc ,
	Gramage, 
	Width, 
	Des_BarnamehNo,
	Des_HavalehNo,
	Des_VehicleNo,
	Num_ResidOriginWeight,
	Num_FactoryBascule,
	Num_BasculeDiff,
	Num_TransportCost,
	Cod_invEntDetailCode,
	Num_Serial
From 
	@TempTable
order by
	convert(numeric,Cod_invEntDetailCode)
else
select 
	RialiAmt,
	WeightSum, 
	RoleNoSum, 
	Des_InvEntDetailDesc, 
	Des_PubUnitDesc, 
	Cod_PubGoodsCode , 
	Des_PubGoodsDesc , 
	SiInvEntranceHd , 
	SiPubGoods , 
	DesPubGoodsDesc ,
	Gramage, 
	Width, 
	Des_BarnamehNo,
	Des_HavalehNo,
	Des_VehicleNo,
	Num_ResidOriginWeight,
	Num_FactoryBascule,
	Num_BasculeDiff,
	Num_TransportCost,
	Cod_invEntDetailCode,
	Num_Serial
From 
	@TempTable


delete @TempTable

GO

alter Procedure Tss_SalApproveContractStp  
(  
 @SiSalInvoice_Hd Numeric,
 @Sta_ContractStatus smallint
)   
As  

if not exists
(
SELECT     *
FROM         Tss_SalInvoice_Dt INNER JOIN
                      Tss_PrcProdProgram_Dt ON Tss_SalInvoice_Dt.SiSalInvoice_Dt = Tss_PrcProdProgram_Dt.SiSalInvoice_DtNo1
WHERE     (Tss_SalInvoice_Dt.SiSalInvoice_Hd = @SiSalInvoice_Hd)
)
Update dbo.Tss_SalInvoice_Hd   
 Set 
    Sta_ContractStatus=@Sta_ContractStatus, 
    Dat_ApprovedForProd=dbo.Tss_StdShamsiToday(GETDATE()),
    Dat_SalConfirmOfProdDate=dbo.Tss_StdShamsiToday(GETDATE())
 Where SiSalInvoice_Hd=@SiSalInvoice_Hd

GO