# Discovery Plan: GitHub CLI 기반 프로젝트/이슈 관리 스킬

**Date**: 2026-03-23
**Product Stage**: 기존 제품 확장 (oh-my-claudecode 스킬)
**Discovery Question**: CLI 환경에서 Linear 수준의 GitHub 이슈/프로젝트 관리 경험을 모듈형 스킬로 구현할 수 있는가?

---

## 비전

> gh CLI 명령어를 몰라도 자연어로 GitHub 이슈/프로젝트를 Linear처럼 관리한다.

## 핵심 원칙

1. **자연어 우선**: 사용자는 gh 명령어를 알 필요 없음
2. **동적 컨텍스트**: `!`command`` 주입으로 실시간 상태 인식
3. **모듈형 설계**: 독립적인 5개 스킬, 조합 가능
4. **점진적 확장**: 이슈 CRUD → 프로젝트 → 워크플로우 순서로 구축

---

## 모듈 아키텍처

```
.claude/skills/
├── gh-issue/              # 모듈 1: 이슈 CRUD
│   ├── SKILL.md
│   ├── references/
│   │   └── gh-issue-commands.md
│   └── scripts/
│       └── issue-template.sh
├── gh-project/            # 모듈 2: 프로젝트 보드 관리
│   ├── SKILL.md
│   ├── references/
│   │   └── gh-project-commands.md
│   └── scripts/
├── gh-workflow/           # 모듈 3: 이슈→브랜치→PR 워크플로우
│   ├── SKILL.md
│   └── scripts/
├── gh-triage/             # 모듈 4: 이슈 트리아지
│   ├── SKILL.md
│   └── scripts/
└── gh-dashboard/          # 모듈 5: 현황 대시보드
    ├── SKILL.md
    └── scripts/
        └── dashboard.py
```

---

## 모듈 상세

### 모듈 1: gh-issue (이슈 CRUD) — MVP, 최우선

**슬래시 명령**: `/gh-issue`

**지원 작업**:
- `create` — 이슈 생성 (제목, 본문, 라벨, 담당자)
- `list` — 이슈 목록 조회 (필터링: 상태, 라벨, 담당자)
- `view` — 이슈 상세 조회
- `edit` — 이슈 수정 (제목, 본문, 라벨, 상태)
- `close` — 이슈 닫기
- `comment` — 이슈에 코멘트 추가
- `search` — 이슈 검색

**동적 컨텍스트 주입**:
```yaml
# SKILL.md 내에서
현재 열린 이슈: !`gh issue list --state open --limit 20`
현재 레포 정보: !`gh repo view --json name,owner --jq '.owner.login + "/" + .name'`
사용 가능한 라벨: !`gh label list --limit 50`
```

**인자 처리 예시**:
```
/gh-issue 버그 리포트: 로그인 페이지에서 OAuth 실패
/gh-issue list label:bug assignee:me
/gh-issue close 42
/gh-issue view 42
```

**gh 명령어 매핑**:
| 사용자 입력 | gh 명령어 |
|-----------|----------|
| `버그: 로그인 실패` | `gh issue create --title "버그: 로그인 실패" --label bug` |
| `list label:bug` | `gh issue list --label bug` |
| `close 42` | `gh issue close 42` |
| `view 42` | `gh issue view 42` |
| `42에 코멘트: 수정 완료` | `gh issue comment 42 --body "수정 완료"` |

---

### 모듈 2: gh-project (프로젝트 보드 관리)

**슬래시 명령**: `/gh-project`

**지원 작업**:
- `list` — 프로젝트 목록 조회
- `view` — 프로젝트 보드 상세 (아이템 목록 포함)
- `add` — 이슈/PR을 프로젝트에 추가
- `move` — 아이템 상태 변경 (Todo → In Progress → Done)
- `create` — 새 프로젝트 생성

**동적 컨텍스트 주입**:
```yaml
내 프로젝트 목록: !`gh project list --limit 10`
```

**gh 명령어 매핑**:
| 사용자 입력 | gh 명령어 |
|-----------|----------|
| `list` | `gh project list` |
| `view 1` | `gh project item-list 1` |
| `add 1 #42` | `gh project item-add 1 --url <issue-url>` |
| `move 1 ITEM_ID --status Done` | `gh project item-edit --project-id X --id Y --field-id Z --single-select-option-id W` |

---

### 모듈 3: gh-workflow (이슈→브랜치→PR 파이프라인)

**슬래시 명령**: `/gh-workflow`

**핵심 가치**: 이슈 하나를 잡으면 브랜치 생성부터 PR까지 원스톱

**워크플로우**:
1. 이슈 번호로 이슈 내용 확인 (`gh issue view`)
2. 이슈 기반 브랜치 생성 (`gh issue develop --checkout`)
3. Claude가 이슈 내용 기반으로 코딩
4. 커밋 & PR 생성 (`gh pr create`)
5. 이슈에 PR 링크 코멘트

**동적 컨텍스트 주입**:
```yaml
이슈 상세: !`gh issue view $0 --json title,body,labels,assignees`
현재 브랜치: !`git branch --show-current`
```

**인자 처리**:
```
/gh-workflow 42          # 이슈 #42 작업 시작
/gh-workflow 42 --no-pr  # PR 생성 없이 브랜치만
```

---

### 모듈 4: gh-triage (이슈 트리아지)

**슬래시 명령**: `/gh-triage`

**핵심 가치**: 열린 이슈를 보고 대화형으로 우선순위/라벨/담당자 배정

**워크플로우**:
1. 동적 주입으로 열린 이슈 목록 로드
2. 이슈별 요약 제시
3. 사용자와 대화하며 라벨, 우선순위, 담당자 배정
4. 배정 결과를 `gh issue edit`로 일괄 적용

**동적 컨텍스트 주입**:
```yaml
열린 이슈: !`gh issue list --state open --limit 30 --json number,title,labels,assignees,createdAt`
라벨 목록: !`gh label list --json name,color --limit 50`
```

---

### 모듈 5: gh-dashboard (현황 대시보드)

**슬래시 명령**: `/gh-dashboard`

**핵심 가치**: 이슈/프로젝트 현황을 한눈에 요약

**출력 형태**:
- **텍스트 요약**: 상태별 이슈 수, 최근 활동, 마일스톤 진행률
- **HTML 리포트** (선택): `scripts/dashboard.py`로 인터랙티브 대시보드 생성

**동적 컨텍스트 주입**:
```yaml
열린 이슈: !`gh issue list --state open --json number,title,labels,assignees,createdAt`
닫힌 이슈 (최근 7일): !`gh issue list --state closed --limit 20 --json number,title,closedAt`
PR 현황: !`gh pr list --json number,title,state,isDraft`
프로젝트 현황: !`gh project item-list 1 --limit 50 2>/dev/null || echo "프로젝트 없음"`
```

---

## 검증 실험

### Critical Assumptions

| # | 가정 | 카테고리 | 영향 | 불확실성 | 우선순위 |
|---|------|---------|------|---------|---------|
| V1 | 자연어 → gh 명령 변환이 정확하다 | Value | 높음 | 낮음 | P0 |
| V3 | 이슈→브랜치→PR 원스톱이 핵심 가치다 | Value | 높음 | 낮음 | P0 |
| U1 | 모듈형 5개 스킬이 사용하기 편하다 | Usability | 높음 | 높음 | P1 |
| U3 | $ARGUMENTS 기반 입력이 충분하다 | Usability | 중간 | 높음 | P1 |
| F3 | Projects v2 API가 보드 관리에 충분하다 | Feasibility | 중간 | 중간 | P2 |
| V2 | CLI에서 Linear 수준 경험이 가능하다 | Value | 높음 | 중간 | P2 |

### Validation Experiments

| # | 검증 대상 | 방법 | 성공 기준 | 난이도 | 기간 |
|---|---------|------|---------|-------|------|
| E1 | gh-issue MVP | 이슈 CRUD 스킬 구현 후 실사용 | 자연어로 이슈 CRUD 5종 동작 | 낮음 | 1일 |
| E2 | 동적 주입 효과 | `!`gh issue list`` 주입 전후 비교 | Claude가 이슈 번호/제목을 정확히 참조 | 낮음 | 반일 |
| E3 | 인자 파싱 한계 | 복잡한 인자 테스트 (라벨+담당자+본문) | 90% 이상 정확 파싱 | 중간 | 1일 |
| E4 | 워크플로우 통합 | gh-workflow로 이슈→PR 전체 흐름 | 한 명령으로 end-to-end 완료 | 중간 | 2일 |
| E5 | 프로젝트 보드 | gh-project로 칸반 관리 | 자연어로 상태 변경 동작 | 중간 | 1일 |

---

## 구현 타임라인

### Week 1: Foundation
- **Day 1-2**: `gh-issue` MVP 구현 (E1)
  - SKILL.md 작성 (동적 주입 포함)
  - 이슈 create/list/view/close/comment 지원
  - 실사용 테스트
- **Day 3**: 동적 주입 효과 검증 (E2) + 인자 파싱 테스트 (E3)
- **Day 4-5**: `gh-dashboard` 구현
  - 텍스트 요약 모드
  - HTML 리포트 (scripts/dashboard.py)

### Week 2: Expansion
- **Day 1-2**: `gh-project` 구현 (E5)
  - 프로젝트 CRUD + 아이템 관리
- **Day 3-4**: `gh-workflow` 구현 (E4)
  - 이슈→브랜치→PR 파이프라인
- **Day 5**: `gh-triage` 구현
  - 대화형 이슈 분류

### Week 3: Polish
- 모듈 간 통합 테스트
- 에지케이스 처리
- references/ 문서 보강
- 사용 가이드 작성

---

## Decision Framework

- E1 성공 → Week 1 나머지 진행
- E1 실패 (자연어 파싱 부정확) → 이슈 타입별 서브커맨드 강화 (`/gh-issue create`, `/gh-issue list` 분리 검토)
- E3 실패 ($ARGUMENTS 한계) → 대화형 입력 방식으로 전환 (단계별 질문)
- E4 성공 → gh-workflow가 킬러 피처로 확정
- E5 실패 (Projects v2 API 제약) → 프로젝트 보드는 `gh issue` 라벨 기반으로 대체

---

## 기술 설계 결정사항

### 스킬 Frontmatter 패턴
```yaml
---
name: gh-issue
description: >
  GitHub 이슈를 자연어로 관리합니다. 이슈 생성, 조회, 수정, 닫기, 코멘트를 지원합니다.
  Use when: gh issue, 이슈, issue, 버그, bug, feature request, 기능 요청
argument-hint: "[action] [details]"
allowed-tools: Bash(gh issue *), Bash(gh api *)
---
```

### 동적 컨텍스트 주입 전략
- **항상 주입**: 현재 레포 정보, 열린 이슈 목록 (최근 20개)
- **조건부 주입**: 라벨 목록, 프로젝트 목록 (해당 모듈에서만)
- **인자 기반 주입**: `!`gh issue view $0`` (이슈 번호 인자 사용)

### 인자 처리 전략
- 첫 번째 단어로 액션 판별: `create`, `list`, `view`, `close`, `edit`, `comment`, `search`
- 액션 없으면 Claude가 자연어에서 의도 추론
- 복잡한 입력은 Claude가 대화형으로 추가 정보 요청
