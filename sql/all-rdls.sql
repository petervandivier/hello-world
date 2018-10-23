use ReportServer
go

with VarBinMax as ( 
	select 
		 ItemID
		,VarBinMax = try_convert(varbinary(max),[Content])
		,HasBom = convert(bit,iif(left(try_convert(varbinary(max),[Content]),3)=0xEFBBBF,1,0))
		,LenVarBinMax = len(try_convert(varbinary(max),[Content]))
		--,[Type]
	from [Catalog]
	where [Type] = 2
) -- select top(10) * from VarBinMax
, ContentNoBom as (
	select 
		 ItemID
		,ContentNoBom = convert(varbinary(max),iif(HasBom=1,substring(VarBinMax,4,LenVarBinMax),VarBinMax))
	from VarBinMax
)  --select top(10) * from ContentNoBom
select 
	 ItemID
	,RdlXml = convert(xml,ContentNoBom)
	,RdlText = convert(nvarchar(max),convert(xml,ContentNoBom))
into #RDL
from ContentNoBom cnb

select * 
from #RDL