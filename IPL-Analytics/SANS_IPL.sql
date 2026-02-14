USE IPL

--1. Find the top 5 batsmen with the highest career strike rates (minimum 500 balls faced).   
--Hint:   
-- Strike Rate = (Total Runs / Total Balls Faced) * 100.

SELECT TOP 5 BATSMANNAME,SUM(RUNS) AS TOTAL_RUNS, SUM(BALLS) AS TOTAL_BALLS_FACED,
             ((SUM(RUNS)*100.0)/SUM(BALLS)) AS STRIKE_RATE
FROM fact_BATTING
GROUP BY BATSMANNAME
HAVING (SUM(BALLS))>=500
ORDER BY STRIKE_RATE DESC

--2. Calculate the average strike rate of all players at each batting position (1-11).                            
--Hint:   
--Use GROUP BY batting_position and Calculate average Strike Rate. 
--Strike Rate = (Total Runs / Total Balls Faced) * 100. 

SELECT BATTINGPOS, 
       AVG(strike_rate) AS avg_strike_rate
FROM (
    SELECT battingPOS, 
           (SUM(runs) * 1.0 / SUM(balls)) * 100 AS strike_rate
    FROM FACT_BATTING
    GROUP BY battingPOS
) AS X
GROUP BY battingPOS
ORDER BY BATTINGPOS 

--3. Determine the batsman with the highest strike rate in the last 3 years. (8 Marks)   
--Hint:   
-- Filter data for YEAR(match_date) >= YEAR(MAX_DATE) - 3. 
-- GROUP BY Batsmen and calculate average Strike Rate. 
-- Strike Rate = (Total Runs / Total Balls Faced) * 100. 


SELECT TOP 1
    BatsmanNAME,
    AVG(StrikeRate) AS AverageStrikeRate
FROM (
    -- Calculate strike rate for each match within the last 3 years
    SELECT
        BatsmanNAME,
        (TotalRuns / TotalBallsFaced) * 100 AS StrikeRate
    FROM (
        -- Filter data for the last 3 years
        SELECT  
            FB.BatsmanNAME,
            SUM(FB.Runs) AS TotalRuns,
            COUNT(FB.BallS) AS TotalBallsFaced
        FROM FACT_BATTING AS FB
        INNER JOIN DIM_MATCH AS DM 
		ON FB.Match_Id = DM.Match_Id
	WHERE DATEDIFF(YEAR, TRY_CAST(DM.matchDate AS DATE), GETDATE()) <= 3
	AND FB.BALLS>0
        GROUP BY FB.BATSMANNAME,MATCHDATE
    ) AS BatsmanStats
) AS StrikeRateData
GROUP BY
    BatsmanNAME
ORDER BY
    AverageStrikeRate DESC

--4. Find the number of batsmen who have scored at least 10 half-centuries (50+ runs) with 
--a strike rate above 130. (8 Marks)   
--Hint: Use HAVING COUNT(*) >= 10 with a WHERE clause on strike rate. 
-- Output should contain the count of batsmen.

SELECT COUNT(*) AS BatsmanCount
FROM (
    SELECT FB.BatsmanNAME
    FROM FACT_BATTING AS FB
    INNER JOIN DIM_MATCH AS DM ON FB.Match_Id = DM.Match_Id
    WHERE FB.Runs >= 50  -- Ensures at least a half-century
    AND (FB.Runs * 1.0 / FB.Balls) * 100 > 130  -- Strike rate above 130
    AND FB.BALLS > 0
    GROUP BY FB.BatsmanNAME
    HAVING COUNT(FB.Match_Id) >= 10  -- Ensure batsman has at least 10 such innings
) AS QualifiedBatsmen;

--5. Calculate the Month-over-Month (MoM) change in average strike rate for each batsman.   
--Hint:   
-- Use VALUE window functions to compare current and previous month’s data. 

	WITH StrikeRateData AS (
    -- Calculate avg strike rate per batsman & month
    SELECT 
        FB.BatsmanNAME, 
        FORMAT(TRY_CAST(DM.matchDate AS DATE), 'yyyy-MM') AS match_month,
        ROUND((SUM(FB.Runs) * 1.0 / SUM(FB.Balls)) * 100, 2) AS avg_strike_rate
    FROM FACT_BATTING AS FB
    INNER JOIN DIM_MATCH AS DM ON FB.Match_Id = DM.Match_Id
    WHERE FB.BALLS > 0
    GROUP BY FB.BatsmanNAME, FORMAT(TRY_CAST(DM.matchDate AS DATE), 'yyyy-MM')
)
SELECT 
    BatsmanNAME, match_month, avg_strike_rate,
    LAG(avg_strike_rate) OVER (PARTITION BY BatsmanNAME ORDER BY match_month) AS prev_month_strike_rate,
    ROUND((avg_strike_rate - LAG(avg_strike_rate) OVER (PARTITION BY BatsmanNAME ORDER BY match_month)), 2) AS MoM_change
FROM StrikeRateData
ORDER BY BatsmanNAME, match_month

