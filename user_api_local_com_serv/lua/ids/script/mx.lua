require('ngx');
require('cjson');
local http = require('socket.http');
local ltn12 = require('ltn12');

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
    trace= function(fmt,...) _log(ngx.DEBUG,fmt,...) end,
    info= function(fmt,...) _log(ngx.INFO,fmt,...) end,
    warn= function(fmt,...) _log(ngx.WARN,fmt,...) end,
    error= function(fmt,...) _log(ngx.ERROR,fmt,...) end
};

--------------------------------
-- http bundle
--------------------------------
function parse_host(url)
    local host = string.match(url,'/[^/]+/');
    if string.len(host)<3 then return false; end
    return string.sub(host,2,string.len(host)-1);
end

function mx.http_get(url)
    if not url then return false; end
    local host = parse_host(url);

    local rb = {};
    local data = {
        url= url,
        method= 'GET',
        headers= {['Host']= host},
        sink= ltn12.sink.table(rb)
    };
    local stime = os.time();
    local r,c,hs = http.request(data);
    if r~=1 or table.maxn(rb)~=1 then return false; end

    return {code=c,headers=hs,body=rb[1],usedtime=os.time()-stime};
end

function mx.http_post(url,body,headers)
    if not url then
        return false;
    end
    local hs = headers and hs or {};
    local host = parse_host(url);

    hs['Host']= host;
    hs['Content-Type']= 'application/json';
    local rb = {};
    local data = {
        url= url,
        method= 'POST',
        headers= hs,
        sink= ltn12.sink.table(rb)
    };
    if body then
        hs['Content-Length']= string.len(body);
        data['source']= ltn12.source.string(body);
    end
    local stime = os.time();
    local r,c,hs = http.request(data);
    if r~=1 or table.maxn(rb)~=1 then return false; end

    return {code=c,headers=hs,body=rb[1],usedtime=os.time()-stime};
end


