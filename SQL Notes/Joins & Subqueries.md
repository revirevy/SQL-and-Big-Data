# Joins

## Basic Joins

```mysql
# Basic
SELECT a.col, b.col 
FROM a
JOIN b ON a.col3 = b.col3

# With conditions
WHERE A.column = 'Freight';
WHERE CONCAT(A.col1, A.col2) <> CONCAT(B.col1, B.col2);
```



## Full Outer Join

```mysql
# full outer join - left join + union all + right + join
SELECT col1, col2
FROM A
LEFT JOIN B
USING (col3)
UNION ALL
SELECT col1, col2
FROM A
RIGHT B                       # used right here, left above
USING (col3)
WHERE A.col3 IS NULL;         # gets rid of duplicates
```



# Subqueries

```mysql
# Select - agg per row
SELECT ..,
   (SELECT ..
	FROM A
	WHERE A.col = B.col) AS description
	
	
# From - cut down the large table
SELECT ..
FROM A
JOIN
   (SELECT ..
	FROM A
	WHERE A.col = B.col) AS description
USING()...
	
	
# Where - match conditions
SELECT ..
FROM ..
WHERE col in (SELECT col
	FROM B
	WHERE B.col2 in ("", ""))
	
	
# Correlated - subquery per group
SELECT ..
FROM A as A1
where col > 
  (SELECT avg(col) 
  from A as A2
  where A2.col = A1.col);
```

