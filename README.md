# in9yu-harness

Claude Code 스킬과 에이전트를 중앙 관리하는 하네스 레포. `projects/` 하위에 클론한 다른 레포들이 이를 공유해서 사용한다.

## 구조

```
in9yu-harness/
├── .claude/
│   ├── CLAUDE.md         # 프로젝트 지침 (OMC 포함)
│   ├── settings.json     # Claude Code 설정
│   ├── skills/           # 공유 스킬
│   └── agents/           # 공유 에이전트
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
- [oh-my-claudecode (OMC)](https://github.com/Yeachan-Heo/oh-my-claudecode) 플러그인 설치

### 셋업

Claude Code 실행 후:

```
/omc-setup
```

- `.claude/CLAUDE.md`(프로젝트 설정)는 커밋에 포함되어 있으므로 클론 시 바로 적용된다.
- `/omc-setup` 실행 시 글로벌 설정(`~/.claude/.omc-config.json`), HUD 등이 구성된다.
- 이미 셋업이 완료된 상태라면 "Update CLAUDE.md only"를 선택하면 된다.

### OMC 업데이트 후

OMC 플러그인 업데이트 후에는 `/omc-setup`을 실행해서 CLAUDE.md를 갱신한다.

## 공유 스킬

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

## Git 관리

`.gitignore`에 의해 다음은 추적되지 않는다:

- `.idea/` — IDE 설정
- `.omc/` — OMC 런타임 상태 (세션 데이터, HUD 상태 등)
