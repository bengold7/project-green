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

You can use docker pull from my DockerHub and run it easily:

```bash
docker pull bengold7/project-green-v1:3
docker run -p 8080:8080 bengold7/project-green-v1:3
```

Or as there is `Dockerfile` in this project, You can build a container image and run it (after compile; next paragraph):

```bash
docker build -t project-green-image .
docker run -p 8080:8080 project-green-image
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

### Dockerfile creation

| Command | Description |
| --- | --- |
| FROM openjdk:17-jdk | **Specifies the base image for the Docker image. (As for the requirment of Spring Petclinic)** |
| WORKDIR /app | **Sets the WORKDIR as /app, so further commands will be executed on this directory** |
| COPY target/spring-petclinic*.jar app.jar | **Copies the JAR file generated during the build process into /app inside the Docker image** |
| EXPOSE 8080 | **The application inside the container will use port 8080** |
| ENTRYPOINT ["java", "-jar", "app.jar"] | **The initial executed command when the container starts to launch the Java application `java -jar app.jar`** |

### Pipline.yml file creation

`pipline.yml` is under `.github/workflows/` to execute the pipline [GitHub Actions](https://github.com/features/actions). 

- *Trigger: pushing to 'main' branch*
- *Runs on: latest ubuntu version*

1. **Checkout Repository** - Fetching the contents of the repository to the runner machine which ensures access to the latest version.
```bash
uses: actions/checkout@v3
```
2. **Set up JDK 17** - Sets up the necessary Java environment for building and testing Java applications in GitHub Actions workflows.
```bash
uses: actions/setup-java@v2
```
3. **Build with Maven Wrapper** - Builds the project. I chose Maven Wrapper as it is recommended by Spring PetClinic's original workflow.
```bash
run: ./mvnw -B package
```
4. **Run Maven Tests** - Instructs Maven to execute tests (./src/test/*) using the configuration specified in the pom.xml file. 
```bash
run: mvn test --file pom.xml
```
5. **Login to Docker Hub** - Used to login against a Docker registry. Credentials are stored in Secrets.
```bash
uses: docker/login-action@v3
```
6. **Set up Docker Buildx** - Required for the following steps of the workflow if using build-push action.
```bash
uses: docker/setup-buildx-action@v3
```
7. **Build and push to Docker Hub** - Builds and pushes the Docker image to [Docker Hub](https://hub.docker.com/r/bengold7/project-green-v1).
```bash
uses: docker/build-push-action@v5
```
8. **Setup JFrog CLI** - Downloads, installs and configures JFrog CLI, so that it can be used as part of the workflow.
```bash
uses: jfrog/setup-jfrog-cli@v3
```
9. **Build and push to JFrog Artifactory** - Builds and pushes the Docker image to JFrog Artifactory.
```bash
run: jf docker build -t $IMAGE_NAME . | run: jf docker push $IMAGE_NAME
```
10. **Publish extra info with JFrog CLI** - Sends extra info such as environment variables, VCS details and build info to JFrog Artifactory.
```bash
run: jf rt build-collect-env | run: jf rt build-add-git | jf rt build-publish
```
11. **Create SBOM** - Creates a software bill of materials (SBOM) and stores it in the workflow's artifacts.
```bash
uses: anchore/sbom-action@v0
```
12. **Scan SBOM** - Scans the SBOM output and check for vulnerabilities. It can fail the workflow if a certain CVE severity is found.
```bash
uses: anchore/scan-action@v3
```
13. **Frogbot Scan** - [JFrog Frogbot](https://github.com/jfrog/frogbot/tree/master) is a Git bot that scans your Git repositories for security vulnerabilities using SCA and more tools.
```bash
uses: jfrog/frogbot@v2
```

## Vulnerabilities

### Frogbot in GitHub Actions

Scan Data complete report - Please also choose the most critical CVE to handle (in your opinion) and explain: why & what is the impact

| Order | CVE | Severity | Component | Fixable? | Potential Impact | Applicable? |
| --- | --- | --- | --- | --- | --- | --- |
| 1 | CVE-2023-51074 | Warning | com.jayway.jsonpath:json-path 2.8.0 | X | DDoS | N/A |
| 2 | CVE-2023-6378 | High | ch.qos.logback:logback-core 1.4.11 | V | DDoS | N/A |
| 3 | CVE-2023-22102 | High | com.mysql:mysql-connector-j 8.1.0 | X | Data Theft | NO |

- **Risk Scope**: In my opinion, Data Theft is more risky than DDoS attack (unless it is hospital/ sensitive organizations)
- **Reputation**: `MySql` is often used and hard to replace. `logback` and `json-path` have a lot of alternatives.
- **Fix**: I chose `json-path` over `logback` only for the reason that it can't be fixed yet so it require more attention until replacement/fix.
- **Applicability**: Although `MySql` presents the highest risk, it is not applicable and therefore I downgraded it to the end of the list.
- *Neither Xray scans could determine if the other components are applicable*

### JFrog Xray Scan

| Order | CVE | Severity | Component | Fixable? | Potential Impact | Applicable? |
| --- | --- | --- | --- | --- | --- | --- | 
| 1 | CVE-2023-4911 | High | 8:glibc:0:2.28-164.0.5.el8_5.3 | YES | Privilege Escalation | YES |
| 2 | CVE-2022-2068 & CVE-2022-1292 | Medium | 8:openssl-libs:1:1.1.1k-6.el8_5 | YES | Arbitrary code execution and Command injection | YES |
| 3 | CVE-2023-6378 | High | 8:zlib:0:1.2.11-17.el8 | YES | DDoS | YES |

- **Risk Scope**: In my opinion, Privelge Escalation equals to jackpot in Cyber attacks.
- **Reputation**: All of the libraries above are often used.
- **Fix**: All of the libraries are fixable.
- **Applicability**: All of the CVEs are aplicable.
- *In this case I chose mostly because of the potential impact*

### Attachments

- Scan Data complete report - [Download - .zip](https://github.com/bengold7/project-green/files/13875847/Docker_jfrog-docker-example-image_version-8_qons.ben%40gmail.com_2024-01-09.1.zip)
- SBOM during the pipline - [Download - .zip](https://github.com/bengold7/project-green/files/13875978/project-green-full-pipline.spdx.json.zip)


## License

The Spring PetClinic sample application is released under version 2.0 of the [Apache License](https://www.apache.org/licenses/LICENSE-2.0).
