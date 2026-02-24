# Orchestration Protocol

## Planes

- **A Client**: 3D WebGL world, avatars, ASR/TTS integration, subtitles, local state caches.
- **B Agent**: local Gemini CLI wrapper orchestrator with strict structured output.
- **C Tools**: MCP-only, per-agent allowlists, no wildcard tools in production.
- **D Control**: least privilege, device binding, immutable audit, safe mode on drift.

## Tiering

- Tier0: read-only operations.
- Tier1: sandbox/dev-stage writes.
- Tier2: privileged admin requiring Sophia approval + break-glass context.

## Required Response Object

```json
{
  "speakText": "...",
  "uiEvents": [{ "type": "toast", "payload": {} }],
  "toolPlan": [{ "server": "...", "tool": "...", "tier": 0, "args": {}, "requiresApproval": false }],
  "auditMeta": {
    "env": "dev",
    "agent": "nexus",
    "intent": "...",
    "configHash": "...",
    "traceId": "...",
    "safeMode": false
  }
}
```
