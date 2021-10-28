CREATE FUNCTION "idb"."idb_ph2_customer_vpn" () RETURNS void AS
$$
	BEGIN
		truncate idb_ph2_customer_vpn;
		insert into idb_ph2_customer_vpn
    	select
            vse.created as created_when, ---дата создания контакта
            vsep.value as description, ---описание клиентской сети
            idb.source_generator('idb_id', l.lc_num::varchar, 'idb_ph2_customer_vpn') as idb_id,---это не точно
            vse.login as object_name, ---название клиентской сети
            ipc.idb_id as parent_id, ---не уверена
 	        idb.source_generator('source_id', l.lc_num::varchar, 'idb_ph2_customer_vpn') as source_id, ---это не точно
 		    idb.source_generator('source_system', l.lc_num::varchar, 'idb_ph2_customer_vpn') as source_system, ---это не точно
            idb.source_generator('source_system_type', l.lc_num::varchar, 'idb_ph2_customer_vpn') as source_system_type, ---это не точно
		    null as isvalid, -- для аудита
            'L2' as type ---уровень VPN - нюанс в том, что предоставляется только L2VPТ и вроде можно проставить везде L2, но L3VPN есть - костыльно, таких клиентов очень мало 
        from v083.lc l
        left join idb.idb_ph2_customer ipc on split_part(ipc.source_id, '_', 4)::integer = l.lc_num
        left join v083.se vse on vse.lc_num = l.lc_num
        left join v083.se_props vsep on vse.se_id = vsep.se_id and vsep.name = 'COMMENT'
        where true
          and vse.svc_id = '84'
          and l.company;
    END
$$
LANGUAGE 'plpgsql'