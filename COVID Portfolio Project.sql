SELECT *
FROM CovidDeaths
--WHERE location LIKE '%slovenia%'
ORDER BY 3,4
;

--SELECT *
--FROM CovidVax
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM CovidDeaths
ORDER BY 1,2
;


--Total Cases VS Total Deaths
-- Shows likelihood of dying if you contract covid in a country

SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    ((total_deaths * 1.0) / total_cases) * 100 AS DeathPercentage
FROM CovidDeaths
WHERE location LIKE '%nigeria%'
ORDER BY location, date(date)
;
-- (* 1.0) to force floating-point division

-- Shows what percentage of population infected with Covid

SELECT 
	Location, 
	date, 
	Population, 
	total_cases,  
	((total_cases * 1.0) / population) * 100 AS PercentPopulationInfected
FROM CovidDeaths
--Where location like '%italy%'
ORDER BY location, date(date)
;


-- Countries with Highest Infection Rate compared to Population

SELECT 
	Location, 
	Population, 
	MAX(total_cases) as HighestInfectionCount,  
	Max((total_cases * 1.0 / population)) * 100 AS PercentPopulationInfected
FROM CovidDeaths
--Where location like '%states%'
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC
;


-- Countries with Highest Death Count per Population

SELECT 
	Location, 
	MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL 
	AND Location NOT IN (
      'World',
      'Europe',
      'North America',
      'European Union',
      'South America',
      'Asia',
      'Africa'
	)
GROUP BY Location
ORDER BY TotalDeathCount DESC
;


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT 
	continent, 
	MAX(CAST(Total_deaths AS INT)) AS TotalDeathCount
FROM CovidDeaths
--Where location like '%states%'
WHERE continent IS NOT NULL 
  AND TRIM(continent) NOT IN ('', 'NULL')
GROUP BY continent
ORDER BY TotalDeathCount DESC
;

--SELECT 
--	continent,
--	location
--FROM CovidDeaths
--;


-- GLOBAL NUMBERS

SELECT 
	SUM(new_cases) AS total_cases, 
	SUM(CAST(new_deaths AS INT)) AS total_deaths, 
	SUM(CAST(new_deaths AS INT)) / SUM(New_Cases) * 100 AS DeathPercentage
FROM CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent IS NOT NULL 
--GROUP BY date
ORDER BY 1,2
;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT 
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CAST(IFNULL(vac.new_vaccinations, 0) AS INTEGER)) 
        OVER (PARTITION BY dea.location ORDER BY (dea.date)) AS RollingPeopleVaccinated,
    (CAST(SUM(CAST(IFNULL(vac.new_vaccinations, 0) AS INTEGER)) 
        OVER (PARTITION BY dea.location ORDER BY date(dea.date)) AS REAL) / dea.population) * 100 
        AS PercentVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY dea.location, date(dea.date)
;

--SELECT *
--FROM CovidVaccinations
--ORDER BY new_vaccinations DESC;


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac AS (
    SELECT 
        dea.continent AS Continent,
        dea.location AS Location,
        dea.date AS Date,
        dea.population AS Population,
        vac.new_vaccinations AS New_Vaccinations,
        SUM(CAST(IFNULL(vac.new_vaccinations, 0) AS INTEGER)) 
            OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated
    FROM CovidDeaths dea
    JOIN CovidVaccinations vac
        ON dea.location = vac.location
        AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *,
       (CAST(RollingPeopleVaccinated AS REAL) / Population) * 100 AS PercentVaccinated
FROM PopvsVac
ORDER BY Location, date(Date)
;





