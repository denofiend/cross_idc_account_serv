--
-- get nextIdSegment
function get_next_id_segment(region, segment)

    local options = {}
    options['host'] = "10.100.15.7"
    options['port'] = 3306
    options['database'] = "mx_ids"
    options['user'] = "mx_ids"
    options['password'] = "mx_ids"
    options['max_packet_size'] = 1024 * 1024 
    local res_obj = initDb(options)


	local res,err,errno,sqlstate=db:query("SET @@auto_increment_increment="..segment)

	if not res then
        ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
        return
    end

    --insert
    local res, err, errno, sqlstate =
    db:query(
    "insert into ids(`end_id`, `region`)values(2*@@auto_increment_increment+LAST_INSERT_ID()-1, '"..region .."');"
    --.."update ids set `end_id` = `beg_id` + @@auto_increment_increment-2 where `beg_id` = LAST_INSERT_ID();"
    --.."select `beg_id`,`end_id`,`region` from ids where `begin_id`=LASTINSERT_ID();"
    )

    if not res then
        ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
        return
    end

    local beg_id = res.insert_id
    --ngx.say("begid:",beg_id)

    -- update
    res, err, errno, sqlstate =
    db:query("update ids set `end_id` = `beg_id` + @@auto_increment_increment-2 where `beg_id` = "..beg_id)

    if not res then
        ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
    end

    res, err, errno, sqlstate =
    db:query("select `beg_id`, `end_id`, `region` from ids where `beg_id` ="..beg_id)
    if not res then
        ngx.say("bad result: ", err, ": ", errno, ": ", sqlstate, ".")
        return
    end

    local cjson = require "cjson"
    ngx.say(cjson.encode(res))

	local ok, err = db:set_keepalive(0, 100)
	if not ok then
		ngx.say("failed to set keepalive: ", err)
		return
	end

	-- or just close the connection right away:
    -- local ok, err = db:close()
	--                         -- if not ok then
	--                                     --     ngx.say("failed to close: ", err)
	--                                                 --     return
	--                                                             -- end
	--                                                                     ';
end


segment=10
get_next_id_segment('IDC5', segment)

