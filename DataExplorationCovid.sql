select * from PortfolioProject..CovidDeaths
order by 3,4;

select * from PortfolioProject..CovidVaccinations
order by 3,4;


--Shows the likelihood of dying if you contract Covid in your country 
-- Total cases vs Total deaths 

select continent,Location, Date ,  total_cases, total_deaths , (total_deaths / total_cases) * 100 as DeathPercentage from PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
order by 1,2;



-- Total at total case vs Population 
-- Percentage of people who got infected 

select location, Date, total_cases , population , (total_cases / population) * 100 as TotalCase_Percentage from 
PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2;

select location, Date, total_cases , population , (total_cases / population) * 100 as TotalCase_Percentage from 
PortfolioProject..CovidDeaths
--where location like '%states%'

order by 1,2;



--country with maximum infection rates compared to population 

select continent,location , max(total_cases) as HighestInfectionCount, population , max((total_cases / population)) * 100 as PercentagePopulationInfected from 
PortfolioProject..CovidDeaths
group by location, population,continent
order by PercentagePopulationInfected desc;


--showing countries with highest death percentage per population

select location,population,max(total_deaths) as HighestDeathCount , max((total_deaths/population)) * 100 as PercentagePopulationOfDeath 
from PortfolioProject..CovidDeaths
group by location , population 
order by PercentagePopulationOfDeath desc ;

--showing countires with highest death count per population

select location,max(cast(total_deaths as int )) as TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc ;


--showing countires with highest death count per continent 

select location,max(cast(total_deaths as int )) as TotalDeathCount 
from PortfolioProject..CovidDeaths
where continent is not  null
group by location
order by TotalDeathCount desc ;


--continents with highest death count 

select continent , max(total_deaths / population) * 100 as HighDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
group by continent 
order by HighDeathCount desc;


--Global numbers per date 

select date, sum(new_cases) as TotalCases  , sum(cast(new_deaths as int )) as TotalDeaths , 
sum(new_cases) / sum(cast(new_deaths as int )) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date 
order by 1,2;

--Global numbers

select  sum(new_cases) as TotalCases  , sum(cast(new_deaths as int )) as TotalDeaths , 
sum(new_cases) / sum(cast(new_deaths as int )) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2;


--joining tables

select * 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
      and dea.date = vac.date;

-- total vaccination vs population 

select dea.continent,dea.location, dea.date ,dea.population, vac.new_vaccinations
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
      and dea.date = vac.date
where dea.continent is not null
order by 2,3;



--rolling over and partition by total vaccination vs population 



with PopvsVac (continent,location,date ,population,new_vaccinations,RollingPeopleVaccinated) as
(
select dea.continent,dea.location, dea.date ,dea.population, vac.new_vaccinations, 
sum(convert(int,vac.new_vaccinations)) over ( partition by dea.location order by dea.location  ) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)* 100
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
      on dea.location = vac.location
      and dea.date = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/population)* 100 as PercentPopulationVaccinated
from PopvsVac




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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 











