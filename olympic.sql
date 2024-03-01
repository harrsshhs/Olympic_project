select * from athlete_events;
SELECT * from athletes
-- which team has won the maximum gold medals over the years.
-- solution 1
select top 1 a.team,COUNT(distinct event) as medal_cnt 
from athlete_events ae
inner join athletes a
on ae.athlete_id=a.id
where ae.medal='Gold'
group by a.team
order by medal_cnt desc;

-- for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver
-- solution 2
with cte as (
select a.team,ae.year,COUNT(distinct event) as silver_medals
,rank() over(partition by team order by count(distinct event) desc) as rn
from athlete_events ae
inner join athletes a
on ae.athlete_id=a.id
where ae.medal='Silver'
group by a.team,ae.year)
select team,SUM(silver_medals) as total_silver_medals,MAX(CASE WHEN rn=1 then year end) as year_of_max_silver
from cte
group by team ;

-- which player has won maximum gold medals  amongst the players 
-- which have won only gold medal (never won silver or bronze) over the years
-- solution 3
with cte as (
select name,medal
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id)
select top 1 name , count(1) as no_of_gold_medals
from cte 
where name not in (select distinct name from cte where medal in ('Silver','Bronze'))
and medal='Gold'
group by name
order by no_of_gold_medals desc


-- in each year which player has won maximum gold medal . Write a query to print year,player name 
-- and no of golds won in that year . In case of a tie print comma separated player names.
-- solution 4 
with cte as(
select ae.year,a.name,COUNT(1) as gold_medals,rank() over(partition by year order by count(1) desc) as rn 
from athlete_events ae
inner join athletes a
on ae.athlete_id=a.id
where ae.medal='Gold'
group by ae.year,a.name)
,cte2 as(
select year,gold_medals,STRING_AGG(name,',') as names
from cte
where rn=1
group by year,gold_medals)
select * from cte2;

-- in which event and year India has won its first gold medal,first silver medal and first bronze medal
-- print 3 columns medal,year,sport
-- solution 5
with cte as(
select *,RANK() over(partition by medal order by year) as rn
from athlete_events ae
inner join athletes a
on ae.athlete_id=a.id
where team='India' and medal not in ('NA'))
select DISTINCT medal,year,event,rn from cte where rn=1;

-- find players who won gold medal in summer and winter olympics both.
-- solution 6
select a.name  
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal='Gold'
group by a.name having count(distinct season)=2

-- find players who won gold, silver and bronze medal in a single olympics. print player name along with year.
-- solution 7
select year,name
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal != 'NA'
group by year,name having count(distinct medal)=3


-- find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
-- Assume summer olympics happens every 4 year starting 2000. print player name and event name.
-- solution 8
with cte as (
select name,year,event
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where year >=2000 and season='Summer'and medal = 'Gold'
group by name,year,event)
select * from
(select *, lag(year,1) over(partition by name,event order by year ) as prev_year
, lead(year,1) over(partition by name,event order by year ) as next_year
from cte) A
where year=prev_year+4 and year=next_year-4