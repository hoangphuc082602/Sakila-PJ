-- 1. Count the Number of each rating

SELECT film_id, title, description
FROM film;

-- 2. Find the Most Common Rating for Movies

SELECT rating, 
       COUNT(*) AS numbers_of_movies
FROM film
GROUP BY rating
ORDER BY numbers_of_movies desc limit 1;

-- 3. Count the number of movies rented each month in a Specific Year (e.g., 2005)

SELECT count(rental_id) AS numbers_of_rental,
DATE_FORMAT(rental_date, '%m') AS month,
DATE_FORMAT(rental_date, '%Y') AS year
FROM rental
WHERE DATE_FORMAT(rental_date, '%Y') = '2005'
GROUP BY month
ORDER BY month;

-- 4. Find TOP 5 most rented movies of 2005.

SELECT f.film_id,
title,
DATE_FORMAT(rental_date, '%Y') AS year,
COUNT(rental_id) AS number_of_rental
FROM film f
JOIN inventory i
ON i.film_id=f.film_id
JOIN rental r
ON r.inventory_id=i.inventory_id
GROUP BY film_id
HAVING year = '2005'
ORDER BY number_of_rental DESC LIMIT 5;

-- 5. Identify all the movies that are longer than 120 minutes

SELECT title,
length
FROM film
WHERE length >=120;

-- 6. Find all the customer that live in London

SELECT first_name,
last_name,
city
FROM customer
JOIN city
ON customer.address_id=city.city_id
WHERE city='London';

-- 7. List the movie titles and category names of each movie.

SELECT title, 
name AS category
FROM film f
JOIN film_category fc
ON f.film_id=fc.film_id
JOIN category c
ON fc.category_id=c.category_id;

-- 8. List of movie titles and number of copies available in stores

SELECT f.film_id,
title,
COUNT(i.film_id) AS stock
FROM film f
LEFT JOIN inventory i
ON i.film_id=f.film_id
GROUP BY f.film_id;

-- 9. Total revenue per customer

SELECT c.customer_id,
first_name,
last_name,
SUM(amount) AS total
FROM customer c
JOIN payment p
ON c.customer_id=p.customer_id
GROUP BY c.customer_id;

-- 10. List of actors involved in movies in the category "Horror"

SELECT first_name,
last_name
FROM actor a
JOIN film_actor fa
ON fa.actor_id=a.actor_id
JOIN film f
ON f.film_id=fa.film_id
JOIN film_category fc
ON fc.film_id=f.film_id
JOIN category c
ON fc.category_id=c.category_id
WHERE name='Horror'
ORDER BY first_name, last_name;

-- 11. Calculate the average length of movies by rating

SELECT rating, 
AVG(length) AS avg_length
FROM film
GROUP BY rating;

-- 12. Find movies that have never been rented before

SELECT film_id, title 
FROM film
EXCEPT 
SELECT f.film_id,
title
FROM film f
JOIN inventory i
ON i.film_id=f.film_id
JOIN rental r
ON r.inventory_id=i.inventory_id;

-- 13. Find all movies that are longer than the average length of all movies.

WITH avg_length AS(
SELECT avg(length) as avg_length
FROM film
)
SELECT film_id, title, length 
FROM film
CROSS JOIN avg_length
WHERE length >= avg_length;

-- 14. Displays the customer's name, the title of the movie they rented, and the rental date

SELECT c.customer_id, 
first_name, 
last_name, 
title, 
rental_date
FROM customer c
JOIN rental r
ON r.customer_id=c.customer_id
JOIN inventory i
ON r.inventory_id=i.inventory_id
JOIN film f
ON i.film_id=f.film_id;

-- 15. List customers who rented a movie for the first time within 7 days of signing up

WITH first_day AS(
SELECT customer_id, rental_id, rental_date,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY rental_date) AS rn
FROM rental
)
SELECT c.customer_id, first_name, last_name
FROM customer c
JOIN first_day f
ON c.customer_id=f.customer_id
WHERE rn=1
AND DATEDIFF(create_date, rental_date) >=7;
-- 16. Find customers whose movie rentals have increased steadily over the months.
WITH rental_per_month AS(
    SELECT
        c.customer_id,
        c.first_name,
        c.last_name,
        DATE_FORMAT(r.rental_date, '%Y-%m') AS month,
        COUNT(*) AS rental_count
    FROM rental r
    JOIN customer c ON r.customer_id = c.customer_id
    GROUP BY c.customer_id, DATE_FORMAT(r.rental_date, '%Y-%m')
),
ranked_rental AS(
    SELECT
        customer_id,
        first_name,
        last_name,
        month,
        rental_count,
        ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY month) AS ranked
    FROM rental_per_month
),
growth_check AS(
    SELECT 
        r1.customer_id,
        r1.first_name,
        r1.last_name
    FROM ranked_rental r1
    JOIN ranked_rental r2 
    ON r1.customer_id = r2.customer_id 
	AND r1.ranked = r2.ranked - 1
    WHERE r2.rental_count > r1.rental_count
    GROUP BY r1.customer_id
    HAVING COUNT(*) = (
        SELECT COUNT(*) - 1
        FROM  ranked_rental r3
        WHERE r3.customer_id = r1.customer_id
    )
)
SELECT * 
FROM growth_check;
