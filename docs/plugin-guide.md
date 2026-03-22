# 플러그인 활용 가이드

이 문서는 in9yu-harness에서 사용하는 플러그인들의 활용법을 정리한다.

## oh-my-claudecode (OMC)

Claude Code 위에 멀티 에이전트 오케스트레이션 레이어를 추가하는 플러그인. 복잡한 작업을 전문 에이전트에게 위임하고, 병렬 실행과 검증을 자동화한다.

### 에이전트 활용

작업 유형에 따라 적합한 에이전트를 선택한다:

| 에이전트 | 모델 | 활용 시나리오 |
|----------|------|---------------|
| `executor` | sonnet | 코드 구현, 파일 수정 등 실행 작업 (복잡한 작업은 `model=opus`) |
| `architect` | opus | 시스템 설계, 아키텍처 의사결정, 깊은 분석 (읽기 전용) |
| `planner` | opus | 구현 전략 수립, 단계별 계획 작성 |
| `analyst` | opus | 요구사항 분석, 사전 기획 컨설팅 |
| `debugger` | sonnet | 근본 원인 분석, 스택 트레이스 해석, 빌드 에러 해결 |
| `tracer` | sonnet | 증거 기반 인과관계 추적, 경쟁 가설 비교 |
| `code-reviewer` | opus | 코드 리뷰, SOLID 원칙 검사, 심각도별 피드백 |
| `security-reviewer` | sonnet | 보안 취약점 탐지 (OWASP Top 10, 시크릿, 위험 패턴) |
| `test-engineer` | sonnet | 테스트 전략, 통합/E2E 커버리지, TDD 워크플로우 |
| `designer` | sonnet | UI/UX 설계 및 구현 |
| `writer` | haiku | 기술 문서, README, API 문서, 주석 작성 |
| `verifier` | sonnet | 검증 전략, 증거 기반 완료 확인, 테스트 적절성 평가 |
| `explorer` | haiku | 코드베이스 빠른 탐색, 파일/패턴 검색 |
| `scientist` | sonnet | 데이터 분석, 리서치 실행 |
| `critic` | opus | 작업 계획 및 코드의 다각적 리뷰 |
| `code-simplifier` | opus | 코드 단순화, 명확성·일관성·유지보수성 개선 |
| `git-master` | sonnet | atomic 커밋, 리베이스, 히스토리 관리 |
| `document-specialist` | sonnet | 외부 문서 검색 및 참조 |
| `qa-tester` | sonnet | tmux 기반 인터랙티브 CLI 테스트 |

### 워크플로우 스킬

반복적인 작업 패턴을 자동화하는 스킬:

| 스킬 | 트리거 | 설명 |
|------|--------|------|
| `/autopilot` | "autopilot" | 아이디어에서 작동하는 코드까지 완전 자율 실행 |
| `/ralph` | "ralph" | 작업 완료까지 자기 참조 루프 반복 (검증 리뷰어 설정 가능) |
| `/ultrawork` | "ulw" | 독립된 작업들을 병렬로 고속 실행 |
| `/team` | 명시적 호출 | N개 에이전트가 공유 태스크 리스트로 협업 |
| `/ultraqa` | - | 테스트 → 검증 → 수정 → 반복 QA 사이클 |
| `/ccg` | "ccg" | Claude + Codex + Gemini 3모델 오케스트레이션 |
| `/ralplan` | "ralplan" | 합의 기반 계획 수립 |
| `/deep-interview` | "deep interview" | 소크라테스식 심층 인터뷰 후 자율 실행 |
| `/trace` | - | 증거 기반 추적 레인, 경쟁 가설 오케스트레이션 |

### 활용 예시

**복잡한 리팩토링:**
```
/team 3:executor "인증 모듈을 JWT에서 세션 기반으로 마이그레이션"
```

**버그 디버깅:**
```
"이 에러 디버깅해줘" → debugger 에이전트가 근본 원인 분석
```

**코드 리뷰 후 배포:**
```
/ralph "PR 리뷰 → 수정 → 테스트 통과까지 반복"
```

**아키텍처 검토:**
```
architect 에이전트에게 설계 검토 위임 (읽기 전용, 안전)
```

---

## pm-skills

PM 도메인 지식을 Claude Code 플러그인으로 제공하는 마켓플레이스. 검증된 PM 방법론(Teresa Torres, Marty Cagan, Alberto Savoia 등)을 구조화된 워크플로우로 제공한다.

### 제품 발견 (pm-product-discovery)

아이디어를 검증하고 실험을 설계하는 스킬:

| 커맨드 | 활용 시나리오 | 산출물 |
|--------|-------------|--------|
| `/discover` | 새 기능/제품 아이디어 구조적 검증 | 가정 목록, 우선순위, 실험 설계, 발견 계획서 |
| `/brainstorm` | PM·디자이너·엔지니어 3관점 아이디어 발산 | 컨셉 랭킹, 실험 가설, 실행 가능성 평가 |
| `/interview` | 고객 인터뷰 스크립트 준비 또는 인터뷰 요약 | 인터뷰 스크립트 / JTBD, 인사이트, 액션 아이템 |
| `/setup-metrics` | 제품 성과 측정 프레임워크 설계 | 노스스타, 입력 지표, 건강 지표, 알림 임계값 |
| `/triage-requests` | 기능 요청 정리 및 우선순위 결정 | 테마별 우선순위 리포트, 노력/정합성 평가 |

**활용 흐름:** `/brainstorm` → `/discover` → `/interview` (준비) → 인터뷰 실시 → `/interview` (요약) → `/setup-metrics`

### 제품 전략 (pm-product-strategy)

비전과 전략을 수립하는 스킬:

| 커맨드 | 활용 시나리오 | 산출물 |
|--------|-------------|--------|
| `/strategy` | 제품 전략 방향 수립 | 9섹션 전략 캔버스 (비전~방어력) |
| `/business-model` | 비즈니스 모델 분석 (Lean/Full/Startup/Value Prop) | 프레임워크별 캔버스, 교차 분석 |
| `/market-scan` | 시장 환경 분석 | SWOT + PESTLE + Porter's + Ansoff 통합 리포트 |
| `/value-proposition` | 가치 제안 명확화 (JTBD 기반) | 6파트 고객 중심 메시징 프레임워크 |
| `/pricing` | 가격 전략 수립 | 가격 모델, 티어 구조, 경쟁 벤치마크, 수익 예측 |

**활용 흐름:** `/value-proposition` → `/strategy` → `/business-model` → `/market-scan` → `/pricing`

### 실행 (pm-execution)

기획을 실행으로 옮기는 스킬:

| 커맨드 | 활용 시나리오 | 산출물 |
|--------|-------------|--------|
| `/write-prd` | 제품 요구사항 문서 작성 | 8섹션 PRD (배경, 목표, 유저 스토리, 타임라인 등) |
| `/write-stories` | 기능을 스프린트 단위 스토리로 분해 | 5~15개 스토리 + 수용 기준 + 우선순위 |
| `/plan-okrs` | 분기 OKR 설정 | 3개 OKR 세트 + 정렬 맵 + 점수 가이드 |
| `/sprint` | 스프린트 계획/회고/릴리즈 노트 | 용량 분석, 회고 요약, 사용자 커뮤니케이션 |
| `/pre-mortem` | 출시 전 리스크 사전 분석 | Tigers(진짜 위험)/Paper Tigers(과장)/Elephants(회피) |
| `/stakeholder-map` | 이해관계자 관리 전략 | Power×Interest 그리드 + RACI + 커뮤니케이션 계획 |
| `/transform-roadmap` | 기능 중심 → 성과 중심 로드맵 전환 | 성과 문장, 성공 지표, 전략 테마 |
| `/test-scenarios` | 유저 스토리를 테스트 케이스로 변환 | 시나리오 테이블, 커버리지 매트릭스 |
| `/meeting-notes` | 회의록 정리 | 결정사항 테이블, 액션 아이템, 미결 사항 |
| `/generate-data` | 개발/테스트용 더미 데이터 생성 | CSV, JSON, SQL, Python 스크립트 |

**활용 흐름:** `/write-prd` → `/write-stories` → `/sprint` (계획) → 개발 → `/sprint` (회고) → `/sprint` (릴리즈 노트)

### 시장 조사 (pm-market-research)

시장과 사용자를 이해하는 스킬:

| 커맨드 | 활용 시나리오 | 산출물 |
|--------|-------------|--------|
| `/competitive-analysis` | 경쟁사 분석 | 시장 개요, 기능 비교, 포지셔닝 맵, 차별화 기회 |
| `/research-users` | 사용자 리서치 데이터 구조화 | 페르소나 3~4개, 행동 세그먼트, 고객 여정 맵 |
| `/analyze-feedback` | 대량 피드백 분석 (리뷰, NPS, 서포트 티켓) | 감성 분석, 테마 추출, 세그먼트별 비교 |

### 데이터 분석 (pm-data-analytics)

데이터 기반 의사결정을 지원하는 스킬:

| 커맨드 | 활용 시나리오 | 산출물 |
|--------|-------------|--------|
| `/analyze-test` | A/B 테스트 결과 통계 분석 | p값, 신뢰구간, 비즈니스 임팩트, SHIP/EXTEND/STOP 판정 |
| `/analyze-cohorts` | 코호트별 리텐션·참여도 분석 | 리텐션 테이블, 커브, 코호트 비교 |
| `/write-query` | 자연어 → SQL 변환 | BigQuery/PostgreSQL/MySQL 쿼리 + 설명 |

### GTM (pm-go-to-market)

시장 진입과 성장을 위한 스킬:

| 커맨드 | 활용 시나리오 | 산출물 |
|--------|-------------|--------|
| `/plan-launch` | 제품 출시 전략 수립 | 비치헤드, ICP, 포지셔닝, 채널, 타임라인 |
| `/battlecard` | 경쟁사 대응 세일즈 자료 | 포지셔닝, 기능 비교, 이의 처리, 전략 질문 |
| `/growth-strategy` | 성장 메커니즘 설계 | 성장 루프 분석, GTM 접근법, 90일 실행 계획 |

### 마케팅 (pm-marketing-growth)

마케팅 자산과 핵심 지표 설정:

| 커맨드 | 활용 시나리오 | 산출물 |
|--------|-------------|--------|
| `/north-star` | 핵심 성공 지표 정의 | 노스스타 메트릭, 입력 지표, 카운터 메트릭 |
| `/market-product` | 마케팅 자산 생성 | 캠페인 아이디어, 포지셔닝, 카피, 제품명 |

### 유틸리티 (pm-toolkit)

범용 도구:

| 커맨드 | 활용 시나리오 | 산출물 |
|--------|-------------|--------|
| `/proofread` | 문서 교정 (문법, 논리, 흐름) | 카테고리별 이슈 목록 + 수정안 |
| `/draft-nda` | NDA 초안 작성 | 관할권별 NDA + 법률 검토 포인트 |
| `/privacy-policy` | 개인정보 처리방침 작성 | 규정 준수 정책 + 구현 체크리스트 |
| `/review-resume` | PM 이력서 평가 | 10개 기준 점수 + 개선 제안 |
| `/tailor-resume` | 특정 JD에 맞춘 이력서 최적화 | 정합성 점수, 키워드 분석, 맞춤 이력서 |

---

## autoresearch

기존 스킬의 프롬프트를 자동으로 최적화하는 스킬. Andrej Karpathy의 autoresearch 방법론 기반.

### 활용 시나리오

- 스킬 성공률이 70~80%에 머물 때 → 자동 실험으로 90%+ 달성
- 새로 만든 스킬의 품질을 체계적으로 끌어올리고 싶을 때
- 어떤 프롬프트 변경이 효과적인지 데이터 기반으로 확인하고 싶을 때

### 사용법

```
/autoresearch
```

또는 "optimize this skill", "run autoresearch on", "make this skill better" 등의 키워드로 트리거.

### 필요 입력

1. **대상 스킬** — 최적화할 SKILL.md 경로
2. **테스트 입력** — 3~5개 다양한 시나리오 (과적합 방지)
3. **Eval 기준** — 3~6개 binary(합/불) 체크 (스케일 사용 금지)
4. **실행 횟수** — 변이당 몇 번 실행할지 (기본 5회)

### 실행 과정

1. 원본 스킬 그대로 실행하여 베이스라인 측정
2. 실패 패턴 분석 → 가설 1개 수립 → 프롬프트 변이
3. 재실행 → 채점 → 점수 향상 시 유지, 아니면 폐기
4. 점수 천장(95%+ 3회 연속) 또는 수동 중단까지 반복
5. 실시간 대시보드(`dashboard.html`)로 진행 상황 모니터링

### 산출물

- `[user-chosen-name].md` — 최적화된 스킬 (원본 SKILL.md 보존)
- `dashboard.html` — 브라우저 대시보드
- `results.tsv` / `results.json` — 실험 로그
- `changelog.md` — 모든 변이 시도 기록

### 핵심 원칙

- 한 번에 **1가지만** 변경 (어떤 변경이 효과적인지 파악 가능)
- **binary eval만** 사용 (1~7 스케일은 노이즈가 큼)
- 원본 SKILL.md는 **절대 수정하지 않음**
