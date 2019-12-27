# as a subquery - 1:52 Nov 4th
# https://dev.mysql.com/doc/refman/8.0/en/window-functions.html
# 1:54 for where windows are permitted Nov 4th

-- ----------------------------------------------------------------
-- TOP VENDORS PER STATE
-- basic
SELECT ROW_NUMBER() OVER (PARTITION BY vendor_state ORDER BY vendor_name) AS vendor_num,
       vendor_id, vendor_name, vendor_state
FROM vendors
ORDER BY vendor_state, vendor_name;

# keeping 0
select RANK() over (partition by vendor_state order by sum(line_item_amt) DESC) as vendor_rank,
vendor_name, vendor_state,
    case when SUM(line_item_amt) IS NULL then 0 
    else SUM(line_item_amt) end as total_business
FROM vendors
left join invoices using (vendor_id)
left join invoice_line_items using(invoice_id)
group by vendor_name;
-- ------------------------------------------
# using materialized table
select * from 
(select rank() over (partition by vendor_state order by sum(line_item_amt) DESC) as vendor_rank,
vendor_name, vendor_state,
	case when SUM(line_item_amt) IS NULL 
    then 0 else SUM(line_item_amt) end as total_business
FROM vendors
left join invoices using (vendor_id)
left join invoice_line_items using(invoice_id)
group by vendor_name) as t
where vendor_rank = 1;
-- ------------------------------------------
# common table expressions - able to join to themselves, good for recursion
-- filter based on result of window functions
with cte as
(select rank() over (partition by vendor_state order by sum(line_item_amt) DESC) as vendor_rank,
vendor_name, vendor_state,
	case when SUM(line_item_amt) IS NULL then 0 else SUM(line_item_amt) end as total_business
FROM vendors
left join invoices using (vendor_id)
left join invoice_line_items using(invoice_id)
group by vendor_name)
select * from cte where vendor_rank = 1 and total_business > 0 order by vendor_name;

-- ----------------------------------------------------------
-- Using a subquery w/window function
SELECT vendor_name, vendor_state,
	(SELECT SUM(line_item_amt) FROM invoice_line_items AS L 
	JOIN invoices AS I USING (invoice_id) 
	WHERE I.vendor_id = V.vendor_id) AS total_business,
	
    RANK() OVER (PARTITION BY vendor_state ORDER BY 
		(SELECT SUM(line_item_amt) 
		FROM invoice_line_items AS L 
		JOIN invoices AS I USING (invoice_id) 
		WHERE I.vendor_id = V.vendor_id) DESC) AS vendor_rank
FROM vendors AS V;
-- -----------------------------------------------------------------
  
-- top customers per store
SELECT I.store_id, customer_id, first_name, last_name, COUNT(*) as rentals,
	RANK() OVER (PARTITION BY I.store_id ORDER BY COUNT(*) DESC) AS cust_rank
  
  FROM rental AS R JOIN customer AS C USING (customer_id) JOIN inventory AS I USING (inventory_id)
GROUP BY I.store_id, customer_id, first_name, last_name
HAVING rentals >= 15
ORDER BY cust_rank, store_id;

-- ----------------------------------------------------------------------------------------------
-- Window function, case statement with null
-- copy number per title per store
SELECT F.title, I.store_id,
ROW_NUMBER() OVER (PARTITION BY I.store_id, I.film_id) as copy_number,
	CASE WHEN C.email IS NULL THEN '(not rented)'
	ELSE C.email END AS email
FROM film AS F 
JOIN inventory AS I USING (film_id)

LEFT JOIN rental AS R ON I.inventory_id = R.inventory_id AND '2005-8-1' BETWEEN R.rental_date AND R.return_date
LEFT JOIN customer AS C USING (customer_id)
WHERE F.film_id IN 
	(SELECT film_id FROM film_category WHERE category_id = 12)
ORDER BY title, store_id, copy_number;
  
  -- -------------------------------------------------------------------------------------------------------
use chinook;
-- hw rewrite
-- List each artist along with the number of months 
-- that artist appeared in the top 10 artists in terms of tracks sold
SELECT A.name, COUNT(T2.artistid) AS top_10
  FROM artist AS A
  LEFT JOIN (SELECT DISTINCT YEAR(I.invoicedate) as yr,
		       MONTH(I.invoicedate) as mnth,
               A.artistid
          FROM artist AS A
          JOIN album AS B USING (artistid)
          JOIN track AS T USING (albumid)
          JOIN invoiceline AS L USING (trackid)
          JOIN invoice AS I USING (invoiceid)
         WHERE EXISTS (SELECT * FROM 
								(SELECT A2.artistid, COUNT(invoicelineid) AS sales
	                             FROM artist AS A2
	                             JOIN album AS B2 USING (artistid)
	                             JOIN track AS T2 USING (albumid)
	                             JOIN invoiceline AS L2 USING (trackid)
	                             JOIN invoice AS I2 USING (invoiceid)
                                WHERE YEAR(I2.invoicedate) = YEAR(I.invoicedate)
                                  AND MONTH(I2.invoicedate) = MONTH(I.invoicedate)
					         GROUP BY A2.artistid
                             ORDER BY sales DESC, artistid LIMIT 10) AS T
				         WHERE T.artistid = A.artistid)) AS T2 USING (artistid) 
			GROUP BY A.name ORDER BY top_10 DESC;
            
            
