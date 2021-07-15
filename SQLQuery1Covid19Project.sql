SELECT *
FROM Covid19Deaths
--WHERE continent is not null
ORDER BY 3, 4

SELECT *
FROM Covid19Vacination
ORDER BY 3, 4

SELECT location, date, total_cases, new_cases, new_deaths, population
FROM Covid19Deaths
ORDER BY 1, 2

/* total cases Vs total Deaths
*/
SELECT location, date, total_cases, total_deaths, (total_deaths/ total_cases)*100 AS DeathPercentage
FROM Covid19Deaths
WHERE location like '%Ghana%'
ORDER BY 1, 2

/* total cases Vs Population
shows what population have gotten covid 
*/
SELECT location, date, population, total_cases, ( total_cases/population)*100 AS Percentage_Covid_cases
FROM Covid19Deaths
--WHERE location like '%Ghana%'
ORDER BY 1, 2

/* Countries with highest infection rate
compared to the population
*/
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX(( total_cases/population))*100 AS PercentagePopInfected
FROM Covid19Deaths
WHERE location like '%Ghana%' 
and continent is not null
GROUP BY location, population
ORDER BY PercentagePopInfected desc

SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM Covid19Deaths
WHERE continent is not null 
GROUP BY location
ORDER BY TotalDeathCount desc

--Exploring the total death count by continent
SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM Covid19Deaths
WHERE continent is not null 
GROUP BY continent
ORDER BY TotalDeathCount desc

--Exploring the total Death Count by location
SELECT location, MAX(cast(Total_deaths as int)) AS TotalDeathCount
FROM Covid19Deaths
WHERE continent is null 
GROUP BY location
ORDER BY TotalDeathCount desc

--Exploring DeathPercentage Globaly
SELECT date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Covid19Deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM Covid19Deaths
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

-- Joining Vaccinations Table to CovidTable
SELECT *
FROM Covid19Deaths deaths
JOIN Covid19Vacination vaccination
    ON deaths.location = vaccination.location
	and deaths.date = vaccination.date

--Total population Vs Vaccination
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations
FROM Covid19Deaths deaths
JOIN Covid19Vacination vaccination
    ON deaths.location = vaccination.location
	and deaths.date = vaccination.date
WHERE deaths.continent is not null
ORDER BY 1,2

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations
FROM Covid19Deaths deaths
JOIN Covid19Vacination vaccination
    ON deaths.location = vaccination.location
	and deaths.date = vaccination.date
WHERE deaths.location like '%Ghana%'
ORDER BY 1,2

--Rolling count
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations
, SUM(cast(vaccination.new_vaccinations as int)) OVER (partition by deaths.location order by deaths.location, deaths.date) as RollingCount
FROM Covid19Deaths deaths
JOIN Covid19Vacination vaccination
    ON deaths.location = vaccination.location
	and deaths.date = vaccination.date
WHERE deaths.continent is not null
ORDER BY 2,3

--USE CTE 
with PopVsVac (continent, location, date, population, new_vaccinations, RollingCount)
as
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations
, SUM(cast(vaccination.new_vaccinations as int)) OVER (partition by deaths.location order by deaths.location, deaths.date) as RollingCount
FROM Covid19Deaths deaths
JOIN Covid19Vacination vaccination
    ON deaths.location = vaccination.location
	and deaths.date = vaccination.date
WHERE deaths.continent is not null
)
SELECT *, (RollingCount/population)*100 as percentageofpopvasccinated
FROM PopVsVac

--TEMP Table
DROP TABLE if exists #PopulationVaccinated

CREATE TABLE #PopulationVaccinated
(
coninent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
RollingCount numeric
)

INSERT INTO #PopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations
, SUM(cast(vaccination.new_vaccinations as int)) OVER (partition by deaths.location order by deaths.location, deaths.date) as RollingCount
FROM Covid19Deaths deaths
JOIN Covid19Vacination vaccination
    ON deaths.location = vaccination.location
	and deaths.date = vaccination.date
WHERE deaths.continent is not null

SELECT *, (RollingCount/population)*100 as percentagePopulationVasccinated
FROM #PopulationVaccinated

--Creating View for visualization

create view PopulationVaccinated as
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccination.new_vaccinations
, SUM(cast(vaccination.new_vaccinations as int)) OVER (partition by deaths.location order by deaths.location, deaths.date) as RollingCount
FROM Covid19Deaths deaths
JOIN Covid19Vacination vaccination
    ON deaths.location = vaccination.location
	and deaths.date = vaccination.date
WHERE deaths.continent is not null