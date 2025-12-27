create database RESTUARANT_CONSUMER;
use RESTUARANT_CONSUMER;

CREATE TABLE Consumers (
    Consumer_ID VARCHAR(10) PRIMARY KEY,
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6),
    Smoker VARCHAR(10),
    Drink_Level VARCHAR(20),
    Transportation_Method VARCHAR(50),
    Marital_Status VARCHAR(20),
    Children VARCHAR(20),
    Age INT,
    Occupation VARCHAR(50),
    Budget VARCHAR(20)
);

select * from Consumers;


CREATE TABLE Consumer_Preferences (
    Consumer_ID VARCHAR(10),
    Preferred_Cuisine VARCHAR(50),
    FOREIGN KEY (Consumer_ID) REFERENCES Consumers(Consumer_ID)
);
select * from Consumer_Preferences;

CREATE TABLE Restaurants (
    Restaurant_ID INT PRIMARY KEY,
    Name VARCHAR(150),
    City VARCHAR(100),
    State VARCHAR(100),
    Country VARCHAR(100),
    Zip_Code VARCHAR(20),
    Latitude DECIMAL(9,6),
    Longitude DECIMAL(9,6),
    Alcohol_Service VARCHAR(50),
    Smoking_Allowed VARCHAR(10),
    Price VARCHAR(20),
    Franchise VARCHAR(10),
    Area VARCHAR(50),
    Parking VARCHAR(50)
);
select * from Restaurants;

CREATE TABLE Restaurant_Cuisines (
    Restaurant_ID INT,
    Cuisine VARCHAR(50),
    FOREIGN KEY (Restaurant_ID) REFERENCES Restaurants(Restaurant_ID)
);

select * from Restaurant_Cuisines;

CREATE TABLE Ratings (
    Consumer_ID VARCHAR(10),
    Restaurant_ID INT,
    Overall_Rating INT,
    Food_Rating INT,
    Service_Rating INT,
    FOREIGN KEY (Consumer_ID) REFERENCES Consumers(Consumer_ID),
    FOREIGN KEY (Restaurant_ID) REFERENCES Restaurants(Restaurant_ID)
);
select * from Ratings;

## Using the WHERE clause to filter data based on specific criteria.

## List all details of consumers who live in the city of 'Cuernavaca'.

SELECT * FROM Consumers
WHERE City = 'Cuernavaca';

## Find the Consumer_ID, Age, and Occupation of all consumers who are 'Students' AND are 'Smokers'.

SELECT Consumer_ID, Age, Occupation
FROM Consumers
WHERE Occupation = 'Student'AND Smoker = 'Yes';

## List the Name, City, Alcohol_Service, and Price of all restaurants that serve 'Wine & Beer' and have a 'Medium' price level.

SELECT Name, City, Alcohol_Service, Price
FROM Restaurants
WHERE Alcohol_Service = 'Wine & Beer'AND Price = 'Medium';

## Find the names and cities of all restaurants that are part of a 'Franchise'.

SELECT Name, City
FROM Restaurants
WHERE Franchise = 'Yes';

## Show the Consumer_ID, Restaurant_ID, and Overall_Rating for all ratings where the Overall_Rating was 'Highly Satisfactory' (which corresponds to a value of 2, according to the data dictionary).

SELECT Consumer_ID, Restaurant_ID, Overall_Rating
FROM Ratings
WHERE Overall_Rating = 2;

##Questions JOINs with Subqueries

## List the names and cities of all restaurants that have an Overall_Rating of 2 (Highly Satisfactory) from at least one consumer.
SELECT DISTINCT r.Name, r.City
FROM Restaurants r
JOIN Ratings ra ON r.Restaurant_ID = ra.Restaurant_ID
WHERE ra.Overall_Rating = 2;

## Find the Consumer_ID and Age of consumers who have rated restaurants located in 'San Luis Potosi'.
SELECT DISTINCT c.Consumer_ID, c.Age
FROM Consumers c
JOIN Ratings r ON c.Consumer_ID = r.Consumer_ID
JOIN Restaurants res ON r.Restaurant_ID = res.Restaurant_ID
WHERE res.City = 'San Luis Potosi';

## List the names of restaurants that serve 'Mexican' cuisine and have been rated by consumer 'U1001'.
SELECT DISTINCT r.Name
FROM Restaurants r
JOIN Restaurant_Cuisines rc
    ON r.Restaurant_ID = rc.Restaurant_ID
JOIN Ratings ra
    ON r.Restaurant_ID = ra.Restaurant_ID
WHERE rc.Cuisine = 'Mexican'AND ra.Consumer_ID = 'U1001';

##Find all details of consumers who prefer 'American' cuisine AND have a 'Medium' budget.
SELECT c.*
FROM consumers c
JOIN consumer_preferences cp 
    ON c.Consumer_ID = cp.Consumer_ID
WHERE cp.Preferred_Cuisine = 'American'AND c.Budget = 'Medium';

## List restaurants (Name, City) that have received a Food_Rating lower than the average Food_Rating across all rated restaurants.
SELECT DISTINCT r.Name, r.City
FROM Restaurants r
JOIN Ratings ra
    ON r.Restaurant_ID = ra.Restaurant_ID
WHERE ra.Food_Rating < (
    SELECT AVG(Food_Rating)
    FROM Ratings
);

## Find consumers (Consumer_ID, Age, Occupation) who have rated at least one restaurant but have NOT rated any restaurant that serves 'Italian' cuisine.
SELECT DISTINCT c.Consumer_ID, c.Age, c.Occupation
FROM consumers c
JOIN ratings ra 
    ON c.Consumer_ID = ra.Consumer_ID
WHERE NOT EXISTS (
    SELECT 1
    FROM ratings r2
    JOIN restaurant_cuisines rc 
        ON r2.Restaurant_ID = rc.Restaurant_ID
    WHERE r2.Consumer_ID = c.Consumer_ID
      AND rc.Cuisine = 'Italian'
);

## List restaurants (Name) that have received ratings from consumers older than 30.
SELECT DISTINCT r.Name
FROM Restaurants r
JOIN Ratings ra
    ON r.Restaurant_ID = ra.Restaurant_ID
JOIN Consumers c
    ON ra.Consumer_ID = c.Consumer_ID
WHERE c.Age > 30;

## Find the Consumer_ID and Occupation of consumers whose preferred cuisine is 'Mexican' and who have given an Overall_Rating of 0 to at least one restaurant (any restaurant).
SELECT DISTINCT c.Consumer_ID, c.Occupation
FROM Consumers c
JOIN Consumer_Preferences cp
    ON c.Consumer_ID = cp.Consumer_ID
JOIN Ratings r
    ON c.Consumer_ID = r.Consumer_ID
WHERE cp.Preferred_Cuisine = 'Mexican'AND r.Overall_Rating = 0;

## List the names and cities of restaurants that serve 'Pizzeria' cuisine and are located in a city where at least one 'Student' consumer lives.
SELECT DISTINCT r.Name, r.City
FROM Restaurants r
JOIN Restaurant_Cuisines rc
    ON r.Restaurant_ID = rc.Restaurant_ID
WHERE rc.Cuisine = 'Pizzeria'
  AND r.City IN (
      SELECT DISTINCT c.City
      FROM Consumers c
      WHERE c.Occupation = 'Student'
  );
  
  ## Find consumers (Consumer_ID, Age) who are 'Social Drinkers' and have rated a restaurant that has 'No' parking.
SELECT DISTINCT c.Consumer_ID, c.Age
FROM Consumers c
JOIN Ratings ra
    ON c.Consumer_ID = ra.Consumer_ID
JOIN Restaurants r
    ON ra.Restaurant_ID = r.Restaurant_ID
WHERE c.Drink_Level = 'Social Drinker'AND r.Parking = 'None';
  
## Questions Emphasizing WHERE Clause and Order of Execution

## List Consumer_IDs and the count of restaurants they've rated, but only for consumers who are 'Students'. Show only students who have rated more than 2 restaurants.
SELECT r.Consumer_ID, COUNT(r.Restaurant_ID) AS Restaurants_Rated
FROM Ratings r
JOIN Consumers c ON r.Consumer_ID = c.Consumer_ID
WHERE c.Occupation = 'Student'
GROUP BY r.Consumer_ID
HAVING COUNT(r.Restaurant_ID) > 2;

## We want to categorize consumers by an 'Engagement_Score' which is their Age divided by 10 (integer division). List the Consumer_ID, Age, and this calculated Engagement_Score, but only for consumers whose Engagement_Score would be exactly 2 and who use 'Public' transportation
SELECT c.Consumer_ID, 
       c.Age, 
       c.Age DIV 10 AS Engagement_Score
FROM Consumers c
WHERE c.Age DIV 10 = 2
  AND c.Transportation_Method = 'Public';
  
  ## For each restaurant, calculate its average Overall_Rating. Then, list the restaurant Name, City, and its calculated average Overall_Rating, but only for restaurants located in 'Cuernavaca' AND whose calculated average Overall_Rating is greater than 1.0.
SELECT r.Name,r.City,
AVG(rt.Overall_Rating) AS Average_Rating
FROM Restaurants r
JOIN Ratings rt ON r.Restaurant_ID = rt.Restaurant_ID
WHERE r.City = 'Cuernavaca'
GROUP BY r.Restaurant_ID, r.Name, r.City
HAVING AVG(rt.Overall_Rating) > 1.0;

## Find consumers (Consumer_ID, Age) who are 'Married' and whose Food_Rating for any restaurant is equal to their Service_Rating for that same restaurant, but only consider ratings where the Overall_Rating was 2.
SELECT DISTINCT c.Consumer_ID, c.Age
FROM Consumers c
JOIN Ratings r ON c.Consumer_ID = r.Consumer_ID
WHERE c.Marital_Status = 'Married'
AND r.Food_Rating = r.Service_Rating
AND r.Overall_Rating = 2;

## List Consumer_ID, Age, and the Name of any restaurant they rated, but only for consumers who are 'Employed' and have given a Food_Rating of 0 to at least one restaurant located in 'Ciudad Victoria'.
SELECT DISTINCT c.Consumer_ID, 
       c.Age, 
       r.Name AS Restaurant_Name
FROM Consumers c
JOIN Ratings ra 
    ON c.Consumer_ID = ra.Consumer_ID
JOIN Restaurants r 
    ON ra.Restaurant_ID = r.Restaurant_ID
WHERE c.Occupation = 'Employed'
  AND ra.Food_Rating = 0
  AND r.City = 'Ciudad Victoria';
  
## Advanced SQL Concepts: Derived Tables, CTEs, Window Functions, Views, Stored Procedures


## Using a CTE, find all consumers who live in 'San Luis Potosi'. Then, list their Consumer_ID, Age, and the Name of any Mexican restaurant they have rated with an Overall_Rating of 2.
WITH SanLuisConsumers AS (
    SELECT c.Consumer_ID, c.Age, rt.Restaurant_ID, rt.Overall_Rating
    FROM Consumers c
    INNER JOIN Ratings rt ON c.Consumer_ID = rt.Consumer_ID
    WHERE c.City = 'San Luis Potosi'
)
SELECT s.Consumer_ID,
       s.Age,
       r.Name AS Restaurant_Name
FROM SanLuisConsumers s
INNER JOIN Restaurants r ON s.Restaurant_ID = r.Restaurant_ID
WHERE s.Overall_Rating = 2;

## For each Occupation, find the average age of consumers. Only consider consumers who have made at least one rating. (Use a derived table to get consumers who have rated).
SELECT c.Occupation,
       AVG(c.Age) AS Avg_Age
FROM (
    SELECT DISTINCT Consumer_ID, Age, Occupation
    FROM Consumers
) c
JOIN (
    SELECT DISTINCT Consumer_ID
    FROM Ratings
) r ON c.Consumer_ID = r.Consumer_ID
GROUP BY c.Occupation;

## Using a CTE to get all ratings for restaurants in 'Cuernavaca', rank these ratings within each restaurant based on Overall_Rating (highest first). Display Restaurant_ID, Consumer_ID, Overall_Rating, and the RatingRank.
WITH CuernavacaRatings AS (
    SELECT rt.Restaurant_ID, rt.Consumer_ID, rt.Overall_Rating
    FROM Ratings rt
    JOIN Restaurants r ON rt.Restaurant_ID = r.Restaurant_ID
    WHERE r.City = 'Cuernavaca'
)
SELECT *,
       RANK() OVER (PARTITION BY Restaurant_ID ORDER BY Overall_Rating DESC) AS RatingRank
FROM CuernavacaRatings;

## For each rating, show the Consumer_ID, Restaurant_ID, Overall_Rating, and also display the average Overall_Rating given by that specific consumer across all their ratings.
WITH ConsumerRatings AS (
    SELECT Consumer_ID, Restaurant_ID, Overall_Rating
    FROM Ratings
)
SELECT Consumer_ID,
       Restaurant_ID,
       Overall_Rating,
       AVG(Overall_Rating) OVER (PARTITION BY Consumer_ID) AS Avg_Consumer_Rating
FROM ConsumerRatings;

## Using a CTE, identify students who have a 'Low' budget. Then, for each of these students, list their top 3 most preferred cuisines based on the order they appear in the Consumer_Preferences table (assuming no explicit preference order, use Consumer_ID, Preferred_Cuisine to define order for ROW_NUMBER).
WITH LowBudgetStudents AS (
    SELECT c.Consumer_ID, c.Age
    FROM Consumers c
    WHERE c.Occupation = 'Student'
      AND c.Budget = 'Low'
),
RankedPreferences AS (
    SELECT lb.Consumer_ID,
           cp.Preferred_Cuisine,
           ROW_NUMBER() OVER (
               PARTITION BY lb.Consumer_ID 
               ORDER BY cp.Consumer_ID, cp.Preferred_Cuisine
           ) AS rn
    FROM LowBudgetStudents lb
    INNER JOIN Consumer_Preferences cp 
        ON lb.Consumer_ID = cp.Consumer_ID
)
SELECT Consumer_ID,
       Preferred_Cuisine
FROM RankedPreferences
WHERE rn <= 3
ORDER BY Consumer_ID, rn;

##Consider all ratings made by 'Consumer_ID' = 'U1008'. For each rating, show the Restaurant_ID, Overall_Rating, and the Overall_Rating of the next restaurant they rated (if any), ordered by Restaurant_ID (as a proxy for time if rating time isn't available). Use a derived table to filter for the consumer's ratings first.
WITH ConsumerRatings AS (
    SELECT *
    FROM Ratings
    WHERE Consumer_ID = 'U1008'
)
SELECT Restaurant_ID,
       Overall_Rating,
       LEAD(Overall_Rating) OVER (ORDER BY Restaurant_ID) AS Next_Rating
FROM ConsumerRatings
ORDER BY Restaurant_ID;

##Create a VIEW named HighlyRatedMexicanRestaurants that shows the Restaurant_ID, Name, and City of all Mexican restaurants that have an average Overall_Rating greater than 1.5.
CREATE VIEW HighlyRatedMexicanRestaurants AS
SELECT 
    r.Restaurant_ID,
    r.Name,
    r.City
FROM Restaurants r
JOIN Restaurant_Cuisines rc
    ON r.Restaurant_ID = rc.Restaurant_ID
JOIN Ratings ra
    ON r.Restaurant_ID = ra.Restaurant_ID
WHERE rc.Cuisine = 'Mexican'
GROUP BY r.Restaurant_ID, r.Name, r.City
HAVING AVG(ra.Overall_Rating) > 1.5;

SELECT * FROM HighlyRatedMexicanRestaurants;

## First, ensure the HighlyRatedMexicanRestaurants view from Q7 exists. Then, using a CTE to find consumers who prefer 'Mexican' cuisine, list those consumers (Consumer_ID) who have not rated any restaurant listed in the HighlyRatedMexicanRestaurants view.

WITH MexicanConsumers AS (
    SELECT cp.Consumer_ID
    FROM Consumer_Preferences cp
    WHERE cp.Preferred_Cuisine = 'Mexican'
)
SELECT mc.Consumer_ID
FROM MexicanConsumers mc
WHERE mc.Consumer_ID NOT IN (
    SELECT r.Consumer_ID
    FROM Ratings r
    JOIN HighlyRatedMexicanRestaurants h
        ON r.Restaurant_ID = h.Restaurant_ID
);

## Create a stored procedure GetRestaurantRatingsAboveThreshold that accepts a Restaurant_ID and a minimum Overall_Rating as input. It should return the Consumer_ID, Overall_Rating, Food_Rating, and Service_Rating for that restaurant where the Overall_Rating meets or exceeds the threshold.

DELIMITER //

CREATE PROCEDURE GetRestaurantRatingsAboveThreshold (
    IN p_Restaurant_ID INT,
    IN p_Min_Overall_Rating INT
)
BEGIN
    SELECT 
        Consumer_ID,
        Overall_Rating,
        Food_Rating,
        Service_Rating
    FROM Ratings
    WHERE Restaurant_ID = p_Restaurant_ID
      AND Overall_Rating >= p_Min_Overall_Rating;
END //

DELIMITER ;

SELECT Restaurant_ID, Overall_Rating
FROM Ratings
LIMIT 5;

CALL GetRestaurantRatingsAboveThreshold(135085, 0);

##Identify the top 2 highest-rated (by Overall_Rating) restaurants for each cuisine type. If there are ties in rating, include all tied restaurants. Display Cuisine, Restaurant_Name, City, and Overall_Rating.
## by using deriveed table
SELECT Cuisine, Restaurant_Name, City, Overall_Rating
FROM (
    SELECT 
        rc.Cuisine,
        r.Name AS Restaurant_Name,           
        r.City,
        ra.Overall_Rating,
        DENSE_RANK() OVER (PARTITION BY rc.Cuisine ORDER BY ra.Overall_Rating DESC) AS rank_num
    FROM Restaurants r
    JOIN Restaurant_Cuisines rc ON r.Restaurant_ID = rc.Restaurant_ID
    JOIN Ratings ra ON r.Restaurant_ID = ra.Restaurant_ID
) AS ranked
WHERE rank_num <= 2
ORDER BY Cuisine, Overall_Rating DESC;  

## First, create a VIEW named ConsumerAverageRatings that lists Consumer_ID and their average Overall_Rating. Then, using this view and a CTE, find the top 5 consumers by their average overall rating. For these top 5 consumers, list their Consumer_ID, their average rating, and the number of 'Mexican' restaurants they have rated.

##  create a VIEW named ConsumerAverageRatings that lists Consumer_ID and their average Overall_Rating 
CREATE OR REPLACE VIEW ConsumerAverageRatings AS
SELECT 
    Consumer_ID,
    AVG(Overall_Rating) AS Avg_Overall_Rating
FROM Ratings
GROUP BY Consumer_ID;

## Then, using this view and a CTE, find the top 5 consumers by their average overall rating. For these top 5 consumers, list their Consumer_ID, their average rating, and the number of 'Mexican' restaurants they have rated.
WITH TopConsumers AS (
    SELECT *
    FROM ConsumerAverageRatings
    ORDER BY Avg_Overall_Rating DESC
    LIMIT 5
)
SELECT 
    tc.Consumer_ID,
    tc.Avg_Overall_Rating,
    COUNT(rc.Restaurant_ID) AS Mexican_Rated_Count
FROM TopConsumers tc
JOIN Ratings r ON tc.Consumer_ID = r.Consumer_ID
JOIN Restaurant_Cuisines rc ON r.Restaurant_ID = rc.Restaurant_ID
WHERE rc.Cuisine = 'Mexican'
GROUP BY tc.Consumer_ID, tc.Avg_Overall_Rating
ORDER BY tc.Avg_Overall_Rating DESC;

## Create a stored procedure named GetConsumerSegmentAndRestaurantPerformance that accepts a Consumer_ID as input.
## 1.The procedure should:
##Determine the consumer's "Spending Segment" based on their Budget:
  'Low' -> 'Budget Conscious'
  'High' -> 'Premium Spender'
   NULL or other -> 'Unknown Budget'
   
##2.For all restaurants rated by this consumer:
List the Restaurant_Name.
The Overall_Rating given by this consumer.
The average Overall_Rating this restaurant has received from all consumers (not just the input consumer).
A "Performance_Flag" indicating if the input consumer's rating for that restaurant is 'Above Average', 'At Average', or 'Below Average' compared to the restaurant's overall average rating.
Rank these restaurants for the input consumer based on the Overall_Rating they gave (highest rating = rank 1).

DELIMITER $$

CREATE PROCEDURE GetConsumerSegmentAndRestaurantPerformance (
    IN input_consumer_id VARCHAR(10)
)
BEGIN

      ##PART 1: Spending Segment
	
    SELECT 
        Consumer_ID,
        Budget,
        CASE
            WHEN Budget = 'Low' THEN 'Budget Conscious'
            WHEN Budget = 'Medium' THEN 'Moderate Spender'
            WHEN Budget = 'High' THEN 'Premium Spender'
            ELSE 'Unknown Budget'
        END AS Spending_Segment
    FROM Consumers
    WHERE Consumer_ID = input_consumer_id;

      ## PART 2: Restaurant Performance
       
    WITH RestaurantAvg AS (
        SELECT 
            Restaurant_ID,
            AVG(Overall_Rating) AS Avg_Rating
        FROM Ratings
        GROUP BY Restaurant_ID
    )
    SELECT
        r.Name AS Restaurant_Name,
        ra.Overall_Rating AS Consumer_Rating,
        avg_r.Avg_Rating,
        CASE
            WHEN ra.Overall_Rating > avg_r.Avg_Rating THEN 'Above Average'
            WHEN ra.Overall_Rating = avg_r.Avg_Rating THEN 'At Average'
            ELSE 'Below Average'
        END AS Performance_Flag,
        DENSE_RANK() OVER (ORDER BY ra.Overall_Rating DESC) AS Rating_Rank
    FROM Ratings ra
    JOIN Restaurants r 
        ON ra.Restaurant_ID = r.Restaurant_ID
    JOIN RestaurantAvg avg_r 
        ON ra.Restaurant_ID = avg_r.Restaurant_ID
    WHERE ra.Consumer_ID = input_consumer_id;

END $$

DELIMITER ;

CALL GetConsumerSegmentAndRestaurantPerformance('U1005');

drop database RESTUARANT_CONSUMER;


SELECT * FROM CONSUMERS;
SELECT * FROM RATINGS;
SELECT * FROM RESTAURANTS;
SELECT * FROM restaurant_cuisines;
SELECT * FROM Consumer_Preferences;

       







































