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

# GitHub CLI 설치 확인
if ! command -v gh &>/dev/null; then
  echo ""
  echo "GitHub CLI(gh)가 설치되어 있지 않습니다."
  echo ""
  echo "  gh는 다음 스킬들을 사용하기 위해 필요합니다:"
  echo "    - gh-issue    : GitHub 이슈 생성/조회/관리"
  echo "    - gh-project  : GitHub Projects 보드 관리"
  echo "    - gh-triage   : 이슈 분류 및 우선순위 배정"
  echo "    - gh-dashboard: 프로젝트 현황 요약 리포트"
  echo "    - gh-blog     : 개발 일지 자동 작성 (Discussions)"
  echo ""
  read -rp "gh를 설치하시겠습니까? (y/N): " install_gh
  if [[ "${install_gh}" =~ ^[Yy]$ ]]; then
    if command -v brew &>/dev/null; then
      brew install gh
      echo "[OK] GitHub CLI 설치 완료"
    else
      echo "ERROR: Homebrew가 설치되어 있지 않습니다."
      echo "  → https://brew.sh/ 에서 Homebrew를 먼저 설치하거나,"
      echo "  → https://cli.github.com/ 에서 gh를 직접 설치하세요."
    fi
  else
    echo "[SKIP] gh 설치를 건너뜁니다. 나중에 수동 설치 가능합니다."
    echo "  → brew install gh (macOS) 또는 https://cli.github.com/"
  fi
else
  echo "[OK] GitHub CLI 감지됨"

  # gh 인증 확인
  if ! gh auth status &>/dev/null 2>&1; then
    echo "  [WARN] gh 인증이 필요합니다 → gh auth login"
  else
    echo "[OK] gh 인증 확인됨"

    # project 스코프 확인
    if ! gh auth status 2>&1 | grep -q "project"; then
      echo "  [WARN] gh 토큰에 project 스코프가 없습니다."
      echo "  → gh-project 스킬을 사용하려면: gh auth refresh -s project"
    else
      echo "[OK] gh project 스코프 확인됨"
    fi
  fi
fi

# 마켓플레이스 등록
echo ""
echo "--- 마켓플레이스 등록 ---"

claude plugin marketplace add Yeachan-Heo/oh-my-claudecode
claude plugin marketplace add phuryn/pm-skills

# oh-my-claudecode 설치
echo ""
echo "--- oh-my-claudecode (OMC) 설치 ---"

claude plugin install oh-my-claudecode --scope project || echo "  [WARN] oh-my-claudecode 설치 실패 — 수동 설치 필요"

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
  claude plugin install "${plugin}@pm-skills" --scope project || echo "  [WARN] ${plugin} 설치 실패 — 수동 설치 필요"
done

echo ""
echo "=== 셋업 완료 ==="
echo "Claude Code 실행 후 /omc-setup 으로 OMC를 구성하세요."
