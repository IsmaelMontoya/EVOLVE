SELECT 
	BillingCountry, COUNT(*) 
FROM Invoice i
GROUP BY BillingCountry 
;

SELECT 
	BillingCountry, SUM(Total) AS Total_Country
FROM Invoice i
GROUP BY BillingCountry
ORDER BY SUM(Total) DESC
;

SELECT 
	BillingCountry, ROUND(AVG(Total), 2) AS Average_Total
FROM Invoice i
GROUP BY BillingCountry 
;

-- MIN() & MAX() can be used

SELECT 
	*  
FROM Invoice i
GROUP BY BillingCountry, BillingCity
;

SELECT 
	i.BillingCountry, SUM(Total) AS Total_Country
FROM Invoice i
GROUP BY i.BillingCountry
HAVING Total_Country > 40 AND i.BillingCountry in ('USA', 'Canada', 'Mexico')
ORDER BY Total_Country DESC
;



SELECT * FROM Invoice i;

SELECT 
	i.InvoiceId, i.CustomerId, i.Total,
	CASE
		WHEN Total >=20 THEN 'High'
		WHEN Total >=10 THEN 'Mid'
		ELSE 'Low'
	END AS Invoice_Bucket
FROM Invoice i ;


SELECT 
	CASE
		WHEN Total >=20 THEN 'High'
		WHEN Total >=10 THEN 'Mid'
		ELSE 'Low'
	END AS Invoice_Bucket, COUNT(*) AS N_Invoices, SUM(Total) AS Revenue
FROM Invoice i
GROUP BY
	Invoice_Bucket 
ORDER BY Revenue DESC;




-- Ejercicio 4
SELECT BillingCountry,  SUM(Total) FROM Invoice GROUP BY BillingCountry ORDER BY SUM(Total) DESC;

SELECT COUNT(*) FROM InvoiceLine;

SELECT COUNT(DISTINCT UnitPrice) FROM InvoiceLine;

SELECT UnitPrice,COUNT(*) FROM InvoiceLine GROUP BY UnitPrice ORDER BY UnitPrice;

--Without Join
SELECT TrackId, COUNT(*) AS TimesDownloaded FROM InvoiceLine GROUP BY TrackId ORDER BY TimesDownloaded DESC;

--With Join

SELECT il.TrackId,
       t.Name AS TrackName,
       COUNT(*) AS VecesDescargada
FROM InvoiceLine AS il
JOIN Track AS t ON il.TrackId = t.TrackId
GROUP BY il.TrackId
ORDER BY VecesDescargada DESC;


SELECT MIN(InvoiceDate), MAX(InvoiceDate) FROM Invoice;


-- Ejercicio 5
SELECT 
    t.Name      AS TrackName,
    SUM(il.Quantity)    AS NumDescargas
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
GROUP BY t.TrackId, t.Name
ORDER BY NumDescargas DESC
LIMIT 5;

SELECT COUNT(DISTINCT a.AlbumId)
FROM InvoiceLine il
JOIN Track t  ON il.TrackId = t.TrackId
JOIN Album a  ON t.AlbumId = a.AlbumId;

SELECT 
    g.Name      AS GenreName,
    SUM(il.Quantity)    AS NumDescargas
FROM InvoiceLine il
JOIN Track t ON il.TrackId = t.TrackId
JOIN Genre g ON t.GenreId = g.GenreId
GROUP BY g.GenreId, g.Name
ORDER BY NumDescargas DESC
LIMIT 1;
