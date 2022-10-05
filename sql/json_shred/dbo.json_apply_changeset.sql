
-- drop proc if exists json_apply_changeset

create or alter proc dbo.json_apply_changeset (
    @Json          nvarchar(max),
    @JsonPathValue JsonPathValue readonly,
    @JsonOut       nvarchar(max) output
)
as
begin;
    set nocount on;
    set xact_abort on;

    declare 
        @Path     nvarchar(750),
        @Value    nvarchar(max);

    set @JsonOut = @Json;

    declare json_command_apply cursor 
        local
        forward_only
        read_only
    for
        select 
            [Path],
            ValueAsText
        from @JsonPathValue
        order by Ordinal asc;
    
    open json_command_apply 
    
    fetch next from json_command_apply into @Path, @Value;
    
    while @@fetch_status = 0
    begin;
        set @JsonOut = json_modify(@JsonOut, @Path, @Value)
        fetch next from json_command_apply into @Path, @Value;
    end;
    
    close json_command_apply;
    deallocate json_command_apply

    return @JsonOut;
end;
go

