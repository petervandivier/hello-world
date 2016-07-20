use <DbName,sysname,>
go

if object_id( N'<schema,sysname,dbo>.<name,sysname,fn>' ) is null
	exec sp_executesql N'create function <schema,sysname,dbo>.<name,sysname,fn>() returns int as begin return 0; end;';
go

alter function <schema,sysname,dbo>.<name,sysname,fn> 
(
	<@Param1,,@> <Param1DataType,datatype,>
)
returns <returnType,datatype,>
as
/************************************************************************************************
-- Description : <PurposeOfFunction,,>
-- Date 		Developer 		Issue# 		Description
--------------- ------------------- ------------------------------------------------------------
-- <Today,,>	<WhoAmI,,petervandivier>	<Issue#,,DAT-0000>	<Description1,,create function>
--***********************************************************************************************
-- testing purposes 

select r = <schema,sysname,dbo>.<name,sysname,fn>(<@TestParam1,,@>); 

*/
begin
	declare <@Result,,@> <returnType,datatype,>, <@InScopeVar,,@> <InScopeVarDatatype,datatype,>;
	select <@InScopeVar,,@> = ;
	select <@Result,sysname,@> = convert( <returnType,datatype,>, <@InScopeVar,,@> );
	return <@Result,sysname,@>;

end;

go
