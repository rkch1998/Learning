-- Table: public.products

DROP TABLE IF EXISTS public.products;

CREATE TABLE IF NOT EXISTS public.products
(
    id bigserial,
    inventoryid bigint,
    productname character varying COLLATE pg_catalog."default",
    price numeric,
    quantity int,
    description character varying COLLATE pg_catalog."default",
    CONSTRAINT fk_inventory FOREIGN KEY (inventoryid) REFERENCES public.inventories(id)
)


INSERT INTO public.products (id, inventoryid, productname, price, quantity, description)
VALUES
-- Products for Inventory 1
(1, 1, 'Product A1', 10.50, 100, 'Category A product, high quality'),
(2, 1, 'Product A2', 15.00, 200, 'Popular item, bulk order available'),
(3, 1, 'Product A3', 12.75, 50, 'High demand during holidays'),
(4, 1, 'Product A4', 8.90, 300, 'Affordable and reliable'),

-- Products for Inventory 2
(5, 2, 'Product B1', 20.00, 120, 'Luxury category product'),
(6, 2, 'Product B2', 18.00, 80, 'Sustainable material product'),
(7, 2, 'Product B3', 25.00, 60, 'Premium item, limited stock'),
(8, 2, 'Product B4', 22.00, 150, 'Best seller in this region'),

-- Products for Inventory 3
(9, 3, 'Product C1', 5.99, 500, 'Discounted item, large stock'),
(10, 3, 'Product C2', 7.50, 400, 'High turnover product'),
(11, 3, 'Product C3', 6.20, 350, 'Best value for money'),
(12, 3, 'Product C4', 9.00, 200, 'Customer favorite'),

-- Products for Inventory 4
(13, 4, 'Product D1', 30.00, 100, 'Exclusive item, unique design'),
(14, 4, 'Product D2', 28.50, 150, 'Luxury item, high customer rating'),
(15, 4, 'Product D3', 35.00, 50, 'Rare product, limited availability'),
(16, 4, 'Product D4', 32.00, 90, 'Customizable options available'),

-- Products for Inventory 5
(17, 5, 'Product E1', 11.00, 200, 'Standard quality product'),
(18, 5, 'Product E2', 12.50, 300, 'Bulk order discounts available'),
(19, 5, 'Product E3', 13.75, 150, 'Special edition packaging'),
(20, 5, 'Product E4', 14.99, 250, 'Recommended by top influencers'),

-- Products for Inventory 6
(21, 6, 'Product F1', 9.50, 400, 'Budget-friendly option'),
(22, 6, 'Product F2', 8.20, 450, 'Environment-friendly product'),
(23, 6, 'Product F3', 7.75, 350, 'Top-rated by customers'),
(24, 6, 'Product F4', 6.99, 500, 'Clearance sale item');
