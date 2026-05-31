# Infrastructure Intelligence: Server Uptime & Financial Downtime Analysis

## 📌 Project Overview
This project transforms raw, unstructured technical server logs into business-centric data intelligence. By building a relational database schema and writing advanced analytical queries, the framework shifts IT infrastructure management from reactive firefighting to a proactive predictive model. The highlight of the project is quantifying technical downtime into exact financial risks to drive strategic decision-making.

## 🛠️ Tech Stack & Tools Used
- **Database Engine:** Microsoft SQL Server (SSMS)
- **Query Language:** Advanced T-SQL
- **Reporting:** Executive Documentation & Presentation Deck

## 📐 Database Architecture & Analytics Strategy
1. **Schema Optimization:** Structured flat infrastructure logs into highly optimized relational tables (`Users`, `Logs`, `Resolution`) with enforced primary and foreign key constraints.
2. **Advanced Query Engineering:** Utilized complex **Common Table Expressions (CTEs)** to isolate sequential error patterns and break down nested system log data.
3. **Sequence Mapping:** Employed advanced **Window Functions (`LAG`/`LEAD`)** to analyze what happens right before a server breakdown, creating a baseline for predictive alerts.
4. **Monetary Translation:** Applied corporate Service Level Agreements (SLAs) to technical failure durations, uncovering a hidden **$33,000 operational risk** caused by infrastructure downtime.

## 📊 Business Metrics Quantified
- **Total Operational Downtime:** Cumulative hours lost per server node.
- **Financial Impact ($):** Exact revenue leakage calculated based on SLA penalty matrices.
- **Error Sequence Vectors:** Identification of high-frequency error codes triggering cascading server failures.

## 📁 Repository Structure
- `Database_Schema/`: Contains SQL production scripts for table creation and relational mapping.
- `Queries/`: Analytical T-SQL scripts featuring CTEs, Window Functions, and financial aggregations.
- `Docs/`: Executive reporting summaries and presentation data.
