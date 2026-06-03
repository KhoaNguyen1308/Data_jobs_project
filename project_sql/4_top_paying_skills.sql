/* 
QuestionL What are the top skills based on salary?
- Look at the average salary associated with each skill for Data Analyst positions
- Focus on roles with specified salaries
- Why? It reveals how different skills impact salary levels for Data Analysts and 
    helps identify the most financially rewarding skills to acquire or improve 
*/


SELECT 
    skills,
    ROUND (AVG(salary_year_avg), 0) AS avg_salary
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short IN ('Data Analyst','Business Analyst') AND
    job_country IN ('Italy', 'Switzerland', 'Netherlands','Vietnam') AND
    salary_year_avg IS NOT NULL
GROUP BY 
    skills
ORDER BY 
    avg_salary DESC
LIMIT 25;

/*
The NoSQL outlier. NoSQL sits $37k above Azure in second place — a remarkable gap. It's likely driven by a small number of very high-paying specialist roles rather than broad demand, so treat it as a premium niche rather than a widely-applicable signal.
Cloud/Big Data forms a dominant top tier. The first six skills are all cloud or big data (NoSQL, Azure, AWS, Hadoop, Airflow, PySpark), ranging from $111k–$177k. There's then a noticeable drop into the $100–110k band. This confirms the cloud premium seen earlier — these skills aren't just better paid, they occupy a clearly separate tier.
Microsoft Office skills appearing this high is surprising. Outlook, Word, and MS Access all sit between $105k–$108k — above Scala, Go, and well above SQL. This almost certainly reflects a confounding factor: these skills appear on high-paying senior roles (like director-level or enterprise BA positions) where MS Office proficiency is listed alongside more advanced skills, rather than being the driver of the salary itself.
SQL is near the bottom despite being the most demanded skill. At $87k average, SQL appears in the most job postings but ranks 23rd out of 25 by salary. This makes sense — SQL is a baseline expectation across all seniority levels, so its average gets pulled down by junior roles. It's essential to get hired, but not a salary differentiator on its own.
The $85k–$100k band is crowded. SQL, Spark, R, SAS, Cognos, Redshift, Looker and several others cluster here — these are the "table stakes" skills that are expected but not differentiating for top pay.
*/