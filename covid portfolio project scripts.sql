--select the data that will we use 
select location,
date,
total_cases,
new_cases,
total_deaths,
population
from [cov-death]
order by 1 , 2;

-- looking to total case vs total death 
-- death in egypt by cov
select location,
date,
total_cases,
total_deaths,
(total_deaths/total_cases) * 100 as deathper ,
population
from [cov-death]
where total_cases <> 0 and total_deaths <>0 and location like '%egy%'
order by 1 , 2;

-- total death per pop 

select location,
date,
total_cases,
population,
(total_cases/population) * 100 as casesperpop ,
population
from [cov-death]
where total_cases <> 0 and total_deaths <>0 and location like '%egy%'
order by 1 , 2;

--the highest countries

select location,
population,
max(total_cases),
max((total_cases/population)) * 100 as casesperpop 
from [cov-death]
where total_cases <> 0 and total_deaths <>0 
group by location,population
order by casesperpop desc;

-- the highest death 

select location,
population,
max(total_deaths) as deaths
--max((total_cases/population)) * 100 as casesperpop 
from [cov-death]
where total_cases <> 0 and total_deaths <>0 and continent is not null
group by location,population
order by deaths desc;

--breaking things down by continent

select location
population,
max(total_deaths) as deaths
--max((total_cases/population)) * 100 as casesperpop 
from [cov-death]
where total_cases <> 0 and total_deaths <>0 and continent is  null
group by location
order by deaths desc;

--showing continent with the highest death 

select continent
population,
max(total_deaths) as deaths
--max((total_cases/population)) * 100 as casesperpop 
from [cov-death]
where total_cases <> 0 and total_deaths <>0 and continent is not null
group by continent
order by deaths desc;

-- global numbers

select 
date,
sum(new_cases) as t_new_cases,
sum(new_deaths)as t_new_death,
(sum(new_deaths)/sum(new_cases)) * 100 as newdeathper
from [cov-death]
where continent is not null and new_cases<>0
group by date
order by 1 , 2;
--
select 
sum(new_cases) as t_new_cases,
sum(new_deaths)as t_new_death,
(sum(new_deaths)/sum(new_cases)) * 100 as newdeathper
from [cov-death]
where continent is not null and new_cases<>0
order by 1 , 2;

-- total vac vs. total pop

select --dth
dth.continent,
dth.location,
dth.date,
dth.population,
vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dth.location order by dth.location, dth.date) as rolling_p_vac
from [cov-death] as dth
inner join [cov-vac] as vac
	on dth.location=vac.location
	and dth.date=vac.date
	where dth.continent is not null
	order by 2,3

-- use cte

	with popvsvac (continent , location , date , population , new_vaccinations , rolling_p_vac)
	as
	(
	select 
dth.continent,
dth.location,
dth.date,
dth.population,
vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dth.location order by dth.location, dth.date) as rolling_p_vac
from [cov-death] as dth
inner join [cov-vac] as vac
	on dth.location=vac.location
	and dth.date=vac.date
	where dth.continent is not null
	)
	select *,
	(rolling_p_vac/population) * 100
	from popvsvac
	where rolling_p_vac is not null

-- got the max with cte 

	with popvsvac (continent , location , population , new_vaccinations , rolling_p_vac)
	as
	(
	select 
dth.continent,
dth.location,
dth.population,
vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dth.location order by dth.location) as rolling_p_vac
from [cov-death] as dth
inner join [cov-vac] as vac
	on dth.location=vac.location
	and dth.date=vac.date
	where dth.continent is not null
	)
	select *,
	max(rolling_p_vac) over(partition by location)
	from popvsvac
	where rolling_p_vac is not null;

-- make cte a temp table

	drop table if exists per_pop_vac
	create table per_pop_vac
	(continent nvarchar(255),
	location nvarchar(255) , 
	date datetime, 
	population numeric,
	new_vaccinations numeric, 
	rolling_p_vac numeric
	)
	insert into 
		per_pop_vac
	
	select 
dth.continent,
dth.location,
dth.date,
dth.population,
vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dth.location order by dth.location, dth.date) as rolling_p_vac
from [cov-death] as dth
inner join [cov-vac] as vac
	on dth.location=vac.location
	and dth.date=vac.date
	where dth.continent is not null
	
	select *,
	(rolling_p_vac/population) * 100
	from per_pop_vac
	;

--create view for later data viz

create view pop_vac as
		select 
dth.continent,
dth.location,
dth.date,
dth.population,
vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over(partition by dth.location order by dth.location, dth.date) as rolling_p_vac
from [cov-death] as dth
inner join [cov-vac] as vac
	on dth.location=vac.location
	and dth.date=vac.date
	where dth.continent is not null
	--

	select *
	from pop_vac;

	





















