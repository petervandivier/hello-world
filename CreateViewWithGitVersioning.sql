USE <DbName,sysname,>
GO

IF object_id( N'<schema,sysname,dbo>.<name,sysname,v>' ) IS NULL
	EXEC sp_executesql N'CREATE VIEW <schema,sysname,dbo>.<name,sysname,v> SELECT a=1;';
GO

ALTER VIEW <schema,sysname,dbo>.<name,sysname,v> 
AS
/************************************************************************************************
-- Description : <PurposeOfVIEW,,>
-- Date 		Developer 		Issue# 		Description
--------------- ------------------- ------------------------------------------------------------
-- <Today,,>	<WhoAmI,,petervandivier>	<Issue#,,DAT-0000>	<Description1,,create VIEW>
--***********************************************************************************************
-- testing purposes 

SELECT TOP 1000 * 
FROM <schema,sysname,dbo>.<name,sysname,v>; 

*/
 
SELECT 

FROM 

WHERE ;

GO
