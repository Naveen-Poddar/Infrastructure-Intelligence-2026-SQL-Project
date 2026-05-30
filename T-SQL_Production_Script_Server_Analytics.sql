-- 1. Creating Database
CREATE DATABASE IT_Operations_Analytics;

-- Using my Database
USE IT_Operations_Analytics;
GO

-- Creating user table

CREATE TABLE System_Users(
        UserID INT PRIMARY KEY IDENTITY(1,1),
        UserName VARCHAR(100) NOT NULL,
        Department VARCHAR(50),
        Location VARCHAR(50) DEFAULT 'Bhilai'
        );
-- 2. Server Logs table 
CREATE TABLE Server_Logs (
        LogID INT PRIMARY KEY IDENTITY(101,1),
        UserID INT,
        ServerName VARCHAR(50) NOT NULL,
        ErrorMessage VARCHAR(255),
        DowntimeMinutes INT,
        LogTimestamp DATETIME,
        FOREIGN KEY(UserID) REFERENCES System_Users(UserID)
       );
-- 3. Resolution Status Table(Joined to direct server log)
CREATE TABLE Resolution_Status (
        StatusID INT PRIMARY KEY IDENTITY(1,1),
        LogID INT,
        IsFixed BIT DEFAULT 1, -- 1 = Fixed, 0 = pending(Edge Case)
        ResolutionTimeMinutes INT,
        FOREIGN KEY (LogID) REFERENCES Server_Logs(LogID)
        );

-- 1. Users Data
INSERT INTO System_Users (UserName, Department, Location) VALUES
('Amit Sharma', 'Operations', 'Bhilai'),
('Priya Patel', 'Data Science', 'Raipur'),
('Manish Sahu', 'IT Infrastructure', 'Bhilai'),
('Rohan Das', 'Operations', 'Bilaspur'),
('Sowmya Sri', 'Data Analytics', 'Bhilai');

-- 2. Server Logs Data (Jisme 180 mins wala outlier bhi shamil hai!)
INSERT INTO Server_Logs (UserID, ServerName, ErrorMessage, DowntimeMinutes, LogTimestamp) VALUES
(1, 'PROD-SRV-01', 'Network Crimping Failure - Timeout', 45, '2026-05-20 09:15:00'),
(2, 'DATA-SRV-02', 'Out of Memory - Pandas DataFrame Overflow', 120, '2026-05-20 10:30:00'),
(3, 'PROD-SRV-01', 'OS Crash - Windows Server 2019 Update Error', 90, '2026-05-20 11:00:00'),
(1, 'PROD-SRV-01', 'Network Crimping Failure - Timeout', 15, '2026-05-20 13:00:00'),
(4, 'BACKUP-SRV-01', 'System Cloning Sync Mismatch', 60, '2026-05-21 08:00:00'),
(5, 'DATA-SRV-02', 'SQL Server Deadlock Detected', 30, '2026-05-21 14:20:00'),
(2, 'DATA-SRV-02', 'Out of Memory - High Volume Join Query', 180, '2026-05-22 04:00:00'),
(3, 'PROD-SRV-01', 'Network Crimping Failure - Timeout', 20, '2026-05-22 17:45:00');

-- 3. Resolution Metrics
INSERT INTO Resolution_Status (LogID, IsFixed, ResolutionTimeMinutes) VALUES
(101, 1, 40),
(102, 1, 115),
(103, 1, 90),
(104, 1, 10),
(105, 0, 0), -- Pending Case
(106, 1, 25),
(107, 1, 175),
(108, 1, 15);

SELECT * FROM Server_Logs;
SELECT * FROM System_Users;
SELECT * FROM Resolution_Status;

/*******************************************************************************
PHASE 1: PROJECT OVERVIEW & SETUP
TOPIC 1.1: BUSINESS PROBLEM STATEMENT & ANALYTICAL OBJECTIVES

THE SITUATION:
An organization is facing heavy operational and financial losses due to 
unpredictable database crashes and server lag. The available raw server logs 
are unstructured, chaotic, and treated reactively.

THE CHALLENGE:
1. Managers cannot identify which server is the biggest operational threat.
2. Large downtime spikes (e.g., a 180-minute outlier) are often ignored 
   or deleted as "noise/glitches" instead of being treated as patterns.
3. Support teams work reactively, fixing systems *after* they break, 
   leading to constant SLA breaches.

ANALYTICAL OBJECTIVE:
Transform raw log data into structured business insights using SQL Server. 
We will quantify financial damage ($100/min rule), reverse-engineer the 
root cause of outliers using Window Functions, and build a proactive 
forecasting model to predict consecutive crashes.
*******************************************************************************/


/*******************************************************************************
PHASE 1: PROJECT OVERVIEW & SETUP
TOPIC 1.2: DATASET SCHEMA & ARCHITECTURE

CHALLENGE: 
Unstructured server logs need to be parsed and loaded into a structured 
Relational Database Management System (RDBMS) for analytical processing.

SOLUTION LOGIC:
Define a clean schema named 'Server_Logs' with appropriate data types 
(INT, VARCHAR, DATETIME) to ensure data integrity and optimal indexing.
*******************************************************************************/

-- Note: This is the table schema on which all the queries have been run.
SELECT * FROM Server_Logs;


/*******************************************************************************
PHASE 2: DESCRIPTIVE ANALYTICS
TOPIC 2.1: THE DOWNTIME KING (Infrastructure Analysis)

CHALLENGE: 
Identify which specific servers are causing the maximum system downtime 
and separate high-frequency small glitches from low-frequency catastrophic crashes.

SOLUTION LOGIC:
Apply 'SUM' and 'COUNT' aggregates grouped by 'ServerName'.
Calculate 'AvgDowntimePerCrash' to measure the severity per incident.
*******************************************************************************/

SELECT 
    ServerName,
    COUNT(LogID) AS TotalIncidents,
    SUM(DowntimeMinutes) AS TotalDowntimeMinutes,
    (SUM(DowntimeMinutes) / COUNT(LogID)) AS AvgDowntimePerCrash
FROM 
    Server_Logs
GROUP BY 
    ServerName
ORDER BY 
    TotalDowntimeMinutes DESC;


/*******************************************************************************
PHASE 2: DESCRIPTIVE ANALYTICS
TOPIC 2.2: INCIDENT FREQUENCY VS. SEVERITY RISK MATRIX

CHALLENGE: 
Management needs to know: Is our primary threat a server that glitches frequently, 
or a server that crashes rarely but deeply? We need a clear mathematical view 
to separate Incident Frequency from Crash Severity.

SOLUTION LOGIC:
Use a 'CASE WHEN' sub-tier within the aggregation framework to classify servers 
into risk groups based on their 'AvgDowntimePerCrash' score.
*******************************************************************************/

SELECT 
    ServerName,
    COUNT(LogID) AS IncidentFrequency,
    SUM(DowntimeMinutes) AS TotalDowntimeMinutes,
    (SUM(DowntimeMinutes) / COUNT(LogID)) AS SeverityMinutesPerIncident,
    -- Dynamic Risk Profiling Matrix
    CASE 
        WHEN (SUM(DowntimeMinutes) / COUNT(LogID)) > 100 THEN 'HIGH SEVERITY CRITICAL THREAT'
        WHEN COUNT(LogID) >= 4 THEN 'HIGH FREQUENCY OPERATIONAL ANNOYANCE'
        ELSE 'STANDARD MAINTENANCE RISK'
    END AS ServerRiskProfile
FROM 
    Server_Logs
GROUP BY 
    ServerName;

/*******************************************************************************
PHASE 3: ADVANCED SEQUENCING & ROOT CAUSE ANALYSIS
TOPIC 3.1: IDENTIFYING THE CHAIN REACTION (The Outlier Mystery)

CHALLENGE: 
Investigate the 180-minute critical crash outlier on 'DATA-SRV-02'. 
Determine if it was an isolated incident or a cascading failure from a previous event.

SOLUTION LOGIC:
Implement the 'LAG()' Window Function ordered by 'LogID' to fetch the 
immediate preceding error message. This exposes chronological dependencies.
*******************************************************************************/

SELECT 
    LogID,
    ServerName,
    ErrorMessage AS CurrentError,
    DowntimeMinutes,
    -- Lag function to see what happened just before
    LAG(ErrorMessage, 1) OVER (ORDER BY LogID) AS PreviousConsecutiveError
FROM 
    Server_Logs;

/*******************************************************************************
PHASE 3: ADVANCED SEQUENCING & ROOT CAUSE ANALYSIS
TOPIC 3.2: MAPPING ERROR SEQUENCES (The Warning-to-Crash Dependency)

CHALLENGE: 
Prove to the database architecture team that a critical system collapse is 
NOT random, but a direct progression from an unresolved warning event.

SOLUTION LOGIC:
Combine a CTE (Common Table Expression) with the 'LAG()' window function. 
Create an explicit sequence string pairing 'Previous Event' ➡️ 'Current Event' 
to map the exact progression line.
*******************************************************************************/

WITH LogSequenceCTE AS (
    SELECT 
        LogID,
        ServerName,
        ErrorMessage AS CurrentEvent,
        LAG(ErrorMessage, 1) OVER (ORDER BY LogID) AS PreviousEvent,
        DowntimeMinutes
    FROM 
        Server_Logs
)
SELECT 
    LogID,
    ServerName,
    CONCAT(ISNULL(PreviousEvent, 'START'), '  -->  ', CurrentEvent) AS FailureChainReaction,
    DowntimeMinutes AS ImpactMinutes
FROM LogSequenceCTE
WHERE DowntimeMinutes > 0;


/*******************************************************************************
PHASE 4: SLA MANAGEMENT & PROACTIVE PLANNING
TOPIC 4.1: THE SLA BREAKER (Incident Classification)

CHALLENGE: 
Filter and categorize server incidents that breached the 60-minute corporate 
SLA limit, ensuring critical issues get management's immediate attention.

SOLUTION LOGIC:
Apply a 'WHERE' filter for DowntimeMinutes > 60.
Use a conditional 'CASE WHEN' expression to dynamically split breaches 
into 'CRITICAL' (>120 mins) or 'STANDARD' levels.
*******************************************************************************/

SELECT 
    LogID,
    ServerName,
    ErrorMessage,
    DowntimeMinutes,
    CASE 
        WHEN DowntimeMinutes > 120 THEN 'CRITICAL BREACH (Immediate Action Required)'
        WHEN DowntimeMinutes BETWEEN 61 AND 120 THEN 'STANDARD SLA BREACH (Review Needed)'
        ELSE 'Within SLA Limit'
    END AS SLABreachStatus
FROM 
    Server_Logs
WHERE 
    DowntimeMinutes > 60
ORDER BY 
    DowntimeMinutes DESC;

/*******************************************************************************
PHASE 4: SLA MANAGEMENT & PROACTIVE PLANNING
TOPIC 4.2: FUTURE BOTTLENECK FORECASTING (Predictive Sequence Mapping)

CHALLENGE: 
Predict which server or service queue might collapse next based on the 
current crash sequence, enabling proactive infrastructure defense.

SOLUTION LOGIC:
Deploy double 'LEAD()' Window Functions to look ahead by 1 row, capturing both 
the 'Next Impacted Server' and 'Next Expected Error Message' simultaneously.
*******************************************************************************/

SELECT 
    LogID,
    ServerName AS CurrentImpactedServer,
    ErrorMessage AS CurrentErrorMessage,
    DowntimeMinutes AS CurrentDowntime,
    LEAD(ServerName, 1) OVER (ORDER BY LogID) AS NextForecastedImpactServer,
    LEAD(ErrorMessage, 1) OVER (ORDER BY LogID) AS NextExpectedErrorMessage
FROM 
    Server_Logs
ORDER BY 
    LogID;

/*******************************************************************************
PHASE 5: BUSINESS IMPACT & PORTFOLIO PRESENTATION
TOPIC 5.1: TRANSLATING CODE TO DOLLARS (Financial Impact Analysis)

CHALLENGE: 
Technical downtime metrics (minutes) don't make sense to business executives. 
We need to translate total downtime into financial loss ($100/minute rule) 
and highlight the exact monetary damage caused by each server's breaches.

SOLUTION LOGIC:
Use aggregate functions 'SUM' and 'COUNT' grouped by ServerName.
Create a calculated column: TotalDowntimeMinutes * 100 AS EstimatedFinancialLoss.
Order the results to show the most financially draining server on top.
*******************************************************************************/

SELECT 
    ServerName,
    COUNT(LogID) AS TotalIncidents,
    SUM(DowntimeMinutes) AS TotalDowntimeMinutes,
    -- Financial Impact Logic: $100 per minute loss
    SUM(DowntimeMinutes) * 100 AS EstimatedFinancialLossUSD,
    -- Formatting into a business insight string
    '$' + CONVERT(VARCHAR, SUM(DowntimeMinutes) * 100) AS FormattedLoss
FROM 
    Server_Logs
GROUP BY 
    ServerName
ORDER BY 
    TotalDowntimeMinutes DESC;

/*******************************************************************************
PHASE 5: BUSINESS IMPACT & PORTFOLIO PRESENTATION
TOPIC 5.2: FINAL DELIVERABLES ARCHITECTURE (The Capstone Wrap-Up)

DOCUMENTATION NOTE FOR CODE AUDITORS & INTERVIEWERS:
This complete production script serves as the Technical Core Asset of the 
Server Infrastructure Optimization Portfolio Project developed by Naveen Poddar.

THE DELIVERABLE ECOSYSTEM:
1. T-SQL Engine File (This Document): Contains the production code, logic architecture, 
   and raw queries used to mine unstructured log repositories.
2. Executive Strategy Deck (PPTX/HTML Asset): Designed in a McKinsey/Consulting style 
   minimalist layout to present business KPIs, dynamic charts, and financial 
   ROI insights directly to C-Suite Executives and Business Heads.

PROJECT SIGNIFICANCE:
Successfully shifted infrastructure team metrics from a Reactive Framework 
(Average Time to Repair) to a Proactive Predictive Operations Framework 
(Sequence Hazard Mapping), uncovering a hidden $33,000 operational risk node.
*******************************************************************************/













































