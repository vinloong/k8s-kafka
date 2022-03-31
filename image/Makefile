VERSION=kafka_2.13-3.1.0
PROJECT_ID=devops
PROJECT=repository.anxinyun.cn/${PROJECT_ID}

all: build

build:
	docker build --pull -t ${PROJECT}/fs-kafka:${VERSION} .

push: build
	gcloud docker -- push ${PROJECT}/fs-kafka:${VERSION}

.PHONY: all build push