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

alter PROCEDURE Tss_SalGoodsPriceCalcStp  
(  
	@SiSalInvoice_Dt numeric,
	@SiPubGoodsClassify numeric,  
	@Num_SampleInnerHeigth numeric,  
	@Num_ColoringRate Int,  
	@Num_SampleHoleNo Int,  
	@Sta_HasMangene SmallInt,  
	@Sta_EttesalType SmallInt,  
	@Num_FeeAdjust numeric,  
	@Sta_DieOrNot SmallInt,  
	@Sta_TipOfGoodsType SmallInt,  
	@TolSheet Numeric,  
	@ArzSheet Numeric,  
	@Area float,
	@Sta_Cyan SmallInt, 
	@Sta_Magenta SmallInt, 
	@Sta_Yellow SmallInt, 
	@Sta_Black SmallInt, 
	@Sta_HasVerni SmallInt,
	@Sta_PackType SmallInt,    
	@Num_OneMeterSheetPrice Numeric,   
	@Num_OneMeterBoxPrice Numeric,  
	@Sta_IsFeeAdjustPercent smallint,
	@Num_NoInPallete numeric,
	@AmountNo numeric,
	@CellophaneType smallint,
	@LaminateType smallint,
	@MatteOrGlossy smallint,
	@NoGdsInDie smallint,
	@SiPrcGoodsType numeric,
	@SiPubGoodsClassifyCardBox numeric,
	@OffsetAreaType smallint,
	@OffsetHeightPrint numeric,
	@PunchNo numeric,
	@Prod_P numeric OutPut,  
	@ColorFee numeric OutPut,  
	@CardBoxPrice numeric OutPut,
	@PalleteFee numeric OutPut,  
	@DieCut_Fee numeric OutPut,  
	@Laminate_Fee numeric OutPut,
	@OffSet_Fee numeric OutPut,
	@LaminateWage numeric OutPut,
	@CellophoneGlueMatteCost numeric OutPut,
	@CellophoneGlueGlossyCost numeric OutPut,
	@CellophoneThermalMatteCost numeric OutPut,
	@CellophoneThermalGlossyCost numeric OutPut,
	@LaminateBoxLockBottomCost numeric OutPut,
	@LaminateBoxTwoPieceCost numeric OutPut,
	@FeeHaml numeric OutPut
)  
As  

Set arithabort ON
Set concat_null_yields_null ON
Set ansi_nulls ON
Set ansi_null_dflt_on ON
Set ansi_padding ON
Set ansi_warnings ON
Set quoted_identifier ON

--Declare  
--   @SiSalInvoice_Dt numeric  
--Set @SiSalInvoice_Dt=7  
/*  
@P01=طول شيت   
@P02=عرض شيت  
@P03=ارتفاع شيت  
@P04=نرخ مصوب  
@P05=قيمت منگنه  
@P06=قيمت منفذ  
@P07=تعداد منفذ  
@P08=هزينه دايكات  
@P09=تعداد در قالب  
@P10=هزينه رنگ  
@P11=درصد رنگ خوري  
@P12=هزينه رنگ تا 1 متر  
@P13=هزينه رنگ بالاي 1 متر و تا 50 درصد رنگ خوري  
@P14=هزينه رنگ بالاي 1 متر و بالاي 50 درصد رنگ خوري  
@P15=هزينه رنگ هافتون سيان
@P16=هزينه رنگ هافتون مگنتا
@P17=هزينه رنگ هافتون زرد
@P18=هزينه رنگ هافتون سياه
@P19=هزينه ورني
@P20=هزينه پالت شرينگ
@P21=بهاي پالت جهت مساحت کالا بالاي 3 متر مربع
@P22=بهاي پالت جهت مساحت کالا زير3 متر مربع

@P23=هزينه يک متر مربع مقوا
@P24=دستمزد يک متر مربع لمينت کردن
@P25=هزينه هاي يک متر مربع سلوفون
@P26=هزينه سلوفون چسبي مات
@P27=هزينه سلوفون چسبي براق
@P28=هزينه سلوفون حرارتي مات
@P29=هزينه سلوفون حرارتي براق
@P30=هزينه ته قفلي  کارتن لمينت
@P31=هزنيه کارتن لمينت دو تکه
@P32=هزينه چاپ پوستر گروه 70 در 100
@P33=هزينه چاپ پوستر 100 در 140
@P34=هزينه چاپ پوستر 120 در 160
@P37= هزینه چاپ پوستر 50 در 70
@P39= هزینه چاپ پوستر 75 در 105
@P35= هزينه تسمه
@P36= هزينه حمل

*/  
/*  
if (@Sta_EttesalType=3) or (@Sta_EttesalType=4) or (@Sta_EttesalType=5)
	Set @Sta_HasMangene = 1
else
	Set @Sta_HasMangene = 0
*/

Declare  
   @TmpTbl Table (f_Abbr VarChar(10), f_Val VarChar(50))  
Declare  
   @P01 VarChar(50),  
   @P02 VarChar(50),  
   @P03 VarChar(50),  
   @P04 VarChar(50),  
   @P05 VarChar(50),  
   @P06 VarChar(50),  
   @P07 VarChar(50),  
   @P08 VarChar(50),  
   @P09 VarChar(50),  
   @P10 VarChar(50),  
   @P11 VarChar(50),  
   @P12 VarChar(50),  
   @P13 VarChar(50),  
   @P14 VarChar(50),  
   @P15 VarChar(50),  
   @P16 VarChar(50),  
   @P17 VarChar(50),  
   @P18 VarChar(50),  
   @P19 VarChar(50),  
   @P20 VarChar(50),  
   @P21 VarChar(50),  
   @P22 VarChar(50),  
   @P23 VarChar(50),  
   @P24 VarChar(50),  
   @P25 VarChar(50),  
   @P26 VarChar(50),  
   @P27 VarChar(50),  
   @P28 VarChar(50),  
   @P29 VarChar(50),  
   @P30 VarChar(50),  
   @P31 VarChar(50),  
   @P32 VarChar(50),  
   @P33 VarChar(50),  
   @P34 VarChar(50),  
   @P35 VarChar(50),
   @P36 VarChar(50),
   @P37 VarChar(50),
   @P38 VarChar(50),
   @P39 VarChar(50),
   @P40 VarChar(50),

   @P1 VarChar(50),  
   @SqlTxt nVarChar(4000),  
 @iCount Int,  
   @TmpStr VarChar(500),  
   @TmpH VarChar(20),  
	--   @Num_OneMeterSheetPrice Numeric,   
	--   @Num_OneMeterBoxPrice Numeric,  
	@Prod_Area numeric,  
	@PriceOfBoxFormula VarChar(500),  
	@Gds_Area Numeric (18,3),  
	@c_Pr numeric,  
	@k_Tmp varChar(50),
	@HasHafton smallint,
	@Num_GdsAmountNo numeric,
	@Sta_CellophaneType smallint,
	@Sta_MatteOrGlossy smallint,
	@Sta_LaminateType smallint,
	@CeloMatteOrGlossyCost numeric,
	@PosterPrintCost numeric,
	@Num_NoGdsInDie smallint,
	@Num_OneMeterCardBoxPrice numeric,
	@TolSheetLaminate numeric,
	@ArzSheetLaminate numeric,
	@SiInvVehicles numeric,
	@Num_NoInVehicle numeric,
	@SiPubPersonsSpec numeric,
	@SiPubGeoPlac numeric,
	@Num_VehicleHamlCost numeric,
	@Sta_TransportState smallint,
	--@FeeHaml numeric,
	@SiPrcPackagingTypes numeric,
	@Num_PackagingTypesCost numeric,
	@FeePallete numeric

if @SiSalInvoice_Dt>0
begin
	SELECT     
		@Num_GdsAmountNo = Tss_SalInvoice_Dt.Num_GdsAmountNo, 
		@Sta_CellophaneType = Tss_SalInvoice_Dt.Sta_CellophaneType, 
		@Sta_MatteOrGlossy = Tss_SalInvoice_Dt.Sta_MatteOrGlossy, 
		@Sta_LaminateType = Tss_PrcGoodsType.Sta_LaminateType,
		@Num_NoGdsInDie = isnull(dbo.Tss_PrcDieSpec.Num_NoGdsInDie,1),
		@SiInvVehicles=SiInvVehicles,
		@Num_NoInVehicle=Num_NoInVehicle, 
		@SiPubPersonsSpec = Tss_SalInvoice_Hd.SiPubPersonsSpec,
		@Sta_TransportState = Tss_SalInvoice_Hd.Sta_TransportState,
		@SiPrcPackagingTypes = Tss_SalInvoice_Dt.SiPrcPackagingTypes
	FROM            
		Tss_SalInvoice_Dt INNER JOIN
		Tss_PrcGoodsType ON Tss_SalInvoice_Dt.SiPrcGoodsType = Tss_PrcGoodsType.SiPrcGoodsType left outer JOIN
		Tss_PrcDieSpec ON Tss_SalInvoice_Dt.SiPrcDieSpec = Tss_PrcDieSpec.SiPrcDieSpec INNER JOIN
		Tss_SalInvoice_Hd ON Tss_SalInvoice_Dt.SiSalInvoice_Hd = Tss_SalInvoice_Hd.SiSalInvoice_Hd
	WHERE     
		(Tss_SalInvoice_Dt.SiSalInvoice_Dt = @SiSalInvoice_Dt)

	SELECT    
		@SiPubGeoPlac = Tss_PubGeoPlac.SiPubGeoPlac
	FROM            
		Tss_PubPersonsSpec INNER JOIN
		Tss_PubGeoPlac ON Tss_PubPersonsSpec.SiPubGeoPlacCity = Tss_PubGeoPlac.SiPubGeoPlac
	WHERE        
		(Tss_PubPersonsSpec.SiPubPersonsSpec = @SiPubPersonsSpec)

	Set @Num_PackagingTypesCost = 0

	SELECT        
		@Num_PackagingTypesCost = isnull(Num_PackagingTypesCost,0)
	FROM            
		Tss_PrcPackagingTypes
	WHERE        
		(SiPrcPackagingTypes = @SiPrcPackagingTypes)

	Set @FeePallete = round(@Num_PackagingTypesCost/@Num_NoInPallete,-1,0)
	Set @PalleteFee = round(@Num_PackagingTypesCost/@Num_NoInPallete,-1,0)
	
	

	if exists
	(
	select
		*
	FROM            
		Tss_InvVehiclesDt
	WHERE        
		(SiInvVehicles = @SiInvVehicles) AND 
		(SiPubGeoPlacCity = @SiPubGeoPlac)
	)
	begin
		SELECT        
			@Num_VehicleHamlCost = isnull(Num_VehicleHamlCost,0)
		FROM            
			Tss_InvVehiclesDt
		WHERE        
			(SiInvVehicles = @SiInvVehicles) AND 
			(SiPubGeoPlacCity = @SiPubGeoPlac)

		if @Sta_TransportState = 1
			Set @FeeHaml = round(@Num_VehicleHamlCost/@Num_NoInVehicle,-1,0)
	end
	else
		Set @FeeHaml = 0
end
else
Begin
	set @Num_GdsAmountNo = @AmountNo 
	set @Sta_CellophaneType = @CellophaneType 
	set @Sta_MatteOrGlossy = @MatteOrGlossy 
	set @Num_NoGdsInDie = @NoGdsInDie
	set	@SiInvVehicles=null
	set	@Num_NoInVehicle=0
	SELECT 
		@Sta_LaminateType = @LaminateType
	FROM 
		dbo.Tss_PrcGoodsType 
	WHERE 
		(SiPrcGoodsType = @SiPrcGoodsType)

end  



if @Sta_LaminateType = 3
	Set @Sta_HasVerni = 0
else
	Set @Sta_HasVerni = 1

Set @HasHafton = 0

if	@Sta_Cyan=1 Set @HasHafton = 1
if	@Sta_Magenta=1 Set @HasHafton = 1
if	@Sta_Yellow=1 Set @HasHafton = 1
if	@Sta_Black=1 Set @HasHafton = 1

Set @Prod_P=0  
Set @Prod_Area=0  
Set @Num_FeeAdjust=0  
  
  
  
  
   
  Select @P40= ltrim(rtrim(dbo.Tss_StdFindSystemParamValue('ProfitPercentage')))
  Set @P40 = '0.'+@P40





Set @P03=Convert(Varchar(10),@Num_SampleInnerHeigth) 
if isnull(@PunchNo,0)>0 
	Set @P03 = @PunchNo*50
else
	Set @P03 = @Num_SampleInnerHeigth

if ((isnull(@Num_OneMeterSheetPrice,0)=0) and (isnull(@Num_OneMeterBoxPrice,0)=0))
begin
	SELECT top 1      
	   @Num_OneMeterSheetPrice=Num_OneMeterSheetPrice,   
	   @Num_OneMeterBoxPrice=Num_OneMeterBoxPrice  
	FROM           
	   Tss_PubSalGoodsPrices  
	WHERE       
	   (SiPubGoodsClassify = @SiPubGoodsClassify)  AND 
		(Sta_SalGoodsPricesEnabled = 1)
	ORDER BY 
		Dat_GoodsPricesEffDate DESC
end

If (@Sta_TipOfGoodsType=0) or (@Sta_TipOfGoodsType=5)  
Begin  
   SELECT @PriceOfBoxFormula=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'PriceOfBoxFormula')  

   Select @P04=Ltrim(Rtrim(Str(@Num_OneMeterBoxPrice)))+'.00'  
End  

If (@Sta_TipOfGoodsType=1) Or (@Sta_TipOfGoodsType=3) Or (@Sta_TipOfGoodsType=6)
Begin  
   SELECT @PriceOfBoxFormula=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'PriceOfSheetFormula')  
   Select @P04=Ltrim(Rtrim(Str(@Num_OneMeterSheetPrice)))+'.00'  
End  

If (@Sta_TipOfGoodsType=4)
Begin  
   SELECT @PriceOfBoxFormula=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'PriceOfSheetFormula')  
   Select @P04=Ltrim(Rtrim(Str((@Num_OneMeterSheetPrice+@Num_OneMeterBoxPrice)/2)))+'.00'  
End  

if (isnull(@Num_SampleHoleNo,0)>0) And (@Sta_DieOrNot=0)
	Set @Num_SampleHoleNo = 1
Else
	if (isnull(@Num_SampleHoleNo,0)>0) And (@Sta_DieOrNot=1)
		Set @Num_SampleHoleNo = 0

Set @Num_OneMeterCardBoxPrice = 0

SELECT top 1      
   @Num_OneMeterCardBoxPrice=Num_OneMeterSheetPrice,   
   @Num_OneMeterCardBoxPrice=Num_OneMeterBoxPrice  
FROM           
   Tss_PubSalGoodsPrices  
WHERE       
   (SiPubGoodsClassify = @SiPubGoodsClassifyCardBox)  AND 
	(Sta_SalGoodsPricesEnabled = 1)
ORDER BY 
	Dat_GoodsPricesEffDate DESC

Select @TolSheetLaminate=Ltrim(Rtrim(Str(@TolSheet)))  
Select @ArzSheetLaminate=Ltrim(Rtrim(Str(@ArzSheet)))  

Select @P01=Ltrim(Rtrim(Str(@TolSheet)))  
Select @P02=Ltrim(Rtrim(Str(@ArzSheet)))  
SELECT @P05=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'PunchUnitPrice')  
SELECT @P06=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'HolePrice')  
SELECT @P07=Ltrim(Rtrim(Str(@Num_SampleHoleNo)))  
SELECT @P08=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'DieCutPrice')  
SELECT @P09=convert(varchar,isnull(@Num_NoGdsInDie,1))  
SELECT @P11=Ltrim(Rtrim(Str(@Num_ColoringRate)))  
SELECT @P12=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'OneMeterColorPrice')  
SELECT @P13=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'UpOneMeterTo50ColorPrice')  
SELECT @P14=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'UpOneMeterUp50ColorPrice')  
SELECT @P15=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'CyanPrice')  
SELECT @P16=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'MagentaPrice')  
SELECT @P17=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'YellowPrice')  
SELECT @P18=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'BlackPrice')  
SELECT @P19=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'VerniPrice')  

if dbo.Tss_StdFindSubLoc(0)<>'Caspian'
begin
	SELECT @P20=ltrim(rtrim(Str(isnull(@FeePallete,0))))
	--SELECT @P20=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'PalleteShrinkPrice')  
	SELECT @P21=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'PalleteFeeForOver3m')  
	SELECT @P22=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'PalleteFeeForUnder3m')  
end
else
begin
	SELECT @P20=ltrim(rtrim(Str(isnull(@FeePallete,0))))+'.00'
	SELECT @P21=0
	SELECT @P22=0
end
--print @FeePallete
--Set @PalleteFee=Convert(numeric,@P20)  

if dbo.Tss_StdFindSubLoc(0)='Caspian'
begin
	set @P36=ltrim(rtrim(Str(@FeeHaml)))+'.00'
end
else
begin
	set @P36='0'
end

--SELECT @P23=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'CardboardFee') 
SELECT @P23=@Num_OneMeterCardBoxPrice
 
SELECT @P24=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'LaminateOneMeteWage')  
SELECT @P25=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'CellophoneOneMeterCost')  
SELECT @P26=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'CellophoneGlueMatteCost')  
SELECT @P27=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'CellophoneGlueGlossyCost')  
SELECT @P28=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'CellophoneThermalMatteCost')  
SELECT @P29=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'CellophoneThermalGlossyCost')  
SELECT @P30=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'LaminateBoxLockBottomCost')  
SELECT @P31=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'LaminateBoxTwoPieceCost')  
SELECT @P32=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'PosterPrintCostGroup1')  
SELECT @P33=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'PosterPrintCostGroup2')  
SELECT @P34=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'PosterPrintCostGroup3')
SELECT @P37=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'PosterPrintCostGroup0')
SELECT @P39=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'PosterPrintCostGroup4')
SELECT @P38=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'LabchasbPrice')

if isnull(@Sta_PackType,0)=1
	SELECT @P35=Des_SysParamsValue FROM Tss_StdAllSystemParams WHERE  (SiStdSystemsList = 20) AND (Des_SysParamsName = 'StrapCost')  
else
	Set @P35 = 0
	
/*if @Sta_Cyan=0
	Set @P15='0'
if @Sta_Magenta=0
	Set @P16='0'
if @Sta_Yellow=0
	Set @P17='0'
if @Sta_Black=0
	Set @P18='0'
*/
--------------------------------------محاسبات لمينه
if @Sta_HasVerni=0
	Set @P19='0'
else
begin
	if (@Sta_CellophaneType = 0) and (@Sta_MatteOrGlossy = 0) 
	begin
		Set @CeloMatteOrGlossyCost = isnull(convert(numeric,@P26),0)
		Set @P27 = '0'
		Set @P28 = '0'
		Set @P29 = '0'
	end
	if (@Sta_CellophaneType = 0) and (@Sta_MatteOrGlossy = 1) 
	begin
		Set @CeloMatteOrGlossyCost = isnull(convert(numeric,@P27),0)
		Set @P26 = '0'
		Set @P28 = '0'
		Set @P29 = '0'
	end


	if (@Sta_CellophaneType = 1) and (@Sta_MatteOrGlossy = 0) 
	begin
		Set @CeloMatteOrGlossyCost = isnull(convert(numeric,@P28),0)
		Set @P26 = '0'
		Set @P27 = '0'
		Set @P29 = '0'
	end


	if (@Sta_CellophaneType = 1) and (@Sta_MatteOrGlossy = 1) 
	begin
		Set @CeloMatteOrGlossyCost = isnull(convert(numeric,@P29),0)
		Set @P26 = '0'
		Set @P27 = '0'
		Set @P28 = '0'
	end


	if (@Sta_LaminateType = 1) Set @P31 = '0'
	if (@Sta_LaminateType = 2) Set @P30 = '0'
	if (@Sta_LaminateType = 0) Set @P31 = '0'
	if (@Sta_LaminateType = 0) Set @P30 = '0'
/*	if (@Sta_CellophaneType = 2) Set @P25 = '0'
	if (@Sta_CellophaneType = 2) Set @P26 = '0'
	if (@Sta_CellophaneType = 2) Set @P27 = '0'
	if (@Sta_CellophaneType = 2) Set @P28 = '0'
	if (@Sta_CellophaneType = 2) Set @P29 = '0'
*/


--@P32=هزينه چاپ پوستر گروه 70 در 100
--@P33=هزينه چاپ پوستر 100 در 140
--@P34=هزينه چاپ پوستر 120 در 160
--@P37= هزینه چاپ پوستر 50 در 70
--@P39= هزینه چاپ پوستر 75 در 105



	if (@TolSheet>@ArzSheet)
	Begin
		if @OffsetAreaType=1
			Set @ArzSheetLaminate = @OffsetHeightPrint

	
		if ((@TolSheetLaminate<=700) and (@ArzSheetLaminate<=500)) 
	--	if (@TolSheet*@ArzSheet)<=700000
		Begin
			if (@Num_GdsAmountNo/@Num_NoGdsInDie)<5000 Set @PosterPrintCost = round(isnull(convert(numeric,@P37),0)/(@Num_GdsAmountNo/@Num_NoGdsInDie),0)/@Num_NoGdsInDie
			if (@Num_GdsAmountNo/@Num_NoGdsInDie)>=5000 Set @PosterPrintCost = round(isnull(convert(numeric,@P37),0)/(5000),0)/@Num_NoGdsInDie --(5000/(@Num_GdsAmountNo/@Num_NoGdsInDie)),0)
		end
		
		if ((@TolSheetLaminate<=1000) and (@ArzSheetLaminate<=700)) 
	--	if (@TolSheet*@ArzSheet)<=700000
		Begin
			if (@Num_GdsAmountNo/@Num_NoGdsInDie)<5000 Set @PosterPrintCost = round(isnull(convert(numeric,@P32),0)/(@Num_GdsAmountNo/@Num_NoGdsInDie),0)/@Num_NoGdsInDie
			if (@Num_GdsAmountNo/@Num_NoGdsInDie)>=5000 Set @PosterPrintCost = round(isnull(convert(numeric,@P32),0)/(5000),0)/@Num_NoGdsInDie --(5000/(@Num_GdsAmountNo/@Num_NoGdsInDie)),0)
		end
		
	--	if ((@TolSheetLaminate>1000) or (@ArzSheetLaminate>700)) and ((@TolSheetLaminate<=1400) and (@ArzSheetLaminate<=1000))
		if ((@TolSheetLaminate<=1400) AND (@ArzSheetLaminate<=1000))
		Begin
			if (@Num_GdsAmountNo/@Num_NoGdsInDie)<5000 Set @PosterPrintCost = round(isnull(convert(numeric,@P33),0)/(@Num_GdsAmountNo/@Num_NoGdsInDie),0)/@Num_NoGdsInDie
			if (@Num_GdsAmountNo/@Num_NoGdsInDie)>=5000 Set @PosterPrintCost = round(isnull(convert(numeric,@P33),0)/(5000),0)/@Num_NoGdsInDie --(5000/(@Num_GdsAmountNo/@Num_NoGdsInDie)),0)
		end
		
	--	if ((@TolSheetLaminate>1400) or (@ArzSheetLaminate>1000)) and ((@TolSheetLaminate<=1600) and (@ArzSheetLaminate<=1200))
		if ((@TolSheetLaminate<=1600) AND (@ArzSheetLaminate<=1200))
		Begin
			if (@Num_GdsAmountNo/@Num_NoGdsInDie)<5000 Set @PosterPrintCost = round(isnull(convert(numeric,@P34),0)/(@Num_GdsAmountNo/@Num_NoGdsInDie),0)/@Num_NoGdsInDie
			if (@Num_GdsAmountNo/@Num_NoGdsInDie)>=5000 Set @PosterPrintCost = round(isnull(convert(numeric,@P34),0)/(5000),0)/@Num_NoGdsInDie --(5000/(@Num_GdsAmountNo/@Num_NoGdsInDie)),0)
		end
	End
	else
	Begin
		if @OffsetAreaType=1
			Set @TolSheetLaminate = @OffsetHeightPrint

		if ((@TolSheetLaminate<=500) and (@ArzSheetLaminate<=700)) 
	--	if (@TolSheet*@ArzSheet)<=700000
		Begin
			if (@Num_GdsAmountNo/@Num_NoGdsInDie)<5000 Set @PosterPrintCost = round(isnull(convert(numeric,@P37),0)/(@Num_GdsAmountNo/@Num_NoGdsInDie),0)/@Num_NoGdsInDie
			if (@Num_GdsAmountNo/@Num_NoGdsInDie)>=5000 Set @PosterPrintCost = round(isnull(convert(numeric,@P37),0)/(5000),0)/@Num_NoGdsInDie --(5000/(@Num_GdsAmountNo/@Num_NoGdsInDie)),0)
		end
		
		if ((@TolSheetLaminate<=700) and (@ArzSheetLaminate<=1000)) 
	--	if (@TolSheet*@ArzSheet)<=700000
		Begin
			if (@Num_GdsAmountNo/@Num_NoGdsInDie)<5000 Set @PosterPrintCost = round(isnull(convert(numeric,@P32),0)/(@Num_GdsAmountNo/@Num_NoGdsInDie),0)/@Num_NoGdsInDie
			if (@Num_GdsAmountNo/@Num_NoGdsInDie)>=5000 Set @PosterPrintCost = round(isnull(convert(numeric,@P32),0)/(5000),0)/@Num_NoGdsInDie --(5000/(@Num_GdsAmountNo/@Num_NoGdsInDie)),0)
		end
		
	--	if ((@TolSheetLaminate>700) or (@ArzSheetLaminate>1000)) and ((@TolSheetLaminate<=1000) and (@ArzSheetLaminate<=1400))
	--	if ((@TolSheet*@ArzSheet)>700000) AND ((@TolSheet*@ArzSheet)<=1400000)
		if ((@TolSheetLaminate<=1000) AND (@ArzSheetLaminate<=1400))
		Begin
			if (@Num_GdsAmountNo/@Num_NoGdsInDie)<5000 Set @PosterPrintCost = round(isnull(convert(numeric,@P33),0)/(@Num_GdsAmountNo/@Num_NoGdsInDie),0)/@Num_NoGdsInDie
			if (@Num_GdsAmountNo/@Num_NoGdsInDie)>=5000 Set @PosterPrintCost = round(isnull(convert(numeric,@P33),0)/(5000),0)/@Num_NoGdsInDie --(5000/(@Num_GdsAmountNo/@Num_NoGdsInDie)),0)
		end
		
	--	if ((@TolSheetLaminate>1000) or (@ArzSheetLaminate>1400)) and ((@TolSheetLaminate<=1200) and (@ArzSheetLaminate<=1600))
	--	if ((@TolSheet*@ArzSheet)>1400000) AND ((@TolSheet*@ArzSheet)<=1920000)
		if ((@TolSheetLaminate<=1200) AND (@ArzSheetLaminate<=1600))
		Begin
			if (@Num_GdsAmountNo/@Num_NoGdsInDie)<5000 Set @PosterPrintCost = round(isnull(convert(numeric,@P34),0)/(@Num_GdsAmountNo/@Num_NoGdsInDie),0)/@Num_NoGdsInDie
			if (@Num_GdsAmountNo/@Num_NoGdsInDie)>=5000 Set @PosterPrintCost = round(isnull(convert(numeric,@P34),0)/(5000),0)/@Num_NoGdsInDie --(5000/(@Num_GdsAmountNo/@Num_NoGdsInDie)),0)
		end
	End 


	IF  (@Sta_CellophaneType = 2)
		Set @P19=(((@TolSheetLaminate*@ArzSheetLaminate)/(1000000*@Num_NoGdsInDie))*(convert(numeric,@P23)+convert(numeric,@P24)+convert(numeric,@P25)))+
		(convert(numeric,@P30)+convert(numeric,@P31))+(isnull(@PosterPrintCost,0))
	ELSE
		Set @P19=(((@TolSheetLaminate*@ArzSheetLaminate)/(1000000*@Num_NoGdsInDie))*(convert(numeric,@P23)+convert(numeric,@P24)+convert(numeric,@P25)+
		convert(numeric,@P26)+convert(numeric,@P27)+convert(numeric,@P28)+convert(numeric,@P29)))+(convert(numeric,@P30)+convert(numeric,@P31))+(isnull(@PosterPrintCost,0))

	Set @P19= @P19*(convert(numeric,dbo.Tss_StdFindSystemParamValue('ProfitPercentage'))+100)/100

	Set @Laminate_Fee = isnull(@P19,0)
	Set @CardBoxPrice   = ((@TolSheetLaminate*@ArzSheetLaminate)/(1000000*@Num_NoGdsInDie))*(convert(numeric,@P23))*(convert(numeric,dbo.Tss_StdFindSystemParamValue('ProfitPercentage'))+100)/100
	Set @OffSet_Fee   = (isnull(@PosterPrintCost,0))*(convert(numeric,dbo.Tss_StdFindSystemParamValue('ProfitPercentage'))+100)/100
	Set @LaminateWage = ((@TolSheetLaminate*@ArzSheetLaminate)/(1000000*@Num_NoGdsInDie))*(convert(numeric,@P24))*(convert(numeric,dbo.Tss_StdFindSystemParamValue('ProfitPercentage'))+100)/100
	Set @CellophoneGlueMatteCost = ((@TolSheetLaminate*@ArzSheetLaminate)/1000000)*(convert(numeric,@P26))*(convert(numeric,dbo.Tss_StdFindSystemParamValue('ProfitPercentage'))+100)/100
	Set @CellophoneGlueGlossyCost = ((@TolSheetLaminate*@ArzSheetLaminate)/1000000)*(convert(numeric,@P27))*(convert(numeric,dbo.Tss_StdFindSystemParamValue('ProfitPercentage'))+100)/100
	Set @CellophoneThermalMatteCost = ((@TolSheetLaminate*@ArzSheetLaminate)/1000000)*(convert(numeric,@P28))*(convert(numeric,dbo.Tss_StdFindSystemParamValue('ProfitPercentage'))+100)/100
	Set @CellophoneThermalGlossyCost = ((@TolSheetLaminate*@ArzSheetLaminate)/1000000)*(convert(numeric,@P29))*(convert(numeric,dbo.Tss_StdFindSystemParamValue('ProfitPercentage'))+100)/100
	Set @LaminateBoxLockBottomCost = (convert(numeric,@P30))*(convert(numeric,dbo.Tss_StdFindSystemParamValue('ProfitPercentage'))+100)/100
	Set @LaminateBoxTwoPieceCost = (convert(numeric,@P31))*(convert(numeric,dbo.Tss_StdFindSystemParamValue('ProfitPercentage'))+100)/100
end
--------------------------------------محاسبات لمينه

If @Sta_HasMangene=0  
   Set @P05='0'  


If @Sta_EttesalType<>1  
	Set @P38='0' 
	
--If @Sta_HasVerni=1  
  -- Set @P05='0'  

If ((@Sta_PackType=0) Or (@Sta_PackType=1)) 
   Set @P20='0'  
Set @DieCut_Fee=0  
If @Sta_DieOrNot=1 
begin
    if @P09 >=1
     Set @DieCut_Fee=Round(Convert(int,@P08)/Convert(float,@P09),0)
    else
        Set @DieCut_Fee=Round(Convert(int,@P08)*2,0)
end
Else  
   Set @P08='0'  
Set @c_Pr=0  



if dbo.Tss_StdFindSubLoc(0)<>'Caspian'
	Set @P20=Convert(int,@P20)*(@TolSheet*@ArzSheet)/1000000 



if (dbo.Tss_StdFindSubLoc(0)<>'Caspian') and (@Num_NoInPallete>0)
Begin
	if ((@TolSheet*@ArzSheet)/1000000)>=3
	Begin
		if @Num_NoInPallete*((@TolSheet*@ArzSheet)/1000000)>500
			Set @P20 = (@P21/@Num_NoInPallete)
		Else
			Set @P20 = (500/(@Num_NoInPallete*((@TolSheet*@ArzSheet)/1000000)))*(@P21/500)*((@TolSheet*@ArzSheet)/1000000)
	End
	Else
	Begin
		if @Num_NoInPallete*((@TolSheet*@ArzSheet)/1000000)>500
			Set @P20 = (@P22/@Num_NoInPallete)
		Else
			Set @P20 = (500/(@Num_NoInPallete*((@TolSheet*@ArzSheet)/1000000)))*(@P22/500)*((@TolSheet*@ArzSheet)/1000000)
	End

End



If ((@Sta_PackType=0) Or (@Sta_PackType=1)) 
	Set @P20='0'  
	

Set @c_Pr=Convert(int,@P12)*isnull(@Num_ColoringRate,0)/100*(@TolSheet*@ArzSheet)/1000000 


If (@Num_ColoringRate=0) and (@Sta_HasVerni=0)    
   Set @c_Pr=0  


If (@Num_ColoringRate=0) and (@HasHafton = 1) 
	begin
		Set @c_Pr= 0
	end


Set @P15='0'
Set @P16='0'
Set @P17='0'
Set @P18='0'
--	Set @P19='0'

--------


Set @P10=Ltrim(Rtrim(Str(@c_Pr))) 



Insert into @TmpTbl 
   (f_Abbr, f_Val)  
Select * From (  
Select '@P01' As abbr, @P01 As fVal  
Union All  
Select '@P02' As abbr, @P02 As fVal  
Union All  
Select '@P03' As abbr, @P03 As fVal  
Union All  
Select '@P04' As abbr, @P04 As fVal  
Union All  
Select '@P05' As abbr, @P05 As fVal  
Union All  
Select '@P06' As abbr, @P06 As fVal 
Union All  
Select '@P07' As abbr, @P07 As fVal  
Union All  
Select '@P08' As abbr, @P08 As fVal  
Union All  
Select '@P09' As abbr, @P09 As fVal  
Union All  
Select '@P10' As abbr, @P10 As fVal 
Union All 
Select '@P15' As abbr, @P15 As fVal  
Union All  
Select '@P19' As abbr, @P19 As fVal  
Union All  
Select '@P20' As abbr, @P20 As fVal  
Union All  
Select '@P35' As abbr, @P35 As fVal  
Union All  
Select '@P36' As abbr, @P36 As fVal  
Union All  
Select '@P16' As abbr, @P16 As fVal  
Union All  
Select '@P17' As abbr, @P17 As fVal  
Union All  
Select '@P18' As abbr, @P18 As fVal  
Union All  
Select '@P38' As abbr, @P38 As fVal  
Union All  
Select '@P40' As abbr, @P40 As fVal 
) Ccc  


--select * from @TmpTbl  
Set @SqlTxt='Set @Prod_P='  
Set @TmpStr=@PriceOfBoxFormula  
Set @iCount=1  
--print '@TmpStr'
--print @TmpStr
While 1=1  
Begin  
 -- print 'tammmmmammm'
   Set @k_Tmp=''  
   If Substring(@TmpStr,@iCount,1)='@'  
   Begin 
      Select @k_Tmp=f_Val from @TmpTbl where f_Abbr=Substring(@TmpStr,@iCount,4) 
	  if Substring(@TmpStr,@iCount,4) = '@P20' Set @k_Tmp = 0
	  if Substring(@TmpStr,@iCount,4) = '@P36' Set @k_Tmp = 0
      Set @SqlTxt=@SqlTxt+@k_Tmp  
	
      Set @iCount=@iCount+3  
   End  
   Else  
   Begin  
      Set @SqlTxt=@SqlTxt+Substring(@TmpStr,@iCount,1)  
   End  
   Set @iCount=@iCount+1  
 
   If @iCount>Len(@TmpStr)  
      Break  
End  



--print @SqlTxt


exec sp_executesql @SqlTxt,N'@Prod_P numeric output', @Prod_P output  


if @Sta_IsFeeAdjustPercent=0
Begin
	If @Prod_P>=@Num_FeeAdjust  
	   If @Num_FeeAdjust<0  
	      Set @Prod_P=@Prod_P-Abs(@Num_FeeAdjust)  
	   Else  
	      Set @Prod_P=@Prod_P+Abs(@Num_FeeAdjust)  
End


if @Sta_IsFeeAdjustPercent=1
Begin
	If @Prod_P>=@Num_FeeAdjust  
	   If @Num_FeeAdjust<0  
	      Set @Prod_P=@Prod_P-(Abs(@Num_FeeAdjust)*@Prod_P/100) 
	   Else  
	      Set @Prod_P=@Prod_P+(Abs(@Num_FeeAdjust)*@Prod_P/100)  
End

Set @ColorFee=Convert(int,@P10) 


Return

go

alter PROCEDURE Tss_SalGoodsCalcStp
(
    @SiSalInvoice_Dt numeric=0,
    @SiPubGoodsClassify numeric=21312,
    @SiPrcFlutType numeric=9,
    @Num_SampleInnerLength numeric=373,
    @Num_SampleInnerWidth numeric=283,
    @Num_SampleInnerHeigth numeric=190,
    @Num_DarbConst numeric=0,
    @Num_ErtefaConst numeric=0,
    @Des_LenghtFormula VarChar(500)='2*@TTT+2*@AAA',
    @Des_WidthFormula VarChar(500)='@EEE+@AAA',
    @Num_UpDoorOpenSize Numeric=0, 
    @Num_DownDoorOpenSize Numeric=0, 
    @SiPrcGoodsType numeric=3,
    @LabConst numeric=0,
    @TolSheet Numeric=0 OutPut,
    @ArzSheet Numeric=0 OutPut
)
As

Set XACT_ABORT ON


Declare
   @TmpTbl Table (f_Abbr VarChar(10), f_Val VarChar(50))
Declare
	@P01 VarChar(50),
	@P02 VarChar(50),
	@P03 VarChar(50),
	@P04 VarChar(50),
	@P05 VarChar(50),
	@P06 VarChar(50),
	@P07 VarChar(50),
	@P08 VarChar(50),
	@P09 VarChar(50),
	@P10 VarChar(50),
	@P11 VarChar(50),
	@P12 VarChar(50),
	@P13 VarChar(50),
	@P14 VarChar(50),
	@TTT VarChar(10),
	@AAA VarChar(10),
	@EEE VarChar(10),
	@HHH VarChar(10),
	@FFF VarChar(10),
	@SqlTxtTool nVarChar(4000),
	@SqlTxtArzi nVarChar(4000),
	@iCount Int,
	@Layers Int,
	@TmpStr VarChar(500),
	@TmpH VarChar(20),
	@TotalDarbBaz int,
	@ToolConst numeric,
	@ArzConst numeric,
	@Num_WidthPert numeric,
	@Num_LabChasbConst numeric,
	@OuterOrInnerFlag smallint,
	@Num_SampleOuterLength numeric,
	@Num_SampleOuterWidth numeric,
	@Num_SampleOuterHeigth numeric,
	@Sta_TipType smallint,
	@Sta_TipOfGoodsType smallint

Set @OuterOrInnerFlag = dbo.Tss_StdFindSystemParamValue('CalcOuterBased')

SELECT 
	@Num_LabChasbConst = Num_ContLabChasbConst
FROM         
	Tss_SalInvoice_Dt
WHERE     
	(SiSalInvoice_Dt = @SiSalInvoice_Dt)

if isnull(@LabConst,0)>0
    Set @Num_LabChasbConst = @LabConst

if @SiPrcGoodsType=0
begin
    if (dbo.Tss_StdFindSubLoc(0) = 'aeen')  or (dbo.Tss_StdFindSubLoc(0) = 'delta') or (dbo.Tss_StdFindSubLoc(0) = 'zarin')
	    SELECT @SiPrcGoodsType=SiPrcGoodsType, @Num_WidthPert=isnull(Num_WidthPert,0) FROM Tss_SalInvoice_Dt WHERE (SiSalInvoice_Dt = @SiSalInvoice_Dt)
    else
        SELECT @SiPrcGoodsType=SiPrcGoodsType, @Num_WidthPert=isnull(Num_WidthPert,0) FROM Tss_SalInvoice_Dt WHERE (SiSalInvoice_Dt = @SiSalInvoice_Dt)
end


select @Sta_TipType = Sta_TipType from dbo.Tss_PrcGoodsType where SiPrcGoodsType = @SiPrcGoodsType
select @Sta_TipOfGoodsType = Sta_TipOfGoodsType from dbo.Tss_PrcGoodsType where SiPrcGoodsType = @SiPrcGoodsType

if @Sta_TipType = 1 
	Set @Num_LabChasbConst= @Num_LabChasbConst*2


if isnull(@SiSalInvoice_Dt,0)>0
begin
	select @Num_SampleOuterLength= Num_SampleOuterLength  from dbo.Tss_SalInvoice_Dt where SiSalInvoice_Dt = @SiSalInvoice_Dt
	select @Num_SampleOuterWidth= Num_SampleOuterWidth from dbo.Tss_SalInvoice_Dt where SiSalInvoice_Dt = @SiSalInvoice_Dt
	select @Num_SampleOuterHeigth= Num_SampleOuterHeigth from dbo.Tss_SalInvoice_Dt where SiSalInvoice_Dt = @SiSalInvoice_Dt
end
else
begin
	If (@Sta_TipOfGoodsType = 0) or (@Sta_TipOfGoodsType = 5)
	Begin
		select @Num_SampleOuterLength= dbo.ConvertInnerOuterBoxDimensions(0,0,@Num_SampleInnerLength,@SiPrcFlutType) 
		select @Num_SampleOuterWidth = dbo.ConvertInnerOuterBoxDimensions(0,1,@Num_SampleInnerWidth,@SiPrcFlutType) 
		select @Num_SampleOuterHeigth= dbo.ConvertInnerOuterBoxDimensions(0,2,@Num_SampleInnerHeigth,@SiPrcFlutType) 
	End
	Else
	Begin
		select @Num_SampleOuterLength= @Num_SampleInnerLength 
		select @Num_SampleOuterWidth = @Num_SampleInnerWidth
	End
end



if @Num_UpDoorOpenSize=0
	select @Num_UpDoorOpenSize= Num_UpDoorOpenSize from dbo.Tss_SalInvoice_Dt where SiSalInvoice_Dt = @SiSalInvoice_Dt
if @Num_DownDoorOpenSize=0
	select @Num_DownDoorOpenSize= Num_DownDoorOpenSize from dbo.Tss_SalInvoice_Dt where SiSalInvoice_Dt = @SiSalInvoice_Dt


if @Num_SampleInnerLength=0
	select @Num_SampleInnerLength= Num_SampleInnerLength,  @Num_SampleOuterLength= Num_SampleOuterLength  from dbo.Tss_SalInvoice_Dt where SiSalInvoice_Dt = @SiSalInvoice_Dt
if @Num_SampleInnerWidth=0
	select @Num_SampleInnerWidth= Num_SampleInnerWidth, @Num_SampleOuterWidth= Num_SampleOuterWidth from dbo.Tss_SalInvoice_Dt where SiSalInvoice_Dt = @SiSalInvoice_Dt
if @Num_SampleInnerHeigth=0
	select @Num_SampleInnerHeigth= Num_SampleInnerHeigth, @Num_SampleOuterHeigth= Num_SampleOuterHeigth from dbo.Tss_SalInvoice_Dt where SiSalInvoice_Dt = @SiSalInvoice_Dt

if @Num_UpDoorOpenSize=0
	select @Num_UpDoorOpenSize= Num_UpDoorOpenSize from dbo.Tss_SalInvoice_Dt where SiSalInvoice_Dt = @SiSalInvoice_Dt
if @Num_DownDoorOpenSize=0
	select @Num_DownDoorOpenSize= Num_DownDoorOpenSize from dbo.Tss_SalInvoice_Dt where SiSalInvoice_Dt = @SiSalInvoice_Dt

if @OuterOrInnerFlag = 0
Begin
	Set @TTT=Convert(Varchar(10),@Num_SampleInnerLength)
	Set @AAA=Convert(Varchar(10),@Num_SampleInnerWidth)
	Set @EEE=Convert(Varchar(10),@Num_SampleInnerHeigth)
End
Else
Begin
	Set @TTT=Convert(Varchar(10),@Num_SampleOuterLength)
	Set @AAA=Convert(Varchar(10),@Num_SampleOuterWidth)
	Set @EEE=Convert(Varchar(10),@Num_SampleOuterHeigth)
End
--print 'ddddd'
--print @TTT
--print @AAA
--print @EEE

--PRINT '@SiPubGoodsClassify'
--PRINT @SiPubGoodsClassify

IF EXISTS
(
Select SiPubGoodsClassifyFormula From dbo.Tss_PrcMatFormulaClaToPaperTypesCla Where (SiPubGoodsClassifyFormula=@SiPubGoodsClassify)
)
Select @Layers=Count(SiPubGoodsClassifyFormula) 
From
   dbo.Tss_PrcMatFormulaClaToPaperTypesCla
Where
   (SiPubGoodsClassifyFormula=@SiPubGoodsClassify)
ELSE
	SELECT @Layers = Num_Layer FROM Tss_PubGoodsClassify WHERE (SiPubGoodsClassify = @SiPubGoodsClassify)

If ISNULL(@Layers,0)=0 
   Set @Layers=3
If ISNULL(@Layers,0)=1 
   Set @Layers=5

if (isnull(@Num_UpDoorOpenSize,0)=0) and (isnull(@Num_DownDoorOpenSize,0)=0)
	SELECT @TotalDarbBaz=(isnull(Num_UpDoorOpenSize,0)+isnull(Num_DownDoorOpenSize,0))
	FROM 
		Tss_SalInvoice_Dt
	WHERE     (SiSalInvoice_Dt = @SiSalInvoice_Dt)
Else
	Set @TotalDarbBaz = isnull(@Num_UpDoorOpenSize,0)+isnull(@Num_DownDoorOpenSize,0)

Set @TotalDarbBaz = @TotalDarbBaz /2
SELECT 
	@FFF=Ltrim(Rtrim(Tss_PrcFlutType.Des_FlutTypeName)) 
FROM 
	Tss_SalInvoice_Dt LEFT OUTER JOIN Tss_PrcFlutType ON Tss_SalInvoice_Dt.SiPrcFlutType = Tss_PrcFlutType.SiPrcFlutType
WHERE     
	(Tss_SalInvoice_Dt.SiSalInvoice_Dt = @SiSalInvoice_Dt)

Set @TmpStr=Ltrim(Rtrim(@Des_LenghtFormula))
Set @SqlTxtTool='Set @TolSheet='
Set @iCount=1

--PRINT '@Layers'
--PRINT @Layers

While 1=1
Begin

   If Substring(@TmpStr,@iCount,1)='@'
   Begin
      If Substring(@TmpStr,@iCount+1,1)='T'
      Begin
         Set @SqlTxtTool=@SqlTxtTool+@TTT
         Set @iCount=@iCount+3
      End
      If Substring(@TmpStr,@iCount+1,1)='A'
      Begin
         Set @SqlTxtTool=@SqlTxtTool+@AAA
         Set @iCount=@iCount+3
      End
      If Substring(@TmpStr,@iCount+1,1)='E'
      Begin
         Set @SqlTxtTool=@SqlTxtTool+@EEE
         Set @iCount=@iCount+3
      End
      If Substring(@TmpStr,@iCount+1,1)='F'
      Begin
         Set @SqlTxtTool=@SqlTxtTool+''''+@FFF+''''
         Set @iCount=@iCount+3
      End
      If Substring(@TmpStr,@iCount+1,1)='H'
      Begin
	--PRINT 'HHH'
         Set @HHH='0'
         Set @TmpH=Substring(@TmpStr,@iCount,13)
         If @Layers=3
            Set @HHH=SubString(@TmpH,6,3)
         If @Layers=5
            Set @HHH=SubString(@TmpH,10,3)
         Set @SqlTxtTool=@SqlTxtTool+@HHH
         Set @iCount=@iCount+12
      End
   End
   Else
   Begin
      Set @SqlTxtTool=@SqlTxtTool+Substring(@TmpStr,@iCount,1)
   End

   Set @iCount=@iCount+1
   If @iCount>Len(@TmpStr)
      Break
End
--print '@SiPrcFlutType'
--print @SiPrcFlutType
--print '@SiPrcFlutType'


if @OuterOrInnerFlag = 0
Begin
	if isnull(@Num_LabChasbConst,0)>0
	Begin
		if @SiPrcFlutType=0
			SELECT @ToolConst=
				((2*Num_OuterLengthConst)+(2*Num_OuterWidthConst)+@Num_LabChasbConst)
			FROM Tss_PrcFlutType
			WHERE
				(SiPrcFlutType = (SELECT SiPrcFlutType FROM Tss_SalInvoice_Dt WHERE (SiSalInvoice_Dt = @SiSalInvoice_Dt)))
		Else
			SELECT @ToolConst=
				((2*Num_OuterLengthConst)+(2*Num_OuterWidthConst)+@Num_LabChasbConst)
			FROM Tss_PrcFlutType
			WHERE
				(SiPrcFlutType = @SiPrcFlutType)
	End
	Else
	Begin
		if @SiPrcFlutType=0
			SELECT @ToolConst=
				((2*Num_OuterLengthConst)+(2*Num_OuterWidthConst)+Num_LabChasbConst)
			FROM Tss_PrcFlutType
			WHERE
				(SiPrcFlutType = (SELECT SiPrcFlutType FROM Tss_SalInvoice_Dt WHERE (SiSalInvoice_Dt = @SiSalInvoice_Dt)))
		Else
			SELECT @ToolConst=
				((2*Num_OuterLengthConst)+(2*Num_OuterWidthConst)+Num_LabChasbConst)
			FROM Tss_PrcFlutType
			WHERE
				(SiPrcFlutType = @SiPrcFlutType)
	End
End
Else
Begin
	if isnull(@Num_LabChasbConst,0)>0
	Begin
		if @SiPrcFlutType=0
			SELECT @ToolConst=
				@Num_LabChasbConst
			FROM Tss_PrcFlutType
			WHERE
				(SiPrcFlutType = (SELECT SiPrcFlutType FROM Tss_SalInvoice_Dt WHERE (SiSalInvoice_Dt = @SiSalInvoice_Dt)))
		Else
			SELECT @ToolConst=
				@Num_LabChasbConst
			FROM Tss_PrcFlutType
			WHERE
				(SiPrcFlutType = @SiPrcFlutType)
	End
	Else
	Begin
		if @SiPrcFlutType=0
			SELECT @ToolConst=
				Num_LabChasbConst
			FROM Tss_PrcFlutType
			WHERE
				(SiPrcFlutType = (SELECT SiPrcFlutType FROM Tss_SalInvoice_Dt WHERE (SiSalInvoice_Dt = @SiSalInvoice_Dt)))
		Else
			SELECT @ToolConst=
				Num_LabChasbConst
			FROM Tss_PrcFlutType
			WHERE
				(SiPrcFlutType = @SiPrcFlutType)
	End
End

if @SiPrcGoodsType = 29 Set @ToolConst = 0

if len(Ltrim(Rtrim(@SqlTxtTool)))>18
	Set @SqlTxtTool = @SqlTxtTool +'+'+convert(varchar,@ToolConst)

exec sp_executesql @SqlTxtTool,N'@TolSheet numeric output', @TolSheet output


Set @TmpStr=Ltrim(Rtrim(@Des_WidthFormula))
Set @SqlTxtArzi='Set @ArzSheet='
Set @iCount=1
While 1=1
Begin
   If Substring(@TmpStr,@iCount,1)='@'
   Begin
      If Substring(@TmpStr,@iCount+1,1)='T'
      Begin
         Set @SqlTxtArzi=@SqlTxtArzi+@TTT
         Set @iCount=@iCount+3
      End
      If Substring(@TmpStr,@iCount+1,1)='A'
      Begin
         Set @SqlTxtArzi=@SqlTxtArzi+@AAA
         Set @iCount=@iCount+3
      End
      If Substring(@TmpStr,@iCount+1,1)='E'
      Begin
         Set @SqlTxtArzi=@SqlTxtArzi+@EEE
         Set @iCount=@iCount+3
      End
      If Substring(@TmpStr,@iCount+1,1)='F'
      Begin
         Set @SqlTxtArzi=@SqlTxtArzi+''''+@FFF+''''
         Set @iCount=@iCount+3
      End
      If Substring(@TmpStr,@iCount+1,1)='H'
      Begin
         Set @HHH='0'
         Set @TmpH=Substring(@TmpStr,@iCount,13)
         If @Layers=3
            Set @HHH=SubString(@TmpH,6,3)
         If @Layers=5
            Set @HHH=SubString(@TmpH,10,3)
         Set @SqlTxtArzi=@SqlTxtArzi+@HHH
         Set @iCount=@iCount+12
      End
   End
   Else
   Begin
      Set @SqlTxtArzi=@SqlTxtArzi+Substring(@TmpStr,@iCount,1)
   End
   Set @iCount=@iCount+1
   If @iCount>Len(@TmpStr)
      Break
End
--print @SqlTxtArzi
if SubString(@SqlTxtArzi,len(@ArzSheet),1)='+'
    SET @SqlTxtArzi = SubString(@SqlTxtArzi,1,len(@ArzSheet)-1)

if @SiPrcFlutType=0
Begin
	if @Num_DarbConst=0
		SELECT @Num_DarbConst=Num_DarbConst+@Num_SampleInnerWidth/2
		FROM Tss_PrcFlutType
		WHERE
			(SiPrcFlutType = (SELECT SiPrcFlutType FROM Tss_SalInvoice_Dt WHERE (SiSalInvoice_Dt = @SiSalInvoice_Dt)))
	
	if @Num_ErtefaConst=0
		SELECT @Num_ErtefaConst=Num_ErtefaConst+@Num_SampleInnerHeigth
		FROM Tss_PrcFlutType
		WHERE
			(SiPrcFlutType = (SELECT SiPrcFlutType FROM Tss_SalInvoice_Dt WHERE (SiSalInvoice_Dt = @SiSalInvoice_Dt)))
End
Else
Begin
	if @Num_DarbConst=0
		SELECT @Num_DarbConst=Num_DarbConst+@Num_SampleInnerWidth/2
		FROM Tss_PrcFlutType
		WHERE
			(SiPrcFlutType = @SiPrcFlutType)

	if @Num_ErtefaConst=0
		SELECT @Num_ErtefaConst=Num_ErtefaConst+@Num_SampleInnerHeigth
		FROM Tss_PrcFlutType
		WHERE
			(SiPrcFlutType = @SiPrcFlutType)
	if @SiPrcGoodsType = 29 
		SELECT @Num_ErtefaConst=@Num_SampleInnerHeigth - Num_ErtefaConst
		FROM Tss_PrcFlutType
		WHERE
			(SiPrcFlutType = @SiPrcFlutType)
end


if @OuterOrInnerFlag = 0
Begin
	if (@SiPrcGoodsType in 
			(SELECT SiPrcGoodsType
			FROM Tss_PrcGoodsType
			WHERE 
				(Cod_PrcGoodsTypeCode = '3') OR
				(Cod_PrcGoodsTypeCode = '35') OR
				(Cod_PrcGoodsTypeCode = '36') OR
				(Cod_PrcGoodsTypeCode = '65') OR
				(Cod_PrcGoodsTypeCode = '70') OR
				(Cod_PrcGoodsTypeCode = '71') OR
				(Cod_PrcGoodsTypeCode = '90') OR
				(Cod_PrcGoodsTypeCode = '93') OR
				(Cod_PrcGoodsTypeCode = '96') OR
				(Cod_PrcGoodsTypeCode = '97') OR
				(Cod_PrcGoodsTypeCode = '101') OR
				(Cod_PrcGoodsTypeCode = '4') OR
				(Cod_PrcGoodsTypeCode = '104') OR
				(Cod_PrcGoodsTypeCode = '68') OR
				(Cod_PrcGoodsTypeCode = '107'))
			)
		SELECT @ArzConst=(@Num_DarbConst-@Num_SampleInnerWidth/2)+(@Num_ErtefaConst-@Num_SampleInnerHeigth)
	if (@SiPrcGoodsType  not in 
			(SELECT SiPrcGoodsType
			FROM Tss_PrcGoodsType
			WHERE 
				(Cod_PrcGoodsTypeCode = '3') OR
				(Cod_PrcGoodsTypeCode = '35') OR
				(Cod_PrcGoodsTypeCode = '36') OR
				(Cod_PrcGoodsTypeCode = '65') OR
				(Cod_PrcGoodsTypeCode = '70') OR
				(Cod_PrcGoodsTypeCode = '71') OR
				(Cod_PrcGoodsTypeCode = '90') OR
				(Cod_PrcGoodsTypeCode = '93') OR
				(Cod_PrcGoodsTypeCode = '96') OR
				(Cod_PrcGoodsTypeCode = '97') OR
				(Cod_PrcGoodsTypeCode = '101') OR
				(Cod_PrcGoodsTypeCode = '4') OR
				(Cod_PrcGoodsTypeCode = '104') OR
				(Cod_PrcGoodsTypeCode = '68') OR
				(Cod_PrcGoodsTypeCode = '107'))
			)
		SELECT @ArzConst=(2*@Num_DarbConst-@Num_SampleInnerWidth)+(@Num_ErtefaConst-@Num_SampleInnerHeigth)
	
	if (len(Ltrim(Rtrim(@SqlTxtTool)))=23) Or (len(Ltrim(Rtrim(@SqlTxtTool)))=25)
		set @ArzConst=(@Num_DarbConst-@Num_SampleInnerWidth/2)+(@Num_ErtefaConst-@Num_SampleInnerHeigth)
	
	if (len(Ltrim(Rtrim(@SqlTxtTool)))=18)
		set @ArzConst=(@Num_ErtefaConst-@Num_SampleInnerHeigth)
End

if (len(Ltrim(Rtrim(@SqlTxtTool)))>18) and (@OuterOrInnerFlag=0)
	Set @SqlTxtArzi = @SqlTxtArzi +'+'+isnull(convert(varchar,@ArzConst),'')

if @TotalDarbBaz>=0
begin
    if (dbo.Tss_StdFindSubLoc(0) = 'aeen')  or (dbo.Tss_StdFindSubLoc(0) = 'delta')  or (dbo.Tss_StdFindSubLoc(0) = 'zarin') 
        Set @SqlTxtArzi=@SqlTxtArzi+'-'+isnull(Ltrim(Rtrim(Str(isnull(@TotalDarbBaz,0)))),0)+'+'+isnull(Ltrim(Rtrim(Str(isnull(@Num_WidthPert,0)))),0)
    else
        Set @SqlTxtArzi=@SqlTxtArzi+'-'+isnull(Ltrim(Rtrim(Str(isnull(@TotalDarbBaz,0)))),0)+'+'+isnull(Ltrim(Rtrim(Str(isnull(0,0)))),0)
end

if @TotalDarbBaz<0
begin
    if (dbo.Tss_StdFindSubLoc(0) = 'aeen')  or (dbo.Tss_StdFindSubLoc(0) = 'delta') or (dbo.Tss_StdFindSubLoc(0) = 'zarin')
	    Set @SqlTxtArzi=@SqlTxtArzi+'+(-1*'+isnull(Ltrim(Rtrim(Str(isnull(@TotalDarbBaz,0)))),0)+')'+'+'+isnull(Ltrim(Rtrim(Str(isnull(@Num_WidthPert,0)))),0)
    else
	    Set @SqlTxtArzi=@SqlTxtArzi+'+(-1*'+isnull(Ltrim(Rtrim(Str(isnull(@TotalDarbBaz,0)))),0)+')'+'+'+isnull(Ltrim(Rtrim(Str(isnull(0,0)))),0)
end

exec sp_executesql @SqlTxtArzi,N'@ArzSheet numeric output', @ArzSheet output



go

alter Procedure Tss_SalUntGdsFeeCalcStp
(
	@SiSalInvoice_Dt Numeric,
	@SiPrcGoodsType Numeric,
	@SiPubGoodsClassify Numeric,
	@SiPrcFlutType Numeric,
	@Num_SampleInnerLength Numeric,
	@Num_SampleInnerWidth Numeric,
	@Num_SampleInnerHeigth Numeric,
	@Num_ColoringRate numeric,
	@Num_SampleHoleNo numeric,
	@Sta_HasMangene smallint,
	@Sta_EttesalType smallint,
	@Sta_IsLipStick smallint,
	@Die_Len Numeric,
	@Die_Wdt Numeric,
	@NoInDie Numeric,
	@Sta_Cyan SmallInt, 
	@Sta_Magenta SmallInt, 
	@Sta_Yellow SmallInt, 
	@Sta_Black SmallInt, 
	@Sta_HasVerni SmallInt,    
	@Sta_PackType SmallInt, 
   @Num_OneMeterSheetPrice Numeric,   
   @Num_OneMeterBoxPrice Numeric,  
	@Num_UpDoorOpenSize Numeric=0, 
	@Num_DownDoorOpenSize Numeric=0, 
	@Num_PalleteNo Numeric=0,
   @Num_GdsAmountNo numeric=0,
   @CellophaneType smallint=0,
   @MatteOrGlossy smallint=0,
   @OffsetAreaType smallint=0,
	@OffsetHeightPrint numeric=0,
	@SiPubGoodsClassifyCardBox numeric,
	@PunchNo numeric,
    @LabConst numeric=0,
	@Gds_Len Numeric=0 OutPut,
	@Gds_Wdt Numeric=0 OutPut,
	@Gds_Fee Numeric=0 OutPut,
	@Col_Fee Numeric=0 OutPut,
	@Pal_Fee Numeric=0 OutPut,
	@Die_Fee Numeric=0 OutPut,
	@Lam_Fee numeric=0 OutPut,
	@OffSet_Fee numeric=0 OutPut,
	@LaminateWage numeric=0 OutPut,
	@CellophoneGlueMatteCost numeric=0 OutPut,
	@CellophoneGlueGlossyCost numeric=0 OutPut,
	@CellophoneThermalMatteCost numeric=0 OutPut,
	@CellophoneThermalGlossyCost numeric=0 OutPut,
	@LaminateBoxLockBottomCost numeric=0 OutPut,
	@LaminateBoxTwoPieceCost numeric=0 OutPut,
	@CardBoxPrice numeric=0 OutPut
)
As
Set @Gds_Len=0
Set @Gds_Wdt=0
Set @Gds_Fee=0
Set @Col_Fee=0
Set @Pal_Fee=0
Set @Die_Fee=0
Declare
	@Sta_DieOrNot SmallInt,
	@Sta_TipOfGoodsType SmallInt,
	@Des_LenghtFormula Varchar(500),
	@Des_WidthFormula Varchar(500),
	@Num_GoodsLength Numeric,
	@Num_GoodsWidth Numeric,
	@Num_NoInDie Numeric,
	@Area Numeric(30,4),
	@Gds_Area Numeric(30,4),
	@Prod_P Numeric,
	@ColorFee Numeric,
	@CardBoxPriceOut numeric,
	@PalleteFee numeric,
	@DieCut_Fee Numeric,
	@Laminate_Fee Numeric,
	@Num_FeeAdjust numeric,
	@LaminateType smallint,
	@OffSet_FeeOut numeric,
	@LaminateWageOut smallint,
	@CellophoneGlueMatteCostOut numeric,
	@CellophoneGlueGlossyCostOut numeric,
	@CellophoneThermalMatteCostOut numeric,
	@CellophoneThermalGlossyCostOut numeric,
	@LaminateBoxLockBottomCostOut numeric,
	@LaminateBoxTwoPieceCostOut numeric,
	@FeeHaml numeric

Set @Prod_P=0
Set @ColorFee=0
set @CardBoxPrice=0
Set @PalleteFee=0
Set @DieCut_Fee=0
Set @Laminate_Fee=0
Set @Num_FeeAdjust=0
Set @Num_GoodsLength=0
Set @Num_GoodsWidth=0



SELECT 
	@Des_LenghtFormula=Des_LenghtFormula, 
	@Des_WidthFormula=Des_WidthFormula, 
	@Sta_DieOrNot=Sta_DieOrNot, @Sta_TipOfGoodsType=Sta_TipOfGoodsType,
	@LaminateType=Sta_LaminateType
FROM 
	dbo.Tss_PrcGoodsType 
WHERE 
	(SiPrcGoodsType = @SiPrcGoodsType)


If @Sta_DieOrNot=0
Begin
    Exec dbo.Tss_SalGoodsCalcStp  
        @SiSalInvoice_Dt,  
        @SiPubGoodsClassify,    
        @SiPrcFlutType,					    
        @Num_SampleInnerLength,    
        @Num_SampleInnerWidth,    
        @Num_SampleInnerHeigth,    
        0,
        0,   
        @Des_LenghtFormula,    
        @Des_WidthFormula, 
        @Num_UpDoorOpenSize, 
        @Num_DownDoorOpenSize, 
        @SiPrcGoodsType,
        @LabConst,
        @Num_GoodsLength OutPut,    
        @Num_GoodsWidth OutPut    
End
Else
Begin
	Set @Num_GoodsLength=@Die_Len
	Set @Num_GoodsWidth=@Die_Wdt
	Set @Num_NoInDie=@NoInDie
	Set @Sta_DieOrNot=1
End
Set @Area=@Num_GoodsLength*@Num_GoodsWidth
Set @Gds_Area=(@Area/1000000.00)
Set @Prod_P=0
Set @ColorFee=0
Set @CardBoxPrice=0
Set @PalleteFee=0

Set @DieCut_Fee=0
set @Laminate_Fee=0
Exec dbo.Tss_SalGoodsPriceCalcStp
	@SiSalInvoice_Dt,
	@SiPubGoodsClassify,
	@Num_SampleInnerHeigth,
	@Num_ColoringRate,
	@Num_SampleHoleNo,
	@Sta_HasMangene,
	@Sta_EttesalType,
	@Num_FeeAdjust,
	@Sta_DieOrNot,
	@Sta_TipOfGoodsType,
	@Num_GoodsLength,
	@Num_GoodsWidth,
	@Area,
	@Sta_Cyan, 
	@Sta_Magenta, 
	@Sta_Yellow, 
	@Sta_Black, 
	@Sta_HasVerni, 
	@Sta_PackType,   
   @Num_OneMeterSheetPrice,   
   @Num_OneMeterBoxPrice,  
	0,
	@Num_PalleteNo,
	@Num_GdsAmountNo,
	@CellophaneType,
	@LaminateType,
	@MatteOrGlossy,
	@Num_NoInDie,
	@SiPrcGoodsType,
	@SiPubGoodsClassifyCardBox,
   @OffsetAreaType,
	@OffsetHeightPrint,
	@PunchNo,
	@Prod_P OutPut,
	@ColorFee OutPut,
	@CardBoxPriceOut OutPut,
	@PalleteFee OutPut,
	@DieCut_Fee OutPut,
	@Laminate_Fee OutPut,
	@OffSet_FeeOut OutPut,
	@LaminateWageOut OutPut,
	@CellophoneGlueMatteCostOut OutPut,
	@CellophoneGlueGlossyCostOut OutPut,
	@CellophoneThermalMatteCostOut OutPut,
	@CellophoneThermalGlossyCostOut OutPut,
	@LaminateBoxLockBottomCostOut OutPut,
	@LaminateBoxTwoPieceCostOut OutPut,
	@FeeHaml Output

Set @Gds_Len=@Num_GoodsLength
Set @Gds_Wdt=@Num_GoodsWidth
Set @Gds_Fee=@Prod_P
Set @Col_Fee=@ColorFee
Set @CardBoxPrice=@CardBoxPriceOut
Set @Pal_Fee=@PalleteFee
Set @Die_Fee=@DieCut_Fee
Set @Lam_Fee=@Laminate_Fee
Set @OffSet_Fee=@OffSet_FeeOut
Set @LaminateWage=@LaminateWageOut
Set @CellophoneGlueMatteCost=@CellophoneGlueMatteCostOut
Set @CellophoneGlueGlossyCost=@CellophoneGlueGlossyCostOut
Set @CellophoneThermalMatteCost=@CellophoneThermalMatteCostOut
Set @CellophoneThermalGlossyCost=@CellophoneThermalGlossyCostOut
Set @LaminateBoxLockBottomCost=@LaminateBoxLockBottomCostOut
Set @LaminateBoxTwoPieceCost=@LaminateBoxTwoPieceCostOut
Return

go

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Tss_LonUntLoansDtVStp]') AND type in (N'P', N'PC'))
BEGIN
    EXEC dbo.sp_executesql N'CREATE PROCEDURE [dbo].[Tss_LonUntLoansDtVStp]
    (
        @InternalWhere VarChar(8000)='''',
        @Where VarChar(8000)='''',
        @Order VarChar(8000)=''''
    ) AS 
    If @InternalWhere<>'''' 
        Set @InternalWhere='' Where ''+@InternalWhere
    If @Where<>'''' 
        Set @Where='' Where ''+@Where
    If @Order<>'''' 
        Set @Order='' Order By ''+@Order
    Exec(
        ''Select * From 
        (
        SELECT        
            SiLonLoans_Dt, 
            SiLonLoans, 
            Cod_LoansDtCode, 
            Dat_InstallmentDate, 
            Num_InstallmentBase, 
            Num_InstallmentProf, 
            Num_BaseRemain, 
            Num_ProfRemain
        FROM            
            Tss_LonLoansDt ''+@InternalWhere+''
        ) CalcSel '' + @Where + @Order
    )'
END

go

alter PROCEDURE dbo.Tss_LonUntLoansVStp
(
	@InternalWhere VarChar(8000)='',
	@Where VarChar(8000)='',
	@Order VarChar(8000)=''
) AS 
If @InternalWhere<>'' 
	Set @InternalWhere=' Where '+@InternalWhere
If @Where<>'' 
	Set @Where=' Where '+@Where
If @Order
<>'' 
	Set @Order=' Order By '+@Order
Exec(
	'Select * From 
	(
	SELECT        
		Tss_LonLoans.SiLonLoans, 
		Tss_LonLoans.StmLonLoans, 
		Tss_LonLoans.Cod_LoansCode, 
		Tss_LonLoans.Des_LoansDesc, 
		Tss_LonLoans.Num_LoansAmt, 
		Tss_LonLoans.Num_LoansInstalmentNo, 
		Tss_LonLoans.Sta_LoansStatus,
		Tss_LonLoans.SiPubCustomCodes, 
		Tss_LonLoans.SiPubPersonsSpec, 
		Tss_LonLoans.Sta_LoanType, 
		Tss_LonLoans.DateLoanStartDate, 
		Tss_LonLoans.Num_BreathDays, 
		Tss_LonLoans.Num_ProfInBreathDate,
		Tss_LonLoans.Num_PorfInInstallments,
		Tss_PubPersonsSpec.Cod_PubPersonCode, 
		Tss_PubPersonsSpec.Des_PubPersonName1,
		Tss_PubPersonsSpec.Des_PubPersonName2, 
		Tss_PubCustomCodes.Cod_CustomCodesCode, 
		Tss_PubCustomCodes.Des_CustomCodesDesc
	FROM            
		Tss_LonLoans LEFT OUTER JOIN
		Tss_PubPersonsSpec ON Tss_LonLoans.SiPubPersonsSpec = Tss_PubPersonsSpec.SiPubPersonsSpec LEFT OUTER JOIN
		Tss_PubCustomCodes ON Tss_LonLoans.SiPubCustomCodes = Tss_PubCustomCodes.SiPubCustomCodes '+@InternalWhere+'
	) CalcSel ' + @Where + @Order
)

go

alter Procedure dbo.Tss_LonUntLoansIudStp
(
	@Err_Code Int OutPut,
	@SiLonLoans Numeric OutPut,
	@Cod_LoansCode varchar(50)='',
	@Des_LoansDesc varchar(500)='',
	@Num_LoansAmt bigint=0,
	@Num_LoansInstalmentNo int=0,
	@Sta_LoansStatus smallint=0,
	@SiPubCustomCodes numeric=null, 
	@SiPubPersonsSpec numeric=null, 
	@Sta_LoanType smallint=0, 
	@DateLoanStartDate varchar(10)='', 
	@Num_BreathDays smallint=0, 
	@Num_ProfInBreathDate numeric=0,
	@Num_PorfInInstallments numeric=0,
	@StmLonLoans TimeStamp=0,
	@SiUser Numeric,
	@FlgInsUpdDel SmallInt
) As
If @FlgInsUpdDel=0
Begin
	Insert Into dbo.Tss_LonLoans
	(
		Cod_LoansCode,
		Des_LoansDesc,
		Num_LoansAmt,
		Num_LoansInstalmentNo,
		Sta_LoansStatus,
		SiPubCustomCodes, 
		SiPubPersonsSpec, 
		Sta_LoanType, 
		DateLoanStartDate, 
		Num_BreathDays, 
		Num_ProfInBreathDate,
		Num_PorfInInstallments
	)
	Values
	(
		@Cod_LoansCode,
		@Des_LoansDesc,
		@Num_LoansAmt,
		@Num_LoansInstalmentNo,
		@Sta_LoansStatus,
		@SiPubCustomCodes, 
		@SiPubPersonsSpec, 
		@Sta_LoanType, 
		@DateLoanStartDate, 
		@Num_BreathDays, 
		@Num_ProfInBreathDate,
		@Num_PorfInInstallments	)
	Set @SiLonLoans=Scope_Identity()
	If IsNull(@SiLonLoans,0)=0
	Begin
		Set @SiLonLoans=0
		Set @Err_Code=400
	End
	Return
End
If @FlgInsUpdDel=1
Begin
	Set @Err_Code=0
	If Exists(
	Select StmLonLoans From dbo.Tss_LonLoans
	Where (SiLonLoans=@SiLonLoans) And (StmLonLoans=@StmLonLoans))
	Begin
		Update dbo.Tss_LonLoans Set
			Cod_LoansCode=@Cod_LoansCode,
			Des_LoansDesc=@Des_LoansDesc,
			Num_LoansAmt=@Num_LoansAmt,
			Num_LoansInstalmentNo=@Num_LoansInstalmentNo,
			Sta_LoansStatus=@Sta_LoansStatus,
			SiPubCustomCodes=@SiPubCustomCodes, 
			SiPubPersonsSpec=@SiPubPersonsSpec, 
			Sta_LoanType=@Sta_LoanType, 
			DateLoanStartDate=@DateLoanStartDate, 
			Num_BreathDays=@Num_BreathDays, 
			Num_ProfInBreathDate=@Num_ProfInBreathDate,
			Num_PorfInInstallments=@Num_PorfInInstallments		
		Where (SiLonLoans=@SiLonLoans)
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
	Select StmLonLoans From dbo.Tss_LonLoans
	Where (SiLonLoans=@SiLonLoans) And (StmLonLoans=@StmLonLoans))
	Begin
		Delete From dbo.Tss_LonLoans
		Where (SiLonLoans=@SiLonLoans)
		Set @Err_Code=@@Error
		If @Err_Code<>0
			Set @Err_Code=4000
	End
	Else
		Set @Err_Code=4001
	Return
End

go

USE [TssEmpty]
GO

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Tss_LonLoansDt]') AND type in (N'U'))
	BEGIN
	CREATE TABLE [dbo].[Tss_LonLoansDt](
		[SiLonLoans_Dt] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
		[SiLonLoans] [numeric](18, 0) NULL,
		[Cod_LoansDtCode] [nchar](10) NULL,
		[Dat_InstallmentDate] [varchar](50) NULL,
		[Num_InstallmentBase] [numeric](18, 0) NULL,
		[Num_InstallmentProf] [numeric](18, 0) NULL,
		[Num_BaseRemain] [numeric](18, 0) NULL,
		[Num_ProfRemain] [numeric](18, 0) NULL,
		[StmLonLoans_Dt] [timestamp] NULL,
	CONSTRAINT [PK_Tss_LonLoansDt] PRIMARY KEY CLUSTERED 
	(
	[SiLonLoans_Dt] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
	) ON [PRIMARY]
    
    PRINT 'Table dbo.Tss_LonLoansDt created successfully.'
END
ELSE
BEGIN
    PRINT 'Table dbo.Tss_LonLoansDt already exists.'
END
GO

ALTER PROCEDURE Tss_RapUntPayedCheque_HdIudStp (
	@Err_Code INT OUTPUT,
	@SiRapPayedCheque NUMERIC OUTPUT,
	@SiRapChequesDefine NUMERIC = NULL,
	@SiPubPersonsSpec NUMERIC = NULL,
	@Cod_RapPayedChequeCode VARCHAR(50) = '',
	@Cod_RapPayedOrderCode VARCHAR(50) = '',
	@Des_RapPayedChequeDesc VARCHAR(500) = '',
	@Dat_RapPayedChequeRegDate VARCHAR(10) = '',
	@Cod_RapPayedChequeSerial VARCHAR(50) = '',
	@Dat_RapPayedChequeEndDate VARCHAR(10) = '',
	@Num_RapPayedChequeAmount NUMERIC = NULL,
	@Sta_RapPayedChequeState SMALLINT = 0,
	@Dat_RapPayedChequeCngDate VARCHAR(10) = '',
	@Dat_RapPayedChequeVosoolDate VARCHAR(10) = '',
	@Dat_RapPayedChequeCancelDate VARCHAR(10) = '',
	@SiPubSubLocations NUMERIC = 1,
	@Des_ChekDesc VARCHAR(1000) = '',
	@SiRapBehalfDefineHd NUMERIC = NULL,
	@SiRapPayedChequeRef_RefrenceHd NUMERIC = NULL,
    @Des_PayedChequeSayadiCode varchar(50)='',
    @Des_PayedChequeSayadiNationalCode varchar(50)='',
	@StmRapPayedCheque TIMESTAMP = 0,
	@SiUser NUMERIC,
	@FlgInsUpdDel SMALLINT
	)
AS
IF @FlgInsUpdDel = 0
BEGIN
	IF isnull(@Cod_RapPayedChequeCode, '') = ''
		SET @Cod_RapPayedChequeCode = (
				SELECT isnull(Max(convert(NUMERIC, Isnull(Cod_RapPayedChequeCode, 0))), 0) + 1
				FROM dbo.Tss_RapPayedCheque
				WHERE Cod_RapPayedChequeCode <> ''
				)

	INSERT INTO dbo.Tss_RapPayedCheque (
		SiRapChequesDefine,
		SiPubPersonsSpec,
		Cod_RapPayedChequeCode,
		Cod_RapPayedOrderCode,
		Des_RapPayedChequeDesc,
		Dat_RapPayedChequeRegDate,
		Cod_RapPayedChequeSerial,
		Dat_RapPayedChequeEndDate,
		Num_RapPayedChequeAmount,
		Sta_RapPayedChequeState,
		Dat_RapPayedChequeCngDate,
		Dat_RapPayedChequeVosoolDate,
		Dat_RapPayedChequeCancelDate,
		SiPubSubLocations,
		Des_ChekDesc,
		SiRapBehalfDefineHd,
		SiRapPayedChequeRef_RefrenceHd,
        Des_PayedChequeSayadiCode,
        Des_PayedChequeSayadiNationalCode
		)
	VALUES (
		@SiRapChequesDefine,
		@SiPubPersonsSpec,
		@Cod_RapPayedChequeCode,
		@Cod_RapPayedOrderCode,
		@Des_RapPayedChequeDesc,
		@Dat_RapPayedChequeRegDate,
		@Cod_RapPayedChequeSerial,
		@Dat_RapPayedChequeEndDate,
		@Num_RapPayedChequeAmount,
		@Sta_RapPayedChequeState,
		@Dat_RapPayedChequeCngDate,
		@Dat_RapPayedChequeVosoolDate,
		@Dat_RapPayedChequeCancelDate,
		@SiPubSubLocations,
		@Des_ChekDesc,
		@SiRapBehalfDefineHd,
		@SiRapPayedChequeRef_RefrenceHd,
        @Des_PayedChequeSayadiCode,
        @Des_PayedChequeSayadiNationalCode
		)

	SET @SiRapPayedCheque = Scope_Identity()

	IF IsNull(@SiRapPayedCheque, 0) <> 0
	BEGIN
		EXEC dbo.Tss_RapUntPayedCheque_DtIudStp 0,
			0,
			@SiRapPayedCheque,
			@SiRapBehalfDefineHd,
			@SiRapPayedChequeRef_RefrenceHd,
			@Num_RapPayedChequeAmount,
			'1',
			'',
			@SiPubPersonsSpec,
			NULL,
			NULL,
			0,
			@SiUser,
			0
	END

	IF IsNull(@SiRapPayedCheque, 0) = 0
	BEGIN
		SET @SiRapPayedCheque = 0
		SET @Err_Code = 400
	END

	RETURN
END

IF @FlgInsUpdDel = 1
BEGIN
    DECLARE
        @SiRapPayedChequeRef NUMERIC,
        @StmRapPayedChequeRef TIMESTAMP,
        @Cod_RapPayedChequeRefCode VARCHAR(50) = '',
        @Des_RapPayedChequeRefDesc VARCHAR(1000) = '',
        @SiPubPersonsSpecdt NUMERIC,
        @SiRapCashDefine NUMERIC,
        @SiPubCostCenter NUMERIC,
        @RowCount INT,
        @CurrentStmRapPayedCheque TIMESTAMP

    SET @Err_Code = 0

    -- Look up the row by key only (no timestamp in the WHERE yet) so we can
    -- tell "doesn't exist" apart from "exists but timestamp is stale".
    SELECT @CurrentStmRapPayedCheque = StmRapPayedCheque
    FROM dbo.Tss_RapPayedCheque
    WHERE SiRapPayedCheque = @SiRapPayedCheque;

    IF @CurrentStmRapPayedCheque IS NULL
    BEGIN
        -- ============================================================
        -- Row doesn't exist -> fall back to insert (same as @FlgInsUpdDel = 0)
        -- ============================================================
        IF isnull(@Cod_RapPayedChequeCode, '') = ''
            SET @Cod_RapPayedChequeCode = (
                    SELECT isnull(Max(convert(NUMERIC, Isnull(Cod_RapPayedChequeCode, 0))), 0) + 1
                    FROM dbo.Tss_RapPayedCheque
                    WHERE Cod_RapPayedChequeCode <> ''
                    )

        INSERT INTO dbo.Tss_RapPayedCheque (
            SiRapChequesDefine,
            SiPubPersonsSpec,
            Cod_RapPayedChequeCode,
            Cod_RapPayedOrderCode,
            Des_RapPayedChequeDesc,
            Dat_RapPayedChequeRegDate,
            Cod_RapPayedChequeSerial,
            Dat_RapPayedChequeEndDate,
            Num_RapPayedChequeAmount,
            Sta_RapPayedChequeState,
            Dat_RapPayedChequeCngDate,
            Dat_RapPayedChequeVosoolDate,
            Dat_RapPayedChequeCancelDate,
            SiPubSubLocations,
            Des_ChekDesc,
            SiRapBehalfDefineHd,
            SiRapPayedChequeRef_RefrenceHd,
            Des_PayedChequeSayadiCode,
            Des_PayedChequeSayadiNationalCode
            )
        VALUES (
            @SiRapChequesDefine,
            @SiPubPersonsSpec,
            @Cod_RapPayedChequeCode,
            @Cod_RapPayedOrderCode,
            @Des_RapPayedChequeDesc,
            @Dat_RapPayedChequeRegDate,
            @Cod_RapPayedChequeSerial,
            @Dat_RapPayedChequeEndDate,
            @Num_RapPayedChequeAmount,
            @Sta_RapPayedChequeState,
            @Dat_RapPayedChequeCngDate,
            @Dat_RapPayedChequeVosoolDate,
            @Dat_RapPayedChequeCancelDate,
            @SiPubSubLocations,
            @Des_ChekDesc,
            @SiRapBehalfDefineHd,
            @SiRapPayedChequeRef_RefrenceHd,
            @Des_PayedChequeSayadiCode,
            @Des_PayedChequeSayadiNationalCode
            )

        SET @SiRapPayedCheque = Scope_Identity()

        IF IsNull(@SiRapPayedCheque, 0) <> 0
        BEGIN
            EXEC dbo.Tss_RapUntPayedCheque_DtIudStp 0,
                0,
                @SiRapPayedCheque,
                @SiRapBehalfDefineHd,
                @SiRapPayedChequeRef_RefrenceHd,
                @Num_RapPayedChequeAmount,
                '1',
                '',
                @SiPubPersonsSpec,
                NULL,
                NULL,
                0,
                @SiUser,
                0
        END

        IF IsNull(@SiRapPayedCheque, 0) = 0
        BEGIN
            SET @SiRapPayedCheque = 0
            SET @Err_Code = 400
        END

        RETURN
    END

    IF @CurrentStmRapPayedCheque <> @StmRapPayedCheque
    BEGIN
        -- ============================================================
        -- Row exists but caller's timestamp is stale -> real concurrency conflict
        -- ============================================================
        SET @Err_Code = 403
        RETURN
    END

    -- ============================================================
    -- Row exists and timestamp matches -> normal update
    -- ============================================================
    UPDATE dbo.Tss_RapPayedCheque
    SET SiRapChequesDefine = @SiRapChequesDefine,
        SiPubPersonsSpec = @SiPubPersonsSpec,
        Cod_RapPayedChequeCode = @Cod_RapPayedChequeCode,
        Cod_RapPayedOrderCode = @Cod_RapPayedOrderCode,
        Des_RapPayedChequeDesc = @Des_RapPayedChequeDesc,
        Dat_RapPayedChequeRegDate = @Dat_RapPayedChequeRegDate,
        Cod_RapPayedChequeSerial = @Cod_RapPayedChequeSerial,
        Dat_RapPayedChequeEndDate = @Dat_RapPayedChequeEndDate,
        Num_RapPayedChequeAmount = @Num_RapPayedChequeAmount,
        Sta_RapPayedChequeState = @Sta_RapPayedChequeState,
        Dat_RapPayedChequeCngDate = @Dat_RapPayedChequeCngDate,
        Dat_RapPayedChequeVosoolDate = @Dat_RapPayedChequeVosoolDate,
        Dat_RapPayedChequeCancelDate = @Dat_RapPayedChequeCancelDate,
        SiPubSubLocations = @SiPubSubLocations,
        Des_ChekDesc = @Des_ChekDesc,
        SiRapBehalfDefineHd = @SiRapBehalfDefineHd,
        SiRapPayedChequeRef_RefrenceHd = @SiRapPayedChequeRef_RefrenceHd,
        Des_PayedChequeSayadiCode = @Des_PayedChequeSayadiCode,
        Des_PayedChequeSayadiNationalCode = @Des_PayedChequeSayadiNationalCode
    WHERE (SiRapPayedCheque = @SiRapPayedCheque)
      AND (StmRapPayedCheque = @StmRapPayedCheque)

    SELECT @RowCount = COUNT(*)
    FROM Tss_RapPayedChequeRef
    WHERE SiRapPayedCheque = @SiRapPayedCheque

    IF @RowCount = 1
    BEGIN
        SELECT TOP 1
            @SiRapPayedChequeRef = SiRapPayedChequeRef,
            @StmRapPayedChequeRef = StmRapPayedChequeRef,
            @Cod_RapPayedChequeRefCode = Cod_RapPayedChequeRefCode,
            @Des_RapPayedChequeRefDesc = Des_RapPayedChequeRefDesc,
            @SiPubPersonsSpecdt = SiPubPersonsSpec,
            @SiRapCashDefine = SiRapCashDefine,
            @SiPubCostCenter = SiPubCostCenter
        FROM
            dbo.Tss_RapPayedChequeRef
        WHERE
            SiRapPayedCheque = @SiRapPayedCheque;

        EXEC dbo.Tss_RapUntPayedCheque_DtIudStp
            0,
            @SiRapPayedChequeRef,
            @SiRapPayedCheque,
            @SiRapBehalfDefineHd,
            @SiRapPayedChequeRef_RefrenceHd,
            @Num_RapPayedChequeAmount,
            @Cod_RapPayedChequeRefCode,
            @Des_RapPayedChequeRefDesc,
            @SiPubPersonsSpecdt,
            @SiRapCashDefine,
            @SiPubCostCenter,
            @StmRapPayedChequeRef,
            @SiUser,
            1
    END
    ELSE IF @RowCount = 0
    BEGIN
        -- Header exists but somehow has no detail row -> create one
        -- (matches the pattern already used in Tss_RapUntCashRecievePayIudStp)
        EXEC dbo.Tss_RapUntPayedCheque_DtIudStp
            0,
            0,
            @SiRapPayedCheque,
            @SiRapBehalfDefineHd,
            @SiRapPayedChequeRef_RefrenceHd,
            @Num_RapPayedChequeAmount,
            '1',
            '',
            @SiPubPersonsSpec,
            NULL,
            NULL,
            0,
            @SiUser,
            0
    END

    SET @Err_Code = @@Error

    IF @Err_Code <> 0
        SET @Err_Code = 401

    RETURN
END

IF @FlgInsUpdDel = 2
BEGIN
	SET @Err_Code = 0

	IF EXISTS (
			SELECT StmRapPayedCheque
			FROM dbo.Tss_RapPayedCheque
			WHERE (SiRapPayedCheque = @SiRapPayedCheque)
				AND (StmRapPayedCheque = @StmRapPayedCheque)
			)
	BEGIN
		DELETE
		FROM dbo.Tss_RapPayedCheque
		WHERE (SiRapPayedCheque = @SiRapPayedCheque)

		SET @Err_Code = @@Error
        
		IF @Err_Code <> 0
			SET @Err_Code = 4000
	END
	ELSE
		SET @Err_Code = 4000

	RETURN
END

GO

alter PROCEDURE dbo.Tss_RapUntCashRecIudStp
(
    @Err_Code Int OutPut,
    @SiRapCashRecievePay Numeric OutPut,
    @SiRapCashDefine numeric,
    @SiPubPersonsSpec numeric,
    @Cod_RapCashRecPayCode varchar(50)='',
    @Des_RapCashRecPayDesc varchar(1000)='',
    @Sta_RapCashRecOrPayFlag smallint=0,
    @Sta_RapCashRecPayState smallint=1,
    @Dat_RapCashRecPayRegDate varchar(10)='',
    @Dat_RapCashRecPayCngDate varchar(10)='',
    @Num_RapCashRecPayAmount numeric=0,
    @Cod_BankBranchCashPayCode varchar(50)='',
    @Des_BankPayedCash varchar(200)='',
    @Des_RapCashRecPayGhabzDesc varchar(1000)='',
    @SiPubPersonsSpec2 numeric=null,
    @SiPubCustomCodes numeric=null,
    @Cod_CashPayedRecieptCode varchar(50)='',
    @Dat_PayDate varchar(10)='',
    @SiPubSubLocations numeric=1,
    @Sta_CashRecieptMainOrNot smallint=0,
    @SiRapBehalfDefineHd numeric=null,
    @SiRapCashRecievePayRef_refrenceHd numeric=null,
    @Sta_ConcurrentReceipt smallint=0,
    @StmRapCashRecievePay TimeStamp=0,
    @SiUser Numeric,
    @FlgInsUpdDel SmallInt
)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @TransactionCount INT = @@TRANCOUNT;

    IF @FlgInsUpdDel = 0 -- INSERT
    BEGIN
        BEGIN TRY
            IF @TransactionCount = 0
                BEGIN TRANSACTION;

            SET @Err_Code = 0;

            -- Handle code generation with transaction isolation
            IF ISNULL(@Cod_RapCashRecPayCode, '') = ''
            BEGIN
                SELECT @Cod_RapCashRecPayCode = MAX(CONVERT(NUMERIC, Cod_RapCashRecPayCode)) + 1
                FROM dbo.Tss_RapCashRecievePay WITH (UPDLOCK, HOLDLOCK)
                WHERE (LEFT(Dat_RapCashRecPayRegDate, 4) = LEFT(@Dat_RapCashRecPayRegDate, 4))
                    AND (Cod_RapCashRecPayCode <> '');
            END

            IF @Cod_RapCashRecPayCode IS NULL OR @Cod_RapCashRecPayCode = ''
                SET @Cod_RapCashRecPayCode = '1';

            INSERT INTO dbo.Tss_RapCashRecievePay
            (
                SiRapCashDefine,
                SiPubPersonsSpec,
                Cod_RapCashRecPayCode,
                Des_RapCashRecPayDesc,
                Sta_RapCashRecOrPayFlag,
                Sta_RapCashRecPayState,
                Dat_RapCashRecPayRegDate,
                Dat_RapCashRecPayCngDate,
                Num_RapCashRecPayAmount,
                Cod_BankBranchCashPayCode,
                Des_BankPayedCash,
                Des_RapCashRecPayGhabzDesc,
                SiPubPersonsSpec2,
                SiPubCustomCodes,
                Cod_CashPayedRecieptCode,
                Dat_PayDate,
                Sta_CashRecieptMainOrNot,
                SiPubSubLocations,
                SiRapBehalfDefineHd,
                SiRapCashRecievePayRef_refrenceHd,
                Sta_ConcurrentReceipt
            )
            VALUES
            (
                @SiRapCashDefine,
                @SiPubPersonsSpec,
                @Cod_RapCashRecPayCode,
                @Des_RapCashRecPayDesc,
                0,
                @Sta_RapCashRecPayState,
                @Dat_RapCashRecPayRegDate,
                GETDATE(),
                @Num_RapCashRecPayAmount,
                @Cod_BankBranchCashPayCode,
                @Des_BankPayedCash,
                @Des_RapCashRecPayGhabzDesc,
                @SiPubPersonsSpec2,
                @SiPubCustomCodes,
                @Cod_CashPayedRecieptCode,
                @Dat_PayDate,
                @Sta_CashRecieptMainOrNot,
                @SiPubSubLocations,
                @SiRapBehalfDefineHd,
                @SiRapCashRecievePayRef_refrenceHd,
                @Sta_ConcurrentReceipt
            );

            SET @SiRapCashRecievePay = SCOPE_IDENTITY();

            -- Insert detail record
            IF ISNULL(@SiRapCashRecievePay, 0) > 0
            BEGIN
                EXEC dbo.Tss_RapUntCashRecievePayRefIudStp
                    0,  
                    0,  
                    @SiRapBehalfDefineHd,  
                    @SiRapCashRecievePay,
                    @Num_RapCashRecPayAmount, 
                    @SiRapCashRecievePayRef_refrenceHd,
                    '1',
                    @Des_RapCashRecPayGhabzDesc,
                    @SiPubPersonsSpec2, 
                    @SiRapCashDefine,
                    null,
                    0,  
                    @SiUser,  
                    0;
                
                IF @Err_Code <> 0
                    RAISERROR('Error in detail insert', 16, 1);
            END

            IF ISNULL(@SiRapCashRecievePay, 0) = 0
            BEGIN
                SET @SiRapCashRecievePay = 0;
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
            SET @SiRapCashRecievePay = 0;

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

            DECLARE @CurrentStmRapCashRecievePay TimeStamp;
            DECLARE @RowCount INT;
            DECLARE @SiRapCashRecievePayRef NUMERIC;
            DECLARE @StmRapCashRecievePayRef TimeStamp;

            -- Check if record exists with proper locking
            SELECT @CurrentStmRapCashRecievePay = StmRapCashRecievePay 
            FROM dbo.Tss_RapCashRecievePay WITH (UPDLOCK, ROWLOCK) 
            WHERE SiRapCashRecievePay = @SiRapCashRecievePay;

            IF @CurrentStmRapCashRecievePay IS NULL
            BEGIN
                SET @Err_Code = 402;
                RAISERROR('Record not found', 16, 1);
            END
            ELSE IF @CurrentStmRapCashRecievePay <> @StmRapCashRecievePay
            BEGIN
                SET @Err_Code = 403;
                RAISERROR('Concurrent modification detected', 16, 1);
            END
            ELSE
            BEGIN
                -- Update main record
                UPDATE dbo.Tss_RapCashRecievePay SET
                    SiRapCashDefine = @SiRapCashDefine,
                    SiPubPersonsSpec = @SiPubPersonsSpec,
                    Cod_RapCashRecPayCode = @Cod_RapCashRecPayCode,
                    Des_RapCashRecPayDesc = @Des_RapCashRecPayDesc,
                    Sta_RapCashRecOrPayFlag = @Sta_RapCashRecOrPayFlag,
                    Sta_RapCashRecPayState = @Sta_RapCashRecPayState,
                    Dat_RapCashRecPayRegDate = @Dat_RapCashRecPayRegDate,
                    Dat_RapCashRecPayCngDate = @Dat_RapCashRecPayCngDate,
                    Num_RapCashRecPayAmount = @Num_RapCashRecPayAmount,
                    Cod_BankBranchCashPayCode = @Cod_BankBranchCashPayCode,
                    Des_BankPayedCash = @Des_BankPayedCash,
                    Des_RapCashRecPayGhabzDesc = @Des_RapCashRecPayGhabzDesc,
                    SiPubPersonsSpec2 = @SiPubPersonsSpec2,
                    SiPubCustomCodes = @SiPubCustomCodes,
                    Cod_CashPayedRecieptCode = @Cod_CashPayedRecieptCode,
                    Dat_PayDate = @Dat_PayDate,
                    Sta_CashRecieptMainOrNot = @Sta_CashRecieptMainOrNot,
                    SiPubSubLocations = @SiPubSubLocations,        
                    SiRapBehalfDefineHd = @SiRapBehalfDefineHd,
                    SiRapCashRecievePayRef_refrenceHd = @SiRapCashRecievePayRef_refrenceHd,
                    Sta_ConcurrentReceipt = @Sta_ConcurrentReceipt
                WHERE SiRapCashRecievePay = @SiRapCashRecievePay
                    AND StmRapCashRecievePay = @StmRapCashRecievePay;

                -- Check if detail record exists
                SELECT @RowCount = COUNT(*)
                FROM Tss_RapCashRecievePayRef
                WHERE SiRapCashRecievePay = @SiRapCashRecievePay

                IF @RowCount = 1 
                BEGIN
                    -- Get the first detail record
                    SELECT TOP 1 
                        @SiRapCashRecievePayRef = SiRapCashRecievePayRef, 
                        @StmRapCashRecievePayRef = StmRapCashRecievePayRef
                    FROM 
                        dbo.Tss_RapCashRecievePayRef 
                    WHERE 
                        SiRapCashRecievePay = @SiRapCashRecievePay;

                    -- Update the detail record
                    EXEC dbo.Tss_RapUntCashRecievePayRefIudStp
                        0,  
                        @SiRapCashRecievePayRef,  
                        @SiRapBehalfDefineHd,  
                        @SiRapCashRecievePay,
                        @Num_RapCashRecPayAmount, 
                        @SiRapCashRecievePayRef_refrenceHd,
                        '1',
                        @Des_RapCashRecPayGhabzDesc,
                        @SiPubPersonsSpec2, 
                        @SiRapCashDefine,
                        NULL,
                        @StmRapCashRecievePayRef,  
                        @SiUser,  
                        1;
                END
                ELSE IF @RowCount = 0
                BEGIN
                    -- No detail exists, insert one
                    EXEC dbo.Tss_RapUntCashRecievePayRefIudStp
                        0,  
                        0,  
                        @SiRapBehalfDefineHd,  
                        @SiRapCashRecievePay,
                        @Num_RapCashRecPayAmount, 
                        @SiRapCashRecievePayRef_refrenceHd,
                        '1',
                        @Des_RapCashRecPayGhabzDesc,
                        @SiPubPersonsSpec2, 
                        @SiRapCashDefine,
                        NULL,
                        0,  
                        @SiUser,  
                        0;
                END

                IF @Err_Code <> 0
                BEGIN
                    SET @Err_Code = 401;
                    RAISERROR('Error in detail operation', 16, 1);
                END
            END

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

            IF EXISTS (
                SELECT 1 
                FROM dbo.Tss_RapCashRecievePay WITH (UPDLOCK, ROWLOCK)
                WHERE SiRapCashRecievePay = @SiRapCashRecievePay 
                    AND StmRapCashRecievePay = @StmRapCashRecievePay
            )
            BEGIN
                -- Delete detail records first
                DELETE FROM dbo.Tss_RapCashRecievePayRef
                WHERE SiRapCashRecievePay = @SiRapCashRecievePay;
                
                DELETE FROM dbo.Tss_RapCashRecievePay
                WHERE SiRapCashRecievePay = @SiRapCashRecievePay;

                SET @Err_Code = @@ERROR;

                IF @Err_Code <> 0
                BEGIN
                    SET @Err_Code = 4000;
                    RAISERROR('Delete failed', 16, 1);
                END
            END
            ELSE
            BEGIN
                SET @Err_Code = 4001;
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

ALTER Procedure Tss_RapUntCashPayIudStp
(
	@Err_Code Int OutPut,
	@SiRapCashRecievePay Numeric OutPut,
	@SiRapCashDefine numeric=null,
	@SiPubSubLocations numeric=1,
	@SiPubPersonsSpec numeric=null,
	@Cod_RapCashRecPayCode varchar(50)='',
	@Des_RapCashRecPayDesc varchar(1000)='',
	@Sta_RapCashRecOrPayFlag smallint=1,
	@Sta_RapCashRecPayState smallint=0,
	@Dat_RapCashRecPayRegDate varchar(10)='',
	@Dat_RapCashRecPayCngDate varchar(10)='',
	@Num_RapCashRecPayAmount numeric=0,
	@Cod_BankBranchCashPayCode varchar(50)='',
	@Des_BankPayedCash varchar(200)='',
	@Des_RapCashRecPayGhabzDesc varchar(1000)='',
	@SiPubPersonsSpec2 numeric=null,
	@SiPubPersonsSpec3 numeric=null,
	@SiPubCustomCodes numeric=null,
	@Cod_CashPayedRecieptCode varchar(50)='',
	@Dat_PayDate varchar(10)='',
	@Sta_CashRecieptType smallint=0,
	@SiRapBehalfDefineHd numeric=null,
	@SiRapCashRecievePayRef_refrenceHd numeric=null, 
	@SiPubCostCenter numeric=null,
    @SiRapPaymentAuthorization numeric=null,
	@StmRapCashRecievePay TimeStamp=0,
	@SiUser Numeric,
	@FlgInsUpdDel SmallInt
) As
If @FlgInsUpdDel=0
Begin
	Insert Into dbo.Tss_RapCashRecievePay
	(
		SiRapCashDefine,
		SiPubPersonsSpec,
		SiPubSubLocations,
		Cod_RapCashRecPayCode,
		Des_RapCashRecPayDesc,
		Sta_RapCashRecOrPayFlag,
		Sta_RapCashRecPayState,
		Dat_RapCashRecPayRegDate,
		Dat_RapCashRecPayCngDate,
		Num_RapCashRecPayAmount,
		Cod_BankBranchCashPayCode,
		Des_BankPayedCash,
		Des_RapCashRecPayGhabzDesc,
		SiPubPersonsSpec2,
		SiPubPersonsSpec3,
		SiPubCustomCodes,
		Cod_CashPayedRecieptCode,
		Dat_PayDate,
		Sta_CashRecieptType,
		SiRapBehalfDefineHd,
		SiRapCashRecievePayRef_refrenceHd,
		SiPubCostCenter,
        SiRapPaymentAuthorization
	)
	Values
	(
		@SiRapCashDefine,
		@SiPubPersonsSpec,
		@SiPubSubLocations,
		@Cod_RapCashRecPayCode,
		@Des_RapCashRecPayDesc,
		1,
		@Sta_RapCashRecPayState,
		@Dat_RapCashRecPayRegDate,
		@Dat_RapCashRecPayCngDate,
		@Num_RapCashRecPayAmount,
		@Cod_BankBranchCashPayCode,
		@Des_BankPayedCash,		
		@Des_RapCashRecPayGhabzDesc,
		@SiPubPersonsSpec2,
		@SiPubPersonsSpec3,
		@SiPubCustomCodes,
		@Cod_CashPayedRecieptCode,
		@Dat_PayDate,
		@Sta_CashRecieptType,
		@SiRapBehalfDefineHd,
		@SiRapCashRecievePayRef_refrenceHd,
		@SiPubCostCenter,
        @SiRapPaymentAuthorization
	)
	Set @SiRapCashRecievePay=Scope_Identity()


	 If IsNull(@SiRapCashRecievePay,0)<>0
	 Begin
	 	exec dbo.Tss_RapUntCashRecievePayRefIudStp
		 0,  
		 0,  
		 @SiRapBehalfDefineHd,  
		 @SiRapCashRecievePay,
		 @Num_RapCashRecPayAmount,
		 @SiRapCashRecievePayRef_refrenceHd,
		 '1',
		 @Des_RapCashRecPayDesc,
		 @SiPubPersonsSpec,
		 @SiRapCashDefine,
		 @SiPubCostCenter,
		 0,  
		 @SiUser,  
		 0
	 End 

	If IsNull(@SiRapCashRecievePay,0)=0
	Begin
		Set @SiRapCashRecievePay=0
		Set @Err_Code=400	
	End
	Return
End
If @FlgInsUpdDel=1
Begin
	DECLARE 
		@CurrentStmRapCashRecievePay TimeStamp,
		@RowCount INT,
		@SiRapCashRecievePayRef numeric,
		@StmRapCashRecievePayRef timestamp,
		@Cod_RapCashRecievePayRefCode varchar(50),
		@Des_RapCashRecievePayRefDesc varchar(1000),
		@SiPubPersonsSpecdt NUMERIC,
		@SiRapCashDefinedt NUMERIC,
		@SiPubCostCenterdt NUMERIC

	Set @Err_Code=0

	-- Look up by key only first, so "not found" and "stale timestamp" can be
	-- told apart instead of both collapsing into the same error code.
	SELECT @CurrentStmRapCashRecievePay = StmRapCashRecievePay
	FROM dbo.Tss_RapCashRecievePay
	WHERE SiRapCashRecievePay = @SiRapCashRecievePay

	IF @CurrentStmRapCashRecievePay IS NULL
	BEGIN
		-- ============================================================
		-- Row doesn't exist -> fall back to insert (same as @FlgInsUpdDel = 0)
		-- ============================================================
		Insert Into dbo.Tss_RapCashRecievePay
		(
			SiRapCashDefine,
			SiPubPersonsSpec,
			SiPubSubLocations,
			Cod_RapCashRecPayCode,
			Des_RapCashRecPayDesc,
			Sta_RapCashRecOrPayFlag,
			Sta_RapCashRecPayState,
			Dat_RapCashRecPayRegDate,
			Dat_RapCashRecPayCngDate,
			Num_RapCashRecPayAmount,
			Cod_BankBranchCashPayCode,
			Des_BankPayedCash,
			Des_RapCashRecPayGhabzDesc,
			SiPubPersonsSpec2,
			SiPubPersonsSpec3,
			SiPubCustomCodes,
			Cod_CashPayedRecieptCode,
			Dat_PayDate,
			Sta_CashRecieptType,
			SiRapBehalfDefineHd,
			SiRapCashRecievePayRef_refrenceHd,
			SiPubCostCenter,
			SiRapPaymentAuthorization
		)
		Values
		(
			@SiRapCashDefine,
			@SiPubPersonsSpec,
			@SiPubSubLocations,
			@Cod_RapCashRecPayCode,
			@Des_RapCashRecPayDesc,
			@Sta_RapCashRecOrPayFlag,
			@Sta_RapCashRecPayState,
			@Dat_RapCashRecPayRegDate,
			@Dat_RapCashRecPayCngDate,
			@Num_RapCashRecPayAmount,
			@Cod_BankBranchCashPayCode,
			@Des_BankPayedCash,
			@Des_RapCashRecPayGhabzDesc,
			@SiPubPersonsSpec2,
			@SiPubPersonsSpec3,
			@SiPubCustomCodes,
			@Cod_CashPayedRecieptCode,
			@Dat_PayDate,
			@Sta_CashRecieptType,
			@SiRapBehalfDefineHd,
			@SiRapCashRecievePayRef_refrenceHd,
			@SiPubCostCenter,
			@SiRapPaymentAuthorization
		)
		Set @SiRapCashRecievePay=Scope_Identity()

		If IsNull(@SiRapCashRecievePay,0)<>0
		Begin
			exec dbo.Tss_RapUntCashRecievePayRefIudStp
			 0,  
			 0,  
			 @SiRapBehalfDefineHd,  
			 @SiRapCashRecievePay,
			 @Num_RapCashRecPayAmount,
			 @SiRapCashRecievePayRef_refrenceHd,
			 '1',
			 @Des_RapCashRecPayDesc,
			 @SiPubPersonsSpec,
			 @SiRapCashDefine,
			 @SiPubCostCenter,
			 0,  
			 @SiUser,  
			 0
		End

		If IsNull(@SiRapCashRecievePay,0)=0
		Begin
			Set @SiRapCashRecievePay=0
			Set @Err_Code=400
		End

		Return
	END

	IF @CurrentStmRapCashRecievePay <> @StmRapCashRecievePay
	BEGIN
		-- ============================================================
		-- Row exists but caller's timestamp is stale -> real concurrency conflict
		-- ============================================================
		Set @Err_Code=403
		Return
	END

	-- ============================================================
	-- Row exists and timestamp matches -> normal update
	-- ============================================================
	Update dbo.Tss_RapCashRecievePay Set
		SiRapCashDefine=@SiRapCashDefine,
		SiPubPersonsSpec=@SiPubPersonsSpec,
		SiPubSubLocations=@SiPubSubLocations,
		Cod_RapCashRecPayCode=@Cod_RapCashRecPayCode,
		Des_RapCashRecPayDesc=@Des_RapCashRecPayDesc,
		Sta_RapCashRecOrPayFlag=@Sta_RapCashRecOrPayFlag,
		Sta_RapCashRecPayState=@Sta_RapCashRecPayState,
		Dat_RapCashRecPayRegDate=@Dat_RapCashRecPayRegDate,
		Dat_RapCashRecPayCngDate=@Dat_RapCashRecPayCngDate,
		Num_RapCashRecPayAmount=@Num_RapCashRecPayAmount,
		Cod_BankBranchCashPayCode=@Cod_BankBranchCashPayCode,
		Des_BankPayedCash=@Des_BankPayedCash,
		Des_RapCashRecPayGhabzDesc=@Des_RapCashRecPayGhabzDesc,
		SiPubPersonsSpec2=@SiPubPersonsSpec2,
		SiPubPersonsSpec3=@SiPubPersonsSpec3,
		SiPubCustomCodes=@SiPubCustomCodes,
		Cod_CashPayedRecieptCode=@Cod_CashPayedRecieptCode,
		Dat_PayDate=@Dat_PayDate,
		Sta_CashRecieptType=@Sta_CashRecieptType,
		SiRapBehalfDefineHd=@SiRapBehalfDefineHd,
		SiRapCashRecievePayRef_refrenceHd=@SiRapCashRecievePayRef_refrenceHd,
		SiPubCostCenter=@SiPubCostCenter,
        SiRapPaymentAuthorization=@SiRapPaymentAuthorization
	Where (SiRapCashRecievePay=@SiRapCashRecievePay)

	SELECT @RowCount = COUNT(*)
	FROM Tss_RapCashRecievePayRef
	WHERE SiRapCashRecievePay = @SiRapCashRecievePay

	IF @RowCount = 1 
	BEGIN
		SELECT TOP 1 
			@SiRapCashRecievePayRef = SiRapCashRecievePayRef, 
			@StmRapCashRecievePayRef = StmRapCashRecievePayRef,
			@Cod_RapCashRecievePayRefCode = Cod_RapCashRecievePayRefCode,
			@Des_RapCashRecievePayRefDesc = Des_RapCashRecievePayRefDesc,
			@SiPubPersonsSpecdt = SiPubPersonsSpec,
			@SiRapCashDefinedt = SiRapCashDefine,
			@SiPubCostCenterdt = SiPubCostCenter
		FROM 
			dbo.Tss_RapCashRecievePayRef
		WHERE 
			SiRapCashRecievePay = @SiRapCashRecievePay

		exec dbo.Tss_RapUntCashRecievePayRefIudStp
			0,  
			@SiRapCashRecievePayRef,  
			@SiRapBehalfDefineHd,  
			@SiRapCashRecievePay,
			@Num_RapCashRecPayAmount, 
			@SiRapCashRecievePayRef_refrenceHd,
			'1',
			@Des_RapCashRecPayGhabzDesc,
			@SiPubPersonsSpec2, 
			@SiRapCashDefine,
			null,
			@StmRapCashRecievePayRef,  
			@SiUser,  
			1
	END
	ELSE IF @RowCount = 0
	BEGIN
		-- Header exists but has no detail row -> create one
		exec dbo.Tss_RapUntCashRecievePayRefIudStp
			0,  
			0,  
			@SiRapBehalfDefineHd,  
			@SiRapCashRecievePay,
			@Num_RapCashRecPayAmount,
			@SiRapCashRecievePayRef_refrenceHd,
			'1',
			@Des_RapCashRecPayGhabzDesc,
			@SiPubPersonsSpec2,
			@SiRapCashDefine,
			null,
			0,  
			@SiUser,  
			0
	END

	Set @Err_Code=@@Error
	If @Err_Code<>0
		Set @Err_Code=401
	Return
End
If @FlgInsUpdDel=2
Begin


	Set @Err_Code=0
	If Exists(
	Select StmRapCashRecievePay 
	From dbo.Tss_RapCashRecievePay
	Where (SiRapCashRecievePay=@SiRapCashRecievePay) And (StmRapCashRecievePay=@StmRapCashRecievePay))
	Begin
		Delete From dbo.Tss_RapCashRecievePay
		Where (SiRapCashRecievePay=@SiRapCashRecievePay)
		Set @Err_Code=@@Error
	



	If @Err_Code<>0
			Set @Err_Code=4000
	End
	Else
		Set @Err_Code=4001
	Return
End

GO

-- =====================================================================
-- Ensure the stored procedure exists; if not, create a dummy version.
-- =====================================================================
IF OBJECT_ID('dbo.Tss_LonUntLoansDtIudStp', 'P') IS NULL
BEGIN
    EXEC('
        CREATE PROCEDURE dbo.Tss_LonUntLoansDtIudStp
        AS
        BEGIN
            SELECT 1;   -- dummy body
        END
    ');
END
GO

-- =====================================================================
-- Alter the procedure to the final definition.
-- =====================================================================
ALTER PROCEDURE dbo.Tss_LonUntLoansDtIudStp
(
    @Err_Code              Int           OUTPUT,
    @SiLonLoans_Dt         Numeric       OUTPUT,
    @SiLonLoans            Numeric       = 0,
    @Cod_LoansDtCode       VARCHAR(50)   = '',        -- Code for the installment
    @Dat_InstallmentDate   VARCHAR(10)   = '',
    @Num_InstallmentBase   Numeric       = 0,
    @Num_InstallmentProf   Numeric       = 0,
    @Num_BaseRemain        Numeric       = 0,
    @Num_ProfRemain        Numeric       = 0,
    @StmLonLoans_Dt        TIMESTAMP     = 0,
    @SiUser                Numeric,
    @FlgInsUpdDel          SmallInt
)
AS
BEGIN
    SET NOCOUNT ON;

    -- ============================================================
    -- INSERT
    -- ============================================================
    IF @FlgInsUpdDel = 0
    BEGIN
        SET @Err_Code = 0;

        INSERT INTO dbo.Tss_LonLoansDt
        (
            SiLonLoans,
            Cod_LoansDtCode,
            Dat_InstallmentDate,
            Num_InstallmentBase,
            Num_InstallmentProf,
            Num_BaseRemain,
            Num_ProfRemain
        )
        VALUES
        (
            @SiLonLoans,
            @Cod_LoansDtCode,
            @Dat_InstallmentDate,
            @Num_InstallmentBase,
            @Num_InstallmentProf,
            @Num_BaseRemain,
            @Num_ProfRemain
        );

        SET @SiLonLoans_Dt = SCOPE_IDENTITY();

        IF ISNULL(@SiLonLoans_Dt, 0) = 0
        BEGIN
            SET @SiLonLoans_Dt = 0;
            SET @Err_Code = 400;
        END

        RETURN;
    END

    -- ============================================================
    -- UPDATE
    -- ============================================================
    IF @FlgInsUpdDel = 1
    BEGIN
        SET @Err_Code = 0;

        IF EXISTS
        (
            SELECT StmLonLoans_Dt
            FROM dbo.Tss_LonLoansDt
            WHERE SiLonLoans_Dt = @SiLonLoans_Dt
              AND StmLonLoans_Dt = @StmLonLoans_Dt
        )
        BEGIN
            UPDATE dbo.Tss_LonLoansDt
            SET SiLonLoans         = @SiLonLoans,
                Cod_LoansDtCode    = @Cod_LoansDtCode,
                Dat_InstallmentDate = @Dat_InstallmentDate,
                Num_InstallmentBase = @Num_InstallmentBase,
                Num_InstallmentProf = @Num_InstallmentProf,
                Num_BaseRemain     = @Num_BaseRemain,
                Num_ProfRemain     = @Num_ProfRemain
            WHERE SiLonLoans_Dt = @SiLonLoans_Dt;

            SET @Err_Code = @@ERROR;
            IF @Err_Code <> 0
                SET @Err_Code = 401;
        END
        ELSE
        BEGIN
            SET @Err_Code = 402;
        END

        RETURN;
    END

    -- ============================================================
    -- DELETE
    -- ============================================================
    IF @FlgInsUpdDel = 2
    BEGIN
        SET @Err_Code = 0;

        IF EXISTS
        (
            SELECT StmLonLoans_Dt
            FROM dbo.Tss_LonLoansDt
            WHERE SiLonLoans_Dt = @SiLonLoans_Dt
              AND StmLonLoans_Dt = @StmLonLoans_Dt
        )
        BEGIN
            DELETE FROM dbo.Tss_LonLoansDt
            WHERE SiLonLoans_Dt = @SiLonLoans_Dt;

            SET @Err_Code = @@ERROR;
            IF @Err_Code <> 0
                SET @Err_Code = 4000;
        END
        ELSE
        BEGIN
            SET @Err_Code = 4001;
        END

        RETURN;
    END

    -- If none of the above, return with an error (optional)
    SET @Err_Code = 999; -- Unknown operation
END

GO

-- Script to create or alter the Tss_GenDates table

DECLARE @TableName NVARCHAR(128) = 'Tss_GenDates'
DECLARE @SchemaName NVARCHAR(128) = 'dbo'
DECLARE @FullTableName NVARCHAR(256) = @SchemaName + '.' + @TableName

-- Check if table exists
IF NOT EXISTS (
    SELECT 1 
    FROM sys.objects 
    WHERE object_id = OBJECT_ID(@FullTableName) 
    AND type = 'U'
)
BEGIN
    -- Table doesn't exist, create it
    PRINT 'Table ' + @FullTableName + ' does not exist. Creating...'
    
    CREATE TABLE [dbo].[Tss_GenDates](
        [SiGenDates] [numeric](18, 0) IDENTITY(1,1) NOT NULL,
        [Dat_GenShamsiDate] [varchar](10) NOT NULL,
        [Dat_GenMiladiDate] [varchar](10) NOT NULL,
        [Dat_GenGhamariDate] [varchar](500) NULL,
        [Num_GenDayNo] [smallint] NOT NULL,
        [IsHoliday] [bit] NULL,
        [HolidayTitle] [nvarchar](500) NULL,
        [StmGenDates] [timestamp] NULL,
        CONSTRAINT [PK_TSS_GENDATES] PRIMARY KEY CLUSTERED 
        (
            [SiGenDates] ASC
        ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    ) ON [PRIMARY]
    
    PRINT 'Table ' + @FullTableName + ' created successfully.'
END
ELSE
BEGIN
    -- Table exists, compare and apply changes
    PRINT 'Table ' + @FullTableName + ' exists. Checking for differences...'
    
    -- 1. Check and add missing columns
    -- SiGenDates
    IF NOT EXISTS (
        SELECT 1 
        FROM sys.columns 
        WHERE object_id = OBJECT_ID(@FullTableName) 
        AND name = 'SiGenDates'
    )
    BEGIN
        PRINT 'Adding column SiGenDates...'
        ALTER TABLE [dbo].[Tss_GenDates] 
        ADD [SiGenDates] [numeric](18, 0) IDENTITY(1,1) NOT NULL
    END
    
    -- Dat_GenShamsiDate
    IF NOT EXISTS (
        SELECT 1 
        FROM sys.columns 
        WHERE object_id = OBJECT_ID(@FullTableName) 
        AND name = 'Dat_GenShamsiDate'
    )
    BEGIN
        PRINT 'Adding column Dat_GenShamsiDate...'
        ALTER TABLE [dbo].[Tss_GenDates] 
        ADD [Dat_GenShamsiDate] [varchar](10) NOT NULL
    END
    
    -- Dat_GenMiladiDate
    IF NOT EXISTS (
        SELECT 1 
        FROM sys.columns 
        WHERE object_id = OBJECT_ID(@FullTableName) 
        AND name = 'Dat_GenMiladiDate'
    )
    BEGIN
        PRINT 'Adding column Dat_GenMiladiDate...'
        ALTER TABLE [dbo].[Tss_GenDates] 
        ADD [Dat_GenMiladiDate] [varchar](10) NOT NULL
    END
    
    -- Dat_GenGhamariDate
    IF NOT EXISTS (
        SELECT 1 
        FROM sys.columns 
        WHERE object_id = OBJECT_ID(@FullTableName) 
        AND name = 'Dat_GenGhamariDate'
    )
    BEGIN
        PRINT 'Adding column Dat_GenGhamariDate...'
        ALTER TABLE [dbo].[Tss_GenDates] 
        ADD [Dat_GenGhamariDate] [varchar](500) NULL
    END
    
    -- Num_GenDayNo
    IF NOT EXISTS (
        SELECT 1 
        FROM sys.columns 
        WHERE object_id = OBJECT_ID(@FullTableName) 
        AND name = 'Num_GenDayNo'
    )
    BEGIN
        PRINT 'Adding column Num_GenDayNo...'
        ALTER TABLE [dbo].[Tss_GenDates] 
        ADD [Num_GenDayNo] [smallint] NOT NULL
    END
    
    -- IsHoliday
    IF NOT EXISTS (
        SELECT 1 
        FROM sys.columns 
        WHERE object_id = OBJECT_ID(@FullTableName) 
        AND name = 'IsHoliday'
    )
    BEGIN
        PRINT 'Adding column IsHoliday...'
        ALTER TABLE [dbo].[Tss_GenDates] 
        ADD [IsHoliday] [bit] NULL
    END
    
    -- HolidayTitle
    IF NOT EXISTS (
        SELECT 1 
        FROM sys.columns 
        WHERE object_id = OBJECT_ID(@FullTableName) 
        AND name = 'HolidayTitle'
    )
    BEGIN
        PRINT 'Adding column HolidayTitle...'
        ALTER TABLE [dbo].[Tss_GenDates] 
        ADD [HolidayTitle] [nvarchar](500) NULL
    END
    
    -- StmGenDates
    IF NOT EXISTS (
        SELECT 1 
        FROM sys.columns 
        WHERE object_id = OBJECT_ID(@FullTableName) 
        AND name = 'StmGenDates'
    )
    BEGIN
        PRINT 'Adding column StmGenDates...'
        ALTER TABLE [dbo].[Tss_GenDates] 
        ADD [StmGenDates] [timestamp] NULL
    END
    
    -- 2. Check and modify column data types if needed
    
    -- Check Dat_GenShamsiDate
    IF EXISTS (
        SELECT 1 
        FROM sys.columns c
        INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
        WHERE c.object_id = OBJECT_ID(@FullTableName) 
        AND c.name = 'Dat_GenShamsiDate'
        AND (t.name != 'varchar' OR c.max_length != 10 OR c.is_nullable != 0)
    )
    BEGIN
        PRINT 'Modifying column Dat_GenShamsiDate data type...'
        ALTER TABLE [dbo].[Tss_GenDates] 
        ALTER COLUMN [Dat_GenShamsiDate] [varchar](10) NOT NULL
    END
    
    -- Check Dat_GenMiladiDate
    IF EXISTS (
        SELECT 1 
        FROM sys.columns c
        INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
        WHERE c.object_id = OBJECT_ID(@FullTableName) 
        AND c.name = 'Dat_GenMiladiDate'
        AND (t.name != 'varchar' OR c.max_length != 10 OR c.is_nullable != 0)
    )
    BEGIN
        PRINT 'Modifying column Dat_GenMiladiDate data type...'
        ALTER TABLE [dbo].[Tss_GenDates] 
        ALTER COLUMN [Dat_GenMiladiDate] [varchar](10) NOT NULL
    END
    
    -- Check Dat_GenGhamariDate
    IF EXISTS (
        SELECT 1 
        FROM sys.columns c
        INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
        WHERE c.object_id = OBJECT_ID(@FullTableName) 
        AND c.name = 'Dat_GenGhamariDate'
        AND (t.name != 'varchar' OR c.max_length != 500 OR c.is_nullable != 1)
    )
    BEGIN
        PRINT 'Modifying column Dat_GenGhamariDate data type...'
        ALTER TABLE [dbo].[Tss_GenDates] 
        ALTER COLUMN [Dat_GenGhamariDate] [varchar](500) NULL
    END
    
    -- Check Num_GenDayNo
    IF EXISTS (
        SELECT 1 
        FROM sys.columns c
        INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
        WHERE c.object_id = OBJECT_ID(@FullTableName) 
        AND c.name = 'Num_GenDayNo'
        AND (t.name != 'smallint' OR c.is_nullable != 0)
    )
    BEGIN
        PRINT 'Modifying column Num_GenDayNo data type...'
        ALTER TABLE [dbo].[Tss_GenDates] 
        ALTER COLUMN [Num_GenDayNo] [smallint] NOT NULL
    END
    
    -- Check IsHoliday
    IF EXISTS (
        SELECT 1 
        FROM sys.columns c
        INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
        WHERE c.object_id = OBJECT_ID(@FullTableName) 
        AND c.name = 'IsHoliday'
        AND (t.name != 'bit' OR c.is_nullable != 1)
    )
    BEGIN
        PRINT 'Modifying column IsHoliday data type...'
        ALTER TABLE [dbo].[Tss_GenDates] 
        ALTER COLUMN [IsHoliday] [bit] NULL
    END
    
    -- Check HolidayTitle
    IF EXISTS (
        SELECT 1 
        FROM sys.columns c
        INNER JOIN sys.types t ON c.user_type_id = t.user_type_id
        WHERE c.object_id = OBJECT_ID(@FullTableName) 
        AND c.name = 'HolidayTitle'
        AND (t.name != 'nvarchar' OR c.max_length != 1000 OR c.is_nullable != 1)
    )
    BEGIN
        PRINT 'Modifying column HolidayTitle data type...'
        ALTER TABLE [dbo].[Tss_GenDates] 
        ALTER COLUMN [HolidayTitle] [nvarchar](500) NULL
    END
    
    -- 3. Check and create primary key if missing
    IF NOT EXISTS (
        SELECT 1 
        FROM sys.key_constraints 
        WHERE parent_object_id = OBJECT_ID(@FullTableName) 
        AND type = 'PK'
        AND name = 'PK_TSS_GENDATES'
    )
    BEGIN
        PRINT 'Creating primary key PK_TSS_GENDATES...'
        ALTER TABLE [dbo].[Tss_GenDates]
        ADD CONSTRAINT [PK_TSS_GENDATES] PRIMARY KEY CLUSTERED 
        (
            [SiGenDates] ASC
        ) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
    END
    
    PRINT 'Table ' + @FullTableName + ' verified and updated successfully.'
END

GO

alter PROCEDURE Tss_AccUntAccountReviewRStp
(  
   @InternalWhere VarChar(8000)='',
   @Where VarChar(8000)='',
   @Order VarChar(8000)='',
   @DsFromDate VarChar(10)='1399/01/01',
   @DsToDate VarChar(10)='1399/03/13',
   @SiAccFinancePeriod Numeric=20,
   @SiPubSubLocations varchar(500)='1,2',
   @Sta_Start SmallInt=0,
   @Sta_End SmallInt=0,
   @Sta_Close SmallInt=0,
   @FlgLevel SmallInt=2,
	@FlgTafType SmallInt=0,
   @SiSelected VarChar(50)='',
   @Cod_AccountLevel1 VarChar(50)='',
   @Cod_AccountLevel2 VarChar(50)='',
   @StaBaMandeh smallint=0
) 

AS

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
else
   Set @Order=' Order By Acc_Code'

Declare
   @WhType VarChar(500),
   @SqlTxt VarCHar(4000),
	@AccAllDocs smallint,
   @TafName VarChar(100)

SELECT 
	SiAccFinancePeriodToPlace
Into #TempTable
FROM         
	dbo.Tss_AccFinancePeriodToPlace
Where
	(SiPubSubLocations in (select * from dbo.Tss_StdStringSiFindUdf(@SiPubSubLocations)))
--select * from #TempTable
Set @WhType=''
If @Sta_Start=0
   SELECT @WhType=convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup = 0)
If @Sta_End=0
   If @WhType=''
      SELECT @WhType=convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup = 1)
   Else
      SELECT @WhType=@WhType+','+convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup = 1)
If @Sta_Close=0
   If @WhType=''
      SELECT @WhType=convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup =3)
   Else
      SELECT @WhType=@WhType+','+convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup = 3)

If @FlgTafType=0
   Set @TafName='SiPubPersonsSpec1'
If @FlgTafType=1
   Set @TafName='SiPubCostCenter1'
If @FlgTafType=2
   Set @TafName='SiPubProjects1'
If @FlgTafType=3
   Set @TafName='SiPurOrder_Hd1'

select @AccAllDocs = dbo.Tss_StdFindSystemParamValue('AccAllDocs')

If @FlgLevel=1
Begin
   Set @SqlTxt=
   'SELECT     
      left(cBook.Cod_AccountCode,2) Acc_Code, 
      substring(cBook.Cod_AccountCode,3,2) as Cod_AccountLevel2, 
      substring(cBook.Cod_AccountCode,5,2) as Cod_AccountLevel3, 
      cBook.SiAccCodeBook as SiAccCodeBook,
      vDet.Num_VdetDebtAmount, 
      vDet.Num_VdetCreditAmount
   FROM         
      dbo.Tss_AccCodeBook cBook 
      INNER JOIN dbo.Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook 
      INNER JOIN dbo.Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
   WHERE '

	if @AccAllDocs=0    
	Set @SqlTxt=@SqlTxt+
	      '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select SiAccFinancePeriodToPlace from #TempTable)) AND
	      (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+')'
	else
	Set @SqlTxt=@SqlTxt+
	      '(vHed.Sta_VochStatus >= 3) AND --(vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select SiAccFinancePeriodToPlace from #TempTable)) AND
	      (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+')'

	if @SiSelected<>''
	Set @SqlTxt=@SqlTxt+ ' and (vDet.' +@TafName+'='+@SiSelected+') '

   If @WhType<>''
      Set @SqlTxt=@SqlTxt+' AND (vHed.SiAccVoucherType Not In ('+@WhType+'))'

   Set @SqlTxt=
      'Select
         Ddd2.Acc_Code,
         Ddd2.SiAccCodeBook,  -- Qualified with Ddd2 alias
         Ddd2.Acc_Bed,
         Ddd2.Acc_Bes,
         Case When Ddd2.Acc_Bed>Ddd2.Acc_Bes Then Ddd2.Acc_Bed-Ddd2.Acc_Bes Else 0 End As Rst_Bed,
         Case When Ddd2.Acc_Bes>Ddd2.Acc_Bed Then Ddd2.Acc_Bes-Ddd2.Acc_Bed Else 0 End As Rst_Bes,
         dbo.Tss_AccCodeBook.Des_AccountDesc,
         dbo.Tss_AccCodeBook.Sta_AccountLeaf,
         dbo.Tss_AccCodeBook.Sta_TafType1 
      From 
      (
         Select 
            Acc_Code,
            SiAccCodeBook,
            Sum(Num_VdetDebtAmount) As Acc_Bed,
            Sum(Num_VdetCreditAmount) As Acc_Bes
         From 
         ('+@SqlTxt+'

         ) Ddd
         Group By Acc_Code, SiAccCodeBook
      ) Ddd2 
      INNER JOIN dbo.Tss_AccCodeBook ON 
      Ddd2.Acc_Code = dbo.Tss_AccCodeBook.Cod_AccountCode'
End
If @FlgLevel=2
Begin
Set @SqlTxt=
   'SELECT     
      left(cBook.Cod_AccountCode,4) As Acc_Code, 
      substring(cBook.Cod_AccountCode,3,2) as Cod_AccountLevel2, 
      substring(cBook.Cod_AccountCode,5,2) as Cod_AccountLevel3, 
      cBook.SiAccCodeBook as SiAccCodeBook,
      vDet.Num_VdetDebtAmount, 
      vDet.Num_VdetCreditAmount
   FROM         
      dbo.Tss_AccCodeBook cBook 
      INNER JOIN dbo.Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook 
      INNER JOIN dbo.Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
   WHERE  '

	if @AccAllDocs=0    
	Set @SqlTxt=@SqlTxt+
	      '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) and
	      (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+')' 
	else
	Set @SqlTxt=@SqlTxt+
	      '(vHed.Sta_VochStatus >= 3) AND --(vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) and
	      (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+')'
	
	if @Cod_AccountLevel1<>'' 
		Set @SqlTxt=@SqlTxt+'AND (left(cBook.Cod_AccountCode,2)='+''''+@Cod_AccountLevel1+''''+')'
	else
		Set @SqlTxt=@SqlTxt--+' AND (Len(cBook.Cod_AccountCode)=4)'


	if @SiSelected<>''
	Set @SqlTxt=@SqlTxt+ ' and (vDet.' +@TafName+'='+@SiSelected+') '
	
   If @WhType<>''
      Set @SqlTxt=@SqlTxt+' AND (vHed.SiAccVoucherType Not In ('+@WhType+'))'
   Set @SqlTxt=
      'Select
         Ddd2.Acc_Code,
         Ddd2.SiAccCodeBook,  -- Qualified with Ddd2 alias
         Ddd2.Acc_Bed,
         Ddd2.Acc_Bes,
         Case When Ddd2.Acc_Bed>Ddd2.Acc_Bes Then Ddd2.Acc_Bed-Ddd2.Acc_Bes Else 0 End As Rst_Bed,
         Case When Ddd2.Acc_Bes>Ddd2.Acc_Bed Then Ddd2.Acc_Bes-Ddd2.Acc_Bed Else 0 End As Rst_Bes,
         dbo.Tss_AccCodeBook.Des_AccountDesc,
         dbo.Tss_AccCodeBook.Sta_AccountLeaf,
         dbo.Tss_AccCodeBook.Sta_TafType1 
      From 
      (
         Select 
            Acc_Code,
            SiAccCodeBook,
            Sum(Num_VdetDebtAmount) As Acc_Bed,
            Sum(Num_VdetCreditAmount) As Acc_Bes
         From 
         ('+@SqlTxt+'

         ) Ddd
         Group By Acc_Code, SiAccCodeBook
      ) Ddd2 
      INNER JOIN dbo.Tss_AccCodeBook ON 
      Ddd2.Acc_Code = dbo.Tss_AccCodeBook.Cod_AccountCode'
End
If @FlgLevel=3
Begin
   Set @SqlTxt=
   'SELECT     
      left(cBook.Cod_AccountCode,6) As Acc_Code, 
      substring(cBook.Cod_AccountCode,3,2) as Cod_AccountLevel2, 
      substring(cBook.Cod_AccountCode,5,2) as Cod_AccountLevel3, 
      cBook.SiAccCodeBook as SiAccCodeBook,
      vDet.Num_VdetDebtAmount, 
      vDet.Num_VdetCreditAmount
   FROM         
      dbo.Tss_AccCodeBook cBook 
      INNER JOIN dbo.Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook 
      INNER JOIN dbo.Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
   WHERE '

	if @AccAllDocs=0    
	Set @SqlTxt=@SqlTxt+
	      '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) and
	      (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+')'
	else
	Set @SqlTxt=@SqlTxt+
	      '(vHed.Sta_VochStatus >= 3) AND --(vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) and
	      (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+')'

	if len(@Cod_AccountLevel2)=4
		Set @SqlTxt=@SqlTxt+'AND (left(cBook.Cod_AccountCode,4)='+''''+@Cod_AccountLevel2+''''+')'
	if @Cod_AccountLevel2=''
		Set @SqlTxt=@SqlTxt+'AND (len(cBook.Cod_AccountCode)=6)'
	
	if @SiSelected<>''
	Set @SqlTxt=@SqlTxt+ ' and (vDet.' +@TafName+'='+@SiSelected+') '

   If @WhType<>''
      Set @SqlTxt=@SqlTxt+' AND (vHed.SiAccVoucherType Not In ('+@WhType+'))'
   Set @SqlTxt=
      'Select
         Ddd2.Acc_Code,
         Ddd2.SiAccCodeBook,  -- Qualified with Ddd2 alias
         Ddd2.Acc_Bed,
         Ddd2.Acc_Bes,
         Case When Ddd2.Acc_Bed>Ddd2.Acc_Bes Then Ddd2.Acc_Bed-Ddd2.Acc_Bes Else 0 End As Rst_Bed,
         Case When Ddd2.Acc_Bes>Ddd2.Acc_Bed Then Ddd2.Acc_Bes-Ddd2.Acc_Bed Else 0 End As Rst_Bes,
         dbo.Tss_AccCodeBook.Des_AccountDesc,
         dbo.Tss_AccCodeBook.Sta_AccountLeaf,
         dbo.Tss_AccCodeBook.Sta_TafType1 
      From 
      (
         Select 
            Acc_Code,
            SiAccCodeBook,
            Sum(Num_VdetDebtAmount) As Acc_Bed,
            Sum(Num_VdetCreditAmount) As Acc_Bes
         From 
         ('+@SqlTxt+'

         ) Ddd
         Group By Acc_Code, SiAccCodeBook
      ) Ddd2 
      INNER JOIN dbo.Tss_AccCodeBook ON 
      Ddd2.Acc_Code = dbo.Tss_AccCodeBook.Cod_AccountCode'
End
Exec(
'Select * From
(
   Select * From
   ( '+@SqlTxt+
   ' ) Ccc  '+@InternalWhere+'
) CalcSel ' + @Where + @Order)
print @SqlTxt


go

ALTER PROCEDURE Tss_AccUntAccountReviewTafsilRStp
(  
   @InternalWhere VarChar(8000)='',
   @Where VarChar(8000)='',
   @Order VarChar(8000)='',
   @DsFromDate VarChar(10)='1390/01/01',
   @DsToDate VarChar(10)='1397/12/29',
   @SiAccFinancePeriod Numeric=9,
   @SiPubSubLocations varchar(500)='1,2',
   @Sta_Start SmallInt=0,
   @Sta_End SmallInt=0,
   @Sta_Close SmallInt=0,
   @FlgLevel SmallInt=4,
   @Cod_AccountCode VarChar(50)='611012',
   @StaBaMandeh smallint=0
) 

AS

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
else
   Set @Order=' Order By convert(numeric,TafCode)'

Declare
   @WhType VarChar(20),
   @SqlTxt VarCHar(4000),
   @Sta_TafType1 SmallInt,
   @SiAccCodeBook Numeric,
	@AccAllDocs smallint

select @AccAllDocs = dbo.Tss_StdFindSystemParamValue('AccAllDocs')

SELECT 
	SiAccFinancePeriodToPlace
Into #TempTable
FROM         
	dbo.Tss_AccFinancePeriodToPlace
Where
--	(SiAccFinancePeriod=@SiAccFinancePeriod) And
	(SiPubSubLocations in (select * from dbo.Tss_StdStringSiFindUdf(@SiPubSubLocations)))
--select * from #TempTable
SELECT     
   @Sta_TafType1=Sta_TafType1, 
   @SiAccCodeBook=SiAccCodeBook
FROM
   dbo.Tss_AccCodeBook cBook
WHERE
   (Cod_AccountCode = @Cod_AccountCode)

Set @WhType=''
If @Sta_Start=0
   SELECT @WhType=convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup = 0)
If @Sta_End=0
   If @WhType=''
      SELECT @WhType=convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup = 1)
   Else
      SELECT @WhType=@WhType+','+convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup = 1)
If @Sta_Close=0
   If @WhType=''
      SELECT @WhType=convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup =3)
   Else
      SELECT @WhType=@WhType+','+convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup = 3)

If @Sta_TafType1=1
Begin
   Set @SqlTxt=
   '
   Select 
      TafCode,
      TafDesc,
      SiTaf,  -- Added SiTaf column
      Acc_Bed,
      Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,  -- Added SiTaf column
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
		Des_CodeDescription
   From
   (
      SELECT     
         dbo.Tss_PubPersonsViw.Cod_PubPersonCode TafCode, 
         dbo.Tss_PubPersonsViw.Des_FullName TafDesc,
         dbo.Tss_PubPersonsViw.SiPubPersonsSpec as SiTaf,  -- SiPubPersonsSpec for @Sta_TafType1=1
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount,
			'''' Des_VdetDesc,
			'''' Dat_AccVoucherDetDate,
			$0.0 Num_VdetAmount,
			dbo.Tss_PubPersonsViw.Des_CodeDescription
      FROM         
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PubPersonsViw ON vDet.SiPubPersonsSpec1 = dbo.Tss_PubPersonsViw.SiPubPersonsSpec
      WHERE '
	if @AccAllDocs=0
    Set @SqlTxt= @SqlTxt+
         '(vHed.Sta_VochStatus >= 3)  AND (vHed.Sta_VochStatus <> 5)  AND 
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+') AND
         (vDet.SiAccCodeBook = '+Str(@SiAccCodeBook)+')'
	else
    Set @SqlTxt= @SqlTxt+
         '(vHed.Sta_VochStatus >= 3)  AND --(vHed.Sta_VochStatus <> 5)  AND 
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+') AND
         (vDet.SiAccCodeBook = '+Str(@SiAccCodeBook)+')'

   If @WhType<>''
      Set @SqlTxt=@SqlTxt+' AND (vHed.SiAccVoucherType Not In ('+@WhType+'))'
   Set @SqlTxt=@SqlTxt+' ) Ddd '
   Set @SqlTxt=@SqlTxt+' Group By TafCode, TafDesc, SiTaf, Des_VdetDesc, Dat_AccVoucherDetDate, Num_VdetAmount, Des_CodeDescription ) Dd2 '
--print @SqlTxt
End


If @Sta_TafType1=2
Begin
   Set @SqlTxt=
   '
   Select 
      TafCode,
      TafDesc,
      SiTaf,  -- Added SiTaf column
      Acc_Bed,
      Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,  -- Added SiTaf column
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
		Des_CodeDescription
   From
   (
      SELECT     
         dbo.Tss_PubCostCenter.Cod_CostCenterCode TafCode,  
         dbo.Tss_PubCostCenter.Des_CostCenterName TafDesc,
         dbo.Tss_PubCostCenter.SiPubCostCenter as SiTaf,  -- SiPubCostCenter for @Sta_TafType1=2
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount,
			'''' Des_VdetDesc,
			'''' Dat_AccVoucherDetDate,
			$0.0 Num_VdetAmount,
			dbo.Tss_PubCostCenter.Des_CodeDescription
      FROM   
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PubCostCenter ON vDet.SiPubCostCenter1 = dbo.Tss_PubCostCenter.SiPubCostCenter
      WHERE '
	if @AccAllDocs=0
    Set @SqlTxt= @SqlTxt+
         '(vHed.Sta_VochStatus >= 3)  AND (vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+') AND
	      (vDet.SiAccCodeBook = '+Str(@SiAccCodeBook)+')'
	else
    Set @SqlTxt= @SqlTxt+
         '(vHed.Sta_VochStatus >= 3)  AND --(vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+') AND
	      (vDet.SiAccCodeBook = '+Str(@SiAccCodeBook)+')'

If @WhType<>''
      Set @SqlTxt=@SqlTxt+' AND (vHed.SiAccVoucherType Not In ('+@WhType+'))'
   Set @SqlTxt=@SqlTxt+' ) Ddd
   Group By TafCode, TafDesc, SiTaf, Des_VdetDesc, Dat_AccVoucherDetDate, Num_VdetAmount, Des_CodeDescription ) Dd2'
End

If @Sta_TafType1=3
Begin
   Set @SqlTxt=
   '
   Select 
      TafCode,
      TafDesc,
      SiTaf,  -- Added SiTaf column
      Acc_Bed,
      Acc_Bes,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		'''' as Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,  -- Added SiTaf column
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes
   From
   (
      SELECT     
         dbo.Tss_PubProjects.Cod_ProjectsCode TafCode,  
         dbo.Tss_PubProjects.Des_ProjectsThemeDesc TafDesc,
         dbo.Tss_PubProjects.SiPubProjects as SiTaf,  -- SiPubProjects for @Sta_TafType1=3
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount 
      FROM         
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PubProjects ON vDet.SiPubProjects1 = dbo.Tss_PubProjects.SiPubProjects
      WHERE '
	if @AccAllDocs=0
    Set @SqlTxt= @SqlTxt+
         '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+') AND
         (vDet.SiAccCodeBook = '+Str(@SiAccCodeBook)+')'
	else
    Set @SqlTxt= @SqlTxt+
         '(vHed.Sta_VochStatus >= 3) AND --(vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+') AND
         (vDet.SiAccCodeBook = '+Str(@SiAccCodeBook)+')'

   If @WhType<>''
      Set @SqlTxt=@SqlTxt+' AND (vHed.SiAccVoucherType Not In ('+@WhType+'))'
   Set @SqlTxt=@SqlTxt+' ) Ddd
   Group By TafCode, TafDesc, SiTaf ) Dd2'  -- Added SiTaf to GROUP BY
End

If @Sta_TafType1=4
Begin
   Set @SqlTxt=
   '
   Select 
      TafCode,
      TafDesc,
      SiTaf,  -- Added SiTaf column
      Acc_Bed,
      Acc_Bes,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		'''' Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,  -- Added SiTaf column
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes
   From
   (
      SELECT     
         dbo.Tss_PurOrder_Hd.Cod_PurOrderCode TafCode,  
         dbo.Tss_PurOrder_Hd.Des_PurOrderDesc TafDesc,
         dbo.Tss_PurOrder_Hd.SiPurOrder_Hd as SiTaf,  -- SiPurOrder_Hd for @Sta_TafType1=4
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount 
      FROM         
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PurOrder_Hd ON vDet.SiPurOrder_Hd1 = dbo.Tss_PurOrder_Hd.SiPurOrder_Hd
      WHERE '
	if @AccAllDocs=0
    Set @SqlTxt= @SqlTxt+
         '(vHed.Sta_VochStatus >= 3)  AND (vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+') AND
         (vDet.SiAccCodeBook = '+Str(@SiAccCodeBook)+')'
	else
    Set @SqlTxt= @SqlTxt+
         '(vHed.Sta_VochStatus >= 3)  AND --(vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+') AND
         (vDet.SiAccCodeBook = '+Str(@SiAccCodeBook)+')'

   If @WhType<>''
      Set @SqlTxt=@SqlTxt+' AND (vHed.SiAccVoucherType Not In ('+@WhType+'))'
   Set @SqlTxt=@SqlTxt+' ) Ddd
   Group By TafCode, TafDesc, SiTaf ) Dd2'  -- Added SiTaf to GROUP BY
End

-- If @Sta_TafType1=0, return NULL for SiTaf
If @Sta_TafType1=0
Begin
   Set @SqlTxt=
   '
   Select 
      '''' TafCode,
      '''' TafDesc,
      NULL as SiTaf,  -- NULL when @Sta_TafType1=0
      convert(numeric,0) Acc_Bed,
      convert(numeric,0) Acc_Bes,
      convert(numeric,0) Rst_Bed,
      convert(numeric,0) Rst_Bes,
      '''' Des_VdetDesc,
      '''' Dat_AccVoucherDetDate,
      convert(numeric,0) Num_VdetAmount,
      '''' RelatedSaler,
      '''' Des_CodeDescription
   '
End

print @SqlTxt

If @Sta_TafType1<>0
Exec(
'Select * From
(
   Select * From
   ( '+@SqlTxt+
   ' ) Ccc  '+@InternalWhere+'
) CalcSel ' + @Where + @Order)
Else
Exec(@SqlTxt)

GO

alter PROCEDURE Tss_AccUntAccountReviewRStp
(  
   @InternalWhere VarChar(8000)='',
   @Where VarChar(8000)='',
   @Order VarChar(8000)='',
   @DsFromDate VarChar(10)='1399/01/01',
   @DsToDate VarChar(10)='1399/03/13',
   @SiAccFinancePeriod Numeric=20,
   @SiPubSubLocations varchar(500)='1,2',
   @Sta_Start SmallInt=0,
   @Sta_End SmallInt=0,
   @Sta_Close SmallInt=0,
   @FlgLevel SmallInt=2,
	@FlgTafType SmallInt=0,
   @SiSelected VarChar(50)='',
   @Cod_AccountLevel1 VarChar(50)='',
   @Cod_AccountLevel2 VarChar(50)='',
   @StaBaMandeh smallint=0
) 

AS

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
else
   Set @Order=' Order By Acc_Code'

Declare
   @WhType VarChar(500),
   @SqlTxt VarCHar(4000),
	@AccAllDocs smallint,
   @TafName VarChar(100)

SELECT 
	SiAccFinancePeriodToPlace
Into #TempTable
FROM         
	dbo.Tss_AccFinancePeriodToPlace
Where
	(SiPubSubLocations in (select * from dbo.Tss_StdStringSiFindUdf(@SiPubSubLocations)))
--select * from #TempTable
Set @WhType=''
If @Sta_Start=0
   SELECT @WhType=convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup = 0)
If @Sta_End=0
   If @WhType=''
      SELECT @WhType=convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup = 1)
   Else
      SELECT @WhType=@WhType+','+convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup = 1)
If @Sta_Close=0
   If @WhType=''
      SELECT @WhType=convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup =3)
   Else
      SELECT @WhType=@WhType+','+convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup = 3)

If @FlgTafType=0
   Set @TafName='SiPubPersonsSpec1'
If @FlgTafType=1
   Set @TafName='SiPubCostCenter1'
If @FlgTafType=2
   Set @TafName='SiPubProjects1'
If @FlgTafType=3
   Set @TafName='SiPurOrder_Hd1'

select @AccAllDocs = dbo.Tss_StdFindSystemParamValue('AccAllDocs')

If @FlgLevel=1
Begin
   Set @SqlTxt=
   'SELECT     
      left(cBook.Cod_AccountCode,2) Acc_Code, 
      substring(cBook.Cod_AccountCode,3,2) as Cod_AccountLevel2, 
      substring(cBook.Cod_AccountCode,5,2) as Cod_AccountLevel3, 
      cBook.SiAccCodeBook as SiAccCodeBook,
      vDet.Num_VdetDebtAmount, 
      vDet.Num_VdetCreditAmount
   FROM         
      dbo.Tss_AccCodeBook cBook 
      INNER JOIN dbo.Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook 
      INNER JOIN dbo.Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
   WHERE '

	if @AccAllDocs=0    
	Set @SqlTxt=@SqlTxt+
	      '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select SiAccFinancePeriodToPlace from #TempTable)) AND
	      (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+')'
	else
	Set @SqlTxt=@SqlTxt+
	      '(vHed.Sta_VochStatus >= 3) AND --(vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select SiAccFinancePeriodToPlace from #TempTable)) AND
	      (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+')'

	if @SiSelected<>''
	Set @SqlTxt=@SqlTxt+ ' and (vDet.' +@TafName+'='+@SiSelected+') '

   If @WhType<>''
      Set @SqlTxt=@SqlTxt+' AND (vHed.SiAccVoucherType Not In ('+@WhType+'))'

   Set @SqlTxt=
      'Select
         Ddd2.Acc_Code,
         Ddd2.SiAccCodeBook,  -- Qualified with Ddd2 alias
         Ddd2.Acc_Bed,
         Ddd2.Acc_Bes,
         Case When Ddd2.Acc_Bed>Ddd2.Acc_Bes Then Ddd2.Acc_Bed-Ddd2.Acc_Bes Else 0 End As Rst_Bed,
         Case When Ddd2.Acc_Bes>Ddd2.Acc_Bed Then Ddd2.Acc_Bes-Ddd2.Acc_Bed Else 0 End As Rst_Bes,
         dbo.Tss_AccCodeBook.Des_AccountDesc,
         dbo.Tss_AccCodeBook.Sta_AccountLeaf,
         dbo.Tss_AccCodeBook.Sta_TafType1 
      From 
      (
         Select 
            Acc_Code,
            SiAccCodeBook,
            Sum(Num_VdetDebtAmount) As Acc_Bed,
            Sum(Num_VdetCreditAmount) As Acc_Bes
         From 
         ('+@SqlTxt+'

         ) Ddd
         Group By Acc_Code, SiAccCodeBook
      ) Ddd2 
      INNER JOIN dbo.Tss_AccCodeBook ON 
      Ddd2.Acc_Code = dbo.Tss_AccCodeBook.Cod_AccountCode'
End
If @FlgLevel=2
Begin
Set @SqlTxt=
   'SELECT     
      left(cBook.Cod_AccountCode,4) As Acc_Code, 
      substring(cBook.Cod_AccountCode,3,2) as Cod_AccountLevel2, 
      substring(cBook.Cod_AccountCode,5,2) as Cod_AccountLevel3, 
      cBook.SiAccCodeBook as SiAccCodeBook,
      vDet.Num_VdetDebtAmount, 
      vDet.Num_VdetCreditAmount
   FROM         
      dbo.Tss_AccCodeBook cBook 
      INNER JOIN dbo.Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook 
      INNER JOIN dbo.Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
   WHERE  '

	if @AccAllDocs=0    
	Set @SqlTxt=@SqlTxt+
	      '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) and
	      (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+')' 
	else
	Set @SqlTxt=@SqlTxt+
	      '(vHed.Sta_VochStatus >= 3) AND --(vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) and
	      (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+')'
	
	if @Cod_AccountLevel1<>'' 
		Set @SqlTxt=@SqlTxt+'AND (left(cBook.Cod_AccountCode,2)='+''''+@Cod_AccountLevel1+''''+')'
	else
		Set @SqlTxt=@SqlTxt--+' AND (Len(cBook.Cod_AccountCode)=4)'


	if @SiSelected<>''
	Set @SqlTxt=@SqlTxt+ ' and (vDet.' +@TafName+'='+@SiSelected+') '
	
   If @WhType<>''
      Set @SqlTxt=@SqlTxt+' AND (vHed.SiAccVoucherType Not In ('+@WhType+'))'
   Set @SqlTxt=
      'Select
         Ddd2.Acc_Code,
         Ddd2.SiAccCodeBook,  -- Qualified with Ddd2 alias
         Ddd2.Acc_Bed,
         Ddd2.Acc_Bes,
         Case When Ddd2.Acc_Bed>Ddd2.Acc_Bes Then Ddd2.Acc_Bed-Ddd2.Acc_Bes Else 0 End As Rst_Bed,
         Case When Ddd2.Acc_Bes>Ddd2.Acc_Bed Then Ddd2.Acc_Bes-Ddd2.Acc_Bed Else 0 End As Rst_Bes,
         dbo.Tss_AccCodeBook.Des_AccountDesc,
         dbo.Tss_AccCodeBook.Sta_AccountLeaf,
         dbo.Tss_AccCodeBook.Sta_TafType1 
      From 
      (
         Select 
            Acc_Code,
            SiAccCodeBook,
            Sum(Num_VdetDebtAmount) As Acc_Bed,
            Sum(Num_VdetCreditAmount) As Acc_Bes
         From 
         ('+@SqlTxt+'

         ) Ddd
         Group By Acc_Code, SiAccCodeBook
      ) Ddd2 
      INNER JOIN dbo.Tss_AccCodeBook ON 
      Ddd2.Acc_Code = dbo.Tss_AccCodeBook.Cod_AccountCode'
End
If @FlgLevel=3
Begin
   Set @SqlTxt=
   'SELECT     
      left(cBook.Cod_AccountCode,6) As Acc_Code, 
      substring(cBook.Cod_AccountCode,3,2) as Cod_AccountLevel2, 
      substring(cBook.Cod_AccountCode,5,2) as Cod_AccountLevel3, 
      cBook.SiAccCodeBook as SiAccCodeBook,
      vDet.Num_VdetDebtAmount, 
      vDet.Num_VdetCreditAmount
   FROM         
      dbo.Tss_AccCodeBook cBook 
      INNER JOIN dbo.Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook 
      INNER JOIN dbo.Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
   WHERE '

	if @AccAllDocs=0    
	Set @SqlTxt=@SqlTxt+
	      '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) and
	      (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+')'
	else
	Set @SqlTxt=@SqlTxt+
	      '(vHed.Sta_VochStatus >= 3) AND --(vHed.Sta_VochStatus <> 5) AND
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) and
	      (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+')'

	if len(@Cod_AccountLevel2)=4
		Set @SqlTxt=@SqlTxt+'AND (left(cBook.Cod_AccountCode,4)='+''''+@Cod_AccountLevel2+''''+')'
	if @Cod_AccountLevel2=''
		Set @SqlTxt=@SqlTxt+'AND (len(cBook.Cod_AccountCode)=6)'
	
	if @SiSelected<>''
	Set @SqlTxt=@SqlTxt+ ' and (vDet.' +@TafName+'='+@SiSelected+') '

   If @WhType<>''
      Set @SqlTxt=@SqlTxt+' AND (vHed.SiAccVoucherType Not In ('+@WhType+'))'
   Set @SqlTxt=
      'Select
         Ddd2.Acc_Code,
         Ddd2.SiAccCodeBook,  -- Qualified with Ddd2 alias
         Ddd2.Acc_Bed,
         Ddd2.Acc_Bes,
         Case When Ddd2.Acc_Bed>Ddd2.Acc_Bes Then Ddd2.Acc_Bed-Ddd2.Acc_Bes Else 0 End As Rst_Bed,
         Case When Ddd2.Acc_Bes>Ddd2.Acc_Bed Then Ddd2.Acc_Bes-Ddd2.Acc_Bed Else 0 End As Rst_Bes,
         dbo.Tss_AccCodeBook.Des_AccountDesc,
         dbo.Tss_AccCodeBook.Sta_AccountLeaf,
         dbo.Tss_AccCodeBook.Sta_TafType1 
      From 
      (
         Select 
            Acc_Code,
            SiAccCodeBook,
            Sum(Num_VdetDebtAmount) As Acc_Bed,
            Sum(Num_VdetCreditAmount) As Acc_Bes
         From 
         ('+@SqlTxt+'

         ) Ddd
         Group By Acc_Code, SiAccCodeBook
      ) Ddd2 
      INNER JOIN dbo.Tss_AccCodeBook ON 
      Ddd2.Acc_Code = dbo.Tss_AccCodeBook.Cod_AccountCode'
End
Exec(
'Select * From
(
   Select * From
   ( '+@SqlTxt+
   ' ) Ccc  '+@InternalWhere+'
) CalcSel ' + @Where + @Order)

GO

alter PROCEDURE Tss_AccUntAccountReviewTafsilRStp
(  
   @InternalWhere VarChar(8000)='',
   @Where VarChar(8000)='',
   @Order VarChar(8000)='',
   @DsFromDate VarChar(10)='1390/01/01',
   @DsToDate VarChar(10)='1397/12/29',
   @SiAccFinancePeriod Numeric=9,
   @SiPubSubLocations varchar(500)='1,2',
   @Sta_Start SmallInt=0,
   @Sta_End SmallInt=0,
   @Sta_Close SmallInt=0,
   @FlgLevel SmallInt=4,
   @Cod_AccountCode VarChar(50)='611012',
   @StaBaMandeh smallint=0
) 

AS

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

-- Fixed ORDER BY to avoid conversion errors
If @Order<>''
   Set @Order=' Order By '+@Order
else
   Set @Order=' Order By CASE WHEN ISNUMERIC(TafCode)=1 THEN convert(numeric, TafCode) ELSE 999999 END'

Declare
   @WhType VarChar(20),
   @SqlTxt VarCHar(4000),
   @Sta_TafType1 SmallInt,
   @SiAccCodeBook Numeric,
	@AccAllDocs smallint

select @AccAllDocs = dbo.Tss_StdFindSystemParamValue('AccAllDocs')

SELECT 
	SiAccFinancePeriodToPlace
Into #TempTable
FROM         
	dbo.Tss_AccFinancePeriodToPlace
Where
	(SiPubSubLocations in (select * from dbo.Tss_StdStringSiFindUdf(@SiPubSubLocations)))

SELECT     
   @Sta_TafType1=Sta_TafType1, 
   @SiAccCodeBook=SiAccCodeBook
FROM
   dbo.Tss_AccCodeBook cBook
WHERE
   (Cod_AccountCode = @Cod_AccountCode)

Set @WhType=''
If @Sta_Start=0
   SELECT @WhType=convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup = 0)
If @Sta_End=0
   If @WhType=''
      SELECT @WhType=convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup = 1)
   Else
      SELECT @WhType=@WhType+','+convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup = 1)
If @Sta_Close=0
   If @WhType=''
      SELECT @WhType=convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup =3)
   Else
      SELECT @WhType=@WhType+','+convert(varchar,SiAccVoucherType) FROM Tss_AccVoucherType WHERE (Sta_VoucherTypeGroup = 3)

If @Sta_TafType1=1
Begin
   Set @SqlTxt=
   '
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Acc_Bed,
      Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
		Des_CodeDescription
   From
   (
      SELECT     
         dbo.Tss_PubPersonsViw.Cod_PubPersonCode TafCode, 
         dbo.Tss_PubPersonsViw.Des_FullName TafDesc,
         dbo.Tss_PubPersonsViw.SiPubPersonsSpec as SiTaf,
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount,
			'''' Des_VdetDesc,
			'''' Dat_AccVoucherDetDate,
			$0.0 Num_VdetAmount,
			dbo.Tss_PubPersonsViw.Des_CodeDescription
      FROM         
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PubPersonsViw ON vDet.SiPubPersonsSpec1 = dbo.Tss_PubPersonsViw.SiPubPersonsSpec
      WHERE '
	if @AccAllDocs=0
    Set @SqlTxt= @SqlTxt+
         '(vHed.Sta_VochStatus >= 3)  AND (vHed.Sta_VochStatus <> 5)  AND 
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+') AND
         (vDet.SiAccCodeBook = '+Str(@SiAccCodeBook)+')'
	else
    Set @SqlTxt= @SqlTxt+
         '(vHed.Sta_VochStatus >= 3)  AND --(vHed.Sta_VochStatus <> 5)  AND 
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+') AND
         (vDet.SiAccCodeBook = '+Str(@SiAccCodeBook)+')'

   If @WhType<>''
      Set @SqlTxt=@SqlTxt+' AND (vHed.SiAccVoucherType Not In ('+@WhType+'))'
   Set @SqlTxt=@SqlTxt+' ) Ddd '
   Set @SqlTxt=@SqlTxt+' Group By TafCode, TafDesc, SiTaf, Des_VdetDesc, Dat_AccVoucherDetDate, Num_VdetAmount, Des_CodeDescription ) Dd2 '
End


If @Sta_TafType1=2
Begin
   Set @SqlTxt=
   '
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Acc_Bed,
      Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes,
		Des_VdetDesc, 
		Dat_AccVoucherDetDate, 
		Num_VdetAmount,
		Des_CodeDescription
   From
   (
      SELECT     
         dbo.Tss_PubCostCenter.Cod_CostCenterCode TafCode,  
         dbo.Tss_PubCostCenter.Des_CostCenterName TafDesc,
         dbo.Tss_PubCostCenter.SiPubCostCenter as SiTaf,
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount,
			'''' Des_VdetDesc,
			'''' Dat_AccVoucherDetDate,
			$0.0 Num_VdetAmount,
			dbo.Tss_PubCostCenter.Des_CodeDescription
      FROM   
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PubCostCenter ON vDet.SiPubCostCenter1 = dbo.Tss_PubCostCenter.SiPubCostCenter
      WHERE '
	if @AccAllDocs=0
    Set @SqlTxt= @SqlTxt+
         '(vHed.Sta_VochStatus >= 3)  AND (vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+') AND
	      (vDet.SiAccCodeBook = '+Str(@SiAccCodeBook)+')'
	else
    Set @SqlTxt= @SqlTxt+
         '(vHed.Sta_VochStatus >= 3)  AND --(vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+') AND
	      (vDet.SiAccCodeBook = '+Str(@SiAccCodeBook)+')'

If @WhType<>''
      Set @SqlTxt=@SqlTxt+' AND (vHed.SiAccVoucherType Not In ('+@WhType+'))'
   Set @SqlTxt=@SqlTxt+' ) Ddd
   Group By TafCode, TafDesc, SiTaf, Des_VdetDesc, Dat_AccVoucherDetDate, Num_VdetAmount, Des_CodeDescription ) Dd2'
End

If @Sta_TafType1=3
Begin
   Set @SqlTxt=
   '
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Acc_Bed,
      Acc_Bes,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		'''' as Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes
   From
   (
      SELECT     
         dbo.Tss_PubProjects.Cod_ProjectsCode TafCode,  
         dbo.Tss_PubProjects.Des_ProjectsThemeDesc TafDesc,
         dbo.Tss_PubProjects.SiPubProjects as SiTaf,
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount 
      FROM         
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PubProjects ON vDet.SiPubProjects1 = dbo.Tss_PubProjects.SiPubProjects
      WHERE '
	if @AccAllDocs=0
    Set @SqlTxt= @SqlTxt+
         '(vHed.Sta_VochStatus >= 3) AND (vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+') AND
         (vDet.SiAccCodeBook = '+Str(@SiAccCodeBook)+')'
	else
    Set @SqlTxt= @SqlTxt+
         '(vHed.Sta_VochStatus >= 3) AND --(vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+') AND
         (vDet.SiAccCodeBook = '+Str(@SiAccCodeBook)+')'

   If @WhType<>''
      Set @SqlTxt=@SqlTxt+' AND (vHed.SiAccVoucherType Not In ('+@WhType+'))'
   Set @SqlTxt=@SqlTxt+' ) Ddd
   Group By TafCode, TafDesc, SiTaf ) Dd2'
End

If @Sta_TafType1=4
Begin
   Set @SqlTxt=
   '
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Acc_Bed,
      Acc_Bes,
      Case When Acc_Bed>Acc_Bes Then Acc_Bed-Acc_Bes Else 0 End As Rst_Bed,
      Case When Acc_Bes>Acc_Bed Then Acc_Bes-Acc_Bed Else 0 End As Rst_Bes,
		dbo.Tss_FindRelatedSaler(TafCode) as RelatedSaler,
		'''' Des_CodeDescription
   From
   (
   Select 
      TafCode,
      TafDesc,
      SiTaf,
      Sum(Num_VdetDebtAmount) Acc_Bed,
      Sum(Num_VdetCreditAmount) Acc_Bes
   From
   (
      SELECT     
         dbo.Tss_PurOrder_Hd.Cod_PurOrderCode TafCode,  
         dbo.Tss_PurOrder_Hd.Des_PurOrderDesc TafDesc,
         dbo.Tss_PurOrder_Hd.SiPurOrder_Hd as SiTaf,
         vDet.Num_VdetDebtAmount, 
         vDet.Num_VdetCreditAmount 
      FROM         
         dbo.Tss_AccVoucher_Dt vDet INNER JOIN dbo.Tss_AccVoucher_Hd vHed 
         ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd INNER JOIN
         dbo.Tss_PurOrder_Hd ON vDet.SiPurOrder_Hd1 = dbo.Tss_PurOrder_Hd.SiPurOrder_Hd
      WHERE '
	if @AccAllDocs=0
    Set @SqlTxt= @SqlTxt+
         '(vHed.Sta_VochStatus >= 3)  AND (vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+') AND
         (vDet.SiAccCodeBook = '+Str(@SiAccCodeBook)+')'
	else
    Set @SqlTxt= @SqlTxt+
         '(vHed.Sta_VochStatus >= 3)  AND --(vHed.Sta_VochStatus <> 5)  AND  
			(vHed.SiAccFinancePeriodToPlace in (select * from #TempTable)) AND
         (vHed.Dat_VhedDate Between '+''''+@DsFromDate+''''+' And '+''''+@DsToDate+''''+') AND
         (vDet.SiAccCodeBook = '+Str(@SiAccCodeBook)+')'

   If @WhType<>''
      Set @SqlTxt=@SqlTxt+' AND (vHed.SiAccVoucherType Not In ('+@WhType+'))'
   Set @SqlTxt=@SqlTxt+' ) Ddd
   Group By TafCode, TafDesc, SiTaf ) Dd2'
End

-- If @Sta_TafType1=0, return NULL for SiTaf
If @Sta_TafType1=0
Begin
   Set @SqlTxt=
   '
   Select 
      '''' TafCode,
      '''' TafDesc,
      NULL as SiTaf,
      convert(numeric,0) Acc_Bed,
      convert(numeric,0) Acc_Bes,
      convert(numeric,0) Rst_Bed,
      convert(numeric,0) Rst_Bes,
      '''' Des_VdetDesc,
      '''' Dat_AccVoucherDetDate,
      convert(numeric,0) Num_VdetAmount,
      '''' RelatedSaler,
      '''' Des_CodeDescription
   '
End

print @SqlTxt

If @Sta_TafType1<>0
Exec(
'Select * From
(
   Select * From
   ( '+@SqlTxt+
   ' ) Ccc  '+@InternalWhere+'
) CalcSel ' + @Where + @Order)
Else
Exec(@SqlTxt)

GO

alter PROCEDURE Tss_AccUntTafsiliReview_03VStp   
(  
    @InternalWhere VARCHAR(8000)='', 
    @Where VARCHAR(8000)='', 
    @Order VARCHAR(8000)='', 
    @DsFromDate VARCHAR(10)='1399/01/01', 
    @DsToDate VARCHAR(10)='1399/09/07', 
    @SiAccFinancePeriod NUMERIC=20, 
    @SiPubSubLocations VARCHAR(500)='1,2', 
    @Sta_Start SMALLINT=0,
    @Sta_End SMALLINT=0, 
    @Sta_Close SMALLINT=0, 
    @StaMandehOrNot SMALLINT=1, 
    @SiAccCodeBook VARCHAR(50)='18,21', 
    @SiSelected VARCHAR(50)='2160',
    @SiUser NUMERIC=1
)
AS
BEGIN
    SET NOCOUNT ON
    SET XACT_ABORT, ARITHABORT, CONCAT_NULL_YIELDS_NULL, ANSI_NULLS, ANSI_NULL_DFLT_ON, ANSI_PADDING, ANSI_WARNINGS, QUOTED_IDENTIFIER ON

    -- Drop temp tables if exist
    DROP TABLE IF EXISTS ##TmpVchTaf
    DROP TABLE IF EXISTS ##TmpVchTafMandeh
    DROP TABLE IF EXISTS ##TmpVchTafBaBiMandeh
    DROP TABLE IF EXISTS #TempTable

    -- Set conditions - handle NULL parameters
    SET @InternalWhere = CASE WHEN @InternalWhere IS NOT NULL AND @InternalWhere<>'' THEN ' WHERE '+@InternalWhere ELSE '' END
    SET @Where = CASE WHEN @Where IS NOT NULL AND @Where<>'' THEN ' WHERE '+@Where ELSE '' END
    SET @Order = CASE WHEN @Order IS NOT NULL AND @Order<>'' THEN ' ORDER BY '+@Order ELSE '' END

    DECLARE @WhType VARCHAR(300)=CASE 
        WHEN @Sta_Start=0 THEN (SELECT STRING_AGG(SiAccVoucherType,',') FROM Tss_AccVoucherType WHERE Sta_VoucherTypeGroup=0) ELSE '' END
        
    SET @WhType = @WhType + CASE WHEN @Sta_End=0 AND @WhType<>'' THEN ',' ELSE '' END + 
        CASE WHEN @Sta_End=0 THEN (SELECT STRING_AGG(SiAccVoucherType,',') FROM Tss_AccVoucherType WHERE Sta_VoucherTypeGroup=1) ELSE '' END
        
    SET @WhType = @WhType + CASE WHEN @Sta_Close=0 AND @WhType<>'' THEN ',' ELSE '' END + 
        CASE WHEN @Sta_Close=0 THEN (SELECT STRING_AGG(SiAccVoucherType,',') FROM Tss_AccVoucherType WHERE Sta_VoucherTypeGroup=3) ELSE '' END
        
    SET @WhType = CASE WHEN @WhType<>'' THEN ' AND vHed.SiAccVoucherType NOT IN ('+@WhType+')' ELSE '' END

    -- Get TafName
    DECLARE @TafName VARCHAR(100)=CASE (SELECT TOP 1 Sta_TafType1 FROM Tss_AccCodeBook WHERE SiAccCodeBook=(SELECT TOP 1 SiSel FROM dbo.Tss_StdStringSiFindUdf(@SiAccCodeBook)))
        WHEN 1 THEN 'SiPubPersonsSpec1' WHEN 2 THEN 'SiPubCostCenter1' WHEN 3 THEN 'SiPubProjects1' WHEN 4 THEN 'SiPurOrder_Hd1' END

    DECLARE @AccAllDocs SMALLINT = dbo.Tss_StdFindSystemParamValue('AccAllDocs')
    
    -- AccStar hidden filter
    DECLARE @HiddenFilter VARCHAR(500)
    IF dbo.Tss_StdFindIfUserIsInGroup(@SiUser,'AccStar') = 1
        SET @HiddenFilter = ''
    ELSE
        SET @HiddenFilter = ' AND (vDet.Sta_IsHidden = 0 OR vDet.Sta_IsHidden IS NULL) '
    
    -- Build temp table for period
    SELECT SiAccFinancePeriodToPlace INTO #TempTable FROM dbo.Tss_AccFinancePeriodToPlace
    WHERE SiPubSubLocations IN (SELECT * FROM dbo.Tss_StdStringSiFindUdf(@SiPubSubLocations))

    -- Create ##TmpVchTaf explicitly with NVARCHAR(4000) for Des_VdetDesc
    CREATE TABLE ##TmpVchTaf (
        SiAccVoucher_Hd NUMERIC NULL,
        Dat_VhedDate VARCHAR(10) NULL,
        Num_VDetRow INT NULL,
        Des_VdetDesc NVARCHAR(4000) NULL,  -- Changed to NVARCHAR(4000)
        Num_VdetDebtAmount BIGINT NULL,
        Num_VdetCreditAmount BIGINT NULL,
        Num_VhedFinalNo DECIMAL(18,0) NULL,
        Num_VhedSubNo INT NULL
    )

    -- Build main query with CAST for Des_VdetDesc
    DECLARE @StatusFilter VARCHAR(100)=CASE WHEN @AccAllDocs=0 THEN 'vHed.Sta_VochStatus >= 3 AND vHed.Sta_VochStatus <> 5 AND ' ELSE 'vHed.Sta_VochStatus >= 3 AND ' END
    
    DECLARE @SqlTxt NVARCHAR(MAX)='
    SELECT 
        vHed.SiAccVoucher_Hd, 
        vHed.Dat_VhedDate, 
        vDet.Num_VDetRow,
        Des_VdetDesc = CAST(CASE WHEN Tss_AccVoucherType.Sta_VoucherTypeGroup IN (4,5) 
            THEN ISNULL(vDet.Des_VdetDesc,'''') 
            ELSE vDet.Des_VdetDesc 
        END AS NVARCHAR(4000)),  -- Cast to NVARCHAR(4000)
        CAST(vDet.Num_VdetDebtAmount AS BIGINT) AS Num_VdetDebtAmount, 
        CAST(vDet.Num_VdetCreditAmount AS BIGINT) AS Num_VdetCreditAmount, 
        CAST(vHed.Num_VhedFinalNo AS DECIMAL(18,0)) AS Num_VhedFinalNo, 
        CAST(vHed.Num_VhedSubNo AS INT) AS Num_VhedSubNo
    FROM Tss_AccCodeBook cBook
    INNER JOIN Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook
    INNER JOIN Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
    INNER JOIN Tss_AccVoucherType ON vHed.SiAccVoucherType = Tss_AccVoucherType.SiAccVoucherType
    WHERE ' + @StatusFilter + '
        vHed.SiAccFinancePeriodToPlace IN (SELECT SiAccFinancePeriodToPlace FROM #TempTable)
        AND vHed.Dat_VhedDate BETWEEN ''' + @DsFromDate + ''' AND ''' + @DsToDate + '''
        AND cBook.SiAccCodeBook IN (SELECT SiSel FROM dbo.Tss_StdStringSiFindUdf(''' + @SiAccCodeBook + '''))
        AND vDet.' + @TafName + ' = ' + @SiSelected + '
        ' + @HiddenFilter + '
        ' + @WhType

    -- Insert into ##TmpVchTaf
    DECLARE @InsertSql NVARCHAR(MAX) = '
    INSERT INTO ##TmpVchTaf
    SELECT * FROM (' + @SqlTxt + ') AS Ccc 
    ' + @InternalWhere + '
    ' + @Where + ' 
    ' + @Order

    BEGIN TRY
        EXEC sp_executesql @InsertSql
    END TRY
    BEGIN CATCH
        PRINT 'Error inserting into ##TmpVchTaf: ' + ERROR_MESSAGE()
    END CATCH

    -- Create ##TmpVchTafMandeh explicitly
    CREATE TABLE ##TmpVchTafMandeh (
        Num_VdetDebtAmount BIGINT NULL,
        Num_VdetCreditAmount BIGINT NULL
    )

    -- Build mandate query
    DECLARE @SqlTxtMandeh NVARCHAR(MAX)='
    SELECT 
        CAST(SUM(vDet.Num_VdetDebtAmount) AS BIGINT) AS Num_VdetDebtAmount, 
        CAST(SUM(vDet.Num_VdetCreditAmount) AS BIGINT) AS Num_VdetCreditAmount
    FROM Tss_AccCodeBook cBook
    INNER JOIN Tss_AccVoucher_Dt vDet ON cBook.SiAccCodeBook = vDet.SiAccCodeBook
    INNER JOIN Tss_AccVoucher_Hd vHed ON vDet.SiAccVoucher_Hd = vHed.SiAccVoucher_Hd
    WHERE ' + @StatusFilter + '
        vHed.SiAccFinancePeriodToPlace IN (SELECT SiAccFinancePeriodToPlace FROM #TempTable)
        AND vHed.Dat_VhedDate BETWEEN ''1385/01/01'' AND ''' + dbo.Tss_StdOneDayDecUdf(@DsFromDate) + '''
        AND cBook.SiAccCodeBook IN (SELECT SiSel FROM dbo.Tss_StdStringSiFindUdf(''' + @SiAccCodeBook + '''))
        AND vDet.' + @TafName + ' = ' + @SiSelected + '
        ' + @HiddenFilter + '
        ' + @WhType + '
    GROUP BY vDet.SiPubPersonsSpec1'

    -- Insert into ##TmpVchTafMandeh
    DECLARE @InsertMandehSql NVARCHAR(MAX) = '
    INSERT INTO ##TmpVchTafMandeh
    SELECT * FROM (' + @SqlTxtMandeh + ') AS Ccc'

    BEGIN TRY
        EXEC sp_executesql @InsertMandehSql
    END TRY
    BEGIN CATCH
        PRINT 'Error inserting into ##TmpVchTafMandeh: ' + ERROR_MESSAGE()
    END CATCH

    -- Create ##TmpVchTafBaBiMandeh explicitly with NVARCHAR(4000) for Des_VdetDesc
    CREATE TABLE ##TmpVchTafBaBiMandeh (
        SiAccVoucher_Hd NUMERIC NULL,
        Dat_VhedDate VARCHAR(10) NULL,
        Num_VDetRow INT NULL,
        Des_VdetDesc NVARCHAR(4000) NULL,  -- Changed to NVARCHAR(4000)
        Num_VdetDebtAmount BIGINT NULL,
        Num_VdetCreditAmount BIGINT NULL,
        Num_VhedFinalNo DECIMAL(18,0) NULL,
        Num_VhedSubNo INT NULL
    )

    -- Combine results with CAST for Des_VdetDesc
    DECLARE @SqlTxtBaBiMandeh NVARCHAR(MAX)
    IF @StaMandehOrNot = 1
    BEGIN
        SET @SqlTxtBaBiMandeh = '
        SELECT 
            0 AS SiAccVoucher_Hd, 
            '''' AS Dat_VhedDate, 
            0 AS Num_VDetRow, 
            CAST(''مانده از قبل'' AS NVARCHAR(4000)) AS Des_VdetDesc,  -- Cast here
            CAST(ISNULL(Num_VdetDebtAmount, 0) AS BIGINT) AS Num_VdetDebtAmount, 
            CAST(ISNULL(Num_VdetCreditAmount, 0) AS BIGINT) AS Num_VdetCreditAmount, 
            CAST(0 AS DECIMAL(18,0)) AS Num_VhedFinalNo, 
            CAST(0 AS INT) AS Num_VhedSubNo
        FROM ##TmpVchTafMandeh
        UNION ALL
        SELECT 
            SiAccVoucher_Hd, 
            Dat_VhedDate, 
            Num_VDetRow, 
            CAST(Des_VdetDesc AS NVARCHAR(4000)) AS Des_VdetDesc,  -- Cast here
            Num_VdetDebtAmount, 
            Num_VdetCreditAmount, 
            Num_VhedFinalNo, 
            Num_VhedSubNo
        FROM ##TmpVchTaf'
    END
    ELSE
    BEGIN
        SET @SqlTxtBaBiMandeh = '
        SELECT 
            SiAccVoucher_Hd, 
            Dat_VhedDate, 
            Num_VDetRow, 
            CAST(Des_VdetDesc AS NVARCHAR(4000)) AS Des_VdetDesc,  -- Cast here
            Num_VdetDebtAmount, 
            Num_VdetCreditAmount, 
            Num_VhedFinalNo, 
            Num_VhedSubNo
        FROM ##TmpVchTaf'
    END

    -- Insert into ##TmpVchTafBaBiMandeh
    DECLARE @InsertCombineSql NVARCHAR(MAX) = '
    INSERT INTO ##TmpVchTafBaBiMandeh
    SELECT * FROM (' + @SqlTxtBaBiMandeh + ') AS Ccc 
    ' + @InternalWhere + '
    ' + @Where + ' 
    ' + @Order

    BEGIN TRY
        EXEC sp_executesql @InsertCombineSql
    END TRY
    BEGIN CATCH
        PRINT 'Error inserting into ##TmpVchTafBaBiMandeh: ' + ERROR_MESSAGE()
    END CATCH

    -- Final calculation - Cast MyId to DECIMAL for BCD
    ;WITH FinalData AS (
        SELECT 
            CAST(ROW_NUMBER() OVER (ORDER BY Dat_VhedDate, SiAccVoucher_Hd, Num_VDetRow) AS DECIMAL(18,0)) AS MyId,
            SiAccVoucher_Hd, 
            CAST(Num_VhedFinalNo AS DECIMAL(18,0)) AS Num_VhedFinalNo,
            CAST(Num_VhedSubNo AS INT) AS Num_VhedSubNo,
            Dat_VhedDate, 
            LEFT(Dat_VhedDate, 7) AS Dat_VhedDateMonth,
            Num_VDetRow,
            Des_VdetDesc,
            CAST(Num_VdetDebtAmount AS BIGINT) AS Num_VdetDebtAmount,
            CAST(Num_VdetCreditAmount AS BIGINT) AS Num_VdetCreditAmount,
            CAST(Num_VdetDebtAmount - Num_VdetCreditAmount AS BIGINT) AS Acc_Rest
        FROM ##TmpVchTafBaBiMandeh
    ),
    RunningSum AS (
        SELECT 
            *,
            SUM(Acc_Rest) OVER (ORDER BY MyId) AS Acc_Rest_Sum
        FROM FinalData
    )
    SELECT 
        MyId,
        SiAccVoucher_Hd,
        Num_VhedFinalNo,
        Num_VhedSubNo,
        Dat_VhedDate,
        Dat_VhedDateMonth,
        Num_VDetRow,
        Des_VdetDesc,
        Num_VdetDebtAmount,
        Num_VdetCreditAmount,
        Acc_Rest,
        Acc_Rest_Sum
    FROM RunningSum
    ORDER BY Dat_VhedDate, SiAccVoucher_Hd, Num_VDetRow

    -- Cleanup
    DROP TABLE IF EXISTS #TempTable
    DROP TABLE IF EXISTS ##TmpVchTaf
    DROP TABLE IF EXISTS ##TmpVchTafMandeh
    DROP TABLE IF EXISTS ##TmpVchTafBaBiMandeh
END

GO