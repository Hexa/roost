.PHONY: all run ubuntu

BRANCH = develop
TAG := $(BRANCH)
TARGET = $@

all:
	crystal build src/roost.cr --release

run:
	crystal run src/roost.cr

ubuntu:
	docker image build -t roost:$(TARGET) --build-arg branch=$(TAG) --no-cache - < docker/Dockerfile
	docker container run -it --name roost-$(TARGET)  roost:$(TARGET) crystal build src/roost.cr --release
	docker container cp roost-$(TARGET):roost/roost .
	tar cf roost-$(TARGET).tar.gz roost
	rm roost
	docker container rm roost-$(TARGET)
	docker image rm roost:$(TARGET)
