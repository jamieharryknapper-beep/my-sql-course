/*
SQL Course
Subqueries Lesson 1 - Self-Contained Subqueries
 
A self-contained subquery is independent of the outer query
It can be executed stand-alone.
It is executed once and the result is used by the outer query.  (As a result, it is generally more efficient than a correlated subquery
*/
 
/*
This is a scalar subquery returning a single value to use in the WHERE <column> =
List the patient stays with the highest tariff
*/
SELECT
	ps.PatientId
	, ps.Hospital
	, ps.Tariff
FROM
	PatientStay ps
WHERE
	ps.Tariff = (
    SELECT MAX(ps2.Tariff) FROM PatientStay ps2
   );
 
/*
List the patient stays in Surgical wards.  (These wards end with the word 'Surgery'.)
This  subquery returns a one column list to use in the WHERE <column> IN (...)
Note: You can list patients in all wards apart from surgical wards by using NOT IN
*/
 
SELECT
	ps.PatientId
	, ps.Hospital
	, ps.Ward
	, ps.Tariff
FROM
	PatientStay ps
WHERE
	ps.Ward NOT IN (
	SELECT DISTINCT Ward FROM dbo.PatientStay WHERE Ward LIKE '%Surgery' 
	);
 
 
/*
* This subqueries are based on a different table to the outer query
*/
SELECT
	h.Hospital
	, h.[HospitalType]
	, h.Reach
FROM
	DimHospital h 
WHERE h.Hospital IN (
	SELECT DISTINCT ps.Hospital FROM PatientStay ps WHERE ps.Ward = 'Ophthalmology' AND ps.AdmittedDate = '2024-02-26'
	);
 

SELECT
    h.Hospital
    ,h.[HospitalType]
    ,h.Reach
FROM
    PatientStay ps INNER JOIN DimHospital h ON ps.Hospital = h.Hospital
WHERE ps.Ward = 'Ophthalmology' AND ps.AdmittedDate = '2024-02-26'




SELECT
	*
FROM
	PatientStay ps
WHERE
	ps.Hospital IN (
	SELECT h.Hospital FROM DimHospital h WHERE h.[HospitalType] = 'Teaching'
	);
/*
This  subquery returns a table so use in the FROM ...
Calculate budget hospital tariffs as 10% more than actuals
*/
 
SELECT
	hosp.Hospital
	, hosp.HospitalTariff
	, hosp.HospitalTariff * 1.1 AS BudgetTariff
FROM
	(
	SELECT
		ps.Hospital
		, SUM(ps.Tariff) AS HospitalTariff
	FROM
		PatientStay ps
	GROUP BY
		ps.Hospital) hosp;
 
/*
This subquery returns a table so use in the FROM ...
Calculate the total tariff of the 10 most expensive patients 
i.e. those with the highest tariff 
(Ignore the possible complication that there may be some ties.)
*/
SELECT
	SUM(Top10Patients.Tariff) AS Top10Tariff
FROM
	(
	SELECT
		TOP 10
         ps.PatientId
		, ps.Tariff
	FROM
		PatientStay ps
	ORDER BY
		ps.Tariff DESC) Top10Patients;
 
/*
Aside: Another way to do first example (scalar subquery) uses SQL variables
*/
DECLARE @MaxTariff AS INT = (
	SELECT MAX(ps2.Tariff) FROM PatientStay ps2
	);
 
SELECT 	@MaxTariff;
 
SELECT
	*
FROM
	PatientStay ps
WHERE
	ps.Tariff = @MaxTariff;


-- EXERCISE
/*
Subqueries Exercise 1 - Self Contained
 
This exercise will use two related tables
* PricePaidSW12 - sales of properties in London SW12 from 1995 to 2019. 
* PropertyTypeLookup - a lookup table on the PropertyType column of PricePaidSW12.  This contains a one letter code e.g. 'D'.  
  The PropertyTypeLookup has a column PropertyTypeCode with matching values and a column PropertyTypeName with the description e.g. 'Detached'
 
In this example we will focus sales in  a particular street, Ranmere Street
*/
 
-- List properties sold in Ranmere Street
SELECT
	pp.TransactionID
	, pp.TransactionDate 
	, pp.Price 
	, pp.PropertyType
	, pp.PAON
	, pp.Street 
FROM
	PricePaidSW12 pp
WHERE
	pp.Street = 'Ranmere Street'
 
-- Get the average price of properties sold in Ranmere Street
SELECT
    AVG(pp.Price) AS AveragePrice
    ,pp.PropertyType
FROM
    PricePaidSW12 pp
WHERE
	pp.Street = 'Ranmere Street'
GROUP BY pp.PropertyType;
 
-- Which property types have not been sold in the Ranmere Street? (use a self-contained subquery to answer this)
 
SELECT
    *
FROM
    PropertyTypeLookup ptl
WHERE ptl.PropertyTypeCode NOT IN (SELECT DISTINCT
    pp.PropertyType
FROM
    PricePaidSW12 pp
WHERE pp.Street = 'Ranmere Street')

	-- complete the query below here
 
	
-- List properties sold for more than the average price
-- Use a simple subquery in the WHERE clause and in the column list
SELECT
	pp.TransactionID
	, pp.TransactionDate 
	, pp.Price 
	, pp.PropertyType
	, pp.PAON
	, pp.Street 
	, (SELECT AVG(sw.Price) FROM PricePaidSW12 sw WHERE sw.Street = 'Ranmere Street') AS AveragePriceInRanmereStreet
FROM
	PricePaidSW12 pp
WHERE
	pp.Street = 'Ranmere Street'	
	AND pp.Price > (SELECT AVG(sw.Price) FROM PricePaidSW12 sw WHERE sw.Street = 'Ranmere Street') -- add the subquery  here
ORDER BY pp.Price DESC;
 
 
-- Optional - Advanced task
-- Calculate the price difference over the average price
-- Use a simple subquery in the WHERE clause and in the column list
 
-- Do this for all sales rather than a single street
