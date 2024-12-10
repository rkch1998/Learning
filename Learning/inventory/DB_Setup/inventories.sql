-- Table: public.inventories

DROP TABLE IF EXISTS public.inventories;

CREATE TABLE IF NOT EXISTS public.inventories
(
    id bigserial PRIMARY KEY,
    userid int,
    inventoryname varchar,
    location character varying COLLATE pg_catalog."default",
    stamp timestamp without time zone DEFAULT (now())::timestamp without time zone,
    CONSTRAINT fk_user FOREIGN KEY (userid) REFERENCES public.users(id)
)


INSERT INTO public.inventories (id, userid, inventoryname, location, stamp)
VALUES
(1, 1, 'Warehouse A', 'New York', now()),
(2, 1, 'Warehouse B', 'Chicago', now()),
(3, 2, 'Storefront A', 'San Francisco', now()),
(4, 2, 'Storefront B', 'Los Angeles', now()),
(5, 3, 'Distribution Center', 'Houston', now()),
(6, 4, 'Online Fulfillment', 'Seattle', now());
