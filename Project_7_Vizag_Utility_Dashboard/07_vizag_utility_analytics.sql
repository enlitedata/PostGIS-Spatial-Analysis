-- ============================================================================
-- Project 7: Urban Utility Infrastructure & Zone Analytics Dashboard (Vizag)
-- Pipeline: Georeferencing -> Multi-Layer Digitization -> PostGIS SQL -> QGIS
-- Coordinate Reference System: EPSG:4326 (WGS 84)
-- ============================================================================

-- BLOCK 1: Initial Data Inspection (Verifying Polygon, LineString & Point Tables)
SELECT * FROM zones_p7;
SELECT * FROM feeders_p7;
SELECT * FROM assets_p7;

-- BLOCK 2: Topology QA/QC Validation (Expect 0 Invalid Geometries)
SELECT id FROM zones_p7 WHERE ST_IsValid(geom) = false;
SELECT id FROM feeders_p7 WHERE ST_IsValid(geom) = false;
SELECT id FROM assets_p7 WHERE ST_IsValid(geom) = false;

-- BLOCK 3: Attribute Standardization (Populating Formatted Feeder & Asset IDs)
UPDATE feeders_p7
SET feeder_nam = 'Feeder-' || LPAD(id::text, 2, '0')
WHERE feeder_nam IS NULL;

UPDATE assets_p7
SET asset_name = 'Asset-' || LPAD(id::text, 2, '0')
WHERE asset_name IS NULL;

-- BLOCK 4: Multi-Layer Spatial Join (Count Assets & Geodesic Feeder Length per Zone)
SELECT 
    z.id AS zone_id,
    z.zone_name,
    COUNT(DISTINCT a.id) AS total_assets,
    COALESCE(ROUND(SUM(DISTINCT ST_Length(ST_Intersection(f.geom, z.geom)::geography))::numeric, 2), 0) AS feeder_length_m
FROM zones_p7 z
LEFT JOIN assets_p7 a ON ST_Intersects(z.geom, a.geom)
LEFT JOIN feeders_p7 f ON ST_Intersects(z.geom, f.geom)
GROUP BY z.id, z.zone_name
ORDER BY z.id;

-- BLOCK 5: Creating Dynamic PostGIS Analytics View for QGIS & Data Plotly Dashboard
CREATE OR REPLACE VIEW vw_assets_analytics_p7 AS
SELECT 
    a.id,
    a.asset_name,
    COALESCE(z.zone_name, 'Outside Zones') AS zone_name,
    nf.feeder_nam AS nearest_feeder,
    nf.dist_m AS dist_to_feeder_m,
    CASE 
        WHEN nf.dist_m <= 50 THEN 'On-Feeder (<=50m)'
        WHEN nf.dist_m <= 150 THEN 'Near Feeder (50-150m)'
        ELSE 'Isolated (>150m)'
    END AS connection_status,
    a.geom
FROM assets_p7 a
LEFT JOIN zones_p7 z 
    ON ST_Intersects(a.geom, z.geom)
CROSS JOIN LATERAL (
    SELECT 
        f.feeder_nam,
        ROUND(ST_Distance(a.geom::geography, f.geom::geography)::numeric, 2) AS dist_m
    FROM feeders_p7 f
    ORDER BY a.geom::geography <-> f.geom::geography
    LIMIT 1
) nf;

-- BLOCK 6: Final Analytics Query (Export to CSV & Inspect Classified Assets)
SELECT id, asset_name, zone_name, nearest_feeder, dist_to_feeder_m, connection_status
FROM vw_assets_analytics_p7
ORDER BY id;