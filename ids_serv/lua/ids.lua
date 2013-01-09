--
-- get nextIdSegment
function get_next_id_segment(region)

    local options = {}
    options['host'] = "10.100.15.7"
    options['port'] = 3306
    options['database'] = "mx_ids"
    options['user'] = "mx_ids"
    options['password'] = "mx_ids"
    options['max_packet_size'] = 1024 * 1024 
    local res_obj = initDb(options)

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
end


get_next_id_segment('IDC5')

