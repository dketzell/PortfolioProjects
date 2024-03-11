SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be suing

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths

-- Alter Data type to float
ALTER TABLE dbo.coviddeaths
Alter Column Total_cases float;
ALTER TABLE dbo.coviddeaths
Alter Column Total_deaths float;

ALTER TABLE dbo.coviddeaths
Alter Column new_cases float;
ALTER TABLE dbo.coviddeaths
Alter Column new_deaths float;

-- Looking at Total cases vs Total Deaths
-- Shows likelehood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location Like '%states%'
ORDER BY 1,2


-- Looking at Total Cases vs Population
-- Shows what percentage of population gopt covid


SELECT Location, date, population, total_cases, (total_cases/population)*100 AS PercentageContractedCovid
FROM PortfolioProject..CovidDeaths
WHERE Location Like '%states%'
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population


SELECT Location, population, MAX (total_cases) As HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location Like '%states%'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY PercentPopulationInfected desc


--Showing Countries with highest Death count per Population


SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location Like '%states%'
WHERE continent is not null
GROUP BY Location, Population
ORDER BY TotalDeathCount desc


-- BREAKING DOWN BY CONTINENT


SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location Like '%states%'
WHERE continent is NOT null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION


SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location Like '%states%'
WHERE continent is NOT null
GROUP BY continent
ORDER BY TotalDeathCount desc


-- Global Numbers


SELECT date, SUM(new_cases), SUM(new_deaths)--, total_deaths, (total_deaths/total_cases)*100 AS GlobalDeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE Location Like '%states%'
where continent is not null
GROUP BY date
ORDER BY 1,2

SELECT date, SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths, SUM(New_deaths)/SUM(New_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE Location Like '%states%'
where continent is not null
GROUP BY date
ORDER BY 1,2

SELECT SUM(new_cases) AS Total_Cases, SUM(new_deaths) AS Total_Deaths, SUM(New_deaths)/SUM(New_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
-- WHERE Location Like '%states%'
where continent is not null
--Group By date
ORDER BY 1,2


-- Looking at Total Polulation vs Vaccinations


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
ORDER BY 2,3

-- Use CTE

with PopvsVac (Continent, Location, Date, Population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100 AS PercentagePopulationVaccinated
FROM PopvsVac


-- Temp Table

DROP TABLE IF exists #PercentPopulationVccinated
CREATE TABLE #PercentPopulationVccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
--ORDER BY 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100 as RollingPercentagePeopleVaccinated
FROM #PercentPopulationVccinated


-- Creating view to store data for later visualization

Create View PercentPopulationVccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations AS FLOAT)) OVER (Partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3


SELECT *
FROM PercentPopulationVccinated
