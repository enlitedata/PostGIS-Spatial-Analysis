-- ============================================================================
-- Project 6: Urban Road-Network Buffer & Building Setback Compliance Analysis
-- Pipeline: Live-Basemap Georeferencing -> QGIS Digitization -> PostGIS SQL
-- Location: Rajahmundry, Andhra Pradesh (EPSG:4326)
-- ============================================================================

--Step.1: Correcting the building table names
--1. Inspecting the both tables first:
SELECT * FROM builds_p6;
SELECT * FROM roads_p6;

--2. Populating the build_name in builds_p6 and length (in meters) in roads_p6:
UPDATE builds_p6
SET build_name = 'Building' || id
WHERE build_name IS NULL;

UPDATE roads_p6
SET length = ROUND(ST_Length(geom::geography)::numeric, 2);

--3. Verifying the updates:
SELECT id, build_name FROM builds_p6 ORDER BY id;
SELECT id, length FROM roads_p6 ORDER BY id;

--Step.2: Topology QA/QC Queries
SELECT id, build_name 
FROM builds_p6 
WHERE ST_IsValid(geom) = false;

SELECT id 
FROM roads_p6 
WHERE ST_IsValid(geom) = false;

--Step 3: Calculating Each Building's Distance to Its Nearest Road Segment
SELECT 
    b.id,
    b.build_name,
    ROUND(MIN(ST_Distance(b.geom::geography, r.geom::geography))::numeric, 2) AS nearest_road_m
FROM builds_p6 b
CROSS JOIN roads_p6 r
GROUP BY b.id, b.build_name
ORDER BY nearest_road_m ASC;

--Step 4: Adding Columns & Classifying Setback Compliance (ALTER TABLE + UPDATE + CASE)
ALTER TABLE builds_p6 ADD COLUMN IF NOT EXISTS nearest_road_m NUMERIC(10, 2);
ALTER TABLE builds_p6 ADD COLUMN IF NOT EXISTS setback_status VARCHAR(40);

WITH nearest_roads AS (
    SELECT 
        b.id,
        ROUND(MIN(ST_Distance(b.geom::geography, r.geom::geography))::numeric, 2) AS min_dist_m
    FROM builds_p6 b
    CROSS JOIN roads_p6 r
    GROUP BY b.id
)
UPDATE builds_p6 b
SET 
    nearest_road_m = nr.min_dist_m,
    setback_status = CASE
        WHEN nr.min_dist_m < 15 THEN 'Encroachment (<15m)'
        WHEN nr.min_dist_m <= 30 THEN 'Setback Review (15-30m)'
        ELSE 'Compliant (>30m)'
    END
FROM nearest_roads nr
WHERE b.id = nr.id;

--Step 5: Writing the Summary Report & Final Output Queries
-- 5A: Summary Compliance Count & Average Distance
SELECT 
    setback_status,
    COUNT(*) AS building_count,
    ROUND(AVG(nearest_road_m), 2) AS avg_dist_to_road_m
FROM builds_p6
GROUP BY setback_status
ORDER BY avg_dist_to_road_m ASC;

-- 5B: Final Classified Table (Running without geom first, for CSV export,& with geom for Map Viewer)
SELECT id, build_name, nearest_road_m, setback_status
FROM builds_p6
ORDER BY nearest_road_m ASC;