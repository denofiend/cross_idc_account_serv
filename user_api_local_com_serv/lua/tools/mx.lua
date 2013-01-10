require('ngx');
require('cjson');

math.randomseed(os.time());

mx = {};

function mx.split(str, sep, ignoreEmpty)
    local findStart = 1;
    local seplen = string.len(sep);
    local result = {};
    while true do
        local findLast = string.find(str, sep, findStart);
        if not findLast then
            local item = string.sub(str, findStart, string.len(str));
            if item or not ignoreEmpty then
                table.insert(result,item);
            end
            break;
        end
        local item = string.sub(str, findStart, findLast - 1);
        if item or not ignoreEmpty then
            table.insert(result,item);
        end
        findStart = findLast + seplen;
    end
    return result;
end

function mx.randstr(length)
    local length = length or 4;
    local pattern = '%a%d';

    local chars = {};
    for i=string.byte('0',1),string.byte('9',1) do
        table.insert(chars,i);
    end
    for i=string.byte('a',1),string.byte('z',1) do
        table.insert(chars,i);
    end
    for i=string.byte('A',1),string.byte('Z',1) do
        table.insert(chars,i);
    end

    local rands = {};
    local charslen = table.maxn(chars);
    for i=1,length do
        table.insert(rands,chars[math.random(1,charslen)]);
    end
    return string.char(unpack(rands));
end

function mx.exit(code,message)
    ngx.header["X-Maxthon-Code"] = code;
    if message then
        if type(message) == 'table' then
            ngx.say(cjson.encode(message));
        else
            ngx.say(message);
        end
    end
    ngx.exit(ngx.HTTP_OK);
end

local function _log(level,fmt,...)
    local t = type(fmt);
    if t=='string' then
        ngx.log(level,string.format(fmt,...))
    elseif t=='table' then
        ngx.log(level,cjson.encode(fmt))
    else
        ngx.log(level,fmt)
    end
end

mx.logger = {
    debug= function(fmt,...) _log(ngx.DEBUG,fmt,...) end,
    info= function(fmt,...) _log(ngx.INFO,fmt,...) end,
    warn= function(fmt,...) _log(ngx.WARN,fmt,...) end,
    error= function(fmt,...) _log(ngx.ERROR,fmt,...) end
};


--mysql
function initDb(options)
    local res_obj = {}

    mysql = require "resty.mysql"
    db, err = mysql:new()
    if not db then
        res_obj['code'] = 300
        res_obj['message'] = 'failed to instantiate mysql:'.. err
        return
    end

    db:set_timeout(1000) -- 1 sec

    --[[ mul --]]

    local ok, err, errno, sqlstate = db:connect(options)

    if not ok then
        res_obj['code'] = 300
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
