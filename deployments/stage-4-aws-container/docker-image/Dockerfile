FROM maven:3.8.5-openjdk-17-slim

WORKDIR /LibraryProject2

COPY ./repo/LibraryProject2 .

RUN mvn clean package -DskipTests

CMD [ "mvn", "spring-boot:run" ]
