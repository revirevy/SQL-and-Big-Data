-- Be sure to set up and use the invoices database as described in the video.
USE invoices;
SHOW TABLES;
DESCRIBE invoices;
DESCRIBE general_ledge_accounts;

 
-- 6. (I do) Show all invoices between May 1 2014 and May 31 2014
SELECT invoice_number, invoice_date, invoice_total
  FROM invoices
 WHERE invoice_date BETWEEN '2014-05-01' AND '2014-05-31';


-- 15. (We do) Show 2 columns: vendor_id, and vendor address as a single field
--             (ex. Minneapolis, MN 55455) named vendor_address.
SELECT vendor_id,
       concat(vendor_city,', ',vendor_state,' ',vendor_zip_code) AS vendor_address
  FROM vendors;


-- 16. (I do) Show the invoice_number, invoice_date, and invoice_total columns
--            but give them nicer names for a report.
SELECT invoice_number AS `Invoice Number`, 
       invoice_date AS `Date`,
       invoice_total AS Total
  FROM invoices;


SELECT invoice_number, invoice_date, invoice_total
  FROM invoices
 WHERE (invoice_date > '2014-05-01' 
    OR invoice_total > 500)
   AND invoice_total - payment_total - credit_total > 0;
   

-- 22. (We do) Find all vendors outside the states of California, Nevada, and Oregon.
SELECT * FROM vendors
 WHERE vendor_state NOT IN ('CA', 'NV', 'OR');
 
 
# Filtering with a created column
SELECT invoice_number,
(invoice_total - payment_total - credit_total) AS balance
FROM invoices
HAVING balance = 0
ORDER BY balance DESC;



Use new;

SELECT MAX(gpa) AS max_gpa,
       AVG(gpa) AS avg_gpa
  FROM Students
 WHERE studentState = 'MN'
   AND studentEnrollDate < '2016-09-1'
ORDER BY avg_gpa;




-- 28. (I do) Extract vendors with area codes 559 and initialize the last names.
SELECT vendor_name,vendor_phone, vendor_contact_last_name, 
       CONCAT(vendor_contact_first_name,' ',
	   SUBSTR(vendor_contact_last_name, 1, 1), '.') AS contact_name,  # start, length
       SUBSTR(vendor_phone, 7) AS phone
  FROM vendors
 WHERE SUBSTR(vendor_phone, 2, 3) = '559'
ORDER BY vendor_name;


-- 30. (I do) Show invoices as "part 1" and "part 2"
SELECT invoice_number, 
       SUBSTR(invoice_number, 1, (INSTR(invoice_number, '-') - 1)) AS part1,
       SUBSTR(invoice_number, (INSTR(invoice_number, '-') + 1)) AS part2
FROM invoices;


-- 32. (I do) How many days have passed since 9-11? What about years?
-- in days
SELECT DATEDIFF(CURRENT_DATE, '2001-09-11');

-- in years
SELECT TIMESTAMPDIFF(YEAR,  '2001-09-11', CURRENT_DATE);

-- 33. (I do) Using invoices table, find out invoices whose invoice_date are 
-- within 60 days of 2014-04-01. show invoice_id, invoice_date.
SELECT invoice_id, 
       invoice_date 
  FROM invoices 
 WHERE invoice_date BETWEEN '2014-04-01' 
AND DATE_ADD('2014-04-01', INTERVAL 60 DAY);

-- 34. (I do) Using invoices table, find invoices whose invoice_date is 
-- during the weekends, show invoice_id, and invoice_date.
-- using dayofweek
SELECT invoice_id, invoice_date, DAYOFWEEK(invoice_date) AS dow 
FROM invoices WHERE DAYOFWEEK(invoice_date) IN (1,7);
-- using weekday
SELECT invoice_id, invoice_date, WEEKDAY(invoice_date) AS dow 
FROM invoices WHERE WEEKDAY(invoice_date) IN (5,6);

-- 35. (I do) Using invoices, if the payment date is NULL, show 
-- “no payment yet”, otherwise show last payment date.
SELECT invoice_id, IFNULL(payment_date, "no payment yet") FROM invoices;

