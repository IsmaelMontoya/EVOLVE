/* Count nº of rows*/
SELECT 
	COUNT(1)
FROM Album; --347 
	
SELECT 
	* 
FROM Album;

SELECT 
	Title 
FROM Album
LIMIT 10;

CREATE TABLE IF NOT EXISTS Album_Title AS 
	SELECT 
		Title
	FROM Album;

SELECT 
	*
FROM Album_Title AS at;

-- Ejercicio 1
select count(*) as num_cols from pragma_table_info('customer'); --13

select * from customer limit 5; --Czech Republic

SELECT Country FROM Customer WHERE rowid = 5; --Czech Republic

select lastname from customer order by lastname; --Bernard

select count(*) from invoice; --412

-- Ejercicio 2
select count(*) from invoice where total > 20;

select count(*) from invoice where total between 10 and 20;

select count(*) from invoice where BillingCountry in ('Brazil','Argentina','Chile');

select * from invoice where BillingCountry like 'C%';

select count(distinct CustomerId ) from Customer where Company is not null;



SELECT DATE('now');


SELECT 
     CustomerId, CAST(CustomerId AS INT)
FROM Customer
LIMIT 10;

SELECT COUNT(DISTINCT EmployeeId) AS Num_Employees
FROM Employee;


-- Ejercicio 3
select count(distinct EmployeeId) from employee;

ALTER TABLE Employee ADD COLUMN PhoneLocal TEXT;

UPDATE Employee SET PhoneLocal = SUBSTR(Phone, LENGTH(Phone) - 7, 8);

SELECT MAX(LENGTH(LastName)) FROM Employee;

SELECT COUNT(*) FROM Employee WHERE strftime('%w', BirthDate) = '0';

SELECT MAX(strftime('%Y', HireDate) - strftime('%Y', BirthDate)) FROM Employee;

