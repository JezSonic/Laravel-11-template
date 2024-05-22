FROM ubuntu:jammy
ENV DEBIAN_FRONTEND noninteractive
ENV TZ=UTC
RUN apt -y -q update \
    && mkdir -p /etc/apt/keyrings \
	&& apt -y -q upgrade \
    && apt-get install -y gnupg software-properties-common gosu curl ca-certificates zip unzip git supervisor sqlite3 libcap2-bin ffmpeg apache2 \
    && curl -sS 'https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x14aa40ec0831756756d7f66c4f4ea0aae5267a6c' | gpg --dearmor | tee /etc/apt/keyrings/ppa_ondrej_php.gpg > /dev/null \
	&& echo "deb [signed-by=/etc/apt/keyrings/ppa_ondrej_php.gpg] https://ppa.launchpadcontent.net/ondrej/php/ubuntu jammy main" > /etc/apt/sources.list.d/ppa_ondrej_php.list \
	&& add-apt-repository -y ppa:ondrej/php
RUN apt-get install -y php8.3-cli php8.3-dev \
       php8.3-pgsql php8.3-sqlite3 php8.3-gd \
       php8.3-curl \
       php8.3-imap php8.3-mysql php8.3-mbstring \
       php8.3-xml php8.3-zip php8.3-bcmath php8.3-soap \
       php8.3-intl php8.3-readline \
       php8.3-ldap \
       php8.3-msgpack php8.3-igbinary php8.3-redis php8.3-swoole \
       php8.3-memcached php8.3-pcov php8.3-imagick php8.3-xdebug
RUN curl -sLS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer \
&& apt-get install -y mysql-client libapache2-mod-php
COPY ./supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./laravel-worker.conf /etc/supervisor/conf.d/laravel-worker.conf
RUN phpenmod sqlite3 gd pdo_mysql mysql mbstring redis zip curl openssl
RUN a2enmod rewrite \
	&& a2enmod ssl \
    && a2enmod php8.3 \
    && service apache2 start
COPY ./000-app.conf /etc/apache2/sites-enabled/000-default.conf
RUN service apache2 start
RUN service supervisor restart
CMD ["tail", "-f", "/dev/null"]
