Name
====

cross IDC account service(http server): A user account services in China, the United States, Europe, and Other countries.


Description
===========

It contains ids service, id service, user-local service, user-local queue service, and user-center service, user-center queue service.

1. ids service: distribute segment of user id.

2. id service: get netxt insert id.

3. user-local service: write, read operations for user db.

4. user-local queue service: send the write operation to user-center service asynchronously.

5. user-center service: handle the user info conflicts, such as nickname, email, mobile..

6. user-center queue service: send the result of handle the conflicts to user-local service asynchronously.



REQUIRED
========

1. nginx(http://nginx.org)

2. openresty(http://openresty.org/)

3. nginx-mysql-module(https://github.com/denofiend/nginx-mysql-module)



INSTALL
=======

Fisrt, install nginx with nginx-mysql-module:
--------------------------

Download nginx

	$ wget http://nginx.org/download/nginx-1.2.6.tar.gz

Download nginx-mysql-module, nginx-mtask-module, rds-json-nginx-module 

	$ git clone https://github.com/denofiend/nginx-mysql-module
  	$ git clone https://github.com/arut/nginx-mtask-module
  	$ git clone https://github.com/denofiend/rds-json-nginx-module

Install nginx

 	$ tar xvzf nginx-1.2.6.tar.gz
	$ cd nginx-1.2.6
	$ ./configure --add-module=/path/to/nginx-mysql-module/ --add-module=/path/to/nginx-mtask-module/ --add-module=/path/to/rds-json-nginx-module/
	$ make
	$ sudo make install
 

Install openresty
-----------------

Download openresty

	$ git clone https://github.com/denofiend/ngx_openresty.git

Install openresty

  	$ cd ngx_openresty
  	$ make
  	$ cd ngx_openresty-1.2.6.1rc2
  	$ ./configure --with-luajit
  	$ make
  	$ sudo make install


Install cross IDC account service(http server) 
----------------------------------------------
Download cross IDC account service(http server)

	$ git clone https://github.com/denofiend/cross_idc_account_serv.git

	
Install ids service in your center IDC
--------------------------------------

Create ids mysql database on your db server:

	create database ids;

	CREATE TABLE `ids` (
			`beg_id` bigint(20) NOT NULL AUTO_INCREMENT,
			`end_id` bigint(20) NOT NULL,
			`region` varchar(15) NOT NULL,
			PRIMARY KEY (`beg_id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	
	grant select, insert, update, delete on mx_ids.* to ids@'%';
	grant all on ids.* to ids@"%" identified by 'ids';

Find ids service mysql configure in ids.lua file

	$ cd cross_idc_account_serv/ids_serv
	$ vim lua/ids.lua

Find the mysql config following, and then modify for your mysql config.  

	options['host'] = "10.100.15.7"
	options['port'] = 3306
	options['database'] = "ids"
	options['user'] = "ids"
	options['password'] = "ids"

Start ids service

	$ mkdir logs
	$ ./app_run.sh

Test ids service

	$ curl http://ids-u.maxthon.cn/ids/segment/get


Install user-local service, id service in cn IDC(other server)
-----------------------------------------------------

Create user-local mysql database on your db server:

	create database mx_u_loc_cn;

	CREATE TABLE `base_user_info` (
		`user_id` int(11) NOT NULL,
		`account` varchar(255) NOT NULL,
		`password` char(64) DEFAULT NULL,
		`nickname` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin NOT NULL,
		`gender` tinyint(4) DEFAULT '0',
		`status` tinyint(4) DEFAULT '2',
		`ip` varchar(50) DEFAULT NULL,
		`register_time` char(10) DEFAULT NULL,
		`update_time` char(10) DEFAULT NULL,
		`language` char(50) DEFAULT NULL,
		`from` char(20) DEFAULT NULL,
		`email` varchar(255) DEFAULT NULL,
		`mobile` varchar(255) DEFAULT NULL,
		`country_code` int(11) DEFAULT NULL,
		PRIMARY KEY (`user_id`),
		UNIQUE KEY `account` (`account`),
		UNIQUE KEY `nickname` (`nickname`),
		UNIQUE KEY `email` (`email`),
		UNIQUE KEY `mobile` (`mobile`,`country_code`),
		KEY `register` (`register_time`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;

	CREATE TABLE `transaction_table` (
	  `region_id` bigint(20) NOT NULL AUTO_INCREMENT,
	    `user_id` bigint(20) NOT NULL,
		  `type` varchar(15) DEFAULT NULL,
		    `json` varchar(500) DEFAULT NULL,
			  `status` int(2) NOT NULL,
			    PRIMARY KEY (`region_id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8; 
	
	grant select, insert, update, delete on mx_u_loc_cn.* to mx_u_loc_cn@'%';
	grant all on mx_u_loc_cn.* to mx_u_loc_cn@"%" identified by 'mx_u_loc_cn';


Find user-local service mysql configure in db/conf/user_api_local.conf file

	$ cd /cross_idc_account_serv/user_api_local_cn_serv
	$ vim db/conf/user_api_local.conf

Find the mysql config following, and then modify for your mysql config.  

	mysql_host 10.100.15.7;
	mysql_user mx_u_loc_cn;
	mysql_password mx_u_loc_cn;
	mysql_port 3306;
	mysql_database mx_u_loc_cn;

Start user-local mysql http service

	$ cd db
	$ mkdir logs
	$ ./db_run.sh

Start user-local service

	$ cd ../
	$ mkdir logs
	$ ./app_run.sh

