-- =============================================================================
-- ONLINE SHOPPERS INTENTION - DATA INSPECTION
-- =============================================================================

-- =============================================================================
-- SECTION 1: ROW COUNTS
-- =============================================================================

-- Total records
SELECT COUNT(*) AS total_sessions FROM sessions;

-- =============================================================================
-- SECTION 2: NULL CHECKS
-- =============================================================================

-- Check for NULLs in key columns
SELECT 
    SUM(CASE WHEN Administrative IS NULL THEN 1 ELSE 0 END) AS null_admin,
    SUM(CASE WHEN ProductRelated IS NULL THEN 1 ELSE 0 END) AS null_product,
    SUM(CASE WHEN BounceRates IS NULL THEN 1 ELSE 0 END) AS null_bounce,
    SUM(CASE WHEN Revenue IS NULL THEN 1 ELSE 0 END) AS null_revenue,
    SUM(CASE WHEN Month IS NULL THEN 1 ELSE 0 END) AS null_month,
    SUM(CASE WHEN VisitorType IS NULL THEN 1 ELSE 0 END) AS null_visitor
FROM sessions;

-- =============================================================================
-- SECTION 3: VALUE RANGES
-- =============================================================================

-- Numeric column ranges
SELECT 
    MIN(Administrative) AS min_admin,
    MAX(Administrative) AS max_admin,
    ROUND(AVG(Administrative), 1) AS avg_admin
FROM sessions;

SELECT 
    MIN(ProductRelated) AS min_product,
    MAX(ProductRelated) AS max_product,
    ROUND(AVG(ProductRelated), 1) AS avg_product
FROM sessions;

SELECT 
    MIN(BounceRates) AS min_bounce,
    MAX(BounceRates) AS max_bounce,
    ROUND(AVG(BounceRates), 4) AS avg_bounce
FROM sessions;

SELECT 
    MIN(PageValues) AS min_page_value,
    MAX(PageValues) AS max_page_value,
    ROUND(AVG(PageValues), 2) AS avg_page_value
FROM sessions;

-- =============================================================================
-- SECTION 4: CATEGORY CHECKS
-- =============================================================================

-- Month distribution
SELECT Month, COUNT(*) AS sessions
FROM sessions
GROUP BY Month
ORDER BY sessions DESC;

-- Visitor type distribution
SELECT VisitorType, COUNT(*) AS sessions
FROM sessions
GROUP BY VisitorType
ORDER BY sessions DESC;

-- Revenue (target variable) distribution
SELECT 
    Revenue,
    COUNT(*) AS sessions,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM sessions), 2) AS pct
FROM sessions
GROUP BY Revenue;

-- Weekend distribution
SELECT 
    Weekend,
    COUNT(*) AS sessions,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM sessions), 2) AS pct
FROM sessions
GROUP BY Weekend;

-- Traffic type distribution
SELECT TrafficType, COUNT(*) AS sessions
FROM sessions
GROUP BY TrafficType
ORDER BY sessions DESC;

-- Region distribution
SELECT Region, COUNT(*) AS sessions
FROM sessions
GROUP BY Region
ORDER BY sessions DESC;

-- =============================================================================
-- SECTION 5: DATA QUALITY SUMMARY
-- =============================================================================

-- Overall data quality check
SELECT 
    COUNT(*) AS total_records,
    COUNT(DISTINCT Month) AS unique_months,
    COUNT(DISTINCT VisitorType) AS visitor_types,
    COUNT(DISTINCT Region) AS regions,
    COUNT(DISTINCT TrafficType) AS traffic_types,
    ROUND(100.0 * SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_rate
FROM sessions;

-- =============================================================================
-- END
-- =============================================================================
