---
name: gh-project
description: >
  GitHub Projects v2를 자연어로 관리합니다. 프로젝트 생성, 보드 조회, 아이템 추가/이동/상태 변경을 지원합니다.
  Use when: gh project, 프로젝트, project, 보드, board, 칸반, kanban, 스프린트, sprint, 상태 변경, status
argument-hint: "[action or natural language description]"
allowed-tools: Bash(gh *)
---

# GitHub Project Manager

GitHub Projects v2를 자연어로 관리하는 스킬입니다. 사용자는 `gh project` 명령어를 알 필요 없습니다.

## 현재 컨텍스트

- 레포: !`gh repo view --json nameWithOwner --jq .nameWithOwner`
- 내 프로젝트: !`gh project list --owner @me --format json --jq '.projects[] | "\(.number): \(.title) (\(.url))"'`

## 사용법

```
/gh-project                                    # 프로젝트 목록 요약
/gh-project create 로드맵                       # 새 프로젝트 생성
/gh-project view 1                             # 프로젝트 #1 아이템 목록
/gh-project add 1 #42                          # 이슈 #42를 프로젝트 #1에 추가
/gh-project move 1 #42 Done                    # 아이템 상태를 Done으로 변경
/gh-project query 1 assignee:me -status:Done   # 필터링 조회
/gh-project fields 1                           # 프로젝트 필드 목록
/gh-project close 1                            # 프로젝트 닫기
```

## 동작 규칙

### 1. 인자 파싱

`$ARGUMENTS`를 분석하여 아래 액션 중 하나를 판별합니다:

| 패턴 | 액션 |
|------|------|
| 인자 없음 | `summary` — 내 프로젝트 목록 요약 |
| `create`, `만들어`, `생성` | `create` |
| `view`, `보기`, `확인`, 또는 숫자만 | `view` |
| `add`, `추가` | `add` |
| `move`, `이동`, `상태 변경`, `status` | `move` |
| `query`, `필터`, `검색` | `query` |
| `fields`, `필드` | `fields` |
| `close`, `닫기` | `close` |
| `delete`, `삭제` | `delete` |
| `edit`, `수정` | `edit` |

### 2. 액션별 실행

#### summary (인자 없음)
위의 "현재 컨텍스트"에 주입된 프로젝트 목록을 분석하여 요약합니다.
프로젝트가 없으면 생성을 안내합니다.

#### create
```bash
gh project create --owner @me --title "프로젝트명"
gh project link 프로젝트번호 --owner OWNER --repo REPO
```
- 자연어에서 프로젝트 제목을 추출합니다
- 생성 후 **현재 레포에 자동 링크**합니다
- 링크 시 `--owner`에는 `@me`가 아닌 실제 유저명(컨텍스트의 레포 owner)을 사용합니다
- 생성 후 프로젝트 번호와 URL을 표시합니다

#### view
```bash
gh project item-list 프로젝트번호 --owner @me --format json --limit 50
```
- 아이템 목록을 상태(Status)별로 그룹핑하여 칸반 스타일로 표시합니다
- 출력 형식:
```
📋 프로젝트: [제목]

🔵 Todo (3)
  - #12 로그인 버그 수정
  - #15 API 문서 업데이트
  - #18 테스트 코드 추가

🟡 In Progress (1)
  - #20 결제 모듈 리팩토링

🟢 Done (5)
  - #10 초기 셋업 완료
  ...
```

#### add
```bash
# 이슈 URL 구성 후 추가
gh project item-add 프로젝트번호 --owner @me --url https://github.com/OWNER/REPO/issues/이슈번호
```
- `#42` 또는 `42` 형태의 이슈 번호를 인식합니다
- 현재 레포 정보를 사용하여 이슈 URL을 자동 구성합니다
- 추가 후 결과를 표시합니다

#### move (상태 변경)
이 액션은 여러 단계를 자동으로 처리합니다:

1. **필드 정보 조회**: `gh project field-list 프로젝트번호 --owner @me --format json`으로 Status 필드의 ID와 옵션 목록을 가져옵니다
2. **아이템 ID 조회**: `gh project item-list 프로젝트번호 --owner @me --format json`에서 해당 이슈의 아이템 ID를 찾습니다
3. **프로젝트 ID 조회**: `gh project view 프로젝트번호 --owner @me --format json --jq .id`
4. **상태 변경 실행**:
```bash
gh project item-edit --id 아이템ID --project-id 프로젝트ID --field-id 필드ID --single-select-option-id 옵션ID
```

- 상태명은 유연하게 매칭합니다:
  - `todo`, `할일`, `백로그` → Todo
  - `진행`, `진행중`, `in progress`, `doing` → In Progress
  - `완료`, `done`, `끝` → Done
  - 기타 커스텀 상태는 가장 유사한 옵션과 매칭

#### query
```bash
gh project item-list 프로젝트번호 --owner @me --query "필터식" --format json
```
- Projects 필터 문법을 지원합니다:
  - `assignee:사용자명`
  - `label:라벨명`
  - `status:상태명`
  - `-status:Done` (제외)
  - `is:issue`, `is:open` 등

#### fields
```bash
gh project field-list 프로젝트번호 --owner @me --format json
```
- 프로젝트의 모든 필드와 옵션을 보기 좋게 표시합니다
- Status 필드의 경우 사용 가능한 상태 옵션 목록을 표시합니다

#### close
```bash
gh project close 프로젝트번호 --owner @me
```
- 닫기 전 프로젝트 제목을 확인하여 사용자에게 보여줍니다

#### delete
```bash
gh project delete 프로젝트번호 --owner @me
```
- **주의**: 삭제는 되돌릴 수 없으므로 실행 전 반드시 사용자에게 확인합니다

#### edit
```bash
gh project edit 프로젝트번호 --owner @me --title "새 제목"
```

### 3. 출력 형식

모든 출력은 다음 형식을 따릅니다:

```
## 📋 [액션 결과]

[결과 내용]

---
💡 다음에 할 수 있는 작업:
- `/gh-project view 1` — 보드 보기
- `/gh-project add 1 #이슈번호` — 아이템 추가
- `/gh-project move 1 #이슈번호 Done` — 상태 변경
```

하단에 항상 관련된 후속 액션을 제안합니다.

### 4. 에러 처리

- `gh` 명령 실패 시 에러 메시지를 한국어로 설명합니다
- 토큰 스코프 부족 시: `gh auth refresh -s project` 안내
- 프로젝트 번호가 잘못된 경우: 프로젝트 목록을 보여주고 선택하게 합니다
- 아이템 ID를 찾지 못한 경우: 프로젝트 아이템 목록을 보여줍니다

### 5. 한국어/영어 처리

- 사용자 입력은 한국어/영어 모두 지원합니다
- 프로젝트 제목은 사용자가 입력한 언어 그대로 사용합니다
- 시스템 안내 메시지는 한국어로 출력합니다
