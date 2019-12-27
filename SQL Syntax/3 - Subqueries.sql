USE invoices;


-- Using a subquery (select clause)
-- aggregating per row
SELECT invoice_id,
   line_item_amt,
   line_item_description,
   (SELECT account_description
	  FROM general_ledger_accounts AS A
	 WHERE A.account_number = L.account_number) AS description
FROM invoice_line_items AS L
WHERE invoice_id = 100
ORDER BY invoice_sequence;



# Subquery (from clause)
-- filtering with smaller tables
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
	  JOIN general_ledger_accounts AS A 
	  ON A.account_number = L.account_number) AS T 
	  USING (invoice_id)
WHERE invoice_id = 100
OR invoice_number = '97/522'
ORDER BY invoice_number;







# Subquery way (Inner) (where clause)
-- matching conditions
SELECT line_item_amt, 
line_item_description
FROM invoice_line_items
WHERE account_number IN (SELECT account_number
					  FROM general_ledger_accounts
					  WHERE account_description IN ('Building Maintenance', 'Meals', 'Telephone'));
					  
					  
					  
                      
                      
# Correlated sub - for every row in outer, has to run inner
SELECT vendor_id, invoice_number, invoice_total
FROM invoices as i_outer
where invoice_total > 
  (SELECT avg(invoice_total) 
  from invoices as i_inner
  where i_inner.invoice_id = i_outer.invoice_id);

  
  
  
  
  
  
  
  
  
  
  
  # Subquery in FROM clause (tabular)
  # Inner step
  SELECT invoice_id,
       line_item_amt,
       line_item_description,
       account_description
  FROM invoice_line_items AS L
  JOIN general_ledger_accounts AS A USING (account_number);
  
  
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
          JOIN general_ledger_accounts AS A 
          ON A.account_number = L.account_number) AS T 
          USING (invoice_id)
 WHERE invoice_id = 100
    OR invoice_number = '97/522'
ORDER BY invoice_number;
  
  
  
  
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
  
  
  
  
  
  
  
  

                          
                          
                          
                          
                          
                          
                          
                          
                          

                          
                          
                          
                          
                          
