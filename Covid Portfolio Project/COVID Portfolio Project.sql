select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

--select *
--from PortfolioProject..CovidVaccinations;

-- select data which we are using

select location,date,total_cases,new_cases,total_deaths,population
from PortfolioProject..CovidDeaths
order by 1,2;

-- looking at total cases vs total deaths
-- shows likelyhood of dying if you get covid in your country
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'India'
order by 1,2;

-- looking at total cases vs the population
-- shows what percentage of population got covid
select location,date,population,total_cases, (total_cases/population)*100 as CovidPercentage
from PortfolioProject..CovidDeaths
--where location = 'India'
order by 1,2;

--looking at country with highest infection rate compared to population
select location,population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
from PortfolioProject..CovidDeaths
group by location,population
order by 4 desc;

--Showing countries with Highest Death Count per population
select location,population,total_deaths, (total_deaths/population)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location = 'India'
order by 4 desc;

select location,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by 2 desc;

-- break down by continent
-- this is right
--select location,max(cast(total_deaths as int)) as TotalDeathCount
--from PortfolioProject..CovidDeaths
--where continent is  null
--group by location
--order by 2 desc;

-- showing the continents with highest death count
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc;

-- Global Numbers
select sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100
as DeathPercentage
from PortfolioProject..CovidDeaths
--where location = 'India'
where continent is not null
--group by date
order by 1,2;


-- looking at total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as Rolling_People_Vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--use cte

with PopvsVac (Continent,Location,Date,Population,New_Vaccinations,Rolling_People_Vaccinated) as 
(
select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as Rolling_People_Vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *,(Rolling_People_Vaccinated/Population)*100
from PopvsVac

-- using temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
Rolling_People_Vaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as Rolling_People_Vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *,(Rolling_People_Vaccinated/Population)*100
from #PercentPopulationVaccinated


-- creating view to store data for later visualizations
create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,
vac.new_vaccinations,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,
dea.date) as Rolling_People_Vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated