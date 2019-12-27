

USE invoices;

select 'AFTER 1/1/2014' AS selection_date,
count(*) as total_number,
round(avg(invoice_total),2) as average
from invoices
where invoice_date >= '2014-1-1';



SELECT * FROM invoice_line_items;
# vendors -- vendor_name
# invoice_line_items -- invoice_id, line_item_amt
# general_ledger_accounts -- account_description

-- What is the maximum line item amount?
SELECT account_number, invoice_id, MAX(line_item_amt) AS max_amt
FROM invoice_line_items;


# Subquery way
SELECT 
line_item_amt,
line_item_description
FROM vendors AS V
JOIN invoices AS I USING (vendor_id)
JOIN invoice_line_items AS L USING (invoice_id)
JOIN general_ledger_accounts AS G
ON V.default_account_number = G.account_number;










-- For each account, show the account description and the total amount invoiced
-- to that account. 
-- Show the account with the highest total first, and include
-- only those accounts with total amounts of $5000 or more.

# general_ledger_accounts -- account_number, account_description
# invoices -- invoice_total
# invoices -- 

SELECT * FROM invoices;

select * from general_ledger_accounts;

select account_description,
count(line_item_amt) as totals
from general_ledger_accounts
join invoice_line_items
using (account_number)
group by account_description;







-- List all account descriptions along with the average line item amount for
-- that account. Before you execute your query, ask yourself “How many rows 
-- should I get?”. See if your query returns what you expect.

select * from general_ledger_accounts;
select * from invoice_line_items;

select account_description,
avg(line_item_amt) as averages
from general_ledger_accounts
join invoice_line_items
using (account_number)
group by account_number;



-- Show the invoice number, account description, and
-- the total of all line items (for that invoice and account) that are greater
-- than the average line item amount (of all line items). (hint: 20 rows)

select * from invoices;
select * from invoice_line_items;
select * from general_ledger_accounts;

select invoice_number, account_description, sum(line_item_amt) as total_amount
from invoices as I
join invoice_line_items as IL using (invoice_id)
join general_ledger_accounts using (account_number)
group by invoice_number, account_description
having total_amount > (select avg(line_item_amt) from invoice_line_items);




-- You realize that query #5 is a bit short sighted. You know from query #4
-- that the average line item amount differs greatly by account. For example,
-- the Telephone account has an average amount of around $30, while book
-- inventory averages over $20K! 

-- Modify your query from #5 so that it reports
-- the same columns for all line items that are greater than the average line
-- item amount for that account. Write two different formulations of this query
-- and compare the relative cost. (hint: 30 rows)

# relative comparison (not global)
# need to be correlated subq
select invoice_number, account_description, sum(line_item_amt) as total_amount, IL.account_number
from invoices as I
join invoice_line_items as IL using (invoice_id)
join general_ledger_accounts using (account_number)
group by invoice_number, account_description
having total_amount > (select avg(line_item_amt) 
                       from invoice_line_items as L2
                       where L2.account_number = IL.account_number);





-- Of all invoices paid on or within the default terms for the invoice’s
-- vendor, what is the average number of days early (w/respect to the
-- vendor’s default terms) by vendor? 

-- List the vendor and average number
-- of days early. Include only those vendors who pay – on average - within
-- the first ½ of their default terms window. For example, if the default
-- terms were 30 days, include only vendors who on average pay within 15 days.
-- Exclude invoices paid after the vendor’s default terms from your analysis.

use invoices;
select * from terms;
select * from vendors;
select * from invoices;

# date and correlated subquery
select V.vendor_id, V.vendor_name,
avg(DATEDIFF(DATE_ADD(invoice_date, interval T.terms_due_days DAY), payment_date)) as avg_early
from invoices as I
join vendors as V using (vendor_id)
join terms as T on V.default_terms_id = T.terms_id
where payment_date <= DATE_ADD(invoice_date, interval T.terms_due_days DAY)
group by V.vendor_id, V.vendor_name, T.terms_due_days
having avg_early > (select terms_due_days from terms as T2
					join vendors as V2 on V2.default_terms_id = T2.terms_id
                    where V2.vendor_id = V.vendor_id) / 2;














