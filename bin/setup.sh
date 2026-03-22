#!/usr/bin/env bash
set -euo pipefail

echo "=== in9yu-harness 환경 셋업 ==="
echo ""

# Claude Code 설치 확인
if ! command -v claude &>/dev/null; then
  echo "ERROR: Claude Code가 설치되어 있지 않습니다."
  echo "  → https://claude.ai/claude-code 에서 설치하세요."
  exit 1
fi
echo "[OK] Claude Code 감지됨"

# 마켓플레이스 등록
echo ""
echo "--- 마켓플레이스 등록 ---"

claude plugin marketplace add Yeachan-Heo/oh-my-claudecode
claude plugin marketplace add phuryn/pm-skills

# oh-my-claudecode 설치
echo ""
echo "--- oh-my-claudecode (OMC) 설치 ---"

claude plugin install oh-my-claudecode || echo "  [WARN] oh-my-claudecode 설치 실패 — 수동 설치 필요"

echo ""
echo "--- pm-skills 플러그인 설치 ---"

PLUGINS=(
  "pm-product-discovery"
  "pm-product-strategy"
  "pm-execution"
  "pm-market-research"
  "pm-data-analytics"
  "pm-go-to-market"
  "pm-marketing-growth"
  "pm-toolkit"
)

for plugin in "${PLUGINS[@]}"; do
  echo "설치 중: ${plugin}"
  claude plugin install "${plugin}@pm-skills" || echo "  [WARN] ${plugin} 설치 실패 — 수동 설치 필요"
done

echo ""
echo "=== 셋업 완료 ==="
echo "Claude Code 실행 후 /omc-setup 으로 OMC를 구성하세요."
