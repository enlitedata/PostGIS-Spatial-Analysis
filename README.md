# Suresh Manda - Spatial Data Analysis Portfolio

Welcome to my spatial data portfolio.

Here you will find projects demonstrating my ability to process, analyze, validate, and extract insights from geospatial data using database-driven approaches (**PostgreSQL and PostGIS**) as well as end-to-end desktop-to-database workflows (**QGIS + PostGIS**).

## Projects Directory

* **[Project 1: Distance Calculator (Proximity Analysis)](./Project_1)**
  * Calculates exact geodesic distances between locations using PostGIS `ST_Distance`.
  * *Skills demonstrated: Geodesic calculations, SQL data types, numeric casting.*

* **[Project 2: Radius Search (Buffer & Proximity Query)](./Project_2_Radius_Search)**
  * Identifies spatial features falling within a specified distance threshold using `ST_DWithin`.
  * *Skills demonstrated: Spatial filtering, distance-based indexing, buffer analysis.*

* **[Project 3: Network Validation (Spatial Topology & QA/QC)](./Project_3_Network_Validation)**
  * Audits spatial network geometries to detect and resolve invalid or broken linework.
  * *Skills demonstrated: Topology validation, `ST_IsValid`, spatial data quality assurance.*

* **[Project 4: Telecom Tower Coverage Analysis](./Project_4_Coverage_Analysis)**
  * Performs spatial joins and aggregation to count telecom towers per city zone and identify coverage gaps.
  * *Skills demonstrated: Spatial joins (`ST_Intersects`), `LEFT JOIN`, `GROUP BY` spatial aggregation.*

* **[Project 5: End-to-End Spatial ETL & Urban Building Classification](./Project_5_Building_Classification)**
  * Georeferences satellite imagery and digitizes urban building footprints in QGIS, migrates them to PostGIS, validates topology, and classifies Commercial vs.       Residential structures using geodesic area.
  * *Skills demonstrated: Georeferencing (`EPSG:4326`), QGIS-to-PostGIS ETL, `ST_Area(geom::geography)`, topology QA/QC (`ST_IsValid`, `ST_Intersects`), SQL            `CASE` classification.*
