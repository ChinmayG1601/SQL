select 
	d.batsman,
	sum(d.run_per_ball) as score,
	count(d.ball_n) as balls_face, 
	sum(d.run_per_ball)*100./count(ball_n) as strike_rate	
from deliveries as d
where extras_type not in('wides')
group by batsman
having count(d.ball_n)>=500 
order by strike_rate desc
limit 10;


select 
	batsman,
	count(distinct match_id) as innings,
	sum(cast(is_wicket as int)) as total_dissmised,
	sum(run_per_ball)*1./sum(cast(is_wicket as int)) as average
from deliveries
group by batsman
having count(distinct match_id)>=28 and sum(cast(is_wicket as int))>=1
order by average desc
limit 10;

--high hitter


select 
	d.batsman,
	sum(d.run_per_ball) as score,
	a.boundries_score,
	a.boundries_score*1./sum(d.run_per_ball) as boundries_percentage
from deliveries as d
	left join
(select 
	batsman,
	count(run_per_ball) as boundries_score
from deliveries
where run_per_ball in (6,4)
group by batsman
) as a
on a.batsman = d.batsman
where d.extras_type not in('wides')
group by d.batsman, a.boundries_score
having count(distinct match_id)>=28
order by boundries_percentage desc
limit 10;

--economy

select 
	a.bowler,
	a.runs_conceded,
	b.balls,
	a.runs_conceded*6./balls as economy_rate
from (
select 
	bowler,
	sum(run_per_ball) as runs_conceded
from deliveries
	where not extras_type='legbyes' and not extras_type='byes' and not extras_type='penalty'
group by bowler

) as a
left join (
select 
	bowler,
	count(ball_n) as balls
from deliveries
	where not extras_type='wides' and not extras_type='noballs' and not extras_type='penalty'
group by bowler

) as b
on a.bowler = b.bowler
where b.balls>500
order by economy_rate
limit 10;

--- wicket taking bowler

select 
	bowler,
	count(ball_n) as balls,
	sum(cast(is_wicket as int)) as total_wicket,
	count(ball_n)*1./sum(cast(is_wicket as int)) as bowling_strike_rate
from deliveries
where 
	 extras_type not in ('wides','noballs','penalty') and not dismissal_kind = 'run out'	
group by bowler
having sum(cast(is_wicket as int))>0 and count(ball_n)>500
order by bowling_strike_rate
limit 10

--- all rounder 

select 
	a.allrounder,
	a.score,
	a.balls_face,
	a.strike_rate,
	b.balls,
	b.bowling_strike_rate
from 
	(select 
	batsman as allrounder,
	sum(run_per_ball) as score,
	count(ball_n) as balls_face, 
	sum(run_per_ball)*100./count(ball_n) as strike_rate	
from deliveries
where extras_type not in('wides')
group by batsman
having count(ball_n)>=500 ) as a
left join 
(select 
	bowler as allrounder,
	count(ball_n) as balls,
	sum(cast(is_wicket as int)) as total_wicket,
	count(ball_n)*1./sum(cast(is_wicket as int)) as bowling_strike_rate
from deliveries
where 
	 extras_type not in ('wides','noballs','penalty') and not dismissal_kind = 'run out'	
group by bowler
having sum(cast(is_wicket as int))>0 and count(ball_n)>300) as b
on a.allrounder = b.allrounder
order by b.bowling_strike_rate,a.strike_rate
limit 10;

----------
----------
wicketkeeper
----------
----------

select  	w.player as wicketkeeper,
	w.dismissal_kind,
	b.strike_rate,
	b.bowling_strike_rate	
from  (select 	fielder as player,
	count(dismissal_kind) as dismissal_kind
from deliveries
where dismissal_kind in ('stumped')
group by fielder) as w
left join  (select 	a.player as player,
 		a.strike_rate as strike_rate,
 		c.bowling_strike_rate as bowling_strike_rate
from  (select 	batsman as player,
	sum(run_per_ball) as score,
	count(ball_n) as balls_face, 
	sum(run_per_ball)*100./count(ball_n) as strike_rate	
from deliveries
where extras_type not in('wides')
group by batsman
having count(ball_n)>=500 ) as a
 left join
 (select 	bowler as player,
	count(ball_n)*1./sum(cast(is_wicket as int)) as bowling_strike_rate
from deliveries
where extras_type not in ('wides','noballs','penalty') and not dismissal_kind = 'run out'	
group by bowler
having sum(cast(is_wicket as int))>0 and count(ball_n)>6) as c
on a.player = c.player
) as b
on w.player = b.player
order by w.dismissal_kind desc
limit 2












---------------
---------------
-- Additional Questions for Final Assessment
---------------
---------------


select
	distinct city,
	count(city) as hosted_city
from matches
group by city
order by hosted_city desc

----------------
----------------

create table deliveries_v02 as 
(select *,
 case 
 	when run_per_ball >=4 then 'boundary'
 	when run_per_ball = 0 then 'dot'
 	else 'other'
 end as ball_result 
 from deliveries)
 
 select * from deliveries_v02 limit 5


-----------------
------------------

select 
	(select count(ball_result) from deliveries_v02 where ball_result = 'boundary' ) as total_boundary,
	(select count(ball_result) from deliveries_v02 where ball_result = 'dot' ) as total_dots
from deliveries_v02 limit 1;


----------
-----------
select * from matches

select * from deliveries_v02


select 
	distinct batting_team as team,
	count(ball_result) as total_boundaries
from deliveries_v02 
where ball_result = 'boundary'
group by batting_team
order by total_boundaries desc
------
------
select 
	distinct bowling_team as team,
	count(ball_result) as total_dots
from deliveries_v02 
where ball_result = 'dot'
group by bowling_team
order by total_dots desc
------
------

select 
	dismissal_kind,
	count(dismissal_kind) as total_dismissal
from deliveries_v02 
where not dismissal_kind ='NA' 
group by dismissal_kind
order by total_dismissal desc
------
------
select 
	bowler,
	sum(extra_run) as total_extra_runs
from deliveries
where extras_type in ('wides','noballs')
group by bowler
order by total_extra_runs desc
limit 5
------
------
create table deliveries_v03 as 
(select d.*,
	m.venue,
	m.date
from deliveries_v02 as d left join matches as m
on d.match_id = m.id)

select * from deliveries_v03

select 
	venue,
	sum(total_runs) as total_runs
from deliveries_v03 
group by venue
order by total_runs desc

select 
	extract(year from to_date(date,'DD-MM-YYYY')) as year,
	SUM(total_runs) AS total_run
from deliveries_v03
where venue = 'Eden Gardens'
group by extract(year from to_date(date,'DD-MM-YYYY'))
order by total_run desc
















