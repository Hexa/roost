.PHONY: all run spec clean

BRANCH ?= develop
TAG := $(BRANCH)
TARGET = $@

all:
	crystal build example/roost.cr --release

run:
	crystal run example/roost.cr

spec:
	crystal spec

clean:
	rm -rf roost*

.PHONY: ubuntu-16.04 ubuntu-18.04 ubuntu-20.04

ubuntu-16.04 ubuntu-18.04 ubuntu-20.04:
	docker image build -t roost:$(TARGET) --build-arg branch=$(TAG) --build-arg target=$(TARGET) --no-cache --output . docker/
	tar cf roost-$(TARGET).tar.gz roost
	rm roost
