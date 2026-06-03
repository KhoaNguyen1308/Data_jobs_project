/*
Questions: What skills are required for the top_paying data analyst jobs?
- Use the top 10 highest-paying jobs from first query 
- Add the specific skills required for these roles
- Why? It provides a detailed look at which high_paying jobs demand certain skills,
    helping job seekers understand which skills to develop tha align with top salaries
*/

WITH top_paying_jobs AS (
 SELECT
    job_id,
    job_title,
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
LIMIT 100
)

SELECT 
    top_paying_jobs.* ,
    skills
FROM top_paying_jobs
INNER JOIN skills_job_dim ON top_paying_jobs.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
ORDER BY
    salary_year_avg DESC

/*
the key takeaways:
SQL and Python are non-negotiable. SQL appears in 31 postings (56% of jobs) and Python in 24 (44%). Together they form the core baseline for top-paying analyst roles — virtually every strong candidate is expected to have both.
The "cloud premium" is real. Despite being rarely required (AWS and Azure appear in only 2–3 jobs each), cloud skills carry by far the highest salary associations — NoSQL at $177k, Azure at $140k, AWS at $123k. These are specialist signals that push compensation up significantly when they appear.
Big Data skills punch above their weight. Hadoop, Airflow, and PySpark are uncommon in the postings but rank in the top salary tier ($111–114k on average), suggesting niche demand with a strong pay premium.
Visualisation tools are common but commoditised. Tableau, Power BI, and Looker each appear 6–13 times, making them the third-most demanded category — but they sit in the middle of the salary range (~$84k avg), indicating they're expected rather than differentiating.
Excel is table stakes, not a differentiator. It appears 13 times but is associated with the lowest average salaries among common skills (~$75k), closely followed by other spreadsheet tools like VBA. Good to have, but not a lever for higher pay.
*/