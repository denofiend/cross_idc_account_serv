
-- user_api_local db
-- --
function user_api_local_update(req_obj)
	local res_obj = {}

	local cjson = require "cjson"
	local uri = "/mx_user/update?user_id=" .. req_obj.user_id .. 
	"&email=" .. req_obj.email .. 
	"&password="..req_obj.password.."&nickname="..req_obj.nickname..
	"&json="..cjson.encode(req_obj).."&status=0"

	local res = ngx.location.capture(uri)
	local body = cjson.decode(res.body)

	res_obj['code'] = body.errcode;

	if body.errcode ~= 0 then
		res_obj['message'] = body.errstr
	end

	return res_obj;
end


-- register
function update(region)
    local res_obj = {}
    
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

	res_obj = user_api_local_update(req_obj)

	res_obj['user_id'] = req_obj.user_id

	if res_obj['code'] == 0 then
		res_obj['message'] = 'ok'
	end


    -- return res
    local cjson = require "cjson"
    ngx.say(cjson.encode(res_obj))
end


update('IDC5')


