---
name: av-base-post-qa
description: |
  대량 작업 후 QA 오케스트레이션.
  gstack 브라우저 E2E 테스트 + bkit:qa-monitor 런타임 QA 통합.
autovibe: true
version: "2.0"
created: "2026-03-29"
group: base
argument-hint: "[url] [--full]"
user-invocable: true
allowed-tools: [Read, Glob, Grep, Bash, Skill, Task]
context: fork
agent: general-purpose
---

# av-base-post-qa — QA 오케스트레이션

> gstack + bkit:qa-monitor 통합 QA

## 실행 시퀀스

1. `Skill("gstack", "navigate $1")` — 페이지 로드 확인
2. `Skill("gstack", "check-errors $1")` — 콘솔 오류 탐지
3. `Skill("gstack", "screenshot $1")` — 시각적 스냅샷
4. `Task("bkit:qa-monitor", ...)` — 서버 로그 오류 감지
5. QA 결과 통합 리포트 출력

## --full 모드

1. 모든 주요 페이지에 대해 위 시퀀스 반복
2. `Skill("gstack", "interact {forms}")` — 인터랙션 테스트
3. `Skill("benchmark", "$1")` — 성능 기준선 측정
