---
name: image-prompt-craft
description: >
  이미지 생성 AI를 위한 프롬프트 크래프팅 스킬. 자연어 설명을 체계적인 영어 프롬프트로 변환합니다.
  Use when: 프롬프트 만들어, 프롬프트 작성, 이미지 프롬프트, prompt craft, image prompt, 프롬프팅, prompting, 프롬프트 도와줘, 프롬프트 최적화
argument-hint: "[이미지 설명] [--style 스타일] [--mood 분위기] [--camera 구도] [--purpose 용도] [--negative 제외요소]"
---

# Image Prompt Crafter

사용자의 자연어 설명을 이미지 생성 AI에 최적화된 영어 프롬프트로 변환합니다.

다음 요청을 처리합니다: $ARGUMENTS

## 인자 파싱

`$ARGUMENTS`에서 다음을 추출합니다:

| 인자 | 기본값 | 설명 |
|------|--------|------|
| 설명 | (필수) | 생성하고 싶은 이미지의 자연어 설명 |
| `--style` | 자동 추론 | 미술 사조/스타일 (예: `minimalism`, `cyberpunk`, `watercolor`) |
| `--mood` | 자동 추론 | 분위기 (예: `dreamy`, `dramatic`, `peaceful`) |
| `--camera` | 자동 추론 | 카메라 구도 (예: `close-up`, `wide shot`, `bird's eye`) |
| `--purpose` | 없음 | 용도 (예: `blog`, `thumbnail`, `poster`, `sns`, `presentation`) |
| `--negative` | 없음 | 제외할 요소 (예: `text`, `people`, `watermark`) |

명시되지 않은 옵션은 사용자 설명의 맥락에서 가장 적합한 값을 자동 추론합니다.

## 프롬프트 구조화 — 4단계 프레임워크

사용자 입력을 다음 4단계 구조로 변환합니다. **좌측이 가장 중요하고, 우측으로 갈수록 보조적입니다.**

```
[1. 주제 + 비주얼 타입] + [2. 세부 묘사] + [3. 스타일 + 분위기] + [4. 품질 + 제약]
```

### 1단계: 주제 + 비주얼 타입

핵심 피사체와 매체를 명확히 정의합니다.

- **주제**: 무엇을 그릴 것인가 — 구체적인 명사와 동작
- **비주얼 타입**: photograph, illustration, 3D render, concept art, flat design 등

> 나쁜 예: "고양이 그림" → 좋은 예: "A cat sitting on a windowsill, digital illustration"

### 2단계: 세부 묘사

장면을 구성하는 시각 요소를 구체적으로 나열합니다.

- **배경/환경**: 장소, 시간대, 날씨
- **색상/팔레트**: 주요 색상, 색감 톤
- **조명**: 빛의 방향, 강도, 색온도
- **카메라 구도**: 앵글, 거리, 초점
- **질감/재질**: 표면 느낌, 소재

> 키워드 나열이 긴 문장보다 안정적입니다.

### 3단계: 스타일 + 분위기

시각적 톤을 결정하는 스타일 키워드를 추가합니다.

- **미술 사조**: Impressionism, Surrealism, Pop Art 등
- **참고 작가**: 특정 아티스트의 화풍 (선택)
- **분위기**: dreamy, dramatic, serene, energetic 등
- **기법**: impasto, sfumato, dry brush 등 (선택)

> 스타일 키워드는 2~4개가 적절합니다. 과하면 충돌합니다.

### 4단계: 품질 + 제약

최종 품질과 제한 사항을 명시합니다.

- **품질 부스터**: highly detailed, 8K, sharp focus 등 (1~2개만)
- **네거티브**: 제외 요소 (텍스트 없음, 워터마크 없음 등)
- **용도별 제약**: 블로그용이면 가로형+여백 확보, 썸네일이면 중앙 집중 구도

## 용도별 프리셋 (--purpose)

`--purpose`가 지정되지 않은 경우에도 웹 에셋 기본값을 적용합니다:
- 반드시 `no text, no watermark` 포함
- 16:9 비율 기본 적용 (정사각형 피사체가 아닌 경우)
- 배경/풍경류는 `seamless composition` 또는 `negative space for content overlay` 중 하나 포함

`--purpose`가 지정되면 다음 제약을 자동 추가합니다:

| 용도 | 자동 추가 요소 |
|------|----------------|
| `blog` | 가로형(16:9), 여백 확보, 깔끔한 구성, no text |
| `thumbnail` | 16:9, 중앙 집중 구도, high contrast, volumetric lighting, shallow depth of field, subject popping from background |
| `poster` | 세로형(2:3), 상단 여백(텍스트 영역), 드라마틱 조명 |
| `sns` | 정사각형(1:1), 밝고 선명한 색감, 눈에 띄는 구성 |
| `presentation` | 가로형(16:9), 미니멀, 플랫 디자인, 밝은 톤, icon-driven |
| `icon` | 정사각형(1:1), single object, centered, clean vector style, no shadow, 아이콘 스타일 가이드 섹션 참조 |
| `app-icon` | 정사각형(1:1), rounded square, single bold symbol, gradient fill, iOS/Android icon design, sharp focus |
| `logo` | 정사각형(1:1), scalable, clean lines, vector art, no background, 로고 스타일 가이드 섹션 참조 |
| `game-asset` | 용도에 맞는 비율, concept art style, game-ready, 게임 에셋 가이드 섹션 참조 |
| `banner` | 가로형(16:9), negative space for text overlay, hero product/subject, studio lighting, professional |
| `mockup` | 용도에 맞는 비율, product photography, studio lighting, clean background, photorealistic render |
| `wallpaper` | 가로형(16:9), 고해상도, 몰입감 있는 장면 |
| `infographic` | 가로형(16:9), flat design, clean layout, icon hierarchy, balanced whitespace, corporate palette |

## 출력 포맷

다음 형식으로 결과를 출력합니다:

```
## 이미지 프롬프트 결과

### 프롬프트 분석

| 항목 | 값 |
|------|-----|
| 원본 입력 | {사용자 원문} |
| 주제 | {추출한 핵심 주제} |
| 비주얼 타입 | {선택한 매체} |
| 스타일 | {적용한 스타일} |
| 분위기 | {적용한 무드} |
| 구도 | {적용한 카메라/구도} |
| 용도 | {--purpose 값 또는 "범용"} |

---

### ✅ 추천 프롬프트

{영어 프롬프트 — 바로 복사해서 사용 가능한 형태}

### 🚫 네거티브 프롬프트

{제외 요소 — 없으면 기본값: "blurry, low quality, distorted, watermark, text, signature"}

---

### 🎨 변형 제안

**1. 안전한 버전** (Safe) — 깔끔하고 예측 가능한 결과
{변형 프롬프트}

**2. 창의적 버전** (Creative) — 독특하고 예술적인 해석
{변형 프롬프트}

**3. 극적인 버전** (Dramatic) — 강렬하고 임팩트 있는 연출
{변형 프롬프트}

---

### 🚀 바로 생성하기

replicate-media 스킬로 바로 생성하려면:
\`\`\`
/replicate-media {추천 프롬프트} --aspect-ratio {용도에 맞는 비율}
\`\`\`
```

## 에셋 특화 가이드

`--purpose`가 디자인/에셋 관련일 때 다음 가이드를 적용합니다.

### 아이콘 (`--purpose icon`, `app-icon`)

**프롬프트 구조**: `[비주얼 타입] + [단일 오브젝트] + [스타일] + [배경/제약]`

- 단일 오브젝트, 중앙 배치가 핵심 — 복잡한 장면 금지
- 아이콘 세트 일관성을 위해 **Style Lock 기법** 사용: 스타일 파라미터를 고정하고 오브젝트만 교체
- 앱 아이콘: `rounded square`, `squircle`, `gradient fill`, `iOS icon design`
- UI 아이콘: `24px grid`, `2px stroke`, `rounded caps`, `pixel-perfect`

Style Lock 템플릿 예시:
```
flat vector icon, [오브젝트], solid fill #2563EB, rounded corners,
no gradient, no shadow, white background, pixel-perfect, 1:1
```

피해야 할 조합: `photorealistic icon`, `minimal + highly detailed`

### 로고 (`--purpose logo`)

**프롬프트 구조**: `[로고 타입] + [형태/심볼] + [스타일] + [배경/제약]`

- 텍스트 렌더링은 AI가 불안정 → 심볼/마크 위주로 생성, 텍스트는 디자인 툴에서 추가
- 확장성(scalability) 키워드 필수: `vector art`, `clean lines`, `scalable`
- 배경: `white background` 또는 `transparent background`

로고 타입별 키워드:
- 미니멀: `minimalist logo, geometric, clean lines, Swiss design`
- 엠블럼: `emblem, badge logo, circular, intricate linework`
- 추상 마크: `abstract mark, geometric shapes, bold silhouette`

### UI 컴포넌트

UI 에셋 생성 시 **디자인 언어**를 사용합니다. 아트 용어를 쓰지 않습니다.

| 피하기 | 대신 사용 |
|--------|-----------|
| beautiful, fantasy, painting | interface, layout, component, Figma |
| artistic, colorful | design system, Material 3, HIG |
| dramatic, emotional | clean navigation, structured, interactive |

디자인 시스템 이름을 명시하면 구조/간격/계층이 즉시 개선됩니다:
`Material 3 design system`, `Apple HIG style`, `Carbon Design System`

### 게임 에셋 (`--purpose game-asset`)

**프롬프트 구조**: `[에셋 타입] + [스타일] + [디테일] + [분위기/조명] + [품질]`

- 일관성 확보: 프롬프트 템플릿 고정 후 변수 하나씩 교체
- 3D 모델 변환 목적이면 `clean white background` 또는 `transparent background`
- 스타일 태그: `low-poly`, `pixel art`, `cel-shaded`, `anime style`, `hand-painted`
- 품질 태그: `game-ready`, `professional game asset`, `concept art`

에셋 타입별 키워드:
- 캐릭터: `character sprite, orthographic view, full body, transparent background`
- 배경: `environment art, parallax background, side-scroll`
- 아이템: `game item, item sprite, isolated, modular asset`

### 마케팅 배너 (`--purpose banner`)

**프롬프트 구조**: `[이미지 타입] + [주 피사체] + [배경] + [여백/구도] + [스타일/조명]`

- **텍스트 공간 예약** 필수: `negative space on the right for text overlay`
- 텍스트는 이미지 생성 후 Figma/Canva에서 추가 (AI의 문자 렌더링 불안정)
- 비율 명시: 배너(16:9), 리타게팅(1:1 또는 4:5)

### 제품 목업 (`--purpose mockup`)

**프롬프트 구조**: `[제품 타입] + [소재/재질] + [뷰 앵글] + [배경] + [조명] + [렌더 스타일]`

- 소재 키워드가 핵심: `frosted glass`, `kraft paper`, `brushed metal`, `matte coating`
- 뷰 앵글: `front-facing`, `45-degree angle`, `isometric view`, `overhead flat lay`
- 전자상거래: `product shot, pure white background, Amazon main image style`

### 인포그래픽 (`--purpose infographic`)

- AI는 실제 데이터 수치를 정확히 표현 못함 → 비주얼 레이아웃 레퍼런스로만 생성
- 스타일: `flat design`, `minimalist`, `icon-driven`, `corporate palette`
- 차트 유형 명시: `timeline`, `flowchart`, `comparison chart`, `funnel diagram`

## 프롬프트 작성 규칙

### 핵심 원칙

1. **40단어 이내** — 추천 프롬프트는 반드시 40단어 이내로 작성. 키워드 나열이 문장보다 안정적. 중복/유사 키워드 제거. "clean and uncluttered" 대신 "clean"만, "soft volumetric lighting with gentle glow" 대신 "soft volumetric glow"로 압축
2. **충돌 방지** — "flat이면서 3D", "minimal이면서 highly detailed" 같은 모순 배제
3. **우선순위 배치** — 중요한 요소일수록 프롬프트 앞부분에 위치
4. **영어 출력** — 이미지 생성 AI는 영어 프롬프트에 최적화됨
5. **2~4개 스타일** — 스타일 키워드는 2~4개가 최적, 과하면 품질 저하
6. **품질 부스터 최대 1개** — highly detailed, 8K, sharp focus 등 품질 키워드는 1개만 사용. 여러 개 쓰면 효과 없이 단어만 낭비

### 피해야 할 패턴

| 피하기 | 이유 |
|--------|------|
| 긴 문장으로 설명 | 키워드 나열이 더 안정적 |
| 모순 스타일 조합 | 결과물이 혼란스러워짐 |
| 과도한 품질 키워드 | 2개 이상이면 효과 미미 |
| 추상적 감정 표현 | "슬픔을 느끼는 풍경" → 구체적 시각 요소로 변환 |
| 한국어 프롬프트 그대로 | 반드시 영어로 변환 |

### 한국어 → 영어 변환 시 주의

- 한국어의 뉘앙스를 영어 시각 키워드로 정확히 변환
- "감성적인" → ethereal, soft, dreamy (맥락에 따라 선택)
- "깔끔한" → clean, minimal, uncluttered
- "화려한" → vibrant, ornate, elaborate (맥락에 따라 선택)
- 문화적 맥락이 필요한 경우 보충 키워드 추가
- **사용 맥락도 시각 키워드로 변환** — 입력에 포함된 사용 맥락(온보딩, 랜딩, 대시보드 등)은 분위기 키워드로 반영해야 함
  - "온보딩" → welcoming, friendly, approachable, inviting
  - "랜딩페이지" → hero, impactful, attention-grabbing
  - "대시보드" → professional, structured, data-driven

## 참고 문서

- [prompt-reference.md](prompt-reference.md) — 스타일, 구도, 조명, 기법 등 전체 레퍼런스 사전. 프롬프트에 사용할 정확한 영어 키워드를 찾을 때 참조합니다.
