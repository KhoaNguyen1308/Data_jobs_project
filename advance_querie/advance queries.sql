SELECT job_posted_date FROM job_postings_fact LIMIT 10;

SELECT
    job_title_short AS title,
    job_location AS location,
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date_time,
    EXTRACT(MONTH FROM job_posted_date) AS date_month
FROM 
    job_postings_fact
LIMIT 10;

SELECT
    COUNT(job_id) AS job_posted_count,
    EXTRACT(MONTH FROM job_posted_date) AS MONTH
FROM 
    job_postings_fact
WHERE 
    job_title_short = 'Data Analyst'
GROUP BY 
    month
ORDER BY
    job_posted_count DESC;


SELECT 
    AVG(salary_year_avg) AS yearly_avg,
    AVG(salary_hour_avg) AS hourly_avg,
    job_schedule_type
FROM
    job_postings_fact
WHERE
    job_posted_date > '2023-06-01'
GROUP BY
    job_schedule_type;

SELECT
    COUNT(job_id) AS job_posted_count,
    EXTRACT(MONTH FROM 
    job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') AS month
FROM 
    job_postings_fact
WHERE
    EXTRACT(YEAR FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') = 2023
GROUP BY
    MONTH
ORDER BY
    MONTH;

SELECT
    job_posted_date,
    job_postings_fact.company_id,
    company_dim.name,
    job_postings_fact.job_health_insurance 
FROM 
    job_postings_fact
INNER JOIN company_dim
    ON job_postings_fact.company_id = company_dim.company_id
WHERE
    job_postings_fact.job_health_insurance = 'true'
    AND 
    EXTRACT(YEAR FROM job_posted_date) = 2023
    AND
    EXTRACT(QUARTER FROM job_posted_date) = 2;

SELECT *
FROM ( -- SubQuery starts here
	SELECT * 
	FROM job_postings_fact
	WHERE EXTRACT(MONTH FROM job_posted_date) = 1) AS january_jobs;
	-- SubQuery ends here


WITH january_jobs AS (-- CTE definition starts here 
	SELECT *
	FROM job_postings_fact
	WHERE EXTRACT (MONTH FROM job_posted_date) = 1
	) -- CTE definition ends here

SELECT * 
FROM january_jobs;


SELECT 
    company_id,
    name AS company_name
FROM 
    company_dim
WHERE company_id IN (
    SELECT 
        company_id
    FROM 
        job_postings_fact
    WHERE
        job_no_degree_mention = true
);

/* 
Find the companies that have the most job openings
 - Get the total number of jobs postings per company id (job_postings_fact)
 - Return the toal number of jobs with the company name (company_dim)
*/ 

WITH company_job_count AS(
    SELECT 
        company_id,
        COUNT(*) AS total_jobs
    FROM 
        job_postings_fact
    GROUP BY   
        company_id
)
SELECT 
    company_dim.name AS company_name,
    company_job_count.total_jobs
FROM company_dim
LEFT JOIN company_job_count ON company_job_count.company_id = company_dim.company_id
ORDER BY company_job_count.total_jobs;



SELECT
    skills_dim.skills,
    skills_dim.skill_id,
    top_skills.total_skill
FROM 
    (
    SELECT
        skills_job_dim.skill_id,
        COUNT(*) AS total_skill
    FROM 
        skills_job_dim
    GROUP BY
        skills_job_dim.skill_id
    ORDER BY
        total_skill DESC
    LIMIT 5 
) AS top_skills
LEFT JOIN skills_dim ON top_skills.skill_id = skills_dim.skill_id
ORDER BY top_skills.total_skill DESC;


SELECT 
    company_dim.name,
    job_number.company_id,
    job_number.number_of_jobs,
    CASE
        WHEN number_of_jobs > 50 THEN 'Large'
        WHEN number_of_jobs BETWEEN 10 AND 50 THEN 'Medium'
        WHEN number_of_jobs < 10 THEN 'Small'
    END AS company_size
FROM (
    SELECT 
        company_id,
        COUNT(job_id) AS number_of_jobs
    FROM 
        job_postings_fact
    GROUP BY 
        company_id
    ORDER BY number_of_jobs DESC) AS job_number
INNER JOIN company_dim ON job_number.company_id = company_dim.company_id;

/* 
Find the count of the number of remote job postings per skills
 - Display the top 5 skiklls by their demand in remote jobs
 - Include skill id, name, and count of postings requiring the skill
*/ 


WITH remote_job_skills AS (
SELECT
    skills_job_dim.skill_id,
    COUNT(*) AS skill_count 
FROM
    skills_job_dim
INNER JOIN job_postings_fact ON job_postings_fact.job_id = skills_job_dim.job_id
WHERE
    job_postings_fact.job_work_from_home = true
    AND 
    job_postings_fact.job_title_short = 'Data Analyst'
GROUP BY
    skills_job_dim.skill_id
)

SELECT 
    skills_dim.skill_id,
    skills_dim.skills AS skill_name,
    remote_job_skills.skill_count
FROM remote_job_skills
INNER JOIN skills_dim ON skills_dim.skill_id = remote_job_skills.skill_id
ORDER BY
    skill_count DESC
LIMIT 5;


WITH q1_job_postings AS ( 
-- Get jobs and companies from January
SELECT
    job_id,
    job_title_short,
    company_id,
    job_location,
    salary_year_avg 
FROM
    january_jobs

UNION ALL

--Get jobs and companies from feb
SELECT
    job_id,
    job_title_short,
    company_id,
    job_location,
    salary_year_avg 
FROM
    feb_jobs

UNION ALL

--Get jobs and companies from march
SELECT
    job_id,
    job_title_short,
    company_id,
    job_location,
    salary_year_avg 
FROM
    march_jobs
)

SELECT 
    q1_job_postings.job_id,
    skills_dim.skills,
    skills_dim.type 
FROM
    q1_job_postings
LEFT JOIN skills_job_dim ON skills_job_dim.job_id = q1_job_postings.job_id
LEFT JOIN skills_dim ON skills_dim.skill_id = skills_job_dim.skill_id
WHERE 
    q1_job_postings.salary_year_avg > 70000;