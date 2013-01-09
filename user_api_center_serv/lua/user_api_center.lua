
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

function doDB(pre_uri, req_obj)

	ngx.log(ngx.DEBUG, ">>>doDB")
	local res_obj = {}
	local cjson = require "cjson"

	--insert into `base_usr_info` table
	--
	while true do
		local uri = pre_uri .."?user_id="..req_obj.user_id..
		"&email="..req_obj.email..
		"&password="..req_obj.password..
		"&nickname="..req_obj.nickname..
		"&json="..cjson.encode(req_obj)..
		"&status=0"..
		"&region_id="..req_obj.region_id

		ngx.log(ngx.DEBUG, uri)

		local res = ngx.location.capture(uri)
		ngx.log(ngx.DEBUG, res.body)
		local obj = cjson.decode(res.body)

		if obj.errcode == 0 then
			res_obj['code'] = 1
			res_obj['message'] = 'ok'
			break
		end

		ngx.log(ngx.NOTICE, obj.errstr)

		if isUserIdDup(obj.errstr) then
			ngx.log(ngx.NOTICE, req_obj.user_id)
			res_obj.code = 301
			res_obj.message = 'user_id is dup'
			break
		else
			res_obj.code = 302
			if isAccountDup(obj.errstr) then
				req_obj.account = 'mx_'..req_obj.account
				res_obj.message = res_obj.message..',account is rewrited'
			elseif isEmailDup(obj.errstr) then
				req_obj.account = 'mx_'..req_obj.email
				res_obj.message = res_obj.message..',email is rewrited'
			elseif isNicknameDup(obj.errstr) then
				req_obj.nickname = 'mx_'..req_obj.nickname
				res_obj.message = res_obj.message..',nickname is rewrited'
			else
				break 
			end
		end

	end

	local cjson = require "cjson"
	ngx.log(ngx.DEBUG, cjson.encode(res_obj))
	return res_obj
end



-- sync
function sync(region)
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

	-- req_obj.type

	if req_obj.type == 'insert' then
		res_obj = doDB("/center/add", req_obj)
	elseif req_obj.type == 'update' then
		res_obj = doDB("/center/update", req_obj)
	end

	-- return res
	res_obj['user'] = req_obj
	local cjson = require "cjson"
	ngx.say(cjson.encode(res_obj))
end


sync('IDC5')


