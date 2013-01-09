--
-- get nextIdSegment
function transaction()

    local options = {}
    options['host'] = "10.100.15.6"
    options['port'] = 3306
    options['database'] = "mx_id"
    options['user'] = "mx_id"
    options['password'] = "mx_id"
    options['max_packet_size'] = 1024 * 1024 
    local res_obj = initDb(options)


    local byte,err = db:send_query('BEGIN')

    ngx.say(byte, err)

    local byte, err = db:send_query('insert into test values(2)')

    ngx.say(byte, err)
    --[[
    local res, err, errno, sqlstate = db:query('BEGIN')

    local res, err, errno, sqlstate = db:query('insert into test values(1)')

    local res, err, errno, sqlstate = db:query('insert into test values(1)')

    local res, err, errno, sqlstate = db:query('commit')

    if not res then
        ngx.say("bad result: ", err) 
        return
    end

    local cjson = require "cjson"
    ngx.say(cjson.encode(res))
    --]]
end


transaction()

