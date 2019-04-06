#!make
### docker-compose

GIT_REPO=git@104.237.3.212:paperview/paperview-magento.git

DOCKER_DIR=docker-magento-1

NGINX_DOCKER=docker-magento_nginx

BASE_URL=http://project.com/

LOCAL_XML=../$(DOCKER_DIR)/etc/local.xml
LOCAL_XML_TO=/usr/share/nginx/www/app/etc/local.xml

MYSQL_DOCKER=docker-magento_mysql
MYSQL_DUMP_FILE=project.sql
MYSQL_DUMP_FILE_DIR=../mysql_dump
MYSQL_USER=magento
MYSQL_PASS=magento
MYSQL_DB_NAME=magento
MYSQL_HOST=172.22.0.108
MYSQL_PORT=3306

# DOCKER TASKS

update_baseurl:
	sudo docker exec -ti $(MYSQL_DOCKER) sh -c "mysql -u $(MYSQL_USER) -p$(MYSQL_PASS) -h $(MYSQL_HOST) $(MYSQL_DB_NAME) -e \"UPDATE core_config_data SET value = '$(BASE_URL)' WHERE path in ('web/unsecure/base_url', 'web/secure/base_url')\"" -P $(MYSQL_PORT)

import_db:
	sudo docker cp $(MYSQL_DUMP_FILE_DIR)/$(MYSQL_DUMP_FILE) $(MYSQL_DOCKER):/$(MYSQL_DUMP_FILE);
	sudo docker exec -ti $(MYSQL_DOCKER) sh -c "mysql -u $(MYSQL_USER) -p$(MYSQL_PASS) -h $(MYSQL_HOST) $(MYSQL_DB_NAME) < /$(MYSQL_DUMP_FILE) -P $(MYSQL_PORT)"

create_localxml:
	sudo docker cp $(LOCAL_XML) $(NGINX_DOCKER):/$(LOCAL_XML_TO);

clone_repo:
	git clone $(GIT_REPO) ../paperview-magento

start:
	docker-compose up -d

install:
	make import_db
	make create_localxml
	make update_baseurl

# install_magerun:
# 	sudo docker exec -ti $(NGINX_DOCKER) sh -c "apt-get install; apt-get install curl;"
# 	sudo docker exec -ti $(NGINX_DOCKER) sh -c "curl -O https://files.magerun.net/n98-magerun.phar"
# 	sudo docker exec -ti $(NGINX_DOCKER) sh -c "chmod +x ./n98-magerun.phar"
# 	sudo docker exec -ti $(NGINX_DOCKER) sh -c "sudo cp ./n98-magerun.phar /usr/local/bin/"




