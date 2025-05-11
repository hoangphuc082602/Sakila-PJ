# Sakila movie rental store Data Analysis using SQL

![](https://github.com/najirh/netflix_sql_project/blob/main/logo.png)

## Overview
This project involves a comprehensive analysis of movie rental stores shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types.
- Identify the most common ratings for movies.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Sakila Database](https://downloads.mysql.com/docs/sakila-db.zip)

## Schema
### TABLE actor

```sql
DROP TABLE IF EXISTS `actor`;
CREATE TABLE actor (
  actor_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (actor_id),
  KEY idx_actor_last_name (last_name)
);
```
### TABLE adress
```sql
DROP TABLE IF EXISTS `address`;
CREATE TABLE address (
  `address_id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `address` varchar(50) NOT NULL,
  `address2` varchar(50) DEFAULT NULL,
  `district` varchar(20) NOT NULL,
  `city_id` smallint unsigned NOT NULL,
  `postal_code` varchar(10) DEFAULT NULL,
  `phone` varchar(20) NOT NULL,
  `location` geometry NOT NULL
  `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`address_id`),
  KEY `idx_fk_city_id` (`city_id`),
  SPATIAL KEY `idx_location` (`location`),
  CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON DELETE RESTRICT ON UPDATE CASCADE
);
```
### TABLE category
```sql
DROP TABLE IF EXISTS 'category';
CREATE TABLE category (
  category_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name VARCHAR(25) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (category_id)
);
```
### TABLE city
```sql
DROP TABLE IF EXISTS 'city';
CREATE TABLE city (
  city_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  city VARCHAR(50) NOT NULL,
  country_id SMALLINT UNSIGNED NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (city_id),
  KEY idx_fk_country_id (country_id),
  CONSTRAINT `fk_city_country` FOREIGN KEY (country_id) REFERENCES country (country_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
```
### TABLE country
```sql
DROP TABLE IF EXISTS 'country';
CREATE TABLE country (
  country_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  country VARCHAR(50) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (country_id)
);
```
### TABLE customer
```sql
DROP TABLE IF EXISTS 'customer';
CREATE TABLE customer (
  customer_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  store_id TINYINT UNSIGNED NOT NULL,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  email VARCHAR(50) DEFAULT NULL,
  address_id SMALLINT UNSIGNED NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  create_date DATETIME NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (customer_id),
  KEY idx_fk_store_id (store_id),
  KEY idx_fk_address_id (address_id),
  KEY idx_last_name (last_name),
  CONSTRAINT fk_customer_address FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_customer_store FOREIGN KEY (store_id) REFERENCES store (store_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
```
### TABLE film
```sql
DROP TABLE IF EXISTS 'film';
CREATE TABLE film (
  film_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  title VARCHAR(128) NOT NULL,
  description TEXT DEFAULT NULL,
  release_year YEAR DEFAULT NULL,
  language_id TINYINT UNSIGNED NOT NULL,
  original_language_id TINYINT UNSIGNED DEFAULT NULL,
  rental_duration TINYINT UNSIGNED NOT NULL DEFAULT 3,
  rental_rate DECIMAL(4,2) NOT NULL DEFAULT 4.99,
  length SMALLINT UNSIGNED DEFAULT NULL,
  replacement_cost DECIMAL(5,2) NOT NULL DEFAULT 19.99,
  rating ENUM('G','PG','PG-13','R','NC-17') DEFAULT 'G',
  special_features SET('Trailers','Commentaries','Deleted Scenes','Behind the Scenes') DEFAULT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (film_id),
  KEY idx_title (title),
  KEY idx_fk_language_id (language_id),
  KEY idx_fk_original_language_id (original_language_id),
  CONSTRAINT fk_film_language FOREIGN KEY (language_id) REFERENCES language (language_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_film_language_original FOREIGN KEY (original_language_id) REFERENCES language (language_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
```
### TABLE film_actor
```sql
DROP TABLE IF EXISTS 'film_actor';
CREATE TABLE film_actor (
  actor_id SMALLINT UNSIGNED NOT NULL,
  film_id SMALLINT UNSIGNED NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (actor_id,film_id),
  KEY idx_fk_film_id (`film_id`),
  CONSTRAINT fk_film_actor_actor FOREIGN KEY (actor_id) REFERENCES actor (actor_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_film_actor_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
```
### TABLE film_category
```sql
DROP TABLE IF EXISTS 'film_category';
CREATE TABLE film_category (
  film_id SMALLINT UNSIGNED NOT NULL,
  category_id TINYINT UNSIGNED NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (film_id, category_id),
  CONSTRAINT fk_film_category_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_film_category_category FOREIGN KEY (category_id) REFERENCES category (category_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
```
### TABLE film_text
```sql
DROP TABLE IF EXISTS 'film_text';
CREATE TABLE film_text (
  film_id SMALLINT UNSIGNED NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  PRIMARY KEY  (film_id),
  FULLTEXT KEY idx_title_description (title,description)
);
```
### TABLE inventory
```sql
DROP TABLE IF EXISTS 'inventory';
CREATE TABLE inventory (
  inventory_id MEDIUMINT UNSIGNED NOT NULL AUTO_INCREMENT,
  film_id SMALLINT UNSIGNED NOT NULL,
  store_id TINYINT UNSIGNED NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (inventory_id),
  KEY idx_fk_film_id (film_id),
  KEY idx_store_id_film_id (store_id,film_id),
  CONSTRAINT fk_inventory_store FOREIGN KEY (store_id) REFERENCES store (store_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_inventory_film FOREIGN KEY (film_id) REFERENCES film (film_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
```
### TABLE language
```sql
DROP TABLE IF EXISTS 'language';
CREATE TABLE language (
  language_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  name CHAR(20) NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (language_id)
);
```
### TABLE payment
```sql
DROP TABLE IF EXISTS 'payment';
CREATE TABLE payment (
  payment_id SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  customer_id SMALLINT UNSIGNED NOT NULL,
  staff_id TINYINT UNSIGNED NOT NULL,
  rental_id INT DEFAULT NULL,
  amount DECIMAL(5,2) NOT NULL,
  payment_date DATETIME NOT NULL,
  last_update TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (payment_id),
  KEY idx_fk_staff_id (staff_id),
  KEY idx_fk_customer_id (customer_id),
  CONSTRAINT fk_payment_rental FOREIGN KEY (rental_id) REFERENCES rental (rental_id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_payment_customer FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_payment_staff FOREIGN KEY (staff_id) REFERENCES staff (staff_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
```
### TABLE rental
```sql
DROP TABLE IF EXISTS 'rental';
CREATE TABLE rental (
  rental_id INT NOT NULL AUTO_INCREMENT,
  rental_date DATETIME NOT NULL,
  inventory_id MEDIUMINT UNSIGNED NOT NULL,
  customer_id SMALLINT UNSIGNED NOT NULL,
  return_date DATETIME DEFAULT NULL,
  staff_id TINYINT UNSIGNED NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (rental_id),
  UNIQUE KEY  (rental_date,inventory_id,customer_id),
  KEY idx_fk_inventory_id (inventory_id),
  KEY idx_fk_customer_id (customer_id),
  KEY idx_fk_staff_id (staff_id),
  CONSTRAINT fk_rental_staff FOREIGN KEY (staff_id) REFERENCES staff (staff_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_rental_inventory FOREIGN KEY (inventory_id) REFERENCES inventory (inventory_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_rental_customer FOREIGN KEY (customer_id) REFERENCES customer (customer_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
```
### TABLE staff
```sql
DROP TABLE IF EXISTS 'staff';
CREATE TABLE staff (
  staff_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  first_name VARCHAR(45) NOT NULL,
  last_name VARCHAR(45) NOT NULL,
  address_id SMALLINT UNSIGNED NOT NULL,
  picture BLOB DEFAULT NULL,
  email VARCHAR(50) DEFAULT NULL,
  store_id TINYINT UNSIGNED NOT NULL,
  active BOOLEAN NOT NULL DEFAULT TRUE,
  username VARCHAR(16) NOT NULL,
  password VARCHAR(40) CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (staff_id),
  KEY idx_fk_store_id (store_id),
  KEY idx_fk_address_id (address_id),
  CONSTRAINT fk_staff_store FOREIGN KEY (store_id) REFERENCES store (store_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_staff_address FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
```
### TABLE store
```sql
DROP TABLE IF EXISTS 'store';
CREATE TABLE store (
  store_id TINYINT UNSIGNED NOT NULL AUTO_INCREMENT,
  manager_staff_id TINYINT UNSIGNED NOT NULL,
  address_id SMALLINT UNSIGNED NOT NULL,
  last_update TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY  (store_id),
  UNIQUE KEY idx_unique_manager (manager_staff_id),
  KEY idx_fk_address_id (address_id),
  CONSTRAINT fk_store_staff FOREIGN KEY (manager_staff_id) REFERENCES staff (staff_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT fk_store_address FOREIGN KEY (address_id) REFERENCES address (address_id) ON DELETE RESTRICT ON UPDATE CASCADE
);
```
## Business Problems and Solutions

### 1. Count the Number of each rating

```sql
SELECT film_id, title, description
FROM film;
```

**Objective:** Determine the content in stores.

### 2. Find the Most Common Rating for Movies

```sql
SELECT rating, 
	   COUNT(*) AS numbers_of_movies
FROM film
GROUP BY rating
ORDER BY numbers_of_movies desc limit 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. Count the number of movies rented each month in a Specific Year (e.g., 2005)

```sql
SELECT count(rental_id) AS numbers_of_rental,
DATE_FORMAT(rental_date, '%m') AS month,
DATE_FORMAT(rental_date, '%Y') AS year
FROM rental
WHERE DATE_FORMAT(rental_date, '%Y') = '2005'
GROUP BY month
ORDER BY month;
```

**Objective:** Retrieve all movies rented each month in a specific year.

### 4. Find TOP 5 most rented movies of 2005.

```sql
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
```

**Objective:** Identify the TOP 5 most rented movies of 2005.

### 5. Identify all the movies that are longer than 120 minutes

```sql
SELECT title,
length
FROM film
WHERE length >=120;
```

**Objective:** Find all the movies longer that are than 120 minutes.

### 6. Find all the customer that live in London
```sql
SELECT first_name,
last_name,
city
FROM customer
JOIN city
ON customer.address_id=city.city_id
WHERE city='London';
```

**Objective:** Find all the customer that live in London

### 7. List the movie titles and category names of each movie.

```sql
SELECT title, 
name AS category
FROM film f
JOIN film_category fc
ON f.film_id=fc.film_id
JOIN category c
ON fc.category_id=c.category_id;
```

**Objective:** List all the movie's titles and category's names of each movies

### 8. List of movie titles and number of copies available in stores

```sql
SELECT f.film_id,
title,
COUNT(i.film_id) AS stock
FROM film f
LEFT JOIN inventory i
ON i.film_id=f.film_id
GROUP BY f.film_id;
```

**Objective:** Identify the number of copies each movies in stores.

### 9. Total revenue per customer

```sql
SELECT c.customer_id,
first_name,
last_name,
SUM(amount) AS total
FROM customer c
JOIN payment p
ON c.customer_id=p.customer_id
GROUP BY c.customer_id;
```

**Objective:** Knowing how much customers spent.

### 10. List of actors involved in movies in the category "Horror"

```sql
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
```

**Objective:** List of actors involved in movies in the category "Horror"

### 11. Calculate the average length of movies by rating

```sql
SELECT rating, 
AVG(length) AS avg_length
FROM film
GROUP BY rating;
```

**Objective:** Retrieve all the average length of movies by rating.

### 12. Find movies that have never been rented before

```sql
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
```

**Objective:** List content that have never been rented before.

### 13. Find all movies that are longer than the average length of all movies.

```sql
WITH avg_length AS(
SELECT avg(length) as avg_length
FROM film
)
SELECT film_id, title, length 
FROM film
CROSS JOIN avg_length
WHERE length >= avg_length;
```

**Objective:** Found all movies that longer than the average length of all movies.

### 14. Displays the customer's name, the title of the movie they rented, and the rental date

```sql
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
```

**Objective:** Showing the customer's name, the title of the movie they rented, and the rental date.

### 15. List customers who rented a movie for the first time within 7 days of signing up

```sql
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
```

**Objective:** Retrived all the customers who rented a movie for the first time within 7 days of signing up.
### 16. Find customers whose movie rentals have increased steadily over the months.
```sql
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
```
**Objective:** Identify customers whose number of rentals increased every month
## Findings and Conclusion

- **Content Distribution:** The dataset contains a diverse range of movies and TV shows with varying ratings and genres.
- **Common Ratings:** Insights into the most common ratings provide an understanding of the content's target audience.
- **Geographical Insights:** The top countries and the average content releases by India highlight regional content distribution.
- **Content Categorization:** Categorizing content based on specific keywords helps in understanding the nature of content available on Netflix.

This analysis provides a comprehensive view of Sakila's content and can help inform content strategy and decision-making.
