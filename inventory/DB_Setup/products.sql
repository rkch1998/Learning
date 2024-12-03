CREATE TABLE products(
id int,
product_name varchar,
price decimal,
description varchar,
stamp timestamp DEFAULT NOW()::timestamp,
modifiedstamp timestamp
);
