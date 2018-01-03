USE Warehouse
GO
-- SELECT * FROM dbo.Months;
-- DROP TABLE dbo.Months;

IF EXISTS ( SELECT * 
			FROM sys.objects 
			WHERE [object_id] = object_id( N'dbo.Months' ) 
				AND [type] in ( N'U' ) )
BEGIN
	SET NOCOUNT ON;
	
	SELECT * 
	INTO #DropNpop_dboMonths
	FROM dbo.Months;

	DROP TABLE dbo.Months;
	PRINT 'Dropped table dbo.Months SUCCESSFULLY! At time ' + convert( varchar, getdate(), 126 );
END;
GO

CREATE TABLE dbo.Months
(
	ID tinyint NOT NULL CONSTRAINT pk_Months PRIMARY KEY CLUSTERED,
	M AS convert( varchar(2), ID ) PERSISTED NOT NULL,
	MMMM AS convert( varchar(10), rtrim( substring( 'Unknown   January   February  March     April     May       June      July      August    September October   November  December  ', ((ID+1)*10)-9, 10 ) ) ) PERSISTED NOT NULL,
	MMM AS convert( char(3), substring( 'Unk Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec ', ((ID+1)*4)-3, 3 ) ) PERSISTED NOT NULL,
	MM AS convert( char(2), right( '0' + convert( varchar(2), ID ), 2 ) ) PERSISTED NOT NULL, 
	InsertBy varchar(100) NOT NULL,
	InsertDT datetime NOT NULL,
	LastUpdateBy varchar(100) NOT NULL,
	LastUpdateDT datetime NOT NULL ,
	Revision int NOT NULL
);

GO

/* -- INIT POP
WITH cte ( ID ) AS
(
	SELECT 
		ID = 0
	UNION ALL
	SELECT 
		ID + 1
	FROM cte
	WHERE ID < 12
) 
INSERT dbo.Months ( ID, InsertBy, InsertDT, LastUpdateBy, LastUpdateDT, Revision )
SELECT ID, suser_sname(), getdate(), suser_sname(), getdate(), 0
FROM cte;

*/

IF object_id( N'tempdb..#DropNpop_dboMonths' ) IS NOT NULL
BEGIN

	DECLARE @sql nvarchar( max ) = ''; 

	SELECT @sql += 
		quotename( c1.name ) + ',' 
	FROM sys.columns c1
	JOIN tempdb.sys.columns c2 ON 
		c2.name = c1.name and
		c2.[object_id] = object_id( N'tempdb..#DropNpop_dboMonths' )
	WHERE c1.[object_id] = object_id( N'dbo.Months' ) and 
		c1.is_computed = 0;

	SET @sql = left( @sql, len( @sql ) - 1 );
		
	SET @sql = 
	'INSERT dbo.Months 
		(' + @sql + ') 
	SELECT 
		' + @sql + '
	FROM #DropNpop_dboMonths;';

	EXEC sp_executesql @sql;

END;
	
GO

IF EXISTS ( SELECT * 
			FROM sys.objects 
			WHERE [object_id] = object_id( N'dbo.Months' ) and 
				[type] in ( N'U' ) )
BEGIN
	PRINT 'Created table dbo.Months SUCCESSFULLY! At time ' + convert( varchar, getdate(), 126 );
END;

GO

CREATE TRIGGER tr_Months_LogLastUpdate 
ON dbo.Months
INSTEAD OF UPDATE, DELETE, INSERT
AS
/* who			when		Issue		what
petervandivier	2016-07-01	DAT-3451	trigger to PREVENT changes
*/
BEGIN
	RAISERROR('Table is read-only.',11,1);
	RETURN;
END;
GO
