use sakila;
-- 1  case statement   
# column for 'Late', 'Ontime', or 'Never'. (42 rows)
select rental_date, return_date, title, 
	case
    WHEN rental_rate < amount THEN 'Ontime'
	WHEN rental_rate > amount THEN 'Late'
	ELSE 'Never' END as pmt_status
from rental join inventory using (inventory_id) join film using (film_id) join payment using (rental_id)
where rental.customer_id = 236;


-- ------------------------------------------------
-- 2 best customers - window function
select * from 
(select rank() over (partition by store_id order by count(rental_id) DESC) as per_store_rank,
customer_id, store_id, first_name, last_name, count(rental_id) as per_store
FROM customer
join rental using (customer_id)
group by customer_id, store_id) as t
where per_store >= 15;


-- ------------------------------------------------
-- 3
create view all_movies as
select title, rating,
	CASE
	WHEN "2005-08-20" between rental_date and return_date THEN 'No'
	ELSE 'Yes' END as available
from inventory join film using (film_id) join film_category using (film_id) join category using (category_id) join rental using (inventory_id)
where store_id = 1 and name = "Horror";

select distinct title, rating, available 
from all_movies
where available = "Yes"
group by title, rating, available;


-- ---------------------------------------------------
-- 4 view
SELECT ROW_NUMBER() OVER (PARTITION BY title) AS copy_num,
title, inventory.store_id,
	CASE 
	WHEN "2005-08-01" between rental_date and return_date THEN email
    ELSE "Not Rented" END AS person_email
from inventory
join film using (film_id) join film_category using (film_id) 
join category using (category_id) join rental using (inventory_id) join customer using (customer_id)
where category.name = "Music" and inventory.store_id = 1
order by title;

-- --------------------------------------------------
-- 5 Late fees probably are not being recorded as part of the rental amount.
# A credit of $5 probably represents that a person has had to pay $5 in late fees
# sample customer id = 318

CREATE VIEW before_cumulative as 
select rental_date as trans_date, case when amount > 0 then "Rental" else "Payment" end as trans_descr,
rental_id, title, rental_rate as amt
from inventory
join film using (film_id) join film_category using (film_id) join rental using (inventory_id) join payment using (rental_id)
where rental.customer_id = 318

union all

select payment_date as trans_date, case when amount * -1 > 0 then "Rental" else "Payment" end as trans_descr,
rental_id, title, (amount * -1) as amt
from inventory
join film using (film_id) join film_category using (film_id) join rental using (inventory_id) join payment using (rental_id)
where rental.customer_id = 318
order by trans_date, amt desc;

# partitioning
select *,
sum(round(amt,2)) over (partition by title order by trans_date, amt desc rows between unbounded preceding and current row) as balance
from before_cumulative
order by trans_date, amt desc;


-- ---------------------------------------------------
-- 6

# how many times has a person rented a film
CREATE VIEW weird_people as 
select email, title, count(title) as how_often
FROM customer
join rental using (customer_id)
join inventory using (inventory_id)
join film using (film_id)
group by email, title
having how_often > 1;

# how many times someone was on the list
CREATE VIEW true_weird_people as 
select email, count(*) as times_being_weird 
from weird_people
group by email
having times_being_weird > 2;

# Per title
select * from 
(select ROW_NUMBER() over (partition by email order by how_often DESC) as movie_rank,
email, title, how_often
FROM weird_people
where email in (select email from true_weird_people)
group by email, title)
as t
where movie_rank < 3;

-- -----------------------------------------------------
# 7 
WITH RECURSIVE cte_classes AS
(SELECT course_id, course_desc, prereq_course_id, 1 AS semester                          # base case
FROM prerequisite join course using (course_id) 
WHERE course_id = "MATH 1271" OR course_id = "CSCI 1133"                                 # class without a pre
UNION ALL
# for each round - add 1 to base case
SELECT e.course_id, course.course_desc, e.prereq_course_id, c.semester+1 AS semester
  FROM prerequisite AS e join course using (course_id)
JOIN cte_classes AS c ON c.course_id = e.prereq_course_id                              # top class = below class
)
SELECT *  FROM cte_classes;

-- --------------------------------------------------------
# 8
-- List the order number, product code, and price (each) of all order details for customer number 131. Include
-- an additional column, discount, that indicates "Yes" if that particular product was sold to the customer at
-- a price less than the manufacturer's suggested retail price (MSRP).
use classicmodels;

select * from products;

select orderNumber, productCode, priceEach,
	CASE WHEN MSRP > priceEach THEN "Yes"
    else "No" end as discount
from customers
join orders using (customerNumber)
join orderdetails using (orderNumber)
join products using (productCode)
where customerNumber = 131;

-- -----------------------------------------------------------------
# 9
# just the payments
DROP VIEW IF EXISTS payments_made;
CREATE VIEW payments_made as 
select customerNumber, checkNumber as trans_number, paymentDate as trans_date, (-1 * amount) as total,
	case when -1 * amount < 0 then "Payment"
	else "Order" end as trans_type
from payments join customers using (customerNumber) join orders using (customerNumber) join orderdetails using (orderNumber)
where customerNumber = 198 or customerNumber = 381
group by customerNumber, trans_number;

# unioning the tables
DROP VIEW IF EXISTS whole_table;
CREATE VIEW whole_table as 
select customerNumber, orderNumber as trans_number, orderDate as trans_date, round(sum(priceEach * quantityOrdered),2) as total,
	case when sum(priceEach * quantityOrdered) > 0 then "Order"
	else "Payment" end as trans_type
from orders join orderdetails using (orderNumber)
where customerNumber = 198 or customerNumber = 381
group by customerNumber, trans_number, trans_date
union all 
select * from payments_made;

# partitioning
select *,
sum(round(total,2)) over (partition by customerNumber order by trans_date rows between unbounded preceding and current row) as balance
from whole_table
order by trans_date;
                                
-- ---------------------------------
# 10 I followed the template from examples folder. Got most ppl correct, couldn't get a couple people right though

# Total sales per person - includes all employees
CREATE VIEW all_emps as 
select employeeNumber, lastName, firstName, reportsTo, round(sum(priceEach * quantityOrdered),2) as total_sales
from employees as e left join customers as c on c.salesRepEmployeeNumber = e.employeeNumber 
left join orders using (customerNumber) left join orderdetails using (orderNumber)
group by employeeNumber, lastName, firstName, reportsTo;

# Joining sales with original table
create view with_sales as
select employeeNumber, e.firstName, e.lastName, e.jobTitle, e.reportsTo, e.officeCode, total_sales
from employees as e join all_emps using (employeeNumber);

WITH RECURSIVE employee_paths AS
(SELECT employeeNumber, firstName, lastName, reportsTo, total_sales as total_sales
  FROM with_sales WHERE reportsTo IS NULL
UNION ALL
SELECT e.employeeNumber, e.firstName, e.lastName, e.total_sales, e.reportsTo, total_sales+total_sales as total_sales
  FROM employees e JOIN employee_paths ep ON ep.employeeNumber = e.reportsTo
)
SELECT employeeNumber, firstName, lastName, total_sales
  FROM with_sales
ORDER BY total_sales;






