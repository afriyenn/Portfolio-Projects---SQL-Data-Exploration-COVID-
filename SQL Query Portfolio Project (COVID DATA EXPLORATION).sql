select *
from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--select *
--from CovidVaccinations$
--order by 3,4

--SELECTING DATA THAT WE ARE GOING TO USE

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2


--LOOKING AT TOTAL CASES VS TOTAL DEATHS 
-- Shows likelihood of dying if you contract COVID in your country 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$
Where location = 'Indonesia'
order by 1,2


-- LOOKING AT TOTAL CASES VS POPULATION
-- Shows what percentage of population got covid 

select location, date, population, total_cases, (total_cases/population)*100 as PopulationPercentage
from PortfolioProject..CovidDeaths$
Where location like '%states%'
order by 1,2


-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

select location, population, MAX(total_cases) AS HighestInfectionCount, 
	Max ((total_cases/population)*100) as PercentPopulationInfected
from PortfolioProject..CovidDeaths$
where continent is not null
group by location, population
order by PercentPopulationInfected DESC


-- LET'S BREAK THINGS DOWN BY CONTINENT (HIGHEST DEATH COUNT)

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is not null
group by continent
order by TotalDeathCount DESC


-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths$
where continent is null
group by location
order by TotalDeathCount DESC


-- GLOBAL NUMBERS 

select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- GLOBAL NUMBERS WITH DATE 

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
	SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths$
where continent is not null
group by date
order by 1,2



--JOINING TABLE DEATHS AND VACCINATIONS
-- Looking at Total Population Vs. Vaccination

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3



-- USING CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
select *, (RollingPeopleVaccinated/Population)*100 as PercentageofVaccinated
from PopvsVac


-- TEMP TABLE


DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric, 
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

select *, (RollingPeopleVaccinated/Population)*100 as PercentageofVaccinated
from #PercentPopulationVaccinated




-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATION

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


select * from PercentPopulationVaccinated