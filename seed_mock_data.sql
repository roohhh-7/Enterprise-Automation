-- Seed Mock Data for Power BI Dashboards

-- 1. Insert Departments
INSERT INTO departments (name, criticality_score) VALUES
('IT Support', 9),
('Human Resources', 6),
('Finance', 8),
('Operations', 7);

-- 2. Insert Users (Managers, Agents, Employees)
DO $$
DECLARE
    dept_it INT;
    dept_hr INT;
    dept_fin INT;
    dept_ops INT;
BEGIN
    SELECT id INTO dept_it FROM departments WHERE name = 'IT Support';
    SELECT id INTO dept_hr FROM departments WHERE name = 'Human Resources';
    SELECT id INTO dept_fin FROM departments WHERE name = 'Finance';
    SELECT id INTO dept_ops FROM departments WHERE name = 'Operations';

    -- Insert 50 Employees
    FOR i IN 1..50 LOOP
        INSERT INTO users (full_name, email, role, department_id)
        VALUES ('Employee ' || i, 'employee' || i || '@company.com', 'Employee', 
                (ARRAY[dept_it, dept_hr, dept_fin, dept_ops])[floor(random() * 4 + 1)]);
    END LOOP;

    -- Insert 15 Agents
    FOR i IN 1..15 LOOP
        INSERT INTO users (full_name, email, role, department_id)
        VALUES ('Agent ' || i, 'agent' || i || '@company.com', 'Agent', 
                (ARRAY[dept_it, dept_hr, dept_fin, dept_ops])[floor(random() * 4 + 1)]);
    END LOOP;

    -- Insert 4 Managers
    INSERT INTO users (full_name, email, role, department_id) VALUES ('IT Manager', 'it_mgr@company.com', 'Manager', dept_it);
    INSERT INTO users (full_name, email, role, department_id) VALUES ('HR Manager', 'hr_mgr@company.com', 'Manager', dept_hr);
    INSERT INTO users (full_name, email, role, department_id) VALUES ('Finance Manager', 'fin_mgr@company.com', 'Manager', dept_fin);
    INSERT INTO users (full_name, email, role, department_id) VALUES ('Ops Manager', 'ops_mgr@company.com', 'Manager', dept_ops);
END $$;

-- 3. Insert 2000 Mock Tickets
DO $$
DECLARE
    r_user UUID;
    a_user UUID;
    d_id INT;
    random_status VARCHAR;
    random_urgency INT;
    random_impact INT;
    created_date TIMESTAMP;
    resolved_date TIMESTAMP;
BEGIN
    FOR i IN 1..2000 LOOP
        -- Select random employee and agent
        SELECT id INTO r_user FROM users WHERE role = 'Employee' ORDER BY random() LIMIT 1;
        SELECT id INTO a_user FROM users WHERE role = 'Agent' ORDER BY random() LIMIT 1;
        
        -- Select random department
        SELECT id INTO d_id FROM departments ORDER BY random() LIMIT 1;

        -- Random urgency and impact (1 to 10)
        random_urgency := floor(random() * 10 + 1);
        random_impact := floor(random() * 10 + 1);

        -- Random created_at within last 60 days
        created_date := NOW() - (random() * 60 || ' days')::INTERVAL;

        -- Random status (weighted towards RESOLVED and CLOSED for realistic historical data)
        random_status := (ARRAY['NEW', 'ASSIGNED', 'IN PROGRESS', 'ESCALATED', 'RESOLVED', 'RESOLVED', 'CLOSED', 'CLOSED', 'CLOSED'])[floor(random() * 9 + 1)];

        -- If resolved or closed, set resolved_at
        IF random_status IN ('RESOLVED', 'CLOSED') THEN
            -- Resolved between 1 and 120 hours after creation
            resolved_date := created_date + (random() * 120 || ' hours')::INTERVAL;
        ELSE
            resolved_date := NULL;
        END IF;

        -- Insert ticket (the trigger trg_set_ticket_priority will handle priority_score, tier, and sla_deadline automatically)
        INSERT INTO tickets (
            requester_id, assigned_agent_id, department_id, request_type, 
            urgency, business_impact, status, created_at, resolved_at
        ) VALUES (
            r_user, 
            CASE WHEN random_status = 'NEW' THEN NULL ELSE a_user END, 
            d_id, 
            (ARRAY['Software Installation', 'Hardware Request', 'Payroll Query', 'Access Revocation', 'System Outage', 'General Inquiry'])[floor(random() * 6 + 1)],
            random_urgency, 
            random_impact, 
            random_status, 
            created_date, 
            resolved_date
        );
    END LOOP;
END $$;

-- 4. Update SLA Breaches
-- Identify tickets that missed their SLA deadline
UPDATE tickets 
SET is_sla_breached = TRUE 
WHERE (resolved_at IS NOT NULL AND resolved_at > sla_deadline)
   OR (resolved_at IS NULL AND NOW() > sla_deadline);
