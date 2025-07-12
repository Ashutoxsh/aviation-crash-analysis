Select date
FROM aircraft_crashes;


SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT aircraft) AS unique_aircraft_models,
    COUNT(DISTINCT manufacturer) AS unique_manufacturers,
    COUNT(DISTINCT operator) AS unique_operators
FROM aircraft_crashes;


-- Insight:
-- Dataset contains 19,796 crash records.
-- Dataset contains Data from 01-01-1950 to 12-06-2025.
-- Includes 622 unique aircraft models, 136 distinct manufacturers, and 8,072 different operators.
-- Indicates a diverse range of aircraft and global airline operations represented in the dataset.





SELECT
    COUNT(*) FILTER (WHERE aircraft IS NULL OR aircraft = '') AS null_aircraft,
    COUNT(*) FILTER (WHERE manufacturer IS NULL OR manufacturer = '') AS null_manufacturer,
    COUNT(*) FILTER (WHERE Total_fatalities IS NULL) AS null_fatalities,
    COUNT(*) FILTER (WHERE crew_on_board IS NULL) AS null_crew,
    COUNT(*) FILTER (WHERE pax_on_board IS NULL) AS null_passengers,
    COUNT(*) FILTER (WHERE yom IS NULL) AS null_yom,
    COUNT(*) FILTER (WHERE aircraft_age IS NULL) AS null_aircraft_age
FROM aircraft_crashes;


-- Insight:
-- Verified data completeness across key fields: no missing values in 'aircraft', 'manufacturer', 'total_fatalities', 'crew_on_board', or 'pax_on_board'.
-- Notably, 'aircraft_age' contains 2362 null values, a gap caused by limitations in publicly available data from open sources.
-- This missing information should be considered when analyzing crash patterns by aircraft age.




SELECT Extract(year From date) AS year, COUNT(*) AS crash_count
FROM aircraft_crashes
GROUP BY year
ORDER BY crash_count DESC;

-- Insight:
-- The year 1951 recorded the highest number of crashes, with 491 aircraft incidents.
-- In contrast, 2022 had the lowest count, with only 98 recorded crashes.
-- This trend suggests a significant long-term decline in aviation accidents, likely due to improvements in technology, safety regulations, and training.




SELECT Extract(year From date) AS year, SUM(total_fatalities) AS total_fatalities
FROM aircraft_crashes
GROUP BY year
ORDER BY total_fatalities DESC;

-- Insight:
-- Fatalities peaked in 1972 (3,354), followed by 1985 (3,023) and 1973 (2985).
-- On the other end, 2023 saw the fewest fatalities (237), with slight increases in 2022 (358) and 2017 (404).
-- This sharp contrast highlights a long-term improvement in aviation safety over the decades.



SELECT manufacturer, COUNT(*) AS total_crashes
FROM aircraft_crashes
GROUP BY manufacturer
ORDER BY total_crashes DESC
LIMIT 10;


-- Insight:
-- Douglas aircraft had the highest number of crashes (2,546),
-- followed by Cessna (1,802) and Beechcraft (1,503). This likely reflects
-- their extensive usage over decades rather than inherently higher risk.





SELECT manufacturer, SUM(total_fatalities) AS total_fatalities
FROM aircraft_crashes
GROUP BY manufacturer
ORDER BY total_fatalities DESC
LIMIT 10;


-- Insight:
-- Total fatalities were highest in crashes involving Douglas aircraft (23,122),
-- followed by Boeing (22,336) and Lockheed (9,413).
-- Boeing's main competitor, Airbus, ranks 8th with 4,129 fatalities,
-- suggesting fewer fatal incidents historically in comparison.





SELECT manufacturer, ROUND(AVG(total_fatalities), 2) AS avg_fatalities
FROM aircraft_crashes
WHERE total_fatalities IS NOT NULL
GROUP BY manufacturer
ORDER BY avg_fatalities DESC
LIMIT 10;


-- Insight:
-- The average fatalities per crash are highest for Airbus (47.46),
-- followed by Tupolev (30.99) and Shaanxi (25.00).
-- Across all manufacturers, the overall average fatalities per crash is 6.53.
-- This suggests that while Airbus crashes are rare, they tend to be more severe.





SELECT flight_phase, COUNT(*) AS crashes
FROM aircraft_crashes
GROUP BY flight_phase
ORDER BY crashes DESC;


-- Insight:
-- Among crashes with known flight phases (21,419 total), 
-- 37.84% occurred during landing (8,104 crashes),
-- 30.23% during in-flight (6,473 crashes),
-- and 21.30% during takeoff/climb (4,561 crashes).
-- These three phases alone account for over 89% of all known-phase crashes.





SELECT flight_phase, COUNT(*) AS crashes, SUM(total_fatalities) AS fatalities
FROM aircraft_crashes
GROUP BY flight_phase
ORDER BY fatalities DESC;


-- Insight:
-- Fatalities peaked during the landing phase (descent or approach) with 8,104 crashes 
-- resulting in 50,796 fatalities. 
-- The in-flight phase recorded 6,473 crashes and 47,400 fatalities. 
-- Takeoff/climb ranked third with 4,561 crashes and 30,232 fatalities.
-- Among manufacturers, Douglas accounted for the most fatalities (23,122), 
-- followed by Boeing (22,336) and Lockheed (9,413).



SELECT 
  aircraft_age_group,
  COUNT(*) AS crash_count
FROM (
  SELECT 
    CASE 
      WHEN aircraft_age < 5 THEN '0–4 yrs'
      WHEN aircraft_age < 10 THEN '5–9 yrs'
      WHEN aircraft_age < 20 THEN '10–19 yrs'
      WHEN aircraft_age < 30 THEN '20–29 yrs'
      WHEN aircraft_age >= 30 THEN '30+ yrs'
      ELSE 'Unknown'
    END AS aircraft_age_group
  FROM aircraft_crashes
) AS age_groups
GROUP BY aircraft_age_group
ORDER BY crash_count DESC;


-- Insight:
-- Aircraft aged 10–19 years were involved in the highest number of crashes (5,156),
-- followed by those aged 20–29 years. This may reflect a peak in aircraft usage
-- during mid-life, before they are retired or heavily maintained.





SELECT country, COUNT(*) AS crash_count
FROM aircraft_crashes
GROUP BY country
ORDER BY crash_count DESC
LIMIT 10;

-- Insight:
-- The United States recorded the highest number of aircraft crashes (5,527),
-- followed by Russia (1,301), Canada (919), and Brazil (638).
-- This likely reflects a combination of high flight volume, large geographic area,
-- and historical reporting practices.





Select Country, Sum(total_fatalities) AS Fatalities
FROM aircraft_crashes
Group by country
ORDER BY Fatalities DESC;


-- Insight:
-- The United States has the highest number of fatalities (20,778),
-- followed by Russia (10,285) and Brazil in third place.
-- India ranks sixth with 3,447 fatalities.
-- These numbers likely reflect not just crash frequency but also aircraft capacity,
-- flight density, and emergency response effectiveness in each country.





SELECT *
FROM aircraft_crashes
ORDER BY total_fatalities DESC
LIMIT 10;

-- Insight:
-- The deadliest crash involved a Boeing 747-200, resulting in 520 fatalities.
-- The second most fatal accident was a Douglas DC-10 crash, which claimed 346 lives.
-- These high-fatality incidents often involved large commercial aircraft,
-- emphasizing the catastrophic potential when wide-body jets are involved.




With Most_fatal_cte AS
(SELECT *
FROM aircraft_crashes
ORDER BY total_fatalities DESC
LIMIT 10)
Select *
FROM Most_fatal_cte
Where manufacturer != 'Boeing';


-- Insight:
-- Boeing appears 6 times in the top 10 most fatal crashes,
-- making it the only manufacturer to show up repeatedly on that list.
-- This likely reflects its dominance in the commercial aviation market,
-- where higher aircraft volume increases exposure to rare but high-impact events.



SELECT *
FROM aircraft_crashes
WHERE aircraft_age != 0
ORDER BY aircraft_age DESC
LIMIT 10;

-- Insight:
-- The oldest aircraft involved in a recorded crash was 108 years old (Beechcraft 1900C Operated by Air Serv International).
-- Such outliers often involve vintage or restored aircraft used for private,
-- ceremonial, or experimental purposes rather than commercial service.





SELECT 
    (EXTRACT(YEAR FROM date)::INT / 10) * 10 AS decade,
    COUNT(*) AS crashes_per_decade
FROM aircraft_crashes
WHERE date IS NOT NULL
GROUP BY decade
ORDER BY decade;


WITH crashes_by_decade AS (
    SELECT 
        (EXTRACT(YEAR FROM date)::INT / 10) * 10 AS decade,
        COUNT(*) AS crashes_per_decade
    FROM aircraft_crashes
    WHERE date IS NOT NULL
    GROUP BY decade
)

SELECT 
    decade,
    crashes_per_decade,
    LAG(crashes_per_decade) OVER (ORDER BY decade) AS previous_decade_crashes,
    crashes_per_decade - LAG(crashes_per_decade) OVER (ORDER BY decade) AS change_in_crashes,
    ROUND(
        100.0 * (crashes_per_decade - LAG(crashes_per_decade) OVER (ORDER BY decade)) 
        / NULLIF(LAG(crashes_per_decade) OVER (ORDER BY decade), 0), 2
    ) AS percent_change
FROM crashes_by_decade
ORDER BY decade;


-- Insight:
-- 1970s marked the peak with 3510 crashes, a 22% rise from the 1960s,
-- likely due to rapid aviation expansion with less mature safety protocols.
-- Every decade after 1980 saw a consistent decline,
-- showing the impact of advancing technology and stronger regulations.
-- The 2020s recorded a massive 63% drop in crashes compared to the 2010s,
-- Crash volume has fallen over 83% since the 1970s, despite growing global air traffic,
-- proving that aviation has become significantly safer over time.







-- Creating views to simplify analysis and support later visualizations in Power BI or dashboards.


-- View: Crashes Summary by Manufacturer

CREATE OR REPLACE VIEW vw_crash_summary_by_manufacturer AS
SELECT 
    manufacturer,
    COUNT(*) AS total_crashes,
    SUM(total_fatalities) AS fatalities,
    ROUND(AVG(total_fatalities), 2) AS avg_fatalities
FROM aircraft_crashes
GROUP BY manufacturer;

SELECT * 
FROM vw_crash_summary_by_manufacturer
ORDER BY fatalities DESC;



-- View: Crashes by Year

CREATE OR REPLACE VIEW vw_crashes_by_year AS
SELECT 
    EXTRACT(YEAR FROM date) AS year,
    COUNT(*) AS total_crashes,
    SUM(total_fatalities) AS total_fatalities
FROM aircraft_crashes
GROUP BY year;

SELECT * 
FROM vw_crashes_by_year
ORDER BY year;



-- View: Crashes by Country

CREATE OR REPLACE VIEW vw_crashes_by_country AS
SELECT 
    country,
    COUNT(*) AS total_crashes,
    SUM(total_fatalities) AS fatalities
FROM aircraft_crashes
GROUP BY country;

SELECT * 
FROM vw_crashes_by_country
ORDER BY total_crashes DESC;



-- View: Top 10 Most Fatal Crashes

CREATE OR REPLACE VIEW vw_fatal_crashes AS
SELECT *
FROM aircraft_crashes
ORDER BY total_fatalities DESC
LIMIT 10;

SELECT * 
FROM vw_fatal_crashes;



-- View: Crashes by Flight Phase

CREATE OR REPLACE VIEW vw_crashes_by_flight_phase AS
SELECT 
    flight_phase,
    COUNT(*) AS total_crashes,
    SUM(total_fatalities) AS fatalities
FROM aircraft_crashes
GROUP BY flight_phase;

SELECT * 
FROM vw_crashes_by_flight_phase
ORDER BY total_crashes DESC;



-- View: Top 10 Oldest Aircraft Crashes

CREATE OR REPLACE VIEW vw_oldest_aircraft AS
SELECT *
FROM aircraft_crashes
WHERE aircraft_age IS NOT NULL AND aircraft_age > 0
ORDER BY aircraft_age DESC
LIMIT 10;

SELECT *
FROM vw_oldest_aircraft;


 
-- View: crash Decline Per Decade


CREATE OR REPLACE VIEW crash_decline_per_decade AS
WITH crashes_by_decade AS (
    SELECT 
        (EXTRACT(YEAR FROM date)::INT / 10) * 10 AS decade,
        COUNT(*) AS crashes_per_decade
    FROM aircraft_crashes
    WHERE date IS NOT NULL
    GROUP BY decade
)

SELECT 
    decade,
    crashes_per_decade,
    LAG(crashes_per_decade) OVER (ORDER BY decade) AS previous_decade_crashes,
    crashes_per_decade - LAG(crashes_per_decade) OVER (ORDER BY decade) AS change_in_crashes,
    ROUND(
        100.0 * (crashes_per_decade - LAG(crashes_per_decade) OVER (ORDER BY decade)) 
        / NULLIF(LAG(crashes_per_decade) OVER (ORDER BY decade), 0), 2
    ) AS percent_change
FROM crashes_by_decade
ORDER BY decade;


SELECT * FROM crash_decline_per_decade;

-- Exploratory Data Analysis Completed
-- Next Step: Use these views in Power BI to build the interactive dashboard
















































