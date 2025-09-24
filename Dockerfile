FROM node:lts

ENV JAVA_HOME=/opt/java/openjdk
COPY --from=eclipse-temurin:17 $JAVA_HOME $JAVA_HOME
ENV PATH="${JAVA_HOME}/bin:${PATH}"

RUN apt-get update && apt-get install maven -y

RUN apt-get update && apt-get install ca-certificates -y
COPY ./helper-scripts/x509-scripts/igi_test_ca/ca.crt /usr/local/share/ca-certificates/
RUN update-ca-certificates