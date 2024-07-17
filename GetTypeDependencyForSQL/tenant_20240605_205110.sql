DROP FUNCTION IF EXISTS notice."FilterNotices";

/*-----------------------------------------------------------------------------------------------------
* 	Procedure Name	:	[notice].[FilterNotices]
* 	Comment			:	11/05/2022 | Rippal Patel | This procedure is used to Filter Notices.
--------------------------------------------------------------------------------------------------------
*	Sample Execution :	DECLARE @TotalRecord INT,
								@EntityIds AS [common].[IntType],
								@Ids [common].[BigIntType];
											
						INSERT INTO @EntityIds VALUES(385);
								
						EXEC [notice].[FilterNotices]
							@SubscriberId  = 172,
							@Ids = @Ids,
							@FinancialYear  = 202021,
							@EntityIds =  @EntityIds,
							@NoticeIds = null,
							@FromNoticeDate = null,
							@ToNoticeDate = null,
							@FromNoticeDueDate = null,
							@ToNoticeDueDate = null,
							@CategoryTypes = null,
							@ActionStatuses = null,
							@Start  = 0,
							@Size  = 20,
							@SortExpression = null,
							@TotalRecord  = @TotalRecord OUT
						SELECT @TotalRecord;
--------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [notice].[FilterNotices]
(
	 @SubscriberId INT,
	 @Ids [common].[BigIntType] READONLY,
	 @FinancialYear INT,
	 @EntityIds [common].[IntType] READONLY,
	 @NoticeIds VARCHAR(MAX),
	 @FromNoticeDate DATETIME NULL,
	 @ToNoticeDate DATETIME NULL,
	 @FromNoticeDueDate DATETIME NULL,
	 @ToNoticeDueDate DATETIME NULL,
	 @CategoryTypes VARCHAR(MAX),
	 @ActionStatuses VARCHAR(MAX),
	 @Start INT,
	 @Size INT,
	 @SortExpression VARCHAR(50),
	 @TotalRecord INT = NULL OUTPUT
)
AS
BEGIN

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @SQL AS NVARCHAR(MAX) = '',
			@FromSQL AS NVARCHAR(MAX) = '';
	
	SELECT 
		Item 
	INTO 
		#TempEntities
	FROM 
		@EntityIds;

	SELECT
		Item
	INTO
		#TempIds
	FROM
		@Ids;

	CREATE CLUSTERED INDEX IDX_TempEntities_Item ON #TempEntities(Item);

	SELECT @FromSQL = CONCAT(N'
						FROM 
							notice.Notices n
							INNER JOIN #TempEntities te ON n.EntityId = te.Item 
						WHERE
							n.SubscriberId = @SubscriberId
							AND n.FinancialYear = @FinancialYear
							',
						CASE
							WHEN EXISTS (SELECT Item FROM #TempIds)
							THEN ' AND n.Id IN (SELECT Item FROM #TempIds)'
							ELSE ''
						END,
						CASE 
							WHEN @NoticeIds IS NULL 
							THEN ''
							ELSE' AND n.NoticeId IN ('+ @NoticeIds +')'  
						END,
						CASE 
							WHEN @FromNoticeDate IS NULL AND @ToNoticeDate IS NULL
							THEN ''
							ELSE ' AND n.NoticeDate BETWEEN @FromNoticeDate AND @ToNoticeDate '
						END,
						CASE 
							WHEN @FromNoticeDueDate IS NULL AND @ToNoticeDueDate IS NULL
							THEN ''
							ELSE ' AND n.NoticeDueDate BETWEEN @FromNoticeDueDate AND @ToNoticeDueDate '
						END,
						CASE 
							WHEN @CategoryTypes IS NULL 
							THEN ''
							ELSE' AND n.CategoryType IN ('+ @CategoryTypes +')'  
						END,
						CASE 
							WHEN @ActionStatuses IS NULL 
							THEN ''
							ELSE' AND n.ActionStatus IN ('+ @ActionStatuses +')'  
						END
						);

	IF @Start = 0
	BEGIN
		SELECT @SQL = CONCAT('SELECT @TotalRecord = COUNT(n.ID)', @FromSQL);
			
		EXEC SP_EXECUTESQL @SQL, 
			N'@SubscriberId INT,
			@FinancialYear INT,
			@FromNoticeDate DATETIME = NULL,
			@ToNoticeDate DATETIME = NULL,
			@FromNoticeDueDate DATETIME = NULL,
			@ToNoticeDueDate DATETIME = NULL,
			@TotalRecord INT OUTPUT',
			@SubscriberId = @SubscriberId,
			@FinancialYear  = @FinancialYear,
			@FromNoticeDate = @FromNoticeDate,
			@ToNoticeDate = @ToNoticeDate,
			@FromNoticeDueDate = @FromNoticeDueDate,
			@ToNoticeDueDate = @ToNoticeDueDate,
			@TotalRecord = @TotalRecord OUTPUT;
	END;

	IF (@SortExpression IS NULL OR @SortExpression = '')
	BEGIN
		SET @SortExpression = 'Id DESC'
	END

	IF (LTRIM(RTRIM(@SortExpression)) <> 'Id DESC' AND  LTRIM(RTRIM(@SortExpression)) <> 'Id ASC')
	BEGIN 
		SET @SortExpression = @SortExpression + ' , n.Id DESC '
	END
	SELECT @SQL = CONCAT('SELECT n.ID', @FromSQL, ' ORDER BY n.', @SortExpression, ' OFFSET @Start ROWS', ' FETCH NEXT @Size ROWS ONLY');
	
	EXEC SP_EXECUTESQL @SQL, 
			N'@SubscriberId INT,
			@FinancialYear INT,
			@FromNoticeDate DATETIME = NULL,
			@ToNoticeDate DATETIME = NULL,
			@FromNoticeDueDate DATETIME = NULL,
			@ToNoticeDueDate DATETIME = NULL,
			@Start INT, 
			@Size INT ',
			@SubscriberId = @SubscriberId,
			@FinancialYear  = @FinancialYear,
			@FromNoticeDate = @FromNoticeDate,
			@ToNoticeDate = @ToNoticeDate,
			@FromNoticeDueDate = @FromNoticeDueDate,
			@ToNoticeDueDate = @ToNoticeDueDate,
			@Start = @Start,
			@Size = @Size;

	DROP TABLE #TempIds, #TempEntities;
END;
DROP FUNCTION IF EXISTS notice."GetNoticesByIds";

/*-----------------------------------------------------------------------------------------------------
* 	Procedure Name	:	[notice].[GetNoticesByIds]
* 	Comment			:	12/05/2022 | Rippal Patel | This procedure is used to get Notices.
					:   04-08-2022 | Krishna Shah | Added UploadedOrDownloadedDateTime in response.
--------------------------------------------------------------------------------------------------------
*	Sample Execution :	DECLARE @Ids [common].[BigIntType];
											
						INSERT INTO @Ids VALUES(385);
								
						EXEC [notice].[GetNoticesByIds]
							@SubscriberId  = 172,
							@Ids = @Ids;
--------------------------------------------------------------------------------------------------------*/
CREATE PROCEDURE [notice].[GetNoticesByIds]
(
	 @SubscriberId INT,
	 @Ids [common].[BigIntType] READONLY
)
AS
BEGIN
	CREATE TABLE #TempNoticeIds
	(
		AutoId INT IDENTITY(1,1) NOT NULL,
		Id BIGINT
	);

	INSERT INTO #TempNoticeIds(Id)
	SELECT 
		*
	FROM 
		@Ids;

	SELECT 
		n.Id,
		n.EntityId,
		n.NoticeId,
		n.[Description],
		n.NoticeDate,
		n.NoticeDueDate,
		n.NoticeStatus,
		n.ActionStatus,
		n.CategoryType,
		n.Details,
	    n.Stamp
	FROM 
		notice.Notices n
		INNER JOIN #TempNoticeIds tni ON n.Id = tni.Id	
	WHERE 
		n.SubscriberId = @SubscriberId
	ORDER BY
		tni.AutoId;

	DROP TABLE #TempNoticeIds;
END;
DROP FUNCTION IF EXISTS notice."GetRecentNotice";

/*-----------------------------------------------------------------------------------------------------
* 	Procedure Name	:	[notice].[GetRecentNotice]
* 	Comment			:	08/02/2024 | Sumant Kumar | This procedure is used to get 5  recent notice.
----------------------------------------------------------------------------------------------*/

CREATE PROCEDURE [notice].[GetRecentNotice]
(
	 @SubscriberId INT,
	 @EntityIds [common].[IntType] READONLY
)
AS
BEGIN
	SELECT
		Item
	INTO 
		#TempEntityIds
	FROM 
		@EntityIds;
     SELECT TOP 5
	     n.EntityId,
		 n.NoticeDate,
		 n.[Description]
     FROM
	     notice.Notices n
	 WHERE 
	     n.SubscriberId = @SubscriberId
		 AND  n.EntityId IN (SELECT Item From #TempEntityIds)
	 ORDER BY 
	     n."Stamp" DESC;
END;
