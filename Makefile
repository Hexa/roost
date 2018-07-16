.PHONY: all ubuntu-14.04 ubuntu-16.04 ubuntu-18.04

BRANCH = develop
TAG := $(BRANCH)
TARGET = $@

all: ubuntu-14.04 ubuntu-16.04 ubuntu-18.04

ubuntu-14.04 ubuntu-16.04 ubuntu-18.04:
	docker image build -t roost:$(TARGET) --build-arg branch=$(TAG) --no-cache - < docker/Dockerfile-$(TARGET)
	docker container run -it --name roost-$(TARGET)  roost:$(TARGET) crystal build src/roost.cr --release
	docker container cp roost-$(TARGET):roost/roost .
	tar cxf roost-$(TARGET).tar.gz roost
	rm roost
	docker container rm roost-$(TARGET)
	docker image rm roost:$(TARGET)
