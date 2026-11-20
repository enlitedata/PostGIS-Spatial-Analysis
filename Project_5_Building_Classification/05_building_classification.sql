-- ============================================================================
-- Project: End-to-End Spatial ETL & Urban Building Classification (QGIS + PostGIS)
-- Location: Rajahmundry, Andhra Pradesh (EPSG:4326)
-- Description: Attribute enrichment, geodesic area calculation, QA/QC topology 
--              validation, and rule-based Commercial/Residential classification.
-- ============================================================================
SELECT * FROM buildings_db;
-- 1. Populate missing building names
UPDATE buildings_db
SET bld_name = 'Building ' || id
WHERE bld_name IS NULL;

-- 2. Calculate true geodesic surface area in square meters
ALTER TABLE buildings_db ADD COLUMN IF NOT EXISTS area_sq_m NUMERIC(10, 2);

UPDATE buildings_db
SET area_sq_m = ROUND(ST_Area(geom::geography)::numeric, 2);

-- 3. QA/QC Topology Validation (Expect 0 rows for clean data)
-- Check A: Invalid or self-intersecting polygons
SELECT id, bld_name
FROM buildings_db
WHERE ST_IsValid(geom) = false;

-- Check B: Overlapping building polygons
SELECT a.id AS building_a, b.id AS building_b
FROM buildings_db a
JOIN buildings_db b ON ST_Intersects(a.geom, b.geom)
WHERE a.id < b.id
  AND ST_Area(ST_Intersection(a.geom, b.geom)) > 0;

-- 4. Rule-based Land-Use Classification (Commercial >= 300 sq.m)
ALTER TABLE buildings_db ADD COLUMN IF NOT EXISTS building_type VARCHAR(30);

UPDATE buildings_db
SET building_type = CASE
    WHEN area_sq_m >= 300 THEN 'Commercial'
    ELSE 'Residential'
END;

-- 5. Summary Analytics Report
SELECT 
    building_type,
    COUNT(*) AS total_buildings,
    SUM(area_sq_m) AS total_area_sq_m,
    ROUND(AVG(area_sq_m), 2) AS avg_area_sq_m
FROM buildings_db
GROUP BY building_type;

-- 6. Final Dataset Inspection (Includes geom for pgAdmin Geometry Viewer)
SELECT id, bld_name, area_sq_m, building_type, geom
FROM buildings_db
ORDER BY area_sq_m DESC;

-- 7. Final Dataset Inspection
SELECT id, bld_name, area_sq_m, building_type
FROM buildings_db
ORDER BY area_sq_m DESC;