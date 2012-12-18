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
        database = "user_api_center",
        user = "user_api_center",
        password = "user_api_center",
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

    return res_obj

end

function isUserIdDup(message) 
    ngx.log(ngx.DEBUG, message)
    local f =  string.find(message, 'PRIMARY') 
    ngx.log(ngx.DEBUG, f)
    return string.find(message, 'PRIMARY') ~= nil
end

function isAccountDup(message) 
    return string.find(message, 'account') ~= nil
end

function isEmailDup(message) 
    return string.find(message, 'email') ~= nil
end
function isNicknameDup(message) 
    return string.find(message, 'nickname') ~= nil
end

function doInsert(req_obj)
    --insert into `transaction_table` table
    sql = "insert into `message_table`(`user_id`, `type`)values("..req_obj.user_id..",'insert')"
    local res_obj = executeSql(sql)


    if res_obj.code ~= 1 then
        return res_obj
    end

    --insert into `base_usr_info` table
    while true do

        local sql = "insert into `base_user_info`(`user_id`, `email`, `account`, `password`, `nickname`)values("..req_obj.user_id..",'"..req_obj.account.."','"..req_obj.account.."','"..req_obj.password.."','"..req_obj.nickname.."')"
        local obj = executeSql(sql)

        if obj.code == 1 then
            break
        end

        ngx.log(ngx.NOTICE, obj.message)

        if isUserIdDup(obj.message) then
            ngx.log(ngx.NOTICE, obj.user_id)
            res_obj.code = 301
            res_obj.message = 'user_id is dup'
            break
        else
            res_obj.code = 302
            if isAccountDup(obj.message) then
                req_obj.account = 'mx_'..req_obj.account
                res_obj.message = res_obj.message..',account is rewrited'
            elseif isEmailDup(obj.message) then
                req_obj.account = 'mx_'..req_obj.email
                res_obj.message = res_obj.message..'email is rewrited'
            elseif isNicknameDup(obj.message) then
                req_obj.nickname = 'mx_'..req_obj.nickname
                res_obj.message = res_obj.message..'nickname is rewrited'
            else
                break end
        end

    end


    local cjson = require "cjson"
    ngx.log(ngx.DEBUG, cjson.encode(res_obj))
    return res_obj
end



function doUpdate(req_obj)
    --insert into `base_usr_info` table
    local sql = "update`base_user_info` set `user_id`="..req_obj.user_id ..", `email` = '"..req_obj.account.."', `account`='"..req_obj.acount.."', `password`='"..req_obj.password .."', `nickname` = '"..req_obj.nickname"')"
    local res_obj = executeSql(sql)

    --insert into `transaction_table` table
    sql = "insert into `message_table`(`user_id`, `type`)values("..user_id..",'update')"
    res_obj = executeSql(sql)

    return res_obj
end


-- sync
function sync(region)
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
    local req_obj
    if data ~= nil then 
        local cjson = require "cjson"
        req_obj = cjson.decode(data)
        ngx.log(ngx.DEBUG, 'request_body(', data, ')');
    else
        res_obj['code'] = 200
        res_obj['message'] = 'miss the reuqest body'
        ngx.log(ngx.ERR, 'miss the request body')
    end

    -- req_obj.type

    if req_obj.type == 'insert' then
        res_obj = doInsert(req_obj)
    elseif req_obj.type == 'update' then
        res_obj = doUpdate(req_obj)
    end

    -- return res
    res_obj['user_id'] = req_obj.user_id
    local cjson = require "cjson"
    ngx.say(cjson.encode(res_obj))
end


sync('IDC5
