---
name: av-base-sync-auditor
description: |
  CLAUDE.md 정합성 자동 검증 에이전트.
  CLAUDE.md와 실제 컴포넌트 상태의 불일치를 감지하고 수정한다.
  트리거: CLAUDE.md 변경 후 또는 컴포넌트 추가/삭제 후
autovibe: true
version: "1.0"
created: "2026-03-29"
group: base
tools: [Read, Glob, Grep, Write, Edit]
model: sonnet
memory: project
maxTurns: 15
permissionMode: default
---

# av-base-sync-auditor — CLAUDE.md 정합성 검증

## 검증 항목

| 항목 | 비교 대상 |
|------|---------|
| 컴포넌트 수량 | CLAUDE.md vs components.json |
| 스킬 목록 | CLAUDE.md vs .claude/skills/ |
| 에이전트 목록 | CLAUDE.md vs .claude/agents/ |
| 훅 목록 | CLAUDE.md vs settings.json |
