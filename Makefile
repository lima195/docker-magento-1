#!make

## Edit this vars:

MYSQL_DUMP_FILE=project.sql
BASE_URL=http://paperview.localhost/
HOST_IP=172.17.0.1 # /sbin/ip route|awk '/default/ { print $3 }'

## CUSTOM VARS



## Do not edit vars above:

DOCKER_DIR=docker-magento-1

PHP_DOCKER=docker-magento_php
NGINX_DOCKER=docker-magento_nginx
MYSQL_DOCKER=docker-magento_mysql
NGINX_WEB_ROOT=/usr/share/nginx/www

MAGENTO_LOCAL_XML=./etc/magento/app/etc/local.xml
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
	@echo " == Magento =="
	@echo " - make setup_magento (This will run all tasks above)"
	@echo " - make magento_update_baseurl"
	@echo " - make magento_create_localxml"
	@echo " - make magento_magerun_install"
	@echo " - make magento_magerun_create_admin"
	@echo " - make magento_cron_setup"
	@echo " - make magento_clear_cache"
	@echo " - make magento_set_permissions"
	@echo " "
	@echo " == Docker =="
	@echo " - make php_xdebug_remote_host"
	@echo " - make install_cron"
	@echo " - make docker_up"
	@echo " "
	@echo " == Custom tasks for project =="
	@echo " "
	@echo " - make magento_update_baseurl_myplanner (Needed to access myplanner store view)"
	@echo " - make create_paperview_host (Create Paperview Host to access paperview.localhost)"
	@echo " - make create_myplanner_host (Create Myplanner Host to access myplanner.localhost)"

## TASKS

## Custom Tasks

magento_update_baseurl_myplanner:
	sudo docker exec -it $(MYSQL_DOCKER) sh -c "mysql -u $(MYSQL_USER) -p$(MYSQL_PASS) -h $(MYSQL_HOST) $(MYSQL_DB_NAME) -e \"UPDATE core_config_data SET value = 'http://myplanner.localhost/' WHERE path in ('web/unsecure/base_url', 'web/secure/base_url') AND scope_id=2\"" -P $(MYSQL_PORT)

create_paperview_host:
	sudo -- sh -c "echo '172.22.0.102 paperview.localhost' >> /etc/hosts";

create_myplanner_host:
	sudo -- sh -c "echo '172.22.0.102 myplanner.localhost' >> /etc/hosts";

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

magento_update_baseurl:
	sudo docker exec -it $(MYSQL_DOCKER) sh -c "mysql -u $(MYSQL_USER) -p$(MYSQL_PASS) -h $(MYSQL_HOST) $(MYSQL_DB_NAME) -e \"UPDATE core_config_data SET value = '$(BASE_URL)' WHERE path in ('web/unsecure/base_url', 'web/secure/base_url')\"" -P $(MYSQL_PORT)

magento_create_localxml:
	sudo docker cp $(MAGENTO_LOCAL_XML) $(NGINX_DOCKER):/usr/share/nginx/www/$(MAGENTO_LOCAL_XML_TO);

magento_magerun_install:
	sudo docker cp bin/$(MAGENTO_MAGERUN) $(PHP_DOCKER):$(MAGENTO_MAGERUN);
	sudo docker cp bin/$(MAGENTO_MAGERUN) $(PHP_DOCKER):$(MAGENTO_MAGERUN_TO)/$(MAGENTO_MAGERUN);

magento_magerun_create_admin:
	sudo docker exec -it $(PHP_DOCKER) sh -c "$(MAGENTO_MAGERUN) admin:user:create"

magento_clear_cache:
	sudo docker exec -it $(NGINX_DOCKER) sh -c "rm -rf var/cache/*; rm -rf var/session/*;"

magento_set_permissions:
	sudo docker exec -it $(NGINX_DOCKER) sh -c "chown 1000:1000 $(NGINX_WEB_ROOT)/ -R; chmod 777 -R $(NGINX_WEB_ROOT)/var/ $(NGINX_WEB_ROOT)/media/"

php_xdebug_remote_host:
	sudo docker exec -it $(PHP_DOCKER) sh -c "head -n -1  $(PHP_XDEBUG_INI) > new_xdebug.ini ; mv new_xdebug.ini $(PHP_XDEBUG_INI)"
	sudo docker exec -it $(PHP_DOCKER) sh -c 'echo "xdebug.remote_host=$(PHP_XDEBUG_INI_HOST_IP)" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini'

docker_up:
	sudo docker-compose up -d

docker_up_build:
	sudo docker-compose up -d --build

remove_all_docker_stuff:
	docker kill $(docker ps -q); docker rm $(docker ps -a -q); docker rmi $(docker images -q); docker image prune -y; #remove all docker stufs;

setup_magento:
	make magento_update_baseurl
	make magento_create_localxml
	make magento_magerun_install
	make magento_set_permissions
	make php_xdebug_remote_host
	make magento_magerun_create_admin

install:
	make docker_up
	make db_install_pv
	make db_import_pv
	make setup_magento

install_paperview:
	make docker_up
	make db_install_pv
	make db_import_pv
	make setup_magento
	make magento_update_baseurl_myplanner

reinstall_paperview:
	make docker_up_build
	make db_install_pv
	make db_import_pv
	make magento_update_baseurl
	make magento_update_baseurl_myplanner
	make magento_create_localxml
	make magento_set_permissions
	make magento_magerun_install
	make magento_magerun_create_admin

PHONY: \
	db_install_pv \
	db_import \
	db_import_pv \
	db_drop_tables \
	magento_update_baseurl \
	magento_create_localxml \
	magento_magerun_install \
	magento_magerun_create_admin \
	magento_cron_setup \
	install_cron \
	php_xdebug_remote_host \
	docker_up \
	magento_clear_cache \
	magento_set_permissions \
	install \
	setup_magento \
	docker_up_build \
	reinstall_paperview \
	remove_all_docker_stuff \
	magento_update_baseurl_myplanner \
	create_paperview_host \
	create_myplanner_host
