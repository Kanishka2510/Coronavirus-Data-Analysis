/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

Select *
From covid_death
Where continent is not null;


-- Starting Query

Select country, date, total_cases, new_cases, total_deaths, population
From covid_death
Where continent is not null;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in India

Select country, date, total_cases,total_deaths, (cast (total_deaths as float)/cast (total_cases as float))*100 as DeathPercentage
From covid_death
Where country like '%India%'
and continent is not null;


-- Total Cases vs Population
-- Shows percentage of population infected with Covid19

Select country, date, Population, total_cases,  (cast (total_cases as float)/cast (population as float))*100 as Percent_Population_Infected
From covid_death;


-- Countries with Highest Infection Rate compared to country

Select country, Population, MAX(cast(total_cases as float)) as Highest_Case,  (Max(cast(total_cases as float)/cast(population as float)))*100 as Percent_Population_Infected
From covid_death
where continent is not null
Group by country, population
order by Percent_Population_Infected desc;


-- Countries with Highest Death Count per Country
create view total_death_per_country as
Select country, MAX(cast(Total_deaths as float)) as Total_Death_Count
From covid_death
Where continent is not null 
Group by country
order by Total_Death_Count desc;


-- Contintents with the highest death count per continent

Select continent, MAX(cast(Total_deaths as float)) as Total_Death_Count
From covid_death
Where continent is not null 
Group by continent
order by Total_Death_Count desc;



-- Global Numbers

Select SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, (SUM(cast(new_deaths as float))/SUM(cast(New_Cases as float)))*100 as Death_Percentage
From covid_death
where continent is not null;



-- Total Population vs Vaccinations
-- Shows Population that has received at least one Covid Vaccine

Select death.continent, death.country, death.date, death.population, vaccine.new_vaccinations
, SUM(cast(vaccine.new_vaccinations as float)) OVER (Partition by death.country Order by death.country, cast(death.Date as date)) as Rolling_People_Vaccinated
From covid_death death
Join covid_vaccine vaccine
	On death.country = vaccine.country
	and death.date = vaccine.date
where death.continent is not null;


-- Using CTE to perform Calculation in previous query

With Pop_vs_Vac (Continent, country, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select death.continent, death.country, death.date, death.population, vaccine.new_vaccinations
, SUM(Cast(vaccine.new_vaccinations as float)) OVER (Partition by death.country Order by death.country, cast (death.Date as date)) as Rolling_People_Vaccinated
From covid_death death
Join covid_vaccine vaccine
	On death.country = vaccine.country
	and death.date = vaccine.date
where death.continent is not null
)
Select *, (Rolling_People_Vaccinated/cast(Population as float))*100 as percent_people_vaccinated
From Pop_vs_Vac;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists Percent_Population_Vaccinated;
Create Temp Table Percent_Population_Vaccinated
(
Continent varchar,
Country varchar,
Date date,
Population float,
New_vaccinations float,
Rolling_People_Vaccinated float
);

Insert into Percent_Population_Vaccinated
Select death.continent, death.country, cast(death.date as date), cast (death.population as float), cast (vaccine.new_vaccinations as float)
, SUM(Cast(vaccine.new_vaccinations as float)) OVER (Partition by death.country Order by death.country, cast(death.Date as date) ) as Rolling_People_Vaccinated
From covid_death death
Join covid_vaccine vaccine
	On death.country = vaccine.country
	and death.date = vaccine.date;
	
Select *, (Rolling_People_Vaccinated/ Population)*100 as percent_population_vaccinated
From Percent_Population_Vaccinated;




-- Creating population vaccinated View

Create View Population_Vaccinated as
Select death.continent, death.country, cast(death.date as date), death.population, vaccine.new_vaccinations
, SUM(Cast(vaccine.new_vaccinations as float)) OVER (Partition by death.country Order by death.country, cast(death.Date as date)) as Rolling_People_Vaccinated
From covid_death death
Join covid_vaccine vaccine
	On death.country = vaccine.country
	and death.date = vaccine.date
where death.continent is not null;