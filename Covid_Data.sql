--Checking imported data
select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

--Data Filtering
select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths which 
--Shows likelihood of you dying if you get covid India
select location, date, total_cases, total_deaths, new_cases, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got covid in India
select location, date, total_cases, new_cases, population, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
where location like '%India%'
order by 1,2

--Looking at countries with Highest Infection Rate compared to Population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectedPopulationPercentage
from PortfolioProject..CovidDeaths
group by location,population
order by InfectedPopulationPercentage desc

--Showing countries with highest Death Count
select location, population, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location, population
order by TotalDeathCount desc

--Breaking things down by continent
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS
select Date, sum(new_cases) as TotalNewCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by DeathPercentage desc

--Looking at total vaccination vs population
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccination
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3