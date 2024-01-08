FROM adoptopenjdk:16-jre-hotspot

WORKDIR /app

COPY target/spring-petclinic*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
