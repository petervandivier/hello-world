
**I WOULD LIKE** _to delete logs_

I am never allowed to delete anything because _compliance_.

I must estimate space requirements for backup history logs prior to being granted space to WORM logging. 

How to estimate growth-over-time of backup schema in MSDB?

The backup schema tables are well-constrained and must be deleted in ascending precedence in order foreign keys. How though do we enumerate which rows will be deleted in any given pass of `sp_delete_backuphistory` and thereby benchmark backup history log space used as a function of time?

MSDB does not by default support SSMS-generated DB diagrams. Even when you restore MSDB as a user database, the requisite tables are marked as system tables and are not by default discoverable.  

Fortunately, we can extract `object_definition(object_id('sp_delete_backuphistory'))`. The ordering observed in the SProc definition matches what we see in the following diagram found on [this blog post][1] (numbering added to denote deletion order)

![backup-erd.png](/backup-erd.png)

Sadly, the following query evidences what is implied by the SProc - that per-table, there is very little to filter by in the way of timestamps...

```sql
select TABLE_NAME, COLUMN_NAME, DATA_TYPE 
from INFORMATION_SCHEMA.COLUMNS
where ( TABLE_NAME like 'backup%' or TABLE_NAME like 'restore%' )
    and DATA_TYPE like '%date%';
```

```ascii
+----------------+------------------------+-----------+
| TABLE_NAME     | COLUMN_NAME            | DATA_TYPE |
+----------------+------------------------+-----------+
| backupset      | expiration_date        | datetime  |
| backupset      | database_creation_date | datetime  |
| backupset      | backup_start_date      | datetime  |
| backupset      | backup_finish_date     | datetime  |
| restorehistory | restore_date           | datetime  |
| restorehistory | stop_at                | datetime  |
+----------------+------------------------+-----------+
```

...therefore we choose to modify `sp_delete_backuphistory` to summarize our existing backup information. 

[1]: https://sqlwhisper.wordpress.com/2015/01/09/deleting-old-backup-information-from-msdb/
