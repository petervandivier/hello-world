USE <DbName,sysname,>
GO

IF object_id( N'<schema,sysname,dbo>.<name,sysname,udf_>' ) is null
	EXEC sp_executesql N'create function <schema,sysname,dbo>.<name,sysname,udf_>() RETURNS @r TABLE(i int)AS BEGIN INSERT @r SELECT 1 RETURN; END;';
GO

ALTER function <schema,sysname,dbo>.<name,sysname,udf_> 
(
	<@Param1,,@> <Param1DataType,datatype,>
)
RETURNS <ResultTableName,,@> TABLE 
(
	<Col1Name,sysname,Id> <Col1DataType,datatype,int identity not null>
	,<Col2Name,sysname,> <Col2DataType,datatype,>
)
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
BEGIN
	DECLARE <@InScopeVar,,@> <InScopeVarDatatype,datatype,>;
	SELECT <@InScopeVar,,@> = ;
	
	INSERT <ResultTableName,,@>
	( 
		<Col1Name,sysname,Id>,
		<Col2Name,sysname,>
	)
	SELECT 
		<Col1Name,sysname,Id>,
		<Col2Name,sysname,>
	FROM 
	WHERE <@InScopeVar,,@> 
	;

	RETURN;
END;

GO
