# Pinterest UI 플로우 및 인터랙션 패턴

Pinterest(kr.pinterest.com) 자동화를 위한 UI 플로우 가이드입니다.

**중요**: Pinterest는 SPA(Single Page Application)로, 페이지 전환 시 전체 새로고침이 아닌 동적 로딩이 발생합니다. 모든 인터랙션 후 `wait` + `snapshot -i`가 필수입니다.

## 페이지 구조

### 홈 피드 (https://kr.pinterest.com/)
- 로그인 상태: 개인화된 핀 피드
- 비로그인: 로그인/가입 프롬프트

### 검색 결과 (https://kr.pinterest.com/search/pins/?q=키워드)
- Masonry grid 레이아웃으로 핀 표시
- 무한 스크롤로 추가 결과 로드
- 각 핀에 hover 시 저장 버튼 노출

### 핀 상세 (https://kr.pinterest.com/pin/핀ID/)
- 핀 이미지, 설명, 출처 정보
- 저장 버튼 (보드 선택 포함)
- 관련 핀 추천

### 프로필/보드 (https://kr.pinterest.com/username/)
- 사용자의 보드 목록
- 보드 생성 버튼 (`+`)

## 핵심 플로우

### 플로우 1: 보드 생성

```
프로필 페이지 → '+' 버튼 클릭 → '보드' 선택 → 보드 이름 입력 → 생성
```

**상세 단계:**

```bash
# 1. 프로필로 이동
agent-browser --session-name pinterest snapshot -i
# 상단 네비게이션에서 프로필 아이콘/아바타를 찾아 클릭
# 또는 직접 프로필 URL로 이동

# 2. '+' 버튼 찾기
agent-browser --session-name pinterest wait --load networkidle
agent-browser --session-name pinterest snapshot -i
# '+' 아이콘 또는 '만들기' 버튼을 찾아 클릭

# 3. '보드' 옵션 선택 (드롭다운 메뉴가 나타남)
agent-browser --session-name pinterest wait 500
agent-browser --session-name pinterest snapshot -i
# '보드' 메뉴 항목 클릭

# 4. 모달에서 보드 이름 입력
agent-browser --session-name pinterest wait 500
agent-browser --session-name pinterest snapshot -i
# 보드 이름 input 필드에 이름 입력
# 비공개 토글이 있으면 필요시 설정

# 5. '만들기' 버튼 클릭
# 보드 생성 확인
agent-browser --session-name pinterest wait --load networkidle
```

### 플로우 2: 검색 & 이미지 분석 & 핀 저장

```
검색 URL 이동 → 어노테이션 스크린샷 → Claude 이미지 분석 → 매칭 핀만 저장 → (스크롤 반복)
```

**Phase A: 검색 & 이미지 분석**

```bash
# 1. 검색 실행
agent-browser --session-name pinterest open "https://kr.pinterest.com/search/pins/?q=검색어"
agent-browser --session-name pinterest wait --load networkidle
agent-browser --session-name pinterest wait 2000  # 이미지 로드 대기

# 2. 어노테이션 스크린샷 촬영 — 각 핀에 번호 라벨 부여
agent-browser --session-name pinterest screenshot --annotate
# 출력: screenshot.png + 매핑 ([1] @e16 핀 카드, [2] @e17 핀 카드 ...)
# Claude가 이 스크린샷을 보고 요구사항에 맞는 핀을 식별

# 3. (필요 시) 스크롤 후 추가 분석
agent-browser --session-name pinterest scroll down 800
agent-browser --session-name pinterest wait 2000
agent-browser --session-name pinterest screenshot --annotate
```

**Phase B: 매칭된 핀 저장 (검증된 패턴)**

매칭 판정을 받은 핀만 저장합니다. **중요: 매번 snapshot -i로 fresh ref를 얻어야 합니다.**

```bash
# 1. 스냅샷에서 N번째 핀의 ref 동적 추출
agent-browser --session-name pinterest snapshot -i
# grep "핀 페이지" | sed -n "Np" 로 N번째 핀 ref 추출

# 2. 핀 클릭 → 상세 페이지
agent-browser --session-name pinterest click @eN
agent-browser --session-name pinterest wait --load networkidle
agent-browser --session-name pinterest wait 1000

# 3. "저장할 보드 선택" 드롭다운 열기 — ref 동적 추출
agent-browser --session-name pinterest snapshot -i
# grep "저장할 보드 선택" → ref 추출
agent-browser --session-name pinterest click @eN

# 4. 보드 검색창에 보드 이름 입력 → 검색 결과에서 보드 행 클릭
agent-browser --session-name pinterest wait 1000
agent-browser --session-name pinterest snapshot -i
# grep "보드에서 검색" → searchbox ref 추출
agent-browser --session-name pinterest fill @eN "보드이름"
agent-browser --session-name pinterest wait 1000
agent-browser --session-name pinterest snapshot -i
# grep "보드이름 저장" → 보드 행 ref 추출 (내부 "저장" 버튼이 아닌 행 자체)
agent-browser --session-name pinterest click @eN
agent-browser --session-name pinterest wait 1500
# "핀이 저장됨" 버튼이 나타나면 성공

# 5. 검색 결과로 돌아가기
agent-browser --session-name pinterest back
agent-browser --session-name pinterest wait --load networkidle
agent-browser --session-name pinterest wait 1500
# 다음 핀 저장 시 다시 snapshot -i부터 시작 (ref 갱신)
```

**주의사항:**
- `back` 후에는 모든 ref가 무효화됨 — 반드시 `snapshot -i`로 새 ref 획득
- 핀 인덱스는 매번 스냅샷에서 동적으로 추출해야 함
- 이미 저장한 핀은 Pinterest가 "핀이 저장됨" 표시하므로 중복 감지 가능
- **보드 선택 시 반드시 검색창에 보드 이름을 입력하여 검색 후 보드 행을 클릭해야 함** — 내부 "저장" 버튼만 클릭하면 저장되지 않음

### 플로우 3: 검색어 입력 (URL 대신 검색창 사용)

```bash
# 1. 상단 검색창 찾기
agent-browser --session-name pinterest snapshot -i
# 검색 input 필드 찾기 (보통 상단 고정)

# 2. 검색어 입력
agent-browser --session-name pinterest fill @eN "검색어"
agent-browser --session-name pinterest press Enter
agent-browser --session-name pinterest wait --load networkidle
```

URL 직접 이동(`/search/pins/?q=키워드`)이 더 안정적이므로 기본적으로 URL 방식을 사용합니다.

## 스크롤 & 추가 로드

Pinterest는 무한 스크롤을 사용합니다. 더 많은 핀을 보려면:

```bash
# 아래로 스크롤하여 추가 핀 로드
agent-browser --session-name pinterest scroll down 800
agent-browser --session-name pinterest wait 2000  # 이미지 로드 대기
agent-browser --session-name pinterest snapshot -i
```

## Rate Limiting 대응

Pinterest는 자동화 감지 시 속도 제한을 걸 수 있습니다:

- **핀 저장 간 대기**: 1~2초 (`wait 1000` ~ `wait 2000`)
- **키워드 전환 간 대기**: 2~3초
- **연속 저장 한도**: 핀 10개 저장 후 5초 추가 대기
- **CAPTCHA 감지**: 스냅샷에서 CAPTCHA 관련 요소 발견 시 사용자에게 `--headed` 모드로 수동 해결 요청

## 트러블슈팅

### 요소를 찾지 못할 때

Pinterest는 동적 클래스명을 사용하므로 CSS 셀렉터보다 **시맨틱 locator**가 안정적:

```bash
# 텍스트 기반 찾기
agent-browser --session-name pinterest find text "저장" click
agent-browser --session-name pinterest find text "보드 만들기" click

# role 기반 찾기
agent-browser --session-name pinterest find role button click --name "저장"
```

### 모달/오버레이가 뜰 때

```bash
# 모달 닫기
agent-browser --session-name pinterest press Escape
agent-browser --session-name pinterest wait 500
agent-browser --session-name pinterest snapshot -i
```

### 로그인 상태 확인

```bash
agent-browser --session-name pinterest open https://kr.pinterest.com/
agent-browser --session-name pinterest wait --load networkidle
agent-browser --session-name pinterest snapshot -i
# 스냅샷에서 로그인/가입 버튼이 보이면 → 로그인 필요
# 홈 피드가 보이면 → 로그인 상태
```
