# Full lecture Oct 28
# Summary at 1:41 on Oct 28

-- ------------------------------------
# adding an index creates a new file in sorted order, and points to the original other columns
# adding indexes adds overhead, only use when tables are large enough
# dont use index on column with only a few unique values

# when using multiple columns in single index creation..
#    ..still does full table scan when looking for value in second variable

# unique key lookup is fastest
# non-unique key lookup is second fastest
# index range scan (numeric fields)

-- Indices
select vendor_id, vendor_city, vendor_state 
from vendors IGNORE INDEX (vendor_city_ix)
where vendor_city = "Washington"
and vendor_state = "DC";

ALTER TABLE vendors ADD INDEX vendor_city_ix (vendor_city);
ALTER TABLE vendors ADD INDEX vendor_st_ix (vendor_state);
SHOW INDEX FROM vendors;
ANALYZE TABLE vendors;
-- -----------------------------------------------------
ALTER TABLE invoices ADD INDEX vendor_city_ix (vendor_city);

-- 1. 
show indexes from invoices;

# sorts so we can grab only the relevant invoice number
ALTER TABLE invoices ADD INDEX vendor_number_ix (invoice_number);

# did full table scan for when looking for invoice_id = 100 OR invoice_number = '97/522'
   # this slow time also impacts the other 2

SELECT invoice_id,invoice_number,invoice_due_date,line_item_amt,line_item_description,account_description
  FROM invoices AS I
  JOIN invoice_line_items AS L USING (invoice_id)
  JOIN general_ledger_accounts AS A USING (account_number)
 WHERE invoice_id = 100 OR invoice_number = '97/522'
ORDER BY invoice_number, invoice_sequence;
-- -----------------------------------------------------
-- 2. 
# full table scan for days < 30
  # index range scan after adding index for terms_due_days
  
# this doesn't help - adding index for the <30 condition
# table is too small, index adds overhead
alter table terms add index terms_due_days_ix (terms_due_days);

SELECT * FROM invoices AS I
  JOIN terms AS T USING (terms_id)
  JOIN vendors AS V USING (vendor_id)
 WHERE T.terms_due_days < 30
   AND vendor_city = 'Sacramento' AND invoice_due_date BETWEEN '2014-6-25' AND '2014-6-29';
-- -----------------------------------------------------

-- 3. 
# full table when using the "like" command
  # index range scan after adding index for terms_due_days

# doesn't help because looking for substrings, still has to go thru each row
alter table invoice_line_items add index line_items_desc_ix (line_items_description);

# gets rid of 1 full scan, but creates another
alter table vendors add index vendor_zip_ix (vendor_zip_code);

SELECT invoice_id, invoice_number,invoice_due_date,vendor_name,line_item_amt,line_item_description,account_description
  FROM invoices AS I
  JOIN invoice_line_items AS L USING (invoice_id)
  JOIN general_ledger_accounts AS A USING (account_number)
  JOIN vendors AS V USING (vendor_id)
 WHERE vendor_zip_code BETWEEN '00000' AND '50000' AND L.line_item_description LIKE '%Freight';	