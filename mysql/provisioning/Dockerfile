FROM alpine:3.4
RUN apk add --update mysql-client bash openssh-client gettext  && rm -rf /var/cache/apk/*

ENV MYSQL_ROOT_PASSWORD=rootthepass
ENV MYSQL_DATABASE=owncloud
ENV OWNCLOUD_DB_PASSWORD=damnpasswords
ENV STARTSCRIPT=/docker-entrypoint/load-structure-testdata.sh
ENV NAMESPACE=TEST

#create users
COPY 01-users.tmpl /templates/01-users.sql

#load scripts
COPY load-structure-testdata.sh /docker-entrypoint/

#copy default entrypoint
COPY startup.sh /docker-entrypoint/

#startup
ENTRYPOINT [ "/docker-entrypoint/startup.sh" ]