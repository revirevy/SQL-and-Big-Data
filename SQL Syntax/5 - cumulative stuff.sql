# cumulative sum with window functions
select rank() over (partition by vendor_state order by sum(line_item_amt) DESC) as vendor_rank,      # ranking by state
vendor_name, vendor_state,
	
    case when SUM(line_item_amt) IS NULL then 0 
    else SUM(line_item_amt) end as total_business,                                                   # switching some values
    
    # cumulative per state
    sum(sum(line_item_amt)) over (partition by vendor_state                                          # sum of the top ones
								rows between unbounded preceding and current row)                    # rows from beginning to end
                                as cumu_business

FROM vendors
left join invoices using (vendor_id)
left join invoice_line_items using (invoice_id)
group by vendor_name;

-- ----------------------------------------------------------------------------------
-- cte, union, new column with running total
WITH T AS 
# rentals per customer
(SELECT rental_date AS trans_date, 'Rental' AS trans_desc, rental_id, title, rental_rate AS amt
  FROM rental AS R JOIN inventory AS I USING (inventory_id) JOIN film AS F USING (film_id)
 WHERE customer_id = 318

UNION

# payments per customer
SELECT payment_date, 'Payment', rental_id, '', -amount 
FROM payment AS P
WHERE customer_id = 318)

SELECT *, SUM(amt) OVER (ORDER BY trans_date, trans_desc DESC 
		ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS balance FROM T;

-- ----------------------------------------------------------------------------------
-- running total
WITH T AS 
(SELECT 'Order' AS trans_type, customerNumber, orderNumber AS trans_num, orderDate AS trans_date, ROUND(SUM(priceEach * quantityOrdered),2) AS total
  FROM orders AS O JOIN orderdetails USING (ordernumber)
GROUP BY orderNumber

UNION ALL

SELECT 'Payment', customerNumber, checkNumber, paymentDate, -amount
FROM payments)
SELECT *, 
ROUND(SUM(total) OVER (ORDER BY trans_date, trans_type ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) AS balance
FROM T WHERE customerNumber IN (198, 381) ORDER BY trans_date;