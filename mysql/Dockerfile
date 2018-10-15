FROM mysql:5

ENV MYSQL_ROOT_PASSWORD=rootthepass
ENV MYSQL_DATABASE=owncloud
ENV MYSQL_RW_PASSWORD=damnpasswords



#customize some settings
COPY custom.cnf /etc/mysql/mysql.conf.d/
