# Project Green

![image](https://github.com/bengold7/project-green/assets/155953562/efbdcb36-dfab-4108-8c89-681183f20d72)

[![Scanned by Frogbot](https://raw.github.com/jfrog/frogbot/master/images/frogbot-badge.svg)](https://docs.jfrog-applications.jfrog.io/jfrog-applications/frogbot) 

## About the project

Project Green is based on: [Spring PetClinic Sample Application](https://github.com/spring-projects/spring-petclinic) with a goal to build a pipline using GitHub Actions.

The task is to cover the following steps: 

- Compile the code
- Run the tests
- Package the project as a runnable Docker image
- Scan the project with an SCA tool 
- Publish the image to JFrog Artifactory

## Run Petclinic using docker

As there is `Dockerfile` in this project. You can build a container image and run it:

```bash
docker build -t project-green-image .
docker run -p 8080:8080 project-green-image
```

Or you can use docker pull from my DockerHub and run it easily:

```bash
docker pull bengold7/project-green-v1:3
docker run -p 8080:8080 bengold7/project-green-v1:3
```

You can then access the Petclinic at <http://localhost:8080/>.

## Run Petclinic locally

Spring Petclinic is a [Spring Boot](https://spring.io/guides/gs/spring-boot) application built using [Maven](https://spring.io/guides/gs/maven/) or [Gradle](https://spring.io/guides/gs/gradle/). You can build a jar file and run it from the command line (it should work just as well with Java 17 or newer):

```bash
git clone https://github.com/bengold7/project-green.git
cd project-green
./mvnw package
java -jar target/*.jar
```

You can then access the Petclinic at <http://localhost:8080/>.

## Screenshot

<img width="1042" alt="petclinic-screenshot" src="https://cloud.githubusercontent.com/assets/838318/19727082/2aee6d6c-9b8e-11e6-81fe-e889a5ddfded.png">

## The work on the project

First, I cloned [Spring PetClinic Sample Application](https://github.com/spring-projects/spring-petclinic) by running:
```bash
git clone https://github.com/spring-projects/spring-petclinic.git
```
And created a `Dockerfile`:

| Command | Description |
| --- | --- |
| FROM openjdk:17-jdk | **Specifies the base image for the Docker image. (As for the requirment of Spring Petclinic)** |
| WORKDIR /app | **Sets the WORKDIR as /app, so further commands will be executed on this directory** |
| COPY target/spring-petclinic*.jar app.jar | **Copies the JAR file generated during the build process into /app inside the Docker image** |
| EXPOSE 8080 | **The application inside the container will use port 8080** |
| ENTRYPOINT ["java", "-jar", "app.jar"] | **The initial executed command when the container starts to launch the Java application `java -jar app.jar`** |

- I specified the base image for the Docker image. (`OpenJDK 17 image`; as the requirments from Spring Petclinic)
- I set the WORKDIR as /app, so further commands will be executed on this directory
- 

## License

The Spring PetClinic sample application is released under version 2.0 of the [Apache License](https://www.apache.org/licenses/LICENSE-2.0).
