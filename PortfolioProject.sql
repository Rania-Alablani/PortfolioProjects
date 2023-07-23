-- 1. General View of Countries Counts
SELECT *
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

-- 2. Same as 1 but with specific columns
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- 3. Saudi Aarbia Total cases vs total deaths
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%saudi%' AND continent is not null
ORDER BY 1,2

-- 4. Saudi Aarbia Total cases vs poplulation
SELECT location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%saudi%' AND continent is not null
ORDER BY 1,2

-- 5. Countries with highest infection rates compared to population
SELECT location, population, MAX(total_cases) AS highestInfectionCount, MAX((total_cases/population))*100 as CasesPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, population
ORDER BY CasesPercentage desc

-- 6. Countries with the highest Death
SELECT location, MAX(cast(total_deaths as int)) AS totalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY totalDeathCount desc

-- LETS BREAK THINGS DOWN BY CONTINENT

-- 7. Continents with highest death count 
SELECT continent, MAX(cast(total_deaths as int)) AS totalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY totalDeathCount desc

--GLOBAL NUMBERS

-- 8. Daily view of new cases and death counts accross the world 
SELECT date, Sum(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


-- 9. Total new cases and death counts accross the world 
SELECT Sum(new_cases) as TotalNewCases, SUM(cast(new_deaths as int)) as TotalNewDeaths, SUM(cast(new_deaths as int))/Sum(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- 10. Total popluation vs vaccination 
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION BY cv.location ORDER BY cv.location , cv.date) as RoolingTotalVaccinations
--,(RoolingTotalVaccinations/cd.population)*100 as vaccinatedPercentage
FROM PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent is not null
ORDER BY 2,3

--Use CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations, RoolingTotalVaccinations)
as 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION BY cv.location ORDER BY cv.location , cv.date) as RoolingTotalVaccinations
FROM PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent is not null
)
SELECT *, (RoolingTotalVaccinations/population)*100 as vaccinatedPercentage
FROM PopvsVac

--TEMB TABLE
DROP TABLE IF EXISTS #PopvsVacPercentage
CREATE TABLE #PopvsVacPercentage
(continent nvarchar(255), 
location nvarchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
RoolingTotalVaccinations numeric)

INSERT INTO #PopvsVacPercentage
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION BY cv.location ORDER BY cv.location , cv.date) as RoolingTotalVaccinations
FROM PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent is not null

SELECT *, (RoolingTotalVaccinations/population)*100 as vaccinatedPercentage
FROM  #PopvsVacPercentage

-- 11. Views For later visualization
Create view PopvsVacPercentage as
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cast(cv.new_vaccinations as int)) OVER (PARTITION BY cv.location ORDER BY cv.location , cv.date) as RoolingTotalVaccinations
FROM PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	on cd.location = cv.location
	and cd.date = cv.date
WHERE cd.continent is not null

SELECT *
FROM PopvsVacPercentage