use <DbName,sysname,>
go

if object_id( N'<schema,sysname,dbo>.<name,sysname,v>' ) is null
	exec sp_executesql N'create view <schema,sysname,dbo>.<name,sysname,v> AS select a=1;';
go

alter view <schema,sysname,dbo>.<name,sysname,v> 
as
/************************************************************************************************
-- Description : <PurposeOfview,,>
-- Date 		Developer 		Issue# 		Description
--------------- ------------------- ------------------------------------------------------------
-- <Today,,>	<WhoAmI,,petervandivier>	<Issue#,,DAT-0000>	<Description1,,create view>
--***********************************************************************************************
-- testing purposes 

select top 1000 * 
from <schema,sysname,dbo>.<name,sysname,v>; 

*/
 
select 

from 

where ;

go
