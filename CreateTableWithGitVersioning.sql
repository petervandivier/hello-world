USE <DbName,,>
GO
-- SELECT * FROM <schemaName,,dbo>.<tableName,,>;

IF EXISTS ( SELECT * 
			FROM sys.objects 
			WHERE [object_id] = object_id( N'<schemaName,,dbo>.<tableName,,>' ) 
				AND [type] in ( N'U' ) )
BEGIN
	SET NOCOUNT ON;
	
	SELECT * 
	INTO #DropNpop_<schemaName,,dbo><tableName,,>
	FROM <schemaName,,dbo>.<tableName,,>;

	DROP TABLE <schemaName,,dbo>.<tableName,,>;
	PRINT 'Dropped table <schemaName,,dbo>.<tableName,,> SUCCESSFULLY! At time ' + convert( varchar, getdate(), 126 );
END;
GO

CREATE TABLE <schemaName,,dbo>.<tableName,,>
(
	<tableName,,>Id int NOT NULL identity,
	<tableName,,>Name varchar( 100 ) NOT NULL CONSTRAINT chk_<tableName,,>_NameIsNotEmpty check ( datalength( ltrim( rtrim( <tableName,,>Name ) ) ) > 0 ),
	
	InsertBy varchar( 100 ) NOT NULL CONSTRAINT df_<tableName,,>_InsertedBy DEFAULT replace( system_user, 'GRCORP\', '' ),
	InsertDT datetime NOT NULL CONSTRAINT df_<tableName,,>_InsertDatetime DEFAULT getdate(),
	LastUpdateBy varchar( 100 ) NOT NULL CONSTRAINT df_<tableName,,>_LastUpdateBy DEFAULT replace( system_user, 'GRCORP\', '' ),
	LastUpdateDT datetime NOT NULL CONSTRAINT df_<tableName,,>_LastUpdateDatetime DEFAULT getdate(),
	Revision int NOT NULL CONSTRAINT df_<tableName,,>_Revision DEFAULT 0,
	CONSTRAINT pk_<tableName,,>_Id primary key ( <tableName,,>Id )
);

GO

CREATE UNIQUE NONCLUSTERED INDEX ak_<tableName,,>_Name ON <schemaName,,dbo>.<tableName,,> ( <tableName,,>Name );

GO

IF object_id( N'tempdb..#DropNpop_<schemaName,,dbo><tableName,,>' ) IS NOT NULL
BEGIN

	<HasId,-- ( no ),-- >SET identity_INSERT <schemaName,,dbo>.<tableName,,> ON;

	DECLARE @sql nvarchar( max ) = ''; 

	SELECT @sql += 
		quotename( c1.name ) + ',' 
	FROM sys.columns c1
	JOIN tempdb.sys.columns c2 ON 
		c2.name = c1.name and
		c2.[object_id] = object_id( N'tempdb..#DropNpop_<schemaName,,dbo><tableName,,>' )
	WHERE c1.[object_id] = object_id( N'<schemaName,,dbo>.<tableName,,>' ) and 
		c1.is_computed = 0;

	SET @sql = left( @sql, len( @sql ) - 1 );
		
	SET @sql = 
	'INSERT <schemaName,,dbo>.<tableName,,> 
		(' + @sql + ') 
	SELECT 
		' + @sql + '
	FROM #DropNpop_<schemaName,,dbo><tableName,,>;';

	EXEC sp_executesql @sql;

	<HasId,-- ( no ),-- > SET identity_INSERT <schemaName,,dbo>.<tableName,,> off;

END;
	
GO

IF EXISTS ( SELECT * 
			FROM sys.objects 
			WHERE [object_id] = object_id( N'<schemaName,,dbo>.<tableName,,>' ) and 
				[type] in ( N'U' ) )
BEGIN
	PRINT 'Created table <schemaName,,dbo>.<tableName,,> SUCCESSFULLY! At time ' + convert( varchar, getdate(), 126 );
END;

go

create trigger tr_<tableName,,>_LogLastUpdate 
on <schemaName,,dbo>.<tableName,,>
<TriggerWhen,,after> <TriggerWhat,,update>
as
/* who				when			what
<Creator,,petervandivier>		<CreateDate,,>	<Description,,TRIGGER to log update revisions>
*/
begin
	SET nocount on;
	
	update <schemaName,,dbo>.<tableName,,> SET 
		LastUpdateBy = replace( system_user, 'GRCORP\', '' ),
		LastUpdateDatetime = getdate(),
		Revision += 1
	FROM <schemaName,,dbo>.<tableName,,> a
	JOIN inserted b on a.<PK,,> = b.<PK,,>;
end;
go
