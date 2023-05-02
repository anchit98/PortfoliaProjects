--Checking imported data
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

--Selecting Data that is to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY location, date

--Looking at Total Cases vs Total Deaths (Shows likelihood of you dying if you get covid in India)
SELECT location, date, total_cases, total_deaths, new_cases, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%India%'
ORDER BY location, date

--Looking at Total Cases vs Population (Shows what percentage of population got covid in India)
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%India%'
ORDER BY location, date

--Looking at countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY InfectedPopulationPercentage DESC

--Showing countries with highest Death Count
SELECT location, population, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

--Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing global dealth percentage per day
SELECT Date, SUM(new_cases) AS TotalNewCases, SUM(cast(new_deaths AS int)) AS TotalDeaths, SUM(cast(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY DeathPercentage DESC

--Looking at total vaccination vs population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(cast(vac.new_vaccinations AS int)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date

--Use CTE (To look at Rolling vaccination percentage)
WITH PopvdVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
         SUM(cast(vac.new_vaccinations AS int)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  FROM PortfolioProject..CovidDeaths dea
  JOIN PortfolioProject..CovidVaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
  WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPeopleVaccinatedPercent
FROM PopvsVac

-- Create TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
  Continent nvarchar(255),
  Location nvarchar(255),
  Date datetime,
  Population numeric,
  New_vaccinations numeric,
  RollingPoepleVaccinated numeric
 )
 
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(cast(vac.new_vaccinations AS int)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
 
SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPeopleVaccinatedPercent
FROM #PercentPopulationVaccinated
 
--Creating View to Store Data for later visulaizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(cast(vac.new_vaccinations AS int)) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
