# n8n Automation Workflows

## Project Title
Enterprise Workflow Intelligence & SLA Analytics Platform

Below are the two core automation workflows required for the project. **n8n** makes it incredibly easy to share workflows—you can literally copy the JSON code blocks below and paste them directly into your n8n canvas (Ctrl+V / Cmd+V)!

---

## 1. SLA Breach Monitor & Escalation
This workflow runs every 15 minutes. It queries the Supabase PostgreSQL database to find any tickets that have passed their `sla_deadline` but aren't resolved. It updates their status to `ESCALATED` and sends a Slack alert.

**Instructions:**
1. Open a new workflow in n8n.
2. Copy the JSON below and paste it into the canvas.
3. Open the **Postgres node**, set up your Supabase connection credentials.
4. Open the **Slack node**, connect your Slack account via OAuth, and pick a channel.

```json
{
  "nodes": [
    {
      "parameters": {
        "rule": {
          "interval": [
            {
              "field": "cronExpression",
              "expression": "*/15 * * * *"
            }
          ]
        }
      },
      "name": "Every 15 Minutes",
      "type": "n8n-nodes-base.scheduleTrigger",
      "position": [ 100, 300 ],
      "typeVersion": 1.1,
      "id": "node-1"
    },
    {
      "parameters": {
        "operation": "executeQuery",
        "query": "UPDATE tickets \nSET status = 'ESCALATED', updated_at = NOW(), is_sla_breached = TRUE\nWHERE status NOT IN ('RESOLVED', 'CLOSED', 'ESCALATED') \nAND sla_deadline < NOW()\nRETURNING id, request_type, priority_tier;"
      },
      "name": "Escalate Breached Tickets",
      "type": "n8n-nodes-base.postgres",
      "position": [ 350, 300 ],
      "typeVersion": 2.2,
      "id": "node-2"
    },
    {
      "parameters": {
        "channel": "operations-alerts",
        "text": "=🚨 *SLA BREACH ESCALATION* 🚨\n\n*Ticket ID:* {{$json[\"id\"]}}\n*Type:* {{$json[\"request_type\"]}}\n*Priority:* {{$json[\"priority_tier\"]}}\n\nThis ticket missed its SLA deadline and has been automatically escalated!"
      },
      "name": "Send Slack Alert",
      "type": "n8n-nodes-base.slack",
      "position": [ 600, 300 ],
      "typeVersion": 2.1,
      "id": "node-3"
    }
  ],
  "connections": {
    "Every 15 Minutes": {
      "main": [
        [
          {
            "node": "Escalate Breached Tickets",
            "type": "main",
            "index": 0
          }
        ]
      ]
    },
    "Escalate Breached Tickets": {
      "main": [
        [
          {
            "node": "Send Slack Alert",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  }
}
```

---

## 2. Instant Critical Ticket Alert (Supabase Webhook)
This workflow listens for immediate alerts. In Supabase, you can go to **Database > Webhooks** and create a trigger that fires on `INSERT` to the `tickets` table when `priority_tier = 'Critical'`. You paste the Webhook URL from the first node below into Supabase.

**Instructions:**
1. Copy and paste the JSON into a new n8n canvas.
2. Double-click the **Webhook node** and copy the "Test URL" or "Production URL".
3. In Supabase, create a Database Webhook pointing to that URL.
4. Set up the Slack node just like in the first workflow.

```json
{
  "nodes": [
    {
      "parameters": {
        "httpMethod": "POST",
        "path": "critical-ticket-alert",
        "options": {}
      },
      "name": "Supabase Webhook",
      "type": "n8n-nodes-base.webhook",
      "position": [ 100, 300 ],
      "typeVersion": 1,
      "id": "node-webhook",
      "webhookId": "critical-alert-123"
    },
    {
      "parameters": {
        "channel": "manager-alerts",
        "text": "=🔥 *NEW CRITICAL TICKET FILED* 🔥\n\n*Ticket ID:* {{$json[\"body\"][\"record\"][\"id\"]}}\n*Type:* {{$json[\"body\"][\"record\"][\"request_type\"]}}\n*Urgency:* {{$json[\"body\"][\"record\"][\"urgency\"]}}/10\n\n<@Manager> Please assign an agent immediately! SLA is 4 hours."
      },
      "name": "Notify Managers",
      "type": "n8n-nodes-base.slack",
      "position": [ 350, 300 ],
      "typeVersion": 2.1,
      "id": "node-slack-alert"
    }
  ],
  "connections": {
    "Supabase Webhook": {
      "main": [
        [
          {
            "node": "Notify Managers",
            "type": "main",
            "index": 0
          }
        ]
      ]
    }
  }
}
```
