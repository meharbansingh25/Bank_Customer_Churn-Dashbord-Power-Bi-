==================================================
==================================================
BANK CUSTOMER CHURN ANALYSIS PROJECT
SQL DATA ANALYSIS & BUSINESS INSIGHTS
==================================================
==================================================


-- SECTION 1:- Dataset Import

Create Table bank_churn(CustomerId int primary key, Surname varchar(50), CreditScore int, Geography varchar(50),
Gender varchar(50), Age int, Tenure int, Balance Decimal(12, 2), NumOfProducts int, HasCrCard int, IsActiveMember int, 
EstimatedSalary decimal(12, 2), Exited int, Age_Group varchar (50), Credit_Category varchar (50), Balance_Category varchar(50),
Customer_Status varchar(50));

==================================================

--Dataset Preview

SELECT * FROM bank_churn
LIMIT 20;

==================================================
==================================================


-- SECTION 2:- Data Validation Queries

--Total Records
--Question 1:How many customer records are available in the dataset?

SELECT COUNT(*) FROM bank_churn;


--Check Churn Distribution
--Question 2:- How many customers have churned and how many customers have been retained?

SELECT  exited, 
COUNT(*) AS customers
FROM bank_churn 
GROUP BY exited;


--Check Geography Distribution
--Question 3:- How are customers distributed across different countries?

SELECT geography, 
COUNT(*) AS total_customers
FROM bank_churn 
GROUP BY geography;

==================================================
==================================================


-- SECTION 3:- Basic Business Analysis

--Geography-wise Churn
--Question 4:- Which country has the highest customer churn rate?

SELECT geography,
		COUNT(*) AS total_customers,
		SUM(exited) AS churned_customers,
		ROUND(SUM(exited) * 100.0 / COUNT(*),2) AS churn_rate
FROM bank_churn
GROUP BY geography
ORDER BY churn_rate DESC;


--Gender-wise Churn
--Question 5:- Does customer churn vary between male and female customers?

SELECT gender,
		COUNT(*) AS total_customers,
		SUM(exited) AS churned_customers,
		ROUND(SUM(exited) * 100.0 / COUNT(*),2) AS churn_rate
FROM bank_churn
GROUP BY gender;


--Age Group Analysis
--Question 6:- Which age group is most likely to leave the bank?

SELECT age_group,
		COUNT(*) AS total_customers,
		SUM(exited) AS churned_customers,
		ROUND(SUM(exited) * 100.0 / COUNT(*),2) AS churn_rate
FROM bank_churn
GROUP BY age_group
ORDER BY churn_rate DESC;


--Credit Score Category Analysis
--Question 7:- How does customer churn vary across different credit score categories?

SELECT credit_category,
		COUNT(*) AS total_customers,
		SUM(exited) AS churned_customers,
		ROUND(SUM(exited) * 100.0 / COUNT(*),2) AS churn_rate
FROM bank_churn
GROUP BY credit_category
ORDER BY churn_rate DESC;


--Balance Category Analysis
--Question 8:- Does account balance influence customer churn behavior?

SELECT balance_category,
		COUNT(*) AS total_customers,
		SUM(exited) AS churned_customers,
		ROUND(SUM(exited) * 100.0 / COUNT(*),2) AS churn_rate
FROM bank_churn
GROUP BY balance_category
ORDER BY churn_rate DESC;


--Activity Status Analysis
--Question 9:- Are inactive customers more likely to churn than active customers?

SELECT isactivemember,
		COUNT(*) AS total_customers,
		SUM(exited) AS churned_customers,
		ROUND(SUM(exited) * 100.0 / COUNT(*),2) AS churn_rate
FROM bank_churn
GROUP BY isactivemember;


--Credit Card Analysis
-- Question 10:- Does credit card ownership have any impact on customer churn behavior?

SELECT HasCrCard,
       COUNT(*) AS total_customers,
       SUM(Exited) AS churned_customers,
       ROUND(SUM(Exited)*100.0/COUNT(*),2) AS churn_rate
FROM bank_churn
GROUP BY HasCrCard;

==================================================
==================================================


-- SECTION 4:- CASE WHEN Analysis

-- Customer Segmentation by Credit Score
--Question 11:- How can customers be segmented based on their credit scores?

SELECT customerid, creditscore,
	CASE
		WHEN creditscore >= 750 THEN 'Excellent'
		WHEN creditscore >= 650 THEN 'Good'
		WHEN creditscore >= 550 THEN 'Average'
		ELSE 'Poor'
	END AS credit_risk
FROM bank_churn;


-- Customer Segmentation by Balance
--Question 12: How can customers be categorized based on their account balances?

SELECT customerid, balance,
	CASE
		WHEN balance = 0 THEN 'Zero Balance'
		WHEN balance < 50000 THEN 'Low Balance'
		WHEN balance < 100000 THEN 'Medium Balance'
		ELSE 'High Balance'
	END AS Balance_Segement
FROM bank_churn;


--High-Risk Customer Identification
--Question 13:- Which customers can be classified as high-risk customers based on age, balance, and credit score?

SELECT customerid, geography, gender, 
	age , balance, creditscore,
	CASE
		WHEN age >= 50 
			AND creditscore < 600
			AND balance > 100000
		THEN 'High Risk'
		ELSE 'Normal Risk'
	END AS risk_status
FROM bank_churn;

==================================================
==================================================


-- SECTION 5:- Window Functions  

--Rank Customers by Balance
--Question 14:- What is the balance rank of each customer across the entire bank?

SELECT customerid, geography, balance,
	RANK() OVER(ORDER BY balance DESC) AS balance_rank
FROM bank_churn;


--Top 10 Customers by Balance
--Question 15:- Who are the top 10 customers with the highest account balances?

SELECT * FROM (
	SELECT customerid, geography, balance,
		RANK() OVER(ORDER BY balance DESC) AS balance_rank
	FROM bank_churn) AS temptable
WHERE balance_rank <=10;


--Geography-wise Ranking
--Question 16:- Who are the highest balance customers within each country?

SELECT customerid, geography, balance,
	RANK() OVER(
		PARTITION BY geography 
		ORDER BY balance DESC) as rank_in_country
FROM bank_churn;


--Average Balance Comparison
--Question 17:- How much does each customer's balance differ from the overall average balance of the bank?

SELECT CustomerId, geography, Balance,
    ROUND(AVG(Balance) OVER(),2) AS Avg_Balance,
    ROUND(Balance - AVG(Balance) OVER(),2) AS Difference
FROM bank_churn;


--Geography Average Balance
--Question 18:-  How does each customer's balance compare with the average balance of customers in their country?

SELECT customerid, geography, balance,
	ROUND(AVG(balance) OVER(
	PARTITION BY geography),2) 
	AS geography_avg_balance,
	ROUND(balance - AVG(balance) OVER(
	PARTITION BY geography),2) AS Difference
FROM bank_churn;

==================================================
==================================================


-- SECTION 6:- CTE Analysis  

--Geography Churn Summary (CTE)
--Question 19:- Can we create a churn summary table for each country using a CTE?

WITH churn_summary AS(
	SELECT geography,
		COUNT(*) AS total_customers,
		SUM(exited) AS churned_customers,
		ROUND(SUM(exited)*100.0/COUNT(*),2) AS churn_rate
	FROM bank_churn
	GROUP BY geography) 

SELECT * FROM churn_summary
ORDER BY churn_rate DESC;


--Above Average Balance Customers
--Question 20:- Which customers have balances higher than the overall average balance?

WITH avgrage_balance AS(
	SELECT AVG(balance) AS avg_balance
	FROM bank_churn)

SELECT * FROM bank_churn
WHERE balance >
		(SELECT avg_balance
		FROM avgrage_balance);


--High Value Customers
--Question 21:- Which countries have the highest number of high-value customers?

WITH high_value AS(
	SELECT * FROM bank_churn
	WHERE balance > 100000)

SELECT geography,
	COUNT(*) AS customers
FROM high_value
GROUP BY geography;

==================================================
==================================================


-- SECTION 7:- SQL Business Insights

-- Germany has the highest churn rate.
-- Senior customers are more likely to churn.
-- Female customers show higher churn behavior than male customers.
-- Poor credit score customers show higher churn behavior.
-- Inactive members churn significantly more than active members.
-- High-risk customers can be identified using age, balance, and credit score analysis.
-- Credit card ownership has minimal impact on churn.

==================================================
==================================================


SECTION 8:- SQL Project Conclusion

--The SQL analysis identified key customer churn patterns using aggregations, CASE WHEN statements, Window Functions, and CTEs. The findings revealed that customer activity status, age group, geography, and credit score are major factors influencing customer churn.

==================================================
==================================================
