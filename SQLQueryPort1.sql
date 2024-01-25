SELECT *
FROM CovidsDeaths
WHERE continent is not null -- not useful in my own table
ORDER BY 3, 4 

--SELECT *
--FROM CovidVaccination
--ORDER BY 3, 4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, 
total_deaths, population
FROM CovidsDeaths
ORDER BY 1, 2

-- Looking Total Cases vs Total Deaths
-- Shows the Likelihood of dying if you contract 
-- covid in your country

SELECT location, date, total_cases, total_deaths, 
(CONVERT(float, total_deaths)/
NULLIF(CONVERT(float, total_cases),0)) * 100 as 
DeathPercentage
FROM CovidsDeaths
WHERE location like '%canada%'
ORDER BY 1, 2


-- Looking at Total Cases vs Population
-- Shows what percentage of population got covid

SELECT location, date, total_cases, population,
(CONVERT(float, total_cases)/
NULLIF(CONVERT(float, population),0)) * 100 as 
PercentPopulationInfected
FROM CovidsDeaths
-- WHERE location like '%nigeria%'
ORDER BY 1, 2

-- Looking at Countries with highest infection 
-- Rate compared to Population

SELECT location, Population, MAX(total_cases) AS 
HighestInfectionCount,
MAX((CONVERT(float, total_cases))/
NULLIF(CONVERT(float, population),0)) * 100 as 
PercentPopulationInfected
FROM CovidsDeaths
-- WHERE location like '%nigeria%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC


-- Showing countries with the Highest Death Count
-- per Population

SELECT location, MAX(cast(total_deaths as int)) AS 
TotalDeathCount
FROM CovidsDeaths
-- WHERE location like '%nigeria%'
-- where continent is null
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK THINGS BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) AS 
TotalDeathCount
FROM CovidsDeaths
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Showing the continents with the highest death
-- count per population

SELECT continent, MAX(cast(total_deaths as int)) AS 
TotalDeathCount
FROM CovidsDeaths
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

SELECT date, sum(new_cases) as total_cases,
sum(new_deaths) as total_deaths, 
(CONVERT(float, sum(new_deaths))/
NULLIF(CONVERT(float, sum(new_cases)),0)) * 100 as 
DeathPercentage
FROM CovidsDeaths
-- WHERE location like '%states%'
GROUP BY date
ORDER BY 1, 2

SELECT sum(new_cases) as total_cases,
sum(new_deaths) as total_deaths, 
(CONVERT(float, sum(new_deaths))/
NULLIF(CONVERT(float, sum(new_cases)),0)) * 100 as 
DeathPercentage
FROM CovidsDeaths
-- WHERE location like '%nigeria%'
--GROUP BY date
ORDER BY 1, 2

Select *
from CovidVaccination

Select dea.continent, dea.location, dea.date,
dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as float)) OVER (Partition by 
dea.location order by dea.location, dea.date) as 
RollingPeopleVaccinated --, (RollingPeopleVaccinated/
--population)*100  THIS WON'T WORK
from CovidsDeaths dea
join CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent like '%north%'
order by 2,3

 
 -- USE CTE

 With PopVsVac (Continent, Location, Date, Population,
 New_Vaccinations, RollingPeopleVaccinated) as 
 (
 Select dea.continent, dea.location, dea.date,
dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as float)) OVER (Partition by 
dea.location order by dea.location, dea.date) as 
RollingPeopleVaccinated --, (RollingPeopleVaccinated/
--population)*100  THIS WON'T WORK
from CovidsDeaths dea
join CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent like '%north%'
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
from PopVsVac

-- TEMP TABLE

DROP TABLE IF exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


INSERT INTO #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,
dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as float)) OVER (Partition by 
dea.location order by dea.location, dea.date) as 
RollingPeopleVaccinated --, (RollingPeopleVaccinated/
--population)*100  THIS WON'T WORK
from CovidsDeaths dea
join CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent like '%north%'
order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date,
dea.population, vac.new_vaccinations, 
sum(cast(new_vaccinations as float)) OVER (Partition by 
dea.location order by dea.location, dea.date) as 
RollingPeopleVaccinated --, (RollingPeopleVaccinated/
--population)*100  THIS WON'T WORK
from CovidsDeaths dea
join CovidVaccination vac
    on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent like '%north%'
--order by 2,3

Select *
From PercentPopulationVaccinated