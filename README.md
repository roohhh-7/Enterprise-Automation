# Enterprise Workflow Intelligence & SLA Analytics Platform

> **A full-stack operational intelligence platform demonstrating end-to-end business analysis, database engineering, and workflow automation.**

![Hero Image or Architecture Diagram](/path/to/hero_image_placeholder.png)
*(Replace the link above with a screenshot of your Power BI Dashboard or an Architecture Diagram)*

## 📖 Project Overview
Manual IT helpdesk triage often leads to missed Service Level Agreements (SLAs), inefficient routing, and zero visibility into departmental bottlenecks. 

This project solves that by engineering a **real-time, event-driven enterprise helpdesk backend**. It utilizes custom database triggers to instantly calculate dynamic SLA deadlines, integrates with the Slack API for automated critical alerting, and visualizes operational KPIs in Power BI.

---

## 🛠️ Technology Stack
* **Database:** PostgreSQL (Supabase), PL/pgSQL, Row Level Security (RLS)
* **Integration & Automation:** n8n, REST APIs, Webhooks, Slack API
* **Data Analytics:** Power BI, DAX, SQL Views
* **Business Analysis:** BRD/FRD Documentation, User Stories, Process Mapping

---

## 🚀 Key Features & Implementation

### 1. Business Analysis & Requirements Engineering
Mapped out "as-is" and "to-be" workflows to align technical deliverables with business objectives.
* Authored comprehensive Business Requirements Documents (BRD) and Functional Requirements Documents (FRD).
* Translated stakeholder needs into actionable Agile User Stories with strict Acceptance Criteria.
* Designed dynamic Priority Matrix logic (Urgency x Business Impact = Priority Score).

### 2. Scalable Database Architecture
Engineered a relational database schema designed for high-volume enterprise data.
* Deployed a PostgreSQL backend via Supabase.
* Wrote `PL/pgSQL` database triggers to automatically calculate exact SLA deadlines the moment a ticket is inserted.
* Generated and ingested 2,000+ rows of mock enterprise data for realistic stress-testing.

### 3. Event-Driven Workflow Automation
Replaced manual triage with zero-latency automated pipelines.
* Built **Schedule-Triggered Workflows** to query the database every 15 minutes, identify SLA breaches, and escalate them to management.
* Built **Webhook-Triggered Workflows** that listen for incoming HTTP POST requests the exact second a 'Critical' ticket is filed.
* Seamlessly formatted and pushed dynamic JSON payloads to the Slack API.

*[Insert screenshot of your n8n Workflow Canvas here]*

*[Insert screenshot of the Slack Alert arriving in your channel here]*

### 4. Operational Intelligence (Power BI)
*(Coming Soon - Phase 4)*
Developed interactive dashboards to give executives a bird's-eye view of operational health.
* Tracked SLA Adherence Rates and Average Resolution Times using custom SQL Views.
* Utilized DAX formulas to create dynamic KPI cards for Departmental Ticket Volumes.

*[Insert screenshot of your Power BI Dashboard here]*

---

## 📂 Project Files & Deliverables
Feel free to explore the raw files used to build this platform:
* [Business Requirements Document (BRD)](./brd.md)
* [Functional Requirements Document (FRD)](./frd.md)
* [Agile User Stories](./user_stories.md)
* [Process Flows](./process_flows.md)
* [Database Schema & Triggers](./supabase_schema.sql)
* [Mock Seed Data (2,000 rows)](./seed_mock_data.sql)
* [n8n Automation Workflows](./n8n_workflows.md)
* [Power BI Analytics Views & DAX](./powerbi_analytics.md)

---
*Created by [Your Name] to demonstrate comprehensive Business Analysis, Systems Integration, and Data Engineering capabilities.*
