USE imdb_ijs;

-- THE BIG PICTURE

-- How many actors are there in the actors table?
select count(distinct id)
from actors;
-- 817,718

-- How many directors are there in the directors table?
select count(id)
from directors;
-- 86,880

-- How many movies are there in the movies table?
select count(id)
from movies;
-- 388,269

-- EXPLORING THE MOVIES

-- From what year are the oldest and the newest movies? What are the names of those movies?

select name, year
from movies
where year = (
	select min(year)
	from movies
) or year = (
	select max(year)
	from movies
) ;
-- Oldest movies
-- 1888
-- Traffic Crossing Leeds Bridge
-- Roundhay Garden Scene

-- Newest movies
-- 2008
-- Harry Potter and the Half-Blood Prince


# Alternative solution from Sandrine
SELECT b.name AS movie_name, b.year AS year
FROM (
	SELECT MIN(year) AS min_year 
	FROM movies 
) AS a, 
(SELECT name, year 
FROM movies) AS b
WHERE b.year = a.min_year
UNION
SELECT b.name AS movie_name, b.year AS year
FROM (
SELECT MAX(year) AS max_year 
FROM movies 
) AS a, 
(SELECT name, year FROM movies) AS b
WHERE b.year = a.max_year;


-- What movies have the highest and the lowest ranks?
select name, `rank`
from movies
where `rank` = (
	select max(`rank`)
	from movies
)
union
select name, movies.rank
from movies
where movies.rank = (
	select min(m.rank)
	from movies m
);

-- What is the most common movie title?
select name, count(name) as count_name
from movies 
group by name
order by count_name desc;
-- Eurovision Song Contest, The

-- UNDERSTANDING THE DATABASE

-- Are there movies with multiple directors?
SELECT id, count(director_id) as dir_count
from movies m
inner join movies_directors md on m.id = md.movie_id
group by id
having dir_count > 1
order by dir_count desc;


-- What is the movie with the most directors? Why do you think it has so many?
with directors_count as (
	SELECT m.id, m.name, count(md.director_id) as dir_count
	from movies m
	inner join movies_directors md on m.id = md.movie_id
	group by m.id
	)
select dc.name, dc.dir_count
from directors_count dc
where dc.dir_count = (
	select max(dc.dir_count)
    from directors_count dc
);
-- "Bill, The", 87 directors. It's a British TV series so many directors have directed different episodes.


-- On average, how many actors are listed by movie?
select AVG(ac.actor_count)
from (
	select count(actor_id) as actor_count
	from movies as m
	inner join roles as r on m.id = r.movie_id
	group by movie_id
) ac;
-- 11.4303

-- Are there movies with more than one “genre”?
select name, count(genre) as genre_count
from movies_genres mg
inner join movies m on m.id = mg.movie_id
group by movie_id 
having genre_count > 1
order by genre_count desc;


-- LOOKING FOR SPECIFIC MOVIES

-- Can you find the movie called “Pulp Fiction”?
select *
from movies m 
where name = "Pulp Fiction";

-- Who directed it?
select first_name, last_name
FROM directors d 
inner join movies_directors md 
on d.id = md.director_id
where md.movie_id = (
	select m.id
	from movies m 
	where name = "Pulp Fiction"
);
-- Quentin Tarantino

-- Which actors where cast in it?
select a.first_name, a.last_name, r.role
FROM actors a 
inner join roles r 
on r.actor_id = a.id
where r.movie_id = (
	select m.id
	from movies m 
	where name = "Pulp Fiction"
);

-- Can you find the movie called “La Dolce Vita”?
select *
from movies m 
where name like "%Dolce Vita%";

-- Who directed it?
with dolce_vita_id as (
	select m.id
	from movies m 
	where name = "Dolce Vita, La"
)
select d.first_name, d.last_name
from directors d
inner join movies_directors md on d.id = md.director_id
where md.movie_id = (
	select id 
    from dolce_vita_id
    );
-- Federico Fellini

-- Which actors where casted on it?
with dolce_vita_id as (
	select m.id
	from movies m 
	where name = "Dolce Vita, La"
)
select a.first_name, a.last_name, r.role
from actors a
inner join roles r on a.id = r.actor_id
where r.movie_id = (
	select id 
    from dolce_vita_id
    );
    
-- When was the movie “Titanic” by James Cameron released?
-- Hint: there are many movies named “Titanic”. We want the one directed by James Cameron.
-- Hint 2: the name “James Cameron” is stored with a weird character on it.
select m.year
from movies m 
inner join movies_directors md 
on m.id = md.movie_id
inner join directors d on d.id = md.director_id
where m.name = "Titanic" and d.first_name like "%James%" and d.last_name = "Cameron";
-- 1997


-- ACTORS AND DIRECTORS

-- Who is the actor that acted more times as “Himself”?
with ac as (
	select actor_id, first_name, last_name, count(actor_id) as actor_count
	from roles r 
	inner join actors a on a.id = r.actor_id 
	where role = "Himself"
	group by actor_id
)
select first_name, last_name, actor_count
from ac
where ac.actor_count = (
	select max(ac.actor_count)
	from ac
);
-- Adolf Hitler, 206

-- What is the most common name for actors? And for directors?
select first_name, count(first_name) as name_count
from actors
group by first_name
order by name_count desc
limit 1;
-- John, 4371


with name_occurences as (
	select first_name, count(first_name) as name_count
	from directors
	group by first_name
)
select first_name, name_count
from name_occurences
where name_count = (
	select max(name_count) 
    from name_occurences
);
-- Michael, 670


-- ANALYSING GENDERS

-- How many actors are male and how many are female?
-- Answer the questions above both in absolute and relative terms.
select gender, count(gender)
from actors
group by gender;
-- Male: 513306, Female: 304412

select gender, count(gender)*100/(select count(*) from actors)
from actors
group by gender;
-- Male: 62.8
-- Female: 37.2

-- MOVIES ACROSS TIME

-- How many of the movies were released after the year 2000?
select count(*)
from movies
where year > 2000;
-- 46006

-- How many of the movies where released between the years 1990 and 2000?
select count(*)
from movies
where year <= 2000 and year >= 1990;
-- 91138

-- Ben's solution
select count(*)
from movies
where year between 1990 and 2000;

-- Which are the 3 years with the most movies? How many movies were produced in those years?
select year, count(*)
from movies m
group by m.year
order by 2 desc
limit 3;
-- '2002', '12056'
-- '2003', '11890'
-- '2001', '11690'


-- What are the top 5 movie genres?
select genre, count(genre)
from movies_genres
group by genre
order by 2 desc
limit 5;
-- 'Short', '81013'
-- 'Drama', '72877'
-- 'Comedy', '56425'
-- 'Documentary', '41356'
-- 'Animation', '17652'

RANK() OVER (ORDER BY COUNT(movie_id) DESC) ranking, genre, COUNT(movie_id) total
FROM movies_genres
GROUP BY genre
ORDER BY 1;
    
WITH cte AS (
	SELECT 
)
SELECT ranking, genre, total
FROM cte
WHERE ranking <= 5;


-- What are the top 5 movie genres before 1920?
select genre, count(genre) as movies_per_genre
from movies_genres mg
join movies m on m.id = mg.movie_id
where m.year < 1920
group by genre
order by 2 desc
limit 5;
-- 'Short', '18559'
-- 'Comedy', '8676'
-- 'Drama', '7692'
-- 'Documentary', '3780'
-- 'Western', '1704'


-- What is the evolution of the top movie genres across all the decades of the 20th century?
WITH common_table_expression AS (
	SELECT RANK() OVER (
		PARTITION BY decade 
        ORDER BY movies_per_genre DESC
        ) ranking, genre, decade, movies_per_genre
	FROM (
		SELECT genre, FLOOR(m.year / 10) * 10 AS decade, COUNT(genre) AS movies_per_genre
		FROM movies_genres mg 
        JOIN movies m ON m.id = mg.movie_id
		GROUP BY decade, genre) AS sub_query
        )
SELECT genre, decade, movies_per_genre
FROM common_table_expression
WHERE ranking = 1 AND decade >= 1900 AND decade < 2000;

-- PUTTING IT ALL TOGETHER: NAMES, GENDERS AND TIME

-- Has the most common name for actors changed over time?
WITH temp AS (
	SELECT RANK() OVER (
		PARTITION BY decade ORDER BY names_per_decade DESC
    ) ranking, first_name, decade
	FROM (
		SELECT first_name, FLOOR(m.year / 10) * 10 AS decade, COUNT(a.first_name) AS names_per_decade
		FROM actors a
		JOIN roles r ON a.id = r.actor_id
		JOIN movies m ON m.id = r.movie_id
		GROUP BY decade, first_name
	) as sub
)
SELECT first_name, decade
FROM temp
WHERE ranking = 1;

-- Get the most common actor name for each decade in the XX century.
WITH temp AS (
	SELECT RANK() OVER (
		PARTITION BY decade ORDER BY names_per_decade DESC
    ) ranking, first_name, decade, names_per_decade
	FROM (
		SELECT first_name, FLOOR(m.year / 10) * 10 AS decade, COUNT(a.first_name) AS names_per_decade
		FROM actors a
		JOIN roles r ON a.id = r.actor_id
		JOIN movies m ON m.id = r.movie_id
		GROUP BY decade, first_name
	) as sub
)
SELECT first_name, decade, names_per_decade
FROM temp
WHERE ranking = 1 AND decade >= 1900 AND decade < 2000;


-- Re-do the analysis on most common names, splitted for males and females.
WITH temp AS (
	SELECT RANK() OVER (
		PARTITION BY decade, gender ORDER BY names_per_decade DESC
    ) ranking, first_name, decade, names_per_decade, gender
	FROM (
		SELECT first_name, FLOOR(m.year / 10) * 10 AS decade, COUNT(a.first_name) AS names_per_decade, gender
		FROM actors a
		JOIN roles r ON a.id = r.actor_id
		JOIN movies m ON m.id = r.movie_id
		GROUP BY decade, gender, first_name
	) as sub
)
SELECT first_name, decade, names_per_decade, gender
FROM temp
WHERE ranking = 1 AND decade >= 1900 AND decade < 2000;

-- Is the proportion of female directors greater after 1968, compared to before 1968?

-- What is the movie genre where there are the most female directors? Answer the question both in absolute and relative terms.

-- How many movies had a majority of females among their cast? Answer the question both in absolute and relative terms.



select *
from (
	select r.movie_id, count(a.id) as female_actors
	from movies m
	join roles r on m.id = r.movie_id
	join actors a on r.actor_id = a.id
	where gender = "F"
	group by r.movie_id
) as female_actors_per_film,
(select r.movie_id, count(a.id) as male_actors
	from movies m
	join roles r on m.id = r.movie_id
	join actors a on r.actor_id = a.id
	where gender = "M"
	group by r.movie_id
) as male_actors_per_film
where female_actors_per_film.movie_id = male_actors_per_film.movie_id;
    



-- absolute
with female_actors_per_film as (
	select r.movie_id as movie_id_f, count(a.id) as female_actors
	from movies m
	join roles r on m.id = r.movie_id
	join actors a on r.actor_id = a.id
	where gender = "F"
	group by r.movie_id
), male_actors_per_film as
(
	select r.movie_id as movie_id_m, count(a.id) as male_actors
	from movies m
	join roles r on m.id = r.movie_id
	join actors a on r.actor_id = a.id
	where gender = "M"
	group by r.movie_id
),
actor_counts_per_film as (
	select *
    from female_actors_per_film
    join male_actors_per_film
    on movie_id_f = movie_id_m
)
select count(*)
from actor_counts_per_film
where female_actors > male_actors;
-- 31739 films have more female actors than male

-- relative
with female_actors_per_film as (
	select r.movie_id as movie_id_f, count(a.id) as female_actors
	from movies m
	join roles r on m.id = r.movie_id
	join actors a on r.actor_id = a.id
	where gender = "F"
	group by r.movie_id
), male_actors_per_film as
(
	select r.movie_id as movie_id_m, count(a.id) as male_actors
	from movies m
	join roles r on m.id = r.movie_id
	join actors a on r.actor_id = a.id
	where gender = "M"
	group by r.movie_id
),
actor_counts_per_film as (
	select *
    from female_actors_per_film
    join male_actors_per_film
    on movie_id_f = movie_id_m
)
select count(*)
from actor_counts_per_film;
-- 234374

with female_actors_per_film as (
	select r.movie_id as movie_id_f, count(a.id) as female_actors
	from movies m
	join roles r on m.id = r.movie_id
	join actors a on r.actor_id = a.id
	where gender = "F"
	group by r.movie_id
), male_actors_per_film as
(
	select r.movie_id as movie_id_m, count(a.id) as male_actors
	from movies m
	join roles r on m.id = r.movie_id
	join actors a on r.actor_id = a.id
	where gender = "M"
	group by r.movie_id
),
actor_counts_per_film as (
	select *
    from female_actors_per_film
    join male_actors_per_film
    on movie_id_f = movie_id_m
)
select count(*)/(
	select count(*) as films_count
	from actor_counts_per_film)
from actor_counts_per_film
where female_actors > male_actors;
-- 0.1354, 13.54% of films have more female actors than male