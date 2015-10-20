print db_name()

if exists ( select * 
			from sys.objects 
			where [object_id] = object_id( N'dbo.spGetDataTableSize' ) and 
				[type] in ( N'P' ) )
begin
	drop proc spGetDataTableSize ;
	print 'Dropped proc dbo.spGetDataTableSize SUCCESSFULLY! At time ' + convert( varchar, getdate(), 126 ) ;
end ;
go

create proc dbo.spGetDataTableSize
	@TableNameLike varchar( 100 )
as
/* who				when			what
petervandivier		2015-10-05		create proc to show the size of a family of similarly named data tables
*/
begin
	set nocount on;
	set tran isolation level read uncommitted ;

	SELECT 
		t.NAME AS TableName,
		s.Name AS SchemaName,
		p.rows AS RowCounts,
		SUM(a.total_pages) * 8 AS TotalSpaceKB, 
		SUM(a.used_pages) * 8 AS UsedSpaceKB, 
		(SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB
	FROM sys.tables t
	INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id
	INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
	INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
	LEFT OUTER JOIN sys.schemas s ON t.schema_id = s.schema_id
	WHERE ( t.NAME LIKE '%%' + @TableNameLike + '%%' )AND
		t.is_ms_shipped = 0 AND 
		i.OBJECT_ID > 255 
	GROUP BY 
		t.Name, 
		s.Name, 
		p.[rows]
	ORDER BY 
		t.Name ;

	return 0 ;

end ;

/*
declare 
	@TableNameLike @varchar( 100 ) = ;

exec dbo.spGetDataTableSize 
	@TableNameLike ;
*/

go

if exists ( select * 
			from sys.objects 
			where [object_id] = object_id( N'dbo.spGetDataTableSize' ) and 
				[type] in ( N'P' ) )
begin
	print 'Created proc dbo.spGetDataTableSize SUCCESSFULLY! At time ' + convert( varchar, getdate(), 126 ) ;
end ;
go