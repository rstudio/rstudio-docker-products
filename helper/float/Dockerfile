FROM ubuntu:18.04

# install deps
RUN apt-get update && \
	apt-get install -y \
	gdebi-core \
	curl \
	wget

# Runtime settings
ARG TINI_VERSION=0.18.0
RUN curl -L -o /usr/local/bin/tini https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini && \
    chmod +x /usr/local/bin/tini

# install license server binary
ARG PRODUCT=rsp
ARG VERSION=1.1.1
ARG PORT=8989
RUN wget https://s3.amazonaws.com/rstudio-license-server/${PRODUCT}-license-server-${VERSION}-x86_64.deb \
	-O ${PRODUCT}-license-server.deb && \
	gdebi -n ${PRODUCT}-license-server.deb && \
	rm ${PRODUCT}-license-server.deb

COPY startup.sh /usr/local/bin/startup.sh

RUN echo '\n\
<?xml version="1.0" encoding="utf-8"?>\n\
<config>\n\
    <!-- port to bind to -->\n\
    <bind port="{{PORT}}"/>\n\
\n\
    <!-- # of worker threads (0 means "one per CPU") -->\n\
    <cpu threads="0"/>\n\
\n\
    <!-- license lease time in seconds -->\n\
    <lease length="1800"/>\n\
\n\
    <!-- file to write logs to -->\n\
    <log file="/var/log/rstudio-licensing.log" level="warning"/>\n\
\n\
    <!-- reactivation settings -->\n\
    <isgenuine days_between="90" grace="14"/>\n\
\n\
    <!-- use proxy -->\n\
    <!-- <proxy url="http://user:pass@127.0.0.1:8080/"/> -->\n\
</config>\n\
\n'\
| sed -s "s/{{PORT}}/${PORT}/" > /etc/${PRODUCT}-license-server.conf && \
sed -i "s/\${PRODUCT}/${PRODUCT}/" /usr/local/bin/startup.sh

ENTRYPOINT [ "tini", "--" ]
CMD [ "/usr/local/bin/startup.sh" ]
EXPOSE ${PORT}
