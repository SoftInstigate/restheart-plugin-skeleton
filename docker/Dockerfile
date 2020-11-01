FROM softinstigate/restheart

LABEL maintainer="SoftInstigate <info@softinstigate.com>"

WORKDIR /opt/restheart
COPY restheart.sh ./

ENTRYPOINT [ "/opt/restheart/restheart.sh" ]

EXPOSE 8080 4000