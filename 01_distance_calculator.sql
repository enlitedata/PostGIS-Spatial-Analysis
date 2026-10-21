-- 1. Create the tables
CREATE TABLE warehouses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    location GEOGRAPHY(POINT)
);

CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50),
    location GEOGRAPHY(POINT)
);

-- 2. Insert a Warehouse in Hyderabad
INSERT INTO warehouses (name, location) 
VALUES ('Central Warehouse', ST_GeographyFromText('POINT(78.4867 17.3850)'));

-- 3. Insert 3 Customers at different distances
INSERT INTO customers (name, location) VALUES 
('Customer A', ST_GeographyFromText('POINT(78.4900 17.3900)')), 
('Customer B', ST_GeographyFromText('POINT(78.5000 17.4000)')), 
('Customer C', ST_GeographyFromText('POINT(78.6000 17.5000)'));

-- 4. Calculate the distance in KM
SELECT 
    c.name AS customer_name,
    ROUND( (ST_Distance(c.location, w.location) / 1000)::numeric, 2 ) AS distance_in_km
FROM 
    customers c,
    warehouses w
ORDER BY 
    distance_in_km ASC;