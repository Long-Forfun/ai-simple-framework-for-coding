#!/bin/sh
# mutation-suite.sh — Wave 2a chặng (1): máy đếm PASS-sai (false-pass) + BLOCK-oan (false-block).
# Mỗi ca = payload đột biến → verifier → kỳ vọng (fail|pass). Suite này là THƯỚC ĐO so trước/sau
# cho mọi thay đổi luật nội dung của verifier (bổ sung, không thay thế, fixture trong --self-test từng verifier).
# Dùng:  sh scripts/mutation-suite.sh            # chạy đủ bảng ca, exit 1 nếu có false-pass/false-block
#        sh scripts/mutation-suite.sh --self-test
set -u
SELF="$0"; case "$SELF" in /*|[A-Za-z]:*) ;; *) SELF="$(pwd)/$SELF";; esac
ROOT=$(dirname "$SELF")/..
BA="$ROOT/skills/ba-flow-logic/ba-verify.sh"
SEC="$ROOT/skills/security-logic/security-verify.sh"

FP=0; FB=0; N=0
FMOK='> Load khi: t\ncovers: src/x\nlast_verified: 2026-01-01\nttl_days: 90\n'
SECFM='> Load khi: t\ncovers: src/x\nlast_verified: 2026-01-01\nttl_days: 90\ndeclared-coverage: A=secret | B=SCA(npm audit) | C=NON-GOAL(pentest)\n'

run_case() { # $1=tên  $2=verifier  $3=mode(all|staged-space|staged-mktemp)  $4=expect(fail|pass)  $5=nội dung file
  N=$((N+1))
  T=$(mktemp -d) || exit 1
  case "$3" in
    all)
      mkdir -p "$T/docs/app-map"; printf "$5" > "$T/docs/app-map/ba-spec-m.md"
      [ "$2" = "$SEC" ] && mv "$T/docs/app-map/ba-spec-m.md" "$T/docs/app-map/security-review-m.md"
      ( cd "$T" && sh "$2" ) >/dev/null 2>&1; RCX=$? ;;
    staged-space)
      ( cd "$T" && git init -q . && git config user.email t@t.t && git config user.name t \
        && mkdir -p docs/app-map && printf "$5" > "docs/app-map/ba-spec my file.md" && git add -A ) >/dev/null 2>&1
      ( cd "$T" && sh "$2" --staged ) >/dev/null 2>&1; RCX=$? ;;
    staged-mktemp)
      mkdir -p "$T/stub" "$T/r/docs/app-map"; printf '#!/bin/sh\nexit 1\n' > "$T/stub/mktemp"; chmod +x "$T/stub/mktemp"
      ( cd "$T/r" && git init -q . && git config user.email t@t.t && git config user.name t \
        && printf "$5" > docs/app-map/ba-spec-m.md && git add -A ) >/dev/null 2>&1
      ( cd "$T/r" && PATH="$T/stub:$PATH" sh "$2" --staged ) >/dev/null 2>&1; RCX=$? ;;
  esac
  rm -rf "$T"
  if [ "$4" = fail ]; then
    [ "$RCX" -ne 0 ] && echo "OK   (chan dung)  $1" || { echo "FALSE-PASS        $1"; FP=$((FP+1)); }
  else
    [ "$RCX" -eq 0 ] && echo "OK   (qua dung)   $1" || { echo "FALSE-BLOCK       $1"; FB=$((FB+1)); }
  fi
}

suite() {
  run_case "ba/staged: ten file dau cach + noi dung sai" "$BA" staged-space fail 'noi dung sai\n'
  run_case "ba/staged: mktemp fail (production-facing)" "$BA" staged-mktemp fail 'noi dung sai\n'
  run_case "ba: AC thieu When (can dung 1 cum G/W/T)" "$BA" all fail "# x\n${FMOK}## 10. Acceptance\n### AC-1 a · Test: e2e\n- **Given** x\n- **Then** z\n- **Assert** count(x)==0\n"
  run_case "ba: AC-ID trung" "$BA" all fail "# x\n${FMOK}## 10. Acceptance\n### AC-1 a · Test: e2e\n- **Given** x\n- **When** y\n- **Then** z\n- **Assert** count(x)==0\n### AC-1 b · Test: unit\n- **Given** x\n- **When** y\n- **Then** z\n- **Assert** count(x)==1\n"
  run_case "ba: Test ngoai enum" "$BA" all fail "# x\n${FMOK}## 10. Acceptance\n### AC-1 a · Test: manual-review\n- **Given** x\n- **When** y\n- **Then** z\n- **Assert** count(x)==0\n"
  run_case "ba: Maps-to khong ton tai" "$BA" all fail "# x\n${FMOK}## 10. Acceptance\n### AC-1 a · Maps to: NV9 · Test: e2e\n- **Given** x\n- **When** y\n- **Then** z\n- **Assert** count(x)==0\n"
  run_case "sec: declared-coverage prefix suong (xyz)" "$SEC" all fail "# s\n> Load khi: t\ncovers: src/x\nlast_verified: 2026-01-01\nttl_days: 90\ndeclared-coverage: xyz\n## F\n- F1 (LLM01): x. tier=RED\n> KHONG thay the pentest.\n"
  run_case "sec: over-claim CHI WARN (khong duoc false-block)" "$SEC" all pass "# s\n${SECFM}## F\n- F1 (A02): da bao mat ✓ het loi\n> KHONG thay the pentest.\n"
  run_case "sec: NHIEU finding, cai thu 2 rong (false-PASS cu)" "$SEC" all fail "# s\n${SECFM}## 2. Findings\n### F-1 — a\n- **Rủi ro**: payload doc don user khac\n- **OWASP**: LLM05 · A03\n- **Vùng / gate**: A — review\n- **Tier**: RED\n### F-2 — b\n- mo ta suong\n\n> KHONG thay the pentest.\n"
  run_case "sec: nhieu finding DU truong (chong-oan)" "$SEC" all pass "# s\n${SECFM}## 2. Findings\n### F-1 — a\n- **Rủi ro**: payload doc don user khac\n- **OWASP**: LLM05 · A03\n- **Vùng / gate**: A — review\n- **Tier**: RED\n### F-2 — b\n- **Rủi ro**: thieu rate-limit gay DoS endpoint\n- **OWASP**: LLM10 · A04\n- **Vùng / gate**: B — SCA/CI\n- **Tier**: YELLOW\n\n> KHONG thay the pentest.\n"
  run_case "ba: format ForFish hop le (chong-oan)" "$BA" all pass "# x\n${FMOK}## Nghiep vu\n| NV1 | them tau |\n## 10. Acceptance\n### AC-1 a · Maps to: NV1 · Test: e2e\n- **Given** x\n- **When** y\n- **Then** z\n- **Assert** count(x)==2\n"
  run_case "sec: review hop le (chong-oan)" "$SEC" all pass "# s\n${SECFM}## F\n- F1 (LLM01/A03): SQLi qua orderId. tier=RED\n> KHONG thay the pentest production.\n"
}

if [ "${1:-}" = "--self-test" ]; then
  # Sanity harness: 1 ca chan-dung + 1 ca qua-dung phai cho verdict OK
  FP=0; FB=0; N=0
  run_case "sanity: spec rong phai bi chan" "$BA" all fail 'rong\n' >/dev/null
  run_case "sanity: sec hop le phai qua" "$SEC" all pass "# s\n${SECFM}## F\n- F1 (LLM01): x. tier=RED\n> KHONG thay the pentest.\n" >/dev/null
  if [ $FP -eq 0 ] && [ $FB -eq 0 ]; then echo "mutation-suite self-test: ALL PASS (harness phan biet duoc chan/qua)"; exit 0
  else echo "mutation-suite self-test: CO FAIL (FP=$FP FB=$FB)"; exit 1; fi
fi

echo "=== mutation-suite ($(date +%Y-%m-%d)) ==="
suite
echo "=== tong: $N ca | FALSE-PASS=$FP | FALSE-BLOCK=$FB ==="
[ $FP -eq 0 ] && [ $FB -eq 0 ] || exit 1
exit 0
