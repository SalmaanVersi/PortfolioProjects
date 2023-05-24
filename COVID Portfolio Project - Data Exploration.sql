Select *
From PortfolioProject1.[dbo].[CovidDeaths$]
where continent is not null
Order by 3,4

Select *
From PortfolioProject1.[dbo].[CovidVaccinations$]
Order by 3,4


--- Select Data that we are going to be using

Select continent, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1.[dbo].[CovidDeaths$]
Order by 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows Likelihood of Dying if you contract COVID in your country
Select continent, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1.[dbo].[CovidDeaths$]
WHERE location like '%Kingdom%'
Order by 1,2

-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid in the UK

Select continent, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject1.[dbo].[CovidDeaths$]
--WHERE location like '%Kingdom%'
Order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select continent, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject1.[dbo].[CovidDeaths$]
--WHERE location like '%Kingdom%' no.39
Group by continent, Population
Order by PercentPopulationInfected desc 

-- Showing Countries with Highest Death Count per Population

Select continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1.[dbo].[CovidDeaths$]
--WHERE location like '%Kingdom%' no.39
where continent is not null
Group by continent
Order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

-- Showing continents with the highest death count per population.

Select Continent, MAX(Cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1.[dbo].[CovidDeaths$]
--WHERE location like '%Kingdom%'
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS 

Select SUM(new_cases) as total_cases, SUM(cast(New_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject1.[dbo].[CovidDeaths$]
WHERE continent is not null
--Group by date
Order by 1,2


-- Looking at Total Population Vs Vaccinations
 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject1.[dbo].[CovidDeaths$] dea
Join  PortfolioProject1.[dbo].[CovidVaccinations$] vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
Order by 2,3

- USE CTE 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject1.[dbo].[CovidDeaths$] dea
Join  PortfolioProject1.[dbo].[CovidVaccinations$] vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent Nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject1.[dbo].[CovidDeaths$] dea
Join  PortfolioProject1.[dbo].[CovidVaccinations$] vac
On dea.location = vac.location
and dea.date = vac.date
--WHERE dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

-- Creating view to store data for later visualisations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
From PortfolioProject1.[dbo].[CovidDeaths$] dea
Join  PortfolioProject1.[dbo].[CovidVaccinations$] vac
On dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
--Order by 2,3

Select *
From PercentPopulationVaccinated