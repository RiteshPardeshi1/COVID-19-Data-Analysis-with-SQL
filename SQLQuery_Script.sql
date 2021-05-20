--SELECT * from 
--PortfolioProject..Covid_vaccination
--order by 3,4

SELECT * FROM 
PortfolioProject..Covid_deaths
ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population 
FROM PortfolioProject..Covid_deaths
ORDER BY 1,2

-- Looking for a Total Cases Vs Total Deaths Percentage of Each Countries

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..Covid_deaths
--WHERE location = 'India'
ORDER BY 1,2

-- Looking at Total Cases Vs Population Percentage of People Infected COVID-19

SELECT location, date, population,total_cases,(total_cases/population)*100 AS Infected_Percentage
FROM PortfolioProject..Covid_deaths
--WHERE location = 'India'
ORDER BY 1,2

-- Which Country have the highest infection rate compared to population

SELECT location,population,MAX(total_cases) AS HighestInfectionCount,
MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..Covid_deaths
--WHERE location = 'India'
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

--Showing Countries with highest death count per population

SELECT location,MAX(CAST(total_deaths as INT)) as TotalDeathCount 
FROM PortfolioProject..Covid_deaths
--WHERE location = 'India' AND
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Breaking upthings by Continents with highest deaths counts 

SELECT continent, MAX(CAST (total_deaths as INT)) AS TotalDeathCount
FROM PortfolioProject..Covid_deaths
--WHERE LOCATION = 'India' AND
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT date,SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths,
SUM(CAST(new_deaths AS int)) / SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..Covid_deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2 

SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS int)) as total_deaths,
SUM(CAST(new_deaths AS int)) / SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..Covid_deaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2 

--Looking at the Total Population VS Vaccination (INNER JOIN)

SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations	
FROM PortfolioProject..Covid_deaths dea JOIN PortfolioProject..Covid_vaccination vac
ON dea.location = vac.location AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
FROM PortfolioProject..Covid_deaths dea JOIN PortfolioProject..Covid_vaccination vac
ON dea.location = vac.location AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--USING CTE

WITH popvsvac (continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as (
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
FROM PortfolioProject..Covid_deaths dea JOIN PortfolioProject..Covid_vaccination vac
ON dea.location = vac.location AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL
)
SELECT *,(rollingpeoplevaccinated / population)*100 AS rollingpeoplevaccinated
FROM popvsvac

-- USING TEMP TABLE (Another Method)

DROP TABLE IF EXISTS #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(continent nvarchar(255)
,location nvarchar(255)
,date datetime
,population numeric
,new_vaccinations numeric
,rollingpeoplevaccinated numeric)

INSERT INTO #percentpopulationvaccinated
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
FROM PortfolioProject..Covid_deaths dea JOIN PortfolioProject..Covid_vaccination vac
ON dea.location = vac.location AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL

SELECT *,(rollingpeoplevaccinated / population)*100 AS rollingpeoplevaccinated
FROM #percentpopulationvaccinated 

--Creating View to store data for data visualization

CREATE VIEW percentpopulationvaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rollingpeoplevaccinated
FROM PortfolioProject..Covid_deaths dea JOIN PortfolioProject..Covid_vaccination vac
ON dea.location = vac.location AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL

select * from percentpopulationvaccinated