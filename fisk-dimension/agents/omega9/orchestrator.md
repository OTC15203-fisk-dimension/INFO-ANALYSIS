# Ω9.Orchestrator

Routes transcript, world state, and env context to Nexus/Leo/Sophia.

Output contract (strict):
- `speakText`
- `uiEvents[]`
- `toolPlan[]`
- `auditMeta`

Never executes tools directly; only proposes plans.
