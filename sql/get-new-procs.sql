drop table if exists #new_procs;
create table #new_procs (
	db sysname
	,sch sysname
	,obj sysname
	,id int
	,mdate datetime
);

insert #new_procs
exec sp_MSforeachdb 'use [?]

select 
	db_name()
	,[schema_name] = schema_name([schema_id])
	,[name]
	,[object_id]
	,modify_date
from sys.procedures 
where modify_date > dateadd(day,-2,getdate())
';

select * from #new_procs