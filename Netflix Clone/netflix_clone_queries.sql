-- =====================================================================
-- NETFLIX DATABASE CLONE — PRACTICE QUERIES (AS VIEWS)
-- Run netflix_clone_complete.sql (or schema.sql + data.sql) first.
--
-- Every practice query below is saved as a CREATE VIEW. Run this whole
-- script ONCE, and after that anyone can instantly see any result with:
--
--     SELECT * FROM view_name;
--
-- ...without re-typing or re-running the original query. Each view is
-- documented with: What it does / SQL concept it teaches / Expected result.
-- =====================================================================
USE netflix_clone;

-- =====================================================================
-- BEGINNER
-- =====================================================================

-- v01_all_movies
-- What it does: shows all movies.
-- Concept: basic SELECT
-- Expected: 32 rows, all columns from movies.
CREATE OR REPLACE VIEW v01_all_movies AS
SELECT * FROM movies;

-- v02_all_tv_shows
-- What it does: shows all TV shows.
-- Concept: basic SELECT
-- Expected: 22 rows, all columns from tv_shows.
CREATE OR REPLACE VIEW v02_all_tv_shows AS
SELECT * FROM tv_shows;

-- v03_movies_after_2020
-- What it does: finds movies released after 2020.
-- Concept: WHERE filter on a numeric column
-- Expected: titles like Parallel Seoul, Neon Tokyo Nights, Digital Ghosts.
CREATE OR REPLACE VIEW v03_movies_after_2020 AS
SELECT title, release_year FROM movies WHERE release_year > 2020;

-- v04_horror_movies
-- What it does: finds every movie tagged with the "Horror" genre.
-- Concept: JOIN across a junction table
-- Expected: Whispering Pines, The Deep End.
CREATE OR REPLACE VIEW v04_horror_movies AS
SELECT m.title, m.release_year
FROM movies m
JOIN movie_genres mg ON mg.movie_id = m.movie_id
JOIN genres g ON g.genre_id = mg.genre_id
WHERE g.genre_name = 'Horror';

-- v05_movies_by_release_year
-- What it does: sorts all movies by release year, newest first.
-- Concept: ORDER BY
-- Expected: 32 rows sorted descending by release_year.
CREATE OR REPLACE VIEW v05_movies_by_release_year AS
SELECT title, release_year FROM movies ORDER BY release_year DESC;

-- v06_indian_actors
-- What it does: lists actors with Indian nationality.
-- Concept: simple WHERE filter
-- Expected: 10 actors (Shah Rukh Khan, Bachchan, Padukone, ...).
CREATE OR REPLACE VIEW v06_indian_actors AS
SELECT first_name, last_name, nationality FROM actors WHERE nationality = 'Indian';

-- v07_movie_countries
-- What it does: lists distinct countries represented in the movies table.
-- Concept: DISTINCT
-- Expected: United States, United Kingdom, India, South Korea, Japan, Spain, France.
CREATE OR REPLACE VIEW v07_movie_countries AS
SELECT DISTINCT country FROM movies;

-- v08_short_movies
-- What it does: finds movies shorter than 105 minutes.
-- Concept: WHERE with a numeric comparison
-- Expected: a handful of short movies.
CREATE OR REPLACE VIEW v08_short_movies AS
SELECT title, duration_minutes FROM movies WHERE duration_minutes < 105;

-- v09_ongoing_shows
-- What it does: finds TV shows that are still ongoing (no end_year).
-- Concept: IS NULL
-- Expected: Kingdom Rising, Starbound Academy, Paris Undercover.
CREATE OR REPLACE VIEW v09_ongoing_shows AS
SELECT title, release_year FROM tv_shows WHERE end_year IS NULL;

-- v10_movies_title_night
-- What it does: searches for movies whose title contains "Night".
-- Concept: LIKE / pattern matching
-- Expected: Neon Tokyo Nights, Mumbai Nights, etc.
CREATE OR REPLACE VIEW v10_movies_title_night AS
SELECT title FROM movies WHERE title LIKE '%Night%';

-- =====================================================================
-- INTERMEDIATE
-- =====================================================================

-- v11_movie_ratings_inner_join
-- What it does: pairs every movie with its rating.
-- Concept: INNER JOIN
-- Expected: 32 rows.
CREATE OR REPLACE VIEW v11_movie_ratings_inner_join AS
SELECT m.title, r.rating_value, r.rating_count
FROM movies m
INNER JOIN ratings r ON r.movie_id = m.movie_id AND r.content_type = 'movie';

-- v12_movie_ratings_left_join
-- What it does: lists all movies, keeping unrated movies visible too.
-- Concept: LEFT JOIN, handling optional relationships
-- Expected: 32 rows; rating columns would be NULL for any unrated movie.
CREATE OR REPLACE VIEW v12_movie_ratings_left_join AS
SELECT m.title, r.rating_value
FROM movies m
LEFT JOIN ratings r ON r.movie_id = m.movie_id AND r.content_type = 'movie';

-- v13_movie_count_by_genre
-- What it does: counts how many movies exist per genre.
-- Concept: GROUP BY + COUNT
-- Expected: one row per genre with a movie count.
CREATE OR REPLACE VIEW v13_movie_count_by_genre AS
SELECT g.genre_name, COUNT(*) AS movie_count
FROM movie_genres mg
JOIN genres g ON g.genre_id = mg.genre_id
GROUP BY g.genre_name
ORDER BY movie_count DESC;

-- v14_genres_over_5_movies
-- What it does: finds genres that appear on more than 5 movies.
-- Concept: GROUP BY + HAVING
-- Expected: only genres passing the 5-movie threshold.
CREATE OR REPLACE VIEW v14_genres_over_5_movies AS
SELECT g.genre_name, COUNT(*) AS movie_count
FROM movie_genres mg
JOIN genres g ON g.genre_id = mg.genre_id
GROUP BY g.genre_name
HAVING COUNT(*) > 5;

-- v15_avg_rating_by_country
-- What it does: computes the average movie rating per country.
-- Concept: JOIN + GROUP BY + AVG
-- Expected: one row per country with its average movie rating.
CREATE OR REPLACE VIEW v15_avg_rating_by_country AS
SELECT m.country, ROUND(AVG(r.rating_value), 2) AS avg_rating
FROM movies m
JOIN ratings r ON r.movie_id = m.movie_id AND r.content_type = 'movie'
GROUP BY m.country
ORDER BY avg_rating DESC;

-- v16_highest_lowest_rated_movie
-- What it does: finds the highest-rated and lowest-rated movie.
-- Concept: MIN / MAX with subqueries
-- Expected: two rows, the top and bottom rated titles.
CREATE OR REPLACE VIEW v16_highest_lowest_rated_movie AS
SELECT title, rating_value FROM movies m
JOIN ratings r ON r.movie_id = m.movie_id AND r.content_type = 'movie'
WHERE rating_value = (SELECT MAX(rating_value) FROM ratings WHERE content_type = 'movie')
   OR rating_value = (SELECT MIN(rating_value) FROM ratings WHERE content_type = 'movie');

-- v17_top10_rated_movies
-- What it does: lists the top 10 highest-rated movies.
-- Concept: ORDER BY + LIMIT
-- Expected: 10 rows sorted by rating_value descending.
CREATE OR REPLACE VIEW v17_top10_rated_movies AS
SELECT m.title, r.rating_value
FROM movies m
JOIN ratings r ON r.movie_id = m.movie_id AND r.content_type = 'movie'
ORDER BY r.rating_value DESC
LIMIT 10;

-- v18_top5_genres_combined
-- What it does: finds the 5 most common genres across movies AND shows.
-- Concept: UNION ALL + GROUP BY across two junction tables
-- Expected: 5 rows, the most frequently used genres overall.
CREATE OR REPLACE VIEW v18_top5_genres_combined AS
SELECT genre_name, COUNT(*) AS total_uses FROM (
    SELECT g.genre_name FROM movie_genres mg JOIN genres g ON g.genre_id = mg.genre_id
    UNION ALL
    SELECT g.genre_name FROM show_genres sg JOIN genres g ON g.genre_id = sg.genre_id
) combined
GROUP BY genre_name
ORDER BY total_uses DESC
LIMIT 5;

-- v19_actors_multiple_movies
-- What it does: finds actors who appeared in more than one movie.
-- Concept: JOIN + GROUP BY + HAVING on a many-to-many relationship
-- Expected: actors like Leonardo DiCaprio, Scarlett Johansson, Morgan Freeman.
CREATE OR REPLACE VIEW v19_actors_multiple_movies AS
SELECT a.first_name, a.last_name, COUNT(*) AS movie_count
FROM movie_actors ma
JOIN actors a ON a.actor_id = ma.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
HAVING COUNT(*) > 1
ORDER BY movie_count DESC;

-- v20_actors_in_movies_and_shows
-- What it does: finds actors who appeared in BOTH a movie and a TV show.
-- Concept: multi-table JOIN across two junction tables
-- Expected: actors present in movie_actors and show_actors simultaneously.
CREATE OR REPLACE VIEW v20_actors_in_movies_and_shows AS
SELECT DISTINCT a.first_name, a.last_name
FROM actors a
JOIN movie_actors ma ON ma.actor_id = a.actor_id
JOIN show_actors sa ON sa.actor_id = a.actor_id;

-- v21_show_genres_concat
-- What it does: lists every TV show with its season count and genre list.
-- Concept: multi-table JOIN, GROUP_CONCAT
-- Expected: 22 rows, each show with a concatenated genre list.
CREATE OR REPLACE VIEW v21_show_genres_concat AS
SELECT t.title, t.number_of_seasons, GROUP_CONCAT(g.genre_name ORDER BY g.genre_name SEPARATOR ', ') AS genres
FROM tv_shows t
JOIN show_genres sg ON sg.show_id = t.show_id
JOIN genres g ON g.genre_id = sg.genre_id
GROUP BY t.show_id, t.title, t.number_of_seasons;

-- v22_avg_duration_by_age_rating
-- What it does: compares average movie duration by age_rating.
-- Concept: GROUP BY + AVG on a different grouping column
-- Expected: one row per age_rating with the average runtime.
CREATE OR REPLACE VIEW v22_avg_duration_by_age_rating AS
SELECT age_rating, ROUND(AVG(duration_minutes), 1) AS avg_duration
FROM movies
GROUP BY age_rating
ORDER BY avg_duration DESC;

-- =====================================================================
-- ADVANCED
-- =====================================================================

-- v23_movie_rank_by_year
-- What it does: ranks all movies by rating within their release year.
-- Concept: RANK() OVER (PARTITION BY ... ORDER BY ...)
-- Expected: every movie gets a rank (1 = highest rated) among others from the same year.
CREATE OR REPLACE VIEW v23_movie_rank_by_year AS
SELECT m.title, m.release_year, r.rating_value,
       RANK() OVER (PARTITION BY m.release_year ORDER BY r.rating_value DESC) AS year_rank
FROM movies m
JOIN ratings r ON r.movie_id = m.movie_id AND r.content_type = 'movie';

-- v24_top_movie_per_genre
-- What it does: finds the top-rated movie in each genre.
-- Concept: CTE + DENSE_RANK() + PARTITION BY
-- Expected: one (or more, on ties) top movie per genre.
CREATE OR REPLACE VIEW v24_top_movie_per_genre AS
WITH genre_ranked AS (
    SELECT g.genre_name, m.title, r.rating_value,
           DENSE_RANK() OVER (PARTITION BY g.genre_name ORDER BY r.rating_value DESC) AS rnk
    FROM movie_genres mg
    JOIN genres g ON g.genre_id = mg.genre_id
    JOIN movies m ON m.movie_id = mg.movie_id
    JOIN ratings r ON r.movie_id = m.movie_id AND r.content_type = 'movie'
)
SELECT genre_name, title, rating_value
FROM genre_ranked
WHERE rnk = 1;

-- v25_movie_rownum_by_country
-- What it does: assigns a sequential row number to movies ordered by rating, per country.
-- Concept: ROW_NUMBER() OVER (PARTITION BY ...)
-- Expected: every movie numbered 1..N within its own country, ordered by rating.
CREATE OR REPLACE VIEW v25_movie_rownum_by_country AS
SELECT m.country, m.title, r.rating_value,
       ROW_NUMBER() OVER (PARTITION BY m.country ORDER BY r.rating_value DESC) AS row_num
FROM movies m
JOIN ratings r ON r.movie_id = m.movie_id AND r.content_type = 'movie';

-- v26_movie_rating_tier
-- What it does: labels each movie's rating tier.
-- Concept: CASE expressions
-- Expected: every movie tagged as 'Excellent', 'Good', or 'Average'.
CREATE OR REPLACE VIEW v26_movie_rating_tier AS
SELECT m.title, r.rating_value,
       CASE
           WHEN r.rating_value >= 8.0 THEN 'Excellent'
           WHEN r.rating_value >= 7.0 THEN 'Good'
           ELSE 'Average'
       END AS rating_tier
FROM movies m
JOIN ratings r ON r.movie_id = m.movie_id AND r.content_type = 'movie';

-- v27_actors_above_avg_rating
-- What it does: finds actors whose average movie rating beats the overall average.
-- Concept: correlated subquery, aggregate comparison
-- Expected: actors who tend to appear in above-average-rated movies.
CREATE OR REPLACE VIEW v27_actors_above_avg_rating AS
SELECT a.first_name, a.last_name,
       ROUND((SELECT AVG(r.rating_value)
              FROM movie_actors ma2
              JOIN ratings r ON r.movie_id = ma2.movie_id AND r.content_type = 'movie'
              WHERE ma2.actor_id = a.actor_id), 2) AS avg_actor_rating
FROM actors a
WHERE EXISTS (SELECT 1 FROM movie_actors ma WHERE ma.actor_id = a.actor_id)
HAVING avg_actor_rating > (SELECT AVG(rating_value) FROM ratings WHERE content_type = 'movie');

-- v28_most_active_actors
-- What it does: counts total appearances per actor across movies AND shows.
-- Concept: CTE, UNION ALL, aggregation across two many-to-many relationships
-- Expected: actors ranked by total combined appearances (top 10).
CREATE OR REPLACE VIEW v28_most_active_actors AS
WITH appearances AS (
    SELECT actor_id FROM movie_actors
    UNION ALL
    SELECT actor_id FROM show_actors
)
SELECT a.first_name, a.last_name, COUNT(*) AS total_appearances
FROM appearances ap
JOIN actors a ON a.actor_id = ap.actor_id
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY total_appearances DESC
LIMIT 10;

-- v29_genre_popularity
-- What it does: computes total content count and average rating per genre, combining movies and shows.
-- Concept: CTE, UNION ALL, complex aggregation across two content types
-- Expected: a ranked genre popularity table.
CREATE OR REPLACE VIEW v29_genre_popularity AS
WITH genre_content AS (
    SELECT g.genre_name, r.rating_value
    FROM movie_genres mg
    JOIN genres g ON g.genre_id = mg.genre_id
    JOIN ratings r ON r.movie_id = mg.movie_id AND r.content_type = 'movie'
    UNION ALL
    SELECT g.genre_name, r.rating_value
    FROM show_genres sg
    JOIN genres g ON g.genre_id = sg.genre_id
    JOIN ratings r ON r.show_id = sg.show_id AND r.content_type = 'show'
)
SELECT genre_name, COUNT(*) AS content_count, ROUND(AVG(rating_value), 2) AS avg_rating
FROM genre_content
GROUP BY genre_name
ORDER BY content_count DESC, avg_rating DESC;

-- v30_yearly_content_running_total
-- What it does: counts movies+shows released each year with a running cumulative total.
-- Concept: UNION ALL, GROUP BY, window function running SUM()
-- Expected: a year-by-year release count with a cumulative total column.
CREATE OR REPLACE VIEW v30_yearly_content_running_total AS
WITH yearly AS (
    SELECT release_year AS yr FROM movies
    UNION ALL
    SELECT release_year AS yr FROM tv_shows
)
SELECT yr, COUNT(*) AS releases_this_year,
       SUM(COUNT(*)) OVER (ORDER BY yr) AS running_total
FROM yearly
GROUP BY yr;

-- v31_similar_to_midnight_horizon
-- What it does: finds movies that share at least one genre with "Midnight Horizon".
-- Concept: subquery + JOIN, "similar content" pattern
-- Expected: other movies tagged with Sci-Fi or Thriller.
CREATE OR REPLACE VIEW v31_similar_to_midnight_horizon AS
SELECT DISTINCT m.title
FROM movies m
JOIN movie_genres mg ON mg.movie_id = m.movie_id
WHERE mg.genre_id IN (
    SELECT genre_id FROM movie_genres
    WHERE movie_id = (SELECT movie_id FROM movies WHERE title = 'Midnight Horizon')
)
AND m.title != 'Midnight Horizon';

-- v32_most_cast_actor
-- What it does: finds the actor with the most total appearances.
-- Concept: subquery returning a scalar MAX for comparison
-- Expected: a single actor row, the most-cast performer.
CREATE OR REPLACE VIEW v32_most_cast_actor AS
SELECT a.first_name, a.last_name, counts.total
FROM (
    SELECT actor_id, COUNT(*) AS total FROM (
        SELECT actor_id FROM movie_actors
        UNION ALL
        SELECT actor_id FROM show_actors
    ) x
    GROUP BY actor_id
) counts
JOIN actors a ON a.actor_id = counts.actor_id
WHERE counts.total = (
    SELECT MAX(total) FROM (
        SELECT actor_id, COUNT(*) AS total FROM (
            SELECT actor_id FROM movie_actors
            UNION ALL
            SELECT actor_id FROM show_actors
        ) y
        GROUP BY actor_id
    ) max_counts
);

-- v33_country_catalog_percentage
-- What it does: shows the percentage of movies each country contributes to the catalog.
-- Concept: window function SUM() OVER () for a grand total, percentage calculation
-- Expected: one row per country with a computed percentage share.
CREATE OR REPLACE VIEW v33_country_catalog_percentage AS
SELECT country, COUNT(*) AS movie_count,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS pct_of_catalog
FROM movies
GROUP BY country;

-- =====================================================================
-- FINAL / SHOWCASE QUERY
-- =====================================================================

-- v34_unique_top_rated_movie_per_country  ⭐ headline result
-- What it does: picks exactly ONE distinct, unique, top-rated movie per
-- country — no duplicates, no ties left unresolved, a clean "best pick
-- per market" leaderboard that's ideal for showing off the dataset.
-- Concept: CTE + ROW_NUMBER() OVER (PARTITION BY country ORDER BY rating DESC)
-- to guarantee uniqueness (exactly one winner per country, even on ties,
-- broken alphabetically by title).
-- Expected: exactly 7 rows — one unique top movie per country
-- (United States, United Kingdom, India, South Korea, Japan, Spain, France),
-- ordered by rating so the single best title overall appears first.
CREATE OR REPLACE VIEW v34_unique_top_rated_movie_per_country AS
WITH ranked AS (
    SELECT m.country, m.title, m.release_year, r.rating_value,
           ROW_NUMBER() OVER (
               PARTITION BY m.country
               ORDER BY r.rating_value DESC, m.title ASC
           ) AS rn
    FROM movies m
    JOIN ratings r ON r.movie_id = m.movie_id AND r.content_type = 'movie'
)
SELECT country, title AS top_rated_movie, release_year, rating_value
FROM ranked
WHERE rn = 1
ORDER BY rating_value DESC;

-- =====================================================================
-- QUICK REFERENCE: run any of these any time
-- =====================================================================
-- SELECT * FROM v01_all_movies;
-- SELECT * FROM v17_top10_rated_movies;
-- SELECT * FROM v24_top_movie_per_genre;
-- SELECT * FROM v28_most_active_actors;
-- SELECT * FROM v34_unique_top_rated_movie_per_country;   -- headline result
