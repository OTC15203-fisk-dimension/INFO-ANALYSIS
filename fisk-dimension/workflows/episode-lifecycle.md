# Episode Lifecycle

1. Intake prompt/transcript (ASR interim + final).
2. Orchestrator context assembly (profile, world-state, env flags).
3. Agent directive planning under Ω9 overlay.
4. Structured response emission (`speakText`, `uiEvents`, `toolPlan`, `auditMeta`).
5. Utility pass (cue sheet, compliance, distribution).
6. Immutable audit commit and optional chain anchor.
