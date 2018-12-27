net stop mssqlserver

Move-Item -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\master.mdf" -Destination "D:\MSSQL\Data\master.mdf"
Move-Item -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\mastlog.ldf" -Destination "D:\MSSQL\Logs\mastlog.ldf"
Move-Item -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdb.mdf" -Destination "D:\MSSQL\Data\tempdb.mdf"
Move-Item -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\templog.ldf" -Destination "D:\MSSQL\Logs\templog.ldf"
Move-Item -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdb_mssql_2.ndf" -Destination "D:\MSSQL\Data\tempdb_mssql_2.ndf"
Move-Item -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdb_mssql_3.ndf" -Destination "D:\MSSQL\Data\tempdb_mssql_3.ndf"
Move-Item -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdb_mssql_4.ndf" -Destination "D:\MSSQL\Data\tempdb_mssql_4.ndf"
Move-Item -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdb_mssql_5.ndf" -Destination "D:\MSSQL\Data\tempdb_mssql_5.ndf"
Move-Item -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdb_mssql_6.ndf" -Destination "D:\MSSQL\Data\tempdb_mssql_6.ndf"
Move-Item -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdb_mssql_7.ndf" -Destination "D:\MSSQL\Data\tempdb_mssql_7.ndf"
Move-Item -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\tempdb_mssql_8.ndf" -Destination "D:\MSSQL\Data\tempdb_mssql_8.ndf"
Move-Item -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\model.mdf" -Destination "D:\MSSQL\Data\model.mdf"
Move-Item -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\modellog.ldf" -Destination "D:\MSSQL\Logs\modellog.ldf"
Move-Item -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\MSDBData.mdf" -Destination "D:\MSSQL\Data\MSDBData.mdf"
Move-Item -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\MSDBLog.ldf" -Destination "D:\MSSQL\Logs\MSDBLog.ldf"

net start mssqlserver