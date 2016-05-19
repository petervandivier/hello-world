USE <DbName,sysname,>
GO

IF object_id( N'<schema,sysname,dbo>.<name,sysname,udf_>' ) is null
	EXEC sp_executesql N'create function <schema,sysname,dbo>.<name,sysname,udf_>() returns int as BEGIN return 0; end;';
GO

ALTER FUNCTION <schema,sysname,dbo>.<name,sysname,udf_> 
(
	<@Param1,,@> <Param1DataType,datatype,>
)
RETURNS <ReturnType,datatype,>
AS
/************************************************************************************************
-- Description : <PurposeOfFunction,,>
-- Date 		Developer 		Issue# 		Description
--------------- ------------------- ------------------------------------------------------------
-- <Today,,>	<WhoAmI,,petervandivier>	<Issue#,,DAT-0000>	<Description1,,create function>
--***********************************************************************************************
-- testing purposes 

select r = <schema,sysname,dbo>.<name,sysname,udf_>(<@TestParam1,,@>); 

*/
BEGIN
	DECLARE <@Result,,@> <ReturnType,datatype,>, <@InScopeVar,,@> <InScopeVarDatatype,datatype,>;
	SELECT <@InScopeVar,,@> = ;
	SELECT <@Result,sysname,@> = convert( <ReturnType,datatype,>, <@InScopeVar,,@> );
	RETURN <@Result,sysname,@>;

END;

GO
