--[beg_id, end_id]
--[bak_beg_id, bak_end_id]
--
--enough
enough = 2
isGet = false


-- get_next_segment_id

function get_next_segment_id()
    local uri = '/ids/segment/get'
    local res = ngx.location.capture(uri)

    local cjson = require "cjson"
    val = cjson.decode(res.body)

    return val[1].beg_id, val[1].end_id
end

    
-- is_enough()
--
function is_enough(beg_id, end_id)
    isGet = not isGet and (tostring(beg_id + enough) < end_id)
    return isGet
end


function get_ranges_from_redis()
    local reqs = {}
    table.insert(reqs, { "/redis/id/get?key=beg_id" })
    table.insert(reqs, { "/redis/id/get?key=end_id" })
    table.insert(reqs, { "/redis/id/get?key=bak_beg_id" })
    table.insert(reqs, { "/redis/id/get?key=bak_end_id" })


    local resps = { ngx.location.capture_multi(reqs) }


    local rangs = {}
    --loop over the responses table
    for i, resp in ipairs(resps) do

        if resp.status ~= ngx.HTTP_OK then
            ngx.say("reids response error")
            return -1, -1, -1, -1
        end

        local f = string.find(resp.body, "\r\n%d+\r\n")
        rangs[i] = -1
        
        if f ~=  nil then
            rangs[i] = string.sub(resp.body, string.find(resp.body, "\r\n%d+\r\n"))
            rangs[i] = string.sub(rangs[i], string.find(rangs[i], "%d+"))
        end

    end

    return unpack(rangs)
end

--set_rangs_from_redis
function set_ranges_to_redis(beg_id, end_id, bak_beg_id, bak_end_id)
    local reqs = {}
    table.insert(reqs, { "/redis/id/set?key=beg_id&val="..beg_id })
    table.insert(reqs, { "/redis/id/set?key=end_id&val="..end_id })
    table.insert(reqs, { "/redis/id/set?key=bak_beg_id&val="..bak_beg_id })
    table.insert(reqs, { "/redis/id/set?key=bak_end_id&val="..bak_end_id })


    local resps = { ngx.location.capture_multi(reqs) }


    local f = true;
    --loop over the responses table
    for i, resp in ipairs(resps) do

        if resp.status ~= ngx.HTTP_OK then
            ngx.say("reids response error")
            return -1, -1, -1, -1
        end

        local f = string.find(resp.body, "+OK")

        if f ==  nil then
            f = false;
            break;
        end

    end

    return f;
end


-- get nextId
--[beg_id, end_id] 
--[bak_beg_id, bak_end_id]
function get_next_id()
    --get from redis
    local beg_id, end_id, bak_beg_id, bak_end_id = get_ranges_from_redis()

    -- [bak_beg_id, bak_end_id] -> [beg_id, end_id]
    if -1 == beg_id and -1 == end_id then
        beg_id, end_id = get_next_segment_id()
    elseif not is_enough(beg_id, end_id) then
        bak_sta_id, bak_end_id = get_next_segment_id()
    end 


    local id = {}
    id["user_id"] = beg_id
    beg_id = beg_id + 1

    -- [bak_beg_id, bak_end_id] -> [beg_id, end_id]
    if beg_id == end_id then
        if nil == bak_sta_id and nil == bak_end_id then
            bak_sta_id, bak_end_id = get_next_segment_id()
        end
        sta_id = bak_sta_id
        end_id = bak_end_id
        bak_sta_id = -1
        bak_end_id = -1
        isGet = false
    end

    set_ranges_to_redis(beg_id, end_id, bak_beg_id, bak_end_id)
    return id 
end


local id = get_next_id()
local cjson = require "cjson"
ngx.say(cjson.encode(id))
