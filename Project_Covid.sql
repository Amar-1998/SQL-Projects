select * from CovidDeaths
where location like 'india'


select * from CovidVaccinations


-- Total Cases vs Total Deaths

select date, location, total_cases, total_deaths,
round((total_deaths/total_cases)*100,2) as Death_percent
from CovidDeaths
where location like 'india' and continent is not null
order by location , date 


-- Total Cases vs Population

select date, location, total_cases, population,
round((total_cases/population)*100,2) as Case_percent
from CovidDeaths
where location like 'india' and continent is not null
order by location , date 

-- Countries with highest infection rate compared to population

select location, population, max (total_cases) as max_cases,
max (round((total_cases/population)*100,2)) as Case_percent
from CovidDeaths
--where location like 'india'
where continent is not null
group by location , population
order by Case_percent desc

-- Countries with highest Deaths compared to population

select location,population, max(cast(total_deaths as int) ) as max_deaths,
max(round((total_deaths/population)*100,2)) as deathrate_by_population
from CovidDeaths
--where location like 'india'
where continent is not null
group by location , population
order by max_deaths desc

-- Country with highest Deathrate compared to population

select location, max(population) as Total_Population,sum(cast(new_deaths as int) ) as Total_Deaths,
round((sum(cast(new_deaths as int) )/max(population))*100,2) as deathrate_by_population
from CovidDeaths
--where location like 'india'
where continent is not null 
group by location
order by Total_Deaths desc 

-- Continent with highest Death count

select continent, max(population) as Total_Population,sum(cast(new_deaths as int) ) as Total_Deaths,
round((sum(cast(new_deaths as int) )/max(population))*100,2) as deathrate_by_population
from CovidDeaths
--where location like 'india'
where continent is not null
group by continent
order by Total_Deaths desc 


--select max(population),location from CovidDeaths
--where location not like 'world' and continent is null
--group by location

-- Continent with highest Deathrate compared to population

select continent, max(population)as totalpopulation,
max(cast(total_deaths as int)) totaldeaths,
max(round((total_deaths/population)*100,2)) as deathrate_by_population from CovidDeaths
where continent is not null
group by continent
order by deathrate_by_population desc

-- Global Numbers

select date,SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths 
,round(SUM(cast(new_deaths as int))/SUM(new_cases)*100,2) as Death_Percent
from CovidDeaths
where continent is not null -- and date = '2020-06-03 00:00:00.000'
group by date
order by date 

select SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths 
,round(SUM(cast(new_deaths as int))/SUM(new_cases)*100,2) as Death_Percent
from CovidDeaths
where continent is not null -- and date = '2020-06-03 00:00:00.000'
--group by date
--order by date 


-- Total Population Vs Population Vaccinated

select D.location,MAX(D.population)as Total_Population, SUM(cast(V.new_vaccinations as int)) as Total_vaccination 
,round(SUM(cast(V.new_vaccinations as int))/MAX(D.population)*100,2) as Vaccination_Percent
from CovidDeaths as D
inner join CovidVaccinations as V
on D.location = V.location and D.date = V.date
where D.continent is not null --and D.location like 'india'
group by   D.location
order by D.location

-- Running Total of Vaccination by Locations and Date (Total Population Vs Population Vaccinated)

select D.continent,D.location,D.date,D.population, V.new_vaccinations,
SUM(cast(V.new_vaccinations as int)) over (partition by D.location order by D.location,D.date) as Running_totalvaccinations
from CovidDeaths as D
inner join CovidVaccinations as V
on D.location = V.location and D.date = V.date
where D.continent is not null
group by D.continent,D.date,v.new_vaccinations, D.location,D.population
--order by D.location


-- CTE - % of Running Total Vaccination by Locations and Date (Total Population Vs Population Vaccinated)

with popvac (continent,location,date,population, new_vaccinations,Running_totalvaccinations)
as 
(
select D.continent,D.location,D.date,D.population, V.new_vaccinations,
SUM(cast(V.new_vaccinations as int)) over (partition by D.location order by D.location,D.date) as Running_totalvaccinations
from CovidDeaths as D
inner join CovidVaccinations as V
on D.location = V.location and D.date = V.date
where D.continent is not null
group by D.continent,D.date,v.new_vaccinations, D.location,D.population
--order by D.location
)
select *,round((Running_totalvaccinations/population)*100,2) as vac_per
from popvac

select location,population,new_vaccinations,
round((Running_totalvaccinations/population)*100,2) as vac_per
from popvac


-- Temp Table - % of Running Total Vaccination by Locations and Date (Total Population Vs Population Vaccinated)

drop table if exists #percent_population_vaccinated
create table #percent_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Running_totalvaccinations numeric
)

insert into #percent_population_vaccinated 
select D.continent,D.location,D.date,D.population, V.new_vaccinations,
SUM(cast(V.new_vaccinations as int)) over (partition by D.location order by D.location,D.date) as Running_totalvaccinations
from CovidDeaths as D
inner join CovidVaccinations as V
on D.location = V.location and D.date = V.date
--where D.continent is not null
group by D.continent,D.date,v.new_vaccinations, D.location,D.population
--order by D.location

select *,round((Running_totalvaccinations/population)*100,2) as vac_per
from #percent_population_vaccinated


-- View to store data

create view percent_population_vaccinated as

select D.continent,D.location,D.date,D.population, V.new_vaccinations,
SUM(cast(V.new_vaccinations as int)) over (partition by D.location order by D.location,D.date) as Running_totalvaccinations
from CovidDeaths as D
inner join CovidVaccinations as V
on D.location = V.location and D.date = V.date
--where D.continent is not null
group by D.continent,D.date,v.new_vaccinations, D.location,D.population
--order by D.location

select * from percent_population_vaccinated















