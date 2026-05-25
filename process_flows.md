# Process Flow Diagrams

## Project Title
Enterprise Workflow Intelligence & SLA Analytics Platform

---

## 1. As-Is Process Flow (Current State)
This diagram illustrates the current manual, inefficient process.

```mermaid
flowchart TD
    A[Employee] -->|Sends Email/Chat| B(Support Inbox / Slack)
    B --> C{Agent Checks Inbox?}
    C -->|No| D[Request Delayed]
    C -->|Yes| E[Agent Reads Request]
    E --> F[Manual Reply to Acknowledge]
    F --> G{Requires Escalation?}
    G -->|Yes| H[Agent emails Manager]
    H --> I[Manager manually intervenes]
    G -->|No| J[Agent Works on Issue]
    J --> K[Issue Resolved]
    K --> L[Agent emails Employee]
    D -.->|Employee Follows up| B
```

---

## 2. To-Be Process Flow (Future State)
This diagram illustrates the automated, centralized workflow.

```mermaid
flowchart TD
    A[Employee] -->|Submits Form| B(Supabase Tickets Table)
    B --> C[Database Trigger: Calculate Priority Score]
    C --> D[Assign SLA Deadline]
    D --> E{Is Priority Critical?}
    E -->|Yes| F[n8n Webhook: Alert Manager]
    E -->|No| G[Dashboard Updated]
    F --> G
    G --> H[Agent Assigns Ticket]
    H --> I[Agent Works Issue]
    I --> J{SLA > 80% used?}
    J -->|Yes| K[n8n: SLA Warning to Agent/Manager]
    J -->|No| L[Issue Resolved]
    K --> L
    L --> M[System logs Resolution Time]
    M --> N[Power BI Refreshes Data]
```

---

## 3. Ticket Lifecycle (State Machine)
This diagram illustrates the standardized states a ticket can move through.

```mermaid
stateDiagram-v2
    [*] --> NEW: Ticket Submitted
    NEW --> ASSIGNED: Agent claims ticket
    ASSIGNED --> IN_PROGRESS: Agent begins work
    IN_PROGRESS --> ESCALATED: Rule triggers / Manual escalation
    ESCALATED --> IN_PROGRESS: Manager assigns to senior agent
    IN_PROGRESS --> RESOLVED: Issue fixed
    RESOLVED --> IN_PROGRESS: Employee reopens ticket
    RESOLVED --> CLOSED: 3 days pass / Employee confirms
    CLOSED --> [*]
```

---

## 4. Automated Escalation Logic Flow
This diagram breaks down the n8n logic for monitoring SLAs.

```mermaid
flowchart LR
    A((Cron Job: Every 15m)) --> B[Query Supabase: Fetch unresolved tickets]
    B --> C{Check Elapsed Time vs SLA}
    C -->| > 100% | D[Status = SLA BREACHED]
    D --> E[n8n: Escalate to Manager via Slack]
    C -->| > 80% | F[n8n: Send Warning Notification]
    C -->| < 80% | G[Do Nothing]
```
