FROM java:openjdk-8-alpine

WORKDIR /usr/src/app

ADD target/carts.jar ./app.jar

ENTRYPOINT ["java","-Djava.security.egd=file:/dev/urandom","-jar","./app.jar", "--port=80"]

