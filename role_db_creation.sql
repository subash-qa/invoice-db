--create role
-------------

CREATE ROLE "ims_admin" WITH LOGIN  PASSWORD 'ims123' SUPERUSER INHERIT CREATEDB CREATEROLE REPLICATION;


--create Database
------------------

CREATE DATABASE ims_db
  WITH OWNER = "ims_admin"
       --ENCODING = 'UTF8'
       --TABLESPACE = pg_default
       --LC_COLLATE = 'en_US.utf8'
       --LC_CTYPE = 'en_US.utf8'
       CONNECTION LIMIT = 2000;
