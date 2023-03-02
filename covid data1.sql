select * from Covid_deaths
order by 3,4

--select * from Covidvaccinations
--order by 3,4
--select the data we are going to be using
select location, date, total_cases,new_cases,total_deaths,population from Covid_deaths
order by 1,2

--Shows likelihood of dying if you contact covid in your country
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from Covid_deaths
where location = 'India'
order by 1,2

--Looking at total cases vs Population
--what percentage of population got covid

select location, date, total_cases,population, (total_cases/population)*100 as Death_Percentage
from Covid_deaths
where location = 'India'
order by 1,2

--Looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as Highest_infection_count, max(total_cases/population)*100 as PercentpopulationInfected
from Covid_deaths
group by location,population
--where location = 'India'
order by PercentpopulationInfected desc

--Showing the countries with highesst death count per population

select location,MAX(cast(total_deaths as int)) as total_deaths 
from Covid_deaths
where continent is not null
group by location

order by total_deaths  desc

--Time stamp : 36:00

-- LET'S BREAK THINGS DOWN BY CONTINENT

select continent,MAX(cast(total_deaths as int)) as total_deaths 
from Covid_deaths
where continent is not null
group by continent

order by total_deaths  desc


--Showing the continents with the  death count per population

select continent,MAX(cast(total_deaths as int)) as total_deaths 
from Covid_deaths
where continent is not null
group by continent

order by total_deaths  desc

--GLOBAL NUMBERS

select  
date,SUM(new_cases)as newcases,SUM(cast(new_deaths as int)) as newdeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_percentage
from Covid_deaths
--where location = 'India'
where continent is not null
group by date
order by 1,2 asc

-- Total in world
select  
SUM(new_cases)as newcases,SUM(cast(new_deaths as int)) as newdeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_percentage
from Covid_deaths
--where location = 'India'
where continent is not null
--group by date
order by 1,2 asc

--Looking total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) 
as Rolling_count
from Covidvaccinations$ vac
join Covid_deaths dea
on vac.location = dea.location
and vac.date=dea.date
where dea.continent is not null
order by 2,3

--USE CTE
with PopvsVsc (Continent,Location,Date,population,new_vaccinations, Rolling_Count)
as 
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) 
as Rolling_count
from Covidvaccinations$ vac
join Covid_deaths dea
on vac.location = dea.location
and vac.date=dea.date
where dea.continent is not null
--order by 2,3
)

select *,(Rolling_Count/population)*100
from PopvsVsc
order by 2,3

--TEMP TABLE

DROP Table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population bigint,
new_vaccinations numeric,
Rolling_count numeric
)

insert into #percentpopulationvaccinated

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) 
as Rolling_count
from Covidvaccinations$ vac
join Covid_deaths dea
on vac.location = dea.location
and vac.date=dea.date
where dea.continent is not null


select *,(Rolling_Count/population)*100
from #percentpopulationvaccinated
order by 2,3

--Creating a view

create view c as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,dea.date) 
as Rolling_count
from Covidvaccinations$ vac
join Covid_deaths dea
on vac.location = dea.location
and vac.date=dea.date
where dea.continent is not null
--order by 2,3

select * from percentpopulationvaccinated