/*
A tally table, also known as a numbers table or sequence table, is a utility table in SQL 
that contains a sequence of numbers (e.g., 1, 2, 3, ..., N) in a single column. 

This table can be incredibly useful for a variety of tasks in SQL querying and data manipulation.
For example, tally tables can easily generate a sequence of dates, numbers, or time intervals without using recursive queries or loops. This is particularly useful for filling in gaps in data, generating date ranges, or creating bins for histograms.
*/

-- Many databases, including the course database, may already have a tally table you can use.

SELECT * FROM Tally WHERE N < 10;

SELECT MAX(N) AS MaxN FROM Tally;


/*
Exercise: write a SQL statement to find out how many rows are in this table.  Are the values contiguous?
*/

/*
 * Using a Tally Table
 * 
 * We can use a Tally table to create a Dates (Calendar) table
 * This sort of table is essential in analytical databases
 * For example, we use the Tally table  to create a table of dates in 2024.
 */

-- Here is a simple, but not good, way to build a Dates table for 2024

SELECT 
	t.N AS DayOfYear
	,DATEADD(DAY, t.N, '2025-12-31') AS TheDate
    ,DATENAME(WEEKDAY,(DATEADD(DAY, t.N, '2025-12-31'))) AS DayOfTheWeek
FROM 
	Tally t WHERE N <=366
order by t.N;



WITH dates AS (
    SELECT
	t.N AS DayOfYear
	,DATEADD(DAY, t.N, '2025-12-31') AS TheDate
FROM 
	Tally t WHERE N <=5
)
SELECT TOP (5) TheDate, DATENAME(WEEKDAY, TheDate) AS WeekDayName FROM dates;


-- Date (Calendar) table pattern

WITH cte AS (
    SELECT
        t.N AS DayOfYear
        ,DATEADD(DAY, t.N, '2025-12-31') AS TheDate
    FROM
        Tally t WHERE N <=365
)
SELECT
        cte.DayOfYear
        ,cte.TheDate
        ,DATENAME(WEEKDAY, cte.TheDate) AS DayOfWeek
        ,DATENAME(MONTH, cte.TheDate) AS MonthName
        ,CASE
            WHEN DATENAME(WEEKDAY, cte.TheDate) IN ('Saturday', 'Sunday') THEN 'Weekend'
            ELSE 'Weekday'
        END AS DayType
FROM    cte
ORDER BY cte.DayOfYear;    


-- A better approach is to use SQL variables to set the start and end dates
DECLARE @StartDate DATE;
DECLARE @EndDate DATE;
SELECT @StartDate = DATEFROMPARTS(2024, 1, 1);
SELECT  @EndDate = DATEFROMPARTS(2024, 12, 31);
DECLARE @NumberOfDays INT = DATEDIFF(DAY, @StartDate, @EndDate) + 1;
SELECT 
	DATEADD(DAY, N-1, @StartDate) AS Date
FROM 
	Tally
WHERE
	N <= @NumberOfDays
ORDER BY Date;
	

/*
 Creating a Tally Table
 Many databases, including the course database, may already have a tally table you can use.
 Before we see how to implement this, let's remind ourselves about UNION and CROSS JOIN
 */

-- A UNION stacks one table on another (like a VSTACK in Excel)

SELECT
	'A' AS MyColumn
UNION
SELECT
	'B'
UNION
SELECT
	'C';

/*
 CROSS JOIN creates a row for every combination of the left and right tables.
 There is no ON clause since no need for a matching column
 */
WITH TableAB (a, b) AS 
(
SELECT
	*
FROM
( VALUES 
	('a1', 'b1')
	, ('a2', 'b2')
	) ab (A	, B))
, TableXY (x, y) AS 
(
SELECT
	*
FROM
( VALUES 
	('x1', 'y1')
	,('x2', 'y2')
	) XY (x	, y)
)
SELECT
	*
FROM
	TableAB
CROSS JOIN TableXY;


/*
One way to build a tally tables  is to use a recursive CTE
This returns a Tally table with 10,000 rows
E1 is a table of 10 rows created by UNION of 10 SELECT statements 
E2 is a CROSS JOIN of E1 with itself so has 10 x 10 or 1000 rows
E4 is a CROSS JOIN of E2 with itself so has 100 x 100 or 10,000 rows
ROW_NUMBER() is Window function that generates an index 1,2,3,... over the 10,000 rows of E4
ROW_NUMBER() must have an ORDER BY clause 
If we need fewer than 10,000 rows the final statement use a WHERE cluase
*/

WITH E1(N) AS (
	    SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
	    UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1 UNION ALL SELECT 1
	)
	, E2(N) AS ( SELECT 1 FROM E1 a CROSS JOIN E1 b)
	, E4(N) AS ( SELECT 1 FROM E2 a CROSS JOIN E2 b)
	, FinalTally(N) AS ( SELECT ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) FROM E4)
SELECT
	N
FROM
	FinalTally
WHERE
	N <= 1000
ORDER BY
	N;