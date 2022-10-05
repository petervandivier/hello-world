
create or alter function dbo.json_changeset (
    @left nvarchar(max),
    @right nvarchar(max)
)
returns table
as
return (
/*
Author:      Peter Vandivier
Date:        2021-10-04
*/
    with diff as (
        select 
            jd.ID,
            jd.[Level],
            jd.LeftKey,
            jd.RightKey,
            jd.LeftValue,
            jd.RightValue,
            jd.LeftType,
            jd.RightType,
            jd.ChangeType
        from dbo.json_diff(@left,@right) as jd
    )
    select
        d.RightKey,
        case d.ChangeType
            when 'SimpleUpdate'
                then d.RightKey
            when 'UnsetNull'
                then d.RightKey
            when 'SetNull'
                then 'strict ' + d.RightKey
        end as [Path],
        case d.RightType
            when 'String'
                then quotename(d.RightValue,'"')
            when 'Numeric'
                then d.RightValue
            when 'NullUndefined'
                then null
        end as [Value]
    from diff as d
);
go
