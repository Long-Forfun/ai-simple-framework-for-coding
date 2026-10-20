#!/bin/sh
# ui-lane.sh — CLASSIFIER lane cho task UI (hội đồng 2026-08-13: "cost router phải là SCRIPT
# xuất 1 token, không phải prose" — 2 người đọc cùng 1 đoạn prose router cho 2 kết quả khác nhau
# trên cùng 40 commit; luật tất định thì không cãi được).
#
# Đọc diff STAGED (mặc định) hoặc stdin (--stdin, dạng `git diff --cached --name-status`),
# xuất ĐÚNG 1 token ở dòng stdout cuối:
#   NOUI  — không chạm file UI/spec → ui-design-logic không cần vào
#   LANE1 — sửa nhỏ trong budget    → đi thẳng; checklist 06 mini + screenshot màn bị chạm
#   LANE2 — thêm màn/route/spec đổi → design-spec delta TRƯỚC khi code (design-verify chặn); ref 01
#   LANE3 — đổi hệ                  → token/theme toàn cục hoặc diện rộng: RED theo 07 §4, 1 câu confirm
#
# LUẬT TẤT ĐỊNH (áp theo thứ tự, dừng ở luật khớp đầu tiên):
#   1. Đụng token/theme toàn cục (globals.css / token*.css / tailwind.config.*) → LANE3
#      (đứng TRƯỚC check NOUI: tailwind.config.ts không phải file UI nhưng là đổi hệ)
#   2. Không có file UI (.tsx/.jsx/.vue/.svelte/.css) và không có design-spec  → NOUI
#   3. > 8 file UI trong diff (diện rộng)                                       → LANE3
#   4. File page/route/screen MỚI (status A) hoặc design-spec trong diff        → LANE2
#   5. Còn lại (sửa component/style cục bộ)                                     → LANE1
#
# DÙNG:
#   sh ui-lane.sh                 # phân lane diff đã stage
#   sh ui-lane.sh --explain       # kèm lý do + read-list ra stderr (stdout vẫn chỉ 1 token)
#   git diff --cached --name-status | sh ui-lane.sh --stdin
#   sh ui-lane.sh --self-test
set -u
MODE="${1:-}"

UI_RE='\.(tsx|jsx|vue|svelte|css)$'
TOKEN_RE='(^|/)globals\.css$|(^|/)tokens?[^/]*\.css$|(^|/)tailwind\.config\.'
SPEC_RE='design-spec[^/]*\.md$|(^|/)DESIGN-SPEC\.md$'
PAGE_RE='(^|/)(page|layout|route)\.(tsx|jsx)$|(^|/)(pages|routes|screens|views)/[^/]*\.(tsx|jsx|vue|svelte)$'

# classify <name-status lines "A\tpath" | "M\tpath" ...> → in 1 token
classify() {
  NS="$1"
  PATHS=$(printf '%s\n' "$NS" | awk 'NF>=2{print $2}')
  if printf '%s\n' "$PATHS" | grep -qE "$TOKEN_RE"; then echo LANE3; return; fi
  UI=$(printf '%s\n' "$PATHS" | grep -E "$UI_RE" || true)
  HAS_SPEC=0; printf '%s\n' "$PATHS" | grep -qE "$SPEC_RE" && HAS_SPEC=1
  if [ -z "$UI" ] && [ "$HAS_SPEC" -eq 0 ]; then echo NOUI; return; fi
  N=$(printf '%s\n' "$UI" | grep -c . || true)
  if [ "$N" -gt 8 ]; then echo LANE3; return; fi
  ADDED=$(printf '%s\n' "$NS" | awk '$1=="A"{print $2}')
  if printf '%s\n' "$ADDED" | grep -qE "$PAGE_RE"; then echo LANE2; return; fi
  if [ "$HAS_SPEC" -eq 1 ]; then echo LANE2; return; fi
  echo LANE1
}

explain() {
  case "$1" in
    NOUI)  echo "NOUI: khong file UI/spec nao trong diff -> ui-design-logic dung ngoai." >&2 ;;
    LANE1) echo "LANE1 (sua nho): doc 06 §2 checklist muc lien quan; screenshot man bi cham o viewport chinh + mobile (06 §1 task nho). KHONG doc ca 8 reference." >&2 ;;
    LANE2) echo "LANE2 (them man/hanh vi): CAP NHAT design-spec truoc khi code (01 §8; design-verify --staged se chan neu thieu); doc 01 + 02 cho man moi; du ma tran screenshot 3 viewport (06 §1)." >&2 ;;
    LANE3) echo "LANE3 (doi he): RED theo 07 §4 -> 1 cau confirm gop truoc khi lam; token doi thi lift vao globals/spec cung commit (04 §5); doc 04 + 07." >&2 ;;
  esac
}

if [ "$MODE" = "--self-test" ]; then
  RC=0
  t() { # t <mong đợi> <name-status lines>
    GOT=$(classify "$2")
    if [ "$GOT" = "$1" ]; then echo "PASS: $1 <- [$(printf '%s' "$2" | tr '\n' ';')]"
    else echo "FAIL: mong $1, ra $GOT <- [$(printf '%s' "$2" | tr '\n' ';')]"; RC=1; fi
  }
  t NOUI  "$(printf 'M\tsrc/lib/api.ts\nM\tREADME.md')"
  t LANE3 "$(printf 'M\tsrc/app/globals.css')"
  t LANE3 "$(printf 'M\ttailwind.config.ts')"
  t LANE3 "$(printf 'M\ta1.tsx\nM\ta2.tsx\nM\ta3.tsx\nM\ta4.tsx\nM\ta5.tsx\nM\ta6.tsx\nM\ta7.tsx\nM\ta8.tsx\nM\ta9.tsx')"
  t LANE2 "$(printf 'A\tsrc/app/orders/page.tsx')"
  t LANE2 "$(printf 'M\tdocs/app-map/07-design-spec.md')"
  t LANE1 "$(printf 'M\tsrc/components/Button.tsx')"
  t LANE1 "$(printf 'A\tsrc/components/Badge.tsx')"           # component mới ≠ màn mới
  t LANE1 "$(printf 'M\tsrc/components/cart-sheet.tsx\nM\tsrc/lib/orders.ts')"  # UI + logic lẫn: theo phần UI
  t LANE3 "$(printf 'M\tsrc/styles/tokens.css')"
  [ "$RC" -eq 0 ] && echo "ui-lane self-test: ALL PASS" || echo "ui-lane self-test: CO FAIL"
  exit $RC
fi

if [ "$MODE" = "--stdin" ]; then NS=$(cat); else NS=$(git diff --cached --name-status 2>/dev/null || true); fi
LANE=$(classify "$NS")
[ "$MODE" = "--explain" ] && explain "$LANE"
echo "$LANE"
exit 0
