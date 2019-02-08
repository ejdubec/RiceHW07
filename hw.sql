USE sakila;

-- 1a
-- First and last names of actors in table actor
SELECT first_name, last_name
FROM actor;

-- 1b
-- First and last name of actor in single column UPPER case name it 'Actor Name'
SELECT UPPER(CONCAT(first_name, ' ', last_name)) as 'Actor Name'
FROM actor;

-- 2a 
-- Need id, FN, LN of actor named "Joe"
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

-- 2b
-- All actors whose last names contain 'GEN'
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%GEN%';

-- 2c
-- All actors whose last names contain 'LI' order by lastname, firstname
SELECT actor_id, first_name, last_name
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

-- 2d
-- use IN to display country_id, country of Afghanistan, Bangladesh, China
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a
-- create a 'decription' column in 'actor' with dtype BLOB
ALTER TABLE sakila.actor
ADD COLUMN `description` BLOB NULL AFTER `last_update`;

-- 3b
-- delete the description column
ALTER TABLE sakila.actor
DROP COLUMN description;

-- 4a
-- List the last names of actors and how many actors have that last name
SELECT last_name, COUNT(last_name) AS 'Number of Name'
FROM actor
GROUP BY last_name;

-- 4b
-- Same as 4a but only where count > 1
SELECT last_name, COUNT(last_name) AS NumLast
FROM actor
GROUP BY last_name
HAVING NumLast > 1;

-- 4c
-- change 'groucho williams' to 'harpo williams'
UPDATE actor
SET first_name = 'HARPO'
WHERE last_name = 'Williams' AND first_name = 'Groucho';

-- 4d
-- change all of the 'harpo' to 'groucho'
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO';

-- 5a
-- query to remake address table
-- SHOW CREATE TABLE address;
CREATE TABLE IF NOT EXISTS `address` (
  `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint(5) unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL,
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a
-- use JOIN to display address and FN, LN of staff members (tables address, staff)
SELECT a.address, s.first_name, s.last_name
FROM staff AS s
INNER JOIN address AS a
ON s.address_id = a.address_id;

-- 6b
-- use JOIN to display total amt rung up by staff in August 2005 (tables staff, payment)
-- NOTE fmt is YYYY-MM-DD HH:MM:SS
SELECT s.staff_id, s.first_name, s.last_name, SUM(p.amount)
FROM staff AS s
INNER JOIN payment AS p
ON s.staff_id = p.staff_id
WHERE p.payment_date LIKE '2005-08%'
GROUP BY s.staff_id;

-- 6c
-- List each film and number of actors for that film, inner join (tables film, film_actor)
SELECT f.title, COUNT(fa.actor_id)
FROM film AS f
INNER JOIN film_actor AS fa
ON f.film_id = fa.film_id
GROUP BY f.title;

-- 6d
-- How many copies of 'Hunchback Impossible' are in inventory
SELECT f.title, COUNT(i.inventory_id)
FROM film AS f
INNER JOIN inventory AS i
ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible'
GROUP BY f.title;

-- 6e
-- use tbls payment, customer and JOIN to list total paid by each customer listed by last name
SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount)
FROM customer AS c
INNER JOIN payment AS p
ON c.customer_id = p.customer_id
GROUP BY c.customer_id
ORDER BY c.last_name;

-- 7a
-- use subqueries to display titles of movies starting with K and Q in English
SELECT title
FROM film
WHERE (title LIKE 'K%' OR title LIKE 'Q%')
AND language_id = (
	SELECT language_id FROM language WHERE name = 'English'
);

-- 7b
-- use subqueries to display all actors who appear in 'Alone Trip'
SELECT first_name, last_name
FROM actor
WHERE actor_id IN (
	SELECT actor_id
    FROM film_actor
    WHERE film_id = (
		SELECT film_id
        FROM film
        WHERE title = 'Alone Trip'
	)
);

-- 7c
-- use joins to get the names and email addresses of all canadian customers
SELECT c.first_name, c.last_name, c.email
FROM customer AS c
INNER JOIN address AS a
ON c.address_id = a.address_id
INNER JOIN city AS ct
ON a.city_id = ct.city_id
INNER JOIN country AS cy
ON ct.country_id = cy.country_id
WHERE cy.country = 'Canada';

-- 7d
-- identify all films categorized as 'family'
SELECT f.title
FROM film AS f
INNER JOIN film_category AS fc
ON f.film_id = fc.film_id
INNER JOIN category AS cat
ON fc.category_id = cat.category_id
WHERE cat.name = 'Family';

-- 7e
-- display most frequently rented films in descending order
SELECT f.title, COUNT(r.rental_id) AS Frequency
FROM film AS f
INNER JOIN inventory AS i
ON f.film_id = i.film_id
INNER JOIN rental AS r
ON i.inventory_id = r.inventory_id
GROUP BY f.title
ORDER BY Frequency DESC;

-- 7f
-- how much business in dollars from each store
SELECT c.store_id, SUM(p.amount)
FROM payment AS p
INNER JOIN customer AS c
ON p.customer_id = c.customer_id
GROUP BY c.store_id;

-- 7g
-- display for each store its store id, city, country
SELECT s.store_id, c.city, cy.country
FROM store AS s
INNER JOIN address AS a
ON s.address_id = a.address_id
INNER JOIN city AS c
ON a.city_id = c.city_id
INNER JOIN country AS cy
ON c.country_id = cy.country_id;

-- 7h
-- top 5 categories by gross revenue in descending order
SELECT c.name, SUM(p.amount) AS GrossRevenue
FROM category AS c
INNER JOIN film_category AS fc
ON c.category_id = fc.category_id
INNER JOIN inventory AS i
ON fc.film_id = i.film_id
INNER JOIN rental AS r
ON i.inventory_id = r.inventory_id
INNER JOIN payment AS p
ON r.customer_id = p.customer_id
GROUP BY c.name
ORDER BY GrossRevenue DESC LIMIT 5;

-- 8a
-- create a view for 7h
CREATE VIEW SevenH AS
SELECT c.name, SUM(p.amount) AS GrossRevenue
FROM category AS c
INNER JOIN film_category AS fc
ON c.category_id = fc.category_id
INNER JOIN inventory AS i
ON fc.film_id = i.film_id
INNER JOIN rental AS r
ON i.inventory_id = r.inventory_id
INNER JOIN payment AS p
ON r.customer_id = p.customer_id
GROUP BY c.name
ORDER BY GrossRevenue DESC LIMIT 5;

-- 8b
-- Display the view 8a
SELECT * FROM SevenH;

-- 8c
-- get rid of the view from 8a
DROP VIEW SevenH;