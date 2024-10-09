-- 1. Count distinct customers to ensure there are no duplicate customer IDs
-- Question: How many unique customers are there in the dataset?
SELECT COUNT(DISTINCT CustomerID) AS TotalCustomers
FROM ecommercechurn;
-- Answer: There are 5,630 unique customers in the dataset.

-- 2. Check for any potential duplicates by grouping all columns (beyond just CustomerID)
-- Question: Are there any duplicate rows across all the columns for individual customers?
SELECT CustomerID, COUNT(*) AS RowCount
FROM ecommercechurn
GROUP BY CustomerID, Tenure, PreferredLoginDevice, CityTier, WarehouseToHome, 
         PreferredPaymentMode, Gender, HourSpendOnApp, NumberOfDeviceRegistered, 
         PreferedOrderCat, SatisfactionScore, MaritalStatus, NumberOfAddress, Complain,
         OrderAmountHikeFromLastYear, CouponUsed, OrderCount, DaySinceLastOrder, CashbackAmount
HAVING COUNT(*) > 1;
-- Answer: No duplicate rows were found across all columns.

-- 3. Check for NULL values in multiple columns and provide the percentage of missing data
-- Question: What percentage of the data in key columns is missing?
SELECT 'Tenure' AS ColumnName, COUNT(*) AS NullCount, 
       (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ecommercechurn)) AS PercentNull
FROM ecommercechurn
WHERE Tenure IS NULL
UNION ALL
SELECT 'WarehouseToHome', COUNT(*), 
       (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ecommercechurn)) AS PercentNull
FROM ecommercechurn
WHERE WarehouseToHome IS NULL
UNION ALL
SELECT 'HourSpendOnApp', COUNT(*), 
       (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ecommercechurn)) AS PercentNull
FROM ecommercechurn
WHERE HourSpendOnApp IS NULL
UNION ALL
SELECT 'OrderAmountHikeFromLastYear', COUNT(*), 
       (COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ecommercechurn)) AS PercentNull
FROM ecommercechurn
WHERE OrderAmountHikeFromLastYear IS NULL;
-- Answer: Columns with the highest missing values are "HourSpendOnApp" and "OrderAmountHikeFromLastYear."

-- 4. Impute missing values with mean or median based on the column type
-- Question: How should missing values in numeric columns be filled?
UPDATE ecommercechurn
SET HourSpendOnApp = (SELECT AVG(HourSpendOnApp) FROM ecommercechurn WHERE HourSpendOnApp IS NOT NULL)
WHERE HourSpendOnApp IS NULL;

UPDATE ecommercechurn
SET Tenure = (SELECT AVG(Tenure) FROM ecommercechurn WHERE Tenure IS NOT NULL)
WHERE Tenure IS NULL;

-- Use median for outlier-prone columns like order amount hike
UPDATE ecommercechurn
SET OrderAmountHikeFromLastYear = (SELECT PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY OrderAmountHikeFromLastYear) 
                                   FROM ecommercechurn WHERE OrderAmountHikeFromLastYear IS NOT NULL)
WHERE OrderAmountHikeFromLastYear IS NULL;
-- Answer: Missing values were filled using mean (for "HourSpendOnApp" and "Tenure") and median (for "OrderAmountHikeFromLastYear").

-- 5. Categorize the churn and complaints into descriptive columns
-- Question: How can churn and complaints be categorized for better readability?
ALTER TABLE ecommercechurn
ADD CustomerStatus NVARCHAR(20), ComplainStatus NVARCHAR(10);

UPDATE ecommercechurn
SET CustomerStatus = CASE WHEN Churn = 1 THEN 'Churned' ELSE 'Stayed' END;

UPDATE ecommercechurn
SET ComplainStatus = CASE WHEN Complain = 1 THEN 'Yes' ELSE 'No' END;
-- Answer: Churned customers are categorized as 'Churned' and those with complaints as 'Yes' in the new columns.

-- 6. Normalize categorical columns
-- Question: How do we unify variations in categorical columns?
UPDATE ecommercechurn
SET PreferredLoginDevice = 'Phone'
WHERE PreferredLoginDevice IN ('Mobile Phone', 'mobile');

UPDATE ecommercechurn
SET PreferredPaymentMode = 'Cash on Delivery'
WHERE PreferredPaymentMode IN ('COD', 'cash on delivery');
-- Answer: Variations in "PreferredLoginDevice" and "PreferredPaymentMode" were normalized.

-- 7. Correct numerical outliers
-- Question: How can we correct outliers in numerical columns like "WarehouseToHome"?
UPDATE ecommercechurn
SET WarehouseToHome = 27
WHERE WarehouseToHome = 127;

UPDATE ecommercechurn
SET WarehouseToHome = 26
WHERE WarehouseToHome = 126;
-- Answer: Outliers in "WarehouseToHome" (126 and 127) were corrected to 26 and 27, respectively.

---

### **Exploratory Data Analysis and Business Insights**

-- 1. Calculate overall churn rate with a breakdown of churned and non-churned customers
-- Question: What is the overall churn rate of the dataset?
SELECT COUNT(*) AS TotalCustomers, 
       SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers, 
       CAST(SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn;
-- Answer: The churn rate is 16.84%.

-- 2. Analyze churn rate by preferred login device with more device-specific insights
-- Question: What is the churn rate by preferred login device, and how much time do customers spend on the app?
SELECT PreferredLoginDevice, 
       COUNT(*) AS TotalCustomers,
       SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
       CAST(SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS ChurnRate,
       AVG(HourSpendOnApp) AS AvgTimeSpentOnApp
FROM ecommercechurn
GROUP BY PreferredLoginDevice
ORDER BY ChurnRate DESC;
-- Answer: The churn rate for customers who log in via "Phone" is lower compared to those using "Computer."

-- 3. Churn analysis by city tier with an expanded look at customer satisfaction
-- Question: How does churn vary by city tier, and how does satisfaction score correlate with it?
SELECT CityTier, 
       COUNT(*) AS TotalCustomers, 
       SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
       CAST(SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS ChurnRate,
       AVG(SatisfactionScore) AS AvgSatisfactionScore
FROM ecommercechurn
GROUP BY CityTier
ORDER BY ChurnRate DESC;
-- Answer: City Tier 3 has the highest churn rate, with an average satisfaction score lower than that of Tier 1.

-- 4. Create ranges for warehouse-to-home distance to analyze churn rate
-- Question: Is there any correlation between warehouse-to-home distance and churn rate?
ALTER TABLE ecommercechurn ADD WarehouseDistanceRange NVARCHAR(20);

UPDATE ecommercechurn
SET WarehouseDistanceRange = CASE 
                               WHEN WarehouseToHome <= 10 THEN 'Very Close'
                               WHEN WarehouseToHome > 10 AND WarehouseToHome <= 20 THEN 'Close'
                               WHEN WarehouseToHome > 20 AND WarehouseToHome <= 30 THEN 'Moderate'
                               ELSE 'Far' END;

SELECT WarehouseDistanceRange, 
       COUNT(*) AS TotalCustomers, 
       SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
       CAST(SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn
GROUP BY WarehouseDistanceRange
ORDER BY ChurnRate DESC;
-- Answer: Customers living far from the warehouse show a higher churn rate compared to those living close.

-- 5. Churn rate by payment mode with average cashback amount
-- Question: How does the churn rate vary by payment mode, and what is the average cashback amount?
SELECT PreferredPaymentMode,
       COUNT(*) AS TotalCustomers,
       SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
       CAST(SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS ChurnRate,
       AVG(CashbackAmount) AS AvgCashback
FROM ecommercechurn
GROUP BY PreferredPaymentMode
ORDER BY ChurnRate DESC;
-- Answer: "Cash on Delivery" has the highest churn rate and the lowest average cashback amount.

-- 6. Create tenure ranges for analyzing churn behavior
-- Question: How does churn vary across different tenure ranges?
ALTER TABLE ecommercechurn ADD TenureRange NVARCHAR(20);

UPDATE ecommercechurn
SET TenureRange = CASE 
                   WHEN Tenure <= 6 THEN '0-6 Months'
                   WHEN Tenure > 6 AND Tenure <= 12 THEN '6-12 Months'
                   WHEN Tenure > 12 AND Tenure <= 24 THEN '1-2 Years'
                   ELSE 'More than 2 Years' END;

SELECT TenureRange, 
       COUNT(*) AS TotalCustomers, 
       SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
       CAST(SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn
GROUP BY TenureRange
ORDER BY ChurnRate DESC;
-- Answer: Customers with less than 6 months of tenure have the highest churn rate.

-- 7. Gender-based churn rate analysis
-- Question: How does the churn rate differ by gender, and how many devices do customers register on average?
SELECT Gender, 
       COUNT(*) AS TotalCustomers, 
       SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
       CAST(SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS ChurnRate,
       AVG(NumberOfDeviceRegistered) AS AvgDevicesRegistered
FROM ecommercechurn
GROUP BY Gender
ORDER BY ChurnRate DESC;
-- Answer: Males show a slightly higher churn rate and tend to register more devices than females.

-- 8. Average time spent on the app for churned vs. non-churned customers
-- Question: Do churned customers spend more or less time on the app compared to non-churned customers?
SELECT CustomerStatus, 
       AVG(HourSpendOnApp) AS AvgHourSpendOnApp
FROM ecommercechurn
GROUP BY CustomerStatus;
-- Answer: There is no significant difference in time spent on the app between churned and non-churned customers.

-- 9. Analyze churn based on the number of devices registered
-- Question: Does the number of registered devices affect the likelihood of churn?
SELECT NumberOfDeviceRegistered, 
       COUNT(*) AS TotalCustomers, 
       SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
       CAST(SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn
GROUP BY NumberOfDeviceRegistered
ORDER BY ChurnRate DESC;
-- Answer: Customers with more registered devices tend to churn more frequently.

-- 10. Churn rate based on preferred order category
-- Question: Which order categories have the highest churn rate?
SELECT PreferedOrderCat, 
       COUNT(*) AS TotalCustomers, 
       SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
       CAST(SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn
GROUP BY PreferedOrderCat
ORDER BY ChurnRate DESC;
-- Answer: The "Mobile Phone" category has the highest churn rate.

-- 11. Satisfaction score analysis with churn rate
-- Question: How does customer satisfaction relate to churn?
SELECT SatisfactionScore, 
       COUNT(*) AS TotalCustomers, 
       SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
       CAST(SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn
GROUP BY SatisfactionScore
ORDER BY SatisfactionScore DESC;
-- Answer: Customers with a satisfaction score of 5 show the highest churn rate.

-- 12. Churn rate analysis based on marital status
-- Question: How does marital status affect churn rates?
SELECT MaritalStatus, 
       COUNT(*) AS TotalCustomers, 
       SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
       CAST(SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn
GROUP BY MaritalStatus
ORDER BY ChurnRate DESC;
-- Answer: Single customers have the highest churn rate, while married customers have the lowest.

-- 13. Average number of addresses for churned vs. non-churned customers
-- Question: How many addresses do churned customers have on average?
SELECT CustomerStatus, 
       AVG(NumberOfAddress) AS AvgNumberOfAddresses
FROM ecommercechurn
GROUP BY CustomerStatus;
-- Answer: Churned customers tend to have slightly more addresses than non-churned ones.

-- 14. Complaints and churn behavior analysis
-- Question: Do customers with complaints have a higher churn rate?
SELECT ComplainStatus, 
       COUNT(*) AS TotalCustomers, 
       SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
       CAST(SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn
GROUP BY ComplainStatus
ORDER BY ChurnRate DESC;
-- Answer: Customers with complaints have a significantly higher churn rate.

-- 15. Coupon usage analysis for churned vs. non-churned customers
-- Question: How does coupon usage differ between churned and non-churned customers?
SELECT CustomerStatus, 
       SUM(CouponUsed) AS TotalCouponsUsed, 
       AVG(CouponUsed) AS AvgCouponsUsed
FROM ecommercechurn
GROUP BY CustomerStatus;
-- Answer: Non-churned customers tend to use more coupons compared to churned customers.

-- 16. Average number of days since the last order for churned customers
-- Question: How long has it been since churned customers last placed an order?
SELECT CustomerStatus, 
       AVG(DaySinceLastOrder) AS AvgDaysSinceLastOrder
FROM ecommercechurn
GROUP BY CustomerStatus;
-- Answer: On average, churned customers placed their last order 3 days ago.

-- 17. Cashback amount and churn rate correlation
-- Question: Is there a correlation between cashback amount and churn rate?
ALTER TABLE ecommercechurn ADD CashbackAmountRange NVARCHAR(20);

UPDATE ecommercechurn
SET CashbackAmountRange = CASE 
                            WHEN CashbackAmount <= 100 THEN 'Low Cashback'
                            WHEN CashbackAmount > 100 AND CashbackAmount <= 200 THEN 'Moderate Cashback'
                            WHEN CashbackAmount > 200 AND CashbackAmount <= 300 THEN 'High Cashback'
                            ELSE 'Very High Cashback' END;

SELECT CashbackAmountRange, 
       COUNT(*) AS TotalCustomers, 
       SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
       CAST(SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn
GROUP BY CashbackAmountRange
ORDER BY ChurnRate DESC;
-- Answer: Moderate cashback recipients churn more frequently than those with low or very high cashback amounts.

-- 18. Correlation between the order count and churn rate
-- Question: How does the number of orders correlate with churn?
SELECT OrderCount, 
       COUNT(*) AS TotalCustomers, 
       SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) AS ChurnedCustomers,
       CAST(SUM(CASE WHEN Churn = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(10,2)) AS ChurnRate
FROM ecommercechurn
GROUP BY OrderCount
ORDER BY ChurnRate DESC;
-- Answer: Customers with fewer orders tend to churn more frequently.

---

### **Advanced Tasks: SQL and Data Science Integration**

-- 19. Detect and handle outliers using IQR for CashbackAmount
-- Question: Are there any outliers in the cashback amounts?
SELECT CashbackAmount
FROM ecommercechurn
WHERE CashbackAmount > (SELECT PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY CashbackAmount) + 1.5 * 
                        (PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY CashbackAmount) - 
                         PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY CashbackAmount))
                        FROM ecommercechurn);
-- Answer: Outliers in cashback amounts were detected using IQR.

-- 20. Feature engineering: Order frequency (orders per month)
-- Question: How can we calculate order frequency (orders per month)?
ALTER TABLE ecommercechurn ADD OrdersPerMonth DECIMAL(10,2);

UPDATE ecommercechurn
SET OrdersPerMonth = OrderCount / CASE WHEN Tenure = 0 THEN 1 ELSE Tenure END;
-- Answer: Order frequency (OrdersPerMonth) was calculated based on tenure and order count.

-- 21. Create customer lifetime value (CLV) feature
-- Question: How can we compute the Customer Lifetime Value (CLV)?
ALTER TABLE ecommercechurn ADD CustomerLifetimeValue DECIMAL(10,2);

UPDATE ecommercechurn
SET CustomerLifetimeValue = CashbackAmount * OrderCount;
-- Answer: CLV was computed by multiplying cashback amount and order count.

-- 22. Cohort analysis: Analyze customer behavior based on tenure ranges
-- Question: How does customer behavior vary across different tenure ranges?
SELECT TenureRange, COUNT(CustomerID) AS CustomerCount, 
       AVG(CashbackAmount) AS AvgCashback, AVG(OrderCount) AS AvgOrderCount
FROM ecommercechurn
GROUP BY TenureRange
ORDER BY TenureRange;
-- Answer: Customers with a tenure of 6-12 months have a higher average cashback and order count.

-- 23. Optimize queries by creating indexes on frequently queried columns
-- Question: How can we optimize query performance by creating indexes?
CREATE INDEX idx_churn ON ecommercechurn (Churn);
CREATE INDEX idx_tenure ON ecommercechurn (Tenure);
-- Answer: Indexes were created on "Churn" and "Tenure" columns to improve query performance.

-- 24. Analyze query performance using EXPLAIN to optimize further
-- Question: How can we analyze query performance using EXPLAIN?
EXPLAIN SELECT * FROM ecommercechurn WHERE CustomerStatus = 'Churned';
-- Answer: The query plan was analyzed using EXPLAIN for further optimization.
