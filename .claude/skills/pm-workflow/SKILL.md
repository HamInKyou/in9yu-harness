---
name: pm-workflow
description: >
  프로젝트 관리 워크플로우 오케스트레이터. 기획→계획→실행→리뷰 전체 라이프사이클을 단계별로 안내합니다.
  Use when: pm workflow, 프로젝트 시작, kickoff, 기능 개발, feature development, 프로젝트 관리, 워크플로우
argument-hint: "[phase or idea]"
allowed-tools: Bash(gh *)
---

# Project Management Workflow Orchestrator

OMC + pm-skills + gh-* 스킬을 종합한 프로젝트 관리 오케스트레이터입니다.
자연어로 프로젝트 관리 워크플로우를 단계별로 안내합니다.

## 현재 컨텍스트

- 레포: !`gh repo view --json nameWithOwner --jq .nameWithOwner`
- 열린 이슈: !`gh issue list --state open --limit 10 --json number,title,labels --jq '.[] | "#\(.number) \(.title)"'`
- 프로젝트: !`gh project list --owner @me --format json --jq '.projects[] | "#\(.number) \(.title)"'`

## 사용법

```
/pm-workflow                           # 전체 워크플로우 메뉴
/pm-workflow kickoff 새 기능 아이디어      # 기획부터 시작
/pm-workflow plan                      # 계획 단계
/pm-workflow execute                   # 실행 단계
/pm-workflow review                    # 리뷰 단계
/pm-workflow daily                     # 일상 루틴
/pm-workflow weekly                    # 주간 루틴
/pm-workflow sprint                    # 스프린트 사이클
```

## 동작 규칙

### 1. 인자 파싱

`$ARGUMENTS`를 분석하여 아래 모드를 판별합니다:

| 패턴 | 모드 |
|------|------|
| 인자 없음 | `menu` — 전체 워크플로우 메뉴 표시 |
| `kickoff`, `시작`, `새 기능` + 설명 | `kickoff` — 기획→계획→이슈 생성까지 |
| `plan`, `계획` | `plan` — 계획 단계 가이드 |
| `execute`, `실행` | `execute` — 실행 단계 가이드 |
| `review`, `리뷰`, `회고` | `review` — 리뷰 단계 가이드 |
| `daily`, `매일`, `오늘` | `daily` — 일상 루틴 실행 |
| `weekly`, `주간` | `weekly` — 주간 루틴 실행 |
| `sprint` | `sprint` — 스프린트 사이클 |

### 2. 모드별 실행

---

#### menu (인자 없음)

현재 컨텍스트를 분석하고 다음 가능한 액션들을 제안합니다:

```
## 🚀 프로젝트 관리 워크플로우

현재 상태:
- 열린 이슈: N개
- 프로젝트: N개

### 지금 할 수 있는 작업

📋 **기획** (새 기능을 시작할 때)
  → `/pm-workflow kickoff 아이디어 설명`

📝 **계획** (기획 완료 후 이슈/보드 세팅)
  → `/pm-workflow plan`

⚡ **실행** (이슈 작업 시작)
  → `/pm-workflow execute`

📊 **리뷰** (진행 상황 확인/회고)
  → `/pm-workflow review`

🔄 **루틴**
  → `/pm-workflow daily` — 매일 아침 루틴
  → `/pm-workflow weekly` — 주간 리뷰
  → `/pm-workflow sprint` — 스프린트 사이클
```

---

#### kickoff (기획→계획→이슈 생성)

새 기능을 처음부터 셋업하는 전체 파이프라인입니다.
각 단계마다 사용자에게 확인을 받고 다음 단계로 진행합니다.

**Step 1: 기능 구체화**
사용자의 아이디어를 분석하여 구현할 기능 목록을 직접 정리합니다.
- 아이디어에서 독립적인 작업 단위(유저 스토리/태스크)를 추출합니다
- 각 작업에 제목, 본문, 적절한 라벨을 붙입니다
- 정리된 목록을 사용자에게 보여주고 확인을 받습니다

**Step 2: GitHub 이슈 일괄 생성**
확인을 받은 후 `gh issue create`로 이슈를 직접 생성합니다:
```bash
gh issue create --title "작업 제목" --body "작업 내용" --label "enhancement"
```
- 각 이슈 생성 결과(번호, URL)를 표시합니다

**Step 3: 프로젝트 보드 생성 + 이슈 추가**
```bash
# 프로젝트 생성
gh project create --owner @me --title "기능명"

# 레포에 링크 (--owner에 실제 유저명 사용)
gh project link 프로젝트번호 --owner OWNER --repo REPO

# 생성된 이슈들을 프로젝트에 추가
gh project item-add 프로젝트번호 --owner @me --url 이슈URL
```
- 모든 이슈를 프로젝트에 자동으로 추가합니다

**Step 4: 완료 요약**
```
## ✅ Kickoff 완료!

📋 이슈: N개 생성 (#번호 목록)
📊 프로젝트: "기능명" 보드 생성 + 이슈 연결 완료

다음 단계:
- `/pm-workflow execute` — 이슈 작업 시작
- `/gh-project view 번호` — 보드 확인
- `/gh-triage` — 이슈 우선순위 배정
```

---

#### plan (계획 단계 가이드)

이미 기획이 끝난 상태에서 계획을 세울 때:

사용자에게 현재 상황을 물어보고 적절한 스킬을 안내합니다:

```
"계획 단계에서 무엇을 하고 싶으세요?"

1. PRD 작성 → `/write-prd` 안내
2. OKR 설정 → `/plan-okrs` 안내
3. 유저 스토리 작성 → `/write-stories` 안내
4. 스프린트 계획 → `/sprint` 안내 (plan 모드)
5. 리스크 분석 → `/pre-mortem` 안내
6. 이슈 생성 → `/gh-issue create ...` 안내
7. 프로젝트 보드 세팅 → `/gh-project create ...` 안내
```

---

#### execute (실행 단계)

작업할 이슈를 선택하고 워크플로우를 직접 실행합니다:

**Step 1: 작업할 이슈 선택**
컨텍스트의 열린 이슈 목록을 표시하고 사용자에게 선택을 요청합니다.

**Step 2: 브랜치 생성 + 체크아웃**
선택된 이슈로 직접 브랜치를 생성합니다:
```bash
gh issue develop 이슈번호 --checkout
```

**Step 3: 구현**
이슈 내용을 분석하여 직접 구현합니다. 복잡한 작업이면 사용자에게 실행 방식을 물어봅니다:
1. Claude가 직접 구현
2. `/autopilot` — 자율 실행
3. `/ralph` — 검증까지 자동 반복

**Step 4: PR 생성**
구현 완료 후 직접 PR을 생성합니다:
```bash
git add . && git commit -m "커밋 메시지"
git push -u origin 브랜치명
gh pr create --title "PR 제목" --body "Closes #이슈번호\n\n변경 요약" --base main
```

**Step 5: 보드 업데이트**
프로젝트가 있으면 상태를 Done으로 변경합니다:
```bash
# 프로젝트 필드/아이템 ID를 조회하여 상태 변경
gh project item-edit --id 아이템ID --project-id 프로젝트ID --field-id 필드ID --single-select-option-id Done옵션ID
```

---

#### review (리뷰 단계 가이드)

```
"리뷰 단계에서 무엇을 하고 싶으세요?"

1. 현황 파악 → `/gh-dashboard` 실행
2. 주간 리포트 → `/gh-dashboard weekly` 실행
3. 이슈 트리아지 → `/gh-triage` 실행
4. 스프린트 회고 → `/sprint` 안내 (retro 모드)
5. 릴리즈 노트 → `/sprint` 안내 (release-notes 모드)
6. 피드백 분석 → `/analyze-feedback` 안내
```

---

#### daily (매일 아침 루틴)

자동으로 다음을 순서대로 실행합니다:

**Step 1: 현황 파악**
`/gh-dashboard` 스킬의 summary 로직을 실행합니다:
- 열린 이슈 수, PR 현황, 최근 활동을 요약합니다

**Step 2: 미분류 이슈 체크**
컨텍스트의 이슈 목록에서 라벨 없는 이슈를 찾습니다:
- 있으면: "라벨 없는 이슈 N개 발견. `/gh-triage`로 분류할까요?"
- 없으면: "모든 이슈가 분류되어 있습니다."

**Step 3: 오늘 할 일 제안**
열린 이슈 중 우선순위가 높은 것을 제안합니다:
```
"오늘 작업 추천:"
- #N 이슈제목 (라벨)
  → `/gh-workflow N` 으로 시작
```

---

#### weekly (주간 루틴)

자동으로 다음을 순서대로 실행합니다:

**Step 1: 주간 리포트**
```bash
gh issue list --state all --json number,title,state,createdAt --limit 50
gh issue list --state closed --json number,title,closedAt --limit 20
gh pr list --state merged --json number,title,mergedAt --limit 20
```
최근 7일 데이터를 분석하여 주간 리포트를 생성합니다.

**Step 2: 전체 이슈 트리아지**
미분류 이슈가 있으면 `/gh-triage` 안내

**Step 3: 다음 주 계획 제안**
열린 이슈를 분석하여 다음 주 작업 추천:
```
"다음 주 추천 작업:"
- 우선순위 높은 이슈 목록
- 오래된 이슈 알림
- 담당자 없는 이슈 알림
```

---

#### sprint (스프린트 사이클)

스프린트 전체 사이클을 안내합니다:

```
"스프린트 사이클에서 무엇을 하고 싶으세요?"

1. 스프린트 계획 (Sprint Planning)
   → `/sprint` (plan 모드) 안내
   → `/gh-project create "스프린트 N"` 으로 보드 생성
   → 이슈 선택 후 `/gh-project add` 로 보드에 추가

2. 스프린트 진행 (Daily)
   → `/pm-workflow daily` 로 매일 루틴

3. 스프린트 회고 (Retrospective)
   → `/sprint` (retro 모드) 안내
   → `/gh-dashboard weekly` 로 데이터 확인

4. 릴리즈 (Release)
   → `/sprint` (release-notes 모드) 안내
```

---

### 3. 출력 형식

모든 출력은 다음 형식을 따릅니다:

```
## 🚀 [현재 단계]

[내용]

---
💡 다음 단계:
- [관련 명령어] — 설명
```

### 4. 핵심 원칙

- **직접 실행**: gh 명령어를 직접 실행합니다. 안내만 하지 않습니다
- **확인 후 실행**: 실행 전 사용자에게 확인을 받습니다 (이슈 목록, PR 내용 등)
- **한 단계씩 진행**: 한꺼번에 모든 것을 하지 않고 단계별로 확인을 받습니다
- **컨텍스트 인식**: 동적 주입된 이슈/프로젝트 상태를 활용합니다
- **한국어 출력**: 모든 안내 메시지는 한국어로 출력합니다
