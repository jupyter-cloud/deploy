up:
	. ./env.sh && docker-compose -p math101 up

down:
	. ./env.sh && docker-compose -p math101 down

clean:
	docker rm `docker ps -a -q`
