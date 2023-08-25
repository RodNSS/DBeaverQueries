-- Get a list of sales records where the sale was a lease.

SELECT
	*
FROM
	sales
WHERE
	sales_type_id = 2;

-- Get a list of sales where the purchase date is within the last five years.

SELECT *
FROM sales
WHERE purchase_date >= CURRENT_DATE - INTERVAL '5 years';

-- Get a list of sales where the deposit was above 5000 or the customer payed with American Express.

SELECT *
FROM sales
where deposit > 5000 or payment_method = 'americanexpress';

-- Get a list of employees whose first names start with "M" or ends with "d".

SELECT *
FROM employees
WHERE first_name LIKE 'M%' OR first_name LIKE '%d';

-- Get a list of employees whose phone numbers have the 604 area code.

SELECT *
FROM employees
WHERE phone LIKE '604%';

-- Get a list of the sales that were made for each sales type.

SELECT DISTINCT s.sales_type_id, st.sales_type_name
FROM sales s
JOIN salestypes st ON s.sales_type_id = st.sales_type_id;

SELECT
    v.vin AS vehicle_vin,
    cu.first_name AS customer_first_name,
    cu.last_name AS customer_last_name,
    emp.first_name AS employee_first_name,
    emp.last_name AS employee_last_name,
    d.business_name,
    d.city,
    d.state
FROM
    sales s
JOIN
    vehicles v using(vehicle_id)
JOIN
    customers cu using(customer_id)
JOIN
    employees emp using(employee_id)
JOIN
    dealershipemployees de ON v.dealership_location_id = de.dealership_id AND s.employee_id = de.employee_id
JOIN
    dealerships d ON de.dealership_id = d.dealership_id;

SELECT
    d.business_name AS dealership_name,
    e.first_name AS employee_first_name,
    e.last_name AS employee_last_name
FROM
    dealerships d
LEFT JOIN
    dealershipemployees de using(dealership_id)
LEFT JOIN
    employees e using(employee_id)
ORDER BY dealership_name;

SELECT
    vt.body_type,
    vt.make,
    vt.model,
    v.exterior_color
FROM
    vehicles v
JOIN
    vehicletypes vt using(vehicle_type_id);
   
SELECT
    e.first_name,
    e.last_name,
    d.business_name,
    s.price
FROM employees e
INNER JOIN dealershipemployees de ON e.employee_id = de.employee_id
INNER JOIN dealerships d ON d.dealership_id = de.dealership_id
LEFT JOIN sales s ON s.employee_id = e.employee_id
WHERE s.price IS NULL;

-- Get all the departments in the database,
-- all the employees in the database and the floor price of any vehicle they have sold.
SELECT
    d.business_name,
    e.first_name,
    e.last_name,
    v.floor_price
FROM dealerships d
LEFT JOIN dealershipemployees de ON d.dealership_id = de.dealership_id
INNER JOIN employees e ON e.employee_id = de.employee_id
INNER JOIN sales s ON s.employee_id = e.employee_id
INNER JOIN vehicles v ON s.vehicle_id = v.vehicle_id;

-- Use a self join to list all sales that will be picked up on the same day,
-- including the full name of customer picking up the vehicle. .
SELECT
    CONCAT  (c.first_name, ' ', c.last_name) AS last_name,
    s1.invoice_number,
    s1.pickup_date
FROM sales s1
INNER JOIN sales s2
    ON s1.sale_id <> s2.sale_id 
    AND s1.pickup_date = s2.pickup_date
INNER JOIN customers c
   ON c.customer_id = s1.customer_id;

-- Produce a report that determines the most popular vehicle model that is leased.
SELECT 
    vt.vehicle_type_id,
    vt.model,
    COUNT(s.vehicle_id) AS total_sales
FROM 
    vehicletypes vt
JOIN 
    vehicles v ON vt.vehicle_type_id = v.vehicle_type_id
JOIN 
    sales s ON v.vehicle_id = s.vehicle_id
WHERE 
    s.sales_type_id = 2
GROUP BY 
    vt.vehicle_type_id, vt.model
ORDER BY 
    total_sales DESC
LIMIT 5;

-- What is the most popular vehicle make in terms of number of sales?
SELECT
    vt.make,
    COUNT(s.vehicle_id) AS total_sales
FROM 
    vehicletypes vt
JOIN 
    vehicles v ON vt.vehicle_type_id = v.vehicle_type_id
JOIN 
    sales s ON v.vehicle_id = s.vehicle_id
WHERE 
    s.sales_type_id = 1
GROUP BY vt.make
ORDER BY 
    total_sales DESC
LIMIT 5;

SELECT * FROM employeetypes;

--Which employee type sold the most of that make?
SELECT
    vt.make,
    et.employee_type_name,
    COUNT(s.vehicle_id) AS total_sales
FROM 
    vehicletypes vt
JOIN 
    vehicles v USING (vehicle_type_id)
JOIN 
    sales s USING (vehicle_id)
JOIN
    employees e USING (employee_id)
JOIN
    employeetypes et USING (employee_type_id)
WHERE 
    s.sales_type_id = 1
    AND vt.make = 'Nissan' 
GROUP BY 
    vt.make, et.employee_type_name
ORDER BY 
    total_sales DESC
LIMIT 5;
-- Answer: Customer Service

SELECT e.employee_id, e.first_name , e.last_name, 
       (SELECT sum(price) 
        FROM sales
        WHERE sales.employee_id = e.employee_id) as total
FROM employees e
ORDER BY total DESC;

SELECT employee_id, price
FROM sales
WHERE
price > (SELECT AVG(price) FROM sales)
ORDER BY price DESC;

-- This statement retrieves all of the fields of the the teacher table with the use of a subquery in the FROM clause.
SELECT e.first_name, e.last_name FROM 
(SELECT employees.first_name, employees.last_name FROM employees e);

select
	sales.employee_id,
	sum(sales.price) total_employee_sales
from
	employees
join
	sales
on
	sales.employee_id = employees.employee_id
group by
	sales.employee_id;

select distinct
	employees.last_name || ', ' || employees.first_name employee_name,
	sales.employee_id,
	sum(sales.price) over() total_sales,
	sum(sales.price) over(partition by employees.employee_id) total_employee_sales
from
	employees
join
	sales
on
	sales.employee_id = employees.employee_id
order by employee_name;

-- 1. Write a query that shows the total purchase sales income per dealership.
SELECT business_name, 
       sum(price) as total_sales
FROM 
	sales 
JOIN
	dealerships 
USING 
	(dealership_id)
JOIN 
	salestypes 
USING
	(sales_type_id)
WHERE sales_type_id = 1
GROUP BY business_name
ORDER BY total_sales DESC;

--2. Write a query that shows the purchase sales income per dealership for July of 2020.
SELECT d.business_name, 
       SUM(s.price) as total_sales
FROM 
	sales s
JOIN
	dealerships d
USING 
	(dealership_id)
JOIN 
	salestypes st
USING
	(sales_type_id)
WHERE 
	st.sales_type_id = 1
	AND EXTRACT(YEAR FROM s.purchase_date) = 2020
	AND EXTRACT(MONTH FROM s.purchase_date) = 7
GROUP BY d.business_name
ORDER BY total_sales DESC;

-- 3. Write a query that shows the purchase sales income per dealership for all of 2020.
SELECT d.business_name, 
       SUM(s.price) as total_sales
FROM 
	sales s
JOIN
	dealerships d
USING 
	(dealership_id)
JOIN 
	salestypes st
USING
	(sales_type_id)
WHERE 
	st.sales_type_id = 1
	AND EXTRACT(YEAR FROM s.purchase_date) = 2020
GROUP BY d.business_name
ORDER BY total_sales DESC;

-- 1. Write a query that shows the total lease income per dealership.
SELECT business_name, 
       sum(price) as total_leased
FROM 
	sales 
JOIN
	dealerships 
USING 
	(dealership_id)
JOIN 
	salestypes 
USING
	(sales_type_id)
WHERE sales_type_id = 2
GROUP BY business_name
ORDER BY total_leased DESC;

-- 2. Write a query that shows the lease income per dealership for Jan of 2020.
SELECT d.business_name, 
       SUM(s.price) as total_leased
FROM 
	sales s
JOIN
	dealerships d
USING 
	(dealership_id)
JOIN 
	salestypes st
USING
	(sales_type_id)
WHERE 
	st.sales_type_id = 2
	AND EXTRACT(YEAR FROM s.purchase_date) = 2020
	AND EXTRACT(MONTH FROM s.purchase_date) = 1
GROUP BY d.business_name
ORDER BY total_leased DESC;

-- 3. Write a query that shows the lease income per dealership for all of 2019.
SELECT d.business_name, 
       SUM(s.price) as total_leased
FROM 
	sales s
JOIN
	dealerships d
USING 
	(dealership_id)
JOIN 
	salestypes st
USING
	(sales_type_id)
WHERE 
	st.sales_type_id = 2
	AND EXTRACT(YEAR FROM s.purchase_date) = 2019
GROUP BY d.business_name
ORDER BY total_leased DESC;

-- 1. Write a query that shows the total income (purchase and lease) per employee.

select distinct
	employees.last_name || ', ' || employees.first_name employee_name,
	sum(sales.price) over(partition by employees.employee_id) total_sales
from
	employees
join
	sales
on
	sales.employee_id = employees.employee_id
order by total_sales DESC;

-- 1. Which model of vehicle has the lowest current inventory? This will help dealerships know which models the purchase from manufacturers.

SELECT vt.model,
       COUNT(*) AS inventory_count
FROM vehicles v
JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
GROUP BY vt.model
ORDER BY inventory_count;
-- Atlas

-- 2. Which model of vehicle has the highest current inventory? This will help dealerships know which models are, perhaps, not selling.
-- Maxima

--next  
WITH ModelsPerDealership AS (
    SELECT
        d.business_name,
        vt.model,
        COUNT(DISTINCT vt.model) AS num_models,
        COUNT(s.sale_id) AS num_sales
    FROM
        dealerships d
    JOIN
        vehicles v ON d.dealership_id = v.dealership_location_id
    JOIN
        sales s ON v.vehicle_id = s.vehicle_id
    JOIN
        vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
    GROUP BY
        d.business_name, vt.model
)
SELECT
    business_name,
    model,
    num_models,
    num_sales
FROM
    ModelsPerDealership
WHERE
    num_models = (
        SELECT MIN(num_models) FROM ModelsPerDealership
    )
ORDER BY
    num_sales;

-- How many emloyees are there for each role?
   
SELECT et.employee_type_name, COUNT(e.employee_id) AS employee_count
FROM employeetypes et
JOIN employees e ON et.employee_type_id = e.employee_type_id
GROUP BY et.employee_type_name;

--General Manager	    135
--Business Development	149
--Sales	                141
--Customer Service	    149
--Finance Manager	    144
--Porter	            144
--Sales Manager	        138

-- How many finance managers work at each dealership?

SELECT d.business_name, COUNT(e.employee_id) AS finance_manager_count
FROM dealerships d
JOIN dealershipemployees de ON d.dealership_id = de.dealership_id
JOIN employees e ON de.employee_id = e.employee_id
JOIN employeetypes et ON e.employee_type_id = et.employee_type_id
WHERE et.employee_type_name = 'Finance Manager'
GROUP BY d.business_name
ORDER BY finance_manager_count DESC;

--Get the names of the top 3 employees who work shifts at the most dealerships?

SELECT CONCAT(e.first_name, ' ', e.last_name) AS employee_name, 
       COUNT(DISTINCT de.dealership_id) AS dealership_count
FROM employees e
JOIN dealershipemployees de ON e.employee_id = de.employee_id
GROUP BY e.employee_id, employee_name
ORDER BY dealership_count DESC
LIMIT 3;

-- Get a report on the top two employees who has made the most sales through leasing vehicles.

SELECT CONCAT(e.first_name, ' ', e.last_name) AS employee_name, 
       SUM(s.price) AS total_sales
FROM employees e
JOIN sales s ON e.employee_id = s.employee_id
JOIN salestypes USING(sales_type_id)
WHERE sales_type_id = 2
GROUP BY employee_name
ORDER BY total_sales DESC
LIMIT 2;

--Boote Chittock	586620.33
--Kyle Corssen	    535344.58

-- What are the top 5 US states with the most customers who have purchased a vehicle from a dealership participating in the Carnival platform?

SELECT c.state, COUNT(*) AS customer_count
FROM customers c
JOIN sales s ON c.customer_id = s.customer_id
WHERE s.sales_type_id = 1
GROUP BY c.state
ORDER BY customer_count DESC
LIMIT 5;

--TX	298
--CA	276
--FL	210
--NY	121
--OH	116

--What are the top 5 US zipcodes with the most customers who have purchased a vehicle from a dealership participating in the Carnival platform?

SELECT c.zipcode, COUNT(*) AS customer_count
FROM customers c
JOIN sales s ON c.customer_id = s.customer_id
WHERE s.sales_type_id = 1
GROUP BY c.zipcode
ORDER BY customer_count DESC
LIMIT 5;

--80015	12
--32825	11
--84145	11
--53285	10
--36114	10

--What are the top 5 dealerships with the most customers?

SELECT d.business_name, COUNT(*) AS customer_count
FROM customers c
JOIN sales s ON c.customer_id = s.customer_id
JOIN dealerships d USING(dealership_id)
GROUP BY d.business_name
ORDER BY customer_count DESC
LIMIT 5;

--Junes Autos of Texas	125
--Meeler Autos of San Diego	119
--Mertgen Autos of Alabama	115
--Sollime Autos of Minnesota	114
--Twidell Autos of Kentucky	114

CREATE VIEW employee_dealership_names2 AS
  SELECT 
    e.first_name,
    e.last_name,
    d.business_name
  FROM employees e
  INNER JOIN dealershipemployees de ON e.employee_id = de.employee_id
  INNER JOIN dealerships d ON d.dealership_id = de.dealership_id;
  
SELECT
	*
FROM
	employee_dealership_names;

--1. Who are the top 5 employees for generating sales income?
	
SELECT distinct 
	concat(e.last_name, ', ', e.first_name) AS employee,
	SUM(s.price) OVER (PARTITION BY s.employee_id) AS total_sales
FROM sales s
JOIN employees AS e ON s.employee_id = e.employee_id 
ORDER BY total_sales desc 
LIMIT 5;

SELECT 
    CONCAT(e.last_name, ', ', e.first_name) AS employee,
    SUM(s.price) AS total_sales
FROM sales s
JOIN employees AS e ON s.employee_id = e.employee_id 
GROUP BY employee
ORDER BY total_sales DESC 
LIMIT 5;

-- 2. Who are the top 5 dealership for generating sales income?
SELECT DISTINCT
    d.business_name AS dealership,
    SUM(s.price) AS total_sales_income
FROM sales s
JOIN dealerships d ON s.dealership_id = d.dealership_id
GROUP BY d.business_name
ORDER BY total_sales_income DESC
LIMIT 5;

-- 3. Which vehicle model generated the most sales income?
SELECT
    vt.model AS vehicle_model,
    SUM(s.price) AS total_sales_income
FROM sales s
JOIN vehicles v ON s.vehicle_id = v.vehicle_id
JOIN vehicletypes vt ON v.vehicle_type_id = vt.vehicle_type_id
WHERE s.sale_returned IS FALSE
GROUP BY vt.model
ORDER BY total_sales_income DESC
LIMIT 1;

-- Which employees generate the most income per dealership?
WITH TopIncomeEmployees AS (
    SELECT
        d.business_name,
        de.employee_id,
        CONCAT(e.last_name, ', ', e.first_name) AS employee,
        SUM(s.price) AS total_sales
    FROM sales s
    JOIN dealershipemployees de ON s.employee_id = de.employee_id
    JOIN employees AS e ON de.employee_id = e.employee_id
    JOIN dealerships d ON de.dealership_id = d.dealership_id
    GROUP BY d.business_name, de.employee_id, e.last_name, e.first_name
),
RankedSales AS (
    SELECT
        business_name,
        employee,
        total_sales,
        RANK() OVER (PARTITION BY business_name ORDER BY total_sales DESC) AS income_rank
    FROM TopIncomeEmployees
)
SELECT business_name, employee, total_sales
FROM RankedSales
WHERE income_rank = 1
ORDER BY total_sales DESC;

WITH TopSalesEmployees AS (
    SELECT
        d.business_name,
        de.employee_id,
        CONCAT(e.last_name, ', ', e.first_name) AS employee,
        COUNT(s.sale_id) AS total_sales_count
    FROM sales s
    JOIN dealershipemployees de ON s.employee_id = de.employee_id
    JOIN employees e ON de.employee_id = e.employee_id
    JOIN dealerships d ON de.dealership_id = d.dealership_id
    GROUP BY d.business_name, de.employee_id, e.last_name, e.first_name
),
RankedSales AS (
    SELECT
        business_name,
        employee,
        total_sales_count,
        RANK() OVER (PARTITION BY business_name ORDER BY total_sales_count DESC) AS sales_rank
    FROM TopSalesEmployees
)
SELECT business_name, employee, total_sales_count
FROM RankedSales
WHERE sales_rank = 1
ORDER BY total_sales_count DESC;

-- In our Vehicle inventory, show the count of each Model that is in stock.
SELECT
    vt.model,
    COUNT(v.vehicle_id) AS stock_count
FROM vehicletypes vt
LEFT JOIN vehicles v USING (vehicle_type_id)
WHERE v.is_sold IS FALSE
GROUP BY vt.model
ORDER BY stock_count DESC;


SELECT DISTINCT vt.model,
	count(s.vehicle_id) OVER (PARTITION BY vt.model) AS count_of_model
FROM sales AS s
JOIN vehicles as v ON s.vehicle_id = v.vehicle_id
JOIN vehicletypes AS vt ON v.vehicle_type_id = vt.vehicle_type_Id
WHERE v.is_sold IS FALSE
ORDER BY count_of_model DESC;

-- In our Vehicle inventory, show the count of each Make that is in stock.

SELECT DISTINCT vt.make,
	count(s.vehicle_id) OVER (PARTITION BY vt.make) AS count_of_make
FROM sales AS s
JOIN vehicles as v ON s.vehicle_id = v.vehicle_id
JOIN vehicletypes AS vt ON v.vehicle_type_id = vt.vehicle_type_Id
WHERE v.is_sold IS FALSE
ORDER BY count_of_make DESC;

-- In our Vehicle inventory, show the count of each BodyType that is in stock.

SELECT DISTINCT vt.body_type,
	count(s.vehicle_id) OVER (PARTITION BY vt.body_type) AS count_of_body
FROM sales AS s
JOIN vehicles as v ON s.vehicle_id = v.vehicle_id
JOIN vehicletypes AS vt ON v.vehicle_type_id = vt.vehicle_type_Id
WHERE v.is_sold IS FALSE
ORDER BY count_of_body DESC;

-- Which US state's customers have the highest average purchase price for a vehicle?

SELECT
    c.state,
    ROUND(AVG(s.price), 2) AS avg_purchase_price
FROM customers c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.state
ORDER BY avg_purchase_price DESC
LIMIT 1;


-- Now using the data determined above, which 5 states have the customers with the highest average purchase price for a vehicle?

SELECT
    c.state,
    ROUND(AVG(s.price), 2) AS avg_purchase_price
FROM customers c
JOIN sales s ON c.customer_id = s.customer_id
GROUP BY c.state
ORDER BY avg_purchase_price DESC
LIMIT 5;

SELECT COUNT(de.dealership_id) AS dealership_count
FROM dealershipemployees de
JOIN employees e ON de.employee_id = e.employee_id
WHERE e.first_name = 'Deb' AND e.last_name = 'Gioan';

SELECT MAX(dealership_count) AS max_dealership_count
FROM (
    SELECT employee_id, COUNT(DISTINCT dealership_id) AS dealership_count
    FROM dealershipemployees
    GROUP BY employee_id
) AS employee_dealership_counts;

SELECT SUM(s.price) AS total_sales_sum
FROM dealershipemployees de
JOIN employees e ON de.employee_id = e.employee_id
JOIN sales s ON de.employee_id = s.employee_id
WHERE e.first_name = 'Deb' AND e.last_name = 'Gioan';

SELECT d.business_name AS dealership,
       SUM(s.price) AS total_sales_sum
FROM dealershipemployees de
JOIN employees e ON de.employee_id = e.employee_id
JOIN sales s ON de.employee_id = s.employee_id
JOIN dealerships d ON de.dealership_id = d.dealership_id
WHERE e.first_name = 'Deb' AND e.last_name = 'Gioan'
GROUP BY d.business_name;



