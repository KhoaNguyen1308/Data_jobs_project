/*
Question: What are the top_paying data analyst jobs?
- Identify the top 10 highest_paying Data Analyst roles that are available remotely 
- Focuses on job postings with specified slaries (remove nulls)
- Why? Highlight the top-paying opportunities for Data Analysts, offering insights into empolyment opportunities 
*/

SELECT
    job_id,
    job_title,
    job_location,
    job_schedule_type,
    salary_year_avg,
    job_posted_date,
    name AS copmany_name
FROM
    job_postings_fact
LEFT JOIN company_dim ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_title_short IN ( 'Data Analyst', 'Business Analyst') AND
    job_country IN ('Italy', 'Switzerland', 'Netherlands','Vietnam') AND
    salary_year_avg IS NOT NULL
ORDER BY
    salary_year_avg DESC
LIMIT 100;

