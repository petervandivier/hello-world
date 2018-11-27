use <DbName,sysname,>
go

if object_id( N'<schema,sysname,dbo>.<name,sysname,>','IF' ) is null
	exec sp_executesql N'create function <schema,sysname,dbo>.<name,sysname,>() returns table as return(select a=1);';
go

alter function <schema,sysname,dbo>.<name,sysname,> (
	<@Param1,,@> <Param1DataType,datatype,>
)
returns table
as
/************************************************************************************************
-- Description : <PurposeOfFunction,,>
-- Date 		Developer 		Issue# 		Description
--------------- ------------------- ------------------------------------------------------------
-- <Today,,>	<WhoAmI,,petervandivier>	<Issue#,,DAT-0000>	<Description1,,create function>
--***********************************************************************************************
-- testing purposes 

select * from <schema,sysname,dbo>.<name,sysname,>(<@TestParam1,,>); 
select * from <schema,sysname,dbo>.<name,sysname,>(<@TestParam2,,>); 
select * from <schema,sysname,dbo>.<name,sysname,>(<@TestParam3,,>); 

*/
return (
	select 
	
	from 
	where <@Param1,,@>
	;
)
go
