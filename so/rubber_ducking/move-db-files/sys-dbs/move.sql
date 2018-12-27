alter database master modify file (
     name = master
    ,filename = 'D:\MSSQL\Data\master.mdf'
);
go
alter database master modify file (
     name = mastlog
    ,filename = 'D:\MSSQL\Logs\mastlog.ldf'
);
go
alter database tempdb modify file (
     name = tempdev
    ,filename = 'D:\MSSQL\Data\tempdb.mdf'
);
go
alter database tempdb modify file (
     name = templog
    ,filename = 'D:\MSSQL\Logs\templog.ldf'
);
go
alter database tempdb modify file (
     name = temp2
    ,filename = 'D:\MSSQL\Data\tempdb_mssql_2.ndf'
);
go
alter database tempdb modify file (
     name = temp3
    ,filename = 'D:\MSSQL\Data\tempdb_mssql_3.ndf'
);
go
alter database tempdb modify file (
     name = temp4
    ,filename = 'D:\MSSQL\Data\tempdb_mssql_4.ndf'
);
go
alter database tempdb modify file (
     name = temp5
    ,filename = 'D:\MSSQL\Data\tempdb_mssql_5.ndf'
);
go
alter database tempdb modify file (
     name = temp6
    ,filename = 'D:\MSSQL\Data\tempdb_mssql_6.ndf'
);
go
alter database tempdb modify file (
     name = temp7
    ,filename = 'D:\MSSQL\Data\tempdb_mssql_7.ndf'
);
go
alter database tempdb modify file (
     name = temp8
    ,filename = 'D:\MSSQL\Data\tempdb_mssql_8.ndf'
);
go
alter database model modify file (
     name = modeldev
    ,filename = 'D:\MSSQL\Data\model.mdf'
);
go
alter database model modify file (
     name = modellog
    ,filename = 'D:\MSSQL\Logs\modellog.ldf'
);
go
alter database msdb modify file (
     name = MSDBData
    ,filename = 'D:\MSSQL\Data\MSDBData.mdf'
);
go
alter database msdb modify file (
     name = MSDBLog
    ,filename = 'D:\MSSQL\Logs\MSDBLog.ldf'
);
go