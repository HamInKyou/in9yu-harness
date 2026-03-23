---
name: gh-triage
description: >
  열린 이슈를 분석하고 대화형으로 라벨, 우선순위, 담당자를 배정합니다.
  Use when: triage, 트리아지, 분류, 우선순위, priority, 라벨 배정, 담당자 배정, 이슈 정리
argument-hint: "[filter or natural language]"
allowed-tools: Bash(gh *)
---

# GitHub Issue Triage

열린 이슈를 분석하고 대화형으로 라벨/우선순위/담당자를 배정하는 스킬입니다.

## 현재 컨텍스트

- 레포: !`gh repo view --json nameWithOwner --jq .nameWithOwner`
- 열린 이슈: !`gh issue list --state open --limit 30 --json number,title,labels,assignees,createdAt`
- 사용 가능한 라벨: !`gh label list --json name --jq '[.[].name] | join(", ")'`

## 사용법

```
/gh-triage                          # 미분류 이슈 전체 트리아지
/gh-triage unlabeled                # 라벨 없는 이슈만
/gh-triage label:bug                # 특정 라벨 이슈만
/gh-triage 1 5 12                   # 특정 이슈들만 트리아지
/gh-triage auto                     # 자동 분류 (확인 후 일괄 적용)
```

## 동작 규칙

### 1. 인자 파싱

`$ARGUMENTS`를 분석하여 아래 모드를 판별합니다:

| 패턴 | 모드 |
|------|------|
| 인자 없음 | `full` — 모든 열린 이슈 트리아지 |
| `unlabeled`, `미분류` | `unlabeled` — 라벨 없는 이슈만 |
| `label:라벨명` | `filtered` — 특정 라벨 이슈만 |
| 숫자 나열 (예: `1 5 12`) | `selected` — 지정된 이슈만 |
| `auto`, `자동` | `auto` — 자동 분류 후 확인 |

### 2. 트리아지 프로세스

#### Step 1: 이슈 분석

각 이슈에 대해 제목과 본문을 분석하여 다음을 추론합니다:

- **타입**: bug / enhancement / documentation / question
- **우선순위**: P0(긴급) / P1(높음) / P2(보통) / P3(낮음)
- **추천 라벨**: 기존 라벨 목록에서 매칭
- **추천 담당자**: 레포 기여자 중 적합한 사람 (알 수 없으면 생략)

#### Step 2: 분류 결과 제시

테이블 형태로 분류 결과를 제시합니다:

```
## 🏷️ 트리아지 결과

| # | 제목 | 타입 | 우선순위 | 추천 라벨 | 담당자 |
|---|------|------|---------|---------|--------|
| 1 | feat: Replicate 스킬 | enhancement | P2 | enhancement | - |
| 5 | 로그인 버그 | bug | P0 | bug | - |
| 12 | API 문서 업데이트 | documentation | P3 | documentation | - |
```

#### Step 3: 사용자 확인

- `full`/`unlabeled`/`filtered` 모드: 이슈별로 확인 요청
  - "이 분류가 맞나요? 수정할 항목이 있으면 알려주세요."
- `auto` 모드: 전체 결과를 보여주고 일괄 적용 여부 확인
  - "위 분류를 일괄 적용할까요? (y/n)"
- `selected` 모드: 선택된 이슈만 확인

#### Step 4: 적용

사용자가 승인하면 `gh issue edit`로 적용합니다:

```bash
# 라벨 추가
gh issue edit 이슈번호 --add-label "라벨명"

# 담당자 배정
gh issue edit 이슈번호 --add-assignee "사용자명"
```

### 3. 우선순위 기준

| 우선순위 | 기준 | 예시 |
|---------|------|------|
| **P0** 긴급 | 서비스 장애, 보안 취약점, 데이터 손실 | "프로덕션 DB 연결 실패" |
| **P1** 높음 | 핵심 기능 버그, 사용자 영향 큼 | "로그인 실패", "결제 오류" |
| **P2** 보통 | 개선 사항, 비핵심 버그 | "UI 개선", "성능 최적화" |
| **P3** 낮음 | 문서, 리팩토링, 기술 부채 | "README 업데이트", "코드 정리" |

### 4. 출력 형식

```
## 🏷️ 트리아지 결과

[분류 테이블]

---
✅ 적용 완료: N개 이슈에 라벨/담당자 배정
💡 다음에 할 수 있는 작업:
- `/gh-issue list` — 이슈 목록 확인
- `/gh-triage unlabeled` — 미분류 이슈 재확인
- `/gh-project add 1 #이슈번호` — 프로젝트에 추가
```

### 5. 에러 처리

- 이슈 본문이 없으면 제목만으로 분류
- 라벨이 레포에 없으면 가장 유사한 기존 라벨로 매칭
- 담당자를 모르면 빈칸으로 두고 사용자에게 위임

### 6. 한국어/영어 처리

- 이슈 제목/본문이 한국어든 영어든 자동 분석
- 시스템 안내 메시지는 한국어로 출력
