function init()
    local res_obj = {}

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
        database = "user_api_local",
        user = "user_api_local",
        password = "user_api_local",
        max_packet_size = 1024 * 1024 
    }

    if not ok then
        res_obj['code'] = -1
        res_obj['message'] = err
        --ngx.say("failed to connect: ", err, ": ", errno, " ", sqlstate)
    else
        res_obj['code'] = 1
        res_obj['message'] = 'ok'
    end

    return res_obj
    --ngx.say("connected to mysql.")
end


--get_next_id

function get_next_id()
    local uri = '/next_id'
    local res = ngx.location.capture(uri)

    local cjson = require "cjson"
    val = cjson.decode(res.body)

    return val.user_id
end


function executeSql(sql)
    local res_obj = {}
    ngx.log(ngx.DEBUG, sql)
    local res, err, errno, sqlstate = db:query(sql)

    if not res then
        res_obj['code'] = 300
        res_obj['message'] = err
        ngx.log(ngx.ERR, err, ',', errno, ',', sqlstate)
    else
        res_obj['code'] = 1
        res_obj['message'] = 'ok'
    end

end

-- register
function register(region)
    local res_obj = {}
    
    --init db conf
    res_obj = init()

    if res_obj['code'] ~= 1 then
        local cjson = require "cjson"
        ngx.say(cjson.encode(res_obj))
        return
    end

    --get request body data
    local data = ngx.req.get_body_data()
    local reg_obj
    if data ~= nil then 
        local cjson = require "cjson"
        reg_obj = cjson.decode(data)
        ngx.log(ngx.DEBUG, 'request_body(', data, ')');
    else
        res_obj['code'] = 200
        res_obj['message'] = 'miss the reuqest body'
        ngx.log(ngx.ERR, 'miss the request body')
    end

    --get next user_id
    local user_id = get_next_id()
    ngx.log(ngx.DEBUG, "user_id(", user_id, ')')


    --insert into `base_usr_info` table
    local sql = "insert into `base_user_info`(`user_id`, `email`, `account`, `password`, `nickname`)values("..user_id..",'"..reg_obj.account.."','"..reg_obj.account.."','"..reg_obj.password.."','"..reg_obj.nickname.."')"
    executeSql(sql)

    --insert into `transaction_table` table
    sql = "insert into `transaction_table`(`user_id`, `type`)values("..user_id..",'insert')"
    executeSql(sql)

    -- return res
    res_obj['user_id'] = user_id
    local cjson = require "cjson"
    ngx.say(cjson.encode(res_obj))
end


register('IDC5')


