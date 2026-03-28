# AutoVibe 30분 퀵스타트

> **목표**: 이 가이드를 따라 30분 안에 Phase 0 기반 인프라를 완료합니다.
> AutoVibe를 처음 접하는 분을 위한 단계별 타임라인입니다.

---

## 시작 전 확인 (2분)

```bash
# Claude Code 버전 확인
claude --version
# 기대: v2.1.71 이상

# git 확인
git --version
# 기대: git version 2.x.x
```

bkit 플러그인 확인 (Claude Code 내에서):
```
/bkit
```
bkit 메뉴가 나타나면 준비 완료입니다. 나타나지 않으면 [guides/bkit-integration.md](bkit-integration.md)를 먼저 참고하세요.

---

## 타임라인

### 0:00~2:00 — 저장소 준비

```bash
# AutoVibe 저장소 클론
git clone https://github.com/{your-org}/autovibe.git /tmp/autovibe

# 내 프로젝트 이동
cd my-project

# AutoVibe 문서 복사 (Phase 0~5 구축에 필요)
mkdir -p docs/autovibe
cp -r /tmp/autovibe/docs/* docs/autovibe/
cp -r /tmp/autovibe/guides docs/autovibe/guides
```

완료 후 구조:
```
my-project/
├── docs/
│   └── autovibe/
│       ├── prd/
│       ├── plan/
│       ├── design/
│       └── guides/
└── .git/
```

---

### 2:00~5:00 — Claude Code 시작 및 Phase 0 대화 시작

```bash
cd my-project
claude
```

Claude에게 입력:
```
AutoVibe 생태계를 구축하고 싶어. Phase 0부터 시작해줘.
docs/autovibe/design/av-ecosystem-design-spec.md 를 참고해서.
```

---

### 5:00~15:00 — Claude의 질문에 답하기 (Phase 0 핵심)

Claude가 4가지 질문을 합니다. 미리 준비하세요:

| 질문 | 예시 답변 | 비고 |
|------|---------|------|
| "프로젝트 이름은 무엇인가요?" | `my-saas` | 영문 소문자, 하이픈 사용 가능 |
| "기술 스택은 무엇인가요?" | `NestJS + Next.js` | 백엔드 + 프론트엔드 |
| "주요 도메인 그룹은 무엇인가요?" | `user, order, payment` | 콤마 구분 |
| "소스 루트 경로는?" | `src` | 기본값 그대로 Enter 가능 |

---

### 15:00~25:00 — Phase 0 구현 완료 대기

Claude가 자동으로 생성하는 것들:

```
.claude/
├── skills/           ← 빈 디렉토리 (Phase 3~4에서 채워짐)
├── agents/           ← 빈 디렉토리 (Phase 2에서 채워짐)
├── rules/            ← 빈 디렉토리 (Phase 1에서 채워짐)
├── hooks/            ← 빈 디렉토리 (Phase 5에서 채워짐)
├── registry/
│   └── components.json   ← 빈 레지스트리 생성됨
├── agent-memory/     ← 빈 디렉토리
└── docs/
    └── av-claude-code-spec/topics/
        └── frontmatter-spec.md  ← 생성됨
CLAUDE.md             ← AutoVibe 섹션 추가됨
.claude/settings.json ← 빈 훅 설정 생성됨
```

---

### 25:00~30:00 — Phase 0 완료 검증

Claude에게:
```
Phase 0이 완료됐는지 확인해줘.
```

또는 직접 확인:
```bash
# .claude/ 디렉토리 구조 확인
ls -la .claude/

# 레지스트리 파일 확인
cat .claude/registry/components.json

# CLAUDE.md AutoVibe 섹션 확인
grep -A 5 "AutoVibe" CLAUDE.md
```

기대 결과:
- `.claude/` 하위 6개 디렉토리 존재
- `components.json` 기본 구조 (`_meta`, `rules`, `agents`, `skills`, `hooks`)
- `CLAUDE.md`에 AutoVibe 관련 섹션 존재

---

## Phase 0 완료 후 다음 단계

Phase 0가 완료되면 Claude가 자동으로 다음을 제안합니다:

```
Phase 0 완료. Phase 1 Base Rules 4종 생성을 시작할까요?
```

"예"라고 답하면 Phase 1으로 자동 진행됩니다.

각 Phase 예상 시간:
| Phase | 목표 | 예상 시간 |
|-------|------|---------|
| **0** | 기반 인프라 | 30분 (이 가이드) |
| **1** | Base Rules 4종 | 10분 |
| **2** | Base Agents 8종 | 20분 |
| **3** | Meta Skills 6종 | 20분 |
| **4** | Core Skills 10종 | 20분 |
| **5** | Hooks 5종 | 10분 |
| **6** | 도메인 확장 | 무제한 (필요 시) |

**총 기반 구축 예상 시간: 약 2시간**

---

## 문제 발생 시

### "Claude가 AutoVibe를 모르는 것 같아요"

```
docs/autovibe/design/av-ecosystem-design-spec.md 파일을 읽어줘.
읽고 나서 AutoVibe Phase 0을 시작할 준비가 됐는지 알려줘.
```

### "Phase 도중 멈췄어요"

```
/pdca status
```
현재 상태 확인 후 해당 Phase부터 재시작:
```
Phase {N}을 다시 시작해줘. 이전까지 만든 파일은 유지해줘.
```

### "bkit을 찾을 수 없어요"

[guides/bkit-integration.md](bkit-integration.md)를 참고하거나 Claude Code를 재시작하세요.

---

## 참조

- **상세 가이드**: [guides/getting-started.md](getting-started.md)
- **네이밍 규칙**: [guides/naming-guide.md](naming-guide.md)
- **Phase 진행 기준**: [guides/phase-progression.md](phase-progression.md)
- **bkit 연동**: [guides/bkit-integration.md](bkit-integration.md)
