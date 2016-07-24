FROM alpine:latest
MAINTAINER kellman
#
# uncomment if you want to have the shell contained
# leave and mount the directories locally to save 
# your own configuration.
#
#COPY cpdeploy /cpdeploy
#COPY root /root
RUN \
	apk -Uuv add --no-cache --update bash ca-certificates \
	tzdata dialog openssh openssl python python3 ncurses \
	nodejs curl jq tree groff less nano vim && \
   	python3 -m ensurepip && \
	rm -r /usr/lib/python*/ensurepip && \
	pip3 install --upgrade pip setuptools && \
	pip3 install awscli && \
	pip3 install aws-shell && \
	npm install -g azure-cli && \
	apk --purge -v del py-pip && \
	rm -rf /root/.cache && \
	rm -rf /tmp/* && \
	rm -rf /var/cache/apk/*
ENTRYPOINT ["/bin/bash"]
