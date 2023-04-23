SELECT *
From [Portfolio Project]..CovidDeaths
Where continent = 'Africa'
order by 3,4

--SELECT *
--From [Portfolio Project]..CovidVaccinations
--order by 3,4

--Select the data that we are going to be using


SELECT continent, location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
Where continent = 'Africa'
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country.

--SELECT Location, date, total_cases,total_deaths, (total_deaths)/total_cases) *100 as DeathPercentage
--FROM [Portfolio Project]..CovidDeaths
--ORDER BY 1,2 (version used by Alex)


SELECT continent, Location, date, total_cases,total_deaths, (convert(float,total_deaths)/ convert(float,total_cases)) *100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--where location LIKE '%Nigeria%'
where continent ='Africa'
ORDER BY 1,2


--Looking at Total Cases vs Population
--Shows what percentage of the population got Covid

SELECT Location, date, population, total_cases, (convert(float,total_cases)/ convert(float,population)) *100 as PercentPoplulationInfected
FROM [Portfolio Project]..CovidDeaths
where location like '%states%'
And continent is not Null
ORDER BY 1,2

--Looking at countries with Highest Infection Rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount, (convert(float,Max(total_cases))/convert(float,population))*100 as PercentPoplulationinfected
FROM [Portfolio Project]..CovidDeaths
--where location like '%states%'
Where continent is not Null
Group by location, Population
ORDER BY PercentPoplulationinfected DESC

--Looking at Continents with Highest Infection Rate compared to population (for drill-down)

SELECT Continent, population, MAX(total_cases) as HighestInfectionCount, (convert(float,Max(total_cases))/convert(float,population))*100 as PercentPoplulationinfected
FROM [Portfolio Project]..CovidDeaths
--where location like '%states%'
Where continent is not Null
Group by continent, Population
ORDER BY PercentPoplulationinfected DESC

--Showing countries with Highest Death Count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount --(convert(float,Max(total_deaths))/convert(float,population))*100 as PercentPoplulationinfected
FROM [Portfolio Project]..CovidDeaths
--where location like '%states%'
Where continent is not Null
Group by continent 
ORDER BY TotalDeathCount DESC


--LET'S BREAK THIS DOWN BY CONTINENT


--Showing the continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount --(convert(float,Max(total_deaths))/convert(float,population))*100 as PercentPoplulationinfected
FROM [Portfolio Project]..CovidDeaths
--where location like '%states%'
Where continent is not Null 
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(convert(float,total_cases)/convert(float,population))*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is not Null
Group by date
Order BY 1,2

--Overall Covid Analysis as @ 19 April 2023 as recorded by WHO

SELECT SUM(new_cases) as total_cases, SUM(new_deaths ) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage 
FROM [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is not Null
--Group by date
Order BY 1,2

--Joining of CovidDeaths and CovidVaccinations tables
Select *
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccination (What is the total amount of people in the world that is vaccinated?)

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--Creating rolling count for people vaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2, 3

--POST NOTE:
--Initial query to convert to int, generated error: 'Msg 8115, Level 16, State 2, Line 128Arithmetic overflow error converting expression to data type int.'
--This error occurs when you try to store a value in an int data type that is larger than its maximum value of 2,147,483,647 or smaller than its minimum value of -2,147,483,648. This can happen when performing mathematical operations or when assigning values to variables or columns. To fix error, I used a larger data type such as bigint if the value you are trying to store is larger than the maximum value of int. , by using CONVERT function to convert the value to a different data type before storing it in the int column.

--To know how many people in a country are vaccinated by adding query eg: (RollingPeopleVaccinated/population)*100 but i can't use a created column: 
--'Invalid column name 'RolingPeopleVaccinated'. - instead I can use a CTE or a Temp Table

--USE CTE: (Ensure the # of columns in CTE = the # of columns reflected in the query (to be connected), if not error)

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
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac


--USE TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating View to store data for later visualizations
--VIEW 1

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Portfolio Project]..CovidDeaths dea
Join [Portfolio Project]..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


--order by 2, 3

--SELECT DB_NAME(), SCHEMA_NAME();

--VIEW 2
--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country.

Create View NGDeathPercentage as
SELECT Location, date, total_cases,total_deaths, (convert(float,total_deaths)/ convert(float,total_cases)) *100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
where location ='%Nigeria%'
AND continent is not Null
--ORDER BY 1,2

--VIEW 3
Create View AfricaDeathPercentage as
SELECT continent, Location, date, total_cases,total_deaths, (convert(float,total_deaths)/ convert(float,total_cases)) *100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--where location LIKE '%Nigeria%'
where continent ='Africa'
--ORDER BY 1,2

--VIEW 4

Create View WorldDeathPercentage as
SELECT SUM(new_cases) as total_cases, SUM(new_deaths ) as total_deaths, SUM(new_deaths)/SUM(new_cases)*100 as DeathPercentage 
FROM [Portfolio Project]..CovidDeaths
--where location like '%states%'
where continent is not Null
--Group by date
--Order BY 1,2

--VIEW 5
--Looking at Continents with Highest Infection Rate compared to population (for drill-down)

Create View HighestInfectionCount as
SELECT Continent, population, MAX(total_cases) as HighestInfectionCount, (convert(float,Max(total_cases))/convert(float,population))*100 as PercentPoplulationinfected
FROM [Portfolio Project]..CovidDeaths
--where location like '%states%'
Where continent is not Null
Group by continent, Population
--ORDER BY PercentPoplulationinfected DESC

--VIEW 6

--Showing countries with Highest Death Count per population

Create View HighestDeathCountCountries as
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount --(convert(float,Max(total_deaths))/convert(float,population))*100 as PercentPoplulationinfected
FROM [Portfolio Project]..CovidDeaths
--where location like '%states%'
Where continent is not Null
Group by continent 
--ORDER BY TotalDeathCount DESC
