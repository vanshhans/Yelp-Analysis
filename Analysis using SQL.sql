select * from tbl_yelp_reviews limit 10;
select * from tbl_yelp_businesses limit 10;

--1 find number of businesses in each category

select
    trim(a.value) as category,count(business_id) as cnt
from tbl_yelp_businesses
,lateral split_to_table(categories,',') a
group by trim(a.value)


--2 find top 10 users who have reviewed the most businesses in restaurant category

select r.user_id,count(distinct r.business_id) as cnt
from tbl_yelp_reviews r
inner join tbl_yelp_businesses b
on r.business_id=b.business_id
where b.categories ilike '%restaurant%'
group by r.user_id
order by cnt desc
limit 10


--3 find the most popular categories of businesses (based on number of reviews)

with cte1 as(
select business_id,trim(a.value) as category
from tbl_yelp_businesses
,lateral split_to_table(categories,',') a
)
select cte1.category,count(*) as no_of_reviews
from cte1
inner join tbl_yelp_reviews r
on cte1.business_id=r.business_id
group by cte1.category
order by no_of_reviews desc


--4 find the top 3 most recent reviews for each business

with cte1 as(
select *,row_number() over(partition by  business_id order by review_date desc) rn
from tbl_yelp_reviews
)
select *
from cte1 
where rn<=3


--5 find the month with the highest no of reviews

select month(review_date),count(*) as no_of_reviews
from tbl_yelp_reviews 
group by month(review_date)
order by no_of_reviews desc
limit 1

--6 find %age of 5 star reviews for each business

with cte1 as(
select business_id,count(*) as no_of_5stars
from tbl_yelp_reviews
where review_stars=5
group by business_id)
,cte2 as(
select cte1.business_id,no_of_5stars,count(review_stars) over(partition by r.business_id) as no_of_reviews
from tbl_yelp_reviews r
inner join cte1
on r.business_id=cte1.BUSINESS_ID)
select distinct business_id,100*no_of_5stars/no_of_reviews
from cte2


--7 find the top 5 most reviewed businesses in each city

with cte1 as(
select b.business_id,b.city,count(*) as no_of_reviews
from tbl_yelp_businesses b
inner join tbl_yelp_reviews r
on b.business_id=r.business_id
group by b.business_id,b.city)
,cte2 as(
select *,row_number() over(partition by city order by no_of_reviews desc) as rn
from cte1)
select *
from cte2
where rn<=5


--8 find avg rating of businesses that have atleast 1000 reviews


select business_id,count(*) as no_of_reviews,avg(review_stars) as avg_rating
from tbl_yelp_reviews
group by business_id
having no_of_reviews>=100


--9 list top 10 users who have written the most reviews. along with businesses they reviewed

with cte1 as(
select user_id,count(*) as no_of_reviews
from tbl_yelp_reviews
group by user_id
order by no_of_reviews desc
limit 10)
select r.business_id,cte1.*
from cte1
inner join tbl_yelp_reviews r
on cte1.user_id=r.user_id


--10 find top 10 businesses with highest +ve sentiment reviews

select business_id,count(*) as positive_reviews
from tbl_yelp_reviews
where sentiments='Positive'
group by business_id
order by positive_reviews desc
limit 10
