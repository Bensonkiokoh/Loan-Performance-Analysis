USE Mogo_Loans


--SELECT * FROM INFORMATION_SCHEMA.TABLES

--SELECT * FROM INFORMATION_SCHEMA.COLUMNS

--How many loans are issued each month?

SELECT 
	FORMAT(application_creation_date, 'yyyy-MM') Month,
	COUNT(*) LoansIssued
FROM Loans
WHERE application_status = 5
GROUP BY FORMAT(application_creation_date, 'yyyy-MM')

--Which team and loan agents issue the most loans?
--By Team:

SELECT * FROM [Loan Status]

SELECT 
	T.team,
	COUNT(DISTINCT L.application_id) LoansIssued
FROM Loans L
INNER JOIN [Loan Status] LS ON L.application_id = LS.application_id
INNER JOIN Team T ON L.loan_agent_id = T.agent_id
WHERE application_status = 5
GROUP BY T.team
ORDER BY LoansIssued DESC

--By Agent
SELECT TOP 1
	l.loan_agent,
	COUNT(DISTINCT L.application_id) LoansIssued
FROM Loans L
--INNER JOIN [Loan Status] LS ON L.application_id = LS.application_id
WHERE application_status = 5 
AND loan_agent IS NOT NULL
GROUP BY L.loan_agent
ORDER BY LoansIssued DESC

--Sales Breakdown by Loan Value (1k Ranges)

SELECT 
	(loan_value /1000) * 1000 RangeStart,
	COUNT(*) LoanCount
FROM Loans
WHERE application_status = 5
GROUP BY (loan_value /1000) * 1000

SELECT 
    CONCAT(FLOOR(loan_value / 1000) * 1000, '-', FLOOR(loan_value / 1000) * 1000 + 999) AS LoanRange,
    COUNT(*) AS TotalLoans,
    SUM(loan_value) AS TotalValue
FROM Loans
WHERE application_status = 5
GROUP BY FLOOR(loan_value / 1000)
ORDER BY FLOOR(loan_value / 1000);

--How many clients take a second loan and how long do they wait?

SELECT 
	client_id ,
	COUNT(*) LoanCount
FROM Loans
WHERE application_status = 5
GROUP BY client_id
HAVING COUNT(*) > 1

--How Long do they wait to take another loan

SELECT 
  client_id,
  COUNT(*) AS loan_count,
  MIN(application_creation_date) AS first_loan_date,
  MAX(application_creation_date) AS last_loan_date,
  DATEDIFF(DAY, MIN(application_creation_date), MAX(application_creation_date)) AS DaysBetweenLoans
FROM Loans
WHERE application_status = 5
GROUP BY client_id
HAVING  COUNT(*) >1
ORDER BY DaysBetweenLoans DESC;

--Which weekdays and loan types are most popular?

SELECT 
	DATENAME(WEEKDAY, application_creation_date) Day,
	COUNT(*) LoansIssued
FROM Loans
WHERE application_status = 5
GROUP BY DATENAME(WEEKDAY, application_creation_date), DATEPART(WEEKDAY, application_creation_date)
ORDER BY DATEPART(WEEKDAY, application_creation_date)

--Most Popular loan types

SELECT 
	loan_type,COUNT(*) LoansIssued
FROM Loans
WHERE application_status = 5
GROUP BY loan_type
ORDER BY LoansIssued DESC

--How many applications come from each source and which source brings the most value?

SELECT 
	S.source_label,
	COUNT(L.application_id) TotalApplications,
	SUM(L.Loan_value) TotalLoanValue
FROM Source S
INNER JOIN Loans L ON S.application_id = L.application_id
WHERE application_status = 5
GROUP BY S.source_label
ORDER BY TotalLoanValue DESC

--What is the average loan issuance time by agent and team?

SELECT 
    L.loan_agent,
    T.team,
    AVG(DATEDIFF(day, L.application_creation_date, LS.status_changed_at)) AS AvgIssuanceDays
FROM Loans L
INNER JOIN Team T ON T.agent_id = L.loan_agent_id
INNER JOIN [Loan Status] LS ON L.application_id = LS.application_id
WHERE L.application_status = 5
GROUP BY L.loan_agent, T.team
ORDER BY AvgIssuanceDays;

--How many loans are active daily?

SELECT COUNT(*) AS ActiveLoans
FROM Loans
WHERE application_status = 5
  AND CAST(application_creation_date AS DATE) <= '2025-01-15'
  AND (loan_paid_off_at IS NULL OR CAST(loan_paid_off_at AS DATE) >= '2025-01-15');


