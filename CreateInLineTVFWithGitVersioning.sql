USE <DbName,sysname,>
GO

IF object_id( N'<schema,sysname,dbo>.<name,sysname,udf_>' ) is null
	EXEC sp_executesql N'create function <schema,sysname,dbo>.<name,sysname,udf_>() RETURNS TABLE AS RETURN(SELECT a=1);';
GO

ALTER function <schema,sysname,dbo>.<name,sysname,udf_> 
(
	<@Param1,,@> <Param1DataType,datatype,>
)
RETURNS TABLE
AS
/************************************************************************************************
-- Description : <PurposeOfFunction,,>
-- Date 		Developer 		Issue# 		Description
--------------- ------------------- ------------------------------------------------------------
-- <Today,,>	<WhoAmI,,petervandivier>	<Issue#,,DAT-0000>	<Description1,,create function>
--***********************************************************************************************
-- testing purposes 

select * from <schema,sysname,dbo>.<name,sysname,udf_>(<@TestParam1,,>); 
select * from <schema,sysname,dbo>.<name,sysname,udf_>(<@TestParam2,,>); 
select * from <schema,sysname,dbo>.<name,sysname,udf_>(<@TestParam3,,>); 

*/
RETURN 
(
	SELECT 
	
	FROM 
	WHERE <@Param1,,@>
	;
)
GO
