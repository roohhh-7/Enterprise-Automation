# Functional Requirement Document (FRD)

## Project Title
Enterprise Workflow Intelligence & SLA Analytics Platform

## 1. System Overview
The system architecture consists of a PostgreSQL database hosted on Supabase, connected to self-hosted n8n for automation workflows, and Power BI for data visualization. 

## 2. Core Functional Modules

### 2.1 Ticket Management System
- **FR-1.1:** The system shall allow creation of tickets with fields: Ticket ID, Department, Request Type, Urgency, Business Impact, Assigned Team, Status, Created Date, and Comments.
- **FR-1.2:** The system shall enforce the workflow lifecycle: `NEW` → `ASSIGNED` → `IN PROGRESS` → `ESCALATED` → `RESOLVED` → `CLOSED`.
- **FR-1.3:** The system shall log every status change and assignment change in a `workflow_logs` history table.

### 2.2 Dynamic Priority & SLA Engine
- **FR-2.1:** The system shall compute a priority score automatically on ticket creation/update using the formula:
  `Priority Score = (Urgency × 0.4) + (Business Impact × 0.3) + (Waiting Time × 0.2) + (Department Criticality × 0.1)`
- **FR-2.2:** The system shall categorize tickets and set SLA deadlines based on priority:
  - Critical → 4h
  - High → 8h
  - Medium → 24h
  - Low → 48h
- **FR-2.3:** The system shall record the exact `Resolution Time` once a ticket moves to `RESOLVED` status.

### 2.3 Automation Engine (n8n)
- **FR-3.1:** The system shall trigger an escalation alert (via Slack/Email webhook) if a ticket remains unresolved for > 24 hours.
- **FR-3.2:** The system shall immediately notify the Department Manager upon creation of a "Critical" ticket.
- **FR-3.3:** The system shall trigger an "SLA Warning" notification when 80% of the SLA time has elapsed without resolution.
- **FR-3.4:** The system shall automatically escalate a ticket if it is reopened more than 2 times.

### 2.4 Operational Intelligence Dashboard
- **FR-4.1:** The system shall expose analytical SQL views to be consumed by Power BI.
- **FR-4.2:** The dashboard shall display the overall SLA Compliance Percentage.
- **FR-4.3:** The dashboard shall highlight workflow bottlenecks (e.g., longest average time spent in the `IN PROGRESS` stage).

## 3. Database Schema Requirements
- Tables required: `tickets`, `departments`, `users`, `workflow_logs`, `escalations`, `sla_rules`.
- Referential integrity must be maintained using Foreign Keys.
- Timestamps (`created_at`, `updated_at`) must be maintained on all records.

## 4. Non-Functional Requirements
- **Performance:** Dashboards must load in under 5 seconds.
- **Scalability:** The database and workflows must handle enterprise-level ticket volume (e.g., thousands of tickets per month).
- **Maintainability:** n8n workflows must be modular and documented to allow easy adjustments to SLA rules.
