up:
	. ./dev_env.sh && docker-compose up -d

down:
	. ./dev_env.sh && docker-compose down

clean:
	docker rm `docker ps -a -q`
