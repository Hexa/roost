.PHONY: all ubuntu-14.04 ubuntu-16.04

BRANCH = develop
TAG := $(BRANCH)

all: ubuntu-14.04 ubuntu-16.04

ubuntu-14.04:
	docker image build -t roost:ubuntu-14.04 --build-arg branch=$(TAG) --no-cache - < docker/Dockerfile-ubuntu-14.04
	docker container run -it --name roost-ubuntu-14.04 roost:ubuntu-14.04 crystal build src/roost.cr --release
	docker container cp roost-ubuntu-14.04:roost/roost .
	mv roost roost-ubuntu-14.04
	docker container rm roost-ubuntu-14.04
	docker image rm roost:ubuntu-14.04

ubuntu-16.04:
	docker image build -t roost:ubuntu-16.04 --build-arg branch=$(TAG) --no-cache - < docker/Dockerfile-ubuntu-16.04
	docker container run -it --name roost-ubuntu-16.04 roost:ubuntu-16.04 crystal build src/roost.cr --release
	docker container cp roost-ubuntu-16.04:roost/roost .
	mv roost roost-ubuntu-16.04
	docker container rm roost-ubuntu-16.04
	docker image rm roost:ubuntu-16.04
