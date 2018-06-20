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
	    && pecl install xdebug-2.5.0 \
	    && docker-php-ext-enable xdebug

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
	&& docker-php-ext-install opcache

#安装PHP COMPOSER 并设置中国镜像源
RUN curl -sS https://getcomposer.org/installer | php \
    && mv composer.phar /usr/local/bin/composer \
    && composer config -g repo.packagist composer https://packagist.phpcomposer.com
    
#删除暂时用不到的依赖包   节省空间  
RUN apk del autoconf dpkg-dev dpkg file g++ gcc libc-dev make pkgconf re2c    
