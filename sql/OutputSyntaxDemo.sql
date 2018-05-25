if object_id( N'tempdb..#outputTest' ) is not null drop table #outputTest ;

select top 1 [object_id]
into #outputTest
from sys.objects
truncate table #outputTest

declare @t table ( col1 int );

insert @t ( col1 )
output inserted.* into #outputTest
select 
	[object_id]
from sys.objects

select * from #outputTest

