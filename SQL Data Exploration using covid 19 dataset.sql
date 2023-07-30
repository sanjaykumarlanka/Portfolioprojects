use portfolioproject

select * from [covid deaths] where continent is not null order by 3,4

select * from [covid vaccinations] order by 3,4

select location,date,population,total_cases,new_cases_smoothed,total_deaths
from [covid deaths] order by 1,2

----looking at total_cases vs total_deaths
select location,date,total_cases,total_deaths,total_deaths/total_cases
from [covid deaths]
where location like '%states%'order by 1,2
alter table [covid deaths] alter column total_deaths bigint
alter table [covid deaths] alter column total_cases bigint

-----looking at total_cases vs population

select location, date,population,total_cases,(total_cases/population)* 100 as 
percentagepopulationinfected from [covid deaths]
where location like '%states%'
and continent is not null order by 1,2

---country with high infection rate compared to population
select location,population,max(total_cases) as highestinfectioncount,
max(total_cases/population)* 100 as 
percentagepopulationinfected from [covid deaths]
---where location like '%states%'
group by location,population
order by percentagepopulationinfected desc

---showing countries with highest death count per population
select location,max(total_deaths) as totaldeathcount
from [covid deaths]
where continent is not null
group by location
order by totaldeathcount desc

---lets braek things down by continent

--showing the comtinents with highest death count per population
select continent,max(total_deaths) as totaldeathcount
from [covid deaths]
where continent is not null
group by continent
order by totaldeathcount desc

---global numbers

select sum(new_cases)as total_cases,sum(cast(new_deaths as int))as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases) * 100 as deathpercentage
from [covid deaths]
--where location like '%states%'
where continent is not null 
order by 1,2

-----total population vs vaccination
select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)as 
rollingpeoplevaccinated
from [covid deaths] dea
join [covid vaccinations] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is null
order by 2,3

---use cte
select dea.continent,dea.location, dea.date, dea.population,vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location,dea.date)as 
rollingpeoplevaccinated
from [covid deaths] dea
join [covid vaccinations] vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is null
order by 2,3

----- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [Covid deaths] dea
Join [Covid vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [covid deaths] dea
Join [covid vaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
