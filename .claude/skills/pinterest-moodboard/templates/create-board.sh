#!/bin/bash
# Pinterest 보드 생성 — 참조용 템플릿 (의사코드)
# 직접 실행 불가: @eN ref는 매번 snapshot에서 동적으로 추출해야 합니다.
# SKILL.md의 워크플로우 가이드에 따라 Claude가 명령을 조합하여 실행합니다.
#
# 사용법 (참조): ./create-board.sh "보드이름"
# 사전 조건: Pinterest 로그인 세션이 설정되어 있어야 합니다

set -euo pipefail

BOARD_NAME="${1:?보드 이름을 입력하세요}"
SESSION="--session-name pinterest"

echo "=== Pinterest 보드 생성: ${BOARD_NAME} ==="

# 1. Pinterest 홈으로 이동
echo "[1/5] Pinterest 홈 이동..."
agent-browser $SESSION open https://kr.pinterest.com/
agent-browser $SESSION wait --load networkidle

# 2. 프로필 페이지 이동 (보드 관리를 위해)
echo "[2/5] 프로필 페이지 이동..."
agent-browser $SESSION snapshot -i
# 프로필 아이콘을 찾아 클릭 (스냅샷에서 ref 확인 필요)
# agent-browser $SESSION click @eN

# 3. '+' 보드 만들기 버튼 클릭
echo "[3/5] 보드 만들기 메뉴 열기..."
agent-browser $SESSION wait --load networkidle
agent-browser $SESSION snapshot -i
# '+' 버튼 또는 '만들기' 버튼 찾아 클릭
# agent-browser $SESSION click @eN
# '보드' 옵션 선택
# agent-browser $SESSION wait 500
# agent-browser $SESSION snapshot -i
# agent-browser $SESSION click @eN

# 4. 보드 이름 입력
echo "[4/5] 보드 이름 입력: ${BOARD_NAME}"
agent-browser $SESSION wait 500
agent-browser $SESSION snapshot -i
# 보드 이름 input 필드에 이름 입력
# agent-browser $SESSION fill @eN "$BOARD_NAME"

# 5. 생성 버튼 클릭
echo "[5/5] 보드 생성 확인..."
# agent-browser $SESSION click @eN  # '만들기' 버튼
agent-browser $SESSION wait --load networkidle

# 결과 확인
BOARD_URL=$(agent-browser $SESSION get url)
echo "=== 보드 생성 완료 ==="
echo "URL: ${BOARD_URL}"
