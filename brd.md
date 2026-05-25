# Business Requirement Document (BRD)

## Project Title
Enterprise Workflow Intelligence & SLA Analytics Platform

## 1. Executive Summary
Organizations currently manage internal operational requests (IT, HR, Finance, Operations) through fragmented channels like emails, chats, and spreadsheets. This manual approach results in delayed issue resolution, missed SLA deadlines, poor accountability, and a lack of centralized visibility. 
The proposed Enterprise Workflow Intelligence & SLA Analytics Platform will centralize ticket management, automate escalation workflows, and provide powerful analytics dashboards to track SLA compliance and identify operational bottlenecks.

## 2. Business Objectives
- **Centralize Operations:** Provide a single source of truth for all internal requests across departments.
- **SLA Compliance:** Track strict SLA deadlines based on dynamic priority scoring.
- **Automated Escalation:** Ensure high-risk tickets are flagged and escalated automatically to management.
- **Operational Intelligence:** Deliver interactive dashboards (Power BI) to monitor bottlenecks, trends, and team performance.
- **Reduce Delays:** Decrease average resolution time by standardizing the workflow lifecycle.

## 3. Current State vs. Future State (As-Is vs. To-Be)
| Feature | Current State (As-Is) | Future State (To-Be) |
|---|---|---|
| **Request Handling** | Manual via emails and Slack. | Centralized ticket management system. |
| **SLA Tracking** | Best-effort, no formal tracking. | Automated timers, SLA breach alerts. |
| **Escalations** | Ad-hoc, often reliant on the requester following up. | Rule-based automatic escalations via n8n. |
| **Reporting** | Manual spreadsheet aggregation. | Real-time Power BI dashboards. |
| **Prioritization** | First-in, first-out or subjective urgency. | Dynamic weighted priority scoring. |

## 4. Project Scope
### 4.1 In-Scope
- Development of a centralized relational database (Supabase).
- Ticket management lifecycle (New → Assigned → In Progress → Escalated → Resolved → Closed).
- SLA engine with rules based on priority (Critical: 4h, High: 8h, Medium: 24h, Low: 48h).
- Automated notification workflows using n8n and Webhooks (Slack/Email).
- Operational Intelligence Dashboards built on Power BI.
- Dynamic priority scoring system.

### 4.2 Out-of-Scope
- Customer-facing support portal (this is strictly for internal operational requests).
- Native mobile application development.
- Integration with external third-party helpdesk software (e.g., Zendesk, Jira), as this platform acts as the core system.

## 5. Stakeholders
| Role | Responsibilities |
|---|---|
| **Operations Manager** | Oversees the workflow, identifies bottlenecks using dashboards. |
| **Support Manager** | Manages the team, handles escalated tickets. |
| **Support Agent** | Resolves tickets, updates statuses. |
| **Employees (End Users)** | Submits tickets, monitors resolution progress. |
| **Business Analyst** | Defines requirements, ensures system meets operational goals. |

## 6. High-Level Business Requirements
- **BR-01:** The system shall allow employees to submit operational requests categorized by department.
- **BR-02:** The system shall dynamically calculate a priority score based on urgency, impact, and waiting time.
- **BR-03:** The system shall enforce Service Level Agreements (SLAs) based on the assigned priority.
- **BR-04:** The system shall automatically escalate tickets that breach or are near-breach of SLA deadlines.
- **BR-05:** The system shall provide analytical capabilities to measure team performance and workflow bottlenecks.
