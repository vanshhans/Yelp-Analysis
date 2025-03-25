--UDF 

CREATE OR REPLACE FUNCTION analyze_sentiment(text STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('textblob') 
HANDLER = 'sentiment_analyzer'
AS $$
from textblob import TextBlob
def sentiment_analyzer(text):
    analysis = TextBlob(text)
    if analysis.sentiment.polarity > 0:
        return 'Positive'
    elif analysis.sentiment.polarity == 0:
        return 'Neutral'
    else:
        return 'Negative'
$$;


--yelp reviews table 

create or replace table yelp_reviews (review_text variant);

copy into yelp_reviews
from 's3://yelp-analysis-data'
credentials=(
    AWS_KEY_ID='************'
    AWS_SECRET_KEY='***********'
)
FILE_FORMAT=(TYPE=JSON);

create or replace table tbl_yelp_reviews as 
select review_text:business_id::string as business_id,
review_text:date::date as review_date,
review_text:user_id::string as user_id,
review_text:stars::number as review_stars,
review_text:text::string as review_text,
analyze_sentiment(review_text) as sentiments
from yelp_reviews limit 10;


----yelp_businesses table

create or replace table yelp_businesses (business_text variant);

copy into yelp_businesses
from 's3://yelp-analysis-data/yelp_academic_dataset_business.json'
credentials=(
    AWS_KEY_ID='*****************'
    AWS_SECRET_KEY='**************'
)
FILE_FORMAT=(TYPE=JSON);

create table tbl_yelp_businesses as
select business_text:business_id::string as business_id,
business_text:city::string as city,
business_text:state::string as state,
business_text:review_count::string as review_count,
business_text:stars::number as stars,
business_text:categories::string as categories
from yelp_businesses limit 10;
