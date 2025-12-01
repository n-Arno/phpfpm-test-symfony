FROM bitnami/php-fpm:latest AS build

ENV COMPOSER_ALLOW_SUPERUSER=1
ENV COMPOSER_PROCESS_TIMEOUT=1800

COPY composer.json /root/composer.json

WORKDIR /root

RUN tdnf install git -y && \
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
    php composer-setup.php && \
    php -r "unlink('composer-setup.php');" && \
    mv composer.phar /usr/local/bin/composer && \
    curl -sS https://get.symfony.com/cli/installer | bash && \
    ln -s /root/.symfony5/bin/symfony /usr/local/bin/symfony && \
    git config --global user.email "hello@demo.com" && \
    git config --global user.name demo && \
    composer require -n symfony/flex && \
    symfony new --demo my_project

FROM bitnami/php-fpm:latest

RUN tdnf install nginx -y && \
    rm -rf /app

COPY --from=build /root/my_project /app
COPY entrypoint.sh /entrypoint.sh
COPY nginx-php.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD [ "/entrypoint.sh" ]
