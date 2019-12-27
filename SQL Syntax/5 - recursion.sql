use departments;
select * from employees;

WITH RECURSIVE cte_employee AS
(SELECT employee_id, first_name, last_name, manager_id, 1 AS lvl   # base case
  
FROM employees WHERE manager_id IS NULL                            # person without a mgr
			   # WHERE employee_id = 9

UNION ALL

# for each round - add 1 to base case
SELECT e.employee_id, e.first_name, e.last_name, e.manager_id, c.lvl+1 AS lvl
  FROM employees AS e
  JOIN cte_employee AS c ON c.employee_id = e.manager_id          # top employee = next level's mgr
)
SELECT *  FROM cte_employee;

-- -----------------------------------------

USE adventureworks;
select * from Product;

WITH RECURSIVE cte_bom AS
(SELECT P.ProductID,
       CAST(P.Name AS CHAR(100)) AS Name,
       P.Color,
       
       1 AS qty, 1 AS bom_level,
       ProductAssemblyID,
       CAST(P.Name AS CHAR(100)) AS sort
  
  FROM Product AS P
  JOIN BillOfMaterials AS B ON B.ComponentID = P.ProductID
 WHERE ProductId = 775

UNION ALL

SELECT P.ProductID, 
	   CAST(CONCAT(REPEAT('|--', bom_level), ' ', P.Name) AS CHAR(100)),
       P.Color,
       PerAssemblyQty,
       bom_level + 1,
       cte_bom.ProductId,
	   CAST(CONCAT(cte_bom.sort, '\\', P.Name) AS CHAR(100)) AS sort
       
  FROM cte_bom
  JOIN BillOfMaterials AS B ON B.ProductAssemblyID = cte_bom.ProductID
  JOIN Product AS P ON B.ComponentID = P.ProductID
   AND (B.EndDate IS NULL OR B.EndDate > NOW())
)
SELECT * FROM cte_bom ORDER BY sort;

-- -----------------------------------------
USE umn_cs_prereqs;

# base case -     course       description     lowest level courses
# only courses NOT in the prereq table
WITH RECURSIVE cte_courses AS 
(SELECT 1 AS semester, CAST(course_id AS CHAR(10)) AS course_id, course_desc
  FROM Course
 WHERE course_id NOT IN (SELECT course_id FROM Prerequisite)

UNION ALL

# join new case (prereq) with the base case (course)
SELECT semester + 1, CAST(C.course_id AS CHAR(10)) AS course_id, C.course_desc
  FROM Course AS C JOIN Prerequisite AS P USING (course_id)
  JOIN cte_courses AS R ON R.course_id = P.prereq_course_id)
SELECT * FROM cte_courses;

-- ------------------------------------------------------

-- Exercise 10
USE classicmodels;

WITH RECURSIVE cte_total AS
(
	WITH RECURSIVE cte_hierarchy AS 
	(
		WITH cte_sales AS 
		(
		SELECT employeeNumber, firstName, lastName, reportsTo,
			   CASE WHEN SUM(priceEach * quantityOrdered) IS NULL THEN 0
                    ELSE SUM(priceEach * quantityOrdered)
			   END AS sales
		  FROM employees AS E
		  LEFT JOIN customers AS C ON C.salesRepEmployeeNumber = E.employeeNumber
		  LEFT JOIN orders AS O USING (customerNumber)
		  LEFT JOIN orderdetails AS D USING (orderNumber)
		GROUP BY employeeNumber, firstName, lastName, reportsTo
		)
		SELECT 1 AS emp_level, employeeNumber, firstName, lastName, reportsTo, sales
		  FROM cte_sales AS E
		 WHERE reportsTo IS NULL
		UNION ALL
		SELECT emp_level + 1, E.employeeNumber, E.firstName, E.lastName, E.reportsTo, E.sales
		  FROM cte_sales AS E
		  JOIN cte_hierarchy AS H ON H.employeeNumber = E.reportsTo
	)
    SELECT emp_level, employeeNumber, firstName, lastName, reportsTo, sales
      FROM cte_hierarchy
	 WHERE emp_level = (SELECT max(emp_level) FROM cte_hierarchy)
	UNION ALL
    SELECT H.emp_level, H.employeeNumber, H.firstName, H.lastName, H.reportsTo,
           CASE T.sales
             WHEN 0 THEN H.sales
             ELSE T.sales
		   END AS sales
      FROM cte_hierarchy AS H
      JOIN cte_total AS T ON T.reportsTo = H.employeeNumber
)
SELECT emp_level, employeeNumber, firstName, lastName, reportsTo, 
       ROUND(SUM(sales), 2) AS total_sales
  FROM cte_total
GROUP BY emp_level, employeeNumber, firstName, lastName, reportsTo
ORDER BY emp_level, total_sales DESC;