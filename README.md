# in9yu-harness

Claude Code 스킬과 에이전트를 중앙 관리하는 하네스 레포. 다른 프로젝트 레포에서 `--add-dir`로 하네스를 주입하여 스킬과 설정을 공유한다.

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
│   │   ├── autoresearch/   #   스킬 자동 최적화
│   │   └── agent-browser/  #   브라우저 자동화
│   └── agents/             # 공유 에이전트
├── bin/
│   └── setup.sh            # 환경 셋업 스크립트
├── docs/                   # 가이드 문서
│   └── project-management-workflow.md
└── README.md
```

## 작동 원리

작업 레포에서 Claude Code를 실행할 때 `--add-dir`로 하네스 경로를 추가하면, 하네스의 `.claude/skills/`와 `agents/`를 인식한다. 작업 레포가 주 컨텍스트(파일 수정, git 등)이고, 하네스는 스킬/설정 공급자 역할을 한다.

```bash
# 작업 레포에서 하네스를 주입하여 Claude Code 실행
cd ~/Projects/my-app
claude --add-dir ~/Teams/in9yu-harness

# 매번 입력이 번거로우면 alias 설정
alias harness-claude='claude --add-dir ~/Teams/in9yu-harness'
```

## 환경 설정

### 사전 요구사항

- [Claude Code](https://claude.ai/claude-code)

### 셋업

```bash
./bin/setup.sh
```

이 스크립트가 다음을 자동으로 처리한다:
- Claude Code 설치 여부 확인
- GitHub CLI 설치/인증/`project` 스코프 확인
- [agent-browser](https://agent-browser.dev) 설치 및 Chrome 다운로드

스크립트 실행 후 Claude Code에서 `/omc-setup`을 실행하여 OMC를 구성한다.

### 플러그인 설치

플러그인(OMC, pm-skills)은 `.claude/settings.json`에 선언되어 있어 **저장소를 trust하면 자동으로 설치**된다. 별도의 설치 명령이 필요 없다.

만약 새로운 플러그인을 추가해야 할 경우, **프로젝트 스코프**로 설치하여 설정이 `.claude/settings.json`에 반영되도록 한다:

```bash
# 마켓플레이스 등록 (최초 1회)
/plugin marketplace add <owner>/<repository>

# 플러그인 프로젝트 스코프 설치
/plugin install <plugin-name>@<marketplace> --scope project
```

`--scope project`로 설치하면 `.claude/settings.json`에 자동 추가되어, 이후 다른 환경에서는 trust만으로 설치된다.

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

### agent-browser (브라우저 자동화)

[agent-browser](https://github.com/anthropics/agent-browser) CLI를 활용한 브라우저 자동화 스킬. 웹 페이지 탐색, 폼 입력, 버튼 클릭, 스크린샷, 데이터 추출, 웹앱 테스트 등 프로그래밍 방식의 브라우저 조작을 수행한다.

**핵심 워크플로우:** `open` → `snapshot` → `interact` → `re-snapshot`

```bash
# 페이지 열기 & 요소 탐색
agent-browser open https://example.com
agent-browser snapshot -i              # @e1, @e2 등 요소 참조 획득

# 폼 입력 & 클릭
agent-browser fill @e1 "user@example.com"
agent-browser click @e3

# 스크린샷 & 데이터 추출
agent-browser screenshot --full        # 전체 페이지 캡처
agent-browser screenshot --annotate    # 요소 번호 오버레이
agent-browser get text @e5             # 텍스트 추출
```

**주요 기능:**

| 기능 | 설명 |
|------|------|
| **스냅샷** | 접근성 트리 기반 요소 참조(`@e1`) — 폼, 버튼, 링크 자동 탐지 |
| **인증** | Auth Vault, 세션 저장, 프로필, 상태 파일 등 5가지 인증 방식 |
| **네트워크** | 요청 추적, HAR 레코딩, 라우트 차단 |
| **디바이스** | 뷰포트 설정, 디바이스 에뮬레이션, iOS 시뮬레이터 |
| **비교** | 스냅샷 diff, 스크린샷 diff, URL 간 비교 |
| **보안** | 도메인 허용 목록, 액션 정책, 콘텐츠 경계 |

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
