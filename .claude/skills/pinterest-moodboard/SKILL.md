---
name: pinterest-moodboard
description: >
  Pinterest 무드보드 자동 생성 스킬. 자연어 설명에서 테마/키워드를 추출하고, Pinterest에서 보드 생성 → 검색 → 핀 저장을 자동 수행합니다.
  Use when: pinterest, 핀터레스트, 무드보드, moodboard, 레퍼런스 보드, 영감, inspiration, 핀 모아, 보드 만들어
argument-hint: "[자연어 설명 또는 테마/키워드]"
allowed-tools: Bash(agent-browser:*), Bash(npx agent-browser:*)
user-invocable: true
---

# Pinterest Moodboard Generator

자연어 설명을 받아 Pinterest에서 무드보드를 자동 생성합니다.

**예시 입력:**
- `"미니멀 인테리어, 화이트톤 거실"` (직접 키워드)
- `"나는 웹으로 다이어리를 만들고 싶은데 엽서를 붙이는 느낌이고 감성적이고 따뜻했으면 좋겠어"` (추상적 설명)

## 현재 컨텍스트

- Pinterest URL: https://kr.pinterest.com/
- 세션 이름: `pinterest`
- 기본 핀 수: 25개 (키워드당 5~8개)

## 사용법

```
/pinterest-moodboard 미니멀 인테리어                    # 직접 키워드
/pinterest-moodboard 따뜻하고 감성적인 웹 다이어리 느낌   # 추상적 설명
/pinterest-moodboard login                             # Pinterest 로그인 설정
/pinterest-moodboard boards                            # 내 보드 목록 확인
```

## 동작 규칙

### 1. 인자 파싱

| 패턴 | 액션 |
|------|------|
| `login`, `로그인` | `login` — Pinterest 로그인 및 세션 저장 |
| `boards`, `보드 목록`, `내 보드` | `list-boards` — 기존 보드 목록 조회 |
| 그 외 모든 텍스트 | `create-moodboard` — 무드보드 생성 |

### 2. 액션별 실행

#### login — Pinterest 로그인 설정

Pinterest 자동화를 위해 최초 1회 로그인이 필요합니다.

**방법 A: 기존 브라우저에서 세션 가져오기 (추천)**

사용자가 이미 Pinterest에 로그인된 Chrome이 있는 경우:

```bash
# 1. 사용자에게 Chrome을 remote debugging 모드로 실행하도록 안내
# macOS: "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --remote-debugging-port=9222

# 2. 세션 가져오기
agent-browser --auto-connect state save ./pinterest-auth.json
agent-browser --session-name pinterest state load ./pinterest-auth.json

# 3. 로그인 확인
agent-browser --session-name pinterest open https://kr.pinterest.com/
agent-browser --session-name pinterest wait --load networkidle
agent-browser --session-name pinterest snapshot -i
```

**방법 B: 직접 로그인**

```bash
# 1. headed 모드로 Pinterest 열기
agent-browser --session-name pinterest --headed open https://kr.pinterest.com/

# 2. 스냅샷으로 로그인 버튼 찾기
agent-browser --session-name pinterest snapshot -i

# 3. 로그인 버튼 클릭 → 이메일/비밀번호 입력 → 로그인
# (스냅샷의 @ref를 사용하여 인터랙션)

# 4. 로그인 성공 확인
agent-browser --session-name pinterest wait --load networkidle
agent-browser --session-name pinterest get url
```

로그인 후 세션은 `--session-name pinterest`로 자동 유지됩니다.

#### list-boards — 보드 목록 조회

```bash
agent-browser --session-name pinterest open https://kr.pinterest.com/
agent-browser --session-name pinterest wait --load networkidle
# 프로필 페이지로 이동하여 보드 목록 확인
agent-browser --session-name pinterest snapshot -i
# 보드 이름과 핀 수를 추출하여 표시
```

#### create-moodboard — 무드보드 생성 (핵심 워크플로우)

**Step 1: 자연어 분석 → 키워드 추출**

사용자 입력을 분석하여 다음을 추출합니다:

1. **보드 이름**: 테마를 대표하는 짧은 한국어 이름 (예: "감성 웹 다이어리 레퍼런스")
2. **메인 키워드**: 핵심 검색어 3~5개
3. **확장 키워드**: 메인 키워드에서 파생된 관련 검색어 2~3개씩

추출 규칙:
- 추상적 설명 → 구체적이고 Pinterest에서 검색 가능한 키워드로 변환
- 한국어 + 영어 키워드 모두 생성 (Pinterest는 영어 검색이 더 풍부)
- 감정/분위기 표현 → 시각적 스타일 키워드로 변환
  - "따뜻한" → "warm tone", "웜톤 인테리어"
  - "감성적인" → "aesthetic", "감성 디자인"
  - "깔끔한" → "minimal", "clean design"
  - "레트로" → "retro", "vintage aesthetic"

**예시: 자연어 → 키워드 변환**

```
입력: "나는 웹으로 다이어리를 만들고 싶은데 엽서를 붙이는 느낌이고 감성적이고 따뜻했으면 좋겠어"

보드 이름: "감성 웹 다이어리 레퍼런스"
메인 키워드:
  - "web diary design aesthetic"
  - "digital journal warm tone"
  - "postcard collage design"
  - "감성 다이어리 디자인"
  - "엽서 콜라주 웹디자인"
확장 키워드:
  - "scrapbook web design"
  - "warm UI design inspiration"
  - "vintage postcard layout"
  - "journal app design cozy"
```

**Step 2: Pinterest 보드 생성**

```bash
# 1. Pinterest 홈으로 이동
agent-browser --session-name pinterest open https://kr.pinterest.com/
agent-browser --session-name pinterest wait --load networkidle

# 2. 프로필 페이지로 이동 (보드 생성은 프로필에서)
agent-browser --session-name pinterest snapshot -i
# 프로필 아이콘/링크를 찾아 클릭

# 3. 보드 만들기 버튼 클릭
agent-browser --session-name pinterest wait --load networkidle
agent-browser --session-name pinterest snapshot -i
# '+' 버튼 또는 '보드 만들기' 버튼 찾기

# 4. 보드 이름 입력
agent-browser --session-name pinterest snapshot -i
# 보드 이름 입력 필드에 이름 입력
# 비공개 설정 (선택사항)

# 5. 보드 생성 확인
agent-browser --session-name pinterest wait --load networkidle
agent-browser --session-name pinterest get url
```

**Step 3: 키워드별 검색 & 이미지 분석 & 핀 저장**

각 키워드에 대해 반복. **핵심: 검색 결과를 시각적으로 분석하여 요구사항에 맞는 핀만 선별 저장합니다.**

```bash
# 1. Pinterest 검색
agent-browser --session-name pinterest open "https://kr.pinterest.com/search/pins/?q=검색키워드"
agent-browser --session-name pinterest wait --load networkidle
agent-browser --session-name pinterest wait 2000
```

**3-A: 검색 결과 이미지 분석 (핵심 단계)**

```bash
# 2. 어노테이션이 달린 스크린샷 촬영 — 각 핀에 번호 라벨이 붙음
agent-browser --session-name pinterest screenshot --annotate
# 출력: screenshot.png + 번호-ref 매핑 (예: [1] @e16 핀 카드, [2] @e17 핀 카드 ...)
```

스크린샷을 Claude가 직접 분석하여 다음 기준으로 핀을 평가합니다:

- **시각적 매칭**: 사용자가 요청한 스타일/분위기/색감/소재와 일치하는가?
- **품질**: 해상도가 충분하고, 레퍼런스로 쓸 만한 퀄리티인가?
- **다양성**: 이미 선택한 핀과 너무 유사하지 않은가?

분석 결과 예시:
```
검색 결과 분석:
- [1] @e16 ✓ 수채화 라인 드로잉, 유럽 마을 풍경 — 매칭
- [2] @e17 ✗ 사진, 일러스트 아님 — 스킵
- [3] @e18 ✓ 잉크 라인 + 수채 채색, 파리 거리 — 매칭
- [4] @e19 ✗ 디지털 일러스트, 동화풍 아님 — 스킵
- [5] @e20 ✓ 동화책 스타일, 유럽 건축 — 매칭
```

**3-B: 매칭된 핀만 선택 저장**

매칭 판정을 받은 핀만 저장합니다. 각 핀에 대해:

**중요: 핀이 화면 밖에 있으면 클릭이 안 될 수 있음. 필요 시 `scroll down 600`으로 핀을 뷰포트에 노출시킨 후 클릭.**

```bash
# 1. 핀 클릭 (상세 페이지 진입) — 스냅샷에서 동적으로 ref 추출
agent-browser --session-name pinterest snapshot -i
# grep으로 N번째 "핀 페이지" 링크의 ref 추출
# (핀이 화면 밖이면 먼저 scroll down 600 후 re-snapshot)
agent-browser --session-name pinterest click @eN
agent-browser --session-name pinterest wait --load networkidle
agent-browser --session-name pinterest wait 1000

# 2. 보드 선택 드롭다운 열기 — "저장할 보드 선택" 버튼의 ref를 동적 추출
agent-browser --session-name pinterest snapshot -i
# grep "저장할 보드 선택" → ref 추출
agent-browser --session-name pinterest click @eN  # 보드 선택 드롭다운

# 3. 보드 검색으로 대상 보드 찾기 (핵심 개선: 검색 활용)
agent-browser --session-name pinterest wait 1000
agent-browser --session-name pinterest snapshot -i
# "보드에서 검색" searchbox의 ref 추출
agent-browser --session-name pinterest fill @eN "보드이름키워드"  # 보드 이름의 일부를 검색
agent-browser --session-name pinterest wait 1000
agent-browser --session-name pinterest snapshot -i
# 검색 결과에서 대상 보드의 "저장" 버튼 ref 추출
agent-browser --session-name pinterest click @eN  # 보드 저장 버튼
agent-browser --session-name pinterest wait 1500

# 4. 검색 결과로 돌아가기
agent-browser --session-name pinterest back
agent-browser --session-name pinterest wait --load networkidle
agent-browser --session-name pinterest wait 1500
```

> **보드 검색 팁**: 드롭다운에 `searchbox "보드에서 검색"`이 있음. 보드 이름의 핵심 키워드 1~2단어를 입력하면 보드를 빠르게 찾을 수 있음. 보드 목록을 스크롤할 필요 없음.

**3-C: 추가 탐색 (핀이 부족할 경우)**

한 화면에서 매칭되는 핀이 부족하면 스크롤하여 추가 탐색:

```bash
# 스크롤 → 새 핀 로드 → 다시 어노테이션 스크린샷 → 분석
agent-browser --session-name pinterest scroll down 800
agent-browser --session-name pinterest wait 2000
agent-browser --session-name pinterest screenshot --annotate
# 새로 로드된 핀들을 다시 분석
```

키워드당 목표 핀 수에 도달하거나, 3회 스크롤 후에도 매칭이 부족하면 다음 키워드로 이동합니다.

**Step 4: 결과 보고**

모든 핀 저장 완료 후:

```bash
# 보드 페이지로 이동하여 결과 확인
agent-browser --session-name pinterest open "https://kr.pinterest.com/보드URL"
agent-browser --session-name pinterest wait --load networkidle
agent-browser --session-name pinterest screenshot --full
```

결과를 사용자에게 보고:
- 보드 이름 및 URL
- 사용한 검색 키워드 목록
- 키워드별 저장 핀 수 및 분석/스킵 통계
- 보드 스크린샷

### 3. 핀 선택 전략 — 이미지 분석 기반

검색 결과에서 핀을 선택할 때 **반드시 시각적 분석을 거칩니다**:

1. **어노테이션 스크린샷 촬영**: `screenshot --annotate`로 번호가 매겨진 스크린샷 획득
2. **Claude 이미지 분석**: 스크린샷을 보고 각 핀이 사용자 요구사항에 맞는지 판단
3. **선별 저장**: 매칭 판정을 받은 핀만 저장 — 순서대로 무작정 저장하지 않음
4. **다양성 확보**: 유사한 구도/색감의 핀이 이미 있으면 스킵
5. **키워드당 3~6개**: 분석을 통해 질 높은 핀만 저장, 총 20~25개 목표
6. **스크롤 탐색**: 한 화면에서 매칭이 부족하면 스크롤 후 재분석

**분석 기준 체크리스트** (사용자 요구사항에서 자동 생성):

사용자 입력에서 다음 요소를 추출하여 체크리스트로 사용합니다:
- **스타일**: 일러스트/사진/그래픽/3D 등
- **기법**: 수채화/유화/디지털/라인드로잉/콜라주 등
- **색감**: 웜톤/쿨톤/파스텔/비비드/모노크롬 등
- **주제/소재**: 무엇을 그린 것인지
- **분위기**: 감성적/모던/레트로/귀여운 등

예시:
```
요구사항: "라인 일러스트 + 수채화 색감 + 유럽 여행 + 동화풍"

체크리스트:
☑ 라인 드로잉/잉크 라인이 보이는가?
☑ 수채화 느낌의 색감인가? (투명하고 번지는 질감)
☑ 유럽 풍경/건축/거리가 소재인가?
☑ 동화책/그림책 같은 아기자기한 분위기인가?
☐ 사진이거나 순수 디지털 일러스트면 스킵
```

### 4. 에러 처리

| 상황 | 대응 |
|------|------|
| 로그인 세션 만료 | 사용자에게 `/pinterest-moodboard login` 안내 |
| 검색 결과 없음 | 키워드를 영어로 변환하여 재검색 |
| 저장 버튼 못 찾음 | 스냅샷을 다시 찍고 다른 셀렉터 시도 |
| 보드 생성 실패 | 에러 메시지 확인 후 사용자에게 보고 |
| Pinterest에서 차단 | 대기 시간 추가 후 재시도 |

### 5. 주의사항

- **rate limiting**: 핀 저장 사이에 1~2초 대기하여 Pinterest 차단 방지
- **세션 관리**: 항상 `--session-name pinterest` 사용
- **re-snapshot**: 페이지 이동/변경 후 반드시 `snapshot -i`로 새 ref 획득
- **headed 모드**: 디버깅 시 `--headed` 추가하여 브라우저 동작 확인 가능

### 6. 출력 형식

```
## Pinterest 무드보드 생성 완료!

**보드**: [보드이름](보드URL)
**테마**: 사용자 입력 요약

### 사용 키워드
| # | 키워드 | 저장 핀 수 |
|---|--------|-----------|
| 1 | web diary design aesthetic | 6 |
| 2 | digital journal warm tone | 5 |
| ... | ... | ... |

**총 핀 수**: 25개

---
다음에 할 수 있는 작업:
- `/pinterest-moodboard boards` — 내 보드 목록 확인
- 보드에 직접 핀 추가하기: [보드 열기](보드URL)
```

## 참고 문서

| 문서 | 내용 |
|------|------|
| [references/pinterest-flow.md](references/pinterest-flow.md) | Pinterest UI 플로우 및 인터랙션 패턴 |
| [references/keyword-extraction.md](references/keyword-extraction.md) | 자연어 → 키워드 추출 전략 |
