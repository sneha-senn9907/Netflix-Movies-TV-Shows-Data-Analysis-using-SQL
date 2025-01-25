--Database setup
create database Netflix
use Netflix
--Imported excel file netflix.csv
select * from Netflix_titles

--1. Count the number of Movies vs TV Shows
select type,count(*) as Count from netflix_titles group by type

--2. Find the most common rating for movies and TV shows
select type,
	   rating from
	   (select rating,type,count(*) as count,
	   rank() over(partition by type order by count(*) desc) as ranking 
	   from netflix_titles group by type,rating 
        ) as t1 
	where ranking=1

--3. List all movies released in a specific year (e.g., 2020)
select title as 'Movies released in the year 2020' from netflix_titles
	where type='movie' and release_year='2020'

--4. Find the top 5 countries with the most content on Netflix
select top(5)trim(value)as country,
		count(*) Total_content from netflix_titles
		cross apply string_split(country,',')
  where trim(value) is not null 
  group by trim(value) 
  order by Total_content desc

--5. Identify the longest movie
select title as Longest_movies,duration from netflix_titles 
	where type='Movie' and duration=(select max(duration) from netflix_titles)

--6. Find content added in the last 5 years
select title,convert(date,date_added,100) as Date_added from netflix_titles 
	where datediff(year,date_added,getdate())<5

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select title as'movies/TV shows by director Rajiv Chilaka',director from netflix_titles 
	where director like'%Rajiv Chilaka%'

--8. List all TV shows with more than 5 seasons
select title,duration from netflix_titles where type='Tv Show' and substring(duration, 1, 1)>5

--9. Count the number of content items in each genre
select trim(value) as Genre, count(*) as Total_content from netflix_titles cross apply string_split(listed_in,',') 
	group by trim(value) 
	order by total_content

--10.Find each year and the average numbers of content release in India on netflix. return top 5 year with highest avg content release!
select top 5 Release_year, AVG(Content_count) as Avg_content from
(
	select year(CONVERT(date,date_added,100)) as Release_year, 
	COUNT(*) As Content_count from netflix_titles 
	where country like '%India%' 
	group by year(CONVERT(date,date_added,100))
)
as Content_release
group by Release_year 
order by Avg_content desc

--11. List all movies that are documentaries
select listed_in,title as Documentaries from netflix_titles
	where listed_in like '%Documentaries%'

--12. Find all content without a director
select title from netflix_titles where director is null

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select * from netflix_titles
	where cast like '%Salman Khan%' and release_year>YEAR(getdate())- 10

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
select top(10)trim(value)as Actors,
		count(*) as Total_Movie_appreacnce  from netflix_titles
		cross apply string_split(cast,',')
where country like '%India' 
group by trim(value) 
order by Total_Movie_appreacnce desc

--15.Categorize the content based on the presence of the keywords 'kill' and 'violence' in  the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.
select category,COUNT(*) as Content_count from
(select 
	case 
		when description like '%kill' or description like '%violence%' then 'Bad'
		else 'Good'
	end as Category
from netflix_titles) as categorized_content 
group by Category


----End of Project
