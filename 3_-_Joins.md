Week 3 - Joins and Subqueries
================
Sam Musch

------------------------------------------------------------------------

### Mannino 9.1, Visc 7-10 (Joins)

### Mannino 9.12, Visc 11 (Subqueries)

**Join** (binary)
<img src="https://i.imgur.com/Voa3b2e.png" width="400px" />

### Joining

**Remember - you perform joins using either**
1. Cross product - list tables in `FROM`, conditions in `WHERE`
  `PRODUCT` returns combo of tables
2. Join op style - write join ops directly in `FROM`
  `JOIN` returns combo of tables, requires matching condition

**Natural joins** (join + select to grab relevant rows)
1. Combines rows (product operation)
2. Removes rows that dont satisfy (restrict operation)
3. Remove one of the join columns (project operation)

These 3 must be Union compatible = both tables must have same number of cols and with matching data types
`Union` all rows in either table
`intersection` all rows in common
`difference` all rows unique to tab1

`Divide` finds values of one col that are associated with every value in another col
`Summarize` organize table on specific groupong cols

------------------------------------------------------------------------

**Full join = Cross product = cartesian (don't use)**

    SELECT tab1.col1, tab2.col2
    FROM tab1, tab2;

------------------------------------------------------------------------

**Inner join (intersection)**

    SELECT tab1.col1, tab2.col2
    FROM tab1 INNER JOIN tab2
    ON tab1.col = tab2.colx
    WHERE condition;

    # could also using USING if the col names are the same

------------------------------------------------------------------------

**One sides outer left join (ie LEFT JOIN)**
keeps matching from both + nonmatching from one

    SELECT tab1.col1, tab1.col2, tab2.col1, tab2.col1  
    FROM tab1 LEFT JOIN tab2
    ON tab1.col = tab2.col
    WHERE condition

------------------------------------------------------------------------

**Full outer (doesn't display twice)**
keeps matching rows + nonmatching rows from both

    SELECT tab1.col1, tab1.col2  
    FROM tab1 
    OUTER JOIN tab2
    ON tab1.col1 = tab2.col2

------------------------------------------------------------------------

**Union (doesn't display duplicates)**
includes all rows from both tables

    SELECT tab1.col1, tab1.col2  
    FROM tab1 
    UNION 
    SELECT tab2.col1, tab2.col2  
    FROM tab2

------------------------------------------------------------------------

**Subquery (alt to join)**

`Row` subq for multiple cols, 1 row
`Scalar` subq for 1 col, 1 row
`Table` subq for 1 or more cols, 0 to many rows

Only use the `=` to connect the tables if there will only be one result

    SELECT tab1.col1, tab2.col2, 
    FROM tab1 AS first
    WHERE tab1.col IN (SELECT tab2.col
                      FROM tab2 AS second
                      WHERE tab2.col2 IN ('Freight', 'Other'));

------------------------------------------------------------------------
