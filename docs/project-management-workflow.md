# 프로젝트 관리 워크플로우 가이드

OMC, pm-skills, gh-* 스킬을 종합한 통합 프로젝트 관리 워크플로우.

## 프로젝트 라이프사이클

```
1. 기획 (Discovery)  →  2. 계획 (Planning)  →  3. 실행 (Execution)  →  4. 리뷰 (Review)
   PM Skills              PM + gh-*             gh-* + OMC              gh-* + PM
```

---

## Phase 1: 기획 (Discovery)

| 상황 | 추천 스킬 | 설명 |
|------|---------|------|
| 아이디어가 막연할 때 | `/discover` | 풀 디스커버리 사이클 (아이디어 → 가정 검증 → 실험 설계) |
| 기능 우선순위 정할 때 | `/brainstorm` → `/triage-requests` | 멀티 관점 브레인스토밍 → 우선순위 분류 |
| 경쟁 분석 | `/competitive-analysis` | 경쟁사 강약점 + 차별화 기회 |
| 사용자 리서치 | `/interview` → `/research-users` | 인터뷰 스크립트 → 페르소나/세그멘트 |
| 시장 규모 | `/market-scan` | SWOT, PESTLE, Porter's Five Forces |
| 지표 설계 | `/north-star` → `/setup-metrics` | 노스스타 메트릭 + 대시보드 설계 |

---

## Phase 2: 계획 (Planning)

| 상황 | 추천 스킬 | 설명 |
|------|---------|------|
| PRD 작성 | `/write-prd` | 8섹션 구조의 제품 요구사항 문서 |
| OKR 설정 | `/plan-okrs` | 팀 OKR 브레인스토밍 |
| 유저 스토리 | `/write-stories` | INVEST 기준 유저 스토리 + 수락 기준 |
| 이슈 생성 | `/gh-issue create ...` | 유저 스토리별 GitHub 이슈 생성 |
| 프로젝트 보드 | `/gh-project create "스프린트 1"` | Projects v2 보드 생성 + 레포 링크 |
| 보드에 추가 | `/gh-project add 1 #이슈번호` | 이슈를 프로젝트에 추가 |
| 스프린트 계획 | `/sprint` | 스프린트 계획 (용량 산정, 스토리 선택) |
| 리스크 분석 | `/pre-mortem` | Tiger/Paper Tiger/Elephant 분류 |

---

## Phase 3: 실행 (Execution)

| 상황 | 추천 스킬 | 설명 |
|------|---------|------|
| 이슈 작업 시작 | `/gh-workflow 이슈번호` | 이슈 기반 브랜치 자동 생성 + 체크아웃 |
| 복잡한 구현 | `/autopilot` 또는 `/ralph` | 자율 실행 또는 반복 루프 |
| 요구사항이 모호할 때 | `/deep-interview` → `/autopilot` | 소크라틱 인터뷰 → 스펙 → 자율 실행 |
| 대규모 병렬 작업 | `/team N:executor "작업"` | N개 에이전트 병렬 실행 |
| 코딩 완료 → PR | `/gh-workflow 이슈번호 --pr` | 자동 PR 생성 (Closes #이슈번호 포함) |
| 상태 변경 | `/gh-project move 1 #이슈번호 Done` | 칸반 보드 상태 변경 |
| 코드 리뷰 | `/simplify` | 변경된 코드 품질/효율 검토 |

---

## Phase 4: 리뷰 & 리포트

| 상황 | 추천 스킬 | 설명 |
|------|---------|------|
| 현황 파악 | `/gh-dashboard` | 이슈/PR 현황 텍스트 요약 |
| HTML 리포트 | `/gh-dashboard html` | 인터랙티브 대시보드 생성 |
| 주간 리포트 | `/gh-dashboard weekly` | 생성/닫힌 이슈, 머지된 PR 요약 |
| 미분류 이슈 정리 | `/gh-triage auto` | 자동 분류 + 라벨/담당자 배정 |
| 스프린트 회고 | `/sprint` (retro) | 잘된 점/아쉬운 점/액션 아이템 |
| 릴리즈 노트 | `/sprint` (release-notes) | 사용자향 릴리즈 노트 생성 |
| A/B 테스트 분석 | `/analyze-test` | 통계적 유의성 + Ship/Extend/Stop 판정 |
| 피드백 분석 | `/analyze-feedback` | 감성 분석 + 테마 추출 |

---

## 일상 워크플로우

### 매일

```bash
# 아침: 현황 파악
/gh-dashboard                    # 이슈/PR 현황
/gh-triage unlabeled             # 밤새 들어온 이슈 분류

# 작업: 이슈 기반 개발
/gh-workflow 42                  # 이슈 #42 작업 시작 (브랜치 생성)
# ... 코딩 ...
/gh-workflow 42 --pr             # PR 생성

# 정리: 보드 업데이트
/gh-project move 1 #42 Done     # 완료 처리
```

### 주간

```bash
/gh-dashboard weekly             # 주간 리포트
/sprint                          # 스프린트 회고 또는 다음 스프린트 계획
/gh-triage                       # 전체 이슈 트리아지
```

### 월간/분기

```bash
/plan-okrs                       # OKR 설정/리뷰
/competitive-analysis            # 경쟁 분석 업데이트
/north-star                      # 노스스타 메트릭 리뷰
```

---

## 기획→실행 파이프라인 (큰 기능)

새로운 기능을 처음부터 끝까지 만드는 전체 파이프라인:

```
/discover "새 기능 아이디어"              # 1. PM 디스커버리
  ↓
/write-prd                               # 2. PRD 작성
  ↓
/write-stories                           # 3. 유저 스토리 분해
  ↓
/gh-issue create ...                     # 4. 이슈 생성 (스토리별)
  ↓
/gh-project create "기능명"               # 5. 프로젝트 보드 생성
/gh-project add 1 #이슈번호               #    이슈들 보드에 추가
  ↓
/gh-workflow 이슈번호                     # 6. 하나씩 작업 시작
/gh-workflow 이슈번호 --pr                #    완료 시 PR 생성
  ↓
/gh-dashboard weekly                     # 7. 진행 상황 추적
  ↓
/sprint                                  # 8. 회고 + 릴리즈 노트
```

---

## Deep Interview 파이프라인 (복잡한 기능)

요구사항이 모호한 복잡한 기능에는 3-stage 파이프라인 사용:

```
/deep-interview "모호한 아이디어"          # Stage 1: 소크라틱 인터뷰
  → 명확도 ≤ 20%까지 질의                  #   (ambiguity 게이트)
  → .omc/specs/ 에 스펙 저장
  ↓
/omc-plan --consensus --direct            # Stage 2: 합의 도출
  → Planner → Architect → Critic 루프      #   (feasibility 게이트)
  → .omc/plans/ 에 계획 저장
  ↓
/autopilot                                # Stage 3: 자율 실행
  → 병렬 구현 → QA → 검증                  #   (correctness 게이트)
```

---

## 스킬 카테고리 요약

| 카테고리 | 스킬 | 용도 |
|---------|------|------|
| **gh-issue** | `/gh-issue` | 이슈 CRUD (10개 액션) |
| **gh-project** | `/gh-project` | Projects v2 보드 관리 |
| **gh-workflow** | `/gh-workflow` | 이슈→브랜치→PR 파이프라인 |
| **gh-triage** | `/gh-triage` | 이슈 자동 분류 + 배정 |
| **gh-dashboard** | `/gh-dashboard` | 현황 요약 + 리포트 |
| **OMC 실행** | `/autopilot`, `/ralph`, `/team` | 자율 코딩 실행 |
| **OMC 기획** | `/deep-interview`, `/omc-plan` | 요구사항 정제 + 계획 |
| **PM Discovery** | `/discover`, `/brainstorm`, `/interview` | 제품 발견 |
| **PM Strategy** | `/strategy`, `/competitive-analysis` | 전략 수립 |
| **PM Execution** | `/write-prd`, `/write-stories`, `/sprint` | 실행 계획 |
| **PM Analytics** | `/analyze-test`, `/analyze-cohorts` | 데이터 분석 |
