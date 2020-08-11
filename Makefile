up:
	. ./env.sh && docker-compose up

down:
	. ./env.sh && docker-compose down

clean:
	docker rm `docker ps -a -q`
