UNAME=$(shell uname)
mkfile_path := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
DEPENDENCY_FILES := $(mkfile_path)/Dockerfile $(mkfile_path)/../../requirements.txt
ifeq ($(UNAME), Linux)
  DEPENDENCY_CHECKSUM=$(shell cat $(DEPENDENCY_FILES) | md5sum | cut -f1 -d ' ')
endif

ifeq ($(UNAME), Darwin)
  DEPENDENCY_CHECKSUM=$(shell cat $(DEPENDENCY_FILES) | md5)
endif

base:
	@ if ! docker images | grep $(DEPENDENCY_CHECKSUM) |grep 'ofn/cli-base' -q ; then \
		docker build -f $(mkfile_path)/Dockerfile $(mkfile_path)../.. \
		  --target cli-base \
		  --build-arg arch=$(DOCKER_ARCH) \
		  -t ofn/cli-base:$(DEPENDENCY_CHECKSUM); \
	fi
	@docker tag ofn/cli-base:$(DEPENDENCY_CHECKSUM) ofn/cli-base:latest

.PHONY: build base push
