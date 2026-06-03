/* 
Question: What are the most optimal skills to learn (it's in high demand and a high-paying skill)?
- Identify skills in high demand and associated with high average salaries 
- Why? Targets skills that offer job secutity (high demand) and financial benefits (high salaries),
    offereing strategic insights for career development in data anlysis
*/ 


WITH skills_demand AS (
    SELECT 
        skills_dim.skill_id,
        skills_dim.skills,
        COUNT(skills_job_dim.job_id) AS demand_count
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short IN ('Data Analyst','Business Analyst') AND
        job_country IN ('Italy', 'Switzerland', 'Netherlands','Vietnam') AND
        salary_year_avg IS NOT NULL
    GROUP BY skills_dim.skill_id
), average_salary AS (
    SELECT 
       skills_job_dim.skill_id,
        ROUND (AVG(salary_year_avg), 0) AS avg_salary
    FROM job_postings_fact
    INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
    INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
    WHERE
        job_title_short IN ('Data Analyst','Business Analyst') AND
        job_country IN ('Italy', 'Switzerland', 'Netherlands','Vietnam') AND
        salary_year_avg IS NOT NULL
    GROUP BY 
        skills_job_dim.skill_id
)

SELECT
    skills_demand.skill_id,
    skills_demand.skills,
    demand_count,
    avg_salary
FROM
    skills_demand
INNER JOIN average_salary ON skills_demand.skill_id = average_salary.skill_id
WHERE 
    demand_count > 5
ORDER BY
    demand_count DESC,
    avg_salary DESC
LIMIT 25

/*
[
  {
    "skill_id": 0,
    "skills": "sql",
    "demand_count": "31",
    "avg_salary": "86759"
  },
  {
    "skill_id": 1,
    "skills": "python",
    "demand_count": "24",
    "avg_salary": "82888"
  },
  {
    "skill_id": 183,
    "skills": "power bi",
    "demand_count": "13",
    "avg_salary": "84591"
  },
  {
    "skill_id": 182,
    "skills": "tableau",
    "demand_count": "13",
    "avg_salary": "80103"
  },
  {
    "skill_id": 181,
    "skills": "excel",
    "demand_count": "13",
    "avg_salary": "72270"
  },
  {
    "skill_id": 5,
    "skills": "r",
    "demand_count": "12",
    "avg_salary": "91441"
  },
  {
    "skill_id": 189,
    "skills": "sap",
    "demand_count": "8",
    "avg_salary": "95914"
  },
  {
    "skill_id": 4,
    "skills": "java",
    "demand_count": "8",
    "avg_salary": "74633"
  },
  {
    "skill_id": 185,
    "skills": "looker",
    "demand_count": "6",
    "avg_salary": "95330"
  }
]
*/