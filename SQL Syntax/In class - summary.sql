USE invoices;

-- What is the maximum line item amount?
SELECT MAX(line_item_amt) AS max_amt FROM invoice_line_items;

-- subq
SELECT vendor_name,
       invoice_number,
       account_description,
       line_item_amt,
       line_item_description
  FROM vendors AS V
  JOIN invoices AS I USING (vendor_id)
  JOIN invoice_line_items AS L USING (invoice_id)
  JOIN general_ledger_accounts AS A USING (account_number)
 WHERE line_item_amt = (SELECT MAX(line_item_amt) AS max_amt FROM invoice_line_items);

-- Using a materialized table
SELECT vendor_name,
       invoice_number,
       account_description,
       line_item_amt,
       line_item_description
  FROM vendors AS V
  JOIN invoices AS I USING (vendor_id)
  JOIN invoice_line_items AS L USING (invoice_id)
  JOIN general_ledger_accounts AS A USING (account_number)
  JOIN (SELECT MAX(line_item_amt) AS max_amt FROM invoice_line_items) AS T
 WHERE line_item_amt = max_amt;



-- Subquery in the SELECT clause
SELECT vendor_name,
       invoice_number,
       account_description,
       line_item_amt,
       line_item_description,
       (SELECT MAX(line_item_amt) AS max_amt FROM invoice_line_items) AS max_amt
  FROM vendors AS V
  JOIN invoices AS I USING (vendor_id)
  JOIN invoice_line_items AS L USING (invoice_id)
  JOIN general_ledger_accounts AS A USING (account_number)
 HAVING line_item_amt = max_amt;


-- For each account, show the account description and the total amount invoiced
-- to that account. Show the account with the highest total first, and include
-- only those accounts with total amounts of $5000 or more.
SELECT account_description,
       SUM(line_item_amt) AS total_amt
  FROM general_ledger_accounts AS A
  JOIN invoice_line_items AS L USING (account_number)
GROUP BY account_description
HAVING total_amt > 5000
ORDER BY total_amt DESC;

-- Using a subquery
SELECT account_description,
       (SELECT SUM(line_item_amt) 
          FROM invoice_line_items AS L 
		 WHERE L.account_number = A.account_number) AS total_amt
  FROM general_ledger_accounts AS A
HAVING total_amt > 5000
ORDER BY total_amt DESC;

-- List all account descriptions along with the average line item amount for
-- that account. Before you execute your query, ask yourself “How many rows 
-- should I get?”. See if your query returns what you expect.
SELECT COUNT(*) FROM general_ledger_accounts;

SELECT account_description,
       AVG(line_item_amt) AS avg_amt
  FROM general_ledger_accounts AS A 
  LEFT JOIN invoice_line_items AS L USING (account_number)
GROUP BY account_description;

-- Using subquery
SELECT account_description,
       (SELECT AVG(line_item_amt) 
          FROM invoice_line_items AS L 
		 WHERE L.account_number = A.account_number) AS avg_amt
  FROM general_ledger_accounts AS A;


-- You are working to identify anomalies, so you are looking for line items on
-- invoices that stand out. Show the invoice number, account description, and
-- the total of all line items (for that invoice and account) that are greater
-- than the average line item amount (of all line items). (hint: 20 rows)
SELECT @@sql_mode;

SELECT invoice_number,
       account_description,
       SUM(line_item_amt) AS total
  FROM invoices AS I
  JOIN invoice_line_items AS L USING (invoice_id)
  JOIN general_ledger_accounts AS A USING (account_number)
GROUP BY invoice_number, account_description
HAVING total > (SELECT AVG(line_item_amt) FROM invoice_line_items);

SELECT * FROM invoice_line_items WHERE invoice_id = 19;


-- You realize that query #5 is a bit short sighted. You know from query #4
-- that the average line item amount differs greatly by account. For example,
-- the Telephone account has an average amount of around $30, while book
-- inventory averages over $20K! Modify your query from #5 so that it reports
-- the same columns for all line items that are greater than the average line
-- item amount for that account. Write two different formulations of this query
-- and compare the relative cost. (hint: 30 rows)
SELECT invoice_number,
       L.account_number,
       account_description,
       SUM(line_item_amt) AS total
  FROM invoices AS I
  JOIN invoice_line_items AS L USING (invoice_id)
  JOIN general_ledger_accounts AS A USING (account_number)
GROUP BY invoice_number, account_description
HAVING total > (SELECT AVG(line_item_amt) 
                  FROM invoice_line_items AS L2
				 WHERE L2.account_number = L.account_number);

-- Using a materialized table
SELECT account_number,
       AVG(line_item_amt) AS avg_amt
  FROM invoice_line_items
GROUP BY account_number;

SELECT invoice_number,
       L.account_number,
       account_description,
       SUM(line_item_amt) AS total,
       T.avg_amt
  FROM invoices AS I
  JOIN invoice_line_items AS L USING (invoice_id)
  JOIN general_ledger_accounts AS A USING (account_number)
  JOIN (SELECT account_number,
               AVG(line_item_amt) AS avg_amt
          FROM invoice_line_items
      GROUP BY account_number) AS T USING (account_number)
GROUP BY invoice_number, account_number
HAVING total > T.avg_amt;

-- Of all invoices paid on or within the default terms for the invoice’s
-- vendor, what is the average number of days early (w/respect to the
-- vendor’s default terms) by vendor? List the vendor and average number
-- of days early. Include only those vendors who pay – on average - within
-- the first ½ of their default terms window. For example, if the default
-- terms were 30 days, include only vendors who on average pay within 15 days.
-- Exclude invoices paid after the vendor’s default terms from your analysis.
SELECT V.vendor_id,
       V.vendor_name,
       T.terms_due_days,
       AVG(DATEDIFF(DATE_ADD(invoice_date, INTERVAL T.terms_due_days DAY), payment_date)) AS avg_early
  FROM invoices AS I
  JOIN vendors AS V USING (vendor_id)
  JOIN terms AS T ON T.terms_id = V.default_terms_id
 WHERE payment_date <= DATE_ADD(invoice_date, INTERVAL T.terms_due_days DAY)
GROUP BY V.vendor_id
HAVING avg_early > T.terms_due_days / 2;

-- Using a correlated subquery
SELECT V.vendor_id,
       V.vendor_name,
       AVG(DATEDIFF(DATE_ADD(invoice_date, INTERVAL T.terms_due_days DAY), payment_date)) AS avg_early
  FROM invoices AS I
  JOIN vendors AS V USING (vendor_id)
  JOIN terms AS T ON T.terms_id = V.default_terms_id
 WHERE payment_date <= DATE_ADD(invoice_date, INTERVAL T.terms_due_days DAY)
GROUP BY V.vendor_id
HAVING avg_early > (SELECT terms_due_days
                      FROM terms AS T2
                      JOIN vendors AS V2 ON V2.default_terms_id = T2.terms_id
					 WHERE V2.vendor_id = V.vendor_id) / 2;
