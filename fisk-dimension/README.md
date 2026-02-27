# Fisk Dimension

Master organization scaffold for Jamie Cordell Fisk's voice-first ecosystem.

## Identity Layer

- **GitHub**: `OTC15203`
- **ORCID**: `https://orcid.org/0009-0004-7767-4270`
- **Sovereign codex owner**: Jamie Cordell Fisk

## Architecture Summary

- `codex/`: sovereignty, dimensional laws, character canon, orchestration constraints.
- `agents/`: Ω9 control, host agents, utility agents.
- `scripts/`: PowerShell, Bash, Firebase deployment stubs.
- `workflows/`: lifecycle, schema, and routing protocol.

## Security + Control Model

- Deny-by-default tool usage with per-agent allowlists.
- Tiered permissions (`Tier0`, `Tier1`, `Tier2`) with Sophia gate on privileged operations.
- Immutable audit metadata (`traceId`, `configHash`, environment, and safeMode state).
- Client executes UI/voice only; privileged actions are planned by orchestrator and executed externally through MCP.

## Offline-First Build Plan

1. Standalone local runtime for UI + ASR/TTS + orchestrator wrapper.
2. Add cloud hardening profile for AWS + GKE + Azure PowerShell + Firebase + Gemini CLI.
3. Enforce Omega9/Firestorm guardrails in all environments.

