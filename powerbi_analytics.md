# Operational Intelligence & Analytics (Power BI)

## Project Title
Enterprise Workflow Intelligence & SLA Analytics Platform

This document outlines everything you need to build the final executive dashboards in Power BI.

---

## 1. Database Views for Power BI
Instead of pulling raw tables and joining them in Power BI, it is best practice to create SQL Views in Supabase to clean and aggregate the data.

**Instructions:** Run these SQL queries in your Supabase SQL Editor. Then, connect Power BI directly to these views using the PostgreSQL connector.

### A. The Master Ticket View (Fact Table)
This view joins tickets with departments and users, and calculates the exact resolution time in hours.
```sql
CREATE OR REPLACE VIEW v_powerbi_tickets AS
SELECT 
    t.id AS ticket_id,
    t.request_type,
    t.status,
    t.urgency,
    t.business_impact,
    t.priority_score,
    t.priority_tier,
    t.created_at,
    t.resolved_at,
    t.sla_deadline,
    t.is_sla_breached,
    EXTRACT(EPOCH FROM (COALESCE(t.resolved_at, NOW()) - t.created_at))/3600 AS hours_open,
    d.name AS department_name,
    u_req.full_name AS requester_name,
    COALESCE(u_agt.full_name, 'Unassigned') AS agent_name
FROM tickets t
JOIN departments d ON t.department_id = d.id
JOIN users u_req ON t.requester_id = u_req.id
LEFT JOIN users u_agt ON t.assigned_agent_id = u_agt.id;
```

### B. The Workflow Bottleneck View
This view helps identify which ticket statuses take the longest on average.
```sql
CREATE OR REPLACE VIEW v_powerbi_bottlenecks AS
SELECT 
    department_name,
    status,
    COUNT(*) as ticket_count,
    AVG(hours_open) as avg_hours_in_status
FROM v_powerbi_tickets
WHERE status NOT IN ('RESOLVED', 'CLOSED')
GROUP BY department_name, status;
```

---

## 2. Power BI Data Modeling (Star Schema)
When you import the data into Power BI, ensure your relationships look like this:

1. **`v_powerbi_tickets`** acts as your central **Fact Table**.
2. Create a new **Date Table** in Power BI (using DAX: `Dates = CALENDARAUTO()`) to serve as your Dimension Table.
3. Link the `Dates[Date]` column to the `v_powerbi_tickets[created_at]` column (One-to-Many).

---

## 3. Executive DAX Measures
Create a new "Measures Table" in Power BI and paste these exact DAX formulas to create your dashboard KPIs.

**1. SLA Compliance Percentage**
The most important KPI. What percentage of tickets are resolved within their SLA?
```dax
SLA Compliance % = 
DIVIDE(
    CALCULATE(COUNTROWS('v_powerbi_tickets'), 'v_powerbi_tickets'[is_sla_breached] = FALSE),
    COUNTROWS('v_powerbi_tickets'),
    0
)
```

**2. Average Resolution Time (Hours)**
How long does it take to close tickets?
```dax
Avg Resolution Time = 
AVERAGE('v_powerbi_tickets'[hours_open])
```

**3. Total Escalations (Risk Metric)**
How many tickets hit the danger zone?
```dax
Total Escalations = 
CALCULATE(
    COUNTROWS('v_powerbi_tickets'), 
    'v_powerbi_tickets'[status] = "ESCALATED"
)
```

**4. Critical Ticket Backlog**
Pending critical items that need immediate attention.
```dax
Critical Ticket Backlog = 
CALCULATE(
    COUNTROWS('v_powerbi_tickets'), 
    'v_powerbi_tickets'[status] <> "RESOLVED",
    'v_powerbi_tickets'[status] <> "CLOSED",
    'v_powerbi_tickets'[priority_tier] = "Critical"
)
```

---

## 4. Recommended Dashboard Pages
With the data and DAX ready, build these 3 pages in Power BI:

1. **Executive Overview:** Big KPI cards for `SLA Compliance %` and `Avg Resolution Time`. A line chart tracking ticket volume over time.
2. **Bottleneck Analysis:** A bar chart using the `v_powerbi_bottlenecks` view to show which departments have tickets stuck in "In Progress" the longest.
3. **Agent Performance:** A matrix showing `agent_name` vs `Total Escalations` and `SLA Compliance %` to see which agents need help.
