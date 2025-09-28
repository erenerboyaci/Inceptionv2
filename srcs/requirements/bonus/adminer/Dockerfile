FROM debian:bullseye

RUN apt update && apt install wget php7.4 php7.4-fpm -y

RUN wget -O adminer.php https://github.com/vrana/adminer/releases/download/v5.4.1/adminer-5.4.1-en.php

RUN chown www-data:www-data adminer.php
RUN chmod 755 adminer.php

COPY ./conf/www.conf /etc/php/7.4/pool.d/www.conf
COPY ./tools/adminer.sh /adminer.sh
RUN chmod +x /adminer.sh
ENTRYPOINT ["/adminer.sh"]
CMD ["php-fpm7.4", "-F"]