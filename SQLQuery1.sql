select * from Covid_SQL_project..CovidDeaths
order by 3,4;

--select * from Covid_SQL_project..CovidVaccinations
--order by 3,4;

select Location, date, total_cases, total_deaths, population
from Covid_SQL_project..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dyning if you contact covid in your country
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Covid_SQL_project..CovidDeaths
where Location like '%states%'
order by 1,2 

--Looking at Total Cases vs Population
-- Shows what percentage of population got covid

select Location, date, total_cases, population, (total_cases/population)*100 as PercentageAffectedbyPopulation
from Covid_SQL_project..CovidDeaths
order by 1,2


-- Looking at countries with highest infection rate compared to population
select Location, Population, max(total_cases) as HighestInfectionCOunt, max((total_cases/population))*100 as PercentageAffectedbyPopulation
from Covid_SQL_project..CovidDeaths
--where Location like '%states%'
group by Location, Population
order by PercentageAffectedbyPopulation desc

--showing countries with highest death count per population

select Location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
from Covid_SQL_project..CovidDeaths
group by Location
order by TotalDeathCount desc

-- let's break thing down by continent
select continent, MAX(CAST(Total_deaths as int)) as TotalDeathCount
from Covid_SQL_project..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

-- let's break thing down by countty
select location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
from Covid_SQL_project..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc

--GLOBAL Numbers
select date, SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Covid_SQL_project..CovidDeaths
where continent is not null
group by date
order by 1,2

select  SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from Covid_SQL_project..CovidDeaths
where continent is not null
order by 1,2

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Covid_SQL_project..CovidDeaths dea
Join Covid_SQL_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Covid_SQL_project..CovidDeaths dea
Join Covid_SQL_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From Covid_SQL_project..CovidDeaths dea
Join Covid_SQL_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Covid_SQL_project..CovidDeaths dea
Join Covid_SQL_project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 