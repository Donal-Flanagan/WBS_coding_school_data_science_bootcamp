USE imdb_ijs;

-- How many actors are there in the actors table?
SELECT COUNT(id)
FROM actors;
-- '817718'

-- How many directors are there in the directors table?
SELECT COUNT(id)
FROM directors;
-- '86880'

-- How many movies are there in the movies table?
SELECT COUNT(id)
FROM movies;
-- '388269'

-- From what year are the oldest and the newest movies? What are the names of those movies?
SELECT MAX(year), MIN(year) FROM movies;
/* # MAX(year), MIN(year)
2008, 1888 */

SELECT name, year 
FROM movies
WHERE year = 2008 
OR year = 1888;
/* # name, year
'Harry Potter and the Half-Blood Prince', '2008'
'Roundhay Garden Scene', '1888'
'Traffic Crossing Leeds Bridge', '1888'
*/

-- What movies have the highest and the lowest ranks?
SELECT MAX(`rank`), MIN(`rank`) FROM movies;
/* # MAX(year), MIN(year)
9.9, 1 */

SELECT name, `rank` 
FROM movies
WHERE `rank` = 9.9 
OR `rank` = 1
ORDER BY `rank` DESC;

-- What is the most common movie title?
SELECT name, COUNT(name)
FROM movies
GROUP BY name
ORDER BY 2 DESC;
/* # name, COUNT(name)
'Eurovision Song Contest, The', '49' */

-- Are there movies with multiple directors?
SELECT movie_id, COUNT(director_id)
FROM movies_directors
GROUP BY movie_id
HAVING COUNT(director_id) > 1
ORDER BY 2 DESC;

-- What is the movie with the most directors? Why do you think it has so many?
SELECT m.name, COUNT(md.director_id)
FROM movies_directors md
JOIN movies m
	ON md.movie_id = m.id
GROUP BY movie_id
HAVING COUNT(director_id) > 1
ORDER BY 2 DESC;
-- All the top dir. counts are long running tv series

-- On average, how many actors are listed by movie?
WITH actors_per_movie AS (
	SELECT movie_id, COUNT(actor_id) AS no_actors
	FROM roles
	GROUP BY movie_id)
SELECT AVG(no_actors)
FROM actors_per_movie
-- 11.4303

-- Are there movies with more than one “genre”?
SELECT movie_id, COUNT(genre)
FROM movies_genres
GROUP BY movie_id
HAVING COUNT(genre) > 1
ORDER BY COUNT(genre) DESC;

-- Can you find the movie called “Pulp Fiction”?
	-- Who directed it?
SELECT d.first_name, d.last_name
FROM directors d
JOIN movies_directors md
	ON d.id = md.director_id
JOIN movies m
	ON md.movie_id = m.id
WHERE m.name LIKE "pulp fiction";
/* # first_name, last_name
Quentin, Tarantino */

	-- Which actors where casted on it?
SELECT a.first_name, a.last_name
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
JOIN movies m
	ON r.movie_id = m.id
WHERE m.name LIKE "pulp fiction";

-- Can you find the movie called “La Dolce Vita”?
	-- Who directed it?
SELECT d.first_name, d.last_name
FROM directors d
JOIN movies_directors md
	ON d.id = md.director_id
JOIN movies m
	ON md.movie_id = m.id
WHERE m.name LIKE "Dolce Vita, la";
/* # first_name, last_name
Federico, Fellini */

	-- Which actors where casted on it?
SELECT a.first_name, a.last_name
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
JOIN movies m
	ON r.movie_id = m.id
WHERE m.name LIKE "Dolce Vita, la";

-- When was the movie “Titanic” by James Cameron released?
SELECT m.year
FROM movies m
JOIN movies_directors md
	ON m.id = md.movie_id
JOIN directors d
	ON md.director_id = d.id
WHERE m.name LIKE "titanic"
AND d.last_name LIKE "Cameron";
-- 1997

-- Who is the actor that acted more times as “Himself”?
SELECT a.first_name, a.last_name, COUNT(a.id)
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
WHERE role LIKE "himself"
GROUP BY a.id, a.first_name, a.last_name
ORDER BY COUNT(a.id) DESC;
/* # first_name, last_name, COUNT(a.id)
Adolf, Hitler, 206 */

-- What is the most common name for actors? 
SELECT first_name, COUNT(first_name)
FROM actors
GROUP BY 1
ORDER BY 2 DESC;
/* # first_name, COUNT(first_name)
John, 4371 */

SELECT last_name, COUNT(last_name)
FROM actors
GROUP BY 1
ORDER BY 2 DESC;
/* # last_name, COUNT(last_name)
Smith, 2425 */

	-- And for directors?
SELECT first_name, COUNT(first_name)
FROM directors
GROUP BY 1
ORDER BY 2 DESC;
/* # first_name, COUNT(first_name)
Michael, 670 */

SELECT last_name, COUNT(last_name)
FROM directors
GROUP BY 1
ORDER BY 2 DESC;
/* # last_name, COUNT(last_name)
Smith, 243 */

-- How many actors are male and how many are female?
-- Answer the questions above both in absolute and relative terms
	-- Absolute
SELECT gender, COUNT(gender)
FROM actors
GROUP BY gender;
/* # gender, COUNT(gender)
F, 304412
M, 513306 */
	
	-- Relative
SELECT
(SELECT COUNT(id)
FROM actors
WHERE gender LIKE "f")
/
(SELECT COUNT(id)
FROM actors)
-- '0.3723' 37% female, therefore 63% male

-- How many of the movies were released after the year 2000?
SELECT COUNT(id)
FROM movies
WHERE year > 2000;
-- '46006'

-- How many of the movies where released between the years 1990 and 2000?
SELECT COUNT(id)
FROM movies
WHERE year BETWEEN 1990 AND 2000;
-- '91138'

-- Which are the 3 years with the most movies? How many movies were produced on those years?
WITH cte AS (SELECT
	RANK() OVER (ORDER BY COUNT(id) DESC) ranking,
    year,
    count(id) total
FROM movies
GROUP BY year
ORDER BY 1)
SELECT ranking, year, total
FROM cte
WHERE ranking <= 3;
/* # ranking, year, total
1, 2002, 12056
2, 2003, 11890
3, 2001, 11690 */

-- What are the top 5 movie genres?
WITH cte AS (SELECT
	RANK() OVER (ORDER BY COUNT(movie_id) DESC) ranking,
    genre,
    COUNT(movie_id) total
FROM movies_genres
GROUP BY genre
ORDER BY 1)
SELECT ranking, genre, total
FROM cte
WHERE ranking <= 5;
/* # ranking, genre, total
1, Short, 81013
2, Drama, 72877
3, Comedy, 56425
4, Documentary, 41356
5, Animation, 17652 */

-- What are the top 5 movie genres before 1920?
WITH cte AS (SELECT
	RANK() OVER (ORDER BY COUNT(movie_id) DESC) ranking,
    genre,
    COUNT(movie_id) total
FROM movies_genres
WHERE movie_id IN (SELECT id FROM movies WHERE year < 1920)
GROUP BY genre
ORDER BY 1)
SELECT ranking, genre, total
FROM cte
WHERE ranking <= 5;
/* # ranking, genre, total
1, Short, 18559
2, Comedy, 8676
3, Drama, 7692
4, Documentary, 3780
5, Western, 1704 */

-- What is the evolution of the top movie genres across all the decades of the 20th century?
SELECT mg.genre, FLOOR(m.year / 10) * 10 as decade, COUNT(m.id) as no_of_movies
FROM movies_genres mg
JOIN movies m
	ON mg.movie_id = m.id
GROUP BY 1, 2
ORDER BY 2, 3 DESC;

-- Get the most common actor name for each decade in the XX century.
WITH cte AS (
SELECT a.first_name as name, 
	COUNT(a.first_name) as totals, 
    FLOOR(m.year / 10) * 10 as decade,
	RANK() OVER (PARTITION BY DECADE ORDER BY TOTALS DESC) AS ranking
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
JOIN movies m
	ON r.movie_id = m.id
GROUP BY 1, 3
ORDER BY 2 DESC)
SELECT decade, name, totals
FROM cte
WHERE ranking = 1
-- AND decade >= 1900
-- AND decade < 1900
ORDER BY decade;
/* # decade, name, totals
1890, Petr, 26
1900, Florence, 180
1910, Harry, 1662
1920, Charles, 1009
1930, Harry, 2161
1940, George, 2128
1950, John, 2027
1960, John, 1823
1970, John, 2657
1980, John, 3855
1990, Michael, 5929
2000, Michael, 3914 */

-- Re-do the analysis on most common names, splitted for males and females
WITH cte AS (
SELECT a.first_name as name, 
	COUNT(a.first_name) as totals, 
    FLOOR(m.year / 10) * 10 as decade,
	RANK() OVER (PARTITION BY DECADE ORDER BY TOTALS DESC) AS ranking
FROM actors a
JOIN roles r
	ON a.id = r.actor_id
JOIN movies m
	ON r.movie_id = m.id
WHERE a.gender LIKE 'f'
GROUP BY 1, 3
ORDER BY 2 DESC)
SELECT decade, name, totals
FROM cte
WHERE ranking = 1
-- AND decade >= 1900
-- AND decade < 1900
ORDER BY decade;
/* # decade, name, totals
1890, Rosemarie, 16
1900, Florence, 180
1910, Florence, 782
1920, Mary, 649
1930, Dorothy, 830
1940, Maria, 739
1950, María, 1005
1960, Maria, 1059
1970, María, 1191
1980, Maria, 1228
1990, Maria, 1728
2000, María, 1148 */

-- How many movies had a majority of females among their cast? Answer the question both in absolute and relative terms.
SELECT COUNT(movie_name_1)
FROM
(SELECT m.name as movie_name_1, COUNT(a.id) as male_actors
FROM movies m
JOIN roles r
	ON m.id = r.movie_id
JOIN actors a
	ON r.actor_id = a.id
WHERE a.gender LIKE "m"
GROUP BY m.name) m_films
JOIN
(SELECT m.name as movie_name_2, COUNT(a.id) as female_actors
FROM movies m
JOIN roles r
	ON m.id = r.movie_id
JOIN actors a
	ON r.actor_id = a.id
WHERE a.gender LIKE "f"
GROUP BY m.name) f_films
ON m_films.movie_name_1 = f_films.movie_name_2
WHERE f_films.female_actors > m_films.male_actors;
-- 29043 movies with more female actors than male (absolute)

SELECT
(SELECT COUNT(movie_name_1)
FROM
(SELECT m.name as movie_name_1, COUNT(a.id) as male_actors
FROM movies m
JOIN roles r
	ON m.id = r.movie_id
JOIN actors a
	ON r.actor_id = a.id
WHERE a.gender LIKE "m"
GROUP BY m.name) m_films
JOIN
(SELECT m.name as movie_name_2, COUNT(a.id) as female_actors
FROM movies m
JOIN roles r
	ON m.id = r.movie_id
JOIN actors a
	ON r.actor_id = a.id
WHERE a.gender LIKE "f"
GROUP BY m.name) f_films
ON m_films.movie_name_1 = f_films.movie_name_2
WHERE f_films.female_actors > m_films.male_actors)
/
(SELECT COUNT(name)
FROM movies)
# (SELECT COUNT(movie_name_1)
FROM
(SELECT m.name as movie_name_1, COUNT(a.id) as male_actors
FROM movies m
JOIN roles r
	ON m.id = r.movie_id
JOIN actors a
	ON r.actor_id = a.id
WHERE a.gender LIKE "m"
GROUP BY m.name) m_films
JOIN
(SELECT m.name as movie_
-- 0.0748 7% of movies have more female actors than males (relative)