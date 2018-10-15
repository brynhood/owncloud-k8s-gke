FROM postgres:latest

ENV POSTGRES_PASSWORD=rootthepass


#customize some settings
COPY custom.cnf /var/lib/postgresql/data/etc/postgresql.conf
COPY pg_hba.conf /var/lib/postgresql/data/etc/postgresql.conf
