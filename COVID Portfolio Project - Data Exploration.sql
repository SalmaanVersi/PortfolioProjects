SELECT *
FROM PortfolioProject1.[dbo].[CovidDeaths$]
WHERE continent IS NOT NULL
ORDER BY 3,4

SELECT *
FROM PortfolioProject1.[dbo].[CovidVaccinations$]
ORDER BY 3,4


--- Select Data that we are going to be using

SELECT continent, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1.[dbo].[CovidDeaths$]
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of Dying if you contract COVID in your country
SELECT continent, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject1.[dbo].[CovidDeaths$]
WHERE location LIKE '%Kingdom%'
ORDER BY 1,2

-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid in the UK

SELECT continent, date, population, total_cases, (total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject1.[dbo].[CovidDeaths$]
--WHERE location LIKE '%Kingdom%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

SELECT continent, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject1.[dbo].[CovidDeaths$]
--WHERE location LIKE '%Kingdom%' no.39
GROUP BY continent, Population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population

SELECT continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1.[dbo].[CovidDeaths$]
--WHERE location LIKE '%Kingdom%' no.39
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population.

SELECT Continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1.[dbo].[CovidDeaths$]
--WHERE location like '%Kingdom%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc

-- GLOBAL NUMBERS 

SELECT SUM(new_cases) as total_cases, SUM(cast(New_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1.[dbo].[CovidDeaths$]
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2


-- Looking at Total Population Vs Vaccinations
 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject1.[dbo].[CovidDeaths$] dea
JOIN  PortfolioProject1.[dbo].[CovidVaccinations$] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (PARTITION BY dea.Location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject1.[dbo].[CovidDeaths$] dea
JOIN PortfolioProject1.[dbo].[CovidVaccinations$] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent Nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject1.[dbo].[CovidDeaths$] dea
JOIN  PortfolioProject1.[dbo].[CovidVaccinations$] vac
ON dea.location = vac.location
AND dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

-- Creating view to store data for later visualisations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject1.[dbo].[CovidDeaths$] dea
JOIN  PortfolioProject1.[dbo].[CovidVaccinations$] vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
 
SELECT *
FROM PercentPopulationVaccinated
