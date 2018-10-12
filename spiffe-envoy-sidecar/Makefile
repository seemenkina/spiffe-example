.PHONY: build run demo clean

build:
	docker build spire-server -t spire-server
	docker build spire-agent -t spire-agent
	docker-compose build
run:
	docker-compose up -d
demo: build run
	sh run-demo.sh
clean:
	docker-compose down
