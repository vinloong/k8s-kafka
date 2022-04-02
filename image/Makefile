VERSION=2.13-3.1.0-220402
PROJECT_ID=devops
PROJECT=<your-image-repository>/${PROJECT_ID}

all: build

build:
	docker build --pull -t ${PROJECT}/dragon-kafka:${VERSION} .

push: build
	docker push ${PROJECT}/dragon-kafka:${VERSION}

