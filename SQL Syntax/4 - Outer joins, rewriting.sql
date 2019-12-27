# Left join + rewrite (finding gains rows when using left instead of inner)
USE invoices;
# If we have 202 with left join, 88 in the right table that don't have a match.
# There would be 114 if we used inner join instead of left join
SELECT vendor_id, vendor_name, invoice_number, invoice_due_date, invoice_total
FROM vendors AS V
LEFT JOIN invoices AS I USING (vendor_id)
ORDER BY vendor_name;

SELECT vendor_name
FROM vendors
WHERE vendor_id NOT IN (SELECT vendor_id FROM invoices);






# Left join + rewrite
USE departments;
SELECT last_name, first_name, department_number, department_name
FROM employees AS E
LEFT JOIN departments AS D
USING (department_number)
ORDER BY last_name;

SELECT last_name, first_name
FROM employees
WHERE department_number NOT IN (SELECT department_number FROM departments);








# Left join + rewrite (in select statement)
USE invoices;
SELECT vendor_name, MAX(invoice_date) AS most_recent_invoice
FROM vendors AS V
LEFT JOIN invoices AS I
USING (vendor_id)
GROUP BY vendor_id
ORDER BY vendor_id;

# rewriting as correlated subquery (no join, no groupby)
SELECT vendor_name,
(SELECT MAX(invoice_date)
FROM invoices AS I
WHERE I.vendor_id = V.vendor_id) AS most_recent
FROM vendors AS V
ORDER BY vendor_name;






 
# table reference itself (ie self referencing foreign key)
# one copy of table is employees = E
# one copy of table is managers = M
# make sure you know how inner join will reduce rows
SELECT E.first_name, E.last_name, 
M.first_name, M.last_name
FROM employees AS E                                     
LEFT JOIN employees AS M ON E.employee_id = M.manager_id; 









# full outer join - left join + union all + right + join
USE departments;
# sql server has full outer, mysql does not
SELECT department_number, department_name,
first_name, last_name
FROM departments AS D
LEFT JOIN employees AS E
USING (department_number)
UNION ALL
SELECT department_number, department_name,
first_name, last_name
FROM departments AS D
RIGHT JOIN employees AS E                       # used right here, left above
USING (department_number)
WHERE D.department_name IS NULL;                # gets rid of duplicates