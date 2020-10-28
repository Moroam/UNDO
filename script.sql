# with a separate procedure for getting json
CREATE PROCEDURE `row_to_json`(tabschema varchar(255), tabname varchar(255), id int, out js JSON )
BEGIN
declare id_auto varchar(255) default '';

select COLUMN_NAME into id_auto
from information_schema.`COLUMNS` 
where TABLE_NAME = tabname and TABLE_SCHEMA = tabschema and EXTRA = 'auto_increment';

SET @sql = NULL;
SET SESSION group_concat_max_len = 1000000;

select group_concat(concat('"', COLUMN_NAME , '", T.', COLUMN_NAME ) ORDER BY ORDINAL_POSITION ASC) into @sql
from information_schema.`COLUMNS` 
where TABLE_NAME = tabname and TABLE_SCHEMA = tabschema and EXTRA NOT LIKE '%VIRTUAL%';

set @sql := concat('SELECT JSON_OBJECT(', @sql, ') into @js FROM `', tabschema, '`.` T where ', id_auto, '=', id, ';');
# range
#set @sql := concat('SELECT JSON_OBJECT(', @sql, ') into @js FROM `', tabschema, '`.`', tabname, '` T where ', id_auto, ' beetween ', id, ' and ', id+10,';');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

set js=@js;
END

CREATE PROCEDURE `backup_row`(tabschema varchar(255), tabname varchar(255), id int, out idbackup int)
BEGIN
declare cnt int;
declare js JSON;
    
call test.row_to_json(tabschema, tabname, id, js);

SELECT LAST_INSERT_ID(0) into cnt;

insert into test.backup_json(`TABLE_NAME`, ROW_JSON)
values(tabname, js);

select LAST_INSERT_ID() into cnt;

set idbackup = cnt;
END

# copying row / rows to json
CREATE PROCEDURE `row_to_json`(tabschema varchar(255), tabname varchar(255), id int, out js JSON )
BEGIN
declare id_auto varchar(255) default '';

select COLUMN_NAME into id_auto
from information_schema.`COLUMNS` 
where TABLE_NAME = tabname and TABLE_SCHEMA = tabschema and EXTRA = 'auto_increment';

SET @sql = NULL;
SET SESSION group_concat_max_len = 1000000;

select group_concat(concat('"', COLUMN_NAME , '", T.', COLUMN_NAME ) ORDER BY ORDINAL_POSITION ASC) into @sql
from information_schema.`COLUMNS` 
where TABLE_NAME = tabname and TABLE_SCHEMA = tabschema and EXTRA NOT LIKE '%VIRTUAL%';

set @sql := concat('SELECT JSON_OBJECT(', @sql, ') into @js FROM `', tabschema, '`.` T where ', id_auto, '=', id, ';');
# range
#set @sql := concat('SELECT JSON_OBJECT(', @sql, ') into @js FROM `', tabschema, '`.`', tabname, '` T where ', id_auto, ' beetween ', id, ' and ', id+10,';');

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

set js=@js;
END

# restore one row - ONLY IF JSON IS OBJECT
CREATE PROCEDURE `restore_one_row`(tabschema varchar(255), id int)
BEGIN
# ONLY FOR JSON OBJECT
set @sql:=null;
select concat('REPLACE INTO `', tabschema, '`.`', `table_name`, '`(', 
	replace(replace(replace(json_keys(row_json),'[',''),']',''),'"','`'),
    ')VALUES(',
    replace(replace(json_extract(row_json,'$.*'),'[',''),']',''),
    ');') 
into @sql
from test.backup_json
where idbackup_json=id;

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

END

# resore rows from json
CREATE PROCEDURE `restore_row`(tabschema  varchar(255), tabname varchar(255), id int)
BEGIN
	
set @sql:=null;
select group_concat( COLUMN_NAME  order by ORDINAL_POSITION) into @sql
from information_schema.`COLUMNS` 
where TABLE_NAME = tabname and TABLE_SCHEMA = tabschema and EXTRA NOT LIKE '%VIRTUAL%';
set @sql := concat('REPLACE INTO `', tabschema,'`.`', tabname,'`(', @sql,') SELECT * FROM JSON_TABLE(');

set @js:=null;
select ROW_JSON into @js
from backup_json 
where idbackup_json = id;

set @cols := null;
select group_concat( concat( COLUMN_NAME, " ", COLUMN_TYPE, " PATH '$.", COLUMN_NAME, "'") order by ORDINAL_POSITION) into @cols
from information_schema.`COLUMNS` 
where TABLE_NAME = tabname and TABLE_SCHEMA = tabschema and EXTRA NOT LIKE '%VIRTUAL%';

set @cols:= concat("'$[*]' COLUMNS(", @cols, ')');

if JSON_TYPE(@js) = 'OBJECT' then
	set @sql := concat(@sql, "'[", @js,"]', " , @cols, ') as B;');
else #ARRAY
	set @sql := concat(@sql, "'", @js,"', " , @cols, ') as B;');
end if;

PREPARE stmt FROM @sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

END
