# Loan Performance Analysis

## Introduction
This project is a full exploratory data analysis (EDA) of loan issuance data. It focuses on understanding how loans are distributed, who takes them, and the operational performance behind the scenes.

### Tools Used: 
- SQL Server for querying, 
- Power BI for visualization, 
- Excel for data review.

The goal is to answer key business questions like:
- How many loans are issued each month?
- Which team and loan agents issue the most loans?
- How are loans distributed by value ranges?
- How many clients take a second loan and how long do they wait?
- Which weekdays and loan types are most popular?
- How many applications come from each source and which source brings the most value?
- What is the average loan issuance time by agent and team?
- How many loans are active daily?

## Dataset Description
Source: Provided Excel file Task 2025 v2 - Data Analyst.xlsx
### Key Tables/Fields:
- Client_id: Unique identifier for each client
- Loan_agent, team: Responsible personnel and group
- Application_date, issuance_date: Timeline of loan processing
- Status: Loan status (5 = issued, 6 = cancelled)
- Loan_type, loan_amount: Product and value details
- Source: Origin of application (e.g., web, referral)
- First_status_change_date: Initial status update timestamp

## Database Exploration
Before diving into analysis, a thorough exploration of the dataset was conducted to understand its structure, assess data quality, and identify key fields relevant to the business questions.

```sql
SELECT * FROM INFORMATION_SCHEMA.TABLES
```
<img width="411" height="106" alt="Screenshot 2025-08-11 210745" src="https://github.com/user-attachments/assets/288072c8-2eab-4c5d-b94c-2950bb78acdb" />

```sql
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
```
<img width="612" height="331" alt="Screenshot 2025-08-11 211012" src="https://github.com/user-attachments/assets/3a48c164-0af6-47e9-8117-9970d3ad37ca" />

## Key Business Questions
These are the critical questions guiding the loan analysis, designed to uncover actionable insights and support data-driven decision-making:

#### How many loans are issued each month?

```sql
SELECT 
	FORMAT(application_creation_date, 'yyyy-MM') Month,
	COUNT(*) LoansIssued
FROM Loans
WHERE application_status = 5
GROUP BY FORMAT(application_creation_date, 'yyyy-MM')
```
<img width="148" height="162" alt="Screenshot 2025-08-11 212238" src="https://github.com/user-attachments/assets/bdd389e4-e5a0-47e3-ac90-6944554cf7da" />

#### Which team and loan agents issue the most loans?
##### By Team:

```sql

SELECT 
	T.team,
	COUNT(DISTINCT L.application_id) LoansIssued
FROM Loans L
INNER JOIN [Loan Status] LS ON L.application_id = LS.application_id
INNER JOIN Team T ON L.loan_agent_id = T.agent_id
WHERE application_status = 5
GROUP BY T.team
ORDER BY LoansIssued DESC
```
<img width="151" height="65" alt="Screenshot 2025-08-11 213912" src="https://github.com/user-attachments/assets/8f918dc4-ee91-417a-85bb-dff8326edfd7" />

##### By Agent:
```sql
SELECT TOP 1
	l.loan_agent,
	COUNT(*) LoansIssued
FROM Loans L
WHERE application_status = 5 
AND loan_agent IS NOT NULL
GROUP BY L.loan_agent
ORDER BY LoansIssued DESC
```

<img width="167" height="45" alt="Screenshot 2025-08-11 214317" src="https://github.com/user-attachments/assets/eec5f853-e23c-489e-a017-e7f9bb91a151" />

#### How are loans distributed by value ranges?

```sql
SELECT 
    CONCAT(FLOOR(loan_value / 1000) * 1000, '-', FLOOR(loan_value / 1000) * 1000 + 999) AS LoanRange,
    COUNT(*) AS TotalLoans,
    SUM(loan_value) AS TotalValue
FROM Loans
WHERE application_status = 5
GROUP BY FLOOR(loan_value / 1000)
ORDER BY FLOOR(loan_value / 1000);
```

<img width="242" height="247" alt="Screenshot 2025-08-11 215619" src="https://github.com/user-attachments/assets/fb229e4e-cc78-4ed2-9dab-6e0c761a3699" />

#### How many clients take a second loan and how long do they wait?
```sql
SELECT 
	client_id ,
	COUNT(*) LoanCount
FROM Loans
WHERE application_status = 5
GROUP BY client_id
HAVING COUNT(*) > 1
```

<img width="145" height="260" alt="Screenshot 2025-08-11 221257" src="https://github.com/user-attachments/assets/98b0bde6-e380-4960-af27-722a477780ae" />




















