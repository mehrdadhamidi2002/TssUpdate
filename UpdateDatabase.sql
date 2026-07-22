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

alter VIEW Tss_RapRecCheckGhabzRep1Vw
AS
SELECT        dbo.Tss_RapReceivedCheque.Cod_RapReceivedChequeCode AS GhabzNo, dbo.Tss_PubCustomCodes.Des_CustomCodesDesc AS BankName, Tss_PubPersonsViw_1.Cod_PubPersonCode AS RecieverCode, 
                         Tss_PubPersonsViw_1.Des_FullName AS RecieverName, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeEndDate AS UsanceDate, dbo.Tss_RapReceivedCheque.Num_RapReceivedChequeAmount AS ChequeAmount, 
                         dbo.Tss_RapReceivedCheque.Cod_RapReceivedChqBankCode AS BankBranchCode, dbo.Tss_RapReceivedCheque.Cod_RapReceivedChequeSerial AS ChequeSerial, 
                         dbo.Tss_RapReceivedCheque.Des_RapReceivedChequeDesc AS Tozihat, dbo.Tss_RapReceivedCheque.Des_RapReceivedChequeRecieptDesc AS RecieptTozih, dbo.Tss_RapReceivedCheque.Sta_ChekRecieptMainOrNot, 
                         dbo.Tss_RapReceivedCheque.SiRapReceivedCheque, dbo.Tss_RapReceivedCheque.SiPubPersonsSpec, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeCngDate, 
                         dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeVosoolDate, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeBargashtDate, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeCancelDate, 
                         dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeToPerDate, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeToBankDate, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeHoghughiDate, 
                         dbo.Tss_RapReceivedCheque.SiPubSubLocations, dbo.Tss_RapReceivedCheque.SiRapCashDefine, dbo.Tss_RapReceivedCheque.SiPubCustomCodes, Tss_PubPersonsViw_2.Cod_PubPersonCode AS GiverCode, 
                         Tss_PubPersonsViw_2.Des_FullName AS GiverName, Tss_PubPersonsViw_2.Cod_PubPersonCode, Tss_PubPersonsViw_2.Des_FullName, dbo.Tss_RapRecChequeToBankVw.Sta_CheckToBankState,
                             (SELECT        TOP (1) dbo.Tss_PubPersonsViw.Des_FullName
                                FROM            dbo.Tss_RapRecChequeToBank INNER JOIN
                                                         dbo.Tss_PubPersonsViw ON dbo.Tss_RapRecChequeToBank.SiPubPersonsSpec = dbo.Tss_PubPersonsViw.SiPubPersonsSpec
                                WHERE        (dbo.Tss_RapRecChequeToBank.Sta_CheckToBankState < 3) AND (dbo.Tss_RapRecChequeToBank.SiRapReceivedCheque = dbo.Tss_RapReceivedCheque.SiRapReceivedCheque)
                                ORDER BY dbo.Tss_RapRecChequeToBank.SiRapRecChequeToBank desc) AS GirandehDesc,
                             (SELECT        TOP (1) Tss_PubPersonsViw_3.Cod_PubPersonCode
                                FROM            dbo.Tss_RapRecChequeToBank AS Tss_RapRecChequeToBank_1 INNER JOIN
                                                         dbo.Tss_PubPersonsViw AS Tss_PubPersonsViw_3 ON Tss_RapRecChequeToBank_1.SiPubPersonsSpec = Tss_PubPersonsViw_3.SiPubPersonsSpec
                                WHERE        (Tss_RapRecChequeToBank_1.Sta_CheckToBankState < 3) AND (Tss_RapRecChequeToBank_1.SiRapReceivedCheque = dbo.Tss_RapReceivedCheque.SiRapReceivedCheque)
                                ORDER BY Tss_RapRecChequeToBank_1.SiRapRecChequeToBank desc) AS GirandehCode, dbo.Tss_RapReceivedCheque.Dat_EsterdadToPer, dbo.Tss_RapReceivedCheque.Dat_EsterdadToCashier, 
                         dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeToAgainDate, dbo.Tss_RapReceivedCheque.SiRapRecievedChequeRef_RefrenceHd, dbo.Tss_RapReceivedCheque.SiRapBehalfDefineHd, 
                         dbo.Tss_RapReceivedCheque.Sta_CalcInReturnRep, dbo.Tss_RapReceivedCheque.Sta_RapReceivedChequeState, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeRegDate AS RegDate, 
                         Tss_PubPersonsViw_4.Cod_PubPersonCode AS Expr1, Tss_PubPersonsViw_4.Des_FullName AS Expr2, Tss_PubPersonsViw_2.SiPerRelatedSaler,
                         dbo.Tss_RapReceivedCheque.Des_ReceivedChequeSayadiCode,dbo.Tss_RapReceivedCheque.Des_ReceivedChequeSayadiNationalCode,
    dbo.Tss_RapReceivedCheque.Sta_IsChecqueElectronic
FROM            dbo.Tss_PubPersonsViw AS Tss_PubPersonsViw_4 RIGHT OUTER JOIN
                         dbo.Tss_RapReceivedCheque INNER JOIN
                         dbo.Tss_RapCashDefine ON dbo.Tss_RapReceivedCheque.SiRapCashDefine = dbo.Tss_RapCashDefine.SiRapCashDefine INNER JOIN
                         dbo.Tss_RapCashOwners ON dbo.Tss_RapCashDefine.SiRapCashDefine = dbo.Tss_RapCashOwners.SiRapCashDefine INNER JOIN
                         dbo.Tss_PubPersonsViw AS Tss_PubPersonsViw_1 ON dbo.Tss_RapCashOwners.SiPubPersonsSpec = Tss_PubPersonsViw_1.SiPubPersonsSpec INNER JOIN
                         dbo.Tss_PubPersonsViw AS Tss_PubPersonsViw_2 ON dbo.Tss_RapReceivedCheque.SiPubPersonsSpec = Tss_PubPersonsViw_2.SiPubPersonsSpec ON 
                         Tss_PubPersonsViw_4.SiPubPersonsSpec = Tss_PubPersonsViw_2.SiPerRelatedSaler LEFT OUTER JOIN
                         dbo.Tss_RapRecChequeToBankVw ON dbo.Tss_RapReceivedCheque.SiRapReceivedCheque = dbo.Tss_RapRecChequeToBankVw.SiRapReceivedCheque LEFT OUTER JOIN
                         dbo.Tss_PubCustomCodes ON dbo.Tss_RapReceivedCheque.SiPubCustomCodes = dbo.Tss_PubCustomCodes.SiPubCustomCodes
GROUP BY dbo.Tss_PubCustomCodes.Des_CustomCodesDesc, Tss_PubPersonsViw_1.Cod_PubPersonCode, Tss_PubPersonsViw_1.Des_FullName, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeEndDate, 
                         dbo.Tss_RapReceivedCheque.Num_RapReceivedChequeAmount, dbo.Tss_RapReceivedCheque.Cod_RapReceivedChqBankCode, dbo.Tss_RapReceivedCheque.Cod_RapReceivedChequeSerial, 
                         dbo.Tss_RapReceivedCheque.SiRapReceivedCheque, dbo.Tss_RapReceivedCheque.Cod_RapReceivedChequeCode, Tss_PubPersonsViw_1.Des_FullName, Tss_PubPersonsViw_1.Cod_PubPersonCode, 
                         dbo.Tss_RapReceivedCheque.Des_RapReceivedChequeDesc, dbo.Tss_RapReceivedCheque.Des_RapReceivedChequeRecieptDesc, dbo.Tss_RapReceivedCheque.Sta_ChekRecieptMainOrNot, 
                         dbo.Tss_RapReceivedCheque.SiPubPersonsSpec, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeCngDate, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeVosoolDate, 
                         dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeBargashtDate, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeCancelDate, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeToPerDate, 
                         dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeToBankDate, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeHoghughiDate, dbo.Tss_RapReceivedCheque.SiPubSubLocations, 
                         dbo.Tss_RapReceivedCheque.SiRapCashDefine, dbo.Tss_RapReceivedCheque.SiPubCustomCodes, Tss_PubPersonsViw_2.Cod_PubPersonCode, Tss_PubPersonsViw_2.Des_FullName, 
                         Tss_PubPersonsViw_2.Cod_PubPersonCode, Tss_PubPersonsViw_2.Des_FullName, dbo.Tss_RapRecChequeToBankVw.Sta_CheckToBankState, dbo.Tss_RapReceivedCheque.Dat_EsterdadToPer, 
                         dbo.Tss_RapReceivedCheque.Dat_EsterdadToCashier, dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeToAgainDate, dbo.Tss_RapReceivedCheque.SiRapRecievedChequeRef_RefrenceHd, 
                         dbo.Tss_RapReceivedCheque.SiRapBehalfDefineHd, dbo.Tss_RapReceivedCheque.Sta_CalcInReturnRep, dbo.Tss_RapReceivedCheque.Sta_RapReceivedChequeState, 
                         dbo.Tss_RapReceivedCheque.Dat_RapReceivedChequeRegDate, Tss_PubPersonsViw_4.Cod_PubPersonCode, Tss_PubPersonsViw_4.Des_FullName, 
                         Tss_PubPersonsViw_2.SiPerRelatedSaler, dbo.Tss_RapReceivedCheque.Des_ReceivedChequeSayadiCode,
                         dbo.Tss_RapReceivedCheque.Des_ReceivedChequeSayadiNationalCode, dbo.Tss_RapReceivedCheque.Sta_IsChecqueElectronic


Go

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

alter PROCEDURE Tss_SalInvoice_HdQkeyStp  
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
else 
   Set @Order='order by Convert(int,Cod_SaleAgreement2) desc'
Exec(  
   'Select * from  
   (Select * From (  
     SELECT       
        Tss_SalInvoice_Hd.SiSalInvoice_Hd, 
        Tss_SalInvoice_Hd.Cod_SaleAgreement2, 
        Tss_SalInvoice_Hd.Cod_SaleAgreement, 
        Tss_SalInvoice_Hd.Cod_SaleAgreementChange, 
        Tss_SalInvoice_Hd.Des_SaleAgreementDesc, 
        Tss_PubPersonsViw.Des_FullName,
        Tss_SalInvoice_Hd.Dat_SalReqToContractDate,
        Tss_SalInvoice_Hd.Sta_ContractStatus, 
        Tss_SalInvoice_Hd.Sta_ForProdOrSale, 
        Tss_SalInvoice_Hd.SiPubPersonsSpec, 
        Tss_SalInvoice_Hd.Sta_MainOrNot, 
        Tss_PubPersonsViw.Cod_PubPersonCode, 
        Tss_SalInvoice_Hd.SiPubCustomCodes, 
        Tss_PubCustomCodes.Des_CustomCodesDesc, 
        Tss_PubCustomCodes.Cod_CustomCodesCode, 
        Tss_SalInvoice_Hd.SiSalTypeOfSales, 
        Tss_SalInvoice_Hd.SiPubSubLocations, 
        Tss_SalTypeOfSales.Cod_SalTypeCode, 
        Tss_SalTypeOfSales.Des_SalTypeDesc, 
        Tss_PubSubLocations.Cod_SubLocCode, 
        Tss_PubSubLocations.Des_SubLocName,
        Tss_SalInvoice_Hd.Dat_SaleRequestRegDate, 
        Tss_SalInvoice_Hd.Cod_LetterNo
    FROM            
        Tss_SalInvoice_Hd INNER JOIN
        Tss_PubPersonsViw ON Tss_SalInvoice_Hd.SiPubPersonsSpec = Tss_PubPersonsViw.SiPubPersonsSpec INNER JOIN
        Tss_SalTypeOfSales ON Tss_SalInvoice_Hd.SiSalTypeOfSales = Tss_SalTypeOfSales.SiSalTypeOfSales INNER JOIN
        Tss_PubSubLocations ON Tss_SalInvoice_Hd.SiPubSubLocations = Tss_PubSubLocations.SiPubSubLocations LEFT OUTER JOIN
        Tss_PubCustomCodes ON Tss_SalInvoice_Hd.SiPubCustomCodes = Tss_PubCustomCodes.SiPubCustomCodes
	WHERE     (Tss_SalInvoice_Hd.Sta_ContractStatus <>3) AND (Tss_SalInvoice_Hd.Sta_ContractStatus <> 4)) Ccc '+@InternalWhere+'  
   ) CalcSel ' + @Where + @Order  
)

GO

BEGIN TRY
    BEGIN TRANSACTION;
    
    PRINT 'Starting column alteration process...';
    
    -- 1. Drop all non-primary-key indexes on Num_Serial
    DECLARE @IndexName NVARCHAR(128);
    DECLARE @DropIndexSQL NVARCHAR(500);
    
    DECLARE IndexCursor CURSOR FOR
    SELECT i.name
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE 
        OBJECT_NAME(i.object_id) = 'Tss_InvEntrance_Dt'
        AND c.name = 'Num_Serial'
        AND i.name IS NOT NULL
        AND i.is_primary_key = 0
        AND i.is_unique_constraint = 0;
    
    OPEN IndexCursor;
    FETCH NEXT FROM IndexCursor INTO @IndexName;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @DropIndexSQL = 'DROP INDEX ' + QUOTENAME(@IndexName) + ' ON Tss_InvEntrance_Dt;';
        PRINT 'Dropping index: ' + @IndexName;
        EXEC sp_executesql @DropIndexSQL;
        FETCH NEXT FROM IndexCursor INTO @IndexName;
    END;
    
    CLOSE IndexCursor;
    DEALLOCATE IndexCursor;
    
    -- 2. Check for foreign keys
    DECLARE @FKName NVARCHAR(128);
    DECLARE @DropFKSQL NVARCHAR(500);
    
    DECLARE FKCursor CURSOR FOR
    SELECT fk.name
    FROM sys.foreign_keys fk
    INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
    INNER JOIN sys.columns c ON fkc.parent_object_id = c.object_id AND fkc.parent_column_id = c.column_id
    WHERE 
        OBJECT_NAME(fk.parent_object_id) = 'Tss_InvEntrance_Dt'
        AND c.name = 'Num_Serial';
    
    OPEN FKCursor;
    FETCH NEXT FROM FKCursor INTO @FKName;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @DropFKSQL = 'ALTER TABLE Tss_InvEntrance_Dt DROP CONSTRAINT ' + QUOTENAME(@FKName) + ';';
        PRINT 'Dropping foreign key: ' + @FKName;
        EXEC sp_executesql @DropFKSQL;
        FETCH NEXT FROM FKCursor INTO @FKName;
    END;
    
    CLOSE FKCursor;
    DEALLOCATE FKCursor;
    
    -- 3. Check for default constraints
    DECLARE @DefaultName NVARCHAR(128);
    DECLARE @DropDefaultSQL NVARCHAR(500);
    
    DECLARE DefaultCursor CURSOR FOR
    SELECT dc.name
    FROM sys.default_constraints dc
    INNER JOIN sys.columns c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
    WHERE 
        OBJECT_NAME(dc.parent_object_id) = 'Tss_InvEntrance_Dt'
        AND c.name = 'Num_Serial';
    
    OPEN DefaultCursor;
    FETCH NEXT FROM DefaultCursor INTO @DefaultName;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @DropDefaultSQL = 'ALTER TABLE Tss_InvEntrance_Dt DROP CONSTRAINT ' + QUOTENAME(@DefaultName) + ';';
        PRINT 'Dropping default constraint: ' + @DefaultName;
        EXEC sp_executesql @DropDefaultSQL;
        FETCH NEXT FROM DefaultCursor INTO @DefaultName;
    END;
    
    CLOSE DefaultCursor;
    DEALLOCATE DefaultCursor;
    
    -- 4. Check for check constraints
    DECLARE @CheckName NVARCHAR(128);
    DECLARE @DropCheckSQL NVARCHAR(500);
    
    DECLARE CheckCursor CURSOR FOR
    SELECT cc.name
    FROM sys.check_constraints cc
    INNER JOIN sys.columns c ON cc.parent_object_id = c.object_id AND cc.parent_column_id = c.column_id
    WHERE 
        OBJECT_NAME(cc.parent_object_id) = 'Tss_InvEntrance_Dt'
        AND c.name = 'Num_Serial';
    
    OPEN CheckCursor;
    FETCH NEXT FROM CheckCursor INTO @CheckName;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @DropCheckSQL = 'ALTER TABLE Tss_InvEntrance_Dt DROP CONSTRAINT ' + QUOTENAME(@CheckName) + ';';
        PRINT 'Dropping check constraint: ' + @CheckName;
        EXEC sp_executesql @DropCheckSQL;
        FETCH NEXT FROM CheckCursor INTO @CheckName;
    END;
    
    CLOSE CheckCursor;
    DEALLOCATE CheckCursor;
    
    -- 5. Now alter the column
    PRINT 'Altering column Num_Serial to DECIMAL(21,0)...';
    ALTER TABLE Tss_InvEntrance_Dt
    ALTER COLUMN Num_Serial DECIMAL(21, 0);
    
    PRINT 'Column altered successfully!';
    
    -- 6. Recreate the indexes (you'll need to know the original definitions)
    -- Add your index recreation scripts here
    -- Example:
    -- CREATE INDEX [IX_YourIndexName] ON Tss_InvEntrance_Dt (Num_Serial);
    
    -- 7. Recreate foreign keys
    -- Add your foreign key recreation scripts here
    
    -- 8. Recreate default constraints
    -- Add your default constraint recreation scripts here
    
    -- 9. Recreate check constraints
    -- Add your check constraint recreation scripts here
    
    PRINT 'All operations completed successfully!';
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR OCCURRED!';
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), '');
    
    -- If there's a specific index that can't be dropped, show it
    IF ERROR_MESSAGE() LIKE '%index%'
    BEGIN
        PRINT 'The error appears to be related to an index.';
        PRINT 'Check if there are any indexes that need to be dropped manually.';
    END
END CATCH

GO

BEGIN TRY
    BEGIN TRANSACTION;
    
    PRINT 'Starting column alteration process for Tss_InvOutGo_Dt...';
    
    -- 1. Drop all non-primary-key indexes on Num_Serial
    DECLARE @IndexName NVARCHAR(128);
    DECLARE @DropIndexSQL NVARCHAR(500);
    
    DECLARE IndexCursor CURSOR FOR
    SELECT i.name
    FROM sys.indexes i
    INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
    INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
    WHERE 
        OBJECT_NAME(i.object_id) = 'Tss_InvOutGo_Dt'
        AND c.name = 'Num_Serial'
        AND i.name IS NOT NULL
        AND i.is_primary_key = 0
        AND i.is_unique_constraint = 0;
    
    OPEN IndexCursor;
    FETCH NEXT FROM IndexCursor INTO @IndexName;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @DropIndexSQL = 'DROP INDEX ' + QUOTENAME(@IndexName) + ' ON Tss_InvOutGo_Dt;';
        PRINT 'Dropping index: ' + @IndexName;
        EXEC sp_executesql @DropIndexSQL;
        FETCH NEXT FROM IndexCursor INTO @IndexName;
    END;
    
    CLOSE IndexCursor;
    DEALLOCATE IndexCursor;
    
    -- 2. Check for foreign keys
    DECLARE @FKName NVARCHAR(128);
    DECLARE @DropFKSQL NVARCHAR(500);
    
    DECLARE FKCursor CURSOR FOR
    SELECT fk.name
    FROM sys.foreign_keys fk
    INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
    INNER JOIN sys.columns c ON fkc.parent_object_id = c.object_id AND fkc.parent_column_id = c.column_id
    WHERE 
        OBJECT_NAME(fk.parent_object_id) = 'Tss_InvOutGo_Dt'
        AND c.name = 'Num_Serial';
    
    OPEN FKCursor;
    FETCH NEXT FROM FKCursor INTO @FKName;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @DropFKSQL = 'ALTER TABLE Tss_InvOutGo_Dt DROP CONSTRAINT ' + QUOTENAME(@FKName) + ';';
        PRINT 'Dropping foreign key: ' + @FKName;
        EXEC sp_executesql @DropFKSQL;
        FETCH NEXT FROM FKCursor INTO @FKName;
    END;
    
    CLOSE FKCursor;
    DEALLOCATE FKCursor;
    
    -- 3. Check for default constraints
    DECLARE @DefaultName NVARCHAR(128);
    DECLARE @DropDefaultSQL NVARCHAR(500);
    
    DECLARE DefaultCursor CURSOR FOR
    SELECT dc.name
    FROM sys.default_constraints dc
    INNER JOIN sys.columns c ON dc.parent_object_id = c.object_id AND dc.parent_column_id = c.column_id
    WHERE 
        OBJECT_NAME(dc.parent_object_id) = 'Tss_InvOutGo_Dt'
        AND c.name = 'Num_Serial';
    
    OPEN DefaultCursor;
    FETCH NEXT FROM DefaultCursor INTO @DefaultName;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @DropDefaultSQL = 'ALTER TABLE Tss_InvOutGo_Dt DROP CONSTRAINT ' + QUOTENAME(@DefaultName) + ';';
        PRINT 'Dropping default constraint: ' + @DefaultName;
        EXEC sp_executesql @DropDefaultSQL;
        FETCH NEXT FROM DefaultCursor INTO @DefaultName;
    END;
    
    CLOSE DefaultCursor;
    DEALLOCATE DefaultCursor;
    
    -- 4. Check for check constraints
    DECLARE @CheckName NVARCHAR(128);
    DECLARE @DropCheckSQL NVARCHAR(500);
    
    DECLARE CheckCursor CURSOR FOR
    SELECT cc.name
    FROM sys.check_constraints cc
    INNER JOIN sys.columns c ON cc.parent_object_id = c.object_id AND cc.parent_column_id = c.column_id
    WHERE 
        OBJECT_NAME(cc.parent_object_id) = 'Tss_InvOutGo_Dt'
        AND c.name = 'Num_Serial';
    
    OPEN CheckCursor;
    FETCH NEXT FROM CheckCursor INTO @CheckName;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @DropCheckSQL = 'ALTER TABLE Tss_InvOutGo_Dt DROP CONSTRAINT ' + QUOTENAME(@CheckName) + ';';
        PRINT 'Dropping check constraint: ' + @CheckName;
        EXEC sp_executesql @DropCheckSQL;
        FETCH NEXT FROM CheckCursor INTO @CheckName;
    END;
    
    CLOSE CheckCursor;
    DEALLOCATE CheckCursor;
    
    -- 5. Now alter the column
    PRINT 'Altering column Num_Serial to DECIMAL(21,0)...';
    ALTER TABLE Tss_InvOutGo_Dt
    ALTER COLUMN Num_Serial DECIMAL(21, 0);
    
    PRINT 'Column altered successfully!';
    
    -- 6. Recreate the indexes (you'll need to know the original definitions)
    -- Add your index recreation scripts here
    -- Example:
    -- CREATE INDEX [IX_YourIndexName] ON Tss_InvOutGo_Dt (Num_Serial);
    
    -- 7. Recreate foreign keys
    -- Add your foreign key recreation scripts here
    
    -- 8. Recreate default constraints
    -- Add your default constraint recreation scripts here
    
    -- 9. Recreate check constraints
    -- Add your check constraint recreation scripts here
    
    PRINT 'All operations completed successfully for Tss_InvOutGo_Dt!';
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'ERROR OCCURRED!';
    PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Error Message: ' + ERROR_MESSAGE();
    PRINT 'Error Line: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Error Procedure: ' + ISNULL(ERROR_PROCEDURE(), '');
    
    -- If there's a specific index that can't be dropped, show it
    IF ERROR_MESSAGE() LIKE '%index%'
    BEGIN
        PRINT 'The error appears to be related to an index.';
        PRINT 'Check if there are any indexes that need to be dropped manually.';
    END
END CATCH

Go

alter procedure Tss_InvUntEntrance_DtIudStp  
(  
	@Err_Code Int OutPut,  
	@SiInvEntrance_Dt  Numeric OutPut,  
	@SiPubGoods Numeric=Null,  
	@Cod_invEntDetailCode varchar(50)='',
	@SiInvEntrance_Hd Numeric=Null,  
	@Sta_InvEntUsedUnit SmallInt=0,  
	@Des_InvEntDetailDesc VarChar(500)='',  
	@Num_InvEntDetailRialFee Decimal(34,18)=0, 
	@Mdt_InvEntDetailRegTime DateTime=0,  
	@Num_InvEntDetailGdsAmount Decimal(34,18)=0,  
	@Num_InvEntDetailGdsAmount2 Decimal(34,18)=0,
	@Num_InvEntDtGdsAmt2Coef Decimal(34,18)=0,  
	@Num_InvEntDetailGdsAmount3 Decimal(34,18)=0,
	@Num_TransportCostFee Decimal(34,18)=0,
	@Num_TaxFee Decimal(34,18)=0,
	@Num_VaredehRialiAmt Decimal(34,18)=0,
	@Num_Serial Decimal(21,0)=0, 
	@SiPubPersonsSpec Numeric=Null,  
	@SiSalInvoice_Hd numeric=null,
	@SiInvBuyReq_Dt numeric=null, 
	@RealDimCol1 Decimal(34,18)=0, 
	@RealDimCol2 Decimal(34,18)=0, 
	@RealDimCol3 Decimal(34,18)=0, 
	@RealDimCol4 Decimal(34,18)=0, 
	@RealDimCol5 Decimal(34,18)=0, 
	@RealDimCol6 Decimal(34,18)=0, 
	@OptDimCol1 Decimal(34,18)=0, 
	@OptDimCol2 Decimal(34,18)=0, 
	@OptDimCol3 Decimal(34,18)=0, 
	@OptDimCol4 Decimal(34,18)=0, 
	@OptDimCol5 Decimal(34,18)=0, 
	@OptDimCol6 Decimal(34,18)=0, 
	@Des_StoreName varchar(1000)='',
	@StmInvEntrance_Dt TimeStamp=0,  
	@SiUser Numeric,  
	@FlgInsUpdDel SmallInt  
) As  

if @SiPubPersonsSpec=0 Set @SiPubPersonsSpec=null

If @FlgInsUpdDel=0  
Begin  
 declare
	@SumVaredeh numeric,
	@SiInventory numeric,
	@SiSaler numeric

Set @Cod_invEntDetailCode = '1'

if exists(
SELECT Cod_invEntDetailCode
FROM dbo.Tss_InvEntrance_Dt 
WHERE (SiInvEntrance_Hd = @SiInvEntrance_Hd) and (Cod_invEntDetailCode<>'')
)
SELECT @Cod_invEntDetailCode=IsNull(MAX(convert(numeric,Cod_invEntDetailCode)),0)+1 
FROM dbo.Tss_InvEntrance_Dt 
WHERE (SiInvEntrance_Hd = @SiInvEntrance_Hd) and (Cod_invEntDetailCode<>'')
--else
--Set @Cod_invEntDetailCode = '1'

 Set @Mdt_InvEntDetailRegTime=GetDate()  

 Insert Into dbo.Tss_InvEntrance_Dt  
 (  
	SiPubGoods,  
	SiInvEntrance_Hd,  
	Cod_invEntDetailCode,  
	Sta_InvEntUsedUnit,  
	Des_InvEntDetailDesc,  
	Num_InvEntDetailRialFee,  
	Num_InvEntDetailGdsAmount,
	Num_InvEntDetailGdsAmount2,  
	Num_InvEntDtGdsAmt2Coef,
	Num_InvEntDetailGdsAmount3,
	Num_TransportCostFee,
	Num_TaxFee,
	Num_Serial,
	SiPubPersonsSpec,
	SiSalInvoice_Hd,
	Mdt_InvEntDetailRegTime,
	SiInvBuyReq_Dt,
	RealDimCol1, 
	RealDimCol2, 
	RealDimCol3, 
	RealDimCol4, 
	RealDimCol5, 
	RealDimCol6, 
	OptDimCol1, 
	OptDimCol2, 
	OptDimCol3, 
	OptDimCol4, 
	OptDimCol5, 
	OptDimCol6, 
	Des_StoreName,
	Num_VaredehRialiAmt
 )  
 Values  
 (  
	@SiPubGoods,  
	@SiInvEntrance_Hd,  
	@Cod_invEntDetailCode,  
	@Sta_InvEntUsedUnit,  
	@Des_InvEntDetailDesc,  
	@Num_InvEntDetailRialFee,  
	@Num_InvEntDetailGdsAmount,  
	@Num_InvEntDetailGdsAmount2,  
	@Num_InvEntDtGdsAmt2Coef,
	@Num_InvEntDetailGdsAmount3,
	@Num_TransportCostFee,
	@Num_TaxFee,
	@Num_Serial,
	@SiPubPersonsSpec,
	@SiSalInvoice_Hd,
	@Mdt_InvEntDetailRegTime,
	@SiInvBuyReq_Dt,
	@RealDimCol1, 
	@RealDimCol2, 
	@RealDimCol3, 
	@RealDimCol4, 
	@RealDimCol5, 
	@RealDimCol6, 
	@OptDimCol1, 
	@OptDimCol2, 
	@OptDimCol3, 
	@OptDimCol4, 
	@OptDimCol5, 
	@OptDimCol6,
	@Des_StoreName,
	(round(((isnull(@Num_InvEntDetailRialFee,0) + isnull(@Num_TransportCostFee,0) + isnull(@Num_TaxFee,0)) * @Num_InvEntDetailGdsAmount),0))
 )  
 Set @SiInvEntrance_Dt=Scope_Identity()  
 If IsNull(@SiInvEntrance_Dt,0)=0  
 Begin  
  Set @SiInvEntrance_Dt=0  
  Set @Err_Code=400  
  Return  
 End

-- If IsNull(@SiInvEntrance_Dt,0)>0
--	Exec dbo.Tss_StdUpdateTabelLog @SiUser, 'Tss_InvEntrance_Dt', @SiInvEntrance_Dt, 'SiInvEntrance_Dt', @FlgInsUpdDel 

	SELECT @SiInventory=Tss_InvEntrance_Hd.SiInvInventory
	FROM Tss_InvEntrance_Dt INNER JOIN Tss_InvEntrance_Hd ON Tss_InvEntrance_Dt.SiInvEntrance_Hd = Tss_InvEntrance_Hd.SiInvEntrance_Hd
	WHERE (Tss_InvEntrance_Dt.SiInvEntrance_Dt = @SiInvEntrance_Dt)
	
	SELECT @SiSaler=SiPubPersonsSpec FROM Tss_InvEntrance_Hd WHERE (SiInvEntrance_Hd = @SiInvEntrance_Hd)

	if @SiInventory = 12
	begin
		SELECT @SumVaredeh=isnull(SUM(Num_InvEntDetailGdsAmount),0)
		FROM Tss_InvEntrance_Dt
		GROUP BY SiInvEntrance_Hd
		HAVING (SiInvEntrance_Hd IN (SELECT SiInvEntrance_Hd FROM Tss_InvEntrance_Dt WHERE (SiInvEntrance_Dt = @SiInvEntrance_Dt))) 
		update dbo.Tss_InvEntrance_Hd set Num_BasculeDiff = isnull(Num_FactoryBascule,0)-@SumVaredeh where SiInvEntrance_Hd = @SiInvEntrance_Hd
		update dbo.Tss_InvEntrance_dt set SiPubPersonsSpec = @SiSaler where SiInvEntrance_Dt=@SiInvEntrance_Dt
		update dbo.Tss_InvEntrance_dt set Num_InvEntDetailGdsAmount2 = 1 where SiInvEntrance_Dt=@SiInvEntrance_Dt
	end
End  

If @FlgInsUpdDel=1  
Begin  
 Set @Err_Code=0  
 If Exists  
 (  
 Select StmInvEntrance_Dt From dbo.Tss_InvEntrance_Dt  
 Where (SiInvEntrance_Dt=@SiInvEntrance_Dt) And (StmInvEntrance_Dt=@StmInvEntrance_Dt)  
 )  
 Begin  
-----------s
	Declare @Amount_Old Decimal(30,4),@Amount_Def Decimal(30,4)
	Select @Amount_Old=Num_InvEntDetailGdsAmount From dbo.Tss_InvEntrance_Dt
	Where  SiInvEntrance_Dt=@SiInvEntrance_Dt 		
-----------e
  Update dbo.Tss_InvEntrance_Dt Set  
	SiPubGoods=@SiPubGoods,  
	Sta_InvEntUsedUnit=@Sta_InvEntUsedUnit,  
	Cod_invEntDetailCode=@Cod_invEntDetailCode,
	Des_InvEntDetailDesc=@Des_InvEntDetailDesc,  
	Num_InvEntDetailRialFee=@Num_InvEntDetailRialFee,  
	Num_InvEntDetailGdsAmount=@Num_InvEntDetailGdsAmount,  
	Num_InvEntDetailGdsAmount2=@Num_InvEntDetailGdsAmount2,  
	Num_InvEntDtGdsAmt2Coef=@Num_InvEntDtGdsAmt2Coef,
	Num_InvEntDetailGdsAmount3=@Num_InvEntDetailGdsAmount3,
	Num_TransportCostFee=@Num_TransportCostFee,
	Num_TaxFee=@Num_TaxFee,
	Num_Serial=@Num_Serial,
	SiPubPersonsSpec=@SiPubPersonsSpec,
	SiSalInvoice_Hd=@SiSalInvoice_Hd,
	SiInvBuyReq_Dt=@SiInvBuyReq_Dt,
	RealDimCol1=@RealDimCol1, 
	RealDimCol2=@RealDimCol2, 
	RealDimCol3=@RealDimCol3, 
	RealDimCol4=@RealDimCol4, 
	RealDimCol5=@RealDimCol5, 
	RealDimCol6=@RealDimCol6, 
	OptDimCol1=@OptDimCol1, 
	OptDimCol2=@OptDimCol2, 
	OptDimCol3=@OptDimCol3, 
	OptDimCol4=@OptDimCol4, 
	OptDimCol5=@OptDimCol5, 
	OptDimCol6=@OptDimCol6, 
	Des_StoreName=@Des_StoreName,
	Num_VaredehRialiAmt=(round(((isnull(@Num_InvEntDetailRialFee,0) + isnull(@Num_TransportCostFee,0) + isnull(@Num_TaxFee,0)) * @Num_InvEntDetailGdsAmount),0))
  Where (SiInvEntrance_Dt=@SiInvEntrance_Dt)  

--	Exec dbo.Tss_StdUpdateTabelLog @SiUser, 'Tss_InvEntrance_Dt', @SiInvEntrance_Dt, 'SiInvEntrance_Dt', @FlgInsUpdDel 

	SELECT @SiInventory=Tss_InvEntrance_Hd.SiInvInventory
	FROM Tss_InvEntrance_Dt INNER JOIN Tss_InvEntrance_Hd ON Tss_InvEntrance_Dt.SiInvEntrance_Hd = Tss_InvEntrance_Hd.SiInvEntrance_Hd
	WHERE (Tss_InvEntrance_Dt.SiInvEntrance_Dt = @SiInvEntrance_Dt)
	if @SiInventory = 12
	begin
		SELECT @SumVaredeh=isnull(SUM(Num_InvEntDetailGdsAmount),0)
		FROM Tss_InvEntrance_Dt
		GROUP BY SiInvEntrance_Hd
		HAVING (SiInvEntrance_Hd IN (SELECT SiInvEntrance_Hd FROM Tss_InvEntrance_Dt WHERE (SiInvEntrance_Dt = @SiInvEntrance_Dt))) 
		update dbo.Tss_InvEntrance_Hd set Num_BasculeDiff = isnull(Num_FactoryBascule,0)-@SumVaredeh where SiInvEntrance_Hd = @SiInvEntrance_Hd
	end
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
 If Exists  
 (  
 Select StmInvEntrance_Dt From dbo.Tss_InvEntrance_Dt  
 Where (SiInvEntrance_Dt=@SiInvEntrance_Dt) And (StmInvEntrance_Dt=@StmInvEntrance_Dt)  
 )  
 Begin  
	SELECT @SiInventory=Tss_InvEntrance_Hd.SiInvInventory
	FROM Tss_InvEntrance_Dt INNER JOIN Tss_InvEntrance_Hd ON Tss_InvEntrance_Dt.SiInvEntrance_Hd = Tss_InvEntrance_Hd.SiInvEntrance_Hd
	WHERE (Tss_InvEntrance_Dt.SiInvEntrance_Dt = @SiInvEntrance_Dt)
	if @SiInventory = 12
	begin
		SELECT 
			@SumVaredeh=isnull(SUM(Num_InvEntDetailGdsAmount)-(SELECT Num_InvEntDetailGdsAmount FROM Tss_InvEntrance_Dt WHERE (SiInvEntrance_Dt = @SiInvEntrance_Dt)),0)
		FROM Tss_InvEntrance_Dt
		GROUP BY SiInvEntrance_Hd
		HAVING (SiInvEntrance_Hd IN (SELECT SiInvEntrance_Hd FROM Tss_InvEntrance_Dt WHERE (SiInvEntrance_Dt = @SiInvEntrance_Dt))) 
		update dbo.Tss_InvEntrance_Hd set Num_BasculeDiff = isnull(Num_FactoryBascule,0)-@SumVaredeh 
		where SiInvEntrance_Hd in (SELECT SiInvEntrance_Hd FROM Tss_InvEntrance_Dt WHERE (SiInvEntrance_Dt = @SiInvEntrance_Dt))
	end
	Delete From dbo.Tss_InvEntrance_Dt  
	Where (SiInvEntrance_Dt=@SiInvEntrance_Dt)  
	Set @Err_Code=@@Error  
	If @Err_Code<>0  
	Set @Err_Code=4000  
 End  
 Else  
  Set @Err_Code=4001 
-- Return  
End

GO

alter Procedure Tss_InvCheckMojForSerial
(
	@Num_Serial varchar(50)='6423310282',
	@Res smallint OutPut,
	@SiPubGoods numeric OutPut,
	@Cod_PubGoodsCode varchar(50) OutPut, 
	@Des_PubGoodsDesc varchar(500) OutPut,
	@Num_InvEntDetailGdsAmount numeric OutPut,
	@Cod_InvEntHeaderCode varchar(50) OutPut
)
as
/*exec dbo.Tss_InvCheckMojForSerial
	'3015480017',
	0,
	0,
	'', 
	'',
	0,
	''
*/
Declare
	@Num_InvEntDetailGdsAmount2 numeric,
	@Num_InvExtDetailGdsAmount numeric,
	@Num_InvExtDetailGdsAmount2 numeric,
	@DateNow varchar(10),
	@SaleMaliStartDate varchar(10),
	@Year int

SELECT @DateNow =	dbo.Tss_StdMildi2ShamsiUdf(getdate())

Set @Year = convert(int,left(@DateNow,4)) ---1

Set @SaleMaliStartDate = convert(char(4),@Year)+'/01/01'

Set @Num_InvEntDetailGdsAmount = 0

SELECT  Top 1   
	@SiPubGoods = Tss_InvEntrance_Dt.SiPubGoods,
	@Num_InvEntDetailGdsAmount = sum(Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount)
FROM         
	Tss_InvEntrance_Dt INNER JOIN
   Tss_InvEntrance_Hd ON Tss_InvEntrance_Dt.SiInvEntrance_Hd = Tss_InvEntrance_Hd.SiInvEntrance_Hd
WHERE     
	(Num_Serial = convert(decimal(21,0),@Num_Serial)) And
	(Tss_InvEntrance_Hd.Dat_InvEnterDate between @SaleMaliStartDate and @DateNow)
GROUP BY 
	Tss_InvEntrance_Dt.SiPubGoods

Set @Num_InvExtDetailGdsAmount = 0
Set @Num_InvExtDetailGdsAmount2 = 0

SELECT     
	@Num_InvExtDetailGdsAmount  = sum(IsNull(Num_InvExtDetailGdsAmount,0)),
	@Num_InvExtDetailGdsAmount2 = sum(IsNull(Num_InvExtDetailGdsAmount2,0))
FROM         
	Tss_InvOutGo_Dt INNER JOIN
	Tss_InvOutGo_Hd ON Tss_InvOutGo_Dt.SiInvOutGo_Hd = Tss_InvOutGo_Hd.SiInvOutGo_Hd
WHERE     
	(Tss_InvOutGo_Dt.SiPubGoods = @SiPubGoods) AND 
	(Tss_InvOutGo_Dt.Num_Serial = convert(decimal(21,0),@Num_Serial)) AND 
	(Tss_InvOutGo_Hd.Dat_InvExitDate between @SaleMaliStartDate and @DateNow)
GROUP BY 
	Tss_InvOutGo_Dt.SiPubGoods

SELECT     
	@Cod_PubGoodsCode = Cod_PubGoodsCode, 
	@Des_PubGoodsDesc = Des_PubGoodsDesc
FROM         
	Tss_PubGoods
WHERE     
	(SiPubGoods = @SiPubGoods)


if Not Exists (SELECT SiPubGoods FROM Tss_InvEntrance_Dt WHERE (Num_Serial = convert(decimal(21,0),@Num_Serial)))
	Set @Res = 0
Else
IF isnull(@Num_InvEntDetailGdsAmount,0) - isnull(@Num_InvExtDetailGdsAmount,0) = 0 
	Set @Res = 1
Else
	Set @Res = 2

set @Num_InvEntDetailGdsAmount = isnull(@Num_InvEntDetailGdsAmount,0) - isnull(@Num_InvExtDetailGdsAmount,0)

--Select @SiPubGoods as SiPubGoods, @Res as Res, @Cod_PubGoodsCode as Cod_PubGoodsCode, @Des_PubGoodsDesc as Des_PubGoodsDesc, @Num_InvEntDetailGdsAmount as Num_InvEntDetailGdsAmount

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

alter PROCEDURE Tss_InvAsnadRep
(
    @SiSanad VARCHAR(8000) = '',
    @SiAnbar VARCHAR(8000) = '',
    @StDate VARCHAR(10) = '1404/04/01',
    @EnDate VARCHAR(10) = '1404/04/01',
    @SortFlag SMALLINT = 0,
    @SiGds VARCHAR(8000) = '',
    @SiPerson NUMERIC = NULL,
    @InternalWhere VARCHAR(8000) = '',
    @Where VARCHAR(8000) = '',
    @Order VARCHAR(8000) = '',
    @SiUser NUMERIC = 1
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET ARITHABORT ON;
    SET CONCAT_NULL_YIELDS_NULL ON;
    SET ANSI_NULLS ON;
    SET ANSI_NULL_DFLT_ON ON;
    SET ANSI_PADDING ON;
    SET ANSI_WARNINGS ON;
    SET QUOTED_IDENTIFIER ON;

    -- Prepare WHERE and ORDER clauses
    IF @InternalWhere <> '' SET @InternalWhere = ' WHERE ' + @InternalWhere;
    
    IF @Where <> ''
        SET @Where = ' WHERE ' + @Where;
    ELSE
        SET @Where = ' WHERE SiInvInventory IN (SELECT SiInvInventory FROM Tss_InvInventoryToPerson WHERE SiPubPersonsSpec = ' + CONVERT(VARCHAR(50), @SiUser) + ')';

    IF @Order <> ''
        SET @Order = ' ORDER BY ' + @Order;
    ELSE
        SET @Order = ' ORDER BY Dat_InvExitDate';

    DECLARE 
        @SqlTxt VARCHAR(8000),
        @Sta_PubPersonsGroup SMALLINT,
        @Branch SMALLINT,
        @IsInvAdmin SMALLINT;

    -- Check if user is in InvAdmin group
    SELECT @IsInvAdmin = dbo.Tss_StdFindIfUserIsInGroup(@SiUser, 'InvAdmin');

    -- Get user's group status
    SELECT @Sta_PubPersonsGroup = Sta_PubPersonsGroup
    FROM Tss_PubPersonsSpec
    WHERE SiPubPersonsSpec = @SiUser;

    SET @Branch = CASE WHEN @Sta_PubPersonsGroup = 8 THEN 1 ELSE 0 END;

    -- Drop temp table if exists
    IF OBJECT_ID('tempdb..##InvAsnadRepTemp') IS NOT NULL
        DROP TABLE ##InvAsnadRepTemp;

    -- Build main query
    SET @SqlTxt = '
    SELECT 
        Tss_InvOutGo_Dt.SiInvOutGo_Hd, 
        Tss_InvOutGo_Dt.SiInvOutGo_Dt, 
        Tss_PubGoods.SiPubGoods, 
        Tss_InvOutGo_Hd.SiPubCustomCodes, 
        Tss_InvOutGo_Hd.Des_InvExtHeaderDesc, 
        Tss_InvInventory.SiInvInventory, 
        Tss_PubGoods.Cod_PubGoodsCode, 
        Tss_PubGoods.Des_PubGoodsDesc, 
        Tss_InvInventory.Cod_InvInventoryCode, 
        Tss_InvInventory.Sta_InvType, 
        Tss_InvInventory.Des_InvInventoryDesc,
        Tss_PubCustomCodes.Cod_CustomCodesCode, 
        Tss_PubCustomCodes.Des_CustomCodesDesc, 
        Tss_InvOutGo_Dt.Num_InvExtDetailGdsAmount,
        CASE 
            WHEN ISNULL(Tss_InvOutGo_Dt.SiSalInvoice_Hd, 0) > 0 THEN 
                ROUND(Tss_InvOutGo_Dt.Num_InvExtDetailGdsAmount * Tss_InvOutGo_Dt.Num_Gramage / 1000, 0)
            ELSE Tss_InvOutGo_Dt.Num_InvExtDetailGdsAmount2 
        END AS Num_InvExtDetailGdsAmount2,
        Tss_InvOutGo_Hd.Cod_InvExtHeaderCode, 
        Tss_InvOutGo_Hd.Dat_InvExitDate, 
        Tss_PubUnitSpecs.Des_PubUnitDesc, 
        Tss_PubUnitSpecs_1.Des_PubUnitDesc AS VahedeSanjeshe2, 
        Tss_InvOutGo_Dt.Num_InvExtDtGdsAmt2Coef, 
        Tss_PubPersonsViw.Des_FullName, 
        Tss_PubCostCenter_1.SiPubCostCenter, 
        Tss_PubCostCenter_1.Cod_CostCenterCode, 
        Tss_PubCostCenter_1.Des_CostCenterName, 
        Tss_InvOutGo_Dt.Num_SaderehRialiAmt, 
        Tss_InvOutGo_Dt.Num_InvExtDetailRialFee, 
        Tss_InvOutGo_Dt.Num_Serial, 
        (SELECT TOP 1 Tss_PubPersonsViw.Des_FullName
         FROM Tss_InvEntrance_Dt 
         INNER JOIN Tss_InvEntrance_Hd ON Tss_InvEntrance_Dt.SiInvEntrance_Hd = Tss_InvEntrance_Hd.SiInvEntrance_Hd 
         INNER JOIN Tss_PubPersonsViw ON Tss_InvEntrance_Hd.SiPubPersonsSpec = Tss_PubPersonsViw.SiPubPersonsSpec
         WHERE Tss_InvEntrance_Dt.Num_Serial = Tss_InvOutGo_Dt.Num_Serial) AS Producer,
        Tss_PubSubLocations.Cod_SubLocCode, 
        Tss_PubSubLocations.Des_SubLocName, 
        Tss_InvOutGo_Dt.SiSaderehVchDt, 
        Tss_AccVoucher_Dt.SiAccVoucher_Hd,
        costFather.Cod_CostCenterCode AS CostCenterCodeF, 
        costFather.Des_CostCenterName AS CostCenterNameF, 
        Tss_SalInvoice_Hd.Cod_SaleAgreement2, 
        Tss_SalInvoice_Hd.Des_SaleAgreementDesc, 
        Tss_SalFactorRespect_Hd.Dat_FactRespRegDate, 
        Tss_SalFactorRespect_Hd.Cod_FactRespCode, 
        Tss_InvOutGo_Hd.Sta_InvOutBranch, 
        RelatedSaler.Cod_PubPersonCode AS CodRelatedSaler, 
        RelatedSaler.Des_FullName AS DesRelatedSaler, 
        Cust.SiPerRelatedSaler, 
        Tss_InvOutGo_Dt.Des_InvExtDetailDesc, 
        Tss_InvOutGo_Hd.Sta_OutToAcc, 
        Tss_InvOutGo_Hd.Dat_OutToAccDate,
        Tss_InvOutGo_Hd.Tss_InvOutGo_HdRegTime, 
        Tss_InvOutGo_Hd.Tss_InvOutGo_HdEditTime, 
        Tss_InvOutGo_Hd.Tss_InvOutGo_HdRegisterer, 
        Tss_InvOutGo_Hd.Tss_InvOutGo_HdEditor, 
        Tss_InvOutGo_Dt.Tss_InvOutGo_DtRegTime, 
        Tss_InvOutGo_Dt.Tss_InvOutGo_DtEditTime, 
        Tss_InvOutGo_Dt.Tss_InvOutGo_DtRegisterer, 
        Tss_InvOutGo_Dt.Tss_InvOutGo_DtEditor,
        Tss_InvOutGo_Dt.Num_RuptureNo, 
        Tss_InvOutGo_Dt.Num_RoleEndWeight,
        Tss_InvOutGo_Dt.Sta_invExtDetailUnitSpec,
        Tss_InvOutGo_Hd.Sta_OutToSection, 
        Tss_PubPersonsViw.Cod_PubPersonCode AS GirandehCode, 
        Tss_PubPersonsViw.Des_FullName AS GirandehDesc,
        Case 
        when Tss_InvInventory.Sta_InvType = 0 then
            ROUND(dbo.Tss_SalFindGdsGramage(Tss_PubGoods.SiPubGoods) * Tss_InvOutGo_Dt.Num_InvExtDetailGdsAmount / 1000, 0) 
        when Tss_InvInventory.Sta_InvType = 6 then
            ROUND(dbo.Tss_PrcFindGdsTheoreiticalGramage(Tss_PubGoods.SiPubGoods,'''') * Tss_InvOutGo_Dt.Num_InvExtDetailGdsAmount / 1000, 0) 
        End AS SaderehWeight, 
        Tss_PubCustomCodesViw.Cod_CustomCodesCode BaseContMazCode, 
        Tss_PubCustomCodesViw.Des_CustomCodesDesc BaseContMazDesc
    FROM            
        Tss_PubUnitSpecs AS Tss_PubUnitSpecs_1 RIGHT OUTER JOIN
        Tss_PubUnitSpecs RIGHT OUTER JOIN
        Tss_PubSubLocations RIGHT OUTER JOIN
        Tss_PubCustomCodes RIGHT OUTER JOIN
        Tss_SalFactorRespect_Hd INNER JOIN
        Tss_SalFactorRespect_Dt ON Tss_SalFactorRespect_Hd.SiSalFactorRespect_Hd = Tss_SalFactorRespect_Dt.SiSalFactorRespect_Hd RIGHT OUTER JOIN
        Tss_SalInvoice_Hd INNER JOIN
        Tss_PubPersonsViw AS Cust ON Tss_SalInvoice_Hd.SiPubPersonsSpec = Cust.SiPubPersonsSpec INNER JOIN
        Tss_PubCustomCodesViw ON Tss_SalInvoice_Hd.SiPubCustomCodes = Tss_PubCustomCodesViw.SiPubCustomCodes RIGHT OUTER JOIN
        Tss_InvOutGo_Dt INNER JOIN
        Tss_InvOutGo_Hd ON Tss_InvOutGo_Dt.SiInvOutGo_Hd = Tss_InvOutGo_Hd.SiInvOutGo_Hd ON Tss_SalInvoice_Hd.SiSalInvoice_Hd = Tss_InvOutGo_Dt.SiSalInvoice_Hd ON 
        Tss_SalFactorRespect_Dt.SiInvEntrance_Dt = Tss_InvOutGo_Dt.SiInvOutGo_Dt LEFT OUTER JOIN
        Tss_AccVoucher_Dt ON Tss_InvOutGo_Dt.SiSaderehVchDt = Tss_AccVoucher_Dt.SiAccVoucher_Dt LEFT OUTER JOIN
        Tss_PubGoods ON Tss_InvOutGo_Dt.SiPubGoods = Tss_PubGoods.SiPubGoods LEFT OUTER JOIN
        Tss_PubCostCenter AS costFather RIGHT OUTER JOIN
        Tss_PubCostCenter AS Tss_PubCostCenter_1 ON costFather.SiPubCostCenter = Tss_PubCostCenter_1.SiPubCostCenterFather ON Tss_InvOutGo_Dt.SiPubCostCenter = Tss_PubCostCenter_1.SiPubCostCenter ON 
        Tss_PubCustomCodes.SiPubCustomCodes = Tss_InvOutGo_Hd.SiPubCustomCodes ON Tss_PubSubLocations.SiPubSubLocations = Tss_InvOutGo_Hd.SiPubSubLocations LEFT OUTER JOIN
        Tss_InvInventory ON Tss_InvOutGo_Hd.SiInvInventory = Tss_InvInventory.SiInvInventory LEFT OUTER JOIN
        Tss_PubPersonsViw ON Tss_InvOutGo_Dt.SiPubPersonsSpec = Tss_PubPersonsViw.SiPubPersonsSpec ON Tss_PubUnitSpecs.SiPubUnitSpecs = Tss_PubGoods.SiPubUnitSpecs1 ON 
        Tss_PubUnitSpecs_1.SiPubUnitSpecs = Tss_PubGoods.SiPubUnitSpecs2 LEFT OUTER JOIN
        Tss_PubPersonsViw AS RelatedSaler ON Cust.SiPerRelatedSaler = RelatedSaler.SiPubPersonsSpec';

    -- Build conditions based on parameters
    DECLARE @Conditions VARCHAR(8000) = '';

    -- Date condition
    SET @Conditions = 'Dat_InvExitDate BETWEEN ''' + @StDate + ''' AND ''' + @EnDate + '''';

    -- Branch condition for non-admin users
    IF (@SiUser <> 1) AND (@IsInvAdmin <> 1)
        SET @Conditions = @Conditions + ' AND (Tss_InvOutGo_Hd.Sta_InvOutBranch = ' + CONVERT(VARCHAR, @Branch) + ')';

    -- Add filter conditions based on parameters
    IF @SiSanad <> '' 
        SET @Conditions = @Conditions + ' AND (Tss_PubCustomCodes.SiPubCustomCodes IN (SELECT SiSel FROM dbo.Tss_StdStringSiFindUdf(''' + @SiSanad + ''')))';

    IF @SiAnbar <> '' 
        SET @Conditions = @Conditions + ' AND (Tss_InvInventory.SiInvInventory IN (SELECT SiSel FROM dbo.Tss_StdStringSiFindUdf(''' + @SiAnbar + ''')))';

    IF @SiGds <> '' 
        SET @Conditions = @Conditions + ' AND (Tss_PubGoods.SiPubGoods IN (SELECT SiSel FROM dbo.Tss_StdStringSiFindUdf(''' + @SiGds + ''')))';

    IF ISNULL(@SiPerson, 0) > 0 
        SET @Conditions = @Conditions + ' AND (Tss_InvOutGo_Dt.SiPubPersonsSpec = ' + CONVERT(VARCHAR, @SiPerson) + ')';

    -- Add WHERE conditions if any
    IF @Conditions <> ''
        SET @SqlTxt = @SqlTxt + ' WHERE ' + @Conditions;

    -- Final query construction
    SET @SqlTxt = 'SELECT * INTO ##InvAsnadRepTemp FROM (SELECT * FROM (' + @SqlTxt + ') Calc ' + 
                  @InternalWhere + ') CalcSel ' + @Where + @Order;

    -- Execute dynamic SQL
    EXEC(@SqlTxt);

    -- Final selection from temp table
    EXEC('
    SELECT 
        ROW_NUMBER() OVER (ORDER BY Dat_InvExitDate, SiInvOutGo_Hd, SiInvOutGo_Dt) AS RowNumber,
        SiInvOutGo_Hd, 
        SiInvOutGo_Dt, 
        SiPubGoods, 
        SiPubCustomCodes, 
        Des_InvExtHeaderDesc, 
        SiInvInventory, 
        Cod_PubGoodsCode, 
        Des_PubGoodsDesc, 
        Cod_InvInventoryCode, 
        Des_InvInventoryDesc,
        Cod_CustomCodesCode, 
        Des_CustomCodesDesc, 
        Num_InvExtDetailGdsAmount, 
        Num_InvExtDetailGdsAmount2, 
        Cod_InvExtHeaderCode, 
        Dat_InvExitDate, 
        Des_PubUnitDesc, 
        VahedeSanjeshe2, 
        Num_InvExtDtGdsAmt2Coef, 
        Des_FullName, 
        SiPubCostCenter, 
        Cod_CostCenterCode, 
        Des_CostCenterName, 
        Num_SaderehRialiAmt, 
        Num_InvExtDetailRialFee, 
        0.00 AS Num_InvExtDetailRialFee2, 
        Num_Serial, 
        Cod_SubLocCode, 
        Des_SubLocName, 
        SiSaderehVchDt, 
        SiAccVoucher_Hd,
        CostCenterCodeF, 
        CostCenterNameF, 
        Cod_SaleAgreement2, 
        Des_SaleAgreementDesc, 
        Dat_FactRespRegDate, 
        Cod_FactRespCode, 
        Sta_InvOutBranch, 
        CodRelatedSaler, 
        DesRelatedSaler, 
        SiPerRelatedSaler, 
        Des_InvExtDetailDesc, 
        Sta_OutToAcc, 
        Dat_OutToAccDate,
        Num_RuptureNo, 
        Num_RoleEndWeight,
        CASE 
            WHEN Sta_InvType = 1 
                 THEN ISNULL(dbo.PubFindGdsTechSpec(SiPubGoods, 1298), '''')
            WHEN Sta_InvType = 0 
                 THEN CAST(dbo.Tss_PrcFindGdsInvoiceGramage(SiPubGoods, SiInvOutGo_Dt) AS varchar(50))
            WHEN Sta_InvType = 6 
                 THEN CAST(dbo.Tss_PrcFindGdsTheoreiticalGramage(SiPubGoods, '''') AS varchar(50))
            ELSE ''0''
        END AS Gramage,

        Producer,
        ISNULL(dbo.PubFindGdsTechSpec(SiPubGoods, 1299), '''') AS Arz,
        ISNULL(dbo.PubFindGdsTechSpec(SiPubGoods, 1665), '''') AS Jens,
        dbo.Tss_StdStaLabelsUdf(1092, Sta_invExtDetailUnitSpec) AS Expr1, 
        dbo.Tss_StdStaLabelsUdf(1093, Sta_OutToSection) AS DesSta_OutToSection, 
        dbo.Tss_PubFindGoodsSpecs(SiPubGoods, 0) AS TipType, 
        dbo.Tss_PubFindGoodsSpecs(SiPubGoods, 1) AS TipDes, 
        dbo.Tss_PubFindGoodsSpecs(SiPubGoods, 2) AS JensGdsCont, 
        Num_InvExtDetailGdsAmount * dbo.Tss_PubFindGoodsSpecs(SiPubGoods, 3) AS Area,
        GirandehCode, 
        GirandehDesc,
        SaderehWeight,
        BaseContMazCode, 
        BaseContMazDesc
    FROM ##InvAsnadRepTemp
    ORDER BY Dat_InvExitDate
    ');

    -- Clean up
    IF OBJECT_ID('tempdb..##InvAsnadRepTemp') IS NOT NULL
        DROP TABLE ##InvAsnadRepTemp;
END;

GO

alter proc Tss_InvAsnadVaredehRep
(
	@SiSanad varchar(8000)='',
	@SiAnbar varchar(8000)='13',
	@StDate varchar(10)='1404/11/11',
	@EnDate varchar(10)='1404/11/12',
	@SiGds varchar(8000)='',
	@SiPer varchar(8000)='',
	@SortFlag SmallInt=0,
	@InternalWhere VarChar(8000)='',
	@Where VarChar(8000)='',
	@Order VarChar(8000)='',
	@SiCust varchar(8000)='',
	@SiUser numeric=1
)
AS

Set XACT_ABORT ON

If @InternalWhere<>''   
   Set @InternalWhere=' Where '+@InternalWhere  
If @Where<>''   
   Set @Where=' Where '+@Where 
--Else
--   Set @Where=' Where SiInvInventory in (SELECT SiInvInventory FROM Tss_InvInventoryToPerson WHERE (SiPubPersonsSpec = '+convert(varchar(50),@SiUser)+'))' 
If @Order<>'' 
   Set @Order=' Order By '+@Order
Else
   Set @Order=' Order By Dat_InvEnterDate'

Declare
	@SqlTxt1 nvarchar(max),
	@SqlTxt2 nvarchar(max),
	@Sta_PubPersonsGroup smallint,
	@Branch smallint,
	@IsInvAdmin smallint


Select @IsInvAdmin = dbo.Tss_StdFindIfUserIsInGroup(@SiUser,'InvAdmin')


SELECT     
	@Sta_PubPersonsGroup = Sta_PubPersonsGroup
FROM         
	Tss_PubPersonsSpec
WHERE     
	(SiPubPersonsSpec = @SiUser)

if @Sta_PubPersonsGroup = 8  
	Set @Branch = 1
Else 
	Set @Branch = 0


if exists (SELECT * FROM tempdb.dbo.sysobjects WHERE (name = '##AsnadVaredehRepTemp'))
	   drop table ##AsnadVaredehRepTemp

Set @SqlTxt1 = ' 
SELECT distinct
Tss_InvInventory.Sta_InvType,
Tss_InvEntrance_Dt.SiInvEntrance_Dt, 
Tss_InvEntrance_Hd.SiInvEntrance_Hd, 
Tss_InvEntrance_Hd.Des_HavalehNo, 
Tss_InvEntrance_Hd.Num_FactoryBascule, 
Tss_InvEntrance_Hd.Num_ResidOriginWeight, 
Tss_InvEntrance_Hd.SiPubCustomCodes, 
Tss_InvInventory.SiInvInventory, 
Tss_PubGoods.Cod_PubGoodsCode, 
Tss_PubGoods.SiPubGoods, 
Tss_PubGoods.Des_PubGoodsDesc, 
Tss_InvInventory.Cod_InvInventoryCode, 
Tss_InvInventory.Des_InvInventoryDesc, 
Tss_PubCustomCodes.Cod_CustomCodesCode, 
Tss_PubCustomCodes.Des_CustomCodesDesc, 
Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount2, 
Tss_InvEntrance_Hd.Cod_InvEntHeaderCode, 
Tss_InvEntrance_Hd.Dat_InvEnterDate, 
Tss_InvEntrance_Hd.Cod_InvProvisionalRecieptNo, 
Tss_PubUnitSpecs_1.Des_PubUnitDesc, 
Tss_InvEntrance_Hd.SiPubPersonsSpec, 
DeliveryPers.Des_FullName, 
Tss_PubUnitSpecs_2.Des_PubUnitDesc AS VahedeSanjesh2, 
Tss_InvEntrance_Dt.Num_InvEntDtGdsAmt2Coef, 
Tss_InvEntrance_Dt.Num_InvEntDetailRialFee,
Tss_SalInvoice_Hd.SiPubPersonsSpec as SiCust,
Tss_SalInvoice_Hd.Cod_SaleAgreement2, 
Tss_SalInvoice_Hd.Cod_SaleAgreement, 
Tss_InvEntrance_Dt.Num_Serial, 
Tss_PubSubLocations.SiPubSubLocations, 
Tss_PubSubLocations.Cod_SubLocCode, 
Tss_PubSubLocations.Des_SubLocName, 
Tss_InvEntrance_Dt.SiVchDt, 
Customer.Cod_PubPersonCode CodCust, 
Customer.Des_FullName AS DesCust,
Tss_PurInvoice_Hd.Cod_PurInvoiceSalerCode, 
Tss_PurInvoice_Hd.Dat_PurInvoiceDate, 
Tss_PubPersonsViw.Sta_IsForeign,
Tss_InvEntrance_Hd.Des_VehicleNo, 
Tss_InvEntrance_Dt.Des_InvEntDetailDesc, 
Tss_SalInvoice_Hd.SiSalInvoice_Hd,
Tss_InvEntrance_Dt.Sta_InvEntUsedUnit,
Tss_InvEntrance_Hd.Num_TransportCost,
Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount,
Tss_InvEntrance_Dt.Num_TaxFee,
ISNULL(Tss_InvEntrance_Dt.Num_TransportCostFee, 0) AS Num_TransportCostFee,
Tss_InvEntrance_Dt.Num_VaredehRialiAmt,
Tss_InvEntrance_Dt.Des_StoreName,
Tss_PurInvoice_Dt.SiPurInvoice_Hd,
Tss_PurInvoice_Dt.Cod_PurInvoiceDtCode,
(SELECT        
	TOP 1 Tss_InvOutGo_Hd.Cod_InvExtHeaderCode
FROM            
	Tss_InvOutGo_Dt AS Tss_InvOutGo_Dt_1 INNER JOIN
	Tss_InvOutGo_Hd AS Tss_InvOutGo_Hd_1 ON Tss_InvOutGo_Dt_1.SiInvOutGo_Hd = Tss_InvOutGo_Hd_1.SiInvOutGo_Hd
WHERE        
	(Tss_InvOutGo_Dt_1.SiPubGoods =  Tss_PubGoods.SiPubGoods) and  
	(isnull(Tss_InvOutGo_Dt_1.Num_Serial,0)=isnull(Tss_InvEntrance_Dt.Num_Serial,0))
ORDER BY 
	Tss_InvOutGo_Hd.Dat_InvExitDate DESC) AS OutCode,

(SELECT        
	TOP 1 Tss_InvOutGo_Hd_1.Dat_InvExitDate
FROM            
	Tss_InvOutGo_Dt AS Tss_InvOutGo_Dt_1 INNER JOIN
	Tss_InvOutGo_Hd AS Tss_InvOutGo_Hd_1 ON Tss_InvOutGo_Dt_1.SiInvOutGo_Hd = Tss_InvOutGo_Hd_1.SiInvOutGo_Hd
WHERE        
	(Tss_InvOutGo_Dt_1.SiPubGoods =  Tss_PubGoods.SiPubGoods) and 
	(isnull(Tss_InvOutGo_Dt_1.Num_Serial,0)=isnull(Tss_InvEntrance_Dt.Num_Serial,0))
ORDER BY 
	Tss_InvOutGo_Hd_1.Dat_InvExitDate DESC) AS OutDate,

'

if (dbo.Tss_StdFindSubLoc(0)='Simorgh') 
Set @SqlTxt2=' 
	isnull(Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount*Tss_InvEntrance_Dt.Num_TransportCostFee,0)+
	isnull(Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount*Tss_InvEntrance_Dt.Num_TaxFee,0)+
	isnull(Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount*Tss_InvEntrance_Dt.Num_InvEntDetailRialFee,0) as RowTotalFee,
	Tss_SalFactorRespect_Hd.Cod_FactRespCode, 
	Tss_SalFactorRespect_Hd.Dat_FactRespRegDate, 
	Tss_InvEntrance_Hd.Sta_InvEntBranch, 
	Tss_InvEntrance_Hd.SiOutDeliReceipt, 
	Tss_InvOutGo_Hd.Cod_InvExtHeaderCode,
	Case 
	when Sta_InvType = 0 
		then round(dbo.Tss_SalFindGdsGramage(Tss_PubGoods.SiPubGoods)*Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount/1000,2)
	when Sta_InvType = 6 
		then round(dbo.Tss_PrcFindGdsTheoreiticalGramage(Tss_PubGoods.SiPubGoods,'''')*Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount/1000,2)
--		then round(dbo.Tss_PrcFindGdsTheoreiticalGramage(Tss_PubGoods.SiPubGoods,'''')*dbo.Tss_SalFindGdsArea(Tss_PubGoods.SiPubGoods)*Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount/1000,2)
	else 0
	End as VaredehWeight, 
	Tss_InvBuyReq_Hd.Cod_BuyReqHdCode,
	Tss_InvBuyReq_Hd.Cod_ReqestCode,
	Tss_InvBuyReq_Hd.Des_SalerContCode,
	Tss_PubPersonsViw_1.Cod_PubPersonCode UserCode, 
	Tss_PubPersonsViw_1.Des_FullName UserDesc, 
    Tss_StdLogFileDet.Sta_ActionType, 
	Tss_StdLogFileDet.Mdt_TransDateShamsi, 
	Tss_StdLogFileDet.FindWindowsUser
FROM            Tss_StdLogFileDet INNER JOIN
                         Tss_PubPersonsViw AS Tss_PubPersonsViw_1 ON Tss_StdLogFileDet.SiPubPersonsSpec = Tss_PubPersonsViw_1.SiPubPersonsSpec RIGHT OUTER JOIN
                         Tss_InvEntrance_Dt INNER JOIN
                         Tss_InvEntrance_Hd ON Tss_InvEntrance_Dt.SiInvEntrance_Hd = Tss_InvEntrance_Hd.SiInvEntrance_Hd INNER JOIN
                         Tss_PubSubLocations ON Tss_InvEntrance_Hd.SiPubSubLocations = Tss_PubSubLocations.SiPubSubLocations ON Tss_StdLogFileDet.SiRecord = Tss_InvEntrance_Dt.SiInvEntrance_Dt LEFT OUTER JOIN
                         Tss_InvBuyReq_Hd INNER JOIN
                         Tss_InvBuyReq_Dt ON Tss_InvBuyReq_Hd.SiInvBuyReq_Hd = Tss_InvBuyReq_Dt.SiInvBuyReq_Hd ON Tss_InvEntrance_Dt.SiInvBuyReq_Dt = Tss_InvBuyReq_Dt.SiInvBuyReq_Dt LEFT OUTER JOIN
                         Tss_PubPersonsViw AS Customer INNER JOIN
                         Tss_SalInvoice_Hd ON Customer.SiPubPersonsSpec = Tss_SalInvoice_Hd.SiPubPersonsSpec ON Tss_InvEntrance_Dt.SiSalInvoice_Hd = Tss_SalInvoice_Hd.SiSalInvoice_Hd LEFT OUTER JOIN
                         Tss_InvOutGo_Hd ON Tss_InvEntrance_Hd.SiOutDeliReceipt = Tss_InvOutGo_Hd.SiInvOutGo_Hd LEFT OUTER JOIN
                         Tss_SalFactorRespect_Hd INNER JOIN
                         Tss_SalFactorRespect_Dt ON Tss_SalFactorRespect_Hd.SiSalFactorRespect_Hd = Tss_SalFactorRespect_Dt.SiSalFactorRespect_Hd ON 
                         Tss_InvEntrance_Dt.SiInvEntrance_Dt = Tss_SalFactorRespect_Dt.SiInvEntrance_Dt LEFT OUTER JOIN
                         Tss_PubGoods ON Tss_InvEntrance_Dt.SiPubGoods = Tss_PubGoods.SiPubGoods LEFT OUTER JOIN
                         Tss_PurInvoice_Dt INNER JOIN
                         Tss_PurInvoice_Hd ON Tss_PurInvoice_Dt.SiPurInvoice_Hd = Tss_PurInvoice_Hd.SiPurInvoice_Hd ON Tss_InvEntrance_Dt.SiInvEntrance_Dt = Tss_PurInvoice_Dt.SiInvEntrance_Dt LEFT OUTER JOIN
                         Tss_PubPersonsViw AS DeliveryPers ON Tss_InvEntrance_Dt.SiPubPersonsSpec = DeliveryPers.SiPubPersonsSpec LEFT OUTER JOIN
                         Tss_PubPersonsViw AS Tss_PubPersonsViw ON Tss_InvEntrance_Hd.SiPubPersonsSpec = Tss_PubPersonsViw.SiPubPersonsSpec LEFT OUTER JOIN
           Tss_PubCustomCodes ON Tss_InvEntrance_Hd.SiPubCustomCodes = Tss_PubCustomCodes.SiPubCustomCodes LEFT OUTER JOIN
                         Tss_InvInventory ON Tss_InvEntrance_Hd.SiInvInventory = Tss_InvInventory.SiInvInventory LEFT OUTER JOIN
                         Tss_PubUnitSpecs AS Tss_PubUnitSpecs_2 ON Tss_PubGoods.SiPubUnitSpecs1 = Tss_PubUnitSpecs_2.SiPubUnitSpecs LEFT OUTER JOIN
                         Tss_PubUnitSpecs AS Tss_PubUnitSpecs_1 ON Tss_PubGoods.SiPubUnitSpecs2 = Tss_PubUnitSpecs_1.SiPubUnitSpecs
Where
--		(Tss_InvEntrance_Hd.Sta_InvEntBranch = '+convert(varchar,@Branch)+') and 
		(Dat_InvEnterDate BETWEEN '+''''+@StDate+''''+' AND '+''''+@EnDate+''''+')'

else
Set @SqlTxt2=' 
	isnull(Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount*Tss_InvEntrance_Dt.Num_TransportCostFee,0)+
	isnull(Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount*Tss_InvEntrance_Dt.Num_TaxFee,0)+
	isnull(Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount*Tss_InvEntrance_Dt.Num_InvEntDetailRialFee,0) as RowTotalFee,
	Tss_SalFactorRespect_Hd.Cod_FactRespCode, 
	Tss_SalFactorRespect_Hd.Dat_FactRespRegDate, 
	Tss_InvEntrance_Hd.Sta_InvEntBranch, 
	Tss_InvEntrance_Hd.SiOutDeliReceipt, 
	Tss_InvOutGo_Hd.Cod_InvExtHeaderCode,
	Case 
	when Sta_InvType = 0 
		then round(dbo.Tss_SalFindGdsGramage(Tss_PubGoods.SiPubGoods)*Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount/1000,2)
	when Sta_InvType = 6 
		then round(dbo.Tss_PrcFindGdsTheoreiticalGramage(Tss_PubGoods.SiPubGoods,'''')*Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount/1000,2)
--		then round(dbo.Tss_PrcFindGdsTheoreiticalGramage(Tss_PubGoods.SiPubGoods,'''')*dbo.Tss_SalFindGdsArea(Tss_PubGoods.SiPubGoods)*Tss_InvEntrance_Dt.Num_InvEntDetailGdsAmount/1000,2)
	else 0
	End as VaredehWeight, 
	Tss_InvBuyReq_Hd.Cod_BuyReqHdCode,
	Tss_InvBuyReq_Hd.Cod_ReqestCode,
	Tss_InvBuyReq_Hd.Des_SalerContCode,
	'''' UserCode, 
	'''' UserDesc, 
  --  0.0$ Sta_ActionType, 
	CAST(0 AS INT) AS Sta_ActionType,
	'''' Mdt_TransDateShamsi, 
	'''' FindWindowsUser
FROM            Tss_InvEntrance_Dt INNER JOIN
                  Tss_InvEntrance_Hd ON Tss_InvEntrance_Dt.SiInvEntrance_Hd = Tss_InvEntrance_Hd.SiInvEntrance_Hd INNER JOIN
                  Tss_PubSubLocations ON Tss_InvEntrance_Hd.SiPubSubLocations = Tss_PubSubLocations.SiPubSubLocations LEFT OUTER JOIN
                  Tss_InvBuyReq_Hd INNER JOIN
                  Tss_InvBuyReq_Dt ON Tss_InvBuyReq_Hd.SiInvBuyReq_Hd = Tss_InvBuyReq_Dt.SiInvBuyReq_Hd ON Tss_InvEntrance_Dt.SiInvBuyReq_Dt = Tss_InvBuyReq_Dt.SiInvBuyReq_Dt LEFT OUTER JOIN
                  Tss_PubPersonsViw AS Customer INNER JOIN
                  Tss_SalInvoice_Hd ON Customer.SiPubPersonsSpec = Tss_SalInvoice_Hd.SiPubPersonsSpec ON Tss_InvEntrance_Dt.SiSalInvoice_Hd = Tss_SalInvoice_Hd.SiSalInvoice_Hd LEFT OUTER JOIN
                  Tss_InvOutGo_Hd ON Tss_InvEntrance_Hd.SiOutDeliReceipt = Tss_InvOutGo_Hd.SiInvOutGo_Hd LEFT OUTER JOIN
                  Tss_SalFactorRespect_Hd INNER JOIN
                  Tss_SalFactorRespect_Dt ON Tss_SalFactorRespect_Hd.SiSalFactorRespect_Hd = Tss_SalFactorRespect_Dt.SiSalFactorRespect_Hd ON 
                  Tss_InvEntrance_Dt.SiInvEntrance_Dt = Tss_SalFactorRespect_Dt.SiInvEntrance_Dt LEFT OUTER JOIN
                  Tss_PubGoods ON Tss_InvEntrance_Dt.SiPubGoods = Tss_PubGoods.SiPubGoods LEFT OUTER JOIN
                  Tss_PurInvoice_Dt INNER JOIN
                  Tss_PurInvoice_Hd ON Tss_PurInvoice_Dt.SiPurInvoice_Hd = Tss_PurInvoice_Hd.SiPurInvoice_Hd ON Tss_InvEntrance_Dt.SiInvEntrance_Dt = Tss_PurInvoice_Dt.SiInvEntrance_Dt LEFT OUTER JOIN
                  Tss_PubPersonsViw AS DeliveryPers ON Tss_InvEntrance_Dt.SiPubPersonsSpec = DeliveryPers.SiPubPersonsSpec LEFT OUTER JOIN
                  Tss_PubPersonsViw AS Tss_PubPersonsViw ON Tss_InvEntrance_Hd.SiPubPersonsSpec = Tss_PubPersonsViw.SiPubPersonsSpec LEFT OUTER JOIN
                  Tss_PubCustomCodes ON Tss_InvEntrance_Hd.SiPubCustomCodes = Tss_PubCustomCodes.SiPubCustomCodes LEFT OUTER JOIN
                  Tss_InvInventory ON Tss_InvEntrance_Hd.SiInvInventory = Tss_InvInventory.SiInvInventory LEFT OUTER JOIN
                  Tss_PubUnitSpecs AS Tss_PubUnitSpecs_2 ON Tss_PubGoods.SiPubUnitSpecs1 = Tss_PubUnitSpecs_2.SiPubUnitSpecs LEFT OUTER JOIN
                  Tss_PubUnitSpecs AS Tss_PubUnitSpecs_1 ON Tss_PubGoods.SiPubUnitSpecs2 = Tss_PubUnitSpecs_1.SiPubUnitSpecs
Where
--		(Tss_InvEntrance_Hd.Sta_InvEntBranch = '+convert(varchar,@Branch)+') and 
		(Dat_InvEnterDate BETWEEN '+''''+@StDate+''''+' AND '+''''+@EnDate+''''+')'


if @SiSanad<>''
Set @SqlTxt2 = @SqlTxt2 +' and (Tss_PubCustomCodes.SiPubCustomCodes IN (select sisel from dbo.Tss_StdStringSiFindUdf('+''''+@SiSanad+''''+')))'
if @SiAnbar<>''
Set @SqlTxt2 = @SqlTxt2 +' and (Tss_InvInventory.SiInvInventory IN (select sisel from dbo.Tss_StdStringSiFindUdf('+''''+@SiAnbar+''''+')))'
if @SiGds<>''
Set @SqlTxt2 = @SqlTxt2 +' and (Tss_PubGoods.SiPubGoods in (select sisel from dbo.Tss_StdStringSiFindUdf('+''''+@SiGds+''''+')))'
if @SiPer<>''
Set @SqlTxt2 = @SqlTxt2 +' and (Tss_InvEntrance_Hd.SiPubPersonsSpec in (select sisel from dbo.Tss_StdStringSiFindUdf('+''''+@SiPer+''''+')))'
if @SiCust<>''
Set @SqlTxt2 = @SqlTxt2 +' and (Tss_SalInvoice_Hd.SiPubPersonsSpec in (select sisel from dbo.Tss_StdStringSiFindUdf('+''''+@SiCust+''''+')))'


--print @SqlTxt1
--print @SqlTxt2

Exec(
	'Select distinct * into ##AsnadVaredehRepTemp From  (Select * from
		('+@SqlTxt1 + @SqlTxt2+') Calc '+@InternalWhere +') CalcSel '+ @Where + @Order)

DECLARE @FinalSql nvarchar(max)

SET @FinalSql = '
Select distinct
ROW_NUMBER() OVER(' + 
    CASE 
        WHEN @Order <> '' THEN @Order 
        ELSE 'ORDER BY Dat_InvEnterDate' 
    END + ') as RowNumber,
UserCode, 
UserDesc, 
Sta_ActionType, 
Mdt_TransDateShamsi, 
FindWindowsUser,
SiInvEntrance_Dt, 
SiInvEntrance_Hd, 
Des_HavalehNo, 
Num_FactoryBascule, 
Num_ResidOriginWeight, 
SiPubCustomCodes, 
SiInvInventory, 
Cod_PubGoodsCode, 
SiPubGoods, 
Des_PubGoodsDesc, 
Cod_InvInventoryCode, 
Des_InvInventoryDesc, 
Cod_CustomCodesCode, 
Des_CustomCodesDesc, 
Num_InvEntDetailGdsAmount2, 
Cod_InvEntHeaderCode, 
Dat_InvEnterDate, 
Cod_InvProvisionalRecieptNo, 
Des_PubUnitDesc, 
SiPubPersonsSpec, 
Des_FullName, 
VahedeSanjesh2, 
Num_InvEntDtGdsAmt2Coef, 
Num_InvEntDetailRialFee,
Cod_SaleAgreement2, 
Cod_SaleAgreement, 
Num_Serial, 
SiPubSubLocations, 
Cod_SubLocCode, 
Des_SubLocName, 
SiVchDt, 
CodCust, 
DesCust,
Cod_PurInvoiceSalerCode, 
Dat_PurInvoiceDate, 
Sta_IsForeign,
Des_VehicleNo, 
Des_InvEntDetailDesc, 
Cod_FactRespCode, 
Dat_FactRespRegDate, 
Sta_InvEntBranch, 
SiOutDeliReceipt, 
Cod_InvExtHeaderCode,
dbo.Tss_SalFindGdsArea(SiPubGoods) gdsarea,
SUM(Num_InvEntDetailGdsAmount)*dbo.Tss_SalFindGdsArea(SiPubGoods) Allgdsarea,
Case
when Sta_InvType = 0 then convert(varchar,ISNULL(dbo.Tss_SalFindGdsGramage(SiPubGoods), 0)) 
when (Sta_InvType = 6) or (Sta_InvType = 7) then Convert(varchar,dbo.Tss_PrcFindGdsTheoreiticalGramage(SiPubGoods,''''))
End AS Gramage, 
ISNULL(dbo.PubFindGdsTechSpec(SiPubGoods, 1299), '''') AS Arz, 
ISNULL(dbo.PubFindGdsTechSpec(SiPubGoods, 1665), '''') AS Jens, 
dbo.Tss_SalFindContGoodsLayes(SiPubGoods) GoodsLayer,
dbo.Tss_StdStaLabelsUdf(1092, Sta_InvEntUsedUnit) AS VahedSanjesh, 
SUM(Num_InvEntDetailGdsAmount) AS Num_InvEntDetailGdsAmount, 
ISNULL(Num_TransportCost, 0) AS Num_TransportCostFee, 
Sum(ROUND(ISNULL(Num_InvEntDetailGdsAmount, 0) * ISNULL(Num_InvEntDetailRialFee, 0), 0)) AS RialiRow, 
ROUND(ISNULL(Num_InvEntDetailGdsAmount, 0) * ISNULL(Num_TransportCostFee, 0), 0) AS TransRateRow, 
Sum(ROUND(ISNULL(Num_InvEntDetailGdsAmount, 0) * ISNULL(Num_InvEntDetailRialFee, 0), 0))+ROUND(ISNULL(Num_InvEntDetailGdsAmount, 0) * ISNULL(Num_TransportCostFee, 0), 0) AS RialiRowWithHaml, 
Sum(ROUND(ISNULL(Num_InvEntDetailGdsAmount, 0) * ISNULL(Num_TaxFee, 0), 0)) AS TaxRow, 
SUM(Num_VaredehRialiAmt) as Num_VaredehRialiAmt, 
(SELECT Dat_VhedDate FROM Tss_AccVoucher_Hd WHERE (SiAccVoucher_Hd = SiVchDt)) as Dat_VhedDate , 
case when SiSalInvoice_Hd>0 then
	dbo.Tss_SalFindContSbLoc(SiSalInvoice_Hd) 
Else
	''''
End As ContSubLoc,
OutCode,
OutDate,
Des_StoreName,
RowTotalFee,
VaredehWeight,
Cod_BuyReqHdCode,
dbo.Tss_SalFindGoodsType(SiPubGoods) AS GoodsType,
SiPurInvoice_Hd,
Cod_ReqestCode,
Des_SalerContCode

From
	##AsnadVaredehRepTemp
GROUP BY 
	SiSalInvoice_Hd, 
	SiInvEntrance_Dt, 
	SiInvEntrance_Hd, 
	Des_HavalehNo, 
	Num_FactoryBascule, 
	Num_ResidOriginWeight, 
	SiPubCustomCodes, 
	SiInvInventory, 
	SiPubCustomCodes, 
	Cod_PubGoodsCode, 
	SiPubGoods, 
	Des_PubGoodsDesc, 
	ISNULL(dbo.PubFindGdsTechSpec(SiPubGoods, 1298), ''''), 
	ISNULL(dbo.PubFindGdsTechSpec(SiPubGoods, 1299), ''''), 
	ISNULL(dbo.PubFindGdsTechSpec(SiPubGoods, 1665), ''''), 
	Cod_InvInventoryCode, 
	Des_InvInventoryDesc, 
	Cod_CustomCodesCode, 
	Des_CustomCodesDesc, 
	dbo.Tss_StdStaLabelsUdf(1092, Sta_InvEntUsedUnit), 
	Num_InvEntDetailGdsAmount2, 
	Cod_InvEntHeaderCode, 
	Dat_InvEnterDate, 
	Cod_InvProvisionalRecieptNo, 
	Des_PubUnitDesc, 
	SiPubPersonsSpec, 
	Des_FullName, 
	Num_InvEntDetailRialFee, 
	Des_PubUnitDesc, 
	Num_InvEntDtGdsAmt2Coef, 
	ISNULL(Num_TransportCost, 0), 
	ROUND(ISNULL(Num_InvEntDetailGdsAmount, 0) * ISNULL(Num_InvEntDetailRialFee, 0), 0), ROUND(ISNULL(Num_InvEntDetailGdsAmount, 0) 
	* ISNULL(Num_TransportCostFee, 0), 0), 
	ROUND(ISNULL(Num_InvEntDetailGdsAmount, 0) * ISNULL(Num_TaxFee, 0), 0), 
	Num_VaredehRialiAmt, 
	Cod_SaleAgreement2, 
	Cod_SaleAgreement, 
	Num_Serial, 
	SiPubSubLocations, 
	Cod_SubLocCode, 
	Des_SubLocName, 
	SiVchDt, 
	CodCust, 
	Des_FullName, 
	Cod_PurInvoiceSalerCode, 
	Dat_PurInvoiceDate, 
	Des_VehicleNo, 
	SiPubPersonsSpec, 
	Cod_FactRespCode, 
	Dat_FactRespRegDate, 
	Sta_InvEntBranch, 
	SiOutDeliReceipt, 
	Cod_InvExtHeaderCode, 
	Des_InvEntDetailDesc, 
	SiPubCustomCodes, 
	Sta_IsForeign,
	VahedeSanjesh2,
	DesCust,
	Des_StoreName,
	Num_InvEntDetailGdsAmount,
	Num_TransportCostFee,
	OutCode,
	OutDate,
	RowTotalFee,
	VaredehWeight,
	Cod_BuyReqHdCode,
	SiPurInvoice_Hd,
	Cod_PurInvoiceDtCode,
	Cod_ReqestCode,
	Des_SalerContCode,
	UserCode, 
	UserDesc, 
	Sta_ActionType, 
	Mdt_TransDateShamsi, 
	FindWindowsUser,
	Sta_InvType'

-- Add the ORDER BY clause
IF @Order <> ''
    SET @FinalSql = @FinalSql + @Order
ELSE
    SET @FinalSql = @FinalSql + ' Order by Dat_InvEnterDate'
	print @FinalSql
-- Execute the final SQL
Exec(@FinalSql)
