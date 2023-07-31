/**Covid 19 Data Exploration
Skill used: Jions, CTE's , Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
**/

select *
from portfolioprojects..CovidDeaths
where continent is not null
order by 3,4

select *
from portfolioprojects..CovidVaccination
order by 3,4



--Geting datas to start work with

select continent, date,total_cases, new_cases, total_deaths,population
from portfolioprojects..CovidDeaths
where continent is not null
order by 1,2


--Total Cases vs Total Death
--Shows the likelihood of dying if you contract Covid in your country

select continent,date, total_cases, total_deaths , (cast(total_deaths as float) / total_cases)*100 as Deathpercentage
from portfolioprojects..CovidDeaths 
where location like '%nigeria%'
 and continent is not null
order by 1,2


--Total Cases vs Population
--Shows the percentage of Population that  got infected with Covid


select continent,date,population, total_cases, (cast (total_cases as float) / population)*100 as PercentageofPopulationAffected
from portfolioprojects..CovidDeaths 
where continent is not null
order by 1,2


--Analyzing Continets with the Highest Infection Rate compared to population


select continent,population, max (total_cases) as HigestInfectionCount, max (cast(total_cases as float)  /population)*100 as PercentofPopulationAffected
from portfolioprojects..CovidDeaths 
where continent is not null
group by continent,population
order by 4 desc
 
 --Analyzing Continent with the Highest Death Count 

 select continent, max (total_deaths) as TotalDeathCount
from portfolioprojects..CovidDeaths 
--where location like'%nigeria%'
where continent is not null
group by continent
order by TotalDeathCount desc


--Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
--From PortfolioProject..CovidDeaths
--Where location like '%states%'
--Where continent is null 
--and location not in ('World', 'European Union', 'International')
--Group by location
--order by TotalDeathCount desc




--visualization 2

select location, sum (total_deaths) as TotalDeathCount
from portfolioprojects..CovidDeaths 
--where location like'%nigeria%'
where continent is null
and location  not in ('World', 'European Union', 'International')
Group by location
--group by continent
order by TotalDeathCount desc

--visualization 3

--Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
--From PortfolioProject..CovidDeaths
--Where location like '%states%'
--Group by Location, Population
--order by PercentPopulationInfected desc

select location,population, max (total_cases) as HigestInfectionCount, max (cast(total_cases as float)  /population)*100 as PercentofPopulationAffected
from portfolioprojects..CovidDeaths 
group by location,population
order by 4 desc

--visualization 4


--Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
--From PortfolioProject..CovidDeaths
--Where location like '%states%'
--Group by Location, Population, date
--order by PercentPopulationInfected desc


 
select location,population, date, max (total_cases) as HigestInfectionCount, max (cast(total_cases as float)  /population)*100 as PercentofPopulationAffected
from portfolioprojects..CovidDeaths 
group by location,population,date
order by 4 desc








--Analyzing Continent with the Highest Death per Count Population


 select continent, max (total_deaths) as TotalDeathCount
from portfolioprojects..CovidDeaths 
--where location like'%nigeria%'
where continent is not null
group by continent, population
order by TotalDeathCount desc



--BREAKING ANALYSIS BY CONTINENT.

--Analyzing continents with the highest death count per population


select continent, max (total_deaths) as TotalDeathCount
from portfolioprojects..CovidDeaths 
where continent is not null
group by continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

select date, sum(cast (new_cases as int)) as total_cases,sum(cast(new_deaths as int)) as total_deaths, 
(isnull(sum(cast (new_deaths as int)) /(nullif(sum(new_cases),0)),0)) *100 as deathpercentage
from portfolioprojects..CovidDeaths 
where continent is not null
group by date
order by 1,2


--Global death and death percentage

select sum(cast (new_cases as int)) as total_cases,sum(cast(new_deaths as int)) as total_deaths, 
(isnull(sum(cast (new_deaths as int)) /(nullif(sum(new_cases),0)),0)) *100 as deathpercentage
from portfolioprojects..CovidDeaths 
where continent is not null
--group by date
order by 1,2


-- Joining our two tables together (covid table and vaccination table)

select*
from portfolioprojects..CovidDeaths dea
join portfolioprojects..CovidVaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date


-- Total Population vs Vaccination
-- Shows percentage of populatin that has recieved at least one Covid Vaccine

select dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations,
sum (cast( vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date ) as rollingvaccinatedpeople
 from portfolioprojects..CovidDeaths dea
join portfolioprojects..CovidVaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null 
	 order by 2,3,4 asc



	 --Using CTE  to perform Calculation on Partition By in previou query


	 with popvsvac(continent, location, date, population, new_vaccinations ,rollingvaccinatedpeople)
	 as 
	 (select dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations,
sum (cast( vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date ) as rollingvaccinatedpeople
 from portfolioprojects..CovidDeaths dea
join portfolioprojects..CovidVaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null 
	-- order by 2,3 
	 )
	 select *, (rollingvaccinatedpeople/population)*100
	 from popvsvac


	 --Using Temp Table to perform Calculation on Partition By in previous query


	 drop table if exists #PercentPopulationVaccinated
	 create table  #PercentPopulationVaccinated
     (
	 continent nvarchar(255),
	 location nvarchar(255),
	 date datetime,
	 population numeric,
	 newvaccinations numeric,
	 rollingvaccinatedpeople numeric
	 )

	 insert into #PercentPopulationVaccinated
	 select dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations,
	 sum (cast( vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date ) as rollingvaccinatedpeople
 from portfolioprojects..CovidDeaths dea
join portfolioprojects..CovidVaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
	 where dea.continent is not null
	 
	 select * , (rollingvaccinatedpeople/population)*100
	 from #PercentPopulationVaccinated 
     


--Creating View to store data for visualizations latter,

create view PercentPopulationVaccinated as
 (select dea.continent, dea.location,  dea.date, dea.population, vac.new_vaccinations,
sum (cast( vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location,
dea.date ) as rollingvaccinatedpeople
 --,(rollingvaccinatedpeople/population)*100
 from portfolioprojects..CovidDeaths dea
join portfolioprojects..CovidVaccination vac
     on dea.location = vac.location
	 and dea.date = vac.date
where dea.continent is not null)
-- order by 2,3 
	 
	 create view continetwiththehighestcount as
 select continent, max (total_deaths) as TotalDeathCount
from portfolioprojects..CovidDeaths 
--where location like'%nigeria%'
where continent is not null
group by continent
--order by TotalDeathCount desc



create view Globaldeathanddeathpercentage as
select sum(cast (new_cases as int)) as total_cases,sum(cast(new_deaths as int)) as total_deaths, 
(isnull(sum(cast (new_deaths as int)) /(nullif(sum(new_cases),0)),0)) *100 as deathpercentage
from portfolioprojects..CovidDeaths 
where continent is not null
--group by date
--order by 1,2


create view totalcasesvstotaldeath as
select continent,date, total_cases, total_deaths , (cast(total_deaths as float) / total_cases)*100 as Deathpercentage
from portfolioprojects..CovidDeaths 
where continent is not null
--order by 1,2


