#!/bin/sh
# agent-memory-verify.sh — CONG MAY cho bo nho theo vai cua agent chuyen gia (ADR 004, NT12 vong B).
# Bo nho la INPUT TRUC TIEP vao AI: muc nho khong bang chung = tien de cu khong ai kiem (STALE).
#
# BLOCK (exit 1) khi mot file docs/agent-memory/<agent>.md:
#   - co dong bullet KHONG mang ma [M-NNN]                 (ghi nho tu do, khong truy duoc)
#   - muc [M-NNN] thieu 'evidence:' / 'last_verified: YYYY-MM-DD' / 'bo khi:' (hoac 'bỏ khi:')
#   - trung ma [M-NNN] trong cung file
#   - vuot MEM_MAX_ENTRIES muc (mac dinh 40) -> phai gop / day len skill-spec / xoa
# WARN (khong chan): muc qua MEM_TTL_DAYS ngay (mac dinh 180) chua re-verify -> SUSPECT.
# README.md trong thu muc duoc bo qua (la giao thuc, khong phai bo nho).
#
# DUNG:
#   sh agent-memory-verify.sh              # lint moi file bo nho tren dia
#   sh agent-memory-verify.sh --self-test
# Wire (tuy chon) vao .githooks/pre-commit cua project:
#   if ! sh .claude/skills/ai-simple-product-dev/agent-memory-verify.sh; then FAIL=1; fi

set -u
SELFV0="$0"; case "$SELFV0" in /*|[A-Za-z]:*) ;; *) SELFV0="$(pwd)/$SELFV0";; esac
MEM_DIR="${MEM_DIR:-docs/agent-memory}"
MEM_MAX_ENTRIES="${MEM_MAX_ENTRIES:-40}"
MEM_TTL_DAYS="${MEM_TTL_DAYS:-180}"
TODAY="${MEM_TODAY:-$(date +%Y-%m-%d)}"

lint_file() {
  awk -v f="$1" -v max="$MEM_MAX_ENTRIES" -v ttl="$MEM_TTL_DAYS" -v today="$TODAY" '
    function days(s,  a) { split(s, a, "-"); return a[1] * 365 + a[2] * 30 + a[3] }
    /^```/ { fence = !fence; next }
    fence { next }
    /^[-*] / {
      if ($0 !~ /^- \[M-[0-9]+\] /) { printf "FAIL %s:%d — bullet khong mang ma [M-NNN]\n", f, NR; bad++; next }
      id = $0; sub(/^- \[/, "", id); sub(/\].*/, "", id); n++
      if (seen[id]++) { printf "FAIL %s:%d — trung ma [%s]\n", f, NR, id; bad++ }
      if ($0 !~ /evidence: *[^ |]/) { printf "FAIL %s:%d — [%s] thieu evidence\n", f, NR, id; bad++ }
      if ($0 !~ /(bo khi|bỏ khi): *[^ |]/) { printf "FAIL %s:%d — [%s] thieu dieu kien \"bo khi\"\n", f, NR, id; bad++ }
      if (match($0, /last_verified: *[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]/)) {
        d = substr($0, RSTART + RLENGTH - 10, 10)
        if (days(today) - days(d) > ttl) printf "WARN %s:%d — [%s] SUSPECT: last_verified %s qua %d ngay, doi chieu lai truoc khi tin\n", f, NR, id, d, ttl
      } else { printf "FAIL %s:%d — [%s] thieu last_verified: YYYY-MM-DD\n", f, NR, id; bad++ }
    }
    END {
      if (n > max) { printf "FAIL %s — %d muc > tran %d: gop, day len skill/spec, hoac xoa muc da het han\n", f, n, max; bad++ }
      exit bad ? 1 : 0
    }' "$1"
}

run_all() {
  RC=0; N=0
  [ -d "$MEM_DIR" ] || { echo "PASS agent-memory-verify (chua co $MEM_DIR — khong co gi de kiem)"; return 0; }
  for f in "$MEM_DIR"/*.md; do
    [ -f "$f" ] || continue
    case "$f" in */README.md) continue;; esac
    N=$((N + 1))
    lint_file "$f" || RC=1
  done
  [ "$RC" -eq 0 ] && echo "PASS agent-memory-verify ($N file bo nho: moi muc co ma + evidence + last_verified + bo-khi)"
  return "$RC"
}

case "${1:-all}" in
  --self-test)
    T="$(mktemp -d)"; trap 'rm -rf "$T"' EXIT; RC=0
    t() { # t <ten> <rc mong doi> <chuoi phai co trong output | ->
      OUT="$(MEM_DIR="$T/m" MEM_TODAY=2026-11-25 MEM_MAX_ENTRIES=3 sh "$SELFV0" 2>&1)"; GOT=$?
      if [ "$GOT" -eq "$2" ] && { [ "$3" = "-" ] || echo "$OUT" | grep -q "$3"; }; then echo "PASS: $1"
      else echo "FAIL: $1 (rc=$GOT, mong $2) — $OUT"; RC=1; fi
    }
    OK='- [M-001] Bang gia tinh theo chuyen, khong theo tan | scope: domain:pricing | evidence: a1b2c3d | last_verified: 2026-11-01 | bỏ khi: doi mo hinh gia'
    # chong-oan 1: chua co thu muc bo nho
    t "chua co thu muc -> qua" 0 "PASS agent-memory-verify"
    mkdir -p "$T/m"
    # chong-oan 2: file hop le + README tu do + bullet trong code fence + dang ASCII 'bo khi'
    printf '# ba-expert\n\n%s\n- [M-002] X | scope: project | evidence: docs/a.md:3 | last_verified: 2026-10-01 | bo khi: Y\n\n```\n- vi du tu do trong fence\n```\n' "$OK" > "$T/m/ba-expert.md"
    printf '# Giao thuc\n- bullet tu do trong README\n' > "$T/m/README.md"
    t "file hop le + README + fence -> qua" 0 "PASS agent-memory-verify"
    printf '# x\n- nho la user thich mau xanh\n' > "$T/m/ui-expert.md"
    t "bullet khong ma -> BLOCK" 1 "khong mang ma"
    printf '# x\n- [M-001] A | scope: project | last_verified: 2026-11-01 | bo khi: B\n' > "$T/m/ui-expert.md"
    t "thieu evidence -> BLOCK" 1 "thieu evidence"
    printf '# x\n- [M-001] A | scope: project | evidence: abc1234 | bo khi: B\n' > "$T/m/ui-expert.md"
    t "thieu last_verified -> BLOCK" 1 "thieu last_verified"
    printf '# x\n- [M-001] A | scope: project | evidence: abc1234 | last_verified: 2026-11-01\n' > "$T/m/ui-expert.md"
    t "thieu bo-khi -> BLOCK" 1 "bo khi"
    printf '# x\n%s\n%s\n' "$OK" "$OK" > "$T/m/ui-expert.md"
    t "trung ma -> BLOCK" 1 "trung ma"
    printf '# x\n- [M-001] A | evidence: a | last_verified: 2026-11-01 | bo khi: B\n- [M-002] A | evidence: a | last_verified: 2026-11-01 | bo khi: B\n- [M-003] A | evidence: a | last_verified: 2026-11-01 | bo khi: B\n- [M-004] A | evidence: a | last_verified: 2026-11-01 | bo khi: B\n' > "$T/m/ui-expert.md"
    t "vuot tran so muc -> BLOCK" 1 "tran 3"
    printf '# x\n- [M-001] A | evidence: a | last_verified: 2025-01-01 | bo khi: B\n' > "$T/m/ui-expert.md"
    t "muc cu qua TTL -> WARN, KHONG chan" 0 "SUSPECT"
    echo "--- self-test: $([ $RC -eq 0 ] && echo ALL PASS || echo CO FAIL) ---"; exit $RC ;;
  *) run_all ;;
esac
