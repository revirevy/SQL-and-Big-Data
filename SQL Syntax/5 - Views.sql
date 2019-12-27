use invoices;

-- using view
DROP VIEW IF EXISTS v_vendors_with_invoices_may2014;
CREATE VIEW v_vendors_with_invoices_may2014 as 
select vendor_id 
from invoices
where invoice_date between "2014-05-01" and "2014-05-31";
        
select vendor_id, vendor_name, vendor_state 
from vendors as V
where vendor_id not in (select vendor_id from v_vendors_with_invoices_may2014);
-- ----------------------------------

-- line items greater than avg for that account
CREATE VIEW v_gen_ledge_acct_avgs AS 

# avg per account
select account_number, avg(line_item_amt) as avg_amt
		from invoice_line_items
		group by account_number;

SELECT invoice_number, account_description, 
SUM(line_item_amt) AS total,                 # only summing ones that are greater than avg
T.avg_amt,                                   # avg per line from above
L.account_number                             # looking at per account
FROM invoices AS I JOIN invoice_line_items AS L USING (invoice_id) JOIN general_ledger_accounts AS A USING (account_number) JOIN v_general_ledger_acct_avgs AS T USING (account_number)
GROUP BY invoice_number, account_number
HAVING total > T.avg_amt;
