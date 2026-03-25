# 키워드 추출 전략

자연어 설명에서 Pinterest 검색에 적합한 키워드를 추출하는 전략입니다.

## 추출 파이프라인

```
사용자 입력 (자연어)
    ↓
1. 의도 파악 (무엇을 만들려는지)
    ↓
2. 시각적 속성 추출 (스타일, 색감, 분위기)
    ↓
3. 메인 키워드 생성 (한국어 + 영어)
    ↓
4. 확장 키워드 파생
    ↓
5. 검색 순서 결정
```

## 1단계: 의도 파악

사용자가 만들려는 것의 **카테고리**를 식별합니다:

| 카테고리 | 키워드 힌트 | Pinterest 검색 접미사 |
|----------|-----------|---------------------|
| 웹/앱 디자인 | 웹, 앱, UI, 사이트 | design, UI, web design, app design |
| 인테리어 | 방, 거실, 인테리어, 공간 | interior, room, decor |
| 패션/스타일 | 옷, 코디, 패션, 룩 | fashion, outfit, style, look |
| 그래픽/일러스트 | 포스터, 로고, 그래픽, 일러스트 | graphic design, illustration, poster |
| 사진/촬영 | 사진, 촬영, 포토 | photography, photo, shooting |
| 브랜딩 | 브랜드, 로고, 아이덴티티 | branding, brand identity, logo |
| 건축/공간 | 건물, 건축, 외관, 공간 | architecture, building, exterior |
| 음식/요리 | 음식, 요리, 카페, 베이커리 | food, recipe, cafe, bakery |

## 2단계: 시각적 속성 매핑

감정/분위기 표현을 Pinterest에서 검색 가능한 시각적 키워드로 변환합니다.

### 분위기 → 시각 스타일

| 한국어 표현 | 영어 키워드 | 관련 시각 요소 |
|------------|-----------|--------------|
| 따뜻한, 포근한 | warm, cozy | warm tone, earth tone, soft light |
| 차가운, 시원한 | cool, cold | blue tone, cool palette, crisp |
| 감성적인 | aesthetic, emotional | aesthetic, moody, film grain |
| 깔끔한, 미니멀 | minimal, clean | minimalist, whitespace, simple |
| 레트로, 복고 | retro, vintage | vintage, retro, 70s/80s/90s |
| 모던한, 세련된 | modern, sleek | modern, contemporary, sophisticated |
| 자연스러운 | natural, organic | organic, earthy, botanical |
| 럭셔리, 고급 | luxury, premium | luxury, gold, marble, elegant |
| 귀여운, 아기자기 | cute, playful | kawaii, pastel, whimsical |
| 다크, 무거운 | dark, moody | dark mode, noir, dramatic |
| 밝은, 화사한 | bright, vibrant | bright colors, vivid, colorful |
| 빈티지, 앤틱 | vintage, antique | aged, distressed, classic |

### 소재/질감 → 시각 키워드

| 표현 | 검색 키워드 |
|------|-----------|
| 엽서 | postcard, mail art, correspondence |
| 콜라주 | collage, mixed media, scrapbook |
| 수채화 | watercolor, aquarelle |
| 필름 | film photography, analog, grain |
| 종이, 텍스처 | paper texture, kraft, handmade |
| 네온 | neon, glow, cyberpunk |
| 유리, 투명 | glass, transparent, glassmorphism |

## 3단계: 메인 키워드 생성 규칙

1. **의도 + 스타일 조합**: `"{카테고리} {시각스타일}"` 형태
   - 예: "warm web diary design", "감성 다이어리 UI"

2. **한국어 + 영어 병행**: Pinterest는 영어 검색이 더 풍부하므로 반드시 영어 키워드 포함
   - 한국어 2개 + 영어 3개 = 메인 키워드 5개

3. **구체성 확보**: 너무 넓은 키워드 대신 2~3단어 조합
   - Bad: "design" → Good: "warm tone web design"
   - Bad: "인테리어" → Good: "미니멀 화이트 거실 인테리어"

## 4단계: 확장 키워드 전략

메인 키워드에서 파생:

### 변형 방식

1. **구체화**: 일반적 → 세부적
   - "미니멀 인테리어" → "미니멀 침실", "미니멀 주방", "미니멀 욕실"

2. **유사 대체**: 동의어/관련어
   - "postcard design" → "mail art", "letter design", "correspondence art"

3. **스타일 교차**: 다른 스타일과 조합
   - "warm diary" → "warm scrapbook", "cozy journal layout"

4. **플랫폼 특화**: Pinterest에서 잘 검색되는 표현 추가
   - "inspiration", "aesthetic", "ideas", "inspo" 접미사 추가

### 확장 예시

```
메인: "감성 웹 다이어리 디자인"
확장:
  - "스크랩북 웹 디자인"
  - "다이어리 앱 UI warm"
  - "journal web design cozy"
  - "digital scrapbook aesthetic"
```

## 5단계: 검색 순서 최적화

1. **영어 메인 키워드** 먼저 (결과 풍부)
2. **한국어 메인 키워드** (한국 특화 결과)
3. **영어 확장 키워드** (다양성 확보)
4. **한국어 확장 키워드** (추가 발견)

핀 수가 충분하면 이후 키워드는 스킵합니다.

## 전체 예시

### 입력
> "카페 같은 느낌의 블로그를 만들고 싶어. 브런치 메뉴판 같은 타이포그래피에 따뜻한 우드톤이었으면 좋겠고, 사진도 필름 느낌으로"

### 분석
- **의도**: 웹 디자인 (블로그)
- **시각 속성**: 카페, 브런치, 우드톤(따뜻), 타이포그래피, 필름 사진
- **분위기**: 따뜻, 자연스러운, 빈티지

### 키워드 결과

**메인 키워드** (5개):
1. `"cafe blog web design warm"` — 핵심 의도
2. `"brunch menu typography design"` — 타이포 레퍼런스
3. `"wood tone website design"` — 우드톤 웹 디자인
4. `"카페 블로그 디자인"` — 한국어 검색
5. `"필름 감성 웹디자인"` — 필름 분위기

**확장 키워드** (6개):
1. `"cafe website inspiration cozy"` — 카페 웹 확장
2. `"vintage typography menu"` — 타이포 확장
3. `"warm wood UI design"` — 우드톤 UI
4. `"film photography blog aesthetic"` — 필름 블로그
5. `"카페 메뉴판 디자인"` — 메뉴판 레퍼런스
6. `"브런치 카페 인테리어"` — 공간 분위기 참고

**보드 이름**: `"카페 감성 블로그 레퍼런스"`
