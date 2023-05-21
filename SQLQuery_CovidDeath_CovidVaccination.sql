/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [PortfolioProject1].[dbo].[CovidVaccinations]

  --Select *
  --from [PortfolioProject1].[dbo].[CovidDeaths]

  select location, date, total_cases, new_cases, total_deaths, population
  from [PortfolioProject1].[dbo].[CovidDeaths]
  order by 1,2

  --Looking at total cases vs total deaths
  --shows likelihood of dying if you contract covid in your country
  select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
  from [PortfolioProject1].[dbo].[CovidDeaths]
  where location like '%states%'
  order by 1,2

  --Looking at total cases vs populations
  --shows what % of population got covid
  select location, date, population, total_cases, (total_cases/population)*100 as AffectedPercentage
  from [PortfolioProject1].[dbo].[CovidDeaths]
  where location like '%states%'
  order by 1,2

  --Countries with highest infection rate compared to population
  select location, population, max(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
  from [PortfolioProject1].[dbo].[CovidDeaths]
  --where location like '%states%'
  where continent is not null
  group by location, population
  order by PercentPopulationInfected desc

  --Countries with highest death count per population
  select location, max(cast(total_deaths as int)) as HighestDeathCount
  from [PortfolioProject1].[dbo].[CovidDeaths]
  where continent is not null
  group by location
  order by HighestDeathCount desc

  --Break is done by Continent
   --showing continents with hightest death count
  select continent, max(cast(total_deaths as int)) as HighestDeathCount
  from [PortfolioProject1].[dbo].[CovidDeaths]
  where continent is not null
  group by continent
  order by HighestDeathCount desc

  --Global numbers
select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
  from [PortfolioProject1].[dbo].[CovidDeaths]
  where continent is not null
  group by date
  order by 1,2

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
  from [PortfolioProject1].[dbo].[CovidDeaths]
  where continent is not null

--joining tables 
select * from PortfolioProject1..CovidDeaths d
join PortfolioProject1..CovidVaccinations v
on d.location = v.location
and d.date = v.date

--looking at total population vs vaccinations
select d.continent, d.location, d.date, d.population, v.new_vaccinations
from PortfolioProject1..CovidDeaths d
join PortfolioProject1..CovidVaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by 1,2,3

--rolling sum
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as int)) over (PARTITION by d.location order by d.location, d.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths d
join PortfolioProject1..CovidVaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null
order by 2,3

--Use CTE
with popvsvac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as int)) over (PARTITION by d.location order by d.location, d.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths d
join PortfolioProject1..CovidVaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/Population)*100 from popvsvac

--Temp Table
Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
SUM(cast(v.new_vaccinations as int)) over (PARTITION by d.location order by d.location, d.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths d
join PortfolioProject1..CovidVaccinations v
on d.location = v.location
and d.date = v.date
where d.continent is not null

select *, (RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated

--Creating Views to store data for later visualizations
Drop view if exists PercentPopulationVaccinated

Create view PercentPopulationVaccinated as 
select d.Continent, d.Location, d.Date, d.Population, v.New_Vaccinations,
SUM(cast(v.new_vaccinations as int)) over (PARTITION by d.location order by d.location, d.date) as RollingPeopleVaccinated
from PortfolioProject1..CovidDeaths d
join PortfolioProject1..CovidVaccinations v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null

select * from PercentPopulationVaccinated


 

