include env
export

default:
	./jupytercloud.sh

up:
	./jupytercloud.sh up

down:
	./jupytercloud.sh down

logs:
	docker-compose logs -f

clean:
	docker rm `docker ps -a -q`
