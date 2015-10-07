-- copied from http://blog.sqlauthority.com/2009/07/19/sql-server-get-last-running-query-based-on-spid/

declare 
	@Login varchar( 255 ) = '',
	@Db varchar( 255 ) = '' ;

declare @t table
(
	Spid  int,
	[Status] varchar( 100 ),
	[Login] varchar( 100 ),
	HostName varchar( 100 ),
	BlkBy varchar( 100 ),
	DbName varchar( 100 ),
	Command varchar( 100 ),
	CpuTime bigint,
	DiskIo bigint,
	LastBatch varchar( 100 ),
	ProgramName varchar( 100 ),
	Spid_ int,
	RequestId int
);

insert into @t
exec sp_who2 ;

select *
from @t 
where Login = @Login and DbName = @Db ;


DECLARE @trans table( sqltext VARBINARY(128), trantext varchar( max ) ) ;

insert @trans ( sqltext )
SELECT sql_handle
FROM sys.sysprocesses
WHERE spid in ( select spid from @t where Login = @Login and DbName = @Db ) ;

update @trans set
	trantext = ( select TEXT from sys.dm_exec_sql_text(sqltext) )
FROM @trans ;

select * from @trans ;
GO