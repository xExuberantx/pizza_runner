-- Table schema from https://8weeksqlchallenge.com/case-study-2/
CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');

--  >>>>Cleaning data from customer_orders and runner_orders<<<<

-- Replace 'null' and '' (empty strings) values with  NULL for exclusions
UPDATE pizza_runner.customer_orders
SET exclusions = NULL
WHERE exclusions IN ('null', '');

-- Replace 'null' and '' (empty strings) values with  NULL for extras
UPDATE pizza_runner.customer_orders
SET extras = NULL
WHERE extras IN ('null', '');

-- Replace 'null' and '' (empty strings) values with  NULL for cancellation 
UPDATE pizza_runner.runner_orders
SET cancellation = NULL
WHERE cancellation = 'null' or cancellation = '';

-- Replace 'null' values with  NULL for pickup_time
UPDATE pizza_runner.runner_orders
SET pickup_time = NULL
WHERE pickup_time = 'null';

-- Replace 'null' values with  NULL for distance
UPDATE pizza_runner.runner_orders
SET distance = NULL
WHERE distance = 'null';

-- Replace 'null' values with  NULL for duration
UPDATE pizza_runner.runner_orders
SET duration = NULL
WHERE duration = 'null';

-- Change pickup_type data type to TIMESTAMP (without the need of picking a timezone)
ALTER TABLE pizza_runner.runner_orders
ALTER COLUMN pickup_time TYPE TIMESTAMP USING pickup_time::TIMESTAMP;

-- Remove km and spaces from distance
UPDATE pizza_runner.runner_orders
SET distance = TRIM(' km' FROM distance);

-- Change distance data type to numeric
ALTER TABLE pizza_runner.runner_orders
ALTER COLUMN distance TYPE numeric USING distance::numeric;

-- Remove any form of 'minutes' from duration
UPDATE pizza_runner.runner_orders
SET duration = TRIM(' minutes' FROM duration);

-- Change duration data type to integer
ALTER TABLE pizza_runner.runner_orders
ALTER COLUMN duration TYPE integer USING duration::integer;

-- >>>>Exercises and questions<<<<

-- A. Pizza Metrics

-- 1. How many pizzas were ordered?
SELECT COUNT(*)
FROM pizza_runner.customer_orders;

-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id)
FROM pizza_runner.customer_orders;

-- 3. How many successful orders were delivered by each runner?
SELECT
    runner_id,
    COUNT(*)
FROM pizza_runner.runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id;

-- 4. How many of each type of pizza was delivered?
SELECT
    pizza_id,
    COUNT(*)
FROM pizza_runner.customer_orders co
JOIN pizza_runner.runner_orders ro
USING(order_id)
WHERE cancellation IS NULL
GROUP BY pizza_id;

-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
SELECT
    customer_id,
    pizza_name,
    COUNT(*)
FROM pizza_runner.customer_orders co
JOIN pizza_runner.pizza_names
USING(pizza_id)
GROUP BY customer_id, pizza_name
ORDER BY customer_id, pizza_name;

-- 6. What was the maximum number of pizzas delivered in a single order?
SELECT
    order_id,
    COUNT(pizza_id) as cnt
FROM pizza_runner.customer_orders co
JOIN pizza_runner.runner_orders ro
USING(order_id)
WHERE cancellation IS NULL
GROUP BY order_id
ORDER BY cnt DESC
LIMIT 1;

-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
SELECT
    customer_id,
    SUM(CASE WHEN exclusions IS NOT NULL OR  extras IS NOT NULL THEN 1 ELSE 0 END) as min_one_change,
    SUM(CASE WHEN exclusions IS     NULL AND extras IS     NULL THEN 1 ELSE 0 END) as no_changes
FROM pizza_runner.customer_orders co
JOIN pizza_runner.runner_orders ro
USING(order_id)
WHERE cancellation IS NULL
GROUP BY customer_id
ORDER BY customer_id;

-- 8. How many pizzas were delivered that had both exclusions and extras?
SELECT
    SUM(CASE WHEN exclusions IS NOT NULL AND extras IS NOT NULL THEN 1 ELSE 0 END) as excl_and_extras
FROM pizza_runner.customer_orders co
JOIN pizza_runner.runner_orders ro
USING(order_id)
WHERE cancellation IS NULL;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT
    EXTRACT('hour' FROM order_time) as hour_of_the_day,
    COUNT(*)
FROM pizza_runner.customer_orders
GROUP BY hour_of_the_day
ORDER BY hour_of_the_day;

-- 10. What was the volume of orders for each day of the week?
SELECT
    TO_CHAR(order_time, 'Day') as day_of_the_week,
    COUNT(DISTINCT order_id)
FROM pizza_runner.customer_orders
GROUP BY day_of_the_week;

-- B. Runner and Customer Experience

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT
    CASE WHEN registration_date BETWEEN '2021-01-01' AND '2021-01-07' THEN 1
         WHEN registration_date BETWEEN '2021-01-08' AND '2021-01-15' THEN 2
         END AS week_of_signup,
    COUNT(*)
FROM pizza_runner.runners
GROUP BY week_of_signup
ORDER BY week_of_signup;

-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
SELECT
    runner_id,
    EXTRACT('minutes' FROM AVG(pickup_time - order_time + INTERVAL '30 second')) as avg_time_to_pickup -- +30sec to round to minute
FROM pizza_runner.customer_orders
JOIN pizza_runner.runner_orders
USING(order_id)
WHERE cancellation IS NULL
GROUP BY runner_id
ORDER BY runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
-- There is no sufficient data to calculate the preparation time and confirm an existing relationship

-- 4. What was the average distance travelled for each customer?
SELECT
    customer_id,
    ROUND(AVG(distance), 2) as avg_distance
FROM pizza_runner.customer_orders co
JOIN pizza_runner.runner_orders ro
USING(order_id)
WHERE cancellation IS NULL
GROUP BY customer_id
ORDER BY customer_id;

-- 5. What was the difference between the longest and shortest delivery times for all orders?
SELECT MAX(delivery_time) - MIN(delivery_time) as longest_to_shortest_difference
FROM ( 
    SELECT
        DISTINCT order_id,
        -- Time from order to pickup + time from pickup to delivery
        pickup_time - order_time + (INTERVAL '1 minute' * duration) as delivery_time 
    FROM pizza_runner.customer_orders co
    JOIN pizza_runner.runner_orders ro
    USING(order_id)
    WHERE cancellation IS NULL) as dt;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
SELECT
    runner_id,
    ROUND(AVG(distance), 2) as avg_dist_km,
    ROUND(AVG(duration), 2) as avg_duration_m
FROM pizza_runner.runner_orders
WHERE cancellation IS NULL
GROUP BY runner_id

-- 7. What is the successful delivery percentage for each runner?
SELECT
    runner_id,
    ROUND(AVG(CASE WHEN cancellation IS NULL THEN 1 ELSE 0 END) * 100, 2) as succ_del_per
FROM pizza_runner.runner_orders
GROUP BY runner_id
ORDER BY runner_id

-- C. Ingredient Optimisation

-- * Creating alternative recipes table (with toppings description)
CREATE TABLE IF NOT EXISTS pizza_recipes_new as 
    SELECT
        pizza_id,
        topping_id,
        topping_name
    FROM (
        SELECT
            pizza_id,
            unnest(string_to_array(toppings, ', '))::integer as topping_id
        FROM pizza_runner.pizza_recipes
        ORDER BY pizza_id
    ) as new_recipes
    JOIN pizza_runner.pizza_toppings as pt
    USING(topping_id)
    ORDER BY pizza_id, topping_id

-- 1. What are the standard ingredients for each pizza?
SELECT
    pizza_id,
    pizza_name,
    topping_id,
    topping_name
FROM pizza_runner.pizza_recipes_new
JOIN pizza_runner.pizza_names
USING(pizza_id)


-- 2. What was the most commonly added extra?
SELECT
    topping_name,
    COUNT(*)
FROM (
    SELECT
        unnest(string_to_array(extras, ', '))::integer as extras
    FROM pizza_runner.customer_orders) e
JOIN pizza_runner.pizza_toppings t
ON e.extras=t.topping_id
GROUP BY topping_name
ORDER BY count DESC

-- 3. What was the most common exclusion?
SELECT
    topping_name,
    COUNT(*)
FROM (
    SELECT
        unnest(string_to_array(exclusions, ', '))::integer as exclusions
    FROM pizza_runner.customer_orders) e
JOIN pizza_runner.pizza_toppings t
ON e.exclusions=t.topping_id
GROUP BY topping_name
ORDER BY count DESC

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
--    > Meat Lovers
--    > Meat Lovers - Exclude Beef
--    > Meat Lovers - Extra Bacon
--    > Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
/*
SELECT 
    order_id,
    customer_id,
    pizza_id,
    pizza_name,
    exclusions,
    extras,
    order_time,
    pizza_name || CASE WHEN exclusions IS NULL AND extras IS NULL THEN ''
        ELSE ' - ' || CASE WHEN END
        as order_item
FROM pizza_runner.customer_orders
JOIN pizza_runner.pizza_names
USING(pizza_id)

-- exclusions comma separated
-- extras comma separated
*/

SELECT
    order_id,
    customer_id,
    pizza_id,
    pizza_name,
    exclusions,
    extras,
    order_time,
    pizza_name || CASE
                        WHEN exclusions IS NULL AND extras IS NULL THEN '' ELSE ' - ' ||
                  CASE  
                        WHEN '1' = ANY(exclusions) THEN 'Bacon'
                        WHEN '2' = ANY(exclusions) THEN 'BBQ Sauce'
                        WHEN '3' = ANY(exclusions) THEN 'Beef'
                        WHEN '4' = ANY(exclusions) THEN 'Cheese'
                        WHEN '5' = ANY(exclusions) THEN 'Chicken'
                        WHEN '6' = ANY(exclusions) THEN 'Mushrooms'
                        WHEN '7' = ANY(exclusions) THEN 'Onions'
                        WHEN '8' = ANY(exclusions) THEN 'Pepperoni'
                        WHEN '9' = ANY(exclusions) THEN 'Peppers'
                        WHEN '10' = ANY(exclusions) THEN 'Salami'
                        WHEN '11' = ANY(exclusions) THEN 'Tomatoes'
                        WHEN '12' = ANY(exclusions) THEN 'Tomato Sauce' END AS enamez
FROM (
    SELECT
        order_id,
        customer_id,
        pizza_id,
        pizza_name,
        string_to_array(exclusions, ', ') as exclusions,
        string_to_array(extras, ', ') as extras,
        order_time
    FROM pizza_runner.customer_orders
    JOIN pizza_runner.pizza_names
    USING(pizza_id)) as t



SELECT *
FROM pizza_runner.pizza_recipes_new
ORDER BY pizza_id, topping_id

-- Alternative way for exclusions and extras
WITH xyz as (
        SELECT
            order_id,
            customer_id,
            pizza_id,
            ROW_NUMBER() OVER (PARTITION BY order_id, customer_id ORDER BY order_id) as order_pizza_id,
            string_to_array(exclusions, ', ') as exclusions,
            string_to_array(extras, ', ') as extras,
            order_time
        FROM pizza_runner.customer_orders
),
    orders_unpacked as (
    SELECT
        order_id,
        customer_id,
        pizza_id,
        order_pizza_id,
        unnest(exclusions)::integer as exclusions,
        unnest(extras)::integer as extras,
        order_time
    FROM xyz
    UNION ALL
    SELECT
        order_id,
        customer_id,
        pizza_id,
        order_pizza_id,
        NULL::integer as exclusions,
        NULL::integer as extras,
        order_time
    FROM xyz
    WHERE exclusions IS NULL AND extras IS NULL

    ORDER BY order_id, order_pizza_id)

SELECT *
FROM orders_unpacked ou
--JOIN pizza_runner.pizza_toppings pt
--ON ou.exclusions=pt.topping_id OR ou.extras=pt.topping_id


-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any
--    relevant ingredients
--    > For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"

-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?