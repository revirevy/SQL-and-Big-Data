-- Ex 3: Modify the stored procedure such that the step is also provided as an argument.  
--       Then use it to create a sequence of (1000,1999), (2000, 2999), …, (9000,9999)
DROP PROCEDURE IF EXISTS pr_insert_seq;
DELIMITER $$
CREATE PROCEDURE pr_insert_seq(p_begin INT, p_end INT)
BEGIN
-- p_begin, p_end are input arguments
-- insert a sequence of ranges to a table 
-- e.g. (1, 9), (10, 19), (20, 29)
DECLARE v_step INTEGER; -- declare a variable
SET v_step = 10;  -- assign a value to a variable
myloop: LOOP   -- mark beginning of loop
  IF p_begin > p_end THEN
    LEAVE myloop;  -- exit the loop
  END IF;
  INSERT IGNORE INTO ranges(beginid, endid) VALUES(p_begin, p_begin + v_step-1);
  SET p_begin = p_begin + v_step; -- increment.
END LOOP myloop; -- end of loop
END$$
DELIMITER ;


-- Ex 4:
DROP PROCEDURE IF EXISTS pr_assign_rank;
DELIMITER $$
CREATE PROCEDURE pr_assign_rank()
BEGIN 
DECLARE v_vendorid, v_rank, v_newvendorid, v_invoiceid, v_finished INTEGER;
DECLARE invoice_cursor CURSOR FOR 
SELECT vendor_id, invoice_id FROM invoices ORDER BY vendor_id, invoice_total DESC;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
-- all the declare statements must appear at the beginning
SET v_finished = 0;
SET v_vendorid = -1; 
SET v_rank = 0;
OPEN invoice_cursor;
get_invoice: LOOP  -- go through records in the cursor
  SET v_rank = v_rank + 1;
  FETCH invoice_cursor INTO v_newvendorid, v_invoiceid;
  IF v_finished = 1 THEN 
    LEAVE get_invoice; -- exit the loop
  END IF;
  IF v_vendorid <> v_newvendorid THEN
    SET v_rank = 1; -- reset rank counter
    SET v_vendorid = v_newvendorid;
  END IF;
  UPDATE invoices SET rank = v_rank WHERE invoice_id = v_invoiceid;
END LOOP get_invoice;
CLOSE invoice_cursor;
END$$
DELIMITER ;


-- Ex 5
