---
name: gh-dashboard
description: >
  GitHub 이슈와 프로젝트 현황을 한눈에 요약합니다. 텍스트 요약 또는 HTML 리포트를 생성합니다.
  Use when: dashboard, 대시보드, 현황, 요약, summary, 상태, 리포트, report, 이슈 현황, 프로젝트 현황
argument-hint: "[format or filter]"
allowed-tools: Bash(gh *), Bash(python *)
---

# GitHub Dashboard

이슈/PR/프로젝트 현황을 한눈에 요약하는 스킬입니다.

## 현재 컨텍스트

- 레포: !`gh repo view --json nameWithOwner --jq .nameWithOwner`
- 열린 이슈: !`gh issue list --state open --json number,title,labels,assignees,createdAt --limit 30`
- 최근 닫힌 이슈: !`gh issue list --state closed --limit 10 --json number,title,closedAt`
- PR 현황: !`gh pr list --json number,title,state,isDraft,author --limit 10`

## 사용법

```
/gh-dashboard                    # 텍스트 요약 (기본)
/gh-dashboard html               # HTML 대시보드 생성
/gh-dashboard weekly              # 주간 리포트
/gh-dashboard issues              # 이슈만 요약
/gh-dashboard prs                 # PR만 요약
```

## 동작 규칙

### 1. 인자 파싱

`$ARGUMENTS`를 분석하여 아래 모드를 판별합니다:

| 패턴 | 모드 |
|------|------|
| 인자 없음 | `summary` — 전체 텍스트 요약 |
| `html` | `html` — 인터랙티브 HTML 대시보드 생성 |
| `weekly`, `주간` | `weekly` — 주간 리포트 |
| `issues`, `이슈` | `issues` — 이슈만 요약 |
| `prs`, `PR` | `prs` — PR만 요약 |

### 2. 모드별 실행

#### summary (텍스트 요약)

동적 주입된 컨텍스트를 분석하여 다음을 출력합니다:

```
## 📊 프로젝트 대시보드: OWNER/REPO

### 이슈 현황
- 🔴 열린 이슈: N개
- 🟢 최근 닫힌 이슈: N개 (최근 7일)
- 🏷️ 라벨별:
  - bug: N개
  - enhancement: N개
  - (라벨 없음): N개

### PR 현황
- 📝 열린 PR: N개
- 📋 Draft: N개
- ✅ 머지 가능: N개

### 최근 활동
- 최신 이슈: #번호 제목 (N일 전)
- 최신 닫힌 이슈: #번호 제목 (N일 전)
- 최신 PR: #번호 제목

### 주의 필요
- ⚠️ 라벨 없는 이슈: N개
- ⚠️ 담당자 없는 이슈: N개
- ⚠️ 7일 이상 미응답 이슈: N개
```

#### html (HTML 대시보드)

Python 스크립트를 실행하여 인터랙티브 HTML 대시보드를 생성합니다:

1. `gh` CLI로 데이터 수집:
```bash
gh issue list --state open --json number,title,labels,assignees,createdAt --limit 50
gh issue list --state closed --json number,title,closedAt --limit 20
gh pr list --json number,title,state,isDraft,author --limit 20
```

2. HTML 파일 생성 (`dashboard.html`):
   - 이슈 상태별 도넛 차트
   - 라벨별 막대 차트
   - 최근 활동 타임라인
   - 이슈/PR 목록 테이블

3. 브라우저에서 자동 열기:
```bash
open dashboard.html
```

#### weekly (주간 리포트)

최근 7일간의 활동을 요약합니다:

```bash
# 이번 주 생성된 이슈
gh issue list --state all --json number,title,state,createdAt --limit 50

# 이번 주 닫힌 이슈
gh issue list --state closed --json number,title,closedAt --limit 20

# 이번 주 머지된 PR
gh pr list --state merged --json number,title,mergedAt --limit 20
```

출력 형식:
```
## 📅 주간 리포트 (MM/DD ~ MM/DD)

### 이번 주 성과
- 생성된 이슈: N개
- 닫힌 이슈: N개
- 머지된 PR: N개
- 순 변화: +N개 (열린 이슈 증감)

### 닫힌 이슈
| # | 제목 | 닫힌 날짜 |
|---|------|----------|

### 머지된 PR
| # | 제목 | 머지 날짜 |
|---|------|----------|

### 새로 생성된 이슈
| # | 제목 | 라벨 |
|---|------|------|
```

#### issues (이슈만 요약)

이슈 관련 상세 통계:
- 상태별 분포 (open/closed)
- 라벨별 분포
- 담당자별 분포
- 평균 해결 시간
- 가장 오래된 열린 이슈

#### prs (PR만 요약)

PR 관련 상세 통계:
- 상태별 분포 (open/merged/closed)
- Draft PR 목록
- 리뷰 대기 PR
- 저자별 분포

### 3. 출력 형식

```
## 📊 [대시보드 유형]

[내용]

---
💡 다음에 할 수 있는 작업:
- `/gh-dashboard html` — HTML 대시보드 생성
- `/gh-dashboard weekly` — 주간 리포트
- `/gh-triage` — 미분류 이슈 트리아지
- `/gh-issue list` — 이슈 목록
```

### 4. 에러 처리

- 이슈가 없으면 "아직 이슈가 없습니다" 안내
- PR이 없으면 해당 섹션 생략
- 프로젝트가 없으면 프로젝트 섹션 생략

### 5. 한국어/영어 처리

- 시스템 안내 메시지는 한국어로 출력
- 이슈/PR 제목은 원본 그대로 표시
