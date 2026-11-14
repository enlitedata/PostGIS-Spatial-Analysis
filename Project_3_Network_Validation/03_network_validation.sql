--Date:14 Nov 2026: Project 3
--1. Create Manholes Table (Points)
CREATE TABLE manholes (
	id SERIAL PRIMARY KEY,
	name VARCHAR(50),
	location GEOGRAPHY(POINT)
);

-- 2. Create Fibre Lines Table (Connecting Points)
CREATE TABLE fibre_lines (
	id SERIAL PRIMARY KEY,
	line_name VARCHAR(50),
	start_location GEOGRAPHY(POINT),
	end_location GEOGRAPHY(POINT)
);

-- 3. Insert 3 Manholes (MH-01 and MH-02 are connected, MH-03 is isolated)
INSERT INTO manholes (name, location) VALUES
('MH-01', ST_GeographyFromText('POINT(78.4000 17.4000)')),
('MH-02', ST_GeographyFromText('POINT(78.5000 17.5000)')),
('MH-03 (Unconnected)', ST_GeographyFromText('POINT(78.6000 17.6000)'));

-- 4. Insert 1 Fibre Line connecting MH-01 and MH-02
INSERT INTO fibre_lineS (line_name, start_location, end_location) VALUES
('CABLE A', ST_GeographyFromText('POINT(78.4000 17.4000)'), ST_GeographyFromText('POINT(78.5000 17.5000)'));

-- 5. THE MAGIC QUERY: Find Manholes with NO Fibre Connection
SELECT m.name AS uncconnected_manhole
FROM manholes m
WHERE NOT EXISTS (
	SELECT 1 FROM fibre_lines f
	WHERE ST_DWithin(m.location, f.start_location, 10) -- Checks if manhole is within 10m of a cable start
	   OR ST_DWithin(m.location, f.end_location, 10) -- Checks if manhole is within 10m of a cable end
);