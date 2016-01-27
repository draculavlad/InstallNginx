# InstallNginxOnCentOS7
* all in /opt

## preparement##
yum groupinstall -y "Development Tools"

## download and extract nginx##
```shell
wget http://nginx.org/download/nginx-1.8.0.tar.gz
tar zxf nginx-1.8.0.tar.gz
```

## download and extract pcre 7.8##
```shell
wget http://downloads.sourceforge.net/project/pcre/pcre/7.8/pcre-7.8.tar.gz
tar zxf pcre-7.8.tar.gz
```
## download and extract zlib 1.2.3##
```shell
wget http://pkgs.fedoraproject.org/repo/pkgs/zlib/zlib-1.2.3.tar.gz/debc62758716a169df9f62e6ab2bc634/zlib-1.2.3.tar.gz
tar zxf zlib-1.2.3.tar.gz 
```

## download nginx-rtmp-module##
```shell
git clone https://github.com/arut/nginx-rtmp-module.git
```

## create log dir and log file
```shell
mkdir -p ~/local
cd ~/local && touch errlog && touch httplog
```

## ready to configure and build and install nginx##
* now we got pcre and zlib and nginx-rtmp-module
* PCREHOME=/opt/pcre-7.8
* ZLIBEHOME=/opt/zlib-1.2.3
* NGINX_RTMP_MODULE_HOME=/opt/nginx-rtmp-module
* errlog_dir_path=/root/local/errlog
* httplog_dir_path=/root/local/httplog
```shell
cd /opt/nginx-1.8.0 && ./configure \
--prefix=/usr/local/nginx \
--sbin-path=/usr/local/nginx/nginx \
--conf-path=/usr/local/nginx/nginx.conf \
--pid-path=/usr/local/nginx/nginx.pid \
--lock-path=/var/run/nginx.lock \
--http-client-body-temp-path=/var/cache/nginx/client_temp \
--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
--with-http_ssl_module \
--with-http_realip_module \
--with-http_addition_module \
--with-http_sub_module \
--with-http_dav_module \
--with-http_flv_module \
--with-http_mp4_module \
--with-http_gunzip_module \
--with-http_gzip_static_module \
--with-http_random_index_module \
--with-file-aio \
--with-threads \
--with-pcre=/opt/pcre-7.8 \
--with-zlib=/opt/zlib-1.2.3 \
--error-log-path=/root/local/errlog \
--http-log-path=/root/local/httplog \
--add-module=/opt/nginx-rtmp-module
make
make install
```

## start nginx##
```shell
./nginx  
```

##stop nginx##
```shell
./nginx -s stop
```
or 
```shell
./nginx -s quit  
```
## host static files##

(how to)[https://github.com/draculavlad/NgxCloudStorage]

## load balance & reverse proxy##

```config
upstream $(instancename) {
	server $(your target ip):$(your target port);
}

server {
	listen $(proxy port to listen);
	
	location / {
		proxy_pass http://$instancename;
	
		        #Proxy Settings
        proxy_redirect     off;
        proxy_set_header   Host             $host;
        proxy_set_header   X-Real-IP        $remote_addr;
        proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
        proxy_next_upstream error timeout invalid_header http_500 http_502 http_503 http_504;
        proxy_max_temp_file_size 0;
        proxy_connect_timeout      90;
        proxy_send_timeout         90;
        proxy_read_timeout         90;
        proxy_buffer_size          4k;
        proxy_buffers              4 32k;
        proxy_busy_buffers_size    64k;
        proxy_temp_file_write_size 64k;

	}
}
```
