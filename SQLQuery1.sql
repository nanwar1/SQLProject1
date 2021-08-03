
select * from Portfolio1..CovidDeath
order by 3,5

select * from Portfolio1..CovidVaccination
order by 3,4

--Death percentage calculation to understand the likelihood of death in Canada if infected by Covid
Select location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS PercentageOfDeath
from Portfolio1..CovidDeath
where location='Canada'
order by 1,2

--Percentage of infection calculation to understand the likelihood of being infected by Covid if residing in Canada
Select location,date, population,total_cases,(total_cases/population)*100 AS PercentageOfInfectedPopulation
from Portfolio1..CovidDeath
where location='Canada'
order by 1,2

--countries with highest percentage of population infected
Select location, population,MAX(total_cases) AS HighestCase,MAX((total_cases/population))*100 AS HighestInfectionPercentage
from Portfolio1..CovidDeath
Group by location,population
Order by HighestInfectionPercentage desc

--Highest death percentage of population calculation in countries with first letter "B"
Select location, population,MAX(total_deaths) AS HighestDeath,MAX((total_deaths/population))*100 AS HighestDeathPercentage
from Portfolio1..CovidDeath
where location like'b%'
Group by location,population
Order by HighestDeathPercentage desc

--Highest death percentage across different continents
Select continent,MAX(total_deaths) AS HighestDeath,MAX((total_deaths/population))*100 AS HighestDeathPercentage
from Portfolio1..CovidDeath
where continent is not null
Group by continent
Order by HighestDeathPercentage desc

--Total covid cases across the world on each date
Select date, sum(new_cases) AS TotalCovidCases
from Portfolio1..CovidDeath
Group by date


--Highest Total death around the world on each date
Select date,sum(cast(new_deaths as INT)) as TotalDeath
from Portfolio1..CovidDeath
Group by date
order by TotalDeath desc

--Highest death percentage  around the world on which dates--

select date,SUM(new_cases)as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as INT))/SUM(new_cases)*100 as DeathPercentage
from Portfolio1..CovidDeath
where continent is not null
Group by date
order by DeathPercentage desc


--total vaccination till that date per location
Select d.location,d.date,v.new_vaccinations,
Sum (cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date) AS TotalVacTillDate
from Portfolio1..CovidDeath D
Join Portfolio1..CovidVaccination V
on d.date=v.date
and d.location=v.location
where d.continent is not null
order by 1,2

--percentage of population vaccinated till date per location
--Used a temp table to do that
Drop table if exists #Percentpopulationvaccinated
Create table #Percentpopulationvaccinated
(location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVacTillDate numeric)
Insert into #Percentpopulationvaccinated
Select d.location,d.date,d.population,v.new_vaccinations,
Sum (cast(v.new_vaccinations as int)) over (partition by d.location order by d.location,d.date) AS TotalVacTillDate
from Portfolio1..CovidDeath D
Join Portfolio1..CovidVaccination V
on d.date=v.date
and d.location=v.location
where d.continent is not null

select *,(TotalVacTillDate/population)*100 as TotalVacPercentTillDate
from #Percentpopulationvaccinated
order by 1,2