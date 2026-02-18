use eagle;

-- Create a country dimension table for geographic-level analysis

CREATE TABLE country_map AS
SELECT 
    z.RestaurantID,
    z.CountryCode,
    c.country_name
FROM zomato_data z
LEFT JOIN country_code c
ON z.CountryCode = c.country_code;

SELECT * FROM country_map;

-- Create a Calendar Table using the Column Date
  
CREATE TABLE calendar_table AS
SELECT DISTINCT
    converted_date AS Datekey,
    YEAR(converted_date) AS Year,
    MONTH(converted_date) AS Monthno,
    MONTHNAME(converted_date) AS Monthfullname,
    CONCAT('Q', QUARTER(converted_date)) AS Quarter,
    DATE_FORMAT(converted_date, '%Y-%b') AS YearMonth,
    DAYOFWEEK(converted_date) AS Weekdayno,
    DAYNAME(converted_date) AS Weekdayname,

    CASE 
        WHEN MONTH(converted_date) >= 4 
        THEN CONCAT('FM', MONTH(converted_date) - 3)
        ELSE CONCAT('FM', MONTH(converted_date) + 9)
    END AS FinancialMonth,

    CASE 
        WHEN MONTH(converted_date) BETWEEN 4 AND 6 THEN 'FQ1'
        WHEN MONTH(converted_date) BETWEEN 7 AND 9 THEN 'FQ2'
        WHEN MONTH(converted_date) BETWEEN 10 AND 12 THEN 'FQ3'
        ELSE 'FQ4'
    END AS FinancialQuarter

FROM (
    SELECT STR_TO_DATE(`Date`, '%d-%m-%Y') AS converted_date
    FROM zomato_data
) AS sub;

SELECT * FROM calendar_table;

-- Find the Numbers of Resturants based on City and Country.

SELECT 
    z.City,
    cm.country_name,
    COUNT(z.RestaurantID) AS Total_Restaurants
FROM zomato_data z
JOIN country_map cm
    ON z.RestaurantID = cm.RestaurantID
GROUP BY z.City, cm.country_name
ORDER BY Total_Restaurants DESC;

-- Numbers of Resturants opening based on Year , Quarter , Month

SELECT 
    c.Year,
    c.Quarter,
    c.Monthno,
    c.Monthfullname,
    COUNT(z.RestaurantID) AS Total_Restaurants_Opened
FROM zomato_data z
JOIN calendar_table c
    ON STR_TO_DATE(z.`Date`, '%d-%m-%Y') = c.Datekey
GROUP BY 
    c.Year,
    c.Quarter,
    c.Monthno,
    c.Monthfullname
ORDER BY 
    c.Year,
    c.Monthno;

-- Count of Resturants based on Average Ratings

DESCRIBE zomato_data;

SELECT 
    CASE 
        WHEN Rating >= 4 THEN 'High Rating (4-5)'
        WHEN Rating >= 3 THEN 'Medium Rating (3)'
        WHEN Rating >= 2 THEN 'Low Rating (2)'
        ELSE 'Poor Rating (1)'
    END AS Rating_Category,
    COUNT(RestaurantID) AS Total_Restaurants
FROM zomato_data
GROUP BY Rating_Category
ORDER BY Total_Restaurants DESC;

-- Create buckets based on Average Price of a reasonable size and find out how many resturants falls in each bucket

DESCRIBE zomato_data;

SELECT 
    CASE 
        WHEN Average_Cost_for_two <= 500 THEN 'Low Cost (0-500)'
        WHEN Average_Cost_for_two <= 1000 THEN 'Moderate (501-1000)'
        WHEN Average_Cost_for_two <= 2000 THEN 'Premium (1001-2000)'
        ELSE 'Luxury (2000+)'
    END AS Price_Bucket,
    
    COUNT(RestaurantID) AS Total_Restaurants

FROM zomato_data
GROUP BY Price_Bucket
ORDER BY Total_Restaurants DESC;

-- Percentage of Restaurants based on "Has_Table_booking"

SELECT
    Has_Table_booking,
    COUNT(DISTINCT RestaurantID) AS restaurant_count,
    ROUND(
        COUNT(DISTINCT RestaurantID) * 100.0 
        / SUM(COUNT(DISTINCT RestaurantID)) OVER (),
        2
    ) AS percentage
FROM zomato_data
GROUP BY Has_Table_booking;

-- Percentage of Restaurants based on "Has_Online_delivery"

SELECT
    Has_Online_delivery,
    COUNT(DISTINCT RestaurantID) AS restaurant_count,
    ROUND(
        COUNT(DISTINCT RestaurantID) * 100.0 
        / SUM(COUNT(DISTINCT RestaurantID)) OVER (),
        2
    ) AS percentage
FROM zomato_data
GROUP BY Has_Online_delivery;

-- Develop Charts based on Cuisines, cities, and ratings

-- Based on Cuisines

SELECT 
    Cuisines,
    COUNT(DISTINCT RestaurantID) AS restaurant_count
FROM zomato_data
GROUP BY Cuisines
ORDER BY restaurant_count DESC
LIMIT 10;

-- Based on Cities

SELECT 
    City,
    COUNT(DISTINCT RestaurantID) AS restaurant_count
FROM zomato_data
GROUP BY City
ORDER BY restaurant_count DESC;

-- Based on Ratings

SELECT
    CASE
        WHEN Rating BETWEEN 0 AND 2 THEN '0-2 (Low)'
        WHEN Rating BETWEEN 2 AND 3 THEN '2-3 (Average)'
        WHEN Rating BETWEEN 3 AND 4 THEN '3-4 (Good)'
        ELSE '4-5 (Excellent)'
    END AS rating_category,
    COUNT(DISTINCT RestaurantID) AS restaurant_count
FROM zomato_data
GROUP BY rating_category
ORDER BY restaurant_count DESC;
















     










