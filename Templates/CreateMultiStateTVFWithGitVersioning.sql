use <DbName,sysname,>
go

if object_id( N'<schema,sysname,dbo>.<name,sysname,mtf>' ) is null
	exec sp_executesql N'create function <schema,sysname,dbo>.<name,sysname,mtf>() returns @r table(i int)as begin insert @r select 1 return; end;';
go

alter function <schema,sysname,dbo>.<name,sysname,mtf> 
(
	<@Param1,,@> <Param1DataType,datatype,>
)
returns <ResulttableName,,@> table 
(
	<Col1Name,sysname,Id> <Col1DataType,datatype,int identity not null>
	,
)
as
/************************************************************************************************
-- Description : <PurposeOfFunction,,>
-- Date 		Developer 		Issue# 		Description
--------------- ------------------- ------------------------------------------------------------
-- <Today,,>	<WhoAmI,,petervandivier>	<Issue#,,DAT-0000>	<Description1,,create function>
--***********************************************************************************************
-- testing purposes 

select * from <schema,sysname,dbo>.<name,sysname,mtf>(<@TestParam1,,>); 
select * from <schema,sysname,dbo>.<name,sysname,mtf>(<@TestParam2,,>); 
select * from <schema,sysname,dbo>.<name,sysname,mtf>(<@TestParam3,,>); 

*/
begin
	
	insert <ResulttableName,,@>
	( 
		<Col1Name,sysname,Id>
		,
	)
	select 
		<Col1Name,sysname,Id>
		,
	from ;
	

	return;
end;

go
