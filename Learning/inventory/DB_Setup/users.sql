-- Table: public.users

DROP TABLE IF EXISTS public.users;

CREATE TABLE IF NOT EXISTS public.users
(
    id serial PRIMARY KEY,
    name character varying COLLATE pg_catalog."default",
    email character varying COLLATE pg_catalog."default",
    username character varying COLLATE pg_catalog."default",
    password character varying COLLATE pg_catalog."default",
    stamp timestamp without time zone DEFAULT (now())::timestamp without time zone
)


INSERT INTO public.users (id, name, username, email, password)
VALUES
(1, 'john doe', 'john_doe', 'john.doe@example.com', 'password123'),
(2, 'jane smith', 'jane_smith', 'jane.smith@example.com', 'password123'),
(3, 'mike jones', 'mike_jones', 'mike.jones@example.com', 'password123'),
(4, 'emily davis', 'emily_davis', 'emily.davis@example.com', 'password123');
