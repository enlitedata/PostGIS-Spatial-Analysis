SELECT 
    c.name AS customer_name,
    ROUND( (ST_Distance(c.location, w.location) / 1000)::numeric, 2 ) AS distance_in_km
FROM 
    customers c,
    warehouses w
WHERE 
    ST_DWithin(c.location, w.location, 10000) 
ORDER BY 
    distance_in_km ASC;