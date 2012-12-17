function init()
    mysql = require "resty.mysql"
    db, err = mysql:new()
    if not db then
        ngx.say("failed to instantiate mysql: ", err)
        return
    end

    db:set_timeout(1000) -- 1 sec

    --[[ mul --]]

    local ok, err, errno, sqlstate = db:connect{
        host = "10.100.15.6",
        port = 3306,
        database = "mx_id",
        user = "mx_id",
        password = "mx_id",
        max_packet_size = 1024 * 1024 
    }

    if not ok then
        ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
        return
    end

    --ngx.say("connected to mysql.")
end


-- get nextIdSegment
function get_next_id_segment(region)
    init()

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
