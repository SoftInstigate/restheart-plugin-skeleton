FROM softinstigate/restheart

LABEL maintainer="SoftInstigate <info@softinstigate.com>"

WORKDIR /opt/java
RUN curl -L https://github.com/TravaOpenJDK/trava-jdk-11-dcevm/releases/download/dcevm-11.0.9%2B1/java11-openjdk-dcevm-linux.tar.gz > java11-openjdk-dcevm-linux.tar.gz
RUN tar -xzf java11-openjdk-dcevm-linux.tar.gz

WORKDIR /opt/restheart
COPY restheart.sh ./

ENTRYPOINT [ "/opt/restheart/restheart.sh" ]

EXPOSE 8080 4000