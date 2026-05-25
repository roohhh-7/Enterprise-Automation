-- Supabase Schema for Enterprise Workflow Intelligence Platform

-- 1. Departments Table
CREATE TABLE departments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    criticality_score INT DEFAULT 5 CHECK (criticality_score BETWEEN 1 AND 10),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. Users Table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(50) CHECK (role IN ('Employee', 'Agent', 'Manager', 'Admin')),
    department_id INT REFERENCES departments(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Tickets Table
CREATE TABLE tickets (
    id SERIAL PRIMARY KEY,
    requester_id UUID REFERENCES users(id) NOT NULL,
    assigned_agent_id UUID REFERENCES users(id),
    department_id INT REFERENCES departments(id) NOT NULL,
    request_type VARCHAR(100) NOT NULL,
    urgency INT CHECK (urgency BETWEEN 1 AND 10) NOT NULL,
    business_impact INT CHECK (business_impact BETWEEN 1 AND 10) NOT NULL,
    status VARCHAR(50) DEFAULT 'NEW' CHECK (status IN ('NEW', 'ASSIGNED', 'IN PROGRESS', 'ESCALATED', 'RESOLVED', 'CLOSED')),
    priority_score FLOAT,
    priority_tier VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    resolved_at TIMESTAMP WITH TIME ZONE,
    sla_deadline TIMESTAMP WITH TIME ZONE,
    is_sla_breached BOOLEAN DEFAULT FALSE
);

-- 4. Workflow Logs Table (For history and bottleneck analysis)
CREATE TABLE workflow_logs (
    id SERIAL PRIMARY KEY,
    ticket_id INT REFERENCES tickets(id) ON DELETE CASCADE,
    changed_by UUID REFERENCES users(id),
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    comment TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Escalations Table
CREATE TABLE escalations (
    id SERIAL PRIMARY KEY,
    ticket_id INT REFERENCES tickets(id) ON DELETE CASCADE,
    escalated_by UUID REFERENCES users(id),
    escalated_to UUID REFERENCES users(id),
    reason TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Dynamic Priority Scoring Logic via Trigger
CREATE OR REPLACE FUNCTION set_ticket_priority_and_sla()
RETURNS TRIGGER AS $$
DECLARE
    dept_criticality INT;
    calc_score FLOAT;
    sla_hours INT;
BEGIN
    -- Get department criticality
    SELECT criticality_score INTO dept_criticality FROM departments WHERE id = NEW.department_id;
    IF NOT FOUND THEN
        dept_criticality := 5;
    END IF;

    -- Calculate base priority score
    -- Score = (Urgency x 0.4) + (Business Impact x 0.3) + (Dept Criticality x 0.1)
    -- Note: Waiting time is added dynamically in analytical views, not stored statically here to avoid constant updates.
    calc_score := (NEW.urgency * 0.4) + (NEW.business_impact * 0.3) + (dept_criticality * 0.1);
    NEW.priority_score := calc_score;

    -- Determine Tier and SLA Hours
    IF calc_score >= 7.5 THEN
        NEW.priority_tier := 'Critical';
        sla_hours := 4;
    ELSIF calc_score >= 5.5 THEN
        NEW.priority_tier := 'High';
        sla_hours := 8;
    ELSIF calc_score >= 3.5 THEN
        NEW.priority_tier := 'Medium';
        sla_hours := 24;
    ELSE
        NEW.priority_tier := 'Low';
        sla_hours := 48;
    END IF;

    -- Set SLA deadline if it's a new ticket or priority changed
    IF TG_OP = 'INSERT' THEN
        NEW.sla_deadline := NEW.created_at + (sla_hours || ' hours')::INTERVAL;
    END IF;

    -- Always update updated_at
    NEW.updated_at := NOW();

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_ticket_priority
BEFORE INSERT OR UPDATE OF urgency, business_impact, department_id ON tickets
FOR EACH ROW
EXECUTE FUNCTION set_ticket_priority_and_sla();

-- View to calculate dynamic score including waiting time for reports
CREATE OR REPLACE VIEW v_dynamic_tickets AS
SELECT 
    t.*,
    CASE 
        WHEN t.status IN ('RESOLVED', 'CLOSED') THEN t.priority_score
        ELSE t.priority_score + ( (EXTRACT(EPOCH FROM (NOW() - t.created_at))/3600) * 0.2 )
    END AS dynamic_priority_score
FROM tickets t;
