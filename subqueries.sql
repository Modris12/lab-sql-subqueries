use sakila;

select * from film;
select * from inventory;

select
	f.title,
    sum(case when i.store_id > 0 then 1 else 0 end) as availability
from 
	sakila.film as f
join 
	sakila.inventory as i on f.film_id = i.film_id
where 
	f.title = "Hunchback Impossible";

select * from film;
select * from inventory;

SELECT 
    f.title,
    f.length
from
    sakila.film AS f
where 
	f.length > ( select avg(length) from sakila.film)
order by length desc;

select * from film;
select * from actor;
select * from film_actor;

select
	f.title,
    concat(a.first_name, " ", a.last_name) as actor_name
from
	sakila.film as f
join
	sakila.film_actor as fa on f.film_id = fa.film_id
join
	sakila.actor as a on fa.actor_id = a.actor_id
    
where 
	f.title = "Alone Trip";

SELECT 
    CONCAT(a.first_name, ' ', a.last_name) AS actor_name
FROM 
    sakila.actor AS a
WHERE 
    a.actor_id IN (
        SELECT fa.actor_id
        FROM sakila.film_actor AS fa
        JOIN sakila.film AS f ON fa.film_id = f.film_id
        WHERE f.title = 'Alone Trip'
    );

select * from category;
select * from film;
select * from film_category;


select
	f.title
from
	sakila.film as f
where 
	f.film_id in (
    select fc.film_id
    from sakila.film_category as fc
    join sakila.category as c on fc.category_id = c.category_id
    where c.name = 'Family');

select * from customer;
select * from address;
select * from country;
select * from city;

select 
	concat(c.first_name, " ", c.last_name) as customer_name,
    c.email as customer_email
from
	sakila.customer as c
join sakila.address as a on c.address_id = a.address_id
join city as ci on a.city_id = ci.city_id
join country as co on  ci.country_id = co.country_id
where 
	co.country = 'Canada'; 

SELECT 
    concat(c.first_name, " ", c.last_name) as customer_name,
    email
FROM customer as c
WHERE address_id IN (
    SELECT address_id
    FROM address
    WHERE city_id IN (
        SELECT city_id
        FROM city
        WHERE country_id IN (
            SELECT country_id
            FROM country
            WHERE country = 'Canada'
        )
    )
);
	
select * from actor;
select * from film_actor;
select * from film;


SELECT
    CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
    COUNT(fa.film_id) AS film_count,
    GROUP_CONCAT(f.title SEPARATOR ', ') AS film_titles
FROM sakila.actor AS a
JOIN sakila.film_actor AS fa ON a.actor_id = fa.actor_id
JOIN sakila.film AS f ON fa.film_id = f.film_id
GROUP BY a.actor_id
ORDER BY film_count DESC
LIMIT 1;

SELECT
    CONCAT(a.first_name, ' ', a.last_name) AS actor_name,
    counts.film_count,
    (SELECT GROUP_CONCAT(f.title SEPARATOR ', ')
     FROM sakila.film AS f
     JOIN sakila.film_actor AS fa2 ON f.film_id = fa2.film_id
     WHERE fa2.actor_id = a.actor_id) AS film_titles
FROM sakila.actor AS a
JOIN (
    SELECT actor_id, COUNT(*) AS film_count
    FROM sakila.film_actor
    GROUP BY actor_id
    ORDER BY film_count DESC
    LIMIT 1
) AS counts ON a.actor_id = counts.actor_id;

select * from customer;
select * from payment;
select * from rental;
select * from inventory;
select * from film;

SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    total_payment,
    GROUP_CONCAT(DISTINCT f.title ORDER BY f.title SEPARATOR ', ') AS film_titles
FROM sakila.customer AS c
JOIN (
    SELECT customer_id, SUM(amount) AS total_payment
    FROM sakila.payment
    GROUP BY customer_id
    ORDER BY total_payment DESC
    LIMIT 1
) AS p ON c.customer_id = p.customer_id
JOIN sakila.rental AS r ON c.customer_id = r.customer_id
JOIN sakila.inventory AS i ON r.inventory_id = i.inventory_id
JOIN sakila.film AS f ON i.film_id = f.film_id
GROUP BY c.customer_id;

select * from customer;
select * from payment;

SELECT
	c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    tot.total_amount_spent
from (
    SELECT 
        customer_id, 
        SUM(amount) AS total_amount_spent
    FROM sakila.payment
    GROUP BY customer_id
    order by total_amount_spent desc
    ) as tot
JOIN sakila.customer AS c ON tot.customer_id = c.customer_id
WHERE tot.total_amount_spent > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(amount) AS customer_total
        FROM sakila.payment
        GROUP BY customer_id
    ) AS all_totals
);


SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    tot.total_amount_spent
FROM (
    SELECT 
        customer_id, 
        SUM(amount) AS total_amount_spent
    FROM sakila.payment
    GROUP BY customer_id
    order by total_amount_spent desc
) AS tot
JOIN sakila.customer c ON tot.customer_id = c.customer_id
WHERE tot.total_amount_spent > (
    SELECT AVG(customer_total)
    FROM (
        SELECT SUM(amount) AS customer_total
        FROM sakila.payment
        GROUP BY customer_id
    ) AS all_totals
);