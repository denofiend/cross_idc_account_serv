Name
=================

cross IDC account server: A user account services in China, the United States, Europe, and Other countries.


Description
=================

It contains ids service, id service, user-local service, user-local queue service, and user-center service, user-center queue service.

1.ids service: distribute segment of user id.

2. id service: get netxt insert id.

3. user-local service: registe,

4. user-local queue service: send the write operation to user-center service asynchronously.

5. user-center service: handle the user info conflicts, such as nickname, email, mobile..

6. user-center queue service: send the result of handle the conflicts to user-local service asynchronously.



REQUIRED
=================

1. nginx(nginx.org)

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
		git clone https://github.com/denofiend/ngx_openresty.git
  		cd ngx_openresty
  		make
  		cd ngx_openresty-1.2.6.1rc2
  		./configure --with-luajit
  		make
  		sudo make install





