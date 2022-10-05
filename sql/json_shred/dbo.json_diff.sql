
create or alter function dbo.json_diff (
    @left nvarchar(max),
    @right nvarchar(max)
)
returns table
as
return (
/*
Author:      Peter Vandivier
Date:        2021-10-04
Description: Converts two arbitrary JSON documents into key-value indexes
             then compares the two for differences and returns them (if 
             any are found). A difference is found in the event of
              * a value change
              * a type change (1 <> '1')
              * a key appears or disappears
             This last bullet is crucial because it allows us to detect a
             change when the absence of key(x) is replaced by the presence
             of key(x) with a null value. For reference, see the "$.h" key
             in the example below. 
Example:
    declare @json1 nvarchar(max) = N'{"a":"foo","b":[1,null,{"d":"bar","e":[0]}],"f":{"g":"baz"},"i":true}';
    -- 
    declare @json2 nvarchar(max) = N'{"a":"bar","b":[1,2,{"e":[0]}],"f":{"g":null},"h":null,"i":"true"}';
    -- 
    select * 
    from dbo.json_diff(@json1,@json2);
Example_Output:
    +----+-------+----------+----------+-----------+------------+---------------+---------------+------------------+
    | ID | Level | LeftKey  | RightKey | LeftValue | RightValue | LeftType      | RightType     | ChangeType       |
    +----+-------+----------+----------+-----------+------------+---------------+---------------+------------------+
    | 1  | 1     | $.a      | $.a      | foo       | bar        | String        | String        | SimpleUpdate     |
    | 2  | 1     | NULL     | $.h      | NULL      | NULL       | NULL          | NullUndefined | CreateScalar     |
    | 3  | 1     | $.i      | $.i      | true      | true       | Boolean       | String        | SameValueNewType |
    | 4  | 2     | $.b[1]   | $.b[1]   | NULL      | 2          | NullUndefined | Numeric       | UnsetNull        |
    | 5  | 2     | $.f.g    | $.f.g    | baz       | NULL       | String        | NullUndefined | SetNull          |
    | 6  | 3     | $.b[2].d | NULL     | bar       | NULL       | String        | NULL          | DeleteScalar     |
    +----+-------+----------+----------+-----------+------------+---------------+---------------+------------------+
TODO:
    Could the predicate be simplified with a row hash?
*/
    with _left as ( 
        select * 
        from dbo.json_shred(@left) l 
        where l.[Type] not in (4,5)
    ), _right as (
        select * 
        from dbo.json_shred(@right) r 
        where r.[Type] not in (4,5)
    )
    select 
        row_number() over (order by 
            coalesce(l.[Level] ,r.[Level]),
            coalesce(l.[Key],r.[Key])
        ) as ID,
        coalesce(l.[Level] ,r.[Level]) as [Level],
        l.[Key] as LeftKey,
        r.[Key] as RightKey,
        l.[Value] as LeftValue,
        r.[Value] as RightValue,
        l.TypeName as LeftType,
        r.TypeName as RightType,
        case
            when r.[Key] is null 
                then 'DeleteScalar'
            when l.[Key] is null 
                then 'CreateScalar'
            when r.[Value] <> l.[Value]
                then 'SimpleUpdate'
            when (r.[Value] is null and l.[Value] is not null)
                then 'SetNull'
            when (r.[Value] is not null and l.[Value] is null)
                then 'UnsetNull'
            when r.[Type] <> l.[Type]
                then 'SameValueNewType'
        end as ChangeType
    from _left as l
    full outer join _right as r on r.[Key] = l.[Key]
    where r.[Value] <> l.[Value]
       or (r.[Value] is null and l.[Value] is not null)
       or (r.[Value] is not null and l.[Value] is null)
       or r.[Key] is null 
       or l.[Key] is null 
       or r.[Type] <> l.[Type]
);
