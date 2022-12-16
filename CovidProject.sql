select * 
from ProjectPortfolio..coviddeaths
where continent is not null 
ORDER BY 3,4


select * from ProjectPortfolio..covidvaccinations order by 3,4



--Update NUll Value 

select iso_code, isnull(new_deaths,0) as new_deaths_fixed, isnull(new_deaths_smoothed,0) as new_deaths_smoothed_fixed 
from projectportfolio..coviddeaths

update ProjectPortfolio..coviddeaths
set new_deaths=0
where new_deaths is null


update ProjectPortfolio..coviddeaths
set new_cases=NULL
where new_cases =0
 

 --Column Specific Analysis

select location,date, total_cases,new_cases, total_deaths,population
from ProjectPortfolio..coviddeaths order by 1,2 


--Setting of Date format

select date, Convert(varchar(20),date,103) as dated
from ProjectPortfolio..coviddeaths



--Death count of Four Asian countries  

select location, SUM(cast(total_deaths as int)) as deaths_count from ProjectPortfolio..coviddeaths
where continent='Asia'
and location IN('India', 'Pakistan','China','Bangladesh')
and continent is not null
group by location
order by deaths_count desc



--looking at total cases vs total deaths
--shows liklihood of dying if you Contract covid in country

select location,date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as deathpercentage
from ProjectPortfolio..coviddeaths 
where location = 'India'-- and location ='United States' 
and continent is not null
order by 1,2


--looking at total cases vs population
--shows percentage of population got covid

select location,date,population,total_cases,
(total_cases/population)*100 as covideffectedpercentage
from ProjectPortfolio..coviddeaths 
where continent is not null
order by 1,2


--Deaths count in particular date range

select date,continent, location,total_cases,total_deaths
from ProjectPortfolio..coviddeaths
where continent='Asia'
and location='India'
AND continent is not null
and date between '2020-02-21' AND '2020-12-23'



--Analysis of weekly hospitalised People admission in india location

select date,continent, location,weekly_hosp_admissions
from ProjectPortfolio..coviddeaths
where location='India'
AND continent is not null


select count(weekly_hosp_admissions) as week_wise_hospitalised ,location
from ProjectPortfolio..coviddeaths
where location='India'
and continent is not null
group by location

select COUNT(weekly_hosp_admissions) as weekly_hospitalised 
from ProjectPortfolio..coviddeaths


--looking at countries with higheset infection rate compared to population

select location,population,max(total_cases) as highestinfectioncount,
max((total_cases/population))*100 as covideffectedpercentage
from ProjectPortfolio..coviddeaths 
where continent is not null
group by location,population 
order by covideffectedpercentage desc


--showing countries with highest death count per population

select location,max(cast(total_deaths as int)) as totaldeathcount
from ProjectPortfolio..coviddeaths 
where continent is not null
group by location
order by totaldeathcount desc


--lets breaks things down by continent 

select continent,max(cast(total_deaths as int)) as totaldeathcount
from ProjectPortfolio..coviddeaths 
where continent is not null
group by continent
order by totaldeathcount desc


--GLOBAL NUMBERS

select sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases) *100 as deathpercentage
from ProjectPortfolio..coviddeaths
where continent is not null
--group by date
order by 1,2


--looking at total population vs vaccinations

select * from ProjectPortfolio..covidvaccinations order by 3,4

select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,sum(Cast(vac.new_vaccinations as int )) over(partition by dea.location order by dea.location,
dea.date) as peoplevaccinationed
from ProjectPortfolio..coviddeaths dea
join ProjectPortfolio..covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by dea.location



--USE CTE 

with popvsvac(continent, location,date,population, new_vaccinations,peoplevaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,sum(Convert(int,vac.new_vaccinations )) over(partition by dea.location order by dea.location,
dea.date) as peoplevaccinationed
from ProjectPortfolio..coviddeaths dea
join ProjectPortfolio..covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select *,(peoplevaccinated/population)*100  as rollingpeoplevaccinated from popvsvac

--TEMP TABLE

Drop Table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
new_vaccinations numeric,
peoplevaccinated numeric
)
insert into #percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,sum(Cast(vac.new_vaccinations as bigint )) over(partition by dea.location order by dea.location,
dea.date) as peoplevaccinationed
from ProjectPortfolio..coviddeaths dea
join ProjectPortfolio..covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null

select *,(peoplevaccinated/population)*100 as rollingpeoplevaccinated 
from #percentpopulationvaccinated


--Creating view

CREATE VIEW percentpopulationvaccinated as (
select dea.continent,dea.location,dea.date,dea.population, vac.new_vaccinations
,sum(Convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,
dea.date) as peoplevaccinationed
from ProjectPortfolio..coviddeaths dea
join ProjectPortfolio..covidvaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
)
select * from percentpopulationvaccinated












