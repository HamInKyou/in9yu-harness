---
name: gh-workflow
description: >
  이슈 기반 개발 워크플로우를 자동화합니다. 이슈 확인→브랜치 생성→작업→커밋→PR 생성까지 원스톱으로 처리합니다.
  Use when: workflow, 워크플로우, 작업 시작, start work, 이슈 작업, 브랜치, branch, PR 만들어
argument-hint: "[issue-number] [options]"
allowed-tools: Bash(gh *), Bash(git *)
---

# GitHub Issue Workflow

이슈 하나를 잡으면 브랜치 생성부터 PR까지 원스톱으로 처리하는 킬러 스킬입니다.

## 현재 컨텍스트

- 레포: !`gh repo view --json nameWithOwner --jq .nameWithOwner`
- 현재 브랜치: !`git branch --show-current`
- 열린 이슈: !`gh issue list --state open --limit 10 --json number,title --jq '.[] | "#\(.number) \(.title)"'`

## 사용법

```
/gh-workflow 1                    # 이슈 #1 작업 시작 (브랜치 생성 + 체크아웃)
/gh-workflow 1 --pr               # 현재 작업을 PR로 생성
/gh-workflow 1 --full             # 브랜치 생성→작업→PR까지 전체 자동화
/gh-workflow pr                   # 현재 브랜치에서 PR 생성 (이슈 자동 감지)
/gh-workflow status               # 현재 워크플로우 상태 확인
```

## 동작 규칙

### 1. 인자 파싱

`$ARGUMENTS`를 분석하여 아래 모드를 판별합니다:

| 패턴 | 모드 |
|------|------|
| 숫자만 (예: `1`, `#42`) | `start` — 이슈 기반 브랜치 생성 + 체크아웃 |
| 숫자 + `--pr` | `pr` — 해당 이슈 작업에 대한 PR 생성 |
| 숫자 + `--full` | `full` — 브랜치→작업→PR 전체 자동화 |
| `pr` | `pr-auto` — 현재 브랜치에서 PR 생성 (이슈 번호 자동 감지) |
| `status`, `상태` | `status` — 현재 워크플로우 상태 |
| 인자 없음 | `select` — 열린 이슈 목록에서 선택 안내 |

### 2. 모드별 실행

#### start (이슈 기반 브랜치 생성)

1. **이슈 확인**:
```bash
gh issue view 이슈번호 --json number,title,body,labels,assignees
```
- 이슈 내용을 요약하여 사용자에게 보여줍니다

2. **브랜치 생성 + 체크아웃**:
```bash
gh issue develop 이슈번호 --checkout
```
- `gh issue develop`가 자동으로 이슈에 연결된 브랜치를 생성합니다
- 브랜치명은 GitHub가 자동 생성 (예: `1-feat-replicate-기반-미디어`)
- 이미 브랜치가 있으면 기존 브랜치로 체크아웃합니다

3. **결과 출력**:
```
## 🚀 작업 시작: #이슈번호 이슈제목

✅ 브랜치 생성: `브랜치명`
✅ 체크아웃 완료

📋 이슈 요약:
[이슈 본문 요약]

---
💡 작업 완료 후:
- `/gh-workflow 이슈번호 --pr` — PR 생성
- `git add . && git commit` — 변경사항 커밋
```

#### pr (PR 생성)

1. **현재 상태 확인**:
```bash
git log main..HEAD --oneline
git diff --stat main
```
- 커밋이 없으면 경고하고 커밋을 먼저 하도록 안내합니다

2. **이슈 정보 조회**:
```bash
gh issue view 이슈번호 --json number,title,body,labels
```

3. **PR 생성**:
```bash
gh pr create --title "PR 제목" --body "PR 본문" --base main
```
- PR 제목: 이슈 제목 기반으로 생성
- PR 본문에 포함할 내용:
  - `Closes #이슈번호` (이슈 자동 닫기 링크)
  - 변경 사항 요약 (커밋 메시지 기반)
  - 이슈 본문에서 추출한 체크리스트
- 이슈에 라벨이 있으면 PR에도 동일 라벨 적용

4. **푸시 + PR 생성**:
```bash
git push -u origin 브랜치명
gh pr create --title "제목" --body "본문" --base main
```

5. **결과 출력**:
```
## 🎉 PR 생성 완료

📌 PR: #PR번호 PR제목
🔗 URL: https://github.com/...
🎫 연결된 이슈: #이슈번호 (자동 닫기 설정됨)

---
💡 다음에 할 수 있는 작업:
- `gh pr view --web` — 브라우저에서 PR 확인
- `/gh-issue close 이슈번호` — 이슈 수동 닫기
- `git checkout main` — main 브랜치로 복귀
```

#### full (전체 자동화)

`start` + 사용자 작업 대기 + `pr`을 순서대로 실행합니다:

1. **start** 단계 실행 (브랜치 생성 + 체크아웃)
2. 이슈 내용을 분석하여 Claude가 자동으로 구현 작업 수행
3. 변경사항 커밋
4. **pr** 단계 실행 (PR 생성)

**주의**: `--full`은 Claude가 자동으로 코드를 작성하므로, 이슈 본문에 구현 방향이 명확히 기술되어 있어야 합니다.

#### pr-auto (현재 브랜치에서 PR 생성)

1. 현재 브랜치명에서 이슈 번호 추출 (예: `1-feat-xxx` → `#1`)
2. 추출 실패 시 사용자에게 이슈 번호를 물어봅니다
3. 이후 `pr` 모드와 동일하게 실행

#### status (워크플로우 상태)

현재 개발 상태를 한눈에 보여줍니다:
```bash
# 현재 브랜치
git branch --show-current

# main과의 차이
git log main..HEAD --oneline

# 변경된 파일
git diff --stat

# 연결된 이슈/PR
gh pr list --head 현재브랜치
```

출력 형식:
```
## 📊 워크플로우 상태

🌿 브랜치: `1-feat-xxx`
📝 커밋: 3개 (main 대비)
📁 변경 파일: 5개
🎫 연결된 이슈: #1
🔄 PR: 없음 (아직 미생성)

---
💡 다음에 할 수 있는 작업:
- `/gh-workflow 1 --pr` — PR 생성
- `/gh-workflow status` — 상태 재확인
```

#### select (인자 없음)

열린 이슈 목록을 보여주고 작업할 이슈를 선택하도록 안내합니다:
```
## 🎫 작업 가능한 이슈

#1 feat: Replicate 기반 미디어 에셋 생성 스킬
#3 fix: 로그인 버그 수정

---
💡 작업을 시작하려면:
- `/gh-workflow 1` — #1 이슈 작업 시작
```

### 3. 에러 처리

- 더티 워킹 트리: 커밋하지 않은 변경사항이 있으면 경고
- 이미 브랜치 존재: 기존 브랜치로 체크아웃 안내
- 푸시 실패: upstream 설정 안내
- 이슈 번호 잘못됨: 열린 이슈 목록 표시

### 4. 한국어/영어 처리

- 사용자 입력은 한국어/영어 모두 지원합니다
- PR 제목/본문은 이슈 언어를 따릅니다
- 시스템 안내 메시지는 한국어로 출력합니다
