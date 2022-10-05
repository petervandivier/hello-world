- https://dbfiddle.uk/?rdbms=sqlserver_2017&fiddle=c797e4fb3575db31e75eb60b56a3f999&hide=2
TODO: 
- add "getParent" path 
- add "just the key" attribute
- rename "key" to "fullPath"

# Shredding JSON in SQL Server

For a while now^[1](https://chat.stackexchange.com/transcript/179?m=55146340#55146340),[2](https://dba.stackexchange.com/questions/239180/find-ancestry-from-json#comment471849_239206)^, I've been a fan of shredding arbitrary JSON to key-value mapping. I've had some success doing this in PowerShell^[3](https://topanswers.xyz/powershell?q=930)^ and using jq^[4](https://topanswers.xyz/nix?q=915)^. These exercises were helpful in identifying aggregate changes to ElasticSearch logs and MongoDB documents on a few occasions.

Sadly, I've never been able to grok the syntax in T-SQL. I blame this on [SQL Server's very limited support for JSON functions](https://docs.microsoft.com/en-us/sql/t-sql/functions/json-functions-transact-sql) - as opposed to [JSON support in PostgreSQL](https://www.postgresql.org/docs/current/functions-json.html) for example. Recently though I had a bit of a breakthrough. Something clicked into place and I'd like to document below the successful approach with some notes on what it does and why. To start with the best bit, the code:

## `dbo.json_shred`
!TODO: final function version goes here

## Explanation

An invocation of the single-argument-no-schema overload of [`OPENJSON()`](https://docs.microsoft.com/en-us/sql/t-sql/functions/openjson-transact-sql) will unpack all elements at the first level. If you then recurse your level-1 resultset into another application of single-argument `OPENJSON()`, you'll get all elements from the 2nd level; and so on. 

### level_0

But why the clunky `level_0` CTE? Well, dear reader, because `APPLY` is still a `JOIN`. The first iteration of `OPENJSON` over your document has a left-to-right relationship to the document; **NOT** an up-to-down relationship. Consider the following:

```sql
select *
from (values 
    (1, '{"a":1,"b":{"c":2}}'),
    (2, '{"d":3}')
) as v (id,doc)
cross apply openjson(v.doc) as js;
```

The resultset might be visualized like...

```none
+----+---------------------+-----+---------+------+
| id | doc                 | key | value   | type |
+----+---------------------+-----+---------+------+
| 1  | {"a":1,"b":{"c":2}} | a   | 1       | 2    |
|    |                     | b   | {"c":2} | 5    |
+----+---------------------+-----+---------+------+
| 2  | {"d":3}             | d   | 3       | 2    |
+----+---------------------+-----+---------+------+
```

Note that key-value pairs associate directly to the containing document. A JSON document can itself contain arbitrary JSON documents as constituent data (consider the data in `[Key]` "b" for document id 1). Therefore for a JSON shredder, I consider the document _itself_ as a data value. If this were [`jq`](https://stedolan.github.io/jq/), the query string I would execute to get the _whole document_ would be `.` (single dot) - meaning, simply: "retrieve everything". 

What I _want_ is all level-1 key-value rows _appended_ to the the level-0 document row - at a deeper `[Level]`. Something like this:

```none
+----+-----+---------------------+-------+
| id | key | value               | Level |
+----+-----+---------------------+-------+
| 1  | .   | {"a":1,"b":{"c":2}} | 0     |
|    | .a  | 1                   | 1     |
|    | .b  | {"c":2}             | 1     |
+----+-----+---------------------+-------+
| 2  | .   | {"d":3}             | 0     |
|    | .d  | 3                   | 1     |
+----+-----+---------------------+-------+
```

In order to achieve this, I've separately defined the level-0 tuple and I prepend it to the final resultset.

### 

# Fin

----

n.b. One of my favorite StackOverflow answers ever is [this T-SQL XML shredder](https://stackoverflow.com/a/10885014/how-can-i-get-a-list-of-element-names-from-an-xml-value-in-sql-server).  
