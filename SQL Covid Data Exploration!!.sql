Select *
From [SQL starter]..CovidDeaths$
Where continent is not null
Order by 3,4

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [SQL starter]..CovidDeaths$
Where location like '%states%'
Order by 1,2

Select Location, date, total_cases, Population, (total_cases/population)*100 as PercentPoulationInfected
From [SQL starter]..CovidDeaths$
--Where location like '%states%'
Order by 1,2

Select Location, MAX(total_cases)as HighestInfectionCount, Population, MAX((total_cases/population))*100 as PercentPoulationInfected
From [SQL starter]..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by Location, Population
Order by PercentPoulationInfected desc

Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [SQL starter]..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by Location
Order by TotalDeathCount desc

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [SQL starter]..CovidDeaths$
--Where location like '%states%'
Where continent is null
Group by location
Order by TotalDeathCount desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [SQL starter]..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

Select date, SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [SQL starter]..CovidDeaths$
--Where location like '%states%'
where continent is not null
group by date
Order by 1,2

Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From [SQL starter]..CovidDeaths$
--Where location like '%states%'
where continent is not null
--group by date
Order by 1,2
Select *
From [SQL starter]..CovidDeaths$ dea
Join [SQL starter]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

	-- TOTAL POP VS TOTAL VAXX
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.Date ) as RollingPplVaxxed
, (RollingPplVaxxed/population)*100
From [SQL starter]..CovidDeaths$ dea
Join [SQL starter]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE A CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPplVaxxed)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.Date ) as RollingPplVaxxed
--, (RollingPplVaxxed/population)*100
From [SQL starter]..CovidDeaths$ dea
Join [SQL starter]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPplVaxxed/Population)*100
From PopvsVac

-- USE TEMP TABLE

DROP Table if exists #PercentPopVaxxed -- This is in case you want to change things. I'm pretty sure the whole point of this is to delete the table when you're done?
Create Table #PercentPopVaxxed
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPplVaxxed numeric
)


Insert into #PercentPopVaxxed
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.Date ) as RollingPplVaxxed
--, (RollingPplVaxxed/population)*100
From [SQL starter]..CovidDeaths$ dea
Join [SQL starter]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPplVaxxed/Population)*100
From #PercentPopVaxxed

-- Creating View to Store Data for later visualizations

Create view PercentPopVaxxed as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location ORDER by dea.location, dea.Date ) as RollingPplVaxxed
--, (RollingPplVaxxed/population)*100
From [SQL starter]..CovidDeaths$ dea
Join [SQL starter]..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopVaxxed