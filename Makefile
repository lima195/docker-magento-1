#!make

## Edit this vars:

MYSQL_DUMP_FILE=database.sql
BASE_URL=http://wordpress/
HOST_IP=10.10.17.142 # /sbin/ip route|awk '/default/ { print $3 }'

## CUSTOM VARS

## Do not edit vars above:

DOCKER_DIR=docker

PHP_DOCKER=docker-wordpress_php
NGINX_DOCKER=docker-wordpress_nginx
MYSQL_DOCKER=docker-wordpress_mysql
NGINX_WEB_ROOT=/usr/share/nginx/www

MAGENTO_LOCAL_XML=../$(DOCKER_DIR)/etc/magento/app/etc/local.xml
MAGENTO_LOCAL_XML_TO=app/etc/local.xml
MAGENTO_MAGERUN=n98-magerun.phar
MAGENTO_MAGERUN_TO=/usr/local/bin

MYSQL_DUMP_FILE_DIR=../mysql_dump
MYSQL_USER=magento
MYSQL_PASS=magento
MYSQL_DB_NAME=magento
MYSQL_HOST=172.22.0.108
MYSQL_PORT=3306

PHP_XDEBUG_INI=/usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini
PHP_XDEBUG_INI_HOST_IP=$(HOST_IP)

default:
	@echo "Please, specify a task to run:"
	@echo " "
	@echo " == Instal All =="
	@echo " - make install"
	@echo " "
	@echo " == Database =="
	@echo " - make db_install_pv"
	@echo " - make db_import"
	@echo " - make db_import_pv"
	@echo " - make db_drop_tables"
	@echo " "
	@echo " == Docker =="
	@echo " - make php_xdebug_remote_host"
	@echo " - make docker_up"
	@echo " "
	@echo " == Custom tasks for project =="
	@echo " "

## TASKS

## Custom Tasks



# Do not edit tasks above

db_install_pv:
	sudo docker exec -it $(MYSQL_DOCKER) sh -c "apt-get update; apt-get install -y pv"

db_import:
	sudo docker cp $(MYSQL_DUMP_FILE_DIR)/$(MYSQL_DUMP_FILE) $(MYSQL_DOCKER):/$(MYSQL_DUMP_FILE);
	sudo docker exec -it $(MYSQL_DOCKER) sh -c "mysql -u $(MYSQL_USER) -p$(MYSQL_PASS) -h $(MYSQL_HOST) $(MYSQL_DB_NAME) < /$(MYSQL_DUMP_FILE) -P $(MYSQL_PORT)"

db_import_pv:
	sudo docker cp $(MYSQL_DUMP_FILE_DIR)/$(MYSQL_DUMP_FILE) $(MYSQL_DOCKER):/$(MYSQL_DUMP_FILE);
	sudo docker exec -it $(MYSQL_DOCKER) sh -c "pv $(MYSQL_DUMP_FILE) | mysql -u $(MYSQL_USER) -p$(MYSQL_PASS) -h $(MYSQL_HOST) -P $(MYSQL_PORT) $(MYSQL_DB_NAME)"

db_drop_tables:
	sudo docker exec -it $(MYSQL_DOCKER) sh -c "mysql -u $(MYSQL_USER) -p$(MYSQL_PASS) -h $(MYSQL_HOST) -P $(MYSQL_PORT) --silent --skip-column-names -e \"SHOW TABLES\" $(MYSQL_DB_NAME) | xargs -L1 -I% echo 'SET FOREIGN_KEY_CHECKS = 0; DROP TABLE %;' | mysql -u $(MYSQL_USER) -p$(MYSQL_PASS) -v $(MYSQL_DB_NAME)"

php_xdebug_remote_host:
	sudo docker exec -it $(PHP_DOCKER) sh -c "head -n -1  $(PHP_XDEBUG_INI) > new_xdebug.ini ; mv new_xdebug.ini $(PHP_XDEBUG_INI)"
	sudo docker exec -it $(PHP_DOCKER) sh -c 'echo "xdebug.remote_host=$(PHP_XDEBUG_INI_HOST_IP)" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini'

docker_up:
	sudo docker-compose up -d

install:
	make docker_up
	make db_install_pv
	make db_import_pv

PHONY: \
	db_install_pv \
	db_import \
	db_import_pv \
	db_drop_tables \
	php_xdebug_remote_host \
	docker_up \
	install
