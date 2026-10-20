#!/bin/sh
# security-verify.sh — CONG MAY cho security-logic (anh em voi ba-verify.sh / triage-verify.sh).
# Co gioi hoa luat "khong co 'da bao mat ✓' — chi co 'phu A/B, KHONG phu C'" (methodology/14).
#
# BLOCK (exit 1) khi security-review:
#   - thieu frontmatter coupling: Load khi / covers / last_verified / ttl_days
#   - thieu 'declared-coverage:' tren frontmatter (khai 3 vung A/B/C)
#   - khong map khung nao (khong co ma OWASP LLM01-10 HOAC A01-10) -> finding "cam giac", khong hanh dong duoc
#   - thieu dong out-of-scope nhac 'pentest' (contract "KHONG thay the pentest production")
# WARN (khong chan): cau over-claim ("da bao mat ✓" / "100% an toan" / "khong co lo hong").
#
# DUNG:
#   bash security-verify.sh            # lint moi security-review trong docs/app-map (doc tren dia)
#   bash security-verify.sh --staged   # lint NOI DUNG DA STAGE (git show :file) — cho pre-commit
#   bash security-verify.sh --self-test
#
# WIRE VAO PRE-COMMIT (chan that) — them vao .githooks/pre-commit cua project:
#   if ! sh .claude/skills/security-logic/security-verify.sh --staged; then FAIL=1; fi
# (qua junction -> ban global moi nhat; KHONG copy thu muc -> tranh drift, bai hoc #08/#10.)

set -u
SELFV0="$0"; case "$SELFV0" in /*|[A-Za-z]:*) ;; *) SELFV0="$(pwd)/$SELFV0";; esac
APP_MAP_DIR="${APP_MAP_DIR:-docs/app-map}"
MODE="${1:-all}"

# Vung frontmatter = tu dau file toi HEADING '## ' dau tien (max 30 dong)
frontmatter_region() { awk 'NR<=30 && /^## /{exit} NR<=30{print}' "$1"; }

# Cau over-claim -> WARN (khong chan). Tach 2 phep de tranh phu thuoc dau tieng Viet trong regex:
# (a) dau tick ✓ tren CUNG dong voi tu bao-mat; (b) cac cum tuyet-doi ASCII-safe.
# Loai NGU CANH PHU DINH khoi (a): dong nhac LUAT VANG "KHONG 'da bao mat ✓'" la menh lenh CAM, khong phai
# tuyen bo -> khong duoc WARN oan. (b) van bat "khong co lo hong" vi do LA cau over-claim tuyet-doi.
# LUU Y case-fold: grep -i o C-locale KHONG fold chu cai co dau tieng Viet (Ô != ô). Nen phai liet ke
# CA bien the HOA co dau ('BẢO MẬT'/'AN TOÀN' cho phat hien; 'KHÔNG'/'LUẬT VÀNG' cho loai tru) — neu khong,
# over-claim VIET HOA co dau se LOT phat hien, va dong LUAT VANG VIET HOA se bi WARN oan (fixture case 8/9).
overclaim_hits() {
  grep -nE '✓' "$1" 2>/dev/null \
    | grep -iE 'bao mat|bảo mật|BẢO MẬT|secure|an toàn|an toan|AN TOÀN' \
    | grep -viE 'khong|không|KHÔNG|cấm|CẤM|cam |never|đừng|ĐỪNG|dung |luật vàng|luat vang|LUẬT VÀNG'
  grep -niE '100%|zero.?vuln|no.?vuln|(khong|không|KHÔNG) c(o|ó|Ó) (lo hong|lỗ hổng|LỖ HỔNG)' "$1" 2>/dev/null
}

lint_one() {
  f="$1"; label="${2:-$1}"; [ -f "$f" ] || return 0
  echo "── lint $label"
  rc=0
  FM=$(frontmatter_region "$f")
  echo "$FM" | grep -qiE 'load (khi|when)'   || { echo "  BLOCK: thieu 'Load khi/Load when'"; rc=1; }
  echo "$FM" | grep -qiE '^covers:'           || { echo "  BLOCK: thieu 'covers:'"; rc=1; }
  echo "$FM" | grep -qiE '^last_verified:'    || { echo "  BLOCK: thieu 'last_verified:'"; rc=1; }
  echo "$FM" | grep -qiE '^ttl_days:'         || { echo "  BLOCK: thieu 'ttl_days:'"; rc=1; }
  echo "$FM" | grep -qiE '^declared.coverage:' || { echo "  BLOCK: thieu 'declared-coverage:' -> phai khai 3 vung A(git)/B(CI)/C(NON-GOAL) (methodology/14)"; rc=1; }
  # Wave 2a [ENFORCED]: parse GIA TRI declared-coverage — du CA BA vung A=/B=/C= khong rong
  # (truoc day chi grep prefix: 'declared-coverage: xyz' van PASS -> false assurance).
  DCLINE=$(echo "$FM" | grep -iE '^declared.coverage:' | head -1)
  if [ -n "$DCLINE" ]; then
    for zone in A B C; do
      echo "$DCLINE" | grep -qE "(^|[| \t])$zone=[^| \t]" || { echo "  BLOCK: declared-coverage thieu vung $zone= co gia tri -> khai du A=<phu>/B=<point-to-tool>/C=NON-GOAL(...)"; rc=1; }
    done
  fi

  # v1.21.0 [ENFORCED] — PER-FINDING qua STATE MACHINE fence-aware (finding-parser.awk).
  # Bản regex-nối-thêm bị audit bypass bằng 7 biến thể (tên vùng khác, heading trong fence, thụt lề,
  # <h3>, bảng markdown, ID khác hoa/thường, placeholder {{...}}/TBD/_____). Nay quét CÓ TRẠNG THÁI
  # và fail-CLOSED với dạng chưa hỗ trợ. Kích hoạt khi có BẤT KỲ heading (mọi cú pháp) trông như
  # finding, hoặc có vùng Findings kèm heading con — review format cũ (list, không heading) KHÔNG
  # kích hoạt ⇒ không chặn oan.
  PARSER="$(dirname "$SELFV0")/finding-parser.awk"
  if [ -f "$PARSER" ]; then
    FOUT=$(awk -f "$PARSER" "$f")
    if [ -n "$FOUT" ]; then echo "$FOUT"; rc=1; fi
  fi

  # Map khung chuan: it nhat 1 ma OWASP LLM (LLM01-LLM10) HOAC web (A01-A10) trong toan file.
  # Phai match CA ma 2-chu-so LLM10 (Unbounded Consumption) + A10 (SSRF) — methodology/14 hang 10 map toi.
  if ! grep -qE 'LLM(0[1-9]|10)|A(0[1-9]|10)' "$f"; then
    echo "  BLOCK: khong co ma OWASP nao (LLM0x/A0x) -> finding 'cam giac', khong phan loai/hanh dong duoc"; rc=1
  fi

  # Contract out-of-scope: phai nhac 'pentest' (dong "KHONG thay the pentest production")
  if ! grep -qi 'pentest' "$f"; then
    echo "  BLOCK: thieu contract out-of-scope nhac 'pentest' -> phai khai C=NON-GOAL (khong thay the pentest production)"; rc=1
  fi

  # Over-claim -> WARN
  overclaim_hits "$f" | grep -v '^$' | sed 's/^/  WARN: cau over-claim (cam "da bao mat ✓" — khai vung phu thay vi tick) -> /' || true

  return $rc
}

if [ "$MODE" = "--self-test" ]; then
  RC=0; T=$(mktemp -d) || exit 1
  SELFV="$0"; case "$SELFV" in /*|[A-Za-z]:*) ;; *) SELFV="$(pwd)/$SELFV";; esac
  FM='> Load khi: review bao mat orders\ncovers: src/orders\nlast_verified: 2026-01-01\nttl_days: 90\ndeclared-coverage: A=secret+injection | B=SCA(npm audit) | C=NON-GOAL(pentest/DAST)\n'
  # 1) review hop le -> PASS
  printf "# sec\n${FM}## Findings\n- F1 (LLM01/A03): input chua escape -> exploit: SQLi qua orderId. tier=RED\n> KHONG thay the pentest production.\n" > "$T/ok.md"
  R=$(lint_one "$T/ok.md")
  echo "$R" | grep -q BLOCK && { echo "FAIL: review hop le bi BLOCK oan:"; echo "$R"; RC=1; } || echo "PASS: review hop le qua"
  # 2) thieu declared-coverage -> BLOCK
  FM2='> Load khi: t\ncovers: src/x\nlast_verified: 2026-01-01\nttl_days: 90\n'
  printf "# sec\n${FM2}## Findings\n- F1 (LLM01): x\n> KHONG thay the pentest.\n" > "$T/nocov.md"
  R=$(lint_one "$T/nocov.md"); echo "$R" | grep -q "declared-coverage" && echo "PASS: bat thieu declared-coverage" || { echo "FAIL: thieu declared-coverage LOT"; RC=1; }
  # v1.18.0 — PER-FINDING (audit 2026-08-16 bat false-PASS: 5 finding, chi cai dau du truong van PASS)
  FGOOD="### F-1 — a\n- **Rủi ro**: gui orderId chua payload doc don user khac\n- **OWASP**: LLM05 · A03\n- **Vùng / gate**: A — review + regression test\n- **Tier**: RED\n"
  printf "# sec\n${FM}## 2. Findings\n${FGOOD}\n> KHONG thay the pentest production.\n" > "$T/f1.md"
  R=$(lint_one "$T/f1.md"); echo "$R" | grep -q BLOCK && { echo "FAIL: finding du truong bi BLOCK oan:"; echo "$R"; RC=1; } || echo "PASS: finding du 5 truong -> qua (chong-oan)"
  printf "# sec\n${FM}## 2. Findings\n${FGOOD}\n### F-2 — b\n- mo ta suong khong co truong nao\n\n> KHONG thay the pentest production.\n" > "$T/f2.md"
  R=$(lint_one "$T/f2.md")
  echo "$R" | grep -q 'F-2' && echo "PASS: finding thu 2 RONG bi BLOCK (het false-PASS quet-toan-file)" || { echo "FAIL: finding rong LOT:"; echo "$R"; RC=1; }
  printf "# sec\n${FM}## 2. Findings\n${FGOOD}\n### F-1 — trung id\n- **Rủi ro**: x cu the nao do\n- **OWASP**: LLM01 · A01\n- **Vùng / gate**: A — gate\n- **Tier**: YELLOW\n\n> KHONG thay the pentest production.\n" > "$T/f3.md"
  R=$(lint_one "$T/f3.md"); echo "$R" | grep -q 'ID TRUNG' && echo "PASS: finding ID trung bi BLOCK" || { echo "FAIL: ID trung LOT"; RC=1; }
  printf "# sec\n${FM}## 2. Findings\n### F-1 — a\n- **Rủi ro**: prompt injection qua doc app-map\n- **OWASP**: LLM01 · A N/A vì đây là lỗ tầng agent, không map web\n- **Vùng / gate**: A — doc-injection lint\n- **Tier**: YELLOW\n\n> KHONG thay the pentest production.\n" > "$T/f4.md"
  R=$(lint_one "$T/f4.md"); echo "$R" | grep -q BLOCK && { echo "FAIL: N/A co ly do bi BLOCK oan:"; echo "$R"; RC=1; } || echo "PASS: web=N/A KEM LY DO -> qua (chong-oan, khong ep map bua)"
  # v1.19.0 (audit doc lap, B1) — 4 BIEN THE HEADING tung LOT het gate per-finding cu:
  printf "# sec\n${FM}## 2. Findings\n### F-1 — a\n- mo ta suong\n### Ghi chu chung\n- **Rủi ro**: rui ro cu the o muc khac\n- **OWASP**: LLM01 · A03\n- **Vùng / gate**: A — lint\n- **Tier**: RED\n> KHONG thay the pentest.\n" > "$T/b1.md"
  R=$(lint_one "$T/b1.md"); echo "$R" | grep -q BLOCK && echo "PASS: B1 — finding rong KHONG muon duoc truong cua heading khac" || { echo "FAIL: B1 ro truong cheo block LOT"; RC=1; }
  printf "# sec\n${FM}## 2. Findings\n## F-1 — a\n- mo ta suong\n> KHONG thay the pentest.\n" > "$T/b2.md"
  R=$(lint_one "$T/b2.md"); echo "$R" | grep -q BLOCK && echo "PASS: B1 — finding dat o '## F-' (2 thang) van bi kiem" || { echo "FAIL: B1 '## F-' lot gate"; RC=1; }
  printf "# sec\n${FM}## 2. Findings\n${FGOOD}#### F-2 — b\n- mo ta suong\n> KHONG thay the pentest.\n" > "$T/b3.md"
  R=$(lint_one "$T/b3.md"); echo "$R" | grep -q BLOCK && echo "PASS: B1 — finding dat o '#### F-' (4 thang) van bi kiem" || { echo "FAIL: B1 '#### F-' lot gate"; RC=1; }
  printf "# sec\n${FM}## 2. Findings\n${FGOOD}### 2.2 Lo token\n- mo ta suong\n> KHONG thay the pentest.\n" > "$T/b4.md"
  R=$(lint_one "$T/b4.md"); echo "$R" | grep -q BLOCK && echo "PASS: B1 — heading con KHONG ten F- trong vung Findings van la finding" || { echo "FAIL: B1 heading khong-F- lot gate"; RC=1; }
  # v1.19.0 (audit ForFish, MAJOR-2) — CHINH TEMPLATE ma skill phat hanh: chua dien -> BLOCK dung nghia
  # "con placeholder", NHAT QUAN moi finding (truoc day F-1 lot chi vi placeholder cua no dai hon 25 byte).
  TPLF="$(dirname "$SELFV")/security-review.md.template"
  if [ -f "$TPLF" ]; then
    R=$(lint_one "$TPLF")
    N1=$(echo "$R" | grep -c 'chua dien')
    [ "$N1" -ge 2 ] && echo "PASS: MAJOR-2 — template chua dien: MOI finding bao 'chua dien' (nhat quan, dung ban chat)" || { echo "FAIL: MAJOR-2 template bao sai/khong nhat quan:"; echo "$R"; RC=1; }
  fi
  printf "# sec\n${FM}## 2. Findings\n### F-1 — a\n- **Rủi ro**: dien that roi, khong con placeholder\n- **OWASP**: LLM01 · A03\n- **Vùng / gate**: A — lint\n- **Tier**: RED\n> KHONG thay the pentest.\n" > "$T/b5.md"
  R=$(lint_one "$T/b5.md"); echo "$R" | grep -q BLOCK && { echo "FAIL: MAJOR-2 chan oan review da dien:"; echo "$R"; RC=1; } || echo "PASS: MAJOR-2 — review DA DIEN qua sach (chong-oan)"
  # v1.21.0 — 10 BIEN THE do auditor craft, TAT CA tung LOT parser regex cu (nay parser state-machine):
  bp(){ printf "$2" > "$T/bp.md"; R=$(lint_one "$T/bp.md"); if echo "$R" | grep -q BLOCK; then [ "$3" = block ] && echo "PASS: parser — $1" || { echo "FAIL: parser CHAN OAN — $1"; echo "$R"; RC=1; }; else [ "$3" = pass ] && echo "PASS: parser — $1" || { echo "FAIL: parser LOT — $1"; RC=1; }; fi; }
  bp "vung ten khac ('## Vulnerabilities') van bi kiem" "# s\n${FM}## Vulnerabilities\n### V-1 Lo token\n- mo ta suong\n> KHONG thay the pentest.\n" block
  bp "heading trong code-fence KHONG dong vung Findings" "# s\n${FM}## 2. Findings\n${FGOOD}\n\`\`\`sh\n## chuan bi\n\`\`\`\n### 2.2 Lo quyen\n- mo ta suong\n> KHONG thay the pentest.\n" block
  bp "heading THUT LE (CommonMark) van la heading" "# s\n${FM}## 2. Findings\n${FGOOD}  ### F-2 — b\n- mo ta suong\n> KHONG thay the pentest.\n" block
  bp "heading HTML <h3> van la heading" "# s\n${FM}## 2. Findings\n<h3>F-9 lo token</h3>\n- mo ta suong\n> KHONG thay the pentest.\n" block
  bp "finding trong BANG markdown -> fail-closed co huong dan" "# s\n${FM}## 2. Findings\n| ID | Mo ta |\n|---|---|\n| F-3 | trong |\n> KHONG thay the pentest.\n" block
  bp "truong nam trong fence KHONG nuoi finding that" "# s\n${FM}## 2. Findings\n### F-1 — a\n- mo ta suong\n\`\`\`\n- **Rủi ro**: vi du mau\n- **OWASP**: LLM01 · A03\n- **Vùng / gate**: A — lint\n- **Tier**: RED\n\`\`\`\n> KHONG thay the pentest.\n" block
  bp "ID trung khac HOA/THUONG van bi bat" "# s\n${FM}## 2. Findings\n${FGOOD}### f-1 — trung\n- **Rủi ro**: rui ro khac cu the\n- **OWASP**: LLM05 · A01\n- **Vùng / gate**: B — SCA\n- **Tier**: YELLOW\n> KHONG thay the pentest.\n" block
  bp "placeholder {{...}} (quy uoc 'bat buoc dien') bi bat" "# s\n${FM}## 2. Findings\n### F-1 — a\n- **Rủi ro**: {{DIEN_SAU}}\n- **OWASP**: LLM01 · A03\n- **Vùng / gate**: A — lint\n- **Tier**: RED\n> KHONG thay the pentest.\n" block
  bp "TBD / gach duoi / '(chua ro)' deu la CHUA DIEN" "# s\n${FM}## 2. Findings\n### F-1 — a\n- **Rủi ro**: TBD\n- **OWASP**: LLM01 · A03\n- **Vùng / gate**: _____\n- **Tier**: RED\n> KHONG thay the pentest.\n" block
  bp "muc [non-finding] trong vung Findings -> KHONG chan oan" "# s\n${FM}## 2. Findings\n${FGOOD}\n### Khuon mau cho lan sau [non-finding]\n\`\`\`md\n### F-<n>\n\`\`\`\n> KHONG thay the pentest.\n" pass
  # Wave 2a: parse GIA TRI A=/B=/C= — prefix suong / thieu vung phai BLOCK; du 3 vung phai PASS (chong-oan o ok.md)
  printf "# sec\n> Load khi: t\ncovers: src/x\nlast_verified: 2026-01-01\nttl_days: 90\ndeclared-coverage: xyz khong co vung nao\n## Findings\n- F1 (LLM01): x. tier=RED\n> KHONG thay the pentest.\n" > "$T/dcval.md"
  R=$(lint_one "$T/dcval.md"); echo "$R" | grep -q 'thieu vung A=' && echo "PASS: declared-coverage 'xyz' (prefix suong) bi BLOCK" || { echo "FAIL: declared-coverage prefix suong LOT"; RC=1; }
  printf "# sec\n> Load khi: t\ncovers: src/x\nlast_verified: 2026-01-01\nttl_days: 90\ndeclared-coverage: A=secret | B=SCA\n## Findings\n- F1 (LLM01): x. tier=RED\n> KHONG thay the pentest.\n" > "$T/dcc.md"
  R=$(lint_one "$T/dcc.md"); echo "$R" | grep -q 'thieu vung C=' && echo "PASS: declared-coverage thieu C= bi BLOCK" || { echo "FAIL: thieu C= LOT"; RC=1; }
  # 3) thieu ma OWASP -> BLOCK
  printf "# sec\n${FM}## Findings\n- F1: co ve nguy hiem\n> KHONG thay the pentest.\n" > "$T/noowasp.md"
  R=$(lint_one "$T/noowasp.md"); echo "$R" | grep -q "OWASP" && echo "PASS: bat thieu ma OWASP" || { echo "FAIL: thieu OWASP LOT"; RC=1; }
  # 4) thieu contract pentest -> BLOCK
  printf "# sec\n${FM}## Findings\n- F1 (LLM01/A03): x\n" > "$T/nopentest.md"
  R=$(lint_one "$T/nopentest.md"); echo "$R" | grep -q "pentest" && echo "PASS: bat thieu contract out-of-scope" || { echo "FAIL: thieu pentest contract LOT"; RC=1; }
  # 5) over-claim -> WARN (khong BLOCK)
  printf "# sec\n${FM}## Findings\n- F1 (A02): da bao mat ✓, khong co lỗ hổng\n> KHONG thay the pentest.\n" > "$T/over.md"
  R=$(lint_one "$T/over.md")
  echo "$R" | grep -q "over-claim" && echo "PASS: WARN over-claim" || { echo "FAIL: over-claim khong WARN"; RC=1; }
  echo "$R" | grep -q BLOCK && { echo "FAIL: over-claim khong duoc BLOCK (chi WARN)"; RC=1; } || echo "PASS: over-claim chi WARN khong BLOCK"
  # 6) review chi co LLM10/A10 (ma 2 chu so) -> phai QUA, chong regex bo sot LLM10/A10 (blocker cu)
  printf "# sec\n${FM}## Findings\n- F1 (LLM10/A10): endpoint khong rate-limit -> exploit: DoS + SSRF qua fetch noi bo. tier=RED\n> KHONG thay the pentest production.\n" > "$T/tens.md"
  R=$(lint_one "$T/tens.md")
  echo "$R" | grep -q BLOCK && { echo "FAIL: review chi LLM10/A10 bi BLOCK oan (regex bo sot ma 2 chu so):"; echo "$R"; RC=1; } || echo "PASS: review chi LLM10/A10 qua (regex match ma 2 chu so)"
  # 7) dong PHU DINH luat vang (KHONG "da bao mat ✓") -> KHONG duoc WARN over-claim (false-positive noise)
  printf "# sec\n${FM}<!-- LUAT VANG: KHONG \"da bao mat ✓\", khai vung phu thay vi tick -->\n## Findings\n- F1 (LLM01/A03): input chua escape -> SQLi qua orderId. tier=RED\n> KHONG thay the pentest production.\n" > "$T/negrule.md"
  R=$(lint_one "$T/negrule.md")
  echo "$R" | grep -q "over-claim" && { echo "FAIL: dong phu dinh luat vang bi WARN over-claim oan:"; echo "$R"; RC=1; } || echo "PASS: dong phu dinh luat vang KHONG bi WARN over-claim oan"
  echo "$R" | grep -q BLOCK && { echo "FAIL: negrule bi BLOCK oan:"; echo "$R"; RC=1; } || echo "PASS: negrule hop le qua (khong BLOCK)"
  # 8) dong LUAT VANG VIET HOA CO DAU (dung chuoi THAT tren security-review.md.template dong 12:
  #    'LUẬT VÀNG: KHÔNG "đã bảo mật ✓"') -> KHONG duoc WARN oan. Case 7 chi dung ASCII 'KHONG'/'LUAT VANG'
  #    nen PASS oan; case nay bao dung dieu kien diacritic HOA de bat regression case-fold.
  printf "# sec\n${FM}<!-- LUẬT VÀNG: KHÔNG \"đã bảo mật ✓\", khai vùng phủ thay vì tick -->\n## Findings\n- F1 (LLM01/A03): input chua escape -> SQLi qua orderId. tier=RED\n> KHÔNG thay the pentest production.\n" > "$T/negrulehoa.md"
  R=$(lint_one "$T/negrulehoa.md")
  echo "$R" | grep -q "over-claim" && { echo "FAIL: dong LUAT VANG HOA co dau bi WARN over-claim oan (case-fold C-locale bo sot):"; echo "$R"; RC=1; } || echo "PASS: dong LUAT VANG HOA co dau KHONG bi WARN over-claim oan"
  echo "$R" | grep -q BLOCK && { echo "FAIL: negrulehoa bi BLOCK oan:"; echo "$R"; RC=1; } || echo "PASS: negrulehoa hop le qua (khong BLOCK)"
  # 9) over-claim VIET HOA CO DAU ('ĐÃ BẢO MẬT ✓') KHONG kem phu dinh -> PHAI WARN (chong LOT phat hien HOA co dau)
  printf "# sec\n${FM}## Findings\n- F1 (A02): ĐÃ BẢO MẬT ✓, hệ thống an toàn\n> KHONG thay the pentest.\n" > "$T/overhoa.md"
  R=$(lint_one "$T/overhoa.md")
  echo "$R" | grep -q "over-claim" && echo "PASS: WARN over-claim VIET HOA co dau (ĐÃ BẢO MẬT ✓)" || { echo "FAIL: over-claim VIET HOA co dau LOT phat hien:"; echo "$R"; RC=1; }
  # v1.11.0 (Lo an toan so 1): mktemp fail tren nhanh --staged (production-facing) PHAI exit 1.
  SELFV="$0"; case "$SELFV" in /*|[A-Za-z]:*) ;; *) SELFV="$(pwd)/$SELFV";; esac
  TS9=$(mktemp -d) || exit 1
  mkdir -p "$TS9/stub" "$TS9/r/docs/app-map"
  printf '#!/bin/sh\nexit 1\n' > "$TS9/stub/mktemp"; chmod +x "$TS9/stub/mktemp"
  ( cd "$TS9/r" && git init -q . && git config user.email t@t.t && git config user.name t \
    && printf 'noi dung sai\n' > docs/app-map/security-review-x.md && git add -A ) >/dev/null 2>&1
  ( cd "$TS9/r" && PATH="$TS9/stub:$PATH" sh "$SELFV" --staged ) >/dev/null 2>&1; RC9=$?
  [ "$RC9" -ne 0 ] && echo "PASS: mktemp fail nhanh --staged -> exit $RC9 (fail-fast, khong PASS gia)" || { echo "FAIL: mktemp fail nhanh --staged van PASS gia"; RC=1; }
  rm -rf "$TS9"
  rm -rf "$T"
  [ "$RC" -eq 0 ] && echo "security-verify self-test: ALL PASS" || echo "security-verify self-test: CO FAIL"
  exit $RC
fi

if [ "$MODE" = "--staged" ]; then
  FILES=$(git -c core.quotepath=false diff --cached --name-only 2>/dev/null | grep -iE 'security-review.*\.md$' || true)
  [ -z "$FILES" ] && { echo "security-verify: khong co security-review staged -> skip (exit 0)"; exit 0; }
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
  [ "$FAIL" -eq 1 ] && { echo "security-verify: FAIL -> security-review staged thieu declared-coverage/OWASP/contract, KHONG cho commit"; exit 1; }
  echo "security-verify: PASS"; exit 0
fi

FILES=$(find "$APP_MAP_DIR" -maxdepth 2 -name '*.md' 2>/dev/null | grep -iE 'security-review' || true)
[ -z "$FILES" ] && { echo "security-verify: khong thay security-review (mode=$MODE) -> skip (exit 0)"; exit 0; }
FAIL=0
while IFS= read -r f; do
  [ -n "$f" ] || continue
  lint_one "$f" || FAIL=1
done <<EOF_ALL
$FILES
EOF_ALL
[ "$FAIL" -eq 1 ] && { echo "security-verify: FAIL -> security-review thieu khai bao phu song, KHONG cho qua"; exit 1; }
echo "security-verify: PASS"
exit 0
