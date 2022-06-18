--SELECT * 
--FROM Covid_exploration..CovidDeaths$

--SELECT * 
--FROM Covid_exploration..CovidVaccinations$

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Covid_exploration..CovidDeaths$
ORDER BY 1,2


--Looking at Total Cases vs Total Deaths
--Shows fluctuation in death percentage in France

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM Covid_exploration..CovidDeaths$
WHERE Location like 'France'
ORDER BY 1,2



--Looking at Total Cases vs Population 
--Shows what percentage of people in France have gotten Covid across time

SELECT Location, date, total_cases, population, (total_cases/population)*100 AS InfectedPopulation
FROM Covid_exploration..CovidDeaths$
WHERE Location LIKE 'France'
ORDER BY 1,2



--Looking at countries with highest Infection Rate relative to Population

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Covid_exploration..CovidDeaths$
GROUP BY population,Location
ORDER BY PercentPopulationInfected DESC



--Showing the countries with the highest death count

SELECT Location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM Covid_exploration..CovidDeaths$
WHERE continent IS NOT null
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- Showing death counts by continent 

SELECT Location, MAX(CAST(Total_deaths AS int)) AS TotalDeathCount
FROM Covid_exploration..CovidDeaths$
WHERE continent IS null
GROUP BY location
ORDER BY TotalDeathCount DESC

--Global numbers across time


SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths,  SUM(CAST(new_deaths AS int)) / SUM(new_cases)* 100 AS DeathPercentage
FROM Covid_exploration..CovidDeaths$
WHERE continent IS NOT null
GROUP BY date
ORDER BY 1,2


--Global numbers 

SELECT SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS int)) AS Total_Deaths,  SUM(CAST(new_deaths AS int)) / SUM(new_cases)* 100 AS DeathPercentage
FROM Covid_exploration..CovidDeaths$
WHERE continent IS NOT null
ORDER BY 1,2


--Looking at Population vs Vaccinations

--CTE

WITH popvsvac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, 
dea.date) AS RollingPeopleVaccinated
FROM Covid_exploration..CovidDeaths$ dea
JOIN Covid_exploration..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null

)
SELECT *, (RollingPeopleVaccinated/Population)*100 AS RollingPopulationVaxed
FROM popvsvac



--Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
RollingPeopleVaccinated numeric
)

INSERT INTO  #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM Covid_exploration..CovidDeaths$ dea 
JOIN Covid_exploration..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date

SELECT*, (RollingPeopleVaccinated/Population)*100 AS PopulationVaxed
FROM #PercentPopulationVaccinated

--Creating view for later visualisations

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
FROM Covid_exploration..CovidDeaths$ dea 
JOIN Covid_exploration..CovidVaccinations$ vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT null
