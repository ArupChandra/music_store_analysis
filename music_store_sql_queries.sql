CREATE DATABASE MUSIC_STORE;

-- Q1. Who is the senior most employee based on job title?

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Q2. which country have the most invoices?

SELECT COUNT(*) AS invoice_count, billing_country
FROM invoice
GROUP BY billing_country
ORDER BY invoice_count DESC
LIMIT 1;

-- Q3. what are top 3 values of total invoice?

SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Q4. which city has the best customers? 
-- We would like to throw a promotional Music Festival in the city we made the most money. 
-- Write a query that returns one city that has highest sum of invoice totals. 
-- Return both city name and sum of all invoice totals.

SELECT SUM(total) AS invoice_total, billing_city 
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1;

-- Q5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 
-- Write a query that returns the person who has spent the most money.

SELECT customer.customer_id, customer.first_name, customer.last_name, 
SUM(invoice.total) AS total_spent
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id, customer.first_name, customer.last_name
ORDER BY total_spent DESC
LIMIT 1;

-- Q6. Write auery to return the email, first name, last name, genre of all Rock Music listeners. 
-- Return your list ordered alphabetically by email starting with A.

SELECT DISTINCT email, first_name, last_name 
FROM customer
JOIN invoice ON customer.customer_id = invoice.invoice_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;

-- Q7. Let's invite the artists who have written the most rock music in our dataset. 
-- Write a query that returns the Artist name and total track count of the top 10 rock bands.

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs
FROM artist
JOIN album2 ON artist.artist_id = album2.artist_id
JOIN track ON album2.album_id = track.album_id
JOIN genre ON track.genre_id = genre.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id, artist.name
ORDER BY number_of_songs DESC
LIMIT 10;

-- Q8. Return all the track names that have a song lenght longer than the average song lenght. 
-- Return the name and millieseconds for each track. Order by the song lenght with the longest songs listed first.

SELECT name, milliseconds 
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_track_length
    FROM track)
ORDER BY milliseconds DESC;

-- Q9. We want to find out the most popular music genre for each country. 
-- We determine the most popular genre as the genre with the highest amount of purchases. 
-- Write a query that returns each country along with the top genre. 
-- For countries where the maximum number of purchases is shared return all genres.

WITH popular_genre AS (
	SELECT genre.name, genre.genre_id, customer.country, 
	COUNT(invoice_line.quantity) AS purchases,
	ROW_NUMBER() OVER(PARTITION BY customer.country 
    ORDER BY COUNT(invoice_line.quantity)DESC) AS RowNo
	FROM invoice_line
	JOIN invoice ON invoice_line.invoice_id = invoice.invoice_id
	JOIN customer ON invoice.customer_id = customer.customer_id
	JOIN track ON invoice_line.track_id = track.track_id
	JOIN genre ON track.genre_id = genre.genre_id
	GROUP BY genre.name, genre.genre_id, customer.country 
	ORDER BY customer.country ASC, purchases DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;

-- Q10.  Write a query that determines the customer that has spent the most on music for each country.
-- Write a query that returns the country along with the top customer and how much they spent.
-- For countries where the top amount spent is shared, provide all customers who spent this amount.

WITH customer_with_country AS (
	SELECT customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country,
    SUM(total) AS total_spending,
    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo
    FROM invoice
    JOIN customer ON customer.customer_id = invoice.customer_id
    GROUP BY customer.customer_id, customer.first_name, customer.last_name, invoice.billing_country
    ORDER BY billing_country ASC, total_spending DESC
)
SELECT * FROM customer_with_country WHERE RowNo = 1;