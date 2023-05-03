--Checking imported data
SELECT *
FROM CovidDeaths
WHERE continent IS NOT NULL
ORDER BY location, date

--Selecting Data that is to be used
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY location, date

--Looking at Total Cases vs Total Deaths (Shows likelihood of you dying if you get covid in India)
SELECT location, date, total_cases, total_deaths, new_cases, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%India%'
ORDER BY location, date

--Looking at Total Cases vs Population (Shows what percentage of population got covid in India)
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM CovidDeaths
WHERE location LIKE '%India%'
ORDER BY location, date

--Looking at countries with Highest Infection Rate compared to Population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

--Showing countries with highest Death Count
SELECT location, population, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY TotalDeathCount DESC

--Showing continents with the highest death count per population
SELECT continent, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Showing global dealth percentage per day
SELECT Date, SUM(new_cases) AS TotalNewCases, SUM(CAST(new_deaths AS int)) AS TotalDeaths, (SUM(new_deaths)/SUM(new_cases))*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY DeathPercentage DESC

--Looking at total vaccination vs population
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, dea.date

--Use CTE (To look at Rolling vaccination percentage)
WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
  SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
         SUM(vac.new_vaccinations) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  FROM CovidDeaths dea
  JOIN CovidVaccinations vac
  ON dea.location=vac.location
  AND dea.date=vac.date
  WHERE dea.continent IS NOT NULL
)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPeopleVaccinatedPercent
FROM PopvsVac

--Create TEMP TABLE
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
       SUM(vac.new_vaccinations) OVER (partition BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
 
SELECT *, (RollingPoepleVaccinated/Population)*100 AS RollingVaccinationPercent
FROM #PercentPopulationVaccinated
 
--Creating View to Store Data for later visulaizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location=vac.location
AND dea.date=vac.date
WHERE dea.continent IS NOT NULL
