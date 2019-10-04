#syntax=docker/dockerfile:experimental
FROM maven:3.6.1-jdk-11 AS build
WORKDIR /usr/src/app
# copy just the pom.xml for cache efficiency
COPY ./pom.xml /usr/src/app
# go-offline using the pom.xml
RUN --mount=type=cache,target=/root/.m2 mvn -f /usr/src/app/pom.xml dependency:go-offline
# now copy the rest of the code and run an offline build
COPY . /usr/src/app
RUN --mount=type=cache,target=/root/.m2 mvn -o clean package 

FROM adoptopenjdk/openjdk11:alpine-jre
ENV SERVER_PORT 80
EXPOSE 80
COPY --from=build /usr/src/app/target/*.jar /opt/target/app.jar
WORKDIR /opt/target

CMD ["java", "-jar", "/opt/target/app.jar", "--server.port=80" ]
