USE <DbName,,>
GO

IF object_id( N'<schemaName,,dbo>.<procName,,sp>' ) IS NULL
	EXEC sp_executesql N'CREATE PROC <schemaName,,dbo>.<procName,,sp> AS BEGIN; RETURN 0; END;';
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
ALTER PROC <schemaName,,dbo>.<procName,,sp>
	<@param1,,@var> <dataType1,,> <Param1Default,,= null>
/************************************************************************************************
-- Description : <PurposeOfProc,,>
-- Date 		Developer 		Issue# 		Description
--------------- ------------------- ------------------------------------------------------------
-- <Today,,>	<WhoAmI,,petervandivier>	<Issue#,,DAT-0000>	<Description1,,create proc>
--***********************************************************************************************
-- TESTING FRAMEWORK
EXEC <schemaName,,dbo>.<procName,,sp> 
	<@param1,,@var> <Param1Default,,= null>;

*/
AS
BEGIN;
	SET NOCOUNT ON;
	SET TRAN ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE
		@ProcName sysname = '<schemaName,,dbo>.<procName,,sp>',
		@ProcRunDT datetime = getdate(),
		@ErrMsg nvarchar( 4000 ) = '',
		@Lb char( 1 ) = char( 10 );
	
ReturnResults:

	RETURN 0;
END;

GO
