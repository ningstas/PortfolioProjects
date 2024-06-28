-- Created by Chang Yi Ning --------------------------------------
------------------------------------------------------------------
-- deaths and hospitalization data from ourworldindata.org -------
-- population (2022) and density (2021) data from worldbank.org --

-- double checking country names --
SELECT location
FROM `portfolio-427801.covid202406.deaths`
GROUP BY location
ORDER BY 1;

SELECT country
FROM `portfolio-427801.covid202406.population`
GROUP BY country
ORDER BY 1;

-- scoping to ASEAN countries + top 3 populations
-- joining data from deaths and population
SELECT 
  dea.location
  , dea.date
  , dea.new_cases
  , dea.total_cases
  , dea.new_deaths
  , dea.total_deaths
  , pop.population
FROM
  `portfolio-427801.covid202406.deaths` dea
JOIN
  `portfolio-427801.covid202406.population` pop
ON
  dea.location = pop.country
WHERE
  location IN ('Brunei', 'Cambodia', 'Indonesia', 'Laos', 'Malaysia', 'Myanmar', 'Philippines', 'Singapore', 'Thailand', 'Vietnam', 'China', 'India', 'United States')
ORDER BY 1, 2;


-- TABLE 1 --
-- Death per million per country
SELECT 
  dea.location
  , COALESCE(ROUND((MAX(dea.total_deaths)/pop.population)*1000000), 0) AS death_pm
FROM
  `portfolio-427801.covid202406.deaths` dea
JOIN
  `portfolio-427801.covid202406.population` pop
ON dea.location = pop.country
WHERE
  location IN ('Brunei', 'Cambodia', 'Indonesia', 'Laos', 'Malaysia', 'Myanmar', 'Philippines', 'Singapore', 'Thailand', 'Vietnam', 'China', 'India', 'United States')
GROUP BY dea.location, pop.population
ORDER BY 2 DESC;


-- TABLE 2 --
-- percentage of population newly infected per country
WITH deaths_pop AS (
  SELECT 
    dea.location
    , dea.date
    , dea.new_cases
    , dea.total_cases
    , dea.new_deaths
    , dea.total_deaths
    , pop.population
  FROM
    `portfolio-427801.covid202406.deaths` dea
  JOIN
    `portfolio-427801.covid202406.population` pop
  ON dea.location = pop.country
  WHERE
    location IN ('Brunei', 'Cambodia', 'Indonesia', 'Laos', 'Malaysia', 'Myanmar', 'Philippines', 'Singapore', 'Thailand', 'Vietnam', 'China', 'India', 'United States')
  ORDER BY 1, 2
)
SELECT
  location
  , date
  , COALESCE(ROUND((new_cases/population)*100, 9), 0) AS new_cases_pc
FROM deaths_pop
ORDER BY 1, 2;


-- TABLE 3 --
-- likelihood of dying if one catches covid per country
SELECT
  location
  , ROUND((MAX(total_deaths)/MAX(total_cases)*100), 9) AS likelihood_death
FROM
  `portfolio-427801.covid202406.deaths`
WHERE
  location IN ('Brunei', 'Cambodia', 'Indonesia', 'Laos', 'Malaysia', 'Myanmar', 'Philippines', 'Singapore', 'Thailand', 'Vietnam', 'China', 'India', 'United States')
GROUP BY
  location
ORDER BY 1;

-- TABLE 4 --
-- relationship of population density and total cases
SELECT
  dea.location
  , ROUND((MAX(dea.total_cases)/MAX(pop.population))*100, 9) AS total_infected_pc
  -- , MAX(dea.total_cases) AS max_total_cases
  , dst.pop_per_sqkm
FROM `portfolio-427801.covid202406.deaths` dea
JOIN `portfolio-427801.covid202406.population` pop ON dea.location = pop.country
JOIN `portfolio-427801.covid202406.density` dst ON dea.location = dst.country
-- WHERE
--   location IN ('Brunei', 'Cambodia', 'Indonesia', 'Laos', 'Malaysia', 'Myanmar', 'Philippines', 'Singapore', 'Thailand', 'Vietnam', 'China', 'India', 'United States')
GROUP BY dea.location, dst.pop_per_sqkm
ORDER BY 1;

-- TABLE 5 --
-- vaccination rate
SELECT
  dea.location
  , dea.date
  , people_fully_vaccinated
  , ROUND((people_fully_vaccinated/pop.population)*100, 9) AS vac_pc
FROM `portfolio-427801.covid202406.deaths` dea
JOIN `portfolio-427801.covid202406.population` pop ON dea.location = pop.country
JOIN `portfolio-427801.covid202406.vaccinations` vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
  dea.location IN ('Brunei', 'Cambodia', 'Indonesia', 'Laos', 'Malaysia', 'Myanmar', 'Philippines', 'Singapore', 'Thailand', 'Vietnam', 'China', 'India', 'United States')
ORDER BY 1, 2;

-- exploring hospitalization data
SELECT entity
FROM `portfolio-427801.covid202406.hospitalization`
GROUP BY entity
ORDER BY 1;

-- contains very limited number of countries

SELECT *
FROM `portfolio-427801.covid202406.hospitalization`
WHERE entity = 'Singapore' --weekly
ORDER BY date;

SELECT *
FROM `portfolio-427801.covid202406.hospitalization`
WHERE entity = 'Malaysia' --daily
ORDER BY date;

SELECT *
FROM `portfolio-427801.covid202406.hospitalization`
WHERE entity = 'United States' --daily
ORDER BY date;

-- TABLE 6 --
-- ICU rate
SELECT
  entity
  , date
  , indicator
  , value
FROM
  `portfolio-427801.covid202406.hospitalization`
WHERE
  entity IN ('Singapore', 'Malaysia', 'United States')
AND indicator IN ('Daily ICU occupancy per million', 'Weekly new ICU admissions per million')
ORDER BY 1, 2;
