FROM alpine:3.15-hw

ARG kafka_version=3.1.0
ARG scala_version=2.13

RUN apk add --no-cache openjdk8 tzdata bash \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone \
    && apk del tzdata && rm -rf /var/cache/apk/*
    
ADD kafka_2.13-3.1.0.tgz /opt/

ENV KAFKA_VERSION=${kafka_version} \
    SCALA_VERSION=$scala_version \
    KAFKA_HOME=/opt/kafka

ENV PATH=${PATH}:${KAFKA_HOME}/bin

WORKDIR ${KAFKA_HOME}

CMD ["bash", "-c", "./run.sh"]
