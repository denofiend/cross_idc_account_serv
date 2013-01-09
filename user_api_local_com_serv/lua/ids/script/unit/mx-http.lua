ngx.say('==MX HTTP UNIT TEST BEGIN...\n')

ngx.say('[request] - GET '..'http://user-api.user.maxthon.cn/v1/users/email/test-1@mx.com\n');
local res = mx.http_get('http://user-api.user.maxthon.cn/v1/users/email/test-1@mx.com');
if res.code == 200 then
    ngx.say('OK\n');
    ngx.say('[headers] - '..cjson.encode(res.headers)..'\n');
    ngx.say('[data] - '..cjson.encode(res.data)..'\n');
else
    ngx.say('FAILED\n');
end

ngx.say('==MX HTTP UNIT TEST FINISH.');

