# in9yu-harness

Claude Code 스킬과 에이전트를 중앙 관리하는 하네스 레포. `projects/` 하위에 클론한 다른 레포들이 이를 공유해서 사용한다.

## 구조

```
in9yu-harness/
├── .claude/
│   ├── CLAUDE.md           # 프로젝트 지침 (OMC 포함)
│   ├── settings.json       # Claude Code 설정
│   ├── skills/             # 공유 스킬
│   │   ├── gh-issue/       #   이슈 CRUD
│   │   ├── gh-project/     #   Projects v2 보드 관리
│   │   ├── gh-workflow/    #   이슈→브랜치→PR 파이프라인
│   │   ├── gh-triage/      #   이슈 자동 분류
│   │   ├── gh-dashboard/   #   현황 대시보드
│   │   ├── pm-workflow/    #   프로젝트 관리 오케스트레이터
│   │   └── autoresearch/   #   스킬 자동 최적화
│   └── agents/             # 공유 에이전트
├── bin/
│   └── setup.sh            # 환경 셋업 스크립트
├── docs/                   # 가이드 문서
│   └── project-management-workflow.md
├── projects/               # 외부 레포 클론 위치 (.gitignore 처리)
└── README.md
```

## 작동 원리

Claude Code는 현재 디렉토리에서 루트까지 상위로 `.claude/`를 탐색한다. `projects/repo-a/`에서 실행해도 `in9yu-harness/.claude/skills/`와 `agents/`를 자동으로 발견하므로 별도 설정이 필요 없다.

## 환경 설정

### 사전 요구사항

- [Claude Code](https://claude.ai/claude-code)
- [GitHub CLI](https://cli.github.com/) (`gh`) — gh-* 스킬에 필요

### 셋업

```bash
./bin/setup.sh
```

이 스크립트가 다음을 자동으로 처리한다:
- Claude Code 설치 여부 확인
- GitHub CLI 설치/인증/`project` 스코프 확인
- [oh-my-claudecode (OMC)](https://github.com/Yeachan-Heo/oh-my-claudecode) 플러그인 설치
- [pm-skills](https://github.com/phuryn/pm-skills) 마켓플레이스 등록 및 8개 플러그인 설치

스크립트 실행 후 Claude Code에서 `/omc-setup`을 실행하여 OMC를 구성한다.

---

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

### pm-workflow (프로젝트 관리 오케스트레이터)

PM Skills + gh-* 스킬을 조합한 프로젝트 관리 허브. 기획→계획→실행→리뷰 전체 라이프사이클을 단계별로 안내한다.

```
/pm-workflow                           # 전체 메뉴
/pm-workflow kickoff 새 기능 아이디어      # 기획→PRD→이슈→보드까지 풀 파이프라인
/pm-workflow daily                     # 매일 아침 루틴 (현황+트리아지+추천)
/pm-workflow weekly                    # 주간 리포트 + 다음 주 계획
/pm-workflow sprint                    # 스프린트 사이클
```

**오케스트레이션 흐름:**
```
kickoff  → /discover → /write-prd → /write-stories → /gh-issue → /gh-project
execute  → /gh-workflow → /autopilot|/ralph → /gh-project move
daily    → /gh-dashboard → /gh-triage → 작업 추천
review   → /gh-dashboard weekly → /sprint retro
```

자세한 가이드는 [docs/project-management-workflow.md](docs/project-management-workflow.md) 참조.

### autoresearch

Andrej Karpathy의 autoresearch 방법론 기반 스킬 자동 최적화. 기존 스킬을 반복 실행하고, binary eval 기준으로 채점, 프롬프트 변이 → 점수 상승 시 유지하는 자율 실험 루프.

```
/autoresearch                          # 대상 스킬 최적화 시작
```

**산출물:** 최적화된 스킬 `.md`, `dashboard.html`, `results.tsv`, `changelog.md`

---

## 플러그인

### oh-my-claudecode (OMC)

[oh-my-claudecode](https://github.com/Yeachan-Heo/oh-my-claudecode)는 Claude Code 위에 멀티 에이전트 오케스트레이션 레이어를 추가하는 플러그인.

- **에이전트** — `executor`, `architect`, `debugger`, `code-reviewer`, `planner`, `verifier` 등 19개
- **워크플로우** — `/autopilot`, `/ralph`, `/ultrawork`, `/team`, `/ultraqa`
- **코드 인텔리전스** — LSP, AST 검색/치환, Python REPL
- **상태 관리** — 노트패드, 프로젝트 메모리, 세션 상태

### pm-skills

[pm-skills](https://github.com/phuryn/pm-skills)는 PM 도메인 지식을 65개 스킬 + 36개 커맨드로 제공하는 플러그인 마켓플레이스.

| 플러그인 | 주요 커맨드 | 설명 |
|----------|-------------|------|
| pm-product-discovery | `/discover`, `/interview`, `/brainstorm` | 기회 탐색, 가정 검증, 실험 설계 |
| pm-product-strategy | `/strategy`, `/business-model`, `/pricing` | 전략, Lean Canvas, SWOT |
| pm-execution | `/write-prd`, `/plan-okrs`, `/sprint` | PRD, OKR, 스프린트, 유저 스토리 |
| pm-market-research | `/competitive-analysis`, `/research-users` | 경쟁 분석, 페르소나, 시장 규모 |
| pm-data-analytics | `/analyze-test`, `/analyze-cohorts` | A/B 테스트, 코호트, SQL |
| pm-go-to-market | `/plan-launch`, `/battlecard` | GTM 전략, 배틀카드, 성장 루프 |
| pm-marketing-growth | `/north-star`, `/market-product` | 노스스타 메트릭, 포지셔닝 |
| pm-toolkit | `/proofread`, `/draft-nda` | NDA, 개인정보 정책, 문법 검사 |

---

## Git 관리

`.gitignore`에 의해 다음은 추적되지 않는다:

- `.idea/` — IDE 설정
- `.omc/` — OMC 런타임 상태 (세션 데이터, HUD 상태 등)
