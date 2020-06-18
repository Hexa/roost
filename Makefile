.PHONY: all run ubuntu-16.04 ubuntu-18.04 ubuntu-20.04

BRANCH ?= develop
TAG := $(BRANCH)
TARGET = $@

all:
	crystal build src/roost.cr --release

run:
	crystal run src/roost.cr

ubuntu-16.04 ubuntu-18.04 ubuntu-20.04:
	docker image build -t roost:$(TARGET) --build-arg branch=$(TAG) --build-arg target=$(TARGET) --no-cache --output . docker/
	tar cf roost-$(TARGET).tar.gz roost
	rm roost
