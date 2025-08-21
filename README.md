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

#### Loan KPI's
```sql
SELECT 
	'Total Issued Loan Value'Description, SUM(Loan_value) Value
FROM Loans
WHERE application_status = 5
UNION
SELECT 
	'Total Cancelled Loan Value' ,SUM(Loan_value) 
FROM Loans
WHERE application_status = 6
UNION
SELECT 
	'Number of Issued Loans' ,COUNT(*) 
FROM Loans
WHERE application_status = 5
UNION
SELECT 
	'Number of Cancelled Loans' ,COUNT(*) 
FROM Loans
WHERE application_status = 6
UNION
SELECT 
	'Number of Customers' ,COUNT(DISTINCT Client_id) 
FROM Loans

```
<img width="219" height="123" alt="Screenshot 2025-08-12 113613" src="https://github.com/user-attachments/assets/bdc2ef22-db39-415b-9cec-d50a94c64d19" />


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

##### Finding:
- April 2025 recorded the highest loan count.
- June and July 2025 tied for the lowest loan counts.

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
SELECT 
	l.loan_agent,
	COUNT(*) LoansIssued
FROM Loans L
WHERE application_status = 5 
AND loan_agent IS NOT NULL
GROUP BY L.loan_agent
ORDER BY LoansIssued DESC
```
<img width="154" height="97" alt="Screenshot 2025-08-12 124330" src="https://github.com/user-attachments/assets/e138163e-ca5b-45ae-a9a3-ff7e3a61086d" />


#### How are loans distributed by value ranges (1K)?

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
##### Finding:
The most common loan value range is 9,000–9,999, with 114 loans issued, totaling KES 1,077,400

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

#### How Long do they wait to take another loan
```sql
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
```
<img width="576" height="262" alt="Screenshot 2025-08-12 052130" src="https://github.com/user-attachments/assets/9d2a6574-d518-4a30-bc53-1b5dd7d1a9a3" />

#### Which weekdays and loan types are most popular?

```sql
SELECT 
	DATENAME(WEEKDAY, application_creation_date) Day,
	COUNT(*) LoansIssued
FROM Loans
WHERE application_status = 5
GROUP BY DATENAME(WEEKDAY, application_creation_date), DATEPART(WEEKDAY, application_creation_date)
ORDER BY DATEPART(WEEKDAY, application_creation_date)
```
<img width="170" height="165" alt="Screenshot 2025-08-12 053010" src="https://github.com/user-attachments/assets/31e78915-3f77-400a-935a-824c91949091" />

#### Most Popular loan types
```
SELECT 
	loan_type,COUNT(*) LoansIssued
FROM Loans
WHERE application_status = 5
GROUP BY loan_type
ORDER BY LoansIssued DESC
```
<img width="185" height="86" alt="Screenshot 2025-08-12 053609" src="https://github.com/user-attachments/assets/c602d925-f488-4792-b8e7-9ed2b30a39d4" />


#### How many applications come from each source and which source brings the most value?
```sql

SELECT 
	S.source_label,
	COUNT(L.application_id) TotalApplications,
	SUM(L.Loan_value) TotalLoanValue
FROM Source S
INNER JOIN Loans L ON S.application_id = L.application_id
WHERE application_status = 5
GROUP BY S.source_label
ORDER BY TotalLoanValue DESC
```
<img width="305" height="108" alt="Screenshot 2025-08-12 054612" src="https://github.com/user-attachments/assets/89fc6100-d64a-4b6f-b8c5-943b9f39bd77" />

#### What is the average loan issuance time by agent and team?
```sql

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
```
<img width="242" height="166" alt="Screenshot 2025-08-12 055953" src="https://github.com/user-attachments/assets/03fa52b4-9b3a-4380-b909-ffeedf955fbb" />

#### How many loans are active daily?
```sql
SELECT 
  d.LoanDate,
  COUNT(l.application_id) AS ActiveLoans
FROM (
  SELECT DISTINCT CAST(application_creation_date AS DATE) AS LoanDate
  FROM Loans
  WHERE application_status = 5
) d
LEFT JOIN Loans l ON l.application_status = 5
  AND CAST(l.application_creation_date AS DATE) <= d.LoanDate
  AND (l.loan_paid_off_at IS NULL OR CAST(l.loan_paid_off_at AS DATE) >= d.LoanDate)
GROUP BY d.LoanDate
ORDER BY d.LoanDate;
```
<img width="167" height="343" alt="Screenshot 2025-08-12 065220" src="https://github.com/user-attachments/assets/f531937d-4b7b-4103-9145-6a951307e9d4" />

### Key Findings
The exploratory analysis revealed several actionable insights across product performance, borrower behavior, and operational efficiency:
#### Motorcycle Loan Highlights
- Motorcycle loans show high uptake especially among small business owners and boda boda operators.
- Loan applications peak on Mondays and Thursdays, suggesting opportunities to align staffing and promotions with demand.
- Low-sales days (e.g. Tuesdays,Wednesdays,Friday and Saturday) present untapped potential for targeted campaigns and client engagement.
  
#### Operational & Performance Insights
- Top Performing Team: Team A issued 705 loans, significantly outperforming Team B (430 loans).
- Fastest Agents: Susan and John from Team A average just 2 days from application to issuance — ideal benchmarks for efficiency.
- Walk-in clients generated the highest loan value (KES 1.77M from 329 applications).
- Telesales and Web channels also performed well, each contributing over KES 1.5M in issued loans.
  
#### Client Behavior & Retention
- Repeat Borrowers: Several clients have taken multiple motorcycle loans, with one client taking 6 loans over 184 days, suggesting strong retention and asset replacement cycles.
- Daily Active Loans: Loan activity steadily increased from 4 active loans on Jan 2 to 132 by Jan 31, indicating strong early growth.

### Recommendations Summary
1. Support Top Agents
   - Encourage knowledge sharing from high performers like John and Susan to improve team-wide efficiency.
   - Recognition & Incentives: Introduce monthly awards or bonuses for agents who meet or exceed KPIs, encouraging others to follow suit.
   - Assign top agents as mentors to newer or lower-performing team members for weekly coaching sessions.
   - Use transparent dashboards to show performance metrics, helping agents track progress and learn from leaders.
2. Promote Popular Loan Ranges
   - Run digital ads and SMS promotions highlighting the benefits of KES 9,000 loans quick approval, flexible repayment, and popular use cases.
   - Reward clients who refer others for KES 9,000 loans with small cash bonuses or discounts on their next loan.
   - Simplify the process of getting loans use pre-approved offers or one-click renewals for returning clients.
3. Engage Repeat Clients
   - Give returning clients small perks like reduced interest rates, faster approval, or airtime bonuses.
   - Ask repeat clients for feedback on their experience and use it to improve services while subtly prompting re-engagement.
4. Expand Motorcycle Loans offering
   - Prioritize high-demand areas with strong motorcycle usage (e.g., rural transport hubs).
   - Bundle motorcycle loans with value-added services such as insurance, helmets, servicing, and accessories.
   - Partner with motorcycle dealers and service providers to streamline the loan-to-purchase and servicing journey.
5. Accelarate Loan Processing
   - Introduce pre-filled forms for repeat clients using existing data to speed up reapplications.
   - Enable instant document uploads and e-signatures to reduce physical paperwork delays.
   - Digitize loan applications via mobile apps, USSD codes, WhatsApp bots, or web portals.
   - Deploy smart notifications to alert staff of pending approvals or missing documents.
6. Align with Peak Days
   - Identify peak loan activity days using historical data e.g., Mondays and Thursdays.
   - Schedule targeted promotions (e.g., discounts, giveaways) to coincide with high-demand days.
   - Send reminder messages to clients ahead of peak days to drive engagement.
   - Use dashboards to visualize daily trends and adjust operations dynamically.




















