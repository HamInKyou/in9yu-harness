# Autoresearch Changelog — replicate-media

## Experiment 0 — baseline

**Score:** 45/60 (75.0%)
**Change:** None — original skill
**Failing outputs:** Korean slug 생성 모호 (3건), Summary가 커스텀 플래그 미반영 (2건), --dir override 불명확 (1건)

## Experiment 1 — keep

**Score:** 51/60 (85.0%)
**Change:** slug를 "번역된 영어 프롬프트에서 핵심 단어 2~4개 추출"로 명시하고, 한국어→slug 예시 3개 추가
**Reasoning:** Filename eval이 한국어 입력 3건에서 모두 FAIL — slug 생성 규칙이 모호했음
**Result:** Filename eval 6/15 → 15/15 (3건 모두 해결). 다른 eval 영향 없음
**Failing outputs:** Summary가 --count/--dir/--model 미반영 (2건), --dir이 download에 미반영 (1건)

## Experiment 2 — keep

**Score:** 60/60 (100.0%)
**Change:** download 경로에 `{저장_디렉토리}` 플레이스홀더 도입 + summary 템플릿을 실제 사용된 값으로 치환하도록 수정 + 비용 표시 추가
**Reasoning:** File Save (--dir 미반영)와 Summary (커스텀 파라미터 미반영)가 남은 실패 원인
**Result:** File Save 12/15 → 15/15, Summary 9/15 → 15/15. 모든 eval 100% 달성
**Failing outputs:** None
