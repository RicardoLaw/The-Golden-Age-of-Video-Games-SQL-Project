CREATE TABLE game_sales (
  game VARCHAR(100) PRIMARY KEY,
  platform VARCHAR(64),
  publisher VARCHAR(64),
  developer VARCHAR(64),
  games_sold NUMERIC(5, 2),
  year INT);
  

CREATE TABLE reviews (
    game VARCHAR(100) PRIMARY KEY,
    critic_score NUMERIC(4, 2),   
    user_score NUMERIC(4, 2));


CREATE TABLE top_critic_years (
    year INT PRIMARY KEY,
    avg_critic_score NUMERIC(4, 2));


CREATE TABLE top_critic_years_more_than_four_games (
    year INT PRIMARY KEY,
    num_games INT,
    avg_critic_score NUMERIC(4, 2)  );


CREATE TABLE top_user_years_more_than_four_games (
    year INT PRIMARY KEY,
    num_games INT,
    avg_user_score NUMERIC(4, 2));



-- Select all information for the top ten best-selling games

SELECT * 
FROM game_sales 
ORDER BY games_sold DESC
Limit 10;


-- Select a count of the number of games where both critic_score and user_score are null

SELECT Count(g.game) 
FROM game_sales g
LEFT JOIN reviews r 
ON g.game = r.game 
WHERE critic_score IS NULL AND user_score IS NULL; 



-- Select release year and average critic score for each year

SELECT g.year, ROUND(AVG(r.critic_score),2) AS avg_critic_score
FROM game_sales g 
INNER JOIN reviews r 
ON g.game = r.game 
GROUP BY g.year 
ORDER by avg_critic_score DESC 
LIMIT 10;

-- Updating the query so that it only returns years that have more than four reviewed games


SELECT g.year, COUNT(g.game) AS num_games, ROUND(AVG(r.critic_score),2) AS avg_critic_score
FROM game_sales g 
INNER JOIN reviews r 
ON g.game = r.game 
GROUP BY g.year 
HAVING COUNT(g.game) > 4
ORDER by avg_critic_score DESC 
LIMIT 10;


-- Select the year and avg_critic_score for those years that dropped off the list of critic favorites 

SELECT year, avg_critic_score 
FROM top_critic_years 
EXCEPT 
SELECT year, avg_critic_score
FROM top_critic_years_more_than_four_games 
ORDER BY avg_critic_score DESC; 


-- Select year, an average of user_score, and a count of games released in a given year

SELECT g.year, COUNT(g.game) AS num_games, ROUND(AVG(r.user_score),2) AS avg_user_score
FROM game_sales g 
INNER JOIN reviews r  
ON g.game = r.game 
GROUP BY g.year 
HAVING COUNT (g.game) > 4 
ORDER BY avg_user_score DESC
LIMIT 10; 



-- Selecting the year results that appear on both tables

SELECT year
FROM top_user_years_more_than_four_games
INTERSECT
SELECT year
FROM top_critic_years_more_than_four_games;



-- Select year and sum of games_sold

SELECT g.year, SUM(g.games_sold) AS total_games_sold
FROM game_sales g
WHERE g.year IN (SELECT year
FROM top_user_years_more_than_four_games
INTERSECT
SELECT year
FROM top_critic_years_more_than_four_games)
GROUP BY g.year
ORDER BY total_games_sold DESC;
