#!/bin/sh
# wireframe.html → ../AppScout_Wireframe.pdf (헤드리스 Chrome)
# 폰트는 Projects/Shared/DesignSystem/Resources/Fonts 의 Pretendard를 상대 경로로 읽습니다.
cd "$(dirname "$0")"
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" --headless=new --disable-gpu \
  --no-pdf-header-footer --allow-file-access-from-files --virtual-time-budget=20000 \
  --print-to-pdf="../AppScout_Wireframe.pdf" "file://$(pwd)/wireframe.html" 2>/dev/null
