/* SELECT
    ps.PatientId
    ,ps.AdmittedDate
    ,ps.DischargeDate
    ,ps.Hospital
    ,ps.Ward
    ,DATEDIFF(DAY, ps.AdmittedDate, ps.DischargeDate) + 1 AS LengthOfStay
FROM
    PatientStay ps
WHERE ps.Hospital IN ('Oxleas','PRUH')
    AND ps.AdmittedDate BETWEEN '2024-02-01' AND '2024-02-29'
    AND ps.Ward LIKE '%Surgery'
ORDER BY ps.AdmittedDate DESC, ps.PatientId DESC */


SELECT
    ps.Hospital
    ,COUNT(ps.PatientId) AS AdmitCount
    ,SUM(ps.Tariff) AS TariffValue
FROM
    PatientStay AS ps
GROUP BY ps.Hospital
HAVING Count(ps.PatientId) > 10
ORDER BY AdmitCount DESC