/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [PortfolioProject].[dbo].[CovidVaccinations]


  SELECT *
  FROM [dbo].[CovidDeaths]

  --Select Data that we are going to be using

  --Looking at total cases vs Population
  --Shows what percentage of Population got Covid
  select location, date, population, total_cases, (total_cases/population) * 100. as DeathPct
  from [dbo].[CovidDeaths]
  where location like 'Poland'
  order by location, date desc


    --Looking at total cases vs Population
  select location, date, total_cases, total_deaths, (total_deaths/population) * 100. as DeathPct
  from [dbo].[CovidDeaths]
  where location like 'Poland'
  order by location, date desc

  --Looking at countries with Highest Infection Rate compared to population
  select  location, population, max(total_cases) as HighestInfectionCount , 
  Max(total_cases/population) * 100. as PctPopulationInfected
  from [dbo].[CovidDeaths]
  group by location, population
  order by PctPopulationInfected desc

  --Showing countris with the highest death count per population
  Select  location, population, max(total_deaths) as HighestDeathCount , 
  Max(total_deaths/population) * 100. as PctPopulationDeaths
  from [dbo].[CovidDeaths]
  where continent is not null
  group by location, population
  order by PctPopulationDeaths desc

  --Breakdown by continent
  Select location, max(total_deaths) as HighestDeathCount , 
  Max(total_deaths/population) * 100. as PctPopulationDeaths
  from [dbo].[CovidDeaths]
  where continent is null
  group by location
  order by PctPopulationDeaths desc



--GLOBAL NUMBERS

  select  date, sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths,
  sum(new_deaths)/sum(new_cases) *100. as DeathPct 
  from [dbo].[CovidDeaths]
  --where location like 'Poland'
  where continent is not null
  group by date
  order by  date desc

  --Total numbers and general percentage
  Select  sum(new_cases) as TotalCases, sum(new_deaths) as TotalDeaths,
  sum(new_deaths)/sum(new_cases) *100. as DeathPct 
  from [dbo].[CovidDeaths]
  where continent is not null


  --Look at total population vs. vaccination
  Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
  sum(convert(numeric(10,1), v.new_vaccinations)) over (Partition by d.location order by d.date) as CurVacc
  from  [dbo].[CovidDeaths] AS d
  JOIN  [dbo].[CovidVaccinations] as v
  on d.location = v.location
  and d.date = v.date
  where d.continent is not null and d.location like 'Poland'
  order by location, date desc

  --Use cte
  With PopulVsVacc 
  as
  (
    Select d.continent, d.location, d.date, d.population, v.new_vaccinations, 
  sum(convert(numeric(10,1), v.new_vaccinations)) over (Partition by d.location order by d.date) as CurVacc
  from  [dbo].[CovidDeaths] AS d
  JOIN  [dbo].[CovidVaccinations] as v
  on d.location = v.location
  and d.date = v.date
  where d.continent is not null and d.location like 'Poland'
  --order by location, date desc
  )
  Select *, CurVacc/population *100. as CurVaccLevel
  from PopulVsVacc 
  order by location, date desc

