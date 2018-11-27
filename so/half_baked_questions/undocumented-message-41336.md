# Undocumented error_message 41336

[XEvents introduced in SQL 2008](https://www.brentozar.com/extended-events/)

Default install includes `system_health` & `telemetry_xevents` XE's - although the definitions vary slightly between versions. 

These 2 XEs in various iterations profile in part for...

````sql
...
	event sqlserver.error_reported
	where error_number = (41336)
...
```` 

The following query reveals that unlike the other profiled error messages, 41336 does not have a corresponding entry in `sys.messages`

````sql
select *
from sys.messages m
right join ( 
    select v.i
    from ( values 
    (17803),(701),(802),(8645),(8651)
    ,(8657),(8902),(41354),(41355),(41367)
    ,(41384),(41336),(41309),(41312),(41313)
) v ( i )) rj on rj.i = m.message_id
where m.language_id = 1033
    or m.language_id is null;
````

TODO: fill out this grid showing inclusion matrix

| version | `system_health` | `telemetry_xevents` |
|---|---|---|
| 2017 | **Yes** | **Yes** |
| 2016 | **Yes** | **Yes** |
| 2014 | _No_ | **Yes** |
| 2012 | _ | _ |
| 2018 | _ | _ |
