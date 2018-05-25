USE DBAdmin
GO

IF object_id( N'dbo.fnXmlNodeValue' ) is null
	EXEC sp_executesql N'create function dbo.fnXmlNodeValue() RETURNS TABLE AS RETURN(SELECT a=1);';

SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Peter Vandivier
-- Create date: 2016-03-17
-- Description:	copied from http://stackoverflow.com/a/10885014/4709762
-- =============================================
/* MODIFICATIONS
who				when			what


-- TESTING FRAMEWORK
select * 
from dbo.fnXmlNodeValue( '<Params><Mmm>Jan</Mmm><Yyyy>2016</Yyyy></Params>' );

*/
ALTER FUNCTION dbo.fnXmlNodeValue 
(	
	@x xml 	 
)
RETURNS TABLE 
AS
RETURN 
(
	WITH cte AS 
	(  
		SELECT 
			lvl =				1,  
			Name =				x.value('local-name(.)','NVARCHAR(MAX)'),  
			ParentName =		CAST(NULL AS NVARCHAR(MAX)), 
			ParentPosition =	CAST(1 AS INT), 
			NodeType =			CAST(N'Element' AS NVARCHAR(20)),  
			FullPath =			x.value('local-name(.)','NVARCHAR(MAX)'),  
			XPath =				x.value('local-name(.)','NVARCHAR(MAX)')  
				+ N'[' + CAST(ROW_NUMBER() OVER(ORDER BY (SELECT 1)) AS NVARCHAR) + N']',  
			Position =			ROW_NUMBER() OVER(ORDER BY (SELECT 1)), 
			Tree =				x.value('local-name(.)','NVARCHAR(MAX)'),  
			Value =				x.value('text()[1]','NVARCHAR(MAX)'), 
			this =				x.query('.'),         
			t =					x.query('*'),  
			Sort =				CAST(CAST(1 AS VARBINARY(4)) AS VARBINARY(MAX)),  
			ID =				CAST(1 AS INT)  
		FROM @x.nodes('/*') a(x)  
		UNION ALL 
		SELECT 
			lvl =				p.lvl + 1,  
			Name =				c.value('local-name(.)','NVARCHAR(MAX)'),  
			ParentName =		CAST(p.Name AS NVARCHAR(MAX)), 
			ParentPosition =	CAST(p.Position AS INT), 
			NodeType =			CAST(N'Element' AS NVARCHAR(20)),  
			FullPath =			CAST(p.FullPath + N'/' + c.value('local-name(.)','NVARCHAR(MAX)') AS NVARCHAR(MAX)),  
			XPath =				CAST(p.XPath + N'/'+ c.value('local-name(.)','NVARCHAR(MAX)') 
				+ N'['+ CAST(ROW_NUMBER() OVER(PARTITION BY c.value('local-name(.)','NVARCHAR(MAX)') ORDER BY (SELECT 1)) AS NVARCHAR)+ N']' AS NVARCHAR(MAX)), 
			Position =			ROW_NUMBER() OVER(PARTITION BY c.value('local-name(.)','NVARCHAR(MAX)') ORDER BY (SELECT 1)), 
			Tree =				CAST( SPACE(2 * p.lvl - 1) + N'|' + REPLICATE(N'-', 1) + c.value('local-name(.)','NVARCHAR(MAX)') AS NVARCHAR(MAX)), 
			Value =				CAST( c.value('text()[1]','NVARCHAR(MAX)') AS NVARCHAR(MAX) ), 
			this =				c.query('.'),  
			t =					c.query('*'),  
			Sort =				CAST(p.Sort + CAST( (lvl + 1) * 1024 + (ROW_NUMBER() OVER(ORDER BY (SELECT 1)) * 2) AS VARBINARY(4)) AS VARBINARY(MAX) ),  
			CAST((lvl + 1) * 1024 + (ROW_NUMBER() OVER(ORDER BY (SELECT 1)) * 2) AS INT)  
		FROM cte p  
		CROSS APPLY p.t.nodes('*') b(c)
	)
	,cte2 AS 
	(
		SELECT 
			lvl AS Depth,  
			Name AS NodeName,  
			ParentName, 
			ParentPosition, 
			NodeType,  
			FullPath,  
			XPath,  
			Position, 
			Tree AS TreeView,  
			Value,  
			this AS XMLData,  
			Sort, ID  
		FROM cte  
		UNION ALL 
		SELECT 
			p.lvl,  
			x.value('local-name(.)','NVARCHAR(MAX)'),  
			p.Name, 
			p.Position, 
			CAST(N'Attribute' AS NVARCHAR(20)),  
			p.FullPath + N'/@' + x.value('local-name(.)','NVARCHAR(MAX)'),  
			p.XPath + N'/@' + x.value('local-name(.)','NVARCHAR(MAX)'),  
			1, 
			SPACE(2 * p.lvl - 1) + N'|' + REPLICATE('-', 1)  
			+ N'@' + x.value('local-name(.)','NVARCHAR(MAX)'),  
			x.value('.','NVARCHAR(MAX)'),  
			NULL,  
			p.Sort,  
			p.ID + 1  
		FROM cte p  
		CROSS APPLY this.nodes('/*/@*') a(x)  
	)  
	SELECT 
		ID = ROW_NUMBER() OVER(ORDER BY Sort, ID),  
		ParentName, 
		ParentPosition, 
		Depth, 
		NodeName, 
		Position,   
		NodeType, 
		FullPath, 
		XPath, 
		TreeView, 
		Value, 
		XMLData 
	FROM cte2
);
