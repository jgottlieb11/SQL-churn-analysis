# Ecommerce Customer Churn Analysis Using SQL

This project aims to analyze customer churn patterns and provide insights and recommendations to reduce churn rates. The analysis is based on a dataset containing various customer attributes and behaviors.

## Key Findings from the Analysis

1. **Total Customers**:
   - The dataset contains **5,630 distinct customers**, with no duplicate customer IDs.

2. **Null Values**:
   - Several columns had missing values, including `Tenure`, `WarehouseToHome`, `HourSpendOnApp`, `OrderAmountHikeFromLastYear`, and `CouponUsed`.
   - These missing values were handled by imputing the mean or median based on the column type.

3. **Churn Rate**:
   - The overall **churn rate is 16.84%**, indicating a significant portion of customers have left the company.

4. **Churn by Preferred Login Device**:
   - Customers who preferred logging in with a **computer have a higher churn rate (19.83%)** compared to those using **phones (15.62%)**.

5. **Churn by City Tier**:
   - **CityTier 3** has the highest churn rate, followed by **CityTier 2**, and **CityTier 1** has the lowest churn rate. This suggests the geographical location of customers plays a role in churn behavior.

6. **Warehouse Distance and Churn**:
   - Customers living **further from the warehouse** are more likely to churn, with churn rates increasing as the distance from the warehouse increases.

7. **Payment Mode and Churn**:
   - **Cash on Delivery** is the most preferred payment mode among churned customers, with a higher churn rate compared to other payment methods like credit or debit cards.

8. **Tenure and Churn**:
   - Customers with a tenure of **less than 6 months** have the highest churn rate, indicating that newer customers are more likely to leave.

9. **Churn by Gender**:
   - **Males** exhibit a slightly higher churn rate than females, and they tend to register more devices on average.

10. **Churn and Time Spent on the App**:
    - No significant difference was found in the **time spent on the app** between churned and non-churned customers.

11. **Registered Devices and Churn**:
    - The **more devices a customer registers**, the more likely they are to churn. This suggests that device registration patterns may be linked to customer disengagement.

12. **Order Categories and Churn**:
    - The **Mobile Phone** category has the highest churn rate, while **Grocery** has the lowest. Retention strategies should be tailored based on order category preferences.

13. **Customer Satisfaction and Churn**:
    - Surprisingly, customers who rated their satisfaction as **5** show the highest churn rate. This emphasizes the need for continuous engagement even with satisfied customers.

14. **Churn by Marital Status**:
    - **Single customers** have the highest churn rate, while **married customers** have the lowest churn rate. Targeting different retention strategies based on customer demographics may prove useful.

15. **Complaints and Churn**:
    - Customers who filed **complaints** have a significantly higher churn rate, showing that addressing customer grievances promptly can help reduce churn.

16. **Coupon Usage and Churn**:
    - **Non-churned customers** use more coupons on average than churned customers, suggesting that coupon incentives can be effective in retaining customers.

17. **Cashback and Churn**:
    - Customers who received **moderate cashback amounts** churn more frequently than those with low or very high cashback. Offering higher cashback incentives could increase retention.

18. **Order Count and Churn**:
    - Customers with **fewer orders** tend to churn more, highlighting the importance of encouraging frequent purchases.

## Recommendations

Based on the findings from the analysis, the following actions are recommended:

- **Improve user experience on desktops**: Since computer users have higher churn rates, efforts should be made to optimize the desktop experience.
- **Implement targeted retention strategies by city tier**: Focusing on customers from **Tier 2 and Tier 3** cities could help reduce churn in these segments.
- **Optimize logistics for distant customers**: Providing faster and more reliable shipping to customers far from warehouses could help reduce churn in this group.
- **Incentivize early engagement**: Since newer customers are more likely to churn, offering promotions or personalized support during the first 6 months could improve retention.
- **Focus on resolving customer complaints**: Ensuring that customer complaints are handled quickly and effectively can help reduce churn.
- **Increase coupon and cashback incentives**: Rewarding customer loyalty through coupons and cashback programs could significantly improve retention rates.
