--Checking if Tables are set up as expected
Select *
FROM PortfolioProject..Covid_Deaths
where continent is not null
Order BY 3,4


--Select *
--FROM PortfolioProject..Covid_Vaccinations
--Order By 3,4

--Next, we will select data that we will be using
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..Covid_Deaths
where continent is not null
order by 1,2


--Looking at Total cases compared to total deaths
--likelyhood of contracting and dying of covid
Select Location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as Death_Percentage
From PortfolioProject..Covid_Deaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Population
--Shows percentage of population that contracted covid
Select Location, date,population, total_cases, (total_cases/population)*100 as PopulationInfectedPercentage
From PortfolioProject..Covid_Deaths
order by 1,2

--Highest infection rates compared to population
Select Location,population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PopulationInfectedPercentage
From PortfolioProject..Covid_Deaths
Group by continent, location, population
order by PopulationInfectedPercentage DESC

--Showing Countries with highest death count per population
Select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_Deaths
where continent is not null
Group by Location, continent
order by TotalDeathCount DESC


--Breaking down by location
Select location,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_Deaths
where continent is null
Group by location,continent
order by TotalDeathCount DESC

--Showing continents with highest death count per population
Select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..Covid_Deaths
where continent is not null
Group by continent
order by TotalDeathCount DESC

--Global Numbers
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..Covid_Deaths
where continent is not null
group by date
order by 1,2


-- Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location,dea.date) as Rolling_Vaccination_Count,
(Rolling_Vaccination_count/Population
from PortfolioProject..Covid_Deaths dea
join PortfolioProject.. Covid_Vaccinations vax
	on dea.location = vax.location
	and dea.date = vax.date
	where dea.continent is not null
Order BY 2,3


--USE CTE
with PopvsVax (Continent, location, date, population,new_vaccinations, Rolling_Vaccination_Count)
as
(
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location,dea.date) as Rolling_Vaccination_Count
from PortfolioProject..Covid_Deaths dea
join PortfolioProject.. Covid_Vaccinations vax
	on dea.location = vax.location
	and dea.date = vax.date
	where dea.continent is not null
--Order BY 2,3
)
Select *, (Rolling_Vaccination_Count/population)*100
From PopvsVax

-- Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_Vaccination_Count numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location,dea.date) as Rolling_Vaccination_Count
from PortfolioProject..Covid_Deaths dea
join PortfolioProject.. Covid_Vaccinations vax
	on dea.location = vax.location
	and dea.date = vax.date
	where dea.continent is not null
Select *, (Rolling_Vaccination_Count/population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as 
select dea.continent, dea.location, dea.date, dea.population, vax.new_vaccinations,
SUM(CONVERT(bigint,vax.new_vaccinations)) OVER (Partition by dea.location Order by dea.Location,dea.date) as Rolling_Vaccination_Count
from PortfolioProject..Covid_Deaths dea
join PortfolioProject.. Covid_Vaccinations vax
	on dea.location = vax.location
	and dea.date = vax.date
	where dea.continent is not null

	Select *
	From PercentPopulationVaccinated
