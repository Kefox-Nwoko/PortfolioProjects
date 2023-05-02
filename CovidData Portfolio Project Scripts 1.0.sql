/*
Queries used for Project in Tableau Visualization
Data last updated  @ 19 April 2023 (www.ourworldindata.org/coronavirus)
*/

--1) Global Death Percentage 

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--where location like '%Africa%'
WHERE continent is not Null
--Group by date
ORDER BY 1,2


--2) Global Death Count (By Continent)

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount --(convert(float,Max(total_deaths))/convert(float,population))*100 as PercentPoplulationinfected
FROM [Portfolio Project]..CovidDeaths
--where location like '%states%'
Where continent is not Null
Group by continent 
--ORDER BY TotalDeathCount DESC


--3) Population Infection (percentage) per country

SELECT Continent, location , population, MAX(total_cases) as HighestInfectionCount, (convert(float,Max(total_cases))/convert(float,population))*100 as PercentPoplulationinfected
FROM [Portfolio Project]..CovidDeaths
--where location like '%states%'
Where continent is not Null
Group by continent, location, Population
ORDER BY PercentPoplulationinfected DESC


--4) Percentage Population Vaccinated 

--To know how many people in a country are vaccinated by adding query eg: (RollingPeopleVaccinated/population)*100 but i can't use a created column: 
--'Invalid column name 'RolingPeopleVaccinated'. - instead I can use a CTE or a Temp Table

--USED CTE: (Ensure the # of columns in CTE = the # of columns reflected in the query (to be connected), if not error) 

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RolingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2, 3
)
Select *, (RollingPeopleVaccinated/Population)*100 as VaccinationPercentage
From PopvsVac
order by 2, 3


--5)Percentage Population (average) Infected Time Series

SELECT Location, Population, date, MAX(total_cases) as HighestInfectionCount, (convert(float,Max(total_cases))/convert(float,population))*100 as PercentPoplulationinfected
FROM [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is not Null
Group by location, Population, date
ORDER BY PercentPoplulationinfected desc
