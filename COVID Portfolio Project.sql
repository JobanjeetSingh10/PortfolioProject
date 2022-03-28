--SELECT *
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select data that we are going to be using

SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- total cases vs total deaths in Canada
SELECT 
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS Death_rate
FROM PortfolioProject..CovidDeaths
WHERE location like '%Canada%'
ORDER BY 1,2

--looking at total cases vs population

-- total cases in Canada 
SELECT
	location,
	date,
	population,
	total_cases,
	(total_cases/population)*100 AS incidence_rate
FROM PortfolioProject..CovidDeaths
WHERE location = 'Canada'
ORDER BY 1,2

-- total cases by continent 
SELECT
	continent,
	MAX(cast(total_deaths as int)) as Total_death_count
FROM PortfolioProject..CovidDeaths
WHERE continent IS not null
GROUP BY continent
ORDER BY Total_death_count DESC

-- total cases by date
SELECT
	date,
	SUM(new_cases) AS total_cases,
	SUM(cast(new_deaths as INT)) AS total_deaths,
	SUM(cast(new_deaths as INT))/NULLIF(SUM(new_cases),0)*100 AS Death_rate
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1 DESC

--total cases by vaccination

SELECT 
	dea.continent,
	dea.location,
	dea.date,
	dea.population,
	vac.new_vaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac 
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT 
	location,
	PortfolioProject..CovidDeaths.date,
	dates.highest_case_count,
	dates.highest_incidence_rate
FROM PortfolioProject..CovidDeaths
	INNER JOIN
		(SELECT 
			date,
			MAX(total_cases) AS highest_case_count,
			MAX((total_cases/population))*100 AS highest_incidence_rate
		FROM PortfolioProject..CovidDeaths
		GROUP BY date
		) AS dates
	ON dates.date = PortfolioProject..CovidDeaths.date
ORDER BY PortfolioProject..CovidDeaths.date

SELECT 
	dea.continent, 
	dea.location, 
	dea.date, 
	dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
	-- (Rollingpeoplevaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.location = 'Canada'
ORDER BY 2,3

-- USE CTE

WITH PopvsVac (Continent, location, Date, population, new_vaccinations, RollingpeopleVaccinated)
as 
(
	SELECT 
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
		-- (Rollingpeoplevaccinated/population)*100
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.location = 'Canada'
)
SELECT *, (RollingpeopleVaccinated/population)*100 AS Rollingvaccinatedrate
FROM PopvsVac

--create view to store data for later for vizualization 

CREATE VIEW Percentpopulationvaccinated AS
SELECT 
		dea.continent, 
		dea.location, 
		dea.date, 
		dea.population, 
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS bigint)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) AS Rollingpeoplevaccinated
		-- (Rollingpeoplevaccinated/population)*100
	FROM PortfolioProject..CovidDeaths dea
	JOIN PortfolioProject..CovidVaccinations vac
		ON dea.location = vac.location
		AND dea.date = vac.date
	WHERE dea.location = 'Canada'