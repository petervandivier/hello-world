use [master]
go
-- the following script evidences that 
-- we cannot use a restored copy of MSDB
-- to enumerate and auto-diagram tables
-- in the backup media schema

backup database msdb 
    to disk = 'c:\temp\msdb.bak'
    with copy_only

restore filelistonly 
    from disk = 'c:\temp\msdb.bak'

restore database msdb_diagram  
    from disk = 'c:\temp\msdb.bak'
    with move 'MSDBData' to 'c:\temp\msdb_diagram.mdf'
        ,move 'MSDBLog'  to 'c:\temp\msdb_diagram_log.ldf'

drop database msdb_diagram
go
