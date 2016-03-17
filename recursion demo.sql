DECLARE	
@StartDate DATETIME = '2015-01-01',
@EndDate DATETIME = '2016-04-10'

;WITH GetDateTable ([FullDate], [MMDDYY])
AS 
(
	SELECT
		[FullDate] =	@StartDate,
		[MMDDYY] =		REPLACE((CONVERT(VARCHAR, @StartDate, 1)), '/', '') 
	UNION ALL 
	SELECT
		(DATEADD(DAY, 1, [FullDate])),
		REPLACE((CONVERT(VARCHAR, (DATEADD(DAY, 1, [FullDate])), 1)), '/', '')
	FROM GetDateTable
	WHERE [FullDate] < @EndDate
)
SELECT
	[FullDate],
	[MMDDYY]
FROM GetDateTable
OPTION (MAXRECURSION 1000)
