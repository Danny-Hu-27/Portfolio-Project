-- Select Data that is going to be used

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..Covid_Deaths
WHERE continent IS NOT NULL
ORDER BY location, date

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM Covid_Deaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY location, date

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Percentage_of_Population_Infected
FROM Covid_Deaths
WHERE location LIKE '%states%' AND continent IS NOT NULL
ORDER BY location, date

-- Looking at Countries with Highest Infection Rate comapred to Population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percentage_of_Population_Infected
FROM Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY Percentage_of_Population_Infected DESC



-- Showing Continents with the highest death count per population

SELECT 
	continent, 
	MAX(CAST(total_deaths AS INT)) AS Highest_Death_Count
FROM Covid_Deaths 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Highest_Death_Count DESC


-- Global Numbers

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, (SUM(CAST(new_deaths AS INT)) / SUM(new_cases))*100 AS Death_Percentage
FROM Covid_Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date


SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_Deaths, (SUM(CAST(new_deaths AS INT)) / SUM(new_cases))*100 AS Death_Percentage
FROM Covid_Deaths
WHERE continent IS NOT NULL


-- Looking at Total Population vs Vaccinations

SELECT 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations,
	SUM(CAST(new_vaccinations AS INT)) OVER(PARTITION BY d.location) AS Total_Vacinnations_by_Countries
FROM Covid_Deaths AS d
JOIN Covid_Vaccination AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL 
ORDER BY d.location, d.date


SELECT 
	d.continent, 
	d.location, 
	d.date, 
	d.population, 
	v.new_vaccinations,
	SUM(CAST(new_vaccinations AS INT)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS Rolling_People_Vaccinated_by_Countries
FROM Covid_Deaths AS d
JOIN Covid_Vaccination AS v
	ON d.location = v.location
	AND d.date = v.date
WHERE d.continent IS NOT NULL 
ORDER BY d.location, d.date


-- Use CTE

WITH PopulationvsVaccination AS (
	SELECT 
		d.continent, 
		d.location, 
		d.date, 
		d.population, 
		v.new_vaccinations,
		SUM(CAST(new_vaccinations AS INT)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS Rolling_People_Vaccinated_by_Countries
	FROM Covid_Deaths AS d
	JOIN Covid_Vaccination AS v
		ON d.location = v.location
		AND d.date = v.date
	WHERE d.continent IS NOT NULL
)

SELECT *, (Rolling_People_Vaccinated_by_Countries/population)*100 AS Vaccination_Rate
FROM PopulationvsVaccination


-- Create View to store data for later visualisation

CREATE View Percentage_of_Population_Vaccinated AS
SELECT 
		d.continent, 
		d.location, 
		d.date, 
		d.population, 
		v.new_vaccinations,
		SUM(CAST(new_vaccinations AS INT)) OVER(PARTITION BY d.location ORDER BY d.location, d.date) AS Rolling_People_Vaccinated_by_Countries
	FROM Covid_Deaths AS d
	JOIN Covid_Vaccination AS v
		ON d.location = v.location
		AND d.date = v.date
	WHERE d.continent IS NOT NULL


