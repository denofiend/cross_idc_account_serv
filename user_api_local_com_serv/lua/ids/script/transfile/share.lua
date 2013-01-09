local APPNAME = 'test';

function is_integer(n)
    local nstr = '' .. n;
    return nstr:match('^[0-9]*$');
end

function is_email(em)
    if not em then return false; end;
    return em:match('[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?');
end

function is_phone(pn)
    if not pn then return false; end
    return pn:match('^[0-9]*-[0-9]*$');
end

function exit(code,msg)
    mx.logger.trace('[gloabl] exit: %s,%s',code,msg);
    mx.exit(code,{ message= msg });
end

--[[
--check if user is online
--return true if user's online, elsewise false
--]]
function user_is_online(uid)
    mx.logger.trace('[call] user_is_online(%s)',uid);
    local res = mx.http_get(
        'http://ps-api-push-s.maxthon.com/devices?user=' .. uid .. '&match_apps=' .. APPNAME);

    mx.logger.trace(res);
    if not res or res.code~=200 or not res.body then
        return false;
    end
    local obj = cjson.decode(res.body);
    return (obj and table.maxn(obj)>0);
end

--[[
--verify user's key is available
--@param u user_id
--@param d device
--@param a app
--@param k key
--return true if user's key is available, elsewise false
--]]
function user_auth(u,d,a,k)
    mx.logger.trace('[call] user_auth(%s,%s,%s,%s)',u,d,a,k);
    local res = mx.http_post(
        'http://key.user.maxthon.cn/key',
        cjson.encode({
            ['user_id']= u,
            ['device']= d,
            ['app']= a,
            ['key']= k
        }));

    mx.logger.trace(res);
    if not res or res.code~=200 or not res.body then
        return false;
    end
    local rbj = cjson.decode(res.body);
    return rbj.code==1;
end

--[[
--push sync message
--@param user
--@param app
--@param msg
--]]
function push_sync_message(user,app,msg)
    mx.logger.trace('[call] push_sync_message(%s,%s,%s)',user,app,msg);
    if not user or not app or not msg then
        return false;
    end
    local res = mx.http_post(
        'http://ps-api-push-s.maxthon.com/sync',
        cjson.encode({
            user_id= '' .. user,
            app_id= app,
            message= msg
        }));

    mx.logger.trace(res);
    if not res or res.code~=200 or not res.body then
        return false;
    end
    local rbj = cjson.decode(res.body);
    return not rbj.error;
end

--[[
--send a short message to somebody.
--@param ac integer, area code
--@param pn string, phone number
--@param msg string, message content max size: 60 characters
--]]
function send_sms(ac,pn,msg)
    mx.logger.trace('[call] send_sms(%s,%s,%s)',ac,pn,msg);
    if not ac or not pn or not msg then
        return false;
    end
    local res = mx.http_post(
        'http://sms-gw.maxthon.com/sms',
        cjson.encode({
            area_code= tonumber(ac),
            phone_no= pn,
            message= msg
        }));

    mx.logger.trace(res);
    if not res or res.code~=200 or not res.body then
        return false;
    end
    local rbj = cjson.encode(res.body);
    return (rbj.code==1);
end

--[[
--send an email to somebody.
--@param address target email address
--@param title mail's title
--@param msg mail content
--]]
function send_email(address,title,msg)
    mx.logger.trace('[call] send_email(%s,%s,%s)',address,title,msg);
    return true;
end

--[[
--query user info by phone number
--@param ac area code
--@param pn phone number
--]]
function get_user_by_phone(ac,pn)
    mx.logger.trace('[call] get_user_by_phone(%s,%s)',ac,pn);
    if not ac or not pn then
        return false;
    end
    local res = mx.http_get('http://user-api.user.maxthon.cn/v1/users/mobile/'..pn..'?country_code='..ac);
    mx.logger.trace(res);
    if not res or res.code~=200 or not res.body then
        return false;
    end
    local rbj = cjson.encode(res.body);
    if rbj.code~=1 then
        return false;
    end
    return rbj.data;
end

--[[
--query user info by email
--@param email
--]]
function get_user_by_email(email)
    mx.logger.trace('[call] get_user_by_email(%s)',email);
    if not email then
        return false;
    end
    local res = mx.http_get('http://user-api.user.maxthon.cn/v1/users/email/'..email);
    mx.logger.trace(res);
    if not res or res.code~=200 or not res.body then
        return false;
    end
    local rbj = cjson.encode(res.body);
    if rbj.code~=1 then
        return false;
    end
    return rbj.data;
end

--[[
--query user info by user id
--@param uid
--]]
function get_user_by_id(uid)
    mx.logger.trace('[call] get_user_by_id(%s)',uid);
    if not uid then return false; end
    local res = mx.http_get('http://user-api.user.maxthon.cn/v1/users/uid/'..uid);
    mx.logger.trace(res);
    if not res or res.code~=200 or not res.body then
        return false;
    end
    local rbj = cjson.encode(res.body);
    if rbj.code~=1 then
        return false;
    end
    return rbj.data;
end

--[[
--request file access key
--@param user_id
--@param user_nickname
--@param user_avatar
--@param path
--@param type
--@param screen_name
--@param message
--@param count
--]]
function request_access_key(uid,unickname,uavatar,path,type,name,message,count)
    return {'aB3dE'};
    --[[
    mx.logger.trace('[call] request_access_key(%s,%s,%s,%s,%s,%s,%s,%s)',
        uid,unickname,uavatar,path,type,name,message,count);
    if not uid
        or not unickname
        or not uavatar
        or not path
        or not type
        or not name
        or not message
        or not count then
        return false;
    end
    local res = mx.http_post(
        'http://cs-s.maxthon.cn/ex/share/generate',
        cjson.encode({
            user_id= uid,
            user_nickname= unickname,
            user_avatar= uavatar,
            path= path,
            type= type,
            screen_name= name,
            message= message,
            count= count
        }));
    mx.logger.trace(res);
    if not res or res.code~=200 or not res.body then
        return false;
    end
    if not res.headers or res.headers['X-Maxthon-FileSync-Ret']~=0 then
        return false;
    end
    local rbj = cjson.encode(res.body);
    return rbj.keys;
    --]]
end

function add_user_contacts(uid,items)
    return true;
    --[[
    mx.logger.trace('[call] add_user_contacts(%s,%s)',uid,items);
    if not uid or not items then return false; end
    local res = mx.http_post(
        'http://contacts-u.maxthon.cn/v1/contacts/sendfile/set',
        cjson.encode({
        }));
    mx.logger.trace(res);
    if not res
        or res.code~=200
        or not res.body
        or not res.headers['X-Maxthon-Code']~=200 then
            return false;
        end
    return true;
    --]]
end

------------------------------------------
-- read request body
------------------------------------------
ngx.req.read_body();
local body = ngx.req.get_body_data();
mx.logger.trace('[global] body: %s',body);
if body==nil then
    exit(400,'body is empty');
end

local p = cjson.decode(body);
if not p.user_id
    or not p.device
    or not p.authkey
    or not p.authapp
    or not p.targets
    or not p.path
    or not p.type
    or not p.screen_name
    or not p.message then
    exit(400,'parameters are not enough');
end

-- TODO
-- avatar_url
-- nickname

------------------------------------------
-- verify user account
------------------------------------------
if not user_auth(p.user_id,p.device,p.authapp,p.authkey) then
    exit(300,'user auth failed');
end

------------------------------------------
-- request file's public access key
------------------------------------------
local keys = request_access_key();
if not keys then
    exit(500,'request public access key failed')
end

------------------------------------------
-- generate messages
------------------------------------------
local link = 'https://surl-s.maxthon.com/'..keys[1];
local pushmsg = cjson.encode({
    action= 'other_transfile',
    avatar= '',
    nickname= '',
    message= p.message,
    link= link
});
local emailtitle = '您有朋友在傲游云端发文件给您！';
local emailmsg = '下载链接：'..link;
local smsmsg = '您有朋友在傲游云端发文件给您：'..link;

------------------------------------------
-- send messages
------------------------------------------
local users = (type(p.targets)=='string' and {p.targets} or p.targets);
local contacts = {};

for i,v in ipairs(users) do
    if is_email(v) then
        local user = get_user_by_email(v);
        if not user then
            -- send email to unregister user
            if send_email(v,emailtitle,emailmsg) then
                table.insert(contacts,v);
            end
        else
            if push_sync_message(user.user_id,APPNAME,pushmsg) then
                table.insert(contacts,v);
            end
        end
    elseif is_phone(v) then
        local ns = mx.split(v,'-',true);
        -- is valid phone number
        if table.maxn(ns) == 2 and is_integer(ns[1]) and is_integer(ns[2]) then
            -- send sms to ns[1]-ns[2]
            local user = get_user_by_phone(ns[1],ns[2]);
            if not user then
                if send_sms(ns[1],ns[2],smsmsg) then
                    table.insert(contacts,v);
                end
            else
                if push_sync_message(user.user_id,APPNAME,pushmsg) then
                    table.insert(contacts,v);
                end
            end
        end
    end
end

------------------------------------------
-- save user contacts
------------------------------------------
if table.maxn(contacts)>0 then
    add_user_contacts(p.user_id,contacts);
end

------------------------------------------
-- done
------------------------------------------
exit(200,'OK');

