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
        
#select
def select():
	url = "/message/select"
	#body = "{\"account\":\"denofiend@gmail.com\", \"nickname\": \"denofiend\", \"password\":\"ee79976c9380d5e337fc1c095ece8c8f22f91f306ceeb161fa51fecede2c4ba1\"}"
	httpMethod = "GET"
	headers = {"Content-type": "application/json"}
	host = "db.maxthon.cn:3306"

	return doRequest(host, url, httpMethod, None, headers)

#update
def update_status(region_id, status):
	url = "/message/status/update?region_id="+str(region_id) +"&status="+str(status)

	httpMethod = "GET"
	headers = {"Content-type": "application/json"}
	host = "db.maxthon.cn:3306"
	return doRequest(host, url, httpMethod, None, headers)


def center_sync(body):
	url = "/sync"
	#body = "{\"type\":\"insert\", \"region_id\":1, \"user_id\":5, \"email\":\"denofiend-2012@gmail.com\", \"account\":\"denofiend-2012@gmail.com\", \"nickname\": \"denofiend-25\", \"password\":\"ee79976c9380d5e337fc1c095ece8c8f22f91f306ceeb161fa51fecede2c4ba1\"}"
	httpMethod = "POST"
	headers = {"Content-type": "application/json"}
	host = "user-api-center.maxthon.cn"
	return doRequest(host, url, httpMethod, body, headers)


# main function
def main():
	#get one from quqeue
	print ">>> get one from queue"
	body =  select()
	print body
	jsonData = json.loads(body)

	if len(jsonData) == 0:
		print 'queue is empty'
		return

	json_json = json.loads(jsonData[0]['json'])
	json_json['status'] = jsonData[0]['status']
	json_json['region_id'] = jsonData[0]['region_id']
	json_json['type'] = jsonData[0]['type']
	json_json['user_id'] = jsonData[0]['user_id']

	#set this message status to 1
	print ">>> set this message status to 1(RUNNING)"
	print update_status(jsonData[0]['region_id'], 1)

	#sync this message to user_api_center
	print ">>> sync this message to user_api_center"
	sync_body =  center_sync(json.dumps(json_json))
	sync_json = json.loads(sync_body)
	print sync_json

	if sync_json['code'] == 1:
		#set this message status to 2
		print ">>> set this message status to 2(FINISH)"
		print update_status(jsonData[0]['region_id'], 2)
	
	print "<<< one task over"



main()


   








    
