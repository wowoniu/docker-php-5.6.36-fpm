FROM php:5.6-fpm-alpine
MAINTAINER qiang <zhiqiangvip999@gmail.com>

#更改国内镜像源
RUN echo -e "https://mirrors.ustc.edu.cn/alpine/v3.7/main\nhttps://mirrors.ustc.edu.cn/alpine/v3.7/community\n" > /etc/apk/repositories

#安装拓展
RUN apk update && apk add --no-cache \
            $PHPIZE_DEPS \
	    freetype \
	    libjpeg-turbo \
	    freetype-dev \
	    libjpeg-turbo-dev \
            libpng \
            libpng-dev \
            libxml2 \
            libxml2-dev \
            libxslt \
            libxslt-dev \
            icu \
            icu-dev \
            libmcrypt \
            libmcrypt-dev \
	    libc-dev \
	    bash \
	    git \
	    re2c \
	    gcc \
	    g++ \
	    make \
	    autoconf \
	    openldap \
	    openldap-dev \
	    && pecl install xdebug-2.5.0 \
	    && pecl install memcache \
	    && pecl install redis \ 
	    && docker-php-ext-enable xdebug \
	    && docker-php-ext-enable memcache \
	    && docker-php-ext-enable redis


RUN  docker-php-ext-configure gd \
	    --with-gd \
	    --with-freetype-dir=/usr/include/ \
	    --with-png-dir=/usr/include/ \
	    --with-jpeg-dir=/usr/include/ && \
	NPROC=$(grep -c ^processor /proc/cpuinfo 2>/dev/null || 1) \    
	&& docker-php-ext-install -j${NPROC} gd \
	&& docker-php-ext-install mysqli \
	&& docker-php-ext-install mysql \
	&& docker-php-ext-install pdo_mysql \
	&& docker-php-ext-install zip \
	&& docker-php-ext-install soap \
	&& docker-php-ext-install xsl \
	&& docker-php-ext-install intl \
	&& docker-php-ext-install bcmath \
	&& docker-php-ext-install mcrypt \
	&& docker-php-ext-install opcache \
	&& docker-php-ext-install ldap

#安装PHP COMPOSER 并设置中国镜像源
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://packagist.phpcomposer.com
#安装phalcon拓展
RUN mkdir /tmp/phalcon-src 
WORKDIR /tmp/phalcon-src
RUN git clone -b 1.3.4 https://github.com/phalcon/cphalcon.git \
    && cd cphalcon/build \
    && ./install \
    && docker-php-ext-enable phalcon
#删除暂时用不到的依赖包   节省空间  
RUN apk del autoconf dpkg-dev dpkg bash git file g++ gcc libc-dev make pkgconf re2c    

#修复官方镜像中iconv bug
RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing gnu-libiconv
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php
