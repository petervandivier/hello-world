USE Hambone
GO

IF EXISTS ( SELECT * FROM sys.objects WHERE [object_id] = object_id( N'dbo.TestTable' ) AND [type] = N'U' )
	DROP TABLE dbo.TestTable;

CREATE TABLE dbo.TestTable
		(
	[Product_PK] INT PRIMARY KEY NOT NULL
	, [ProductName] VARCHAR(25) NOT NULL
	, [Price] MONEY NULL
	, [Description] TEXT NULL
		)
GO

INSERT [dbo].[TestTable]
	([Product_PK], [ProductName], [Price], [Description])
		VALUES (1, 'Gatorade', 1.55, 'a refreshing beverage')
GO

