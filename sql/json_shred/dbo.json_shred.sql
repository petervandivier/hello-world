
create or alter function dbo.json_shred (
    @json nvarchar(max)
)
returns table 
as
return (
/*
Author:      Peter Vandivier
Date:        2021-10-04
Description: Takes an arbitrary JSON document and returns all valid
             json_paths within the document as well as the values
             present at said path and the depth within the document
             to which the given path with probe
Example:
    -- Filtering to `[Type] not in (4,5)` returns all leaf-node
    -- paths and values for the given document
    --
    declare @json nvarchar(max) = N'{"a":"foo","b":[1,2,{"d":"bar","e":[0]}],"f":{"g":"baz"},"h":null,"i":"zap"}';
    --
    select * 
    from dbo.json_shred(@json)
    where [Type] not in (4,5);
Example_Output:
    +-------+----------+-------------+-------+------+
    | Level | Parent   | Key         | Value | Type |
    +-------+----------+-------------+-------+------+
    | 1     | $.       | $.a         | foo   | 1    |
    | 1     | $.       | $.h         | NULL  | 0    |
    | 1     | $.       | $.i         | zap   | 1    |
    | 2     | $.f      | $.f.g       | baz   | 1    |
    | 2     | $.b      | $.b[0]      | 1     | 2    |
    | 2     | $.b      | $.b[1]      | 2     | 2    |
    | 3     | $.b[2]   | $.b[2].d    | bar   | 1    |
    | 4     | $.b[2].e | $.b[2].e[0] | 0     | 2    |
    +-------+----------+-------------+-------+------+
*/
    with level_0 as (
        select
            convert(int,0) as [Level],
            convert(nvarchar(4000),N'$') as [Key],
            @json as [Value],
            convert(
                int,
                case left(@json,1)
                    when N'[' then 4
                    when N'{' then 5
                    else 0
                end
            ) as [Type]
    )
    , key_value_unwrap as(
        select 
            l0.[Level] + 1 as [Level],
            convert(nvarchar(max),null) as Parent,
            l0.[Key] + iif(l0.[Type] = 5, '.' + oj.[Key], quotename(-1 + row_number() over (order by (select null)))) collate database_default as [Key],
            oj.[Value],
            oj.[Type]
        from level_0 l0
        outer apply openjson(l0.[Value]) as oj
        where l0.[Value] is not null 
        union all
        select 
            kvu.[Level] + 1 as [Level],
            convert(nvarchar(max),kvu.[Key]) as Parent,
            kvu.[Key] + iif(kvu.[Type] = 5, '.' + oj.[Key], quotename(-1 + row_number() over (order by (select null)))) as [Key],
            oj.[Value],
            oj.[Type]
        from key_value_unwrap as kvu
        outer apply openjson(kvu.[Value], 'lax $') as oj
        where kvu.[Type] in (4,5)
    ), _union as (
        select 
            l0.[Level],
            convert(nvarchar(max),null) as Parent,
            l0.[Key] + N'.' as [Key],
            l0.[Value],
            l0.[Type]
        from level_0 as l0
        union all
        select 
            kvu.[Level],
            kvu.Parent,
            kvu.[Key],
            kvu.[Value],
            kvu.[Type]
        from key_value_unwrap as kvu
    ), _type as (
        select 
            TypeId,
            TypeName
        from ( values
            -- https://docs.microsoft.com/en-us/sql/t-sql/functions/openjson-transact-sql#jsonexpression
            (0,'NullUndefined'),
            (1,'String'),
            (2,'Numeric'),
            (3,'Boolean'),
            (4,'Array'),
            (5,'Object')
        ) v ( TypeId, TypeName )
    ) 
    select 
        u.[Level],
        iif(u.[Level]=1,N'$.',u.Parent) as Parent,
        u.[Key],
        u.[Value],
        u.[Type],
        t.TypeName
    from _union as u
    join _type t on t.TypeId = u.[Type]
);
go
