# Replicate Text-to-Image 모델 레퍼런스

> 2026-03 기준. 가격은 변동될 수 있으므로 각 모델 페이지에서 최신 가격을 확인하세요.

## 가격대별 분류

### 초저가 ($0.01 미만)

| 모델 ID | 가격 | 특징 | 추천 용도 |
|---------|------|------|----------|
| `nvidia/sana-sprint-1.6b` | ~$0.002/img | 원스텝 디퓨전, 초고속 | 프로토타이핑, 대량 생성 |
| `black-forest-labs/flux-schnell` | $0.003/img | FLUX.1 최고속 모델 (638M+ runs) | 빠른 반복, 로컬 테스트 |

### 저가 ($0.01~$0.03)

| 모델 ID | 가격 | 특징 | 추천 용도 |
|---------|------|------|----------|
| `luma/photon` | ~$0.015/img | 초고해상도 출력 | 사진 스타일 이미지 |
| `google/imagen-4-fast` | ~$0.02/img | Google 속도 최적화 | 빠른 반복 + 품질 균형 |
| `black-forest-labs/flux-2-pro` | ~$0.03/1MP | 메가픽셀 과금, JSON 프롬프팅 | **기본 추천 모델** |
| `bytedance/seedream-4` | $0.03/img | 4K 해상도, 스타일 전이 (30M+ runs) | 범용 고품질 |
| `ideogram-ai/ideogram-v3-turbo` | $0.03/img | 그래픽 디자인 + 브랜딩 특화 | 로고, 텍스트 포함 이미지 |

### 중가 ($0.03~$0.06)

| 모델 ID | 가격 | 특징 | 추천 용도 |
|---------|------|------|----------|
| `recraft-ai/recraft-v4` | $0.04/img | 디자인 퍼스트, 통합 텍스트 렌더링 | 디자인 에셋 |
| `google/imagen-4` | ~$0.04/img | Google 주력 모델 (7.9M runs) | 범용 고품질 |
| `bytedance/seedream-4.5` | ~$0.04/img | 영화적 미학, 공간 이해 | 시네마틱 스타일 |
| `openai/gpt-image-1.5` | $0.009~$0.05/img | 품질별 차등 과금, OpenAI 키 필요 | 복잡한 프롬프트 |
| `google/imagen-4-ultra` | ~$0.06/img | Google 최고 품질 | 프로덕션 최종 결과물 |
| `ideogram-ai/ideogram-v3-balanced` | $0.06/img | 속도/품질/비용 균형 | 균형잡힌 품질 |
| `black-forest-labs/flux-2-flex` | ~$0.06/1MP | 텍스트 렌더링 특화, 10개 참조 이미지 | 타이포그래피 |
| `stability-ai/stable-diffusion-3.5-large` | $0.065/img | 다양한 예술 스타일 | 아트 스타일 다양성 |

### 고가 ($0.07 이상)

| 모델 ID | 가격 | 특징 | 추천 용도 |
|---------|------|------|----------|
| `black-forest-labs/flux-2-max` | ~$0.07/1MP | 최고 해상도, 8개 참조 이미지 | 제품 사진, 캐릭터 일관성 |
| `recraft-ai/recraft-v4-svg` | $0.08/img | 네이티브 SVG 벡터 출력 | Figma/Illustrator용 벡터 |
| `ideogram-ai/ideogram-v3-quality` | $0.09/img | 최고 품질 Ideogram | 프로덕션 그래픽 |
| `nvidia/sana` | ~$0.19/run | 4096x4096 초고해상도 | 대형 인쇄물 |
| `recraft-ai/recraft-v4-pro` | $0.25/img | 인쇄 품질 (~2048px) | 인쇄 에셋 |
| `recraft-ai/recraft-v4-pro-svg` | $0.30/img | 프로 SVG, 기하학적 디테일 | 고급 벡터 에셋 |

## 용도별 추천

| 용도 | 추천 모델 | 이유 |
|------|----------|------|
| 빠른 프로토타이핑 | `flux-schnell` | $0.003, 최고속 |
| 범용 (기본) | `flux-2-pro` | $0.03, 품질/가격 균형 |
| 텍스트/로고 포함 | `ideogram-v3-turbo` | 정확한 텍스트 렌더링 |
| 사진 스타일 | `google/imagen-4` | 포토리얼리즘 |
| 디자인 에셋 | `recraft-v4` | 디자인 특화 |
| 시네마틱 | `seedream-4.5` | 영화적 미학 |
| 벡터/SVG | `recraft-v4-svg` | 네이티브 SVG 출력 |
| 대량 생성 | `sana-sprint-1.6b` | $0.002, 초저가 |
| 최고 품질 | `flux-2-max` | 최고 해상도 + 참조 이미지 |

## 참고

- **무료 모델은 없습니다.** Replicate 신규 가입 시 소량의 무료 크레딧이 제공되지만, 모든 모델은 유료입니다.
- **FLUX.2 계열** (pro/max/flex)은 메가픽셀 기반 과금입니다. 1024x1024 (1MP)가 기준이며, 고해상도 출력 시 비용이 비례 증가합니다.
- **GPT Image 1.5**는 별도의 OpenAI API 키가 필요하며, Replicate 인프라 비용 + OpenAI 비용이 합산됩니다.
- 가격 출처: [Replicate Pricing](https://replicate.com/pricing), [BFL Pricing](https://bfl.ai/pricing), [PricePerToken](https://pricepertoken.com/image)
