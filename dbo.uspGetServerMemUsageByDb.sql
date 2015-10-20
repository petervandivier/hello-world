print db_name() ;

if exists ( select * 
			from sys.objects 
			where [object_id] = object_id( N'dbo.uspGetServerMemUsageByDb' ) and 
				[type] in ( N'P' ) )
begin
	drop proc dbo.uspGetServerMemUsageByDb ;
	print 'Dropped proc dbo.uspGetServerMemUsageByDb SUCCESSFULLY! At time ' + convert( varchar, getdate(), 126 ) ;
end ;
go

create proc dbo.uspGetServerMemUsageByDb
as
/* who				when			what
petervandivier		2015-10-14		return remaining server phys mem by Db
*/
begin
	set tran isolation level read uncommitted ;
	set nocount on ;

	if object_Id( N'tempdb..##DbSizes' ) is not null drop table ##DbSizes ;

	create table ##DbSizes
	(
		DbName sysname,
		[DbId] int,
		TotalSpaceKB int,
		UsedSpaceKB int,
		UnusedSpaceKB int
	) ;

	declare
		@DbName sysname,
		@DbId int,
		@Sql nvarchar( max ),
		@Counter int = 0 ;

	declare CursorDb cursor for
		select name, database_id from [master].sys.databases order by database_id ;

	open CursorDb ;
	fetch next from CursorDb into @DbName, @DbId ;

	-- print @DbName

	while @@fetch_status = 0
	begin
		set @Sql = 
'insert ##DbSizes
SELECT 
	''' + @DbName + ''',
	' + convert( varchar, @DbId ) + ',
	SUM(a.total_pages) * 8 AS TotalSpaceKB, 
	SUM(a.used_pages) * 8 AS UsedSpaceKB, 
	(SUM(a.total_pages) - SUM(a.used_pages)) * 8 AS UnusedSpaceKB
FROM ' + @DbName + '.sys.tables t
INNER JOIN ' + @DbName + '.sys.indexes i ON t.OBJECT_ID = i.object_id
INNER JOIN ' + @DbName + '.sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
INNER JOIN ' + @DbName + '.sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.is_ms_shipped = 0 AND 
	i.OBJECT_ID > 255 ;' ;

		-- print @Sql

		exec sp_executesql @Sql ;

		select @Counter += 1 ;
		if @Counter > 100 break ;

		fetch next from CursorDb into @DbName, @DbId ;

	end ;

	close CursorDb ;
	deallocate CursorDb ;

	insert ##DbSizes
	select
		convert( varchar, serverproperty( 'servername' ) ),
		0,
		sum( TotalSpaceKb ),
		sum( UsedSpaceKb ),
		sum( UnusedSpaceKb )
	from ##DbSizes ;

	select *, convert( float, UnusedSpaceKb ) / nullif( convert( float, TotalSpaceKb ), 0 ) as PctRemaining
	from ##DbSizes
	order by [DbId] ;



	-- select * from [master].sys.databases

	return 0 ;
end ;

/*

exec dbo.uspGetServerMemUsageByDb 

*/

go

if exists ( select * 
			from sys.objects 
			where [object_id] = object_id( N'dbo.uspGetServerMemUsageByDb' ) and 
				[type] in ( N'P' ) )
begin
	print 'Created proc dbo.uspGetServerMemUsageByDb SUCCESSFULLY! At time ' + convert( varchar, getdate(), 126 ) ;
end ;
else
begin
	print 'Create proc dbo.uspGetServerMemUsageByDb FAILED! At time ' + convert( varchar, getdate(), 126 ) ;
end ; 
go