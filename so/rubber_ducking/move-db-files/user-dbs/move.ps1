net stop mssqlserver

Move-Item -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\MyDatabase.mdf"     -Destination "D:\MSSQL\Data\MyDatabase.mdf"
Move-Item -Path "C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\MyDatabase_log.ldf" -Destination "D:\MSSQL\Logs\MyDatabase_log.ldf"

net start mssqlserver
