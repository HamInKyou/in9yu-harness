---
name: gh-blog
description: >
  오늘 작업한 내용을 GitHub Discussions에 블로그로 기록합니다. git 히스토리를 분석해서 양질의 개발 일지를 자동 작성합니다.
  Use when: blog, 블로그, 기록, 일지, 오늘 한 거, 작업 기록, devlog, 기록 남겨, 블로그 써줘
argument-hint: "[topic or date range]"
allowed-tools: Bash(gh *), Bash(git *)
---

# GitHub Blog Writer

오늘 작업한 내용을 GitHub Discussions에 양질의 블로그로 기록하는 스킬입니다.
git 히스토리를 분석하고, 독자가 읽기 좋은 개발 일지를 작성합니다.

## 현재 컨텍스트

- 레포: !`gh repo view --json nameWithOwner --jq .nameWithOwner`
- 오늘 커밋: !`git log --since="midnight" --oneline --no-merges`
- 변경된 파일: !`git log --since="midnight" --no-merges --name-only --pretty=format: | sort -u | head -20`

## 사용법

```
/gh-blog                               # 오늘 작업 기록
/gh-blog 이번 주                        # 이번 주 작업 기록
/gh-blog 2026-03-20..2026-03-23         # 날짜 범위 지정
/gh-blog --draft                        # 초안만 보여주기 (게시 안 함)
```

## 동작 규칙

### 1. 인자 파싱

| 패턴 | 동작 |
|------|------|
| 인자 없음 | 오늘(`--since="midnight"`) 커밋 기반 |
| `이번 주`, `this week` | 이번 주(`--since="1 week ago"`) |
| 날짜 범위 (`YYYY-MM-DD..YYYY-MM-DD`) | 해당 범위 |
| `--draft` | 게시하지 않고 초안만 표시 |

### 2. 작업 흐름

#### Step 1: 데이터 수집

다음 git 명령으로 원본 데이터를 수집합니다:

```bash
# 커밋 로그 (상세)
git log --since="midnight" --no-merges --format="%h %s%n%b---"

# 변경 통계
git log --since="midnight" --no-merges --stat

# 변경된 파일 목록
git log --since="midnight" --no-merges --name-only --pretty=format: | sort -u
```

#### Step 2: 분석 및 구조화

수집된 데이터를 분석하여 다음을 추출합니다:

1. **주제 (What)**: 오늘 무엇을 했는가?
   - 커밋 메시지에서 핵심 작업 추출
   - 관련 커밋을 논리적 그룹으로 묶기

2. **동기 (Why)**: 왜 이 작업을 했는가?
   - 커밋 메시지의 맥락에서 동기 추론
   - 이전 작업과의 연결고리

3. **과정 (How)**: 어떤 과정을 거쳤는가?
   - 시간순 흐름 재구성
   - 문제 발견 → 해결 과정
   - 시도 → 실패 → 수정 패턴 찾기

4. **배운 점 (Learned)**: 무엇을 배웠는가?
   - FIX 커밋에서 교훈 추출
   - 기술적 발견

#### Step 3: 블로그 글 작성

독자가 읽기 좋은 형태로 작성합니다. 다음 원칙을 따릅니다:

**글쓰기 원칙:**
- **구체적으로**: "스킬을 만들었다" ❌ → "gh CLI를 자연어로 감싸는 이슈 관리 스킬을 만들었다" ✅
- **과정을 보여주기**: 결과만이 아닌, 시행착오와 의사결정 과정을 포함
- **코드 예시 포함**: 핵심 코드/명령어는 코드 블록으로 보여주기
- **배운 점 강조**: 독자가 가져갈 수 있는 인사이트
- **한국어로 작성**: 자연스러운 한국어, 기술 용어는 영어 그대로

**글 구조:**

```markdown
## [제목 — 오늘 한 일을 한 문장으로]

### 배경
[왜 이 작업을 했는지. 어떤 문제/필요가 있었는지.]

### 과정

#### [작업 그룹 1 제목]
[무엇을 했고, 어떤 판단을 했고, 어떤 결과가 나왔는지]

#### [작업 그룹 2 제목]
[시행착오가 있었다면 포함. 처음에 X를 시도 → Y 문제 발생 → Z로 해결]

### 결과
[최종 산출물 요약. 코드 구조, 파일 목록 등]

### 배운 것들
[기술적 발견, 도구 사용법, 설계 판단 등 독자가 가져갈 수 있는 것]

---
커밋: [N]개 | 파일: [M]개 | 날짜: [YYYY-MM-DD]
```

#### Step 4: 게시 확인

`--draft`가 아닌 경우:

1. 작성된 글을 사용자에게 보여줍니다
2. "이 내용으로 Discussions에 게시할까요?" 확인을 받습니다
3. 수정 요청이 있으면 반영합니다

#### Step 5: GitHub Discussion 게시

확인을 받은 후 게시합니다:

1. 본문을 임시 파일에 저장
2. GraphQL mutation으로 Discussion 생성:

```bash
BODY=$(cat /tmp/gh-blog-body.md)
gh api graphql \
  -F repositoryId="레포ID" \
  -F categoryId="Show and tell 카테고리ID" \
  -F title="제목" \
  -F body="$BODY" \
  -f query='
mutation($repositoryId: ID!, $categoryId: ID!, $title: String!, $body: String!) {
  createDiscussion(input: {
    repositoryId: $repositoryId,
    categoryId: $categoryId,
    title: $title,
    body: $body
  }) {
    discussion { url }
  }
}'
```

3. 게시된 URL을 표시합니다

**카테고리/레포 ID 조회:**
- 레포 ID: `gh api graphql -f query='{ repository(owner: "OWNER", name: "REPO") { id } }' --jq '.data.repository.id'`
- 카테고리 ID: `gh api graphql -f query='{ repository(owner: "OWNER", name: "REPO") { discussionCategories(first: 10) { nodes { id name } } } }' --jq '.data.repository.discussionCategories.nodes[] | select(.name == "Show and tell") | .id'`
- Discussions가 비활성화 상태면: `gh repo edit --enable-discussions` 실행

### 3. 제목 생성 규칙

제목은 다음 패턴을 따릅니다:
- 날짜 + 핵심 키워드: `[2026-03-23] gh-* 스킬 모듈형 설계 + 테스트`
- 작업이 하나면 구체적으로: `[2026-03-23] GitHub CLI를 자연어로 감싸는 이슈 관리 스킬`
- 작업이 여러 개면 요약: `[2026-03-23] 스킬 5개 구현 + 문서 정리 + 워크플로우 오케스트레이터`

### 4. 에러 처리

- 오늘 커밋이 없으면: "오늘 커밋이 없습니다. 날짜 범위를 지정해주세요." 안내
- Discussions가 비활성화: `gh repo edit --enable-discussions` 자동 실행
- "Show and tell" 카테고리가 없으면: "General" 카테고리 사용

### 5. 한국어/영어 처리

- 블로그 글은 한국어로 작성
- 커밋 메시지가 영어면 한국어로 의역
- 기술 용어 (skill, agent, CLI 등)는 영어 그대로 유지
