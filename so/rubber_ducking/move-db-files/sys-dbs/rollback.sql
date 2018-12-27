alter database master modify file (
     name = master
    ,filename = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\master.mdf'
);
go
alter database master modify file (
     name = mastlog
    ,filename = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\mastlog.ldf'
);
go
alter database tempdb modify file (
     name = tempdev
    ,filename = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdb.mdf'
);
go
alter database tempdb modify file (
     name = templog
    ,filename = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\templog.ldf'
);
go
alter database tempdb modify file (
     name = temp2
    ,filename = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdb_mssql_2.ndf'
);
go
alter database tempdb modify file (
     name = temp3
    ,filename = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdb_mssql_3.ndf'
);
go
alter database tempdb modify file (
     name = temp4
    ,filename = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdb_mssql_4.ndf'
);
go
alter database tempdb modify file (
     name = temp5
    ,filename = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdb_mssql_5.ndf'
);
go
alter database tempdb modify file (
     name = temp6
    ,filename = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdb_mssql_6.ndf'
);
go
alter database tempdb modify file (
     name = temp7
    ,filename = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdb_mssql_7.ndf'
);
go
alter database tempdb modify file (
     name = temp8
    ,filename = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdb_mssql_8.ndf'
);
go
alter database model modify file (
     name = modeldev
    ,filename = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\model.mdf'
);
go
alter database model modify file (
     name = modellog
    ,filename = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\modellog.ldf'
);
go
alter database msdb modify file (
     name = MSDBData
    ,filename = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\MSDBData.mdf'
);
go
alter database msdb modify file (
     name = MSDBLog
    ,filename = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\MSDBLog.ldf'
);
go