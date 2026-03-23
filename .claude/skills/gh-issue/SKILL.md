---
name: gh-issue
description: >
  GitHub 이슈를 자연어로 관리합니다. 이슈 생성, 조회, 수정, 닫기, 코멘트, 검색을 지원합니다.
  Use when: gh issue, 이슈, issue, 버그, bug, feature request, 기능 요청, 이슈 만들어, 이슈 목록, 이슈 닫아, 이슈 확인
argument-hint: "[action or natural language description]"
allowed-tools: Bash(gh *)
---

# GitHub Issue Manager

GitHub 이슈를 자연어로 관리하는 스킬입니다. 사용자는 `gh` 명령어를 알 필요 없습니다.

## 현재 컨텍스트

- 레포: !`gh repo view --json nameWithOwner --jq .nameWithOwner`
- 열린 이슈: !`gh issue list --state open --limit 20 --json number,title,labels,assignees,createdAt`
- 사용 가능한 라벨: !`gh label list --json name --jq '[.[].name] | join(", ")'`

## 사용법

```
/gh-issue                              # 열린 이슈 요약
/gh-issue 로그인 버그 수정 필요            # 이슈 생성 (자연어)
/gh-issue create 제목 --label bug        # 이슈 생성 (명시적)
/gh-issue list                          # 이슈 목록
/gh-issue list label:bug                # 라벨 필터링
/gh-issue view 42                       # 이슈 상세 보기
/gh-issue close 42                      # 이슈 닫기
/gh-issue edit 42 라벨 추가: enhancement  # 이슈 수정
/gh-issue comment 42 수정 완료했습니다     # 코멘트 추가
/gh-issue search 로그인                  # 이슈 검색
```

## 동작 규칙

### 1. 인자 파싱

`$ARGUMENTS`를 분석하여 아래 액션 중 하나를 판별합니다:

| 패턴 | 액션 |
|------|------|
| 인자 없음 | `summary` — 열린 이슈 요약 표시 |
| `create`, `만들어`, `생성`, 또는 이슈 제목으로 보이는 텍스트 | `create` |
| `list`, `목록`, `ls` | `list` |
| `view`, `보기`, `확인`, 또는 숫자만 | `view` |
| `close`, `닫기`, `닫아` | `close` |
| `reopen`, `다시 열어` | `reopen` |
| `edit`, `수정`, `변경` | `edit` |
| `comment`, `코멘트`, `댓글` | `comment` |
| `search`, `검색`, `찾아` | `search` |
| `delete`, `삭제` | `delete` |

### 2. 액션별 실행

#### summary (인자 없음)
위의 "현재 컨텍스트"에 주입된 열린 이슈 목록을 분석하여 다음을 출력합니다:
- 총 열린 이슈 수
- 이슈별 한줄 요약 (번호, 제목, 라벨, 담당자)
- 라벨별 분류

#### create
```bash
gh issue create --title "제목" --body "본문" [--label 라벨] [--assignee 담당자]
```
- 자연어에서 제목, 본문, 라벨, 담당자를 추론합니다
- 라벨은 "현재 컨텍스트"의 사용 가능한 라벨 목록에서 매칭합니다
- 본문이 명시되지 않으면 제목에서 적절한 본문을 생성합니다
- 생성 후 이슈 번호와 URL을 표시합니다

#### list
```bash
gh issue list [--state open|closed|all] [--label 라벨] [--assignee 담당자] [--limit N]
```
- 기본: 열린 이슈 20개
- `label:bug` → `--label bug`
- `closed` → `--state closed`
- `all` → `--state all`
- 결과를 테이블 형태로 정리하여 표시합니다

#### view
```bash
gh issue view 번호 --json number,title,body,state,labels,assignees,comments,createdAt,updatedAt
```
- 이슈 내용을 읽기 좋게 포맷팅합니다
- 코멘트가 있으면 최근 5개를 함께 표시합니다

#### close
```bash
gh issue close 번호 [--reason "completed"|"not planned"|"duplicate"] [--comment "닫는 이유"]
```
- 닫는 이유가 제공되면 코멘트로 남깁니다
- 닫기 전 이슈 제목을 확인하여 사용자에게 보여줍니다

#### reopen
```bash
gh issue reopen 번호 [--comment "다시 여는 이유"]
```

#### edit
```bash
gh issue edit 번호 [--title "새 제목"] [--body "새 본문"] [--add-label 라벨] [--remove-label 라벨] [--add-assignee 담당자]
```
- 자연어에서 변경 사항을 추론합니다
- 예: "42번 라벨 bug 추가" → `gh issue edit 42 --add-label bug`

#### comment
```bash
gh issue comment 번호 --body "코멘트 내용"
```

#### search
```bash
gh issue list --search "검색어" [--state all]
```
- 기본적으로 모든 상태(open + closed)에서 검색합니다

#### delete
```bash
gh issue delete 번호 --yes
```
- **주의**: 삭제는 되돌릴 수 없으므로 실행 전 반드시 사용자에게 확인합니다

### 3. 출력 형식

모든 출력은 다음 형식을 따릅니다:

```
## 🎫 [액션 결과]

[결과 내용]

---
💡 다음에 할 수 있는 작업:
- `/gh-issue view 번호` — 상세 보기
- `/gh-issue comment 번호 내용` — 코멘트 추가
```

하단에 항상 관련된 후속 액션을 제안합니다.

### 4. 에러 처리

- `gh` 명령 실패 시 에러 메시지를 한국어로 설명합니다
- 인증 문제: `gh auth login`을 안내합니다
- 권한 문제: 필요한 권한을 안내합니다
- 이슈 번호 누락: 열린 이슈 목록을 보여주고 선택하게 합니다

### 5. 한국어/영어 처리

- 사용자 입력은 한국어/영어 모두 지원합니다
- 이슈 제목/본문은 사용자가 입력한 언어 그대로 사용합니다
- 시스템 안내 메시지는 한국어로 출력합니다
