
function user_api_message_update(req_obj)
	local res_obj = {}

	local cjson = require "cjson"
	local uri = "/v1/message/update?user_id=" .. req_obj.user_id .. 
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
-- user_api_local db
--
function user_api_local_add(user_id, req_obj)
	local res_obj = {}

	local cjson = require "cjson"
	local uri = "/v1/message/add?user_id=" .. user_id .. 
	"&email=" .. req_obj.account .. "&account="..req_obj.account..
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

function is_own(req_obj)
	local res_obj = {}

	local cjson = require "cjson"
	local uri = "/v1/message/isown?region_id="..req_obj.region_id..
	"&user_id=" .. req_obj.user_id; 

	local res = ngx.location.capture(uri)
	local body = cjson.decode(res.body)
	
	ngx.log(ngx.DEBUG, 'is_own response(', res.body, ')');
	ngx.log(ngx.DEBUG, 'is_own body.errcode(', body.errcode, ')');

	res_obj['code'] = body[1].count;

	ngx.log(ngx.DEBUG, 'is_own res_obj[code](', res_obj['code'], ')');

	if body.errcode ~= 0 then
		res_obj['message'] = body.errstr
	end

	return res_obj

end



--run
function run(region)
    local res_obj = {}
    
    --get request body data
    local data = ngx.req.get_body_data()
    local req_obj
    if data ~= nil then 
        local cjson = require "cjson"
        req_obj = cjson.decode(data)
        ngx.log(ngx.DEBUG, 'request_body(', data, ')')
    else
        res_obj['code'] = 200
        res_obj['message'] = 'miss the reuqest body'
        ngx.log(ngx.ERR, 'miss the request body')
    end

	local type = req_obj['type']

	if type == "insert" then
		res_obj = is_own(req_obj)

		if 0 == res_obj['code'] then
			res_obj = user_api_local_add(req_obj.user_id, req_obj)
		end
	else
		res_obj = user_api_message_update(req_obj)
	end

	res_obj['user_id'] = req_obj.user_id

	if res_obj['code'] == 0 then
		res_obj['code'] = 1;
		res_obj['message'] = 'ok'
	end

	-- return res
	local cjson = require "cjson"
	ngx.say(cjson.encode(res_obj))
end


run('IDC5')


