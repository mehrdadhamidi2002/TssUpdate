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

------------------------------------------------œ—Ã œ— „Õ«”»Â „«„Ê—Ì ------------------------------------------------------
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

------------------------------------------------œ—Ã œ— „Õ«”»Â „«„Ê—Ì ------------------------------------------------------

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

------------------------------------------------œ—Ã œ— „Õ«”»Â „«„Ê—Ì -------------------------------------
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

------------------------------------------------œ—Ã œ— „Õ«”»Â „«„Ê—Ì -------------------------------------
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
------------------------------------------------Õ–› „Õ«”»Â „«„Ê—Ì -------------------------------------
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

------------------------------------------------Õ–› „Õ«”»Â „«„Ê—Ì -------------------------------------
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
		------------------------------------------------œ—Ã œ— „Õ«”»Â „—Œ’Ì------------------------------------------------------
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

				print '„‰ «Ì‰Ã«„„„„„„„„„„„„„„„„„'
			
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
		
		------------------------------------------------œ—Ã œ— „Õ«”»Â „—Œ’Ì------------------------------------------------------
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
		------------------------------------------------œ—Ã œ— „Õ«”»Â „—Œ’Ì------------------------------------------------------
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
		------------------------------------------------œ—Ã œ— „Õ«”»Â „—Œ’Ì------------------------------------------------------
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
------------------------------------------------Õ–› „Õ«”»Â „—Œ’Ì-------------------------------------
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

------------------------------------------------Õ–› „Õ«”»Â „—Œ’Ì-------------------------------------
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

------------------------------------------------œ—Ã œ— „Õ«”»Â „«„Ê—Ì ------------------------------------------------------
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

------------------------------------------------œ—Ã œ— „Õ«”»Â „«„Ê—Ì ------------------------------------------------------

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

------------------------------------------------œ—Ã œ— „Õ«”»Â „«„Ê—Ì -------------------------------------
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

------------------------------------------------œ—Ã œ— „Õ«”»Â „«„Ê—Ì -------------------------------------
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
------------------------------------------------Õ–› „Õ«”»Â „«„Ê—Ì -------------------------------------
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

------------------------------------------------Õ–› „Õ«”»Â „«„Ê—Ì -------------------------------------
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
			------------------------------------------------œ—Ã œ— „Õ«”»Â «÷«›Âùﬂ«—Ì------------------------------------------------------
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
			------------------------------------------------œ—Ã œ— „Õ«”»Â «÷«›Âùﬂ«—Ì------------------------------------------------------
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
    Tss_PrcDieSpec.Des_DieSpecDesc+'+''''+' - '+''''+'+convert(varchar,Tss_PrcDieSpec.Num_NoGdsInDie)+'+''''+'  «ÌÌ '+''''+' as Des_DieSpecDesc,
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
            AND (@SiUser = 1 OR Tss_StdSystemUsers.SiPubPersonsSpec = @SiUser)
            AND EXISTS (
                SELECT 1 
                FROM Tss_PubPersonsSpec p
                WHERE p.SiPubPersonsSpec = Tss_StdSystemUsers.SiPubPersonsSpec
            )
    ),
    TreeCTE AS
    (
        -- Anchor: the accessible leaf items themselves
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
            INNER JOIN AccessibleLeaves al
                ON al.SiStdSystemMenuItems = m.SiStdSystemMenuItems

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
    Tss_PrcDieSpec.Des_DieSpecDesc+'+''''+' - '+''''+'+convert(varchar,Tss_PrcDieSpec.Num_NoGdsInDie)+'+''''+'  «ÌÌ '+''''+' as Des_DieSpecDesc,
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
            Tss_PrcDieSpec.Des_DieSpecDesc + N'' - '' + CONVERT(VARCHAR, Tss_PrcDieSpec.Num_NoGdsInDie) + N''  «ÌÌ '' AS Des_DieSpecDesc,
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
                Tss_PrcDieSpec.Des_DieSpecDesc + N'' - '' + CONVERT(VARCHAR, Tss_PrcDieSpec.Num_NoGdsInDie) + N''  «ÌÌ '' AS Des_DieSpecDesc,
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
	@Sta_ContIsLaminate smallint=0,
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
	@Sta_ContIsLaminate smallint=0,
	@StmSalInvoice_Hd TimeStamp=0,  
	@SiUser Numeric,  
	@FlgInsUpdDel SmallInt  
) As 

if dbo.Tss_StdFindSubLoc(0)='Pe
rsa'
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
			If (IsNull(@Sta_TransportState,0) 
<> 0)
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
				Set @Err_Code=
400  
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
