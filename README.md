# Infrastructure Intelligence: Server Uptime & Financial Downtime Analysis

This repository contains a data-driven SQL portfolio project focused on analyzing technical server breakdowns and converting infrastructure logs into exact monetary business impact. The project shifts infrastructure tracking from a reactive fixing mindset to a proactive analytics framework.

---

## Technical Project Framework
*   **Database Engine:** Microsoft SQL Server (SSMS)
*   **Core SQL Concepts Used:** Common Table Expressions (CTEs), Window Functions (LAG/LEAD), Advanced Joins, and Aggregations.
*   **Data Models:** Structured relational schemas mapping Users, System Logs, and Incident Resolution timelines.

---

## Repository Directory
*   `infrastructure_downtime_analysis.sql` - Complete T-SQL script containing schema definitions, data insertion, and analytical business queries.

---

## Key Operational & Financial Insights Delivered
1.  **Quantifying Business Risk:** Successfully mapped raw technical server error sequences to financial metrics, uncovering a hidden \$33,000 operational risk caused by cumulative micro-downtimes.
2.  **Error Sequence Mapping:** Formulated complex CTEs and Window Functions (`LAG`/`LEAD`) to pinpoint recurring failure patterns, identifying specific server nodes that frequently trigger sequential system drops.
3.  **SLA Breakdown & Resolution:** Analyzed the time gap between log generation and final resolution to isolate systemic bottlenecks in the hardware patch deployment pipeline.
4.  **Proactive Resource Allocation:** Developed structural metrics that help database administrators allocate maintenance schedules effectively before critical system failures occur.

---
**Maintained by Naveen Poddar**  
*MBA Candidate (Operations & Data Science) | IT Operations & Data Specialist*
