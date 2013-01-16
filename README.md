Name
=================

cross IDC account service(http server): A user account services in China, the United States, Europe, and Other countries.


Description
=================

It contains ids service, id service, user-local service, user-local queue service, and user-center service, user-center queue service.

1. ids service: distribute segment of user id.

2. id service: get netxt insert id.

3. user-local service: write, read operations for user db.

4. user-local queue service: send the write operation to user-center service asynchronously.

5. user-center service: handle the user info conflicts, such as nickname, email, mobile..

6. user-center queue service: send the result of handle the conflicts to user-local service asynchronously.



REQUIRED
=================

1. nginx(http://nginx.org)

2. openresty(http://openresty.org/)

3. nginx-mysql-module(https://github.com/denofiend/nginx-mysql-module)



INSTALL
=================

nginx-mysql-module install
=================

	#download nginx
  		wget http://nginx.org/download/nginx-1.2.6.tar.gz

	#download nginx-mysql-module 
  		git clone https://github.com/denofiend/nginx-mysql-module
  		git clone https://github.com/arut/nginx-mtask-module
  		git clone https://github.com/denofiend/rds-json-nginx-module

	#install nginx
  		tar xvzf nginx-1.2.6.tar.gz
		cd nginx-1.2.6
		./configure --add-module=/path/to/nginx-mysql-module/ --add-module=/path/to/nginx-mtask-module/ --add-module=/path/to/rds-json-nginx-module/
		make
		sudo make install
 

openresty install
=================

	#download openresty
		git clone https://github.com/denofiend/ngx_openresty.git

	#install openresty
  		cd ngx_openresty
  		make
  		cd ngx_openresty-1.2.6.1rc2
  		./configure --with-luajit
  		make
  		sudo make install


cross IDC account service(http server) install
=================
	#download cross IDC account service(http server)
	git clone https://github.com/denofiend/cross_idc_account_serv.git

	
ids service 
=======

#mysql sqls
	create database ids;

	CREATE TABLE `ids` (
			`beg_id` bigint(20) NOT NULL AUTO_INCREMENT,
			`end_id` bigint(20) NOT NULL,
			`region` varchar(15) NOT NULL,
			PRIMARY KEY (`beg_id`)
	) ENGINE=InnoDB DEFAULT CHARSET=utf8;
	
	grant select, insert, update, delete on mx_ids.* to ids@'%';
	grant all on ids.* to ids@"%" identified by 'ids';

#ids service mysql configure on ids.lua 
	#download cross IDC account service(http server)
	cd cross_idc_account_serv/ids_serv
	vim lua/ids.lua

	#find the mysql config following, and then modify for your mysql config.  
		options['host'] = "10.100.15.7"
		options['port'] = 3306
		options['database'] = "ids"
		options['user'] = "ids"
		options['password'] = "ids"

#start ids service
	mkdir logs
	./app_run.sh




