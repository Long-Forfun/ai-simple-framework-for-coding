#!/bin/sh
# design-verify.sh — CỔNG MÁY cho ui-design-logic (anh em với ba-flow-logic/ba-verify.sh
# và ui-ux-triage/triage-verify.sh). Bịt mắt xích yếu: design là skill duy nhất chưa có gate.
# Cơ giới hoá luật "DESIGN-SPEC chưa đủ = chưa được code UI" (skill §pipeline + ref 01 §7 + 07).
#
# PHẠM VI: lint DESIGN-SPEC (oracle GIAO DIỆN), KHÔNG lint code UI.
#   Check px/màu hard-code ở CODE thuộc pre-commit hook của project (ref 07 §5) — cố tình KHÔNG
#   lặp ở đây để tránh "2 cơ chế cùng việc = drift đôi" (chính luật 07 §5 cảnh báo).
#
# BLOCK (exit 1) khi design-spec:
#   - thiếu frontmatter coupling: Load khi / covers / last_verified / ttl_days  (07 §1)
#   - thiếu section "Thang người dùng" (user ladder)  — luật vàng "không design cho user chung chung"
#   - thiếu section "Screen map"  — bảng trung tâm của spec (01 §5)
#   - có heading Screen map nhưng KHÔNG có bảng / bảng 0 dòng dữ liệu  (màn hình rỗng = chưa design)
#   - header Screen map thiếu cột bắt buộc: Vào từ / đến để làm gì / Step tiếp theo / Primary  (01 §4-5)
#   - thiếu section "Ma trận trạng thái" (state matrix)  — màn hình thiếu trạng thái = design một nửa (01 §4)
# WARN (không chặn): thiếu Action→Expectation; thiếu nhắc tới platform/mobile (3 design con, 05);
#   thiếu Flows; chưa thấy bằng chứng screenshot QA (06) — runtime, không đọc được chắc trên đĩa.
#
# DÙNG:
#   sh design-verify.sh            # lint mọi design-spec trong docs/app-map + root DESIGN-SPEC.md
#   sh design-verify.sh --staged   # lint NỘI DUNG ĐÃ STAGE (git show :file) — cho pre-commit
#   sh design-verify.sh --self-test
#
# WIRE VÀO PRE-COMMIT: từ hook template v1.8.0, mục 1d2 TỰ GỌI file này qua junction
#   .claude/skills/ui-design-logic/ (do `ai-simple init` tạo) — không cần wire tay nữa.
#   Project KHÔNG dùng ai-simple: thêm tay vào pre-commit của bạn:
#   if ! sh .claude/skills/ui-design-logic/design-verify.sh --staged; then FAIL=1; fi
# (qua junction → bản global mới nhất; KHÔNG copy thư mục → tránh drift, bài học ai-simple #08/#10.)

set -u
APP_MAP_DIR="${APP_MAP_DIR:-docs/app-map}"
MODE="${1:-all}"

# Vùng frontmatter = từ đầu file tới HEADING `## ` đầu tiên (max 30 dòng) — không kẹt ở head -8.
frontmatter_region() { awk 'NR<=30 && /^## /{exit} NR<=30{print}' "$1"; }

# Body 1 section: các dòng SAU heading `## ...<pat>...` tới heading `## ` kế tiếp (rỗng nếu không có).
sec_of() {
  start=$(grep -niE "^##[^#].*($2)" "$1" 2>/dev/null | head -1 | cut -d: -f1)
  [ -z "$start" ] && return 1
  awk -v s="$start" 'NR>s { if(/^##[^#]/) exit; print }' "$1"
}
has_section() { grep -qiE "^##[^#].*($2)" "$1" 2>/dev/null; }

lint_one() {
  f="$1"; label="${2:-$1}"; [ -f "$f" ] || return 0
  echo "── lint $label"
  rc=0
  FM=$(frontmatter_region "$f")
  echo "$FM" | grep -qiE 'load (khi|when)' || { echo "  BLOCK: thieu 'Load khi/Load when' (frontmatter coupling, 07 §1)"; rc=1; }
  echo "$FM" | grep -qiE '^covers:'        || { echo "  BLOCK: thieu 'covers:' (07 §1 — design-spec la doc de muc nhat, phai co coupling map)"; rc=1; }
  echo "$FM" | grep -qiE '^last_verified:' || { echo "  BLOCK: thieu 'last_verified:'"; rc=1; }
  echo "$FM" | grep -qiE '^ttl_days:'      || { echo "  BLOCK: thieu 'ttl_days:'"; rc=1; }

  # Thang người dùng — luật vàng: không design cho "user chung chung".
  has_section "$f" 'thang người dùng|thang nguoi dung|user ladder' \
    || { echo "  BLOCK: thieu section 'Thang nguoi dung' -> design cho user chung chung (cam, 01 §1)"; rc=1; }

  # Ma trận trạng thái — màn hình thiếu trạng thái = design một nửa.
  has_section "$f" 'ma trận trạng thái|ma tran trang thai|state matrix' \
    || { echo "  BLOCK: thieu section 'Ma tran trang thai' -> man hinh chua dinh nghia trang thai (01 §4)"; rc=1; }

  # Screen map — bảng trung tâm.
  SM=$(sec_of "$f" 'screen map|bản đồ màn hình|ban do man hinh|sơ đồ màn hình')
  if [ $? -ne 0 ] || [ -z "$SM" ]; then
    echo "  BLOCK: thieu section 'Screen map' -> chua liet ke man hinh (01 §5)"; rc=1
  else
    TBL=$(echo "$SM" | grep '^[[:space:]]*|')
    HDR=$(echo "$TBL" | head -1)
    if [ -z "$HDR" ]; then
      echo "  BLOCK: Screen map khong co bang | ... | -> man hinh chua duoc liet ke dang bang"; rc=1
    else
      # cột bắt buộc trên header (01 §4-5): vào từ / đến để làm gì / step tiếp theo / primary action
      # Alias RỘNG theo khái niệm, không bắt đúng từng chữ — BLOCK oan project dogfood vì header
      # viết "Step tiếp mong muốn" thay vì "Step tiếp theo" là FP của cổng, không phải lỗi spec
      # (hội đồng 2026-08-13). Khi thêm alias: thêm cả fixture ở --self-test.
      echo "$HDR" | grep -qiE 'vào từ|vao tu|entry' || { echo "  BLOCK: Screen map thieu cot 'Vao tu' (entry point, 01 §4)"; rc=1; }
      echo "$HDR" | grep -qiE 'làm gì|lam gi|đến để|den de|goal|mục đích|muc dich' || { echo "  BLOCK: Screen map thieu cot 'den de lam gi' (user goal, 01 §4)"; rc=1; }
      echo "$HDR" | grep -qiE 'tiếp theo|tiep theo|step tiếp|step tiep|tiếp mong muốn|tiep mong muon|next step' || { echo "  BLOCK: Screen map thieu cot 'Step tiep theo' (desired next step, 01 §4)"; rc=1; }
      echo "$HDR" | grep -qiE 'primary|hành động chính|hanh dong chinh' || { echo "  BLOCK: Screen map thieu cot 'Primary action' (1 man = 1 primary, 01 §5)"; rc=1; }
      # đếm dòng dữ liệu: bỏ header (dòng 1) + bỏ dòng separator (chỉ | - : space)
      ROWS=$(echo "$TBL" | awk 'NR==1{next} { t=$0; gsub(/[ \t|:-]/,"",t); if(t!="") print }')
      if [ -z "$ROWS" ]; then
        echo "  BLOCK: Screen map co header nhung 0 dong man hinh -> spec rong"; rc=1
      fi
      # Cột Type (nếu có) = ENUM đúng 3 giá trị: product | read | marketing-public (01 §7).
      # Giá trị lạ -> BLOCK: enum là cơ chế phân giải luật theo loại màn, gõ sai là luật áp sai.
      TCOL=$(echo "$HDR" | awk -F'|' '{for(i=1;i<=NF;i++){t=$i; gsub(/^[ \t]+|[ \t]+$/,"",t); if(tolower(t)=="type") print i}}' | head -1)
      if [ -n "$TCOL" ]; then
        BADTYPE=$(echo "$TBL" | awk -F'|' -v c="$TCOL" 'NR==1{next} { t=$0; gsub(/[ \t|:-]/,"",t); if(t=="") next; v=$c; gsub(/^[ \t]+|[ \t]+$/,"",v); if(v!="" && v!="product" && v!="read" && v!="marketing-public") print v }' | sort -u)
        if [ -n "$BADTYPE" ]; then
          echo "  BLOCK: cot Type co gia tri ngoai enum (product|read|marketing-public): $(echo "$BADTYPE" | tr '\n' ' ')(01 §7)"; rc=1
        fi
      fi
    fi
  fi

  # WARN — không chặn (spec nhỏ cho task nhỏ vẫn hợp lệ, nhưng nhắc):
  has_section "$f" 'action.*expectation|hành động.*kỳ vọng|hanh dong.*ky vong' \
    || echo "  WARN: thieu 'Action -> Expectation' (moi hanh dong chinh nen co ky vong, 01 §4)"
  grep -qiE 'mobile|tablet|desktop|platform|ios|android|viewport|responsive' "$f" \
    || echo "  WARN: spec khong nhac platform/mobile -> 3 design con chua duoc xet (05)"
  has_section "$f" 'flow' \
    || echo "  WARN: thieu section 'Flows' (flow map — duong user di, 01 §3)"
  grep -qiE 'screenshot|qa|nghiệm thu|nghiem thu|\.png|\.jpg' "$f" \
    || echo "  WARN: chua thay bang chung screenshot QA (man hinh chua co anh 3 viewport = chua xong, 06)"
  # Contract 08: màn marketing-public đã build thì phải có mục Ngôn ngữ hình (08 §3;
  # nhận cả tên cũ 'Visual fingerprint' — spec viết trước v1.9.0 không bị bắt oan)
  if grep -qi 'marketing-public' "$f" && ! grep -qiE 'ngôn ngữ hình|ngon ngu hinh|visual.?fingerprint' "$f"; then
    echo "  WARN: co man 'marketing-public' nhung thieu muc 'Ngon ngu hinh' (contract 08 §3)"
  fi

  return $rc
}

if [ "$MODE" = "--self-test" ]; then
  RC=0; T=$(mktemp -d) || exit 1
  FM='> Load khi: task chạm UI\ncovers: src/app\nlast_verified: 2026-01-01\nttl_days: 90\n'
  LADDER='## Thang người dùng\n| Loại user | Muốn thấy gì | Truyền tải | Action tiếp |\n|---|---|---|---|\n| Public | demo | x | Đăng ký |\n'
  STATE='## Ma trận trạng thái\n| Màn hình | Chưa login | Trống | Lỗi |\n|---|---|---|---|\n| Dashboard | redirect | onboarding | retry |\n'
  SMHDR='## Screen map\n| # | Màn hình | Vào từ | User đến để làm gì | Step tiếp theo mong muốn | Primary action | Widget | Density |\n|---|---|---|---|---|---|---|---|\n'
  SMROW='| 1 | Dashboard | login | Nắm tình hình | xử lý cảnh báo | + Tạo đơn | metric | M |\n'

  # 1) spec hợp lệ đầy đủ → KHÔNG bị BLOCK
  printf "# DESIGN-SPEC x\n${FM}${LADDER}${SMHDR}${SMROW}${STATE}## Action → Expectation\n| Tạo | thấy detail |\n## Flows\nx\nmobile: bottom tabs\nscreenshot ok\n" > "$T/ok.md"
  R=$(lint_one "$T/ok.md")
  echo "$R" | grep -q BLOCK && { echo "FAIL: spec hop le bi BLOCK oan:"; echo "$R"; RC=1; } || echo "PASS: spec hop le qua het"

  # 2) thiếu Screen map → BLOCK
  printf "# x\n${FM}${LADDER}${STATE}" > "$T/no-sm.md"
  R=$(lint_one "$T/no-sm.md"); echo "$R" | grep -q "thieu section 'Screen map'" && echo "PASS: bat thieu Screen map" || { echo "FAIL: thieu Screen map LOT"; RC=1; }

  # 3) Screen map có header nhưng 0 dòng dữ liệu → BLOCK
  printf "# x\n${FM}${LADDER}${SMHDR}${STATE}" > "$T/empty-sm.md"
  R=$(lint_one "$T/empty-sm.md"); echo "$R" | grep -q "0 dong man hinh" && echo "PASS: bat Screen map 0 dong" || { echo "FAIL: Screen map rong LOT"; RC=1; }

  # 4) header Screen map thiếu cột 'Step tiếp theo' → BLOCK
  SMHDR_BAD='## Screen map\n| # | Màn hình | Vào từ | User đến để làm gì | Primary action | Density |\n|---|---|---|---|---|---|\n'
  printf "# x\n${FM}${LADDER}${SMHDR_BAD}${SMROW}${STATE}" > "$T/bad-col.md"
  R=$(lint_one "$T/bad-col.md"); echo "$R" | grep -q "thieu cot 'Step tiep theo'" && echo "PASS: bat thieu cot Step tiep theo" || { echo "FAIL: thieu cot LOT"; RC=1; }

  # 5) thiếu Ma trận trạng thái → BLOCK
  printf "# x\n${FM}${LADDER}${SMHDR}${SMROW}" > "$T/no-state.md"
  R=$(lint_one "$T/no-state.md"); echo "$R" | grep -q "thieu section 'Ma tran trang thai'" && echo "PASS: bat thieu state matrix" || { echo "FAIL: state matrix LOT"; RC=1; }

  # 6) thiếu frontmatter covers → BLOCK
  printf "# x\n> Load khi: t\nlast_verified: 2026-01-01\nttl_days: 90\n${LADDER}${SMHDR}${SMROW}${STATE}" > "$T/no-covers.md"
  R=$(lint_one "$T/no-covers.md"); echo "$R" | grep -q "thieu 'covers:'" && echo "PASS: bat thieu covers" || { echo "FAIL: thieu covers LOT"; RC=1; }

  # 7) thiếu Thang người dùng → BLOCK
  printf "# x\n${FM}${SMHDR}${SMROW}${STATE}" > "$T/no-ladder.md"
  R=$(lint_one "$T/no-ladder.md"); echo "$R" | grep -q "thieu section 'Thang nguoi dung'" && echo "PASS: bat thieu user ladder" || { echo "FAIL: user ladder LOT"; RC=1; }

  # 8) WARN không được lên BLOCK: spec đủ phần cứng nhưng thiếu Action/Flows/platform → chỉ WARN
  printf "# x\n${FM}${LADDER}${SMHDR}${SMROW}${STATE}" > "$T/warn-only.md"
  R=$(lint_one "$T/warn-only.md")
  if echo "$R" | grep -q BLOCK; then echo "FAIL: phan tuy chon thieu lai len BLOCK:"; echo "$R"; RC=1
  else echo "$R" | grep -q WARN && echo "PASS: thieu phan tuy chon -> chi WARN, khong chan" || { echo "FAIL: khong WARN gi"; RC=1; }; fi

  # 9) marketing-public không có Visual fingerprint → WARN (không BLOCK); có đủ thì im
  printf "# x\n${FM}${LADDER}${SMHDR}${SMROW}| 2 | Landing | marketing-public | seo | đọc | Đăng ký | hero | S |\n${STATE}" > "$T/mkt.md"
  R=$(lint_one "$T/mkt.md")
  if echo "$R" | grep -q "thieu muc 'Ngon ngu hinh'"; then
    echo "$R" | grep -q BLOCK && { echo "FAIL: WARN Ngon ngu hinh keo theo BLOCK oan"; RC=1; } || echo "PASS: marketing-public thieu 'Ngon ngu hinh' -> chi WARN"
  else echo "FAIL: marketing-public thieu 'Ngon ngu hinh' khong WARN"; RC=1; fi

  # 10) alias cột: header kiểu ForFish ("User đến để" / "Step tiếp mong muốn" / "Primary") → KHÔNG BLOCK oan
  SMHDR_FF='## Screen map\n| # | Màn | Vào từ | User đến để | Step tiếp mong muốn | Primary | Density |\n|---|---|---|---|---|---|---|\n'
  SMROW_FF='| 1 | Trang chủ | dock, login | Coi việc cần làm | chạm việc khẩn | (không) | M |\n'
  printf "# x\n${FM}${LADDER}${SMHDR_FF}${SMROW_FF}${STATE}" > "$T/alias.md"
  R=$(lint_one "$T/alias.md")
  echo "$R" | grep -q "BLOCK" && { echo "FAIL: header alias hop le (kieu ForFish) van bi BLOCK:"; echo "$R"; RC=1; } || echo "PASS: alias cot — header 'Step tiep mong muon' qua, het FP dogfood"

  # 11) enum Type: gia tri la ('landing') -> BLOCK; 3 gia tri hop le -> qua; khong co cot Type -> khong soi
  SMHDR_T='## Screen map\n| # | Màn | Type | Vào từ | User đến để làm gì | Step tiếp theo | Primary |\n|---|---|---|---|---|---|---|\n'
  printf "# x\n${FM}${LADDER}${SMHDR_T}| 1 | X | landing | nav | xem | xong | Tạo |\n${STATE}" > "$T/type-bad.md"
  R=$(lint_one "$T/type-bad.md")
  echo "$R" | grep -q "ngoai enum" && echo "PASS: enum Type — 'landing' bi BLOCK (phai la marketing-public)" || { echo "FAIL: enum Type khong bat gia tri la"; RC=1; }
  printf "# x\n${FM}${LADDER}${SMHDR_T}| 1 | X | product | nav | xem | xong | Tạo |\n| 2 | Y | read | nav | đọc | xong | (không) |\n| 3 | Z | marketing-public | seo | đọc | Đăng ký | CTA |\nNgôn ngữ hình: có\n${STATE}" > "$T/type-ok.md"
  R=$(lint_one "$T/type-ok.md")
  echo "$R" | grep -q "ngoai enum" && { echo "FAIL: enum Type bat oan gia tri hop le:"; echo "$R"; RC=1; } || echo "PASS: enum Type — product/read/marketing-public deu qua"

  # v1.11.0 (Lo an toan so 1): mktemp fail tren nhanh --staged (production-facing) PHAI exit 1.
  SELFV="$0"; case "$SELFV" in /*|[A-Za-z]:*) ;; *) SELFV="$(pwd)/$SELFV";; esac
  TS9=$(mktemp -d) || exit 1
  mkdir -p "$TS9/stub" "$TS9/r/docs/app-map"
  printf '#!/bin/sh\nexit 1\n' > "$TS9/stub/mktemp"; chmod +x "$TS9/stub/mktemp"
  ( cd "$TS9/r" && git init -q . && git config user.email t@t.t && git config user.name t \
    && printf 'noi dung sai\n' > docs/app-map/design-spec-x.md && git add -A ) >/dev/null 2>&1
  ( cd "$TS9/r" && PATH="$TS9/stub:$PATH" sh "$SELFV" --staged ) >/dev/null 2>&1; RC9=$?
  [ "$RC9" -ne 0 ] && echo "PASS: mktemp fail nhanh --staged -> exit $RC9 (fail-fast, khong PASS gia)" || { echo "FAIL: mktemp fail nhanh --staged van PASS gia"; RC=1; }
  rm -rf "$TS9"
  rm -rf "$T"
  [ "$RC" -eq 0 ] && echo "design-verify self-test: ALL PASS" || echo "design-verify self-test: CO FAIL"
  exit $RC
fi

if [ "$MODE" = "--staged" ]; then
  FILES=$(git -c core.quotepath=false diff --cached --name-only 2>/dev/null | grep -iE '(design-spec.*\.md|DESIGN-SPEC\.md)$' || true)
  [ -z "$FILES" ] && { echo "design-verify: khong co design-spec staged -> skip (exit 0)"; exit 0; }
  FAIL=0; TMP=$(mktemp) || exit 1
  # Wave 2a [ENFORCED]: while-read thay for-word-split — ten file co DAU CACH/tieng Viet khong bi SKIP
  # im lang; git show fail -> BLOCK fail-closed.
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if ! git show ":$f" > "$TMP" 2>/dev/null; then echo "  BLOCK: khong doc duoc noi dung staged cua '$f'"; FAIL=1; continue; fi
    lint_one "$TMP" "$f" || FAIL=1
  done <<EOF_STAGED
$FILES
EOF_STAGED
  rm -f "$TMP"
  [ "$FAIL" -eq 1 ] && { echo "design-verify: FAIL -> design-spec staged thieu phan bat buoc, KHONG cho commit"; exit 1; }
  echo "design-verify: PASS"; exit 0
fi

FILES=$(find "$APP_MAP_DIR" -maxdepth 2 -name '*.md' 2>/dev/null | grep -iE 'design-spec' || true)
[ -f DESIGN-SPEC.md ] && FILES="$FILES
DESIGN-SPEC.md"
FILES=$(echo "$FILES" | grep -v '^$' || true)
[ -z "$FILES" ] && { echo "design-verify: khong thay design-spec (mode=$MODE) -> skip (exit 0)"; exit 0; }
FAIL=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  lint_one "$f" || FAIL=1
done <<EOF_ALL
$FILES
EOF_ALL
[ "$FAIL" -eq 1 ] && { echo "design-verify: FAIL -> design-spec thieu phan bat buoc, KHONG cho qua"; exit 1; }
echo "design-verify: PASS"
exit 0
