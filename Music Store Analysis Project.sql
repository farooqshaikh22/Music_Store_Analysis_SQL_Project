-- 1.Who is the senior most employee based on job title
SELECT first_name,last_name,title
FROM Employee
ORDER BY levels desc
LIMIT 1

-- 2.Which countries have the most Invoices?

SELECT billing_country,COUNT(DISTINCT invoice_id)total_invoice FROM invoice
GROUP BY billing_country
ORDER BY total_invoice DESC;

-- 3.What are top 3 values of total invoice?
SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;

/* Q4: Which city has the best customers? We would like to throw
a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of 
invoice totals.Return both the city name & sum of all invoice
totals */

SELECT billing_city,sum(total)total FROM invoice
GROUP BY billing_city
ORDER BY total DESC
LIMIT 1;

/* Q5: Who is the best customer? The customer who has spent the
most money will be declared the best customer. Write a query that
returns the person who has spent the most money.*/

WITH T1 AS (
	
	SELECT a.customer_id,a.first_name,a.last_name,sum(b.total)total_spent
	FROM customer a
	INNER JOIN invoice b
	ON a.customer_id = b.customer_id
	GROUP BY a.customer_id,a.first_name,a.last_name
)
SELECT * FROM T1
ORDER BY T1.total_spent DESC
LIMIT 1;

/* Q6.Write query to return the email, first name, last name, & 
Genre of all Rock Music listeners. Return your list ordered 
alphabetically by email starting with A. */

SELECT DISTINCT a.email,a.first_name,a.last_name from customer a
INNER JOIN invoice b ON a.customer_id=b.customer_id
INNER JOIN invoice_line c ON b.invoice_id = c.invoice_id
INNER JOIN track d ON c.track_id = d.track_id
INNER JOIN genre e ON d.genre_id = e.genre_id
WHERE e.name = 'Rock'
ORDER BY email;

/* Q7: Let's invite the artists who have written the most 
rock music in our dataset. Write a query that returns the Artist
name and total track count of the top 10 rock bands.*/

SELECT a.name artist_name,COUNT(d.name) total_track FROM artist a
INNER JOIN album b ON a.artist_id = b.artist_id
INNER JOIN track c ON b.album_id = c.album_id
INNER JOIN genre d ON c.genre_id = d.genre_id
WHERE d.name LIKE 'Rock'
GROUP BY a.name
ORDER BY total_track DESC
LIMIT 10;

/* Q8: Return all the track names that have a song length longer
than the average song length. Return the Name and Milliseconds
for each track. Order by the song length with the longest songs
listed first. */

SELECT name song_name,milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

/* Q9: Find how much amount spent by each customer on artists?
Write a query to return customer name, artist name and
total spent */

WITH T1 AS (
	SELECT DISTINCT f.first_name,f.last_name,e.invoice_date,a.artist_id,a.name artist_name,b.album_id,c.track_id,d.unit_price,
	d.quantity,e.invoice_id FROM artist a
	INNER JOIN album b ON a.artist_id = b.artist_id
	INNER JOIN track c ON b.album_id = c.album_id
	INNER JOIN invoice_line d ON d.track_id = c.track_id
	INNER JOIN invoice e ON d.invoice_id = e.invoice_id
	INNER JOIN customer f ON e.customer_id = f.customer_id
)
SELECT first_name,last_name,artist_name,SUM(unit_price*quantity)total_spent
FROM T1
GROUP BY first_name,last_name,artist_name
ORDER BY total_spent DESC


/* Q10. We want to find out the most popular music Genre for 
each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns
each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres.*/


WITH T1 AS (
	SELECT DISTINCT a.billing_country,SUM(a.total)total_spent,d.name genre FROM invoice a
	INNER JOIN invoice_line b ON a.invoice_id = b.invoice_id
	INNER JOIN track c ON b.track_id = c.track_id
	INNER JOIN genre d ON c.genre_id = d.genre_id
	GROUP BY a.billing_country,d.name	
),
T2 AS (
	SELECT *,
	RANK() OVER(PARTITION BY T1.billing_country ORDER BY total_spent DESC)rnk
	FROM T1
)
SELECT T2.billing_country,T2.genre,T2.total_spent
FROM T2
WHERE rnk=1

/* Q11: Write a query that determines the customer that has spent
the most on music for each country. Write a query that returns
the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all
customers who spent this amount. */

WITH T1 AS (
	SELECT a.customer_id,a.first_name,a.last_name,a.country,SUM(b.total)total_spent FROM customer a
	INNER JOIN invoice b ON a.customer_id = b.customer_id
	GROUP BY 1,2,3,4	
),
T2 AS (
	SELECT *,
	RANK() OVER(PARTITION BY country ORDER BY total_spent DESC)rnk
	FROM T1
)
SELECT T2.customer_id,T2.first_name,T2.last_name,T2.country,T2.total_spent
FROM T2
WHERE rnk=1;


