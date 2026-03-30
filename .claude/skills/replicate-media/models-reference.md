# Replicate 모델 레퍼런스

## 모델 탐색

모델 선택이 필요할 때 **[Replicate Explore](https://replicate.com/explore)** 페이지를 `WebFetch`로 탐색하세요.
이 문서에 모델을 하드코딩하지 않습니다 — 모델과 가격은 수시로 변동되므로 원천 소스를 직접 확인하는 것이 정확합니다.

### 탐색 방법

1. **카테고리 탐색**: `https://replicate.com/collections/text-to-image` — 이미지 생성 모델 모음
2. **개별 모델 확인**: `https://replicate.com/{owner}/{model}` — 가격, 파라미터, 예시 확인
3. **인기순 정렬**: Explore 페이지에서 runs 수 기준으로 정렬하면 검증된 모델을 찾을 수 있음

### 모델 선택 기준

| 기준 | 확인할 것 |
|------|----------|
| 가격 | 모델 페이지의 `Pricing` 섹션 — per-prediction 또는 per-megapixel |
| 품질 | 모델 페이지의 `Examples` 탭에서 출력 샘플 확인 |
| 속도 | 모델 페이지의 평균 실행 시간 (cold start vs warm) |
| 인기도 | runs 수 — 많을수록 안정적이고 검증됨 |

### 기본 모델

`--model`이 지정되지 않으면 `black-forest-labs/flux-2-pro`를 사용합니다.
사용자가 다른 모델을 원하면, Explore 페이지를 탐색하여 용도에 맞는 모델을 추천하세요.

### 주의사항

- **무료 모델은 없습니다.** Replicate 신규 가입 시 소량의 무료 크레딧이 제공되지만, 모든 모델은 유료입니다.
- **FLUX.2 계열** (pro/max/flex)은 메가픽셀 기반 과금입니다. 1024x1024 (1MP)가 기준이며, 고해상도 출력 시 비용이 비례 증가합니다.
- **OpenAI 모델** (`openai/gpt-image-1` 등)은 별도의 OpenAI API 키가 필요하며, Replicate가 프록시 역할을 하고 OpenAI 계정에 직접 과금됩니다.
