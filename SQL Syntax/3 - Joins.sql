-- Cartesian product with projection
SELECT invoice_id,
       vendor_name
  FROM invoices,
       vendors;

-- Natural join
SELECT invoice_id,
       vendor_name
  FROM invoices,
       vendors
 WHERE invoices.vendor_id = vendors.vendor_id;


-- Natural join shorthand w/aliases
SELECT invoice_id,
       vendor_name
  FROM invoices AS i
  JOIN vendors AS v ON v.vendor_id = i.vendor_id;






# -------------------------------------
# Inner join (normal)
USE invoices;
SELECT line_item_amt, 
line_item_description
FROM invoice_line_items AS L
JOIN general_ledger_accounts AS A
ON L.account_number = A.account_number
WHERE A.account_description = 'Freight';

# Inner join (3 tables)
USE invoices;
SELECT invoice_number,
       invoice_due_date,
       vendor_name,
       A.terms_due_days,
       D.terms_due_days
  FROM invoices AS I
  JOIN vendors AS V ON V.vendor_id = I.vendor_id
  JOIN terms AS D ON D.terms_id = V.default_terms_id
  JOIN terms AS A ON A.terms_id = I.terms_id
 WHERE A.terms_due_days < D.terms_due_days
ORDER BY invoice_due_date DESC;








# concat stuff

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


-- Comparing individual fields:
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












-- Using a subquery - (where clause) 
SELECT V.vendor_id,
       V.vendor_name,
       V.vendor_contact_first_name,
       V.vendor_contact_last_name
  FROM vendors AS V
 WHERE CONCAT(V.vendor_contact_first_name,V.vendor_contact_last_name) <>
       (SELECT CONCAT(first_name, last_name) 
          FROM vendor_contacts AS C
		 WHERE C.vendor_id = V.vendor_id);







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

-- Using subqueries in the where clause
SELECT invoice_number,
       invoice_due_date,
       vendor_name
  FROM invoices AS I
  JOIN vendors AS V USING (vendor_id)
 WHERE (SELECT terms_due_days FROM terms AS A WHERE A.terms_id = I.terms_id) <
       (SELECT terms_due_days FROM terms AS D WHERE D.terms_id = V.default_terms_id);

