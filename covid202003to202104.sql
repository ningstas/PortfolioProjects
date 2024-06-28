-------------------------------------------------------------------
-- Getting a sense of the data from the first table only: deaths --
-------------------------------------------------------------------

SELECT *
FROM `portfolio-427509.covid2.deaths`
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- Select data to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM `portfolio-427509.covid2.deaths`
ORDER BY 1, 2;


-- Total cases VS total deaths: likelihood of death if you catch covid in a particular country
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100,2) AS percentage_death
FROM `portfolio-427509.covid2.deaths`
WHERE location = 'Singapore'
ORDER BY 1, 2;


-- Total cases VS population: percentage of population having Covid at that point in time
SELECT location, date, total_cases, population, ROUND((total_cases/population)*100,2) AS percentage_covid
FROM `portfolio-427509.covid2.deaths`
WHERE location = 'Singapore'
ORDER BY 2 DESC;


-- Countries with highest infection rate
SELECT
 location
 , population
 , MAX(total_cases) AS max_cases
 , ROUND((max(total_cases)/population)*100,2) AS max_percentage_covid
FROM `portfolio-427509.covid2.deaths`
GROUP BY location, population
ORDER BY max_percentage_covid DESC;


-- Countries with the highest deaths
SELECT
 location
 , population
 , MAX(total_deaths) AS max_death
FROM `portfolio-427509.covid2.deaths`
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_death DESC;


-- Countries with the highest death rate
SELECT
 location
 , population
 , MAX(total_deaths) AS max_death
 , ROUND((MAX(total_deaths)/population)*100,2) AS max_percentage_death
FROM `portfolio-427509.covid2.deaths`
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_percentage_death DESC;


-- Continents with the highest death rate (the highest death count will always be on the latest date)
SELECT
 continent
 , SUM(population) AS continent_pop
 , SUM(total_deaths) AS continent_deaths
 , ROUND((SUM(total_deaths)/SUM(population))*100,2) AS percentage_death
FROM `portfolio-427509.covid2.deaths`
WHERE continent IS NOT NULL
AND date IN (SELECT MAX(date) FROM `portfolio-427509.covid2.deaths`)
GROUP BY continent
ORDER BY percentage_death DESC;


-- this method is possible because the sum is already in the dataset (where continent is null and location is entered as continent name)
SELECT
 location
 , population
 , MAX(total_deaths) AS continent_deaths
 , ROUND((MAX(total_deaths)/population)*100,2) AS percentage_death
FROM `portfolio-427509.covid2.deaths`
WHERE continent IS NULL
GROUP BY location, population
ORDER BY percentage_death DESC;


-- Global cases and deaths per day
SELECT
 date
 , SUM(new_cases) AS global_new_cases_per_day
 , SUM(new_deaths) AS global_new_deaths_per_day
 , COUNT(location) AS num_countries
 , SUM(population) AS global_population
FROM `portfolio-427509.covid2.deaths`
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date

--------------------------------------------
-- Joining tables: death and vaccinations --
--------------------------------------------
  
-- Rolling count of new vaccinations
SELECT
 dea.continent
 , dea.location
 , dea.date
 , dea.population
 , vac.new_vaccinations
 , SUM(vac.new_vaccinations)
     OVER (
       PARTITION BY dea.location  -- count will break when it reaches another location
       ORDER BY dea.location, dea.date -- ensures count is rolling and not total
       ) AS rolling_count_vac
FROM `portfolio-427509.covid2.deaths` dea
JOIN `portfolio-427509.covid2.vaccinations` vac
 ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;




-- Percentage of population vaccinated (skipped nulls)
-- CTE: for reusing the rolling count
WITH vac_count
AS (
 SELECT
   dea.continent
   , dea.location
   , dea.date
   , dea.population
   , vac.new_vaccinations
   , SUM(vac.new_vaccinations)
       OVER (
         PARTITION BY dea.location
         ORDER BY dea.location, dea.date
         ) AS rolling_count_vac
 FROM `portfolio-427509.covid2.deaths` dea
 JOIN `portfolio-427509.covid2.vaccinations` vac
   ON dea.location = vac.location
   AND dea.date = vac.date
 WHERE dea.continent IS NOT NULL
 ORDER BY 2, 3
)
SELECT
  *
 , ROUND((rolling_count_vac/population)*100, 8) AS percentage_vac
FROM vac_count
WHERE rolling_count_vac IS NOT NULL;


-- using table
DROP TABLE IF EXISTS percent_vac;
CREATE TABLE `portfolio-427509.covid2.percent_vac` (
 continent STRING
 , Location STRING
 , date DATETIME
 , population INT
 , new_vac NUMERIC
 , rolling_count_vac NUMERIC
);


INSERT INTO percent_vac -- could not test this in free BigQuery account
SELECT
 dea.continent
 , dea.location
 , dea.date
 , dea.population
 , vac.new_vaccinations
 , SUM(vac.new_vaccinations)
     OVER (
       PARTITION BY dea.location
       ORDER BY dea.location, dea.date
       ) AS rolling_count_vac
FROM `portfolio-427509.covid2.deaths` dea
JOIN `portfolio-427509.covid2.vaccinations` vac
 ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


-- using temp table
CREATE TEMP TABLE temptable AS
SELECT
 dea.continent
 , dea.location
 , dea.date
 , dea.population
 , vac.new_vaccinations
 , SUM(vac.new_vaccinations)
     OVER (
       PARTITION BY dea.location
       ORDER BY dea.location, dea.date
       ) AS rolling_count_vac
FROM `portfolio-427509.covid2.deaths` dea
JOIN `portfolio-427509.covid2.vaccinations` vac
 ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;


SELECT
  *
 , ROUND((rolling_count_vac/population)*100, 8) AS percentage_vac
FROM temptable
WHERE rolling_count_vac IS NOT NULL;


-- view to store data for viz
CREATE VIEW `portfolio-427509.covid2.percentage_of_pop_vac` AS
SELECT
 dea.continent
 , dea.location
 , dea.date
 , dea.population
 , vac.new_vaccinations
 , SUM(vac.new_vaccinations)
     OVER (
       PARTITION BY dea.location
       ORDER BY dea.location, dea.date
       ) AS rolling_count_vac
FROM `portfolio-427509.covid2.deaths` dea
JOIN `portfolio-427509.covid2.vaccinations` vac
 ON dea.location = vac.location
 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2, 3;
