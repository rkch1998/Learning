CREATE TABLE users(
id int,
name varchar,
username varchar,
password varchar,
email varchar,
stamp timestamp DEFAULT NOW()::timestamp,
modifiedstamp timestamp
);