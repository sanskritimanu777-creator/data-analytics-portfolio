----------------------------------------------MOVIE-RENTAL-SHOP-------------------------------------------------

--1 . Calculate the Total Sale Amount by the merchant location. 
 select Merchant_Location, sum(sale_amount) as total_sale
 from [product] as p
 inner join transactions as t
 on p.Product_Id=t.product_id
  and
  p.Merchant_id=t.merchant_id
  group by Merchant_Location

--2. Find the total number of customers who purchased between July 2012 and December 2012. 
select DISTINCT count(customer_id) as tot_cust, FTD
FROM CUSTOMER
WHERE FTD BETWEEN '2012-07-01' AND '2012-12-31'
GROUP BY FTD
ORDER BY FTD ASC

select DISTINCT count(customer_id) as tot_cust, LTD
FROM CUSTOMER
WHERE LTD BETWEEN '2012-07-01' AND '2012-12-31'
GROUP BY LTD
ORDER BY LTD ASC

--3. What is the average transaction value by the top 10 customers in terms of sales?
SELECT top 10 customer_id,(sum(sale_amount)/count(total_orders)) as avg_transaction_value 
FROM CUSTOMER as c
inner join transactions as t 
on c.Customer_ID=t.[USER_ID]
group by customer_id
 
-- 