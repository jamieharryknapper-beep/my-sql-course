SELECT
ps.PatientId,
ps.AdmittedDate,
ps.DischargeDate,
ps.Hospital,
ps.Ward,
DATEDIFF(DAY, ps.AdmittedDate, ps.DischargeDate) + 1 AS LengthOfStay,
DATEADD(MONTH,3,ps.DischargeDate) AS DischargeDate3M
FROM
PatientStay ps
WHERE
ps.Hospital IN ( 'Oxleas', 'PRUH' )
AND ps.AdmittedDate BETWEEN '2024-02-01'
AND '2024-02-28'
AND ps.Ward LIKE '%Surgery'
ORDER BY
ps.AdmittedDate DESC,
ps.PatientId DESC;



SELECT
ps.Hospital
, COUNT(*) AS NumberOfAdmissions
, SUM(ps.Tariff) AS TotalTariff
FROM
PatientStay ps
GROUP BY
ps.Hospital
HAVING
COUNT(*) > 10
ORDER BY
NumberOfAdmissions DESC;