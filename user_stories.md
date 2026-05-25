# User Stories & Acceptance Criteria

## Project Title
Enterprise Workflow Intelligence & SLA Analytics Platform

---

### Epic 1: Ticket Management & Lifecycle

**User Story 1.1**
> As an Employee, I want to create a support ticket by specifying the department and urgency, so that my operational issue can be addressed.
- **Acceptance Criteria:**
  - Given the employee fills out the request form.
  - When submitted, the system creates a ticket with status `NEW`.
  - Then a unique Ticket ID is generated.

**User Story 1.2**
> As a Support Agent, I want to update the status of a ticket, so that the requester and management know the current progress.
- **Acceptance Criteria:**
  - Given a ticket in `ASSIGNED` state.
  - When the agent starts working, they can change the status to `IN PROGRESS`.
  - Then the system logs this status change with a timestamp in the workflow history.

---

### Epic 2: Dynamic Priority & SLA Management

**User Story 2.1**
> As a System Administrator, I want the system to calculate priority dynamically based on weighted factors, so that critical issues bubble up automatically without human bias.
- **Acceptance Criteria:**
  - Given a ticket with specified Urgency and Business Impact.
  - When created, the database trigger calculates the `Priority Score`.
  - Then the system assigns an SLA deadline based on the resulting priority tier (Critical, High, Medium, Low).

**User Story 2.2**
> As an Operations Manager, I want the system to automatically track SLA deadlines, so that I know which tickets are at risk of breaching.
- **Acceptance Criteria:**
  - Given a ticket with a 4h SLA deadline.
  - When the system time crosses the 4h mark and the status is not `RESOLVED`.
  - Then the ticket is flagged as `SLA_BREACHED`.

---

### Epic 3: Automated Workflow & Escalations (n8n)

**User Story 3.1**
> As a Support Manager, I want to receive immediate Slack/Email alerts for Critical tickets, so that I can mobilize the team instantly.
- **Acceptance Criteria:**
  - Given a ticket is created with a `Critical` priority tier.
  - When the database record is inserted.
  - Then an n8n webhook triggers an alert containing the Ticket ID and Description to the Manager's channel.

**User Story 3.2**
> As a Support Manager, I want SLA breach warnings before the breach happens, so that delayed tickets can be escalated proactively.
- **Acceptance Criteria:**
  - Given a ticket has reached 80% of its allotted SLA time.
  - When evaluated by the n8n scheduled workflow.
  - Then a warning notification is sent to the assigned agent and manager.

---

### Epic 4: Operational Intelligence Dashboards

**User Story 4.1**
> As an Operations Manager, I want dashboard visibility into ticket trends, so that I can identify workflow bottlenecks.
- **Acceptance Criteria:**
  - Given the Power BI dashboard is refreshed.
  - When viewing the Bottleneck Analysis page.
  - Then I can see the average time tickets spend in each workflow state (e.g., time spent in `IN PROGRESS`).

**User Story 4.2**
> As an Executive, I want to see the overall SLA compliance percentage by department, so that I can evaluate operational efficiency.
- **Acceptance Criteria:**
  - Given a date range filter in Power BI.
  - When viewing the Executive Overview.
  - Then a KPI card displays the % of tickets resolved within their SLA deadline.
