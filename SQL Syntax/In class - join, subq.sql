

-- join
SELECT invoice_id,
       line_item_amt,
       line_item_description,
       account_description 
  FROM invoice_line_items AS L
  JOIN general_ledger_accounts AS A ON A.account_number = L.account_number
 WHERE invoice_id = 100
ORDER BY invoice_sequence;


-- Using a subquery (no join)
SELECT invoice_id,
       line_item_amt,
       line_item_description,
       (SELECT account_description
          FROM general_ledger_accounts AS A
		 WHERE A.account_number = L.account_number) AS description
  FROM invoice_line_items AS L
 WHERE invoice_id = 100
ORDER BY invoice_sequence;








-- Augment the query above to include the following:
--    * invoice number, invoice date, and due date columns
--    * include invoice *number* 97/522 in addition to invoice id 100 
--    CHALLENGE: Formulate as a *single SQL statement* with each query 
--               using no more than a single join (of any kind).
SELECT invoice_id,
	   invoice_number,
       invoice_date,
       invoice_due_date,
       line_item_amt,
       line_item_description,
       account_description 
  FROM invoices AS I
  JOIN invoice_line_items AS L USING (invoice_id)
  JOIN general_ledger_accounts AS A USING (account_number)
 WHERE invoice_id = 100
    OR invoice_number = '97/522'
ORDER BY invoice_number, invoice_sequence;

-- Using subquery in the FROM clause
-- First, our subquery:
SELECT invoice_id,
       line_item_amt,
       line_item_description,
       account_description
  FROM invoice_line_items AS L
  JOIN general_ledger_accounts AS A USING (account_number);

-- Used in the FROM clause:
SELECT invoice_id,
	   invoice_number,
       invoice_date,
       invoice_due_date,
       line_item_amt,
       line_item_description,
       account_description 
  FROM invoices AS I
  JOIN (SELECT invoice_id,
               line_item_amt,
			   line_item_description,
               account_description
          FROM invoice_line_items AS L
          JOIN general_ledger_accounts AS A USING (account_number)) AS T USING (invoice_id)
 WHERE invoice_id = 100
    OR invoice_number = '97/522'
ORDER BY invoice_number;


-- Show the invoice id, invoice number, invoice date, due date, and invoice total 
-- columns for all invoices due in July 2014. Add a column to the results showing 
-- the SUM of all line items for each invoice. Verify that the invoice_total column matches the
-- SUM of all line items by showing only those rows where the invoice_total
-- is different than the SUM of all line items.

-- Check the invoice_total field in the invoices table
SELECT * FROM invoices WHERE invoice_id = 100;
-- Check the sum of all line items for that invoice
SELECT SUM(line_item_amt) FROM invoice_line_items WHERE invoice_id = 100;

-- Combined into one query:
SELECT invoice_id,
       invoice_number,
       invoice_date,
       invoice_due_date,
       invoice_total,
       (SELECT SUM(line_item_amt)
          FROM invoice_line_items AS L
		 WHERE L.invoice_id = I.invoice_id) AS line_item_total
  FROM invoices AS I
 WHERE invoice_due_date BETWEEN '2014-07-01' AND '2014-07-31'
 HAVING line_item_total <> invoice_total;
 

-- There are two sources of vendor contact names: the vendors table and the
-- vendor_contacts table. We are trying to find (and eliminate) inconsistency,
-- so use a join to list all vendors for whom the contact listed in the 
-- vendors table is different than the contact listed in the vendor_contacts
-- table. List the vendor name, the name of the contact in the vendors table,
-- and the name of the contact in the vendor_contacts table. Order by the 
-- vendor name.
SELECT * FROM vendors;
SELECT * FROM vendor_contacts;

-- Comparing indiviudal fields:
SELECT V.vendor_id,
       V.vendor_name,
       V.vendor_contact_first_name,
       V.vendor_contact_last_name,
       C.first_name,
       C.last_name
  FROM vendors AS V
  JOIN vendor_contacts AS C USING (vendor_id)
 WHERE vendor_contact_first_name != first_name
    OR vendor_contact_last_name <> last_name;

-- Using CONCAT:
SELECT V.vendor_id,
       V.vendor_name,
       V.vendor_contact_first_name,
       V.vendor_contact_last_name,
       C.first_name,
       C.last_name
  FROM vendors AS V
  JOIN vendor_contacts AS C USING (vendor_id)
 WHERE CONCAT(V.vendor_contact_first_name,V.vendor_contact_last_name) <>
       CONCAT(C.first_name,C.last_name);

-- Using CONCAT in the ON clause:
SELECT V.vendor_id,
       V.vendor_name,
       V.vendor_contact_first_name,
       V.vendor_contact_last_name,
       C.first_name,
       C.last_name
  FROM vendors AS V
  JOIN vendor_contacts AS C ON C.vendor_id = V.vendor_id
   AND CONCAT(V.vendor_contact_first_name,V.vendor_contact_last_name) <>
       CONCAT(C.first_name,C.last_name);

-- Using a subquery:
SELECT V.vendor_id,
       V.vendor_name,
       V.vendor_contact_first_name,
       V.vendor_contact_last_name
  FROM vendors AS V
 WHERE CONCAT(V.vendor_contact_first_name,V.vendor_contact_last_name) <>
       (SELECT CONCAT(first_name, last_name) 
          FROM vendor_contacts AS C
		 WHERE C.vendor_id = V.vendor_id);


-- In fact – are there *any* vendors for whom the contact listed in the vendors
-- table is the same as the contact listed in the vendor_contacts table? How
-- would you write a query to find out?
SELECT V.vendor_id,
       V.vendor_name,
       V.vendor_contact_first_name,
       V.vendor_contact_last_name,
       C.first_name,
       C.last_name
  FROM vendors AS V
  JOIN vendor_contacts AS C USING (vendor_id)
 WHERE vendor_contact_first_name = first_name
   AND vendor_contact_last_name = last_name;  -- No, there are not!


-- List the invoice_number, due date, vendor name, default terms and actual
-- terms (from the invoices tables) for all invoices whose actual terms are 
-- shorter than the default terms for that vendor. Order each by the due date, 
-- listing the most recent invoice first:
SELECT * FROM invoices;
SELECT * FROM terms;
SELECT * FROM vendors;

-- Using JOIN
SELECT invoice_number,
       invoice_due_date,
       vendor_name,
       A.terms_due_days,
       D.terms_due_days
  FROM invoices AS I
  JOIN vendors AS V USING (vendor_id)
  JOIN terms AS D ON D.terms_id = V.default_terms_id
  JOIN terms AS A ON A.terms_id = I.terms_id
 WHERE A.terms_due_days < D.terms_due_days
ORDER BY invoice_due_date DESC;

-- Using subqueries
SELECT invoice_number,
       invoice_due_date,
       vendor_name
  FROM invoices AS I
  JOIN vendors AS V USING (vendor_id)
 WHERE (SELECT terms_due_days FROM terms AS A WHERE A.terms_id = I.terms_id) <
       (SELECT terms_due_days FROM terms AS D WHERE D.terms_id = V.default_terms_id);
