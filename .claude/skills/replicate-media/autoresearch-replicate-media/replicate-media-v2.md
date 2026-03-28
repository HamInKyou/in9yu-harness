---
name: replicate-media
description: >
  Replicate API를 활용한 이미지/동영상 에셋 생성 스킬. 자연어 프롬프트로 에셋을 생성하고 로컬 디렉토리에 자동 저장합니다.
  Use when: replicate, 이미지 생성, 이미지 만들어, 그림 그려, 사진 생성, image generate, 동영상 생성, 영상 만들어, 에셋 생성, asset generate
argument-hint: "[자연어 프롬프트] [--dir 저장경로] [--model 모델ID] [--count N]"
allowed-tools: Bash(curl *), Bash(mkdir *), Read, Write
---

# Replicate Media Generator

다음 요청을 처리합니다: $ARGUMENTS

**예시 호출:**
```
/replicate-media cyberpunk city at night         # 이미지 1장 생성 (기본)
/replicate-media 우주 고양이 --count 3            # 3장 생성
/replicate-media 로고 디자인 --dir ./assets       # 저장 경로 지정
/replicate-media 풍경 사진 --model google/imagen-4  # 모델 지정
```

## 동작 규칙

### 1. 인자 파싱

`$ARGUMENTS`에서 다음을 추출합니다:

| 인자 | 기본값 | 설명 |
|------|--------|------|
| 프롬프트 | (필수) | 생성할 에셋의 자연어 설명 |
| `--dir` | `./references` | 저장 디렉토리 경로 |
| `--model` | 자동 선택 | Replicate 모델 ID |
| `--count` | `1` | 생성할 에셋 수 (1~5) |
| `--aspect-ratio` | `1:1` | 이미지 비율 (예: `16:9`, `3:4`) |

### 2. 미디어 타입 판별

사용자 입력에서 자동으로 미디어 타입을 판별합니다:

| 키워드 | 타입 |
|--------|------|
| 이미지, 사진, 그림, 일러스트, 로고, 배경, image, photo, illustration | `image` |
| 동영상, 영상, 비디오, 클립, video, clip | `video` |
| 명시 없음 | `image` (기본값) |

### 3. 모델 선택

`--model`이 지정되지 않으면 미디어 타입에 따라 자동 선택:

| 타입 | 기본 모델 | 비고 |
|------|-----------|------|
| 이미지 | `black-forest-labs/flux-2-pro` | 고품질 기본 모델 |
| 동영상 | `minimax/video-01` | 기본 동영상 모델 (Phase 2) |

### 4. 실행 플로우

#### Step 1: 환경 확인

```bash
# REPLICATE_API_TOKEN 확인
if [ -z "$REPLICATE_API_TOKEN" ]; then
  echo "REPLICATE_API_TOKEN 환경변수가 설정되지 않았습니다."
  echo "https://replicate.com/account/api-tokens 에서 토큰을 발급받으세요."
  echo "설정: export REPLICATE_API_TOKEN=r8_..."
  exit 1
fi
```

토큰이 없으면 사용자에게 안내 메시지를 출력하고 중단합니다.

#### Step 2: 프롬프트 최적화

사용자 입력이 한국어일 경우, 영어로 번역하여 Replicate 프롬프트로 사용합니다.
원문도 함께 보존합니다.

예시:
```
사용자: "네온 빛이 나는 사이버펑크 도시 야경"
→ 프롬프트: "Cyberpunk city nightscape with neon lights, highly detailed, cinematic lighting"
```

#### Step 3: Replicate API 호출 — Prediction 생성

```bash
# 이미지 생성 (flux-2-pro) — Prefer: wait로 동기 호출 (최대 60초 대기)
curl -s -X POST "https://api.replicate.com/v1/predictions" \
  -H "Authorization: Bearer $REPLICATE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Prefer: wait" \
  -d '{
    "version": "black-forest-labs/flux-2-pro",
    "input": {
      "prompt": "생성 프롬프트",
      "aspect_ratio": "1:1",
      "output_format": "webp",
      "output_quality": 90,
      "safety_tolerance": 2
    }
  }'
```

**`Prefer: wait` 헤더**: prediction이 완료될 때까지 동기 대기 (최대 60초). flux-2-pro는 평균 ~20초로 이 방식 사용 가능.
60초 내 완료되지 않으면 polling으로 전환합니다.

> **주의**: `minimax/video-01`(동영상)은 `Prefer: wait`를 지원하지 않습니다. 반드시 polling을 사용하세요.

#### Step 4: Polling (필요한 경우)

`Prefer: wait`으로 완료되지 않았거나, 동영상 등 오래 걸리는 작업의 경우:

```bash
# prediction 상태 확인
curl -s "https://api.replicate.com/v1/predictions/{prediction_id}" \
  -H "Authorization: Bearer $REPLICATE_API_TOKEN"
```

상태값:
- `starting` → 대기 중
- `processing` → 생성 중
- `succeeded` → 완료, `output` 필드에 결과 URL
- `failed` → 실패, `error` 필드 확인
- `canceled` → 취소됨

Polling 전략:
- 5초 간격으로 상태 확인
- 이미지: 최대 2분 timeout
- 동영상: 최대 10분 timeout
- 사용자에게 진행 상태 표시 ("생성 중... (30초 경과)")

#### Step 5: 결과 다운로드 & 저장

```bash
# 저장 디렉토리 생성 (--dir 지정 시 해당 경로, 미지정 시 ./references)
mkdir -p {저장_디렉토리}

# 파일 다운로드 (Authorization 헤더 필요)
curl -s -L \
  -H "Authorization: Bearer $REPLICATE_API_TOKEN" \
  -o "{저장_디렉토리}/{filename}" "{output_url}"
```

> **중요**: `--dir`이 지정된 경우 반드시 해당 경로를 `mkdir -p`와 `curl -o` 모두에 사용합니다. Replicate 출력 URL은 Authorization 헤더가 필요하며, `-L` 플래그로 리다이렉트를 따라갑니다.

**파일명 규칙**: `{timestamp}_{slug}.{ext}`
- `timestamp`: `YYYYMMDD_HHmmss` 형식 (예: `20260327_143052`)
- `slug`: **Step 2에서 번역/최적화한 영어 프롬프트**에서 핵심 단어 2~4개를 추출하여 생성 (공백→하이픈, 소문자, 특수문자 제거, 최대 30자)
- `ext`: 파일 확장자 (이미지: `webp` 또는 `png`, 동영상: `mp4`)

slug 생성 예시:
- 입력: "미니멀 로고 디자인" → 번역: "Minimal logo design, clean..." → slug: `minimal-logo-design`
- 입력: "cyberpunk city at night" → slug: `cyberpunk-city-at-night`
- 입력: "우주 고양이" → 번역: "Space cat in cosmos..." → slug: `space-cat-cosmos`

전체 파일명 예시: `20260327_143052_cyberpunk-city-at-night.webp`

복수 생성 시 접미사 추가: `20260327_143052_space-cat-cosmos_01.webp`, `_02.webp` ...

#### Step 6: 완료 요약 출력

생성 완료 후 다음 정보를 출력합니다:

```
## 에셋 생성 완료

| 항목 | 값 |
|------|-----|
| 모델 | {실제 사용한 모델 ID — --model 지정 시 해당 모델, 미지정 시 기본 모델} |
| 프롬프트 | {Step 2에서 번역/최적화한 영어 프롬프트} |
| 비율 | {사용한 aspect_ratio} |
| 생성 수 | {실제 생성한 수}장 |
| 소요 시간 | {API 호출~다운로드 완료 총 소요 시간}초 |
| 저장 경로 | {--dir 지정 시 해당 경로, 미지정 시 ./references} |
| 예상 비용 | ~${모델별 단가 × 생성 수} |

생성된 파일:
- `{저장_디렉토리}/{파일명_1}`
- `{저장_디렉토리}/{파일명_2}` (복수 생성 시)
```

> **핵심**: 요약 테이블은 실제 사용된 값(--model, --dir, --count)을 정확히 반영해야 합니다. 기본값이 아닌 사용자 지정 값을 표시합니다.

생성된 이미지가 있으면 Read 도구로 이미지를 표시하여 사용자가 결과를 바로 확인할 수 있게 합니다.

### 5. 복수 생성 (--count N)

`--count`가 2 이상인 경우:
- 동일 프롬프트로 N번 개별 API 호출을 실행합니다
- 가능하면 병렬로 호출하여 시간을 단축합니다 (최대 5개)
- 각 결과를 `_01`, `_02` ... 접미사로 저장합니다

### 6. 에러 처리

| 상황 | 대응 |
|------|------|
| `REPLICATE_API_TOKEN` 미설정 | 토큰 발급 안내 메시지 출력 |
| API 401 Unauthorized | 토큰 만료/잘못됨 안내 |
| API 422 Validation Error | 입력 파라미터 오류 — 에러 메시지 표시 후 프롬프트 수정 제안 |
| API 429 Rate Limited | 30초 대기 후 재시도 (최대 2회) |
| Prediction `failed` | 에러 원인 표시 및 대안 모델 제안 |
| Polling timeout | timeout 안내 및 prediction ID 제공 (수동 확인용) |
| 다운로드 실패 | URL 직접 제공 및 수동 다운로드 안내 |

### 7. 주의사항

- **비용**: Replicate API는 유료입니다. 생성 전 모델별 예상 비용을 안내합니다. 상세 가격은 [models-reference.md](models-reference.md) 참조.
- **프롬프트 언어**: Replicate 모델은 영어 프롬프트에 최적화되어 있으므로, 한국어 입력은 자동 번역합니다.
- **파일 크기**: 생성된 파일이 큰 경우 (특히 동영상) 디스크 공간을 확인합니다.
- **NSFW**: 부적절한 콘텐츠 생성 요청은 거부합니다.

## 참고 문서

- [models-reference.md](models-reference.md) — 지원 모델 전체 목록, 가격, 용도별 추천
