# Simple case statement (preferred)
  # does not handle null - doesnt drop rows, just uses the "else" condition
# Searched case statement - works in order


-- was the amt paid in full?
select invoice_number, vendor_name, invoice_total,
	CASE payment_total + credit_total
	WHEN 0 THEN 'Not Paid'
	WHEN invoice_total THEN 'Paid In Full'
	ELSE 'Partial Paid' END as pmt_status
from invoices as I
join vendors as V using (vendor_id);

select invoice_number, vendor_name, invoice_total,
	CASE 
    WHEN payment_total + credit_total = invoice_total THEN 'Paid In Full'
	WHEN payment_total + credit_total = 0 THEN 'Not Paid'
    ELSE 'Partial Paid' END as pmt_status
from invoices as I
join vendors as V using (vendor_id);
-- -----------------------------------------------------------------------
 
-- group by invoice, then count line items
SELECT invoice_number,
	CASE COUNT(*)
	WHEN 1 THEN 'No'
	ELSE 'Yes' END AS multiline
FROM invoices AS I JOIN terms AS T USING (terms_id) JOIN invoice_line_items AS L USING (invoice_id)
WHERE terms_due_days = 60
GROUP BY invoice_number;
 
-- Using a subquery
SELECT invoice_number,
	CASE (SELECT COUNT(*) FROM invoice_line_items AS L WHERE L.invoice_id = I.invoice_id)
	WHEN 1 THEN 'No'
	ELSE 'Yes' END AS multiline
FROM invoices AS I JOIN terms AS T USING (terms_id)
WHERE terms_due_days = 60;
 -- --------------------------------------------------------------------
 -- HARDER EXAMPLES
 
 -- datediff
 -- CASE with datediff
SELECT rental_date, title, return_date,
       CASE WHEN DATEDIFF(return_date, rental_date) > rental_duration THEN 'Late'
            WHEN return_date IS NULL THEN 'Never'
            ELSE 'Ontime'
       END AS 'returned?'
  FROM rental AS R JOIN inventory AS I USING (inventory_id) JOIN film AS F USING (film_id) WHERE customer_id = 236;
 
 
