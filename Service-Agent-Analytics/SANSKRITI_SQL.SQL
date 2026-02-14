
USE SERVICE_AGENT;

select * from customer_satisfaction
select * from help_desk

--1 . Calculate the average resolution time for each agent. (7 Marks)   
--Hint: Aggregate the Resolution time by each agent. 

SELECT service_agent_id, AVG(DATEDIFF(MINUTE, case_sent_time, case_resolution_time) * 1.0)
                           AS avg_resolution_time_minutes
FROM help_desk
GROUP BY service_agent_id
order by service_agent_id asc

--2 . List agents with above-average resolution times.
WITH AgentResolution AS (
    SELECT  service_agent_id,AVG(DATEDIFF(MINUTE, case_sent_time, case_resolution_time) * 1.0) --1.0 for float--
	                                       AS avg_resolution_time
    FROM  help_desk
    GROUP BY service_agent_id),
OverallAvg AS (
    SELECT AVG(DATEDIFF(MINUTE, case_sent_time, case_resolution_time) * 1.0) AS overall_avg_time
    FROM  help_desk)
SELECT a.service_agent_id, a.avg_resolution_time
FROM AgentResolution a,OverallAvg o
WHERE a.avg_resolution_time > o.overall_avg_time
order by service_agent_id asc

--3. find the percentage of cases where agents received a customer rating of 4 or higher .

SELECT ROUND(
             (SELECT COUNT(*) FROM customer_satisfaction 
              WHERE satisfaction_score >= 4) * 100.0 / (SELECT COUNT(*)  FROM customer_satisfaction), 2
              ) AS percentage_high_ratings;

 -- 4.  Rank agents based on resolution speed. 
 --Hint: Aggregate the resolution time by agent.
 -- Use Rank Window Function to give Ranks. 

WITH agent_resolution AS (
    SELECT
        service_agent_id,
        AVG(DATEDIFF(MINUTE, case_sent_time, case_resolution_time)) AS avg_resolution_minutes
    FROM help_desk
    GROUP BY service_agent_id
)
SELECT 
    service_agent_id,
    avg_resolution_minutes,
    RANK() OVER (ORDER BY avg_resolution_minutes ASC) AS resolution_rank
FROM agent_resolution


