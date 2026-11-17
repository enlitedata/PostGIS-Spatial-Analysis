--17 Nov 2026: Project 4: Telecom Tower Coverage Analysis
--1.CREATE ZONE TABLE (Polygon)
CREATE TABLE Zones(
	id SERIAL PRIMARY KEY,
	zone_name VARCHAR(50),
	geom GEOGRAPHY(POLYGON)
	);

-- 2. Insert 2 Zones (Simple square shapes)
-- Zone A is around 78.4, 17.4. Zone B is around 78.6, 17.6.
INSERT INTO zones (zone_name, geom) VALUES 
('Zone A', ST_GeographyFromText('POLYGON((78.40 17.40, 78.40 17.50, 78.50 17.50, 78.50 17.40, 78.40 17.40))')),
('Zone B', ST_GeographyFromText('POLYGON((78.60 17.60, 78.60 17.70, 78.70 17.70, 78.70 17.60, 78.60 17.60))'));

-- 3. Create the Towers Table (Points)
CREATE TABLE Towers(
	id SERIAL PRIMARY KEY,
	tower_name VARCHAR(50),
	location GEOGRAPHY(POINT)
	);

-- 4. Insert Towers (2 in Zone A, 0 in Zone B)
INSERT INTO TOWERS (tower_name,location) VALUES
('Tower 1', ST_GeographyFromText('POINT(78.45 17.45)')),
('Tower 2', ST_GeographyFromText('POINT(78.48 17.48)'));

-- 5. Spatial Join & Aggregation: Tower Coverage Analysis
SELECT 
    z.zone_name, 
    COUNT(t.id) AS total_towers
FROM 
    zones z
LEFT JOIN 
    towers t ON ST_Intersects(z.geom, t.location)
GROUP BY 
    z.zone_name
ORDER BY 
    total_towers DESC;

SELECT * FROM towers;
SELECT * FROM zones;