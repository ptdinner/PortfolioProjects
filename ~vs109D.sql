Select*
From Covid19..[owid-covid-data-1]
order by 3,4

SELECT [iso_code]
      ,[continent]
      ,[location]
      ,[date]
      ,[total_tests]
      ,[new_tests]
      ,[total_tests_per_thousand]
      ,[new_tests_per_thousand]
      ,[new_tests_smoothed]
  FROM [Covid19].[dbo].[owid-covid-datavacinacion]



SELECT location, date, total_cases, new_cases, total_deaths, population
From Covid19..[owid-covid-data-1]
order by 1,2


--looking at the total case vs total deaths

SELECT location, date, total_cases, total_deaths, (Total_deaths/total_cases)
From Covid19..[owid-covid-data-1]
order by 1,2

SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    CASE 
        WHEN ISNUMERIC(total_cases) = 1 AND ISNUMERIC(total_deaths) = 1 AND total_cases != 0 THEN CAST(total_deaths AS float) / CAST(total_cases AS float)*100 
        ELSE NULL
    END AS death_percentage
FROM 
    Covid19..[owid-covid-data-1]
	where location like '%states%'
ORDER BY 
    1, 2;

	--shows what percentage of population got covid
SELECT 
    location, 
    date, 
    total_cases, 
    population, 
    CASE 
        WHEN ISNUMERIC(total_cases) = 1 AND ISNUMERIC(population) = 1 AND total_cases != 0 THEN CAST(total_cases AS float) / CAST(population AS float)*100 
        ELSE NULL
    END AS death_percentage
FROM 
    Covid19..[owid-covid-data-1]
	where location like '%states%'
ORDER BY 
    1, 2;

--looking at countries with highest infection rate compare to population
SELECT 
    location, 
    population, 
    MAX(CASE 
            WHEN ISNUMERIC(total_cases) = 1 AND ISNUMERIC(population) = 1 AND CAST(total_cases AS float) != 0 
            THEN CAST(total_cases AS float) / CAST(population AS float) * 100
            ELSE NULL
        END) AS PercentagePopulationInfected
FROM 
    Covid19..[owid-covid-data-1]
--WHERE location LIKE '%states%'
GROUP BY 
    location, 
    population
ORDER BY 
    PercentagePopulationInfected DESC;

	-- showing the countries with the Hightest death count per population
SELECT 
    location, 
    MAX(CAST(total_deaths AS int)) AS TotalDeathcount      
FROM 
    Covid19..[owid-covid-data-1]
--WHERE location LIKE '%states%'
Where continent is null
GROUP BY 
    location
ORDER BY 
    TotalDeathcount DESC;

	-- let break thing down by continent
	SELECT 
    continent, 
    MAX(CAST(total_deaths AS int)) AS TotalDeathcount      
FROM 
    Covid19..[owid-covid-data-1]
--WHERE location LIKE '%states%'
Where continent is null
GROUP BY 
    continent
ORDER BY 
    TotalDeathcount DESC;

	-- to see the continent

	SELECT * FROM Covid19..[owid-covid-data-1] WHERE continent IS not NULL;

	Select continent FROM [Covid19].[dbo].[owid-covid-datavacinacion]

	---global numbers
	SELECT 
    location, 
    date, 
    total_cases, 
    total_deaths, 
    CASE 
        WHEN ISNUMERIC(total_cases) = 1 AND ISNUMERIC(total_deaths) = 1 AND total_cases != 0 THEN CAST(total_deaths AS float) / CAST(total_cases AS float)*100 
        ELSE NULL
    END AS death_percentage
FROM 
    Covid19..[owid-covid-data-1]
	--where location like '%states%'
	Where continent is not null
ORDER BY 
    1, 2;

	--total global numbers
	Select date, SUM(new_cases), SUM(Cast(new_deaths as int)), SUM(cast(NEW_deaths as int))/SUM(new_cases)*100 as deathpercentages
	From Covid19..[owid-covid-data-1]
		Where continent is not null
		Group by date
ORDER BY 
    1 2;

	SELECT 
    date, 
    SUM(CAST(new_cases AS int)) AS total_new_cases, 
    SUM(CAST(COALESCE(NULLIF(new_deaths, ''), '0') AS int)) AS total_new_deaths, 
    CASE 
        WHEN SUM(CAST(new_cases AS int)) = 0 THEN 0
        ELSE SUM(CAST(COALESCE(NULLIF(new_deaths, ''), '0') AS int)) / SUM(CAST(new_cases AS int)) * 100 
    END AS death_percentage
FROM 
    Covid19..[owid-covid-data-1]
WHERE 
    continent IS NOT NULL
    AND ISNUMERIC(new_cases) = 1
    AND new_cases IS NOT NULL
--GROUP BY date
ORDER BY 
    1,2;

	---looking at total population vs vaccinations

	Select *
From Covid19..[owid-covid-data-1] dea
Join [Covid19].[dbo].[owid-covid-datavacinacion] vac
on dea. location = vac.location
and dea.date = vac.date
	
	---looking at total population vs vaccinations with filter
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From Covid19..[owid-covid-data-1] dea
Join [Covid19].[dbo].[owid-covid-datavacinacion] vac
on dea. location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 1,2

---by location
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location)
From Covid19..[owid-covid-data-1] dea
Join [Covid19].[dbo].[owid-covid-datavacinacion] vac
on dea. location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3

----- different version

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated,
---(RollingPeoplevaccinated/population)*100
From Covid19..[owid-covid-data-1] dea
Join [Covid19].[dbo].[owid-covid-datavacinacion] vac
on dea. location = vac.location
and dea.date = vac.date
Where dea.continent is not null
order by 2,3


----USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeoplevaccinated
---(RollingPeoplevaccinated/population)*100
From Covid19..[owid-covid-data-1] dea
Join [Covid19].[dbo].[owid-covid-datavacinacion] vac
on dea. location = vac.location
and dea.date = vac.date
Where dea.continent is not null
--order by 2,3
)	
Select* , (RollingPeopleVaccinated/population)*100
From PopvsVac


-----Temp Table

Drop table if exists #PercentpopulationVaccinated
CREATE TABLE #PercentpopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    NewVaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentpopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
    Covid19..[owid-covid-data-1] dea
JOIN
    [Covid19].[dbo].[owid-covid-datavacinacion] vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;

-- Calculate percentage of population vaccinated
SELECT
    *,
    (RollingPeopleVaccinated / Population) * 100 AS PercentPopulationVaccinated
FROM
    #PercentpopulationVaccinated;

	----correction
IF OBJECT_ID('tempdb..#PercentpopulationVaccinated') IS NOT NULL
    DROP TABLE #PercentpopulationVaccinated;

CREATE TABLE #PercentpopulationVaccinated (
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    NewVaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

INSERT INTO #PercentpopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    ISNULL(TRY_CONVERT(NUMERIC, vac.new_vaccinations), 0), -- Use TRY_CONVERT to handle conversion errors
    SUM(ISNULL(TRY_CONVERT(BIGINT, vac.new_vaccinations), 0)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
    Covid19..[owid-covid-data-1] dea
JOIN
    [Covid19].[dbo].[owid-covid-datavacinacion] vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;

-- Calculate percentage of population vaccinated
SELECT
    *,
    (RollingPeopleVaccinated / NULLIF(Population, 0)) * 100 AS PercentPopulationVaccinated -- Avoid division by zero
FROM
    #PercentpopulationVaccinated;


	----creating view
	IF OBJECT_ID('dbo.PercentpopulationVaccinated', 'V') IS NOT NULL
    DROP VIEW dbo.PercentpopulationVaccinated;

GO

CREATE VIEW dbo.PercentpopulationVaccinated AS
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    ISNULL(TRY_CONVERT(NUMERIC, vac.new_vaccinations), 0) AS NewVaccinations,
    SUM(ISNULL(TRY_CONVERT(BIGINT, vac.new_vaccinations), 0)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM
    Covid19..[owid-covid-data-1] dea
JOIN
    [Covid19].[dbo].[owid-covid-datavacinacion] vac ON dea.location = vac.location AND dea.date = vac.date
WHERE
    dea.continent IS NOT NULL;

	Select * 
	From PercentpopulationVaccinated