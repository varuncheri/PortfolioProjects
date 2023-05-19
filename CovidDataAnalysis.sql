SELECT * 
FROM PortfolioProject..CovidDeaths$
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4

SELECT * 
FROM PortfolioProject..CovidVaccine$
ORDER BY 3,4

-- Select the data that we are going to use

SELECT Location,date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
ORDER BY 1,2

-- Total Cases vs Total Deaths
SELECT Location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2

-- Total Cases vs Population
SELECT Location,date, total_cases,population, (total_deaths/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
WHERE location like '%states%'
ORDER BY 1,2

--Countries with highest infectious rate
SELECT Location, MAX(total_cases) as HighestInfectionCount,population, MAX((total_cases/population)*100) as InfectionRate
FROM PortfolioProject..CovidDeaths$
GROUP BY location, population
ORDER BY InfectionRate desc	

--Countries with highest death count
SELECT Location, MAX(cast(total_deaths as int)) as HighestDeathCount,population, MAX((total_deaths/population)*100) as DeathRate
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
GROUP BY location, population
ORDER BY HighestDeathCount desc	

--Continent with highest death count
SELECT location, MAX(cast(total_deaths as int)) as HighestDeathCount
FROM PortfolioProject..CovidDeaths$
WHERE continent is null
GROUP BY location
ORDER BY HighestDeathCount desc	

-- join 2 tables
SELECT * 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccine$ vac
ON dea.location = vac.location
AND dea.date = vac.date

--Total Population vs Vaccination

SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingVaccineCount, 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccine$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3


-- Use CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, rollingvaccinecount)
AS
(
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingVaccineCount 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccine$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *, ((rollingvaccinecount/population)*100) AS VaccineCountPercent
FROM PopvsVac
ORDER BY 2,3

-- Total vaccine count by country
WITH PopvsVac (continent, location, date, population, new_vaccinations, rollingvaccinecount)
AS
(
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,
dea.date) as RollingVaccineCount 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccine$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT continent,location,MAX(rollingvaccinecount) as TotalVaccineCount, MAX(((rollingvaccinecount/population)*100)) AS TotalVaccineCountPercent
FROM PopvsVac
GROUP BY continent,location
ORDER BY 1,2

--Temporary Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingVaccineCount numeric
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingVaccineCount 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccine$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT *--,((rollingvaccinecount/population)*100) AS VaccineCountPercent
FROM #PercentPopulationVaccinated


-- Creating view to store data for later visualisations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) as RollingVaccineCount 
FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccine$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null

SELECT * FROM PercentPopulationVaccinated

SELECT DISTINCT * FROM PercentPopulationVaccinated