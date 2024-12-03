CREATE TABLE inventories(
id int,
product_id int,
stock_quantity int,
location varchar,
stamp timestamp DEFAULT NOW()::timestamp,
modifiedstamp timestamp
);