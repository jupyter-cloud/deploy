up:
	docker-compose up -d

down:
	docker-compose down

clean:
	docker rm `docker ps -a -q`
