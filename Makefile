all: help

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""  This is merely a base image for usage read the README file
	@echo ""   1. make run       - build and run docker container

build: builddocker beep

#run: steam_username steam_password steam_guard_code steam_dir mysql builddocker rundocker beep

run:  www_dir tmp_dir mysqlmeta rundocker jobs

mysqlmeta: mysql_password mysql_dir mysql

mysql:
	docker run --name `cat NAME`-mysql \
	--cidfile="mysql" \
	-e MYSQL_ROOT_PASSWORD=`cat mysql_password` \
	-v `cat mysql_dir`:/var/lib/mysql \
	-d mysql:latest

rundocker:
	@docker run --name=`cat NAME` \
	-d \
	--cidfile="cid" \
	-v `cat www_dir`/config:/var/www/config \
	-v `cat www_dir`/html:/var/www/html \
	-v `cat tmp_dir`/moviemasher/temporary:/tmp/moviemasher/temporary \
	-v `cat tmp_dir`/moviemasher/queue:/tmp/moviemasher/queue \
	-v `cat tmp_dir`/moviemasher/log:/tmp/moviemasher/log \
	-p 44884:80 \
	--link `cat NAME`-mysql:mysql \
	-t `cat TAG`

jobs:
	@docker run --name=`cat NAME`jobs \
	-d \
	--cidfile="jobscid" \
	--volumes-from=`cat NAME` \
	-t moviemasher/moviemasher.rb \
	process_loop

builddocker:
	/usr/bin/time -v docker build -t `cat TAG` .

beep:
	@echo "beep"
	@aplay /usr/share/sounds/alsa/Front_Center.wav

kill:
	@docker kill `cat jobscid`
	@docker kill `cat cid`
	@docker kill `cat mysql`

rm-image:
	@docker rm `cat jobscid`
	@rm jobscid
	@docker rm `cat cid`
	@rm cid
	@docker rm `cat mysql`
	@rm mysql

cleanfiles:
	rm mysql_password
	rm tmp_dir
	rm www_dir
	rm mysql_dir

rm: kill rm-image

rmmysql: killmysql rmmysql-image

clean: cleanfiles rm

enter:
	docker exec -i -t `cat cid` /bin/bash

logs:
	docker logs -f `cat cid`

mysql_password:
	@while [ -z "$$MYSQL_PASSWORD" ]; do \
		read -r -p "Enter the mysql password you wish to associate with this container [MYSQL_PASSWORD]: " MYSQL_PASSWORD; echo "$$MYSQL_PASSWORD">>mysql_password; cat mysql_password; \
	done ;

tmp_dir:
	@while [ -z "$$TMP_DIR" ]; do \
		read -r -p "Enter the tmp dir you wish to associate with this container [TMP_DIR]: " TMP_DIR; echo "$$TMP_DIR">>tmp_dir; cat tmp_dir; \
	done ;

www_dir:
	@while [ -z "$$WWW_DIR" ]; do \
		read -r -p "Enter the www dir you wish to associate with this container [WWW_DIR]: " WWW_DIR; echo "$$WWW_DIR">>www_dir; cat www_dir; \
	done ;

mysql_dir:
	@while [ -z "$$MSYQL_DIR" ]; do \
		read -r -p "Enter the mysql dir you wish to associate with this container [MSYQL_DIR]: " MSYQL_DIR; echo "$$MSYQL_DIR">>mysql_dir; cat mysql_dir; \
	done ;
