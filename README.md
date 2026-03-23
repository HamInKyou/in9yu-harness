# in9yu-harness

Claude Code 스킬과 에이전트를 중앙 관리하는 하네스 레포. `projects/` 하위에 클론한 다른 레포들이 이를 공유해서 사용한다.

## 구조

```
in9yu-harness/
├── .claude/
│   ├── CLAUDE.md         # 프로젝트 지침 (OMC 포함)
│   ├── settings.json     # Claude Code 설정
│   ├── skills/           # 공유 스킬 (gh-issue, gh-project, gh-workflow, gh-triage, gh-dashboard, autoresearch)
│   └── agents/           # 공유 에이전트
├── bin/
│   └── setup.sh          # 환경 셋업 스크립트
├── docs/                 # 하네스 관련 문서
├── projects/             # 외부 레포 클론 위치 (.gitignore 처리)
└── README.md
```

## 작동 원리

Claude Code는 현재 디렉토리에서 루트까지 상위로 `.claude/`를 탐색한다. `projects/repo-a/`에서 실행해도 `in9yu-harness/.claude/skills/`와 `agents/`를 자동으로 발견하므로 별도 설정이 필요 없다.

## 환경 설정

이 레포를 클론한 후 다음 단계를 따른다.

### 사전 요구사항

- [Claude Code](https://claude.ai/claude-code) 설치

### 셋업

```bash
./bin/setup.sh
```

이 스크립트가 다음을 자동으로 처리한다:
- Claude Code 설치 여부 확인
- [oh-my-claudecode (OMC)](https://github.com/Yeachan-Heo/oh-my-claudecode) 플러그인 설치
- [pm-skills](https://github.com/phuryn/pm-skills) 마켓플레이스 등록 및 8개 플러그인 설치

스크립트 실행 후 Claude Code에서 `/omc-setup`을 실행하여 OMC를 구성한다.

- `.claude/CLAUDE.md`(프로젝트 설정)는 커밋에 포함되어 있으므로 클론 시 바로 적용된다.
- 이미 셋업이 완료된 상태라면 "Update CLAUDE.md only"를 선택하면 된다.

### OMC 업데이트 후

OMC 플러그인 업데이트 후에는 `/omc-setup`을 실행해서 CLAUDE.md를 갱신한다.

## 공유 스킬

### GitHub 이슈/프로젝트 관리 (gh-* 스킬 모음)

`gh` CLI를 자연어로 감싸는 5개 모듈형 스킬. GitHub 이슈와 프로젝트를 Linear처럼 관리한다. 동적 컨텍스트 주입(`!`command``)으로 현재 레포/이슈/라벨 상태를 실시간 인식한다.

| 스킬 | 명령 | 설명 |
|------|------|------|
| **gh-issue** | `/gh-issue` | 이슈 CRUD — 생성, 조회, 수정, 닫기, 코멘트, 검색 (10개 액션) |
| **gh-project** | `/gh-project` | Projects v2 보드 관리 — 생성+레포 링크, 아이템 추가, 상태 변경(칸반) |
| **gh-workflow** | `/gh-workflow` | 이슈→브랜치→PR 파이프라인 — `gh issue develop` 기반 원스톱 워크플로우 |
| **gh-triage** | `/gh-triage` | 이슈 트리아지 — 자동 분류(타입/우선순위) + 라벨/담당자 대화형 배정 |
| **gh-dashboard** | `/gh-dashboard` | 현황 대시보드 — 텍스트 요약, HTML 리포트, 주간 리포트 |

**사용 예시:**
```
/gh-issue 로그인 버그 수정 필요           # 자연어로 이슈 생성
/gh-issue list label:bug                # 라벨 필터링
/gh-workflow 1                          # 이슈 #1 작업 시작 (브랜치 생성)
/gh-workflow 1 --pr                     # PR 생성
/gh-project create 스프린트 1            # 프로젝트 생성 + 레포 링크
/gh-project move 1 #42 Done            # 상태 변경
/gh-triage auto                        # 미분류 이슈 자동 분류
/gh-dashboard weekly                   # 주간 리포트
```

**사전 요구사항:** `gh auth status`에서 `project` 스코프가 필요 (`gh auth refresh -s project`)

### pm-workflow (프로젝트 관리 워크플로우 오케스트레이터)

PM Skills + gh-* 스킬을 조합한 프로젝트 관리 허브. 기획→계획→실행→리뷰 전체 라이프사이클을 단계별로 안내한다. 직접 실행하지 않고 적절한 스킬을 안내하는 오케스트레이터 역할.

**사용법:**
```
/pm-workflow                           # 전체 메뉴
/pm-workflow kickoff 새 기능 아이디어      # 기획→PRD→이슈→보드까지 풀 파이프라인
/pm-workflow plan                      # 계획 단계 가이드
/pm-workflow execute                   # 실행 단계 가이드 (이슈 선택→작업)
/pm-workflow review                    # 리뷰 단계 가이드
/pm-workflow daily                     # 매일 아침 루틴 (현황+트리아지+추천)
/pm-workflow weekly                    # 주간 리포트 + 다음 주 계획
/pm-workflow sprint                    # 스프린트 사이클 (계획→진행→회고→릴리즈)
```

**오케스트레이션 흐름:**
```
kickoff  → /discover → /write-prd → /write-stories → /gh-issue → /gh-project
execute  → /gh-workflow → /autopilot|/ralph → /gh-project move
daily    → /gh-dashboard → /gh-triage → 작업 추천
review   → /gh-dashboard weekly → /sprint retro
```

자세한 워크플로우 가이드는 [docs/project-management-workflow.md](docs/project-management-workflow.md) 참조.

### autoresearch

Andrej Karpathy의 autoresearch 방법론을 Claude Code 스킬에 적용한 자동 최적화 스킬. 기존 스킬을 반복 실행하고, binary eval(합/불) 기준으로 채점한 뒤, 프롬프트를 변이시켜 점수가 오르는 변이만 유지하는 자율 실험 루프를 돌린다.

**사용법:** `/autoresearch` 또는 "optimize this skill", "run autoresearch on" 등의 키워드로 트리거

**흐름:**
1. 대상 스킬, 테스트 입력, eval 기준 등 컨텍스트 수집
2. 원본 스킬을 그대로 실행하여 베이스라인 점수 측정
3. 실패 패턴 분석 → 가설 수립 → 프롬프트 1가지 변이 → 재실행 → 채점 → 유지/폐기 판정
4. 점수 천장 도달 또는 수동 중단까지 자율 반복

**산출물:**
- `[user-chosen-name].md` — 최적화된 스킬 (원본 SKILL.md는 변경하지 않음)
- `dashboard.html` — 실시간 브라우저 대시보드
- `results.tsv` / `results.json` — 실험별 점수 로그
- `changelog.md` — 모든 변이 시도 기록

## 플러그인

### oh-my-claudecode (OMC)

[oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode)는 Claude Code 위에 멀티 에이전트 오케스트레이션 레이어를 추가하는 플러그인. 복잡한 작업을 전문 에이전트에게 위임하고, 병렬 실행과 검증을 자동화한다.

**주요 기능:**

- **전문 에이전트 카탈로그** — `executor`(구현), `architect`(설계), `debugger`(디버깅), `code-reviewer`(리뷰), `planner`(기획), `verifier`(검증) 등 19개 에이전트
- **워크플로우 스킬** — `/autopilot`(자율 실행), `/ralph`(반복 루프), `/ultrawork`(병렬 실행), `/team`(팀 협업), `/ultraqa`(QA 사이클)
- **코드 인텔리전스** — LSP(정의 이동, 참조 찾기, 진단), AST 검색/치환, Python REPL
- **상태 관리** — 노트패드, 프로젝트 메모리, 세션 상태 추적
- **HUD** — 상태 표시줄을 통한 실시간 작업 현황

**셋업:** `./bin/setup.sh` 실행 후 Claude Code에서 `/omc-setup`

### pm-skills

[pm-skills](https://github.com/phuryn/pm-skills)는 PM 도메인 지식을 Claude Code 플러그인으로 제공하는 마켓플레이스. 65개 스킬과 36개 커맨드를 8개 플러그인으로 묶어 제공한다. 의존성이 없는 순수 마크다운 기반이라 OMC와 충돌 없이 사용 가능.

**설치된 플러그인:**

| 플러그인 | 스킬 수 | 주요 커맨드 | 설명 |
|----------|---------|-------------|------|
| pm-product-discovery | 13 | `/discover`, `/interview`, `/brainstorm` | 기회 탐색, 가정 검증, 인터뷰, 실험 설계 |
| pm-product-strategy | 12 | `/strategy`, `/business-model`, `/pricing` | 비전, 전략, Lean Canvas, SWOT, 가격 전략 |
| pm-execution | 15 | `/write-prd`, `/plan-okrs`, `/sprint` | PRD, OKR, 스프린트, 로드맵, 유저 스토리 |
| pm-market-research | 7 | `/competitive-analysis`, `/research-users` | 경쟁 분석, 페르소나, 시장 규모, 고객 여정 |
| pm-data-analytics | 3 | `/analyze-test`, `/analyze-cohorts` | A/B 테스트, 코호트 분석, SQL 쿼리 |
| pm-go-to-market | 6 | `/plan-launch`, `/battlecard` | GTM 전략, 배틀카드, 성장 루프 |
| pm-marketing-growth | 5 | `/north-star`, `/market-product` | 노스스타 메트릭, 포지셔닝, 제품 네이밍 |
| pm-toolkit | 4 | `/proofread`, `/draft-nda` | NDA 초안, 개인정보 정책, 문법 검사 |

## Git 관리

`.gitignore`에 의해 다음은 추적되지 않는다:

- `.idea/` — IDE 설정
- `.omc/` — OMC 런타임 상태 (세션 데이터, HUD 상태 등)
