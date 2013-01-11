#!/usr/bin/python
'''
Created on 2012-4-17

@author: DenoFiend
'''
import httplib
import simplejson as json
import sys 
RETURN_SUCCESS_CODE = 1
ERROR_LEV1 = 1
SYSTEM_ERROR = 300
OK = 0

httplib.socket.setdefaulttimeout(5)

def doRequest(host, url, httpMethod, body, headers) :
	try:
		conn = httplib.HTTPConnection(host)
		conn.request(httpMethod, url, body, headers)
		response = conn.getresponse()
	#    print response.status, response.reason
	#    print response.msg
		data = response.read()

		response.close();
		conn.close()
	except httplib.socket.error:
		errno, errstr = sys.exc_info()[:2]
		print errno
		print errstr
		sys.exit(2)
	return data

def checkResponse(responseBody):
	#print ">>> parseResponse " + response
	jsonData = json.loads(responseBody)
	#print data["code"]
	if jsonData["code"] == SYSTEM_ERROR:
		print jsonData
		sys.exit (ERROR_LEV1)

#register
def register(host):
	url = "/register"
	body = "{\"account\":\"zhaoxu@gmail.com\", \"email\":\"zhaoxu@gmail.com\",\"nickname\": \"zhaoxu@com\", \"password\":\"123\"}"

	httpMethod = "POST"
	headers = {"Content-type": "application/json"}
	return doRequest(host, url, httpMethod, body, headers)

#update
def update(user_id,host):
	url = "/update"
	body = "{\"user_id\":"+ str(user_id) +", \"email\":\"denofiend@gmail.com\", \"nickname\": \"denofiend-25\", \"password\":\"123456\"}"
	httpMethod = "POST"
	headers = {"Content-type": "application/json"}
	return doRequest(host, url, httpMethod, body, headers)


# main function
def main():
	host = sys.argv[1]
	port = sys.argv[2]
	host = host + ":" + port
	print host
	#body =  register(host)
	#print body
	#jsonData = json.loads(body) 

	#user_id = jsonData['user_id']
	print update(2729, host)

main()











    
