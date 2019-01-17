use [master]
go
create database frag_me_seymour;
alter authorization on database ::frag_me_seymour to sa;
go
use frag_me_seymour
go
drop table if exists foo;
create table foo (
     i int identity primary key
    ,c char(7900) default 'bar'
);
go
insert foo default values
go
select
     db       = db_name()
    ,[Schema] = s.[name]
    ,[Table]  = t.[name]
    ,[Index]  = i.[name]
    ,frag_pct = ips.avg_fragmentation_in_percent
    ,pages    = ips.page_count
from sys.dm_db_index_physical_stats ( db_id(), null, null, null, null ) as ips
inner join sys.tables t on t.[object_id] = ips.[object_id]
inner join sys.schemas s on t.[schema_id] = s.[schema_id]
inner join sys.indexes i 
    on i.[object_id] = ips.[object_id] 
    and ips.index_id = i.index_id
where t.name = 'foo'
go
use [master]
go
EXECUTE dbo.IndexOptimize
	@Databases = 'frag_me_seymour',
	@LogToTable = 'Y',
	@MinNumberOfPages = 0;

select top(10) * 
from CommandLog 
where DatabaseName = 'frag_me_seymour'
order by id desc
go
drop database if exists frag_me_seymour;
go
