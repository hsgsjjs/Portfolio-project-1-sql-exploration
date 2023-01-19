select location,date , total_cases,new_cases, total_deaths,population
from [SQL_portfolio project]..CovidDeaths$
order by 1,2
Now total cases vs total deaths	


-- total_cases vs population
select location,date , total_cases, total_deaths,population,(total_cases/Population)*100 as affectedpeople
from [SQL_portfolio project]..CovidDeaths$
where location like 'india'
order by 1,2
--highest infection rate compared to population

select location ,population, max(total_cases)as highestinfectioncount, max((total_cases/Population))*100 as percentagepopulationinfected
from [SQL_portfolio project]..CovidDeaths$
--where location like 'india'
group by location,population
order by percentagepopulationinfected desc

-- countries with highest death count per population

select location ,max(cast(Total_deaths as int)) as totaldeathcount
from [SQL_portfolio project]..CovidDeaths$
where continent is null
group by location
order by totaldeathcount desc



--continent with highest death count
select continent ,max(cast(Total_deaths as int)) as totaldeathcount
from [SQL_portfolio project]..CovidDeaths$
where continent is  not null
group by continent
order by totaldeathcount desc

--global numbers just by date --
select date , sum(new_cases) from [SQL_portfolio project]..CovidDeaths$
where continent is not null
group by date 
order by 1,2

-- global number with death percentage --
select date , sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_death,sum(cast
(new_deaths as int))/sum(new_cases)*100 as deathpercentage from [SQL_portfolio project]..CovidDeaths$
where continent is not null
group by date 
order by 1,2

--joining both table --
select *
from [SQL_portfolio project]..CovidDeaths$ dea
join [SQL_portfolio project]..CovidDeaths$ vac
      on dea.location = vac.location
	  and dea.date = vac.date

-- total population vs total vaccinations --
select dea.continent, dea.location, dea.date
,dea.population, vac.new_vaccinations 
from [SQL_portfolio project]..CovidDeaths$ dea
join [SQL_portfolio project]..CovidVaccinations$ vac
      on dea.location = vac.location
	  and dea.date = vac.date
	  where dea.continent is not null
	  order by 2,3

-- new vaccinations per day  by location--
select dea.continent, dea.location, dea.date
,dea.population, vac.new_vaccinations ,SUM(convert(int,vac.new_vaccinations)) over 
(partition  by dea.location order by dea.location,dea.date) as rollingpeople
from [SQL_portfolio project]..CovidDeaths$ dea
join [SQL_portfolio project]..CovidVaccinations$ vac
      on dea.location = vac.location
	  and dea.date = vac.date
	  where dea.continent is not null
	  order by 2,3

--population vs  vacination (using CTE and variable in cte should be same as variable in the command and it is used to use alias
--name as a function)

--use cte
with popvsvac (continent, location ,date, population, new_vaccinations,rollingpeple)
as
(select dea.continent, dea.location, dea.date
,dea.population, vac.new_vaccinations ,SUM(convert(int,vac.new_vaccinations)) over 
(partition  by dea.location order by dea.location,dea.date) as rollingpeople
from [SQL_portfolio project]..CovidDeaths$ dea
join [SQL_portfolio project]..CovidVaccinations$ vac
      on dea.location = vac.location
	  and dea.date = vac.date
	  where dea.continent is not null
	 -- order by 2,3
	 )
select * ,(rollingpeple/population)*100
from popvsvac
-- Temp table--
create table #percentagepopulationavaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vac numeric,
rollingpeople numeric
)
insert into #percentagepopulationavaccinated
select dea.continent, dea.location, dea.date
,dea.population, vac.new_vaccinations ,SUM(convert(int,vac.new_vaccinations)) over 
(partition  by dea.location order by dea.location,dea.date) as rollingpeople
from [SQL_portfolio project]..CovidDeaths$ dea
join [SQL_portfolio project]..CovidVaccinations$ vac
      on dea.location = vac.location
	  and dea.date = vac.date
	  where dea.continent is not null
	  --order by 2,3
	 
select *,(rollingpeople/population)*100
from #percentagepopulationavaccinated


--creating a view to store data for later visulaization
create view percentagepopulationavaccinated as 
select dea.continent, dea.location, dea.date
,dea.population, vac.new_vaccinations ,SUM(convert(int,vac.new_vaccinations)) over 
(partition  by dea.location order by dea.location,dea.date) as rollingpeople
from [SQL_portfolio project]..CovidDeaths$ dea
join [SQL_portfolio project]..CovidVaccinations$ vac
      on dea.location = vac.location
	  and dea.date = vac.date
	  where dea.continent is not null
	  --order by 2,3
	 
select *
from #percentagepopulationavaccinated

-----                ------



----- tableau project queries ---



Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From [SQL_portfolio project]..CovidDeaths$
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [SQL_portfolio project]..CovidDeaths$
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From [SQL_portfolio project]..CovidDeaths$
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [SQL_portfolio project]..CovidDeaths$
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2