#!/bin/bash
# Pinterest 검색 & 핀 저장 — 참조용 템플릿 (의사코드)
# 직접 실행 불가: @eN ref는 매번 snapshot에서 동적으로 추출해야 합니다.
# SKILL.md의 워크플로우 가이드에 따라 Claude가 명령을 조합하여 실행합니다.
#
# 사용법 (참조): ./search-and-pin.sh "검색키워드" "보드이름" [핀수]
# 사전 조건: Pinterest 로그인 세션 + 대상 보드가 존재해야 합니다

set -euo pipefail

KEYWORD="${1:?검색 키워드를 입력하세요}"
BOARD_NAME="${2:?대상 보드 이름을 입력하세요}"
PIN_COUNT="${3:-5}"
SESSION="--session-name pinterest"

echo "=== 키워드 검색: ${KEYWORD} → 보드: ${BOARD_NAME} (${PIN_COUNT}개) ==="

# URL 인코딩된 검색어로 검색 페이지 이동
ENCODED_KEYWORD=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$KEYWORD'))")

echo "[1] 검색 페이지 이동..."
agent-browser $SESSION open "https://kr.pinterest.com/search/pins/?q=${ENCODED_KEYWORD}"
agent-browser $SESSION wait --load networkidle
agent-browser $SESSION wait 2000

echo "[2] 검색 결과 확인..."
agent-browser $SESSION snapshot -i

SAVED=0
ATTEMPTS=0
MAX_ATTEMPTS=$((PIN_COUNT * 3))

while [ $SAVED -lt $PIN_COUNT ] && [ $ATTEMPTS -lt $MAX_ATTEMPTS ]; do
    ATTEMPTS=$((ATTEMPTS + 1))
    echo "[저장 ${SAVED}/${PIN_COUNT}] 핀 선택 시도 #${ATTEMPTS}..."

    # 핀 클릭 (상세 페이지 진입)
    # agent-browser $SESSION click @eN
    agent-browser $SESSION wait --load networkidle
    agent-browser $SESSION snapshot -i

    # 저장 버튼 클릭
    # agent-browser $SESSION click @eN  # '저장' 버튼
    agent-browser $SESSION wait 500
    agent-browser $SESSION snapshot -i

    # 보드 선택
    # agent-browser $SESSION click @eN  # 대상 보드
    agent-browser $SESSION wait 1000

    SAVED=$((SAVED + 1))
    echo "  ✓ 핀 저장 완료 (${SAVED}/${PIN_COUNT})"

    # 검색 결과로 돌아가기
    agent-browser $SESSION back
    agent-browser $SESSION wait --load networkidle
    agent-browser $SESSION wait 1000
    agent-browser $SESSION snapshot -i

    # Rate limiting 대응: 5개마다 추가 대기
    if [ $((SAVED % 5)) -eq 0 ]; then
        echo "  ⏳ Rate limiting 대기 (3초)..."
        agent-browser $SESSION wait 3000
    fi

    # 스크롤하여 새로운 핀 로드
    if [ $((ATTEMPTS % 3)) -eq 0 ]; then
        echo "  📜 스크롤하여 추가 핀 로드..."
        agent-browser $SESSION scroll down 600
        agent-browser $SESSION wait 2000
        agent-browser $SESSION snapshot -i
    fi
done

echo "=== 완료: ${KEYWORD} → ${SAVED}개 핀 저장 ==="
