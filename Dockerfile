FROM debian:buster

# Sury APT リポジトリを Debian に追加
RUN apt update
RUN apt -y upgrade
RUN apt update
RUN apt install -y lsb-release ca-certificates apt-transport-https software-properties-common gnupg2 curl

RUN echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/sury-php.list

RUN curl -fsSL  https://packages.sury.org/php/apt.gpg| gpg --dearmor -o /etc/apt/trusted.gpg.d/sury-keyring.gpg

# PHP8.1 と apache2 のインストール
RUN apt update 
RUN apt install -y php8.1 apache2

# Node.js のインストール
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -
RUN apt install -y nodejs

# PHP の依存モジュールインストール
RUN apt update \
        && apt install -y \
            g++ \
            libicu-dev \
            libpq-dev \
            libzip-dev \
            zip \
            zlib1g-dev \
            php8.1-intl \
            php8.1-opcache \
            php8.1-pdo \
            php8.1-mysql \
            php8.1-xml \
            php8.1-dom \
            php8.1-curl \
            php8.1-mbstring \
            php8.1-dev \
            php-pear

## XDebug のインストール
RUN pecl install xdebug
RUN echo 'zend_extension=/usr/lib/php/20210902/xdebug.so' >> /etc/php/8.1/cli/php.ini
RUN echo '[xdebug] \n\
	    xdebug.mode = debug \n\
		xdebug.start_with_request = yes \n\
		xdebug.client_host = "host.docker.internal" \n\
		xdebug.client_port = 9003 \n\
		xdebug.log = "/var/log/xdebug.log" \n\
' >> /etc/php/8.1/cli/php.ini

# mod_rewrite を有効化
RUN a2enmod rewrite

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]