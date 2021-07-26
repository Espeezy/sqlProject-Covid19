--Exploring DeathPercentage Globaly - Viz 1

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Covid19Deaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Exploring the total Death Count by location-Viz 2
SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM Covid19Deaths
WHERE continent is null 
and location not in ('World', 'European Union', 'International') --we need to take this locations out since it's not part of the query
GROUP BY location
ORDER BY TotalDeathCount desc

-- Countries with highest infection rate compared to the population-Viz 3
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(( total_cases/population))*100 AS PercentagePopulationInfected
FROM Covid19Deaths
--WHERE location like '%Ghana%' 
GROUP BY location, population
ORDER BY PercentagePopulationInfected desc

-- Countries with highest infection rate compared to the population-Viz 4
SELECT location, population, date, MAX(total_cases) AS HighestInfectionCount, MAX(( total_cases/population))*100 AS PercentagePopulationInfected
FROM Covid19Deaths
--WHERE location like '%Ghana%' 
GROUP BY location, population, date
ORDER BY PercentagePopulationInfected desc