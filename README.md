# Data & Business Analyst Job Market Analysis
### *Exploring top-paying roles and in-demand skills across Italy, Switzerland, the Netherlands & Vietnam*

---

# Introduction

This project looks at the data analyst and business analyst job market across four countries: **Italy, Switzerland, the Netherlands, and Vietnam**. I used SQL to pull insights from real job posting data to figure out which roles pay the most, which skills they require, and which skills offer the best mix of high demand and high salary.

All queries were written in VSCode and PostgreSQL, and run against a structured dataset of job postings, companies, and skills.

---

# Background

Moving forward in the data field means making deliberate choices about which skills to invest in. Most advice is generic and global, so I wanted answers tied to a specific regional context.

**The questions driving this analysis:**

1. What are the top-paying Data Analyst and Business Analyst jobs?
2. What skills do those top-paying jobs require?
3. What are the most in-demand skills across all job postings?
4. Which skills are linked to the highest average salaries?
5. Which skills are both high-demand and high-paying?

The dataset includes job postings from `job_postings_fact`, with company data from `company_dim` and skill metadata from `skills_dim` and `skills_job_dim`.

---

# Tools I Used

| Tool | Purpose |
|---|---|
| **PostgreSQL** | All querying and analysis |
| **SQL (CTEs, JOINs, aggregations)** | Data extraction and transformation |
| **VS Code** | Query writing and project management |
| **Git & GitHub** | Version control and project sharing |

---

# The Analysis

Each query focused on a specific question. Here is what I explored:

### 1. Top-Paying Jobs
Filtered for Data Analyst and Business Analyst roles in the four target countries, removed postings without salaries, and ranked by `salary_year_avg`. Limited to the top 100 to focus on genuinely competitive roles.

```sql
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
```

### 2. Skills Behind Top-Paying Jobs
Used a CTE to pull the same top-100 roles, then joined to the skills tables to see which skills appear in the highest-paying postings.

```sql
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
    salary_year_avg DESC;

```

**Key findings:**
- SQL (56% of jobs) and Python (44%) are the core baseline for top-paying roles
- Cloud skills (AWS, Azure) appear rarely but are linked to a significant salary premium
- Big Data tools (Hadoop, Airflow, PySpark) are niche but high-paying
- Visualisation tools (Tableau, Power BI, Looker) are common but not salary differentiators
- Excel is widely expected but not a path to higher pay

### 3. Most In-Demand Skills
Counted skill appearances across all postings (not just high-salary ones) to identify what employers ask for most often.

```sql
SELECT 
    skills,
    COUNT(skills_job_dim.job_id) AS demand_count
FROM job_postings_fact
INNER JOIN skills_job_dim ON job_postings_fact.job_id = skills_job_dim.job_id
INNER JOIN skills_dim ON skills_job_dim.skill_id = skills_dim.skill_id
WHERE
    job_title_short IN ('Data Analyst','Business Analyst') AND
    job_country IN ('Italy', 'Switzerland', 'Netherlands','Vietnam')
GROUP BY skills
ORDER BY 
    demand_count DESC
LIMIT 5;
```

| Skill | Demand Count |
|---|---|
| SQL | 5,383 |
| Excel | 4,068 |
| Python | 3,911 |
| Power BI | 2,280 |
| Tableau | 2,209 |

SQL leads by a wide margin, with Excel and Python close behind. The top 5 are split between core query/programming skills and visualisation tools.

### 4. Top Skills by Salary
Calculated the average salary tied to each skill to see which tools and technologies are financially rewarded most.

```sql 

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

```

**Key findings:**
- NoSQL ranks highest at ~$177k avg, well above the next tier
- Cloud and Big Data tools form the top salary tier: NoSQL, Azure, AWS, Hadoop, Airflow, PySpark ($111k to $177k)
- SQL averages ~$87k despite being the most demanded skill, since it is a hiring baseline across all seniority levels

### 5. Optimal Skills (High Demand + High Pay)
Combined both dimensions using CTEs: filtered to skills appearing in more than 5 postings, then sorted by demand and average salary.

```sql
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

```

| Skill | Demand Count | Avg Salary |
|---|---|---|
| SQL | 31 | $86,759 |
| Python | 24 | $82,888 |
| Power BI | 13 | $84,591 |
| Tableau | 13 | $80,103 |
| Excel | 13 | $72,270 |
| R | 12 | $91,441 |
| SAP | 8 | $95,914 |
| Java | 8 | $74,633 |
| Looker | 6 | $95,330 |

SQL and Python dominate on demand. R, SAP, and Looker are interesting: lower demand but salary averages above $90k, meaning they attract fewer job postings but better-paid ones. Excel sits at the bottom on salary ($72,270) despite appearing in 13 postings, reinforcing the pattern from query 2.

---

# What I Learned

- **CTEs keep complex queries readable.** Queries 2 and 5 both used CTEs to build a clean filtered base before joining additional dimensions on top.
- **Aggregations surface non-obvious patterns.** Counting and averaging across thousands of postings revealed things like Microsoft Office skills appearing in high-salary roles, likely due to senior-level job postings listing them alongside more advanced tools.
- **Filtering context changes everything.** Running these queries globally would give different results. Scoping to four countries keeps the findings useful for someone actually job-hunting in that market.
- **SQL is the starting point, not the finish line.** It gets you in the door, but cloud tools, big data, or Python are what push salaries into the upper range.

---

# Conclusion

For Data and Business Analysts targeting Italy, Switzerland, the Netherlands, or Vietnam:

- **Start with SQL and Python.** They show up in most top-paying roles and are close to required at this point.
- **Add a cloud or big data skill.** AWS, Azure, Hadoop, or Airflow are less common in postings but tied to noticeably higher salaries when they appear.
- **Pick up at least one visualisation tool.** Tableau, Power BI, and Looker are expected by many employers, even if they do not drive a salary premium on their own.
- **Do not count on Excel alone.** It is useful to have, but it does not move the salary needle.

The clearest path: build a solid SQL and Python foundation, then specialise in one cloud or big data tool. That combination scores well on both demand and salary in this regional market.

---


