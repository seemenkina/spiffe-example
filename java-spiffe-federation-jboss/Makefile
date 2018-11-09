build:
	docker build spire-base -t spire-base
	docker-compose build
run:
	docker-compose up -d
demo: build run
	./run-demo.sh
clean:
	docker-compose down

.PHONY: build run demo clean

