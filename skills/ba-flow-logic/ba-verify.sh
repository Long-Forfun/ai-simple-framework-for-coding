#!/bin/sh
# ba-verify.sh — CỔNG MÁY cho ba-flow-logic (anh em với ui-ux-triage/triage-verify.sh).
# Cơ giới hoá luật "nghiệp vụ/AC vẽ ra mà không test được = chưa xong" (ai-simple #04 + #08).
#
# BLOCK (exit 1) khi ba-spec:
#   - thiếu frontmatter coupling: Load khi / covers / last_verified / ttl_days
#   - không có AC nào (0 acceptance criteria)
#   - một AC thiếu `Test:` trên header (e2e|integration|unit|manual)
#   - một AC thiếu dòng `Assert` (điểm đo được)
#   - AC chứa tên component UI tiếng Anh (button/sidebar/popup/modal…) — anti-UI luật vàng
# WARN (không chặn): AC chứa từ UI tiếng Việt mơ hồ (màu/tab/góc…); Assert chưa định lượng.
#
# DÙNG:
#   bash ba-verify.sh            # lint mọi ba-spec trong docs/app-map (đọc trên đĩa)
#   bash ba-verify.sh --staged   # lint NỘI DUNG ĐÃ STAGE (git show :file) — cho pre-commit
#   bash ba-verify.sh --self-test
#
# WIRE VÀO PRE-COMMIT (chặn thật) — thêm vào .githooks/pre-commit của project:
#   if ! sh .claude/skills/ba-flow-logic/ba-verify.sh --staged; then FAIL=1; fi
# (qua junction → bản global mới nhất; KHÔNG copy thư mục → tránh drift, bài học #08/#10.)

set -u
APP_MAP_DIR="${APP_MAP_DIR:-docs/app-map}"
MODE="${1:-all}"

# Component UI tiếng Anh — KHÔNG bao giờ xuất hiện hợp lệ trong AC hành vi → BLOCK
UI_BLOCK='button|sidebar|navbar|dropdown|tooltip|popup|modal|placeholder|scrollbar|checkbox|breadcrumb'
# UI tiếng Việt TÍN-HIỆU-CAO (yêu cầu cụm để tránh trùng domain: "nút giao thông", "màu sơn", "bấm giờ") → WARN
UI_WARN='màn hình|kéo thả|nút bấm|bấm nút|nhấn nút|thanh cuộn|click chuột|cửa sổ popup|góc (phải|trái|trên|dưới) màn|#[0-9a-fA-F]{3,6}'

# Vùng frontmatter = từ đầu file tới HEADING `## ` đầu tiên (max 30 dòng) — không kẹt ở head -8
frontmatter_region() { awk 'NR<=30 && /^## /{exit} NR<=30{print}' "$1"; }

lint_one() {
  f="$1"; label="${2:-$1}"; [ -f "$f" ] || return 0
  echo "── lint $label"
  rc=0
  FM=$(frontmatter_region "$f")
  echo "$FM" | grep -qiE 'load (khi|when)' || { echo "  BLOCK: thieu 'Load khi/Load when'"; rc=1; }
  echo "$FM" | grep -qiE '^covers:'        || { echo "  BLOCK: thieu 'covers:'"; rc=1; }
  echo "$FM" | grep -qiE '^last_verified:' || { echo "  BLOCK: thieu 'last_verified:'"; rc=1; }
  echo "$FM" | grep -qiE '^ttl_days:'      || { echo "  BLOCK: thieu 'ttl_days:'"; rc=1; }

  NAC=$(grep -cE '^###[ \t]*AC' "$f" 2>/dev/null); NAC=${NAC:-0}
  if ! [ "$NAC" -gt 0 ] 2>/dev/null; then
    echo "  BLOCK: ba-spec khong co AC nao (0 acceptance criteria) -> nghiep vu chua test duoc"; rc=1
  fi

  # mỗi AC (Wave 2a — kiểm NỘI DUNG, không chỉ hình thức; nhãn per-assertion):
  #   ENFORCED: Test: ∈ enum · AC-ID duy nhất · đúng MỘT cụm Given/When/Then
  #   DETECTED (WARN, cấm nâng BLOCK — heuristic ngôn ngữ, án lệ design-verify BLOCK oan): Assert định lượng
  OUT=$(awk '
    function flush() {
      if (name=="") return
      if (hdr !~ /[Tt]est[ \t]*:/) print "  BLOCK: " name " -> thieu Test: tren header (e2e|integration|unit|manual)"
      else if (hdr !~ /[Tt]est[ \t]*:[ \t]*(e2e|integration|unit|manual)([^A-Za-z0-9-]|$)/) print "  BLOCK: " name " -> Test: ngoai enum {e2e,integration,unit,manual}"
      if (!asrt)                   print "  BLOCK: " name " -> thieu dong Assert (diem do duoc bang may)"
      else if (aval==0)            print "  WARN: " name " -> Assert co the chua dinh luong (them == / <= / >= / count / trang-thai-dat-ten)"
      if (g!=1 || w!=1 || t!=1)    print "  BLOCK: " name " -> can dung MOT cum Given/When/Then (hien Given:" g " When:" w " Then:" t ")"
    }
    /^###[ \t]*AC/ {
      flush(); name=$0; hdr=$0; asrt=0; aval=0; g=0; w=0; t=0
      id=$2; if (seen[id]++) print "  BLOCK: " $0 " -> AC-ID \x27" id "\x27 TRUNG voi AC truoc (ID phai duy nhat)"
      next
    }
    /^#/           { flush(); name=""; next }
    {
      if (name=="") next
      if ($0 ~ /^[-*> \t]*\**[Gg]iven\**[ \t]/) g++
      if ($0 ~ /^[-*> \t]*\**[Ww]hen\**[ \t]/)  w++
      if ($0 ~ /^[-*> \t]*\**[Tt]hen\**[ \t]/)  t++
      if ($0 ~ /^[-*> \t]*\**[Aa]ssert\**/) {
        asrt=1
        if ($0 ~ /(==|<=|>=|<|>|[0-9]|"|status|count|trạng thái|số lượng)/) aval=1
      }
    }
    END { flush() }
  ' "$f")
  [ -n "$OUT" ] && echo "$OUT"
  echo "$OUT" | grep -q BLOCK && rc=1

  # ENFORCED (Wave 2a): "Maps to: <ID>" trên header AC → TỪNG ID phải tồn tại chỗ khác trong file
  # (định nghĩa flow/nghiệp vụ). Không có "Maps to:" thì KHÔNG bắt — không phải spec nào cũng dùng.
  MAPIDS=$(grep -E '^###[ \t]*AC' "$f" | grep -oiE 'Maps to:[ \t]*[^·|]*' | sed 's/^[Mm]aps to:[ \t]*//' | tr ',' '\n' | sed 's/^ *//; s/ *$//' | grep -v '^$' | sort -u)
  if [ -n "$MAPIDS" ]; then
    while IFS= read -r mid; do
      [ -n "$mid" ] || continue
      NDEF=$(grep -v '^###[ \t]*AC' "$f" | grep -cE "(^|[^A-Za-z0-9])$mid([^A-Za-z0-9]|$)")
      if [ "$NDEF" -eq 0 ] 2>/dev/null; then
        echo "  BLOCK: Maps to: '$mid' khong ton tai trong file -> Flow-ID phai co dinh nghia (bang nghiep vu / section Flow)"; rc=1
      fi
    done <<EOF_MAP
$MAPIDS
EOF_MAP
  fi

  # vùng AC: heading "Acceptance" HOẶC "Nghiệm thu"; không thấy → quét mọi block ### AC
  ACSEC=$(awk '/^##[^#].*([Aa]cceptance|[Nn]ghiệm thu)/{p=1;next} /^##[^#]/{p=0} p' "$f")
  [ -z "$ACSEC" ] && ACSEC=$(awk '/^###[ \t]*AC/{p=1} /^##[^#]/{p=0} p' "$f")
  ACSCAN=$(echo "$ACSEC" | grep -vE '^[[:space:]]*>')   # bỏ dòng blockquote (meta-note giải thích, không phải AC)
  HITB=$(echo "$ACSCAN" | grep -niE "$UI_BLOCK" || true)
  if [ -n "$HITB" ]; then echo "$HITB" | sed 's/^/  BLOCK: AC chua component UI (anti-UI) -> /'; rc=1; fi
  echo "$ACSCAN" | grep -niE "$UI_WARN" 2>/dev/null | sed 's/^/  WARN: AC co the chua tu UI -> /' || true

  return $rc
}

if [ "$MODE" = "--self-test" ]; then
  RC=0; T=$(mktemp -d) || exit 1
  FM='> Load khi: t\ncovers: src/x\nlast_verified: 2026-01-01\nttl_days: 90\n'
  printf "# x\n${FM}## 10. Acceptance\n### AC-1 a\n- Given x\n- Then y\n" > "$T/a.md"
  R=$(lint_one "$T/a.md")
  echo "$R" | grep -q 'thieu Test:'       && echo "PASS: bat AC thieu Test:"   || { echo "FAIL: thieu Test:"; RC=1; }
  echo "$R" | grep -q 'thieu dong Assert' && echo "PASS: bat AC thieu Assert"  || { echo "FAIL: thieu Assert"; RC=1; }
  printf "# x\n${FM}## 10. Acceptance\nproza khong co AC heading\n" > "$T/b.md"
  R=$(lint_one "$T/b.md"); echo "$R" | grep -q '0 acceptance' && echo "PASS: bat 0-AC" || { echo "FAIL: 0-AC LOT"; RC=1; }
  printf "# x\n> Load khi: t\nlast_verified: 2026-01-01\nttl_days: 90\n## 10. Acceptance\n### AC-1 a · Test: e2e\n- **Assert** status==\"x\"\n" > "$T/c.md"
  R=$(lint_one "$T/c.md"); echo "$R" | grep -q "thieu 'covers:'" && echo "PASS: bat thieu covers" || { echo "FAIL: thieu covers LOT"; RC=1; }
  printf "# x\n${FM}> Muc dich: ...\n\n## 1. JTBD\nx\n## 10. Acceptance\n### AC-1 a · Test : e2e\n- Given x\n- When y xay ra\n- Then y\n- **Assert** status==\"da duyet\"\n" > "$T/d.md"
  R=$(lint_one "$T/d.md"); echo "$R" | grep -q BLOCK && { echo "FAIL: spec hop le bi BLOCK oan:"; echo "$R"; RC=1; } || echo "PASS: spec hop le qua (Test co space, frontmatter co preamble, G/W/T du, Assert dinh luong)"
  # Wave 2a — 4 luat noi dung moi (ENFORCED) + fixture chong-oan format ForFish:
  printf "# x\n${FM}## 10. Acceptance\n### AC-1 a · Test: e2e\n- **Given** x\n- **When** y\n- **Then** z\n- **Assert** count(x)==0\n### AC-1 b · Test: unit\n- **Given** x\n- **When** y\n- **Then** z\n- **Assert** count(x)==1\n" > "$T/h.md"
  R=$(lint_one "$T/h.md"); echo "$R" | grep -q 'TRUNG' && echo "PASS: AC-ID trung bi BLOCK" || { echo "FAIL: AC-ID trung LOT"; RC=1; }
  printf "# x\n${FM}## 10. Acceptance\n### AC-1 a · Test: manual-review\n- **Given** x\n- **When** y\n- **Then** z\n- **Assert** count(x)==0\n" > "$T/i.md"
  R=$(lint_one "$T/i.md"); echo "$R" | grep -q 'ngoai enum' && echo "PASS: Test ngoai enum bi BLOCK (manual-review)" || { echo "FAIL: Test ngoai enum LOT"; RC=1; }
  printf "# x\n${FM}## 10. Acceptance\n### AC-1 a · Test: e2e\n- **Given** x\n- **Then** z\n- **Assert** count(x)==0\n" > "$T/j.md"
  R=$(lint_one "$T/j.md"); echo "$R" | grep -q 'MOT cum Given/When/Then' && echo "PASS: thieu When bi BLOCK (dung mot cum G/W/T)" || { echo "FAIL: thieu When LOT"; RC=1; }
  printf "# x\n${FM}## Nghiep vu\n| NV1 | them tau |\n## 10. Acceptance\n### AC-1 a · Maps to: NV9 · Test: e2e\n- **Given** x\n- **When** y\n- **Then** z\n- **Assert** count(x)==0\n" > "$T/k.md"
  R=$(lint_one "$T/k.md"); echo "$R" | grep -q "Maps to: 'NV9' khong ton tai" && echo "PASS: Maps-to khong ton tai bi BLOCK" || { echo "FAIL: Maps-to NV9 khong ton tai LOT"; RC=1; }
  printf "# x\n${FM}## Nghiep vu\n| NV1 | them tau |\n## 10. Acceptance\n### AC-1 a · Maps to: NV1 · Test: e2e\n- **Given** chu tau co tau\n- **When** them tau moi\n- **Then** tau moi duoc chon\n- **Assert** count(boats)==2\n" > "$T/l.md"
  R=$(lint_one "$T/l.md"); echo "$R" | grep -q BLOCK && { echo "FAIL: format ForFish hop le bi BLOCK oan:"; echo "$R"; RC=1; } || echo "PASS: chong-oan format ForFish (Maps to + bold G/W/T + enum) qua sach"
  printf "# x\n${FM}## 10. Acceptance\n### AC-1 a · Test: e2e\n- Then he thong se assert quyen nguoi dung\n" > "$T/e.md"
  R=$(lint_one "$T/e.md"); echo "$R" | grep -q 'thieu dong Assert' && echo "PASS: khong nham 'assert' trong Then" || { echo "FAIL: nham assert trong Then -> false-pass"; RC=1; }
  printf "# x\n${FM}## 10. Acceptance\n### AC-1 a · Test: e2e\n- Then mo popup va bam nut Duyet\n- **Assert** status==1\n" > "$T/g.md"
  R=$(lint_one "$T/g.md"); echo "$R" | grep -q 'component UI' && echo "PASS: BLOCK component UI tieng Anh (popup)" || { echo "FAIL: UI tieng Anh LOT"; RC=1; }
  # v1.11.0 (Lo an toan so 1): mktemp fail tren nhanh --staged (production-facing) PHAI exit 1 —
  # truoc day TMP rong -> git show fail -> || continue -> moi file staged bi skip im lang -> PASS GIA.
  SELFV="$0"; case "$SELFV" in /*|[A-Za-z]:*) ;; *) SELFV="$(pwd)/$SELFV";; esac
  TS9=$(mktemp -d) || exit 1
  mkdir -p "$TS9/stub" "$TS9/r/docs/app-map"
  printf '#!/bin/sh\nexit 1\n' > "$TS9/stub/mktemp"; chmod +x "$TS9/stub/mktemp"
  ( cd "$TS9/r" && git init -q . && git config user.email t@t.t && git config user.name t \
    && printf 'noi dung sai\n' > docs/app-map/ba-spec-x.md && git add -A ) >/dev/null 2>&1
  ( cd "$TS9/r" && PATH="$TS9/stub:$PATH" sh "$SELFV" --staged ) >/dev/null 2>&1; RC9=$?
  [ "$RC9" -ne 0 ] && echo "PASS: mktemp fail nhanh --staged -> exit $RC9 (fail-fast, khong PASS gia)" || { echo "FAIL: mktemp fail nhanh --staged van PASS gia"; RC=1; }
  rm -rf "$TS9"
  # Wave 2a: ten file co DAU CACH tren nhanh --staged PHAI duoc lint (truoc day word-split -> SKIP im lang -> PASS gia)
  TSP=$(mktemp -d) || exit 1
  ( cd "$TSP" && git init -q . && git config user.email t@t.t && git config user.name t \
    && mkdir -p docs/app-map && printf 'noi dung sai\n' > "docs/app-map/ba-spec my feature.md" && git add -A ) >/dev/null 2>&1
  ( cd "$TSP" && sh "$SELFV" --staged ) >/dev/null 2>&1; RCSP=$?
  [ "$RCSP" -ne 0 ] && echo "PASS: ten file co dau cach nhanh --staged -> BLOCK (het false-pass word-split)" || { echo "FAIL: ten file dau cach van PASS gia"; RC=1; }
  rm -rf "$TSP"
  rm -rf "$T"
  [ "$RC" -eq 0 ] && echo "ba-verify self-test: ALL PASS" || echo "ba-verify self-test: CO FAIL"
  exit $RC
fi

if [ "$MODE" = "--staged" ]; then
  FILES=$(git -c core.quotepath=false diff --cached --name-only 2>/dev/null | grep -iE 'ba-spec.*\.md$' || true)
  [ -z "$FILES" ] && { echo "ba-verify: khong co ba-spec staged -> skip (exit 0)"; exit 0; }
  FAIL=0; TMP=$(mktemp) || exit 1
  # Wave 2a [ENFORCED]: while-read thay for-word-split — ten file co DAU CACH/tieng Viet khong bi SKIP
  # im lang (false-pass da chung minh); git show fail -> BLOCK fail-closed, khong continue im lang.
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    if ! git show ":$f" > "$TMP" 2>/dev/null; then echo "  BLOCK: khong doc duoc noi dung staged cua '$f'"; FAIL=1; continue; fi
    lint_one "$TMP" "$f" || FAIL=1
  done <<EOF_STAGED
$FILES
EOF_STAGED
  rm -f "$TMP"
  [ "$FAIL" -eq 1 ] && { echo "ba-verify: FAIL -> ba-spec staged thieu test/frontmatter, KHONG cho commit"; exit 1; }
  echo "ba-verify: PASS"; exit 0
fi

FILES=$(find "$APP_MAP_DIR" -maxdepth 2 -name '*.md' 2>/dev/null | grep -iE 'ba-spec' || true)
[ -z "$FILES" ] && { echo "ba-verify: khong thay ba-spec (mode=$MODE) -> skip (exit 0)"; exit 0; }
FAIL=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  lint_one "$f" || FAIL=1
done <<EOF_ALL
$FILES
EOF_ALL
[ "$FAIL" -eq 1 ] && { echo "ba-verify: FAIL -> nghiep vu/AC thieu test, KHONG cho qua"; exit 1; }
echo "ba-verify: PASS"
exit 0
