-- =============================================================================
-- ONLINE SHOPPERS INTENTION - ANALYSIS QUERIES
-- =============================================================================

-- =============================================================================
-- SECTION 1: OVERALL CONVERSION METRICS
-- =============================================================================

-- Overall conversion rate (16.4%)
SELECT 
    COUNT(*) AS total_sessions,
    SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) AS purchases,
    ROUND(100.0 * SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_rate
FROM sessions;

-- =============================================================================
-- SECTION 2: VISITOR TYPE ANALYSIS
-- =============================================================================

-- Conversion by visitor type (Returning = 16.5%, New = 15.9%)
SELECT 
    VisitorType,
    COUNT(*) AS sessions,
    SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) AS purchases,
    ROUND(100.0 * SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_rate
FROM sessions
GROUP BY VisitorType
ORDER BY sessions DESC;

-- Visitor type share of total sessions
SELECT 
    VisitorType,
    COUNT(*) AS sessions,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM sessions), 1) AS pct_of_traffic
FROM sessions
GROUP BY VisitorType
ORDER BY sessions DESC;

-- =============================================================================
-- SECTION 3: MONTHLY TRENDS
-- =============================================================================

-- Conversion by month
SELECT 
    Month,
    COUNT(*) AS sessions,
    SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) AS purchases,
    ROUND(100.0 * SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_rate
FROM sessions
GROUP BY Month
ORDER BY conversion_rate DESC;

-- Monthly traffic volume
SELECT 
    Month,
    COUNT(*) AS sessions,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM sessions), 1) AS pct_of_traffic
FROM sessions
GROUP BY Month
ORDER BY sessions DESC;

-- =============================================================================
-- SECTION 4: WEEKEND VS WEEKDAY
-- =============================================================================

-- Conversion by day type
SELECT 
    CASE WHEN Weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    COUNT(*) AS sessions,
    SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) AS purchases,
    ROUND(100.0 * SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_rate
FROM sessions
GROUP BY Weekend;

-- =============================================================================
-- SECTION 5: ENGAGEMENT METRICS (BUYER VS NON-BUYER)
-- =============================================================================

-- Page engagement comparison
SELECT 
    CASE WHEN Revenue = 1 THEN 'Buyer' ELSE 'Non-Buyer' END AS segment,
    COUNT(*) AS sessions,
    ROUND(AVG(ProductRelated), 1) AS avg_product_pages,
    ROUND(AVG(ProductRelated_Duration), 0) AS avg_product_time_sec,
    ROUND(AVG(BounceRates), 4) AS avg_bounce_rate,
    ROUND(AVG(ExitRates), 4) AS avg_exit_rate,
    ROUND(AVG(PageValues), 2) AS avg_page_value
FROM sessions
GROUP BY Revenue;

-- =============================================================================
-- SECTION 6: BOUNCE RATE IMPACT
-- =============================================================================

-- Conversion by bounce rate tier
SELECT 
    CASE 
        WHEN BounceRates < 0.02 THEN '1. Very Low (<2%)'
        WHEN BounceRates < 0.05 THEN '2. Low (2-5%)'
        WHEN BounceRates < 0.10 THEN '3. Medium (5-10%)'
        ELSE '4. High (>10%)'
    END AS bounce_tier,
    COUNT(*) AS sessions,
    SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) AS purchases,
    ROUND(100.0 * SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_rate
FROM sessions
GROUP BY bounce_tier
ORDER BY bounce_tier;

-- =============================================================================
-- SECTION 7: BROWSING INTENSITY
-- =============================================================================

-- Conversion by product pages viewed
SELECT 
    CASE 
        WHEN ProductRelated < 10 THEN '1. Light (<10 pages)'
        WHEN ProductRelated < 30 THEN '2. Moderate (10-30 pages)'
        WHEN ProductRelated < 50 THEN '3. Heavy (30-50 pages)'
        ELSE '4. Very Heavy (50+ pages)'
    END AS browsing_intensity,
    COUNT(*) AS sessions,
    ROUND(100.0 * SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_rate
FROM sessions
GROUP BY browsing_intensity
ORDER BY browsing_intensity;

-- =============================================================================
-- SECTION 8: TRAFFIC SOURCE ANALYSIS
-- =============================================================================

-- Top traffic types by volume and conversion
SELECT 
    TrafficType,
    COUNT(*) AS sessions,
    SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) AS purchases,
    ROUND(100.0 * SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_rate
FROM sessions
GROUP BY TrafficType
ORDER BY sessions DESC
LIMIT 10;

-- =============================================================================
-- SECTION 9: REGIONAL PERFORMANCE
-- =============================================================================

-- Conversion by region
SELECT 
    Region,
    COUNT(*) AS sessions,
    SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) AS purchases,
    ROUND(100.0 * SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_rate
FROM sessions
GROUP BY Region
ORDER BY sessions DESC;

-- Best and worst performing regions
SELECT 
    Region,
    COUNT(*) AS sessions,
    ROUND(100.0 * SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_rate
FROM sessions
GROUP BY Region
HAVING sessions >= 300
ORDER BY conversion_rate DESC;

-- =============================================================================
-- SECTION 10: PAGE VALUE ANALYSIS
-- =============================================================================

-- Conversion by page value tier
SELECT 
    CASE 
        WHEN PageValues = 0 THEN '1. Zero'
        WHEN PageValues < 10 THEN '2. Low (0-10)'
        WHEN PageValues < 50 THEN '3. Medium (10-50)'
        ELSE '4. High (50+)'
    END AS page_value_tier,
    COUNT(*) AS sessions,
    ROUND(100.0 * SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_rate
FROM sessions
GROUP BY page_value_tier
ORDER BY page_value_tier;

-- =============================================================================
-- SECTION 11: COMBINED SEGMENTS
-- =============================================================================

-- New visitors by month
SELECT 
    Month,
    VisitorType,
    COUNT(*) AS sessions,
    ROUND(100.0 * SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_rate
FROM sessions
WHERE VisitorType IN ('New_Visitor', 'Returning_Visitor')
GROUP BY Month, VisitorType
ORDER BY Month, VisitorType;

-- High-value session profile
SELECT 
    VisitorType,
    CASE WHEN Weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    COUNT(*) AS sessions,
    ROUND(100.0 * SUM(CASE WHEN Revenue = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS conversion_rate
FROM sessions
GROUP BY VisitorType, Weekend
ORDER BY conversion_rate DESC;

-- =============================================================================
-- END
-- =============================================================================
