Select *
From dbo.CovidDeaths
Where continent is not null
Order by 3,4

Select *
From dbo.CovidVaccinations
Where continent is not null
Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From dbo.CovidDeaths
Where continent is not null
Order by 1,2

--Looking at Total Cases vs Total Deaths 
--Shows likelihood of dying if you contract covid in the Philippines

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From dbo.CovidDeaths
Where location = 'Philippines'
and continent is not null
Order by 1,2

--Looking at Total Cases vs Population
--Shows percentage of the population that contracted covid

Select location, date, total_cases, population, (total_cases/population)*100 as Percent_Population_Infected
From dbo.CovidDeaths
Where location = 'Philippines'
and continent is not null
Order by 1,2

--Looking at Countries with Highest Infection Rate compared to Population

Select location, MAX(total_cases) as Highest_Infection_Count, population, MAX((total_cases/population))*100 as Percent_Population_Infected
From dbo.CovidDeaths
--Where location = 'Philippines'
Where continent is not null
Group by location, population
Order by Percent_Population_Infected DESC

--Showing Countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as Highest_Death_Count
From dbo.CovidDeaths
--Where location = 'Philippines'
Where continent is not null
Group by location
Order by Highest_Death_Count DESC

--Breaking down by continent
--Showing the continents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as Highest_Death_Count
From dbo.CovidDeaths
--Where location = 'Philippines'
Where continent is not null
Group by continent
Order by Highest_Death_Count DESC

--Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,  SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
From dbo.CovidDeaths
--Where location = 'Philippines'
Where continent is not null
--Group by date
Order by 1,2


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--CTE

With PopsVac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (rolling_people_vaccinated/population)*100
From PopsVac

--Creating view to store data for later visualizations

Create View Percent_Population_Vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From dbo.CovidDeaths dea
Join dbo.CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3