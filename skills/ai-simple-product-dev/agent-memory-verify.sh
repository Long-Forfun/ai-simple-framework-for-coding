#!/bin/sh
# agent-memory-verify.sh — CONG MAY cho bo nho theo vai cua agent chuyen gia (ADR 004, NT12 vong B).
# Bo nho la INPUT TRUC TIEP vao AI: muc nho khong bang chung = tien de cu khong ai kiem (STALE).
#
# BLOCK (exit 1) khi mot file docs/agent-memory/<agent>.md:
#   - co dong bullet KHONG mang ma [M-NNN]                 (ghi nho tu do, khong truy duoc)
#   - muc [M-NNN] thieu 'evidence:' / 'last_verified: YYYY-MM-DD' / 'bo khi:' (hoac 'bỏ khi:')
#   - trung ma [M-NNN] trong cung file
#   - vuot MEM_MAX_ENTRIES muc (mac dinh 40) -> phai gop / day len skill-spec / xoa
#   - [v2] ma MOI (chua co o ban git MEM_BASE, mac dinh HEAD) nho hon hoac bang ma lon nhat
#     cua ban do -> tai dung ma da xoa / chen ma cu: evidence va lich su cua ma bi lan
# WARN (khong chan):
#   - muc qua MEM_TTL_DAYS ngay (mac dinh 180) chua re-verify -> SUSPECT
#   - [v2] mat qua nua so muc cua ban MEM_BASE (ban do co >= 5 muc) -> nghi viet lai ca file;
#     bo nho chi duoc sua TUNG DONG (them / sua / xoa mot muc), viet lai ca file lam mon chi tiet
#   - [v2] cung mot khang dinh nam o >= 2 file vai -> su that chung, dua len spec/app-map
# README.md trong thu muc duoc bo qua (la giao thuc, khong phai bo nho).
#
# DUNG:
#   sh agent-memory-verify.sh              # lint moi file bo nho tren dia
#   sh agent-memory-verify.sh --stats      # [v2] bang do: so muc, SUSPECT, so lan user sua tung vai theo thang
#   sh agent-memory-verify.sh --self-test
# Wire (tuy chon) vao .githooks/pre-commit cua project:
#   if ! sh .claude/skills/ai-simple-product-dev/agent-memory-verify.sh; then FAIL=1; fi

set -u
SELFV0="$0"; case "$SELFV0" in /*|[A-Za-z]:*) ;; *) SELFV0="$(pwd)/$SELFV0";; esac
MEM_DIR="${MEM_DIR:-docs/agent-memory}"
MEM_MAX_ENTRIES="${MEM_MAX_ENTRIES:-40}"
MEM_TTL_DAYS="${MEM_TTL_DAYS:-180}"
MEM_BASE="${MEM_BASE:-HEAD}"
MEM_EVENTS="${MEM_EVENTS:-docs/learning/events.jsonl}"
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

# In ra so cua moi ma [M-NNN] ngoai code fence, moi dong mot so (doc tu stdin).
ids_of() {
  awk '/^```/ { fence = !fence; next } fence { next }
       /^- \[M-[0-9]+\] / { s = $0; sub(/^- \[M-/, "", s); sub(/\].*/, "", s); print s + 0 }'
}

# [v2] So voi ban git MEM_BASE: chan tai dung ma, canh bao viet lai ca file.
# Khong co git / file chua tung commit / MEM_BASE khong ton tai -> bo qua (khong chan oan file moi).
history_check() {
  command -v git >/dev/null 2>&1 || return 0
  git rev-parse --verify -q "$MEM_BASE" >/dev/null 2>&1 || return 0
  OLD="$(git show "$MEM_BASE:./$1" 2>/dev/null)" || return 0
  [ -n "$OLD" ] || return 0
  OLD_IDS="$(printf '%s\n' "$OLD" | ids_of)"
  NEW_IDS="$(ids_of < "$1")"
  [ -n "$OLD_IDS" ] || return 0
  printf 'OLD %s\n' $OLD_IDS > "${TMPDIR:-/tmp}/amv.$$"
  printf 'NEW %s\n' $NEW_IDS >> "${TMPDIR:-/tmp}/amv.$$"
  awk -v f="$1" -v base="$MEM_BASE" '
    $1 == "OLD" { old[$2] = 1; if ($2 > max) max = $2; nold++; next }
    $1 == "NEW" && $2 != "" { now[$2] = 1; if (!($2 in old) && $2 <= max) { printf "FAIL %s — ma [M-%03d] moi nhung <= ma lon nhat cua %s (M-%03d): khong tai dung / chen ma cu, lay ma ke tiep\n", f, $2, base, max; bad++ } }
    END {
      for (i in old) if (!(i in now)) gone++
      if (nold >= 5 && gone * 2 > nold) printf "WARN %s — mat %d/%d muc so voi %s: nghi viet lai ca file; bo nho chi sua tung dong (them/sua/xoa mot muc)\n", f, gone, nold, base
      exit bad ? 1 : 0
    }' "${TMPDIR:-/tmp}/amv.$$"
  RC_H=$?; rm -f "${TMPDIR:-/tmp}/amv.$$"; return "$RC_H"
}

# [v2] Cung mot khang dinh o >= 2 file vai -> WARN (su that chung thuoc spec/app-map, hai noi ghi se lech).
cross_check() {
  # shellcheck disable=SC2086
  awk '
    FNR == 1 { fence = 0 }
    /^```/ { fence = !fence; next } fence { next }
    /^- \[M-[0-9]+\] / {
      c = $0; sub(/^- \[M-[0-9]+\] */, "", c); sub(/ *\|.*/, "", c); c = tolower(c); gsub(/[ \t]+/, " ", c)
      if (length(c) < 12) next
      if ((c in where) && where[c] != FILENAME) printf "WARN trung khang dinh giua %s va %s: \"%s\" — su that chung, dua len spec/app-map roi xoa o ca hai\n", where[c], FILENAME, c
      else if (!(c in where)) where[c] = FILENAME
    }' "$@"
}

memory_files() {
  for f in "$MEM_DIR"/*.md; do
    [ -f "$f" ] || continue
    case "$f" in */README.md) continue;; esac
    printf '%s\n' "$f"
  done
}

run_all() {
  RC=0; N=0
  [ -d "$MEM_DIR" ] || { echo "PASS agent-memory-verify (chua co $MEM_DIR — khong co gi de kiem)"; return 0; }
  FILES="$(memory_files)"
  for f in $FILES; do
    N=$((N + 1))
    lint_file "$f" || RC=1
    history_check "$f" || RC=1
  done
  # shellcheck disable=SC2086
  [ "$N" -ge 2 ] && cross_check $FILES
  [ "$RC" -eq 0 ] && echo "PASS agent-memory-verify ($N file bo nho: moi muc co ma + evidence + last_verified + bo-khi, khong tai dung ma)"
  return "$RC"
}

# [v2] Bang do "agent co gioi len khong": so muc, SUSPECT, va so lan user SUA viec cua tung vai theo thang
# (dem event /learn co truong "agent"). Chuyen gia gioi len = cot sua giam dan theo thang. Khong chan gi.
run_stats() {
  echo "| Vai | Muc nho | SUSPECT | Lan user sua theo thang (tu $MEM_EVENTS) |"
  echo "|---|---|---|---|"
  ROLES="$(memory_files | sed 's#.*/##; s#\.md$##')"
  if [ -f "$MEM_EVENTS" ]; then
    ROLES="$(printf '%s\n%s\n' "$ROLES" "$(sed -n 's/.*"agent" *: *"\([A-Za-z0-9_-]*\)".*/\1/p' "$MEM_EVENTS")" | sort -u)"
  fi
  for r in $ROLES; do
    [ -n "$r" ] || continue
    F="$MEM_DIR/$r.md"
    if [ -f "$F" ]; then
      NM="$(ids_of < "$F" | wc -l | tr -d ' ')"
      NS="$(lint_file "$F" 2>/dev/null | grep -c '^WARN.*SUSPECT')"
    else NM=0; NS=0; fi
    BYM="-"
    if [ -f "$MEM_EVENTS" ]; then
      BYM="$(grep "\"agent\" *: *\"$r\"" "$MEM_EVENTS" | sed -n 's/.*"at" *: *"\([0-9][0-9][0-9][0-9]-[0-9][0-9]\).*/\1/p' \
        | sort | uniq -c | awk '{ printf "%s%s:%s", (n++ ? " " : ""), $2, $1 } END { if (!n) printf "-" }')"
    fi
    echo "| $r | $NM | $NS | $BYM |"
  done
}

case "${1:-all}" in
  --self-test)
    T="$(mktemp -d)" || exit 1; trap 'rm -rf "$T"' EXIT; RC=0
    t() { # t <ten> <rc mong doi> <chuoi phai co trong output | -> [chuoi KHONG duoc co]
      OUT="$(cd "$T" && MEM_DIR="m" MEM_TODAY=2026-11-25 MEM_MAX_ENTRIES=6 sh "$SELFV0" ${MODE:-} 2>&1)"; GOT=$?
      if [ "$GOT" -eq "$2" ] && { [ "$3" = "-" ] || echo "$OUT" | grep -q "$3"; } && { [ -z "${4:-}" ] || ! echo "$OUT" | grep -q "$4"; }; then echo "PASS: $1"
      else echo "FAIL: $1 (rc=$GOT, mong $2) — $OUT"; RC=1; fi
    }
    OK='- [M-001] Bang gia tinh theo chuyen, khong theo tan | scope: domain:pricing | evidence: a1b2c3d | last_verified: 2026-11-01 | bỏ khi: doi mo hinh gia'
    e() { printf -- '- [M-%03d] %s | evidence: a | last_verified: 2026-11-01 | bo khi: B\n' "$1" "$2"; }
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
    { echo '# x'; for i in 1 2 3 4 5 6 7; do e "$i" "muc so $i"; done; } > "$T/m/ui-expert.md"
    t "vuot tran so muc -> BLOCK" 1 "tran 6"
    printf '# x\n- [M-001] A | evidence: a | last_verified: 2025-01-01 | bo khi: B\n' > "$T/m/ui-expert.md"
    t "muc cu qua TTL -> WARN, KHONG chan" 0 "SUSPECT"
    # [v2] trung khang dinh giua hai vai -> WARN, khong chan
    printf '# x\n- [M-001] Bang gia tinh theo chuyen, khong theo tan | scope: domain:pricing | evidence: b | last_verified: 2026-11-01 | bo khi: C\n' > "$T/m/ui-expert.md"
    t "cung khang dinh o 2 vai -> WARN, KHONG chan" 0 "trung khang dinh"
    # chong-oan 3: khang dinh ngan/khac nhau -> khong WARN
    printf '# x\n- [M-001] Nut chinh mau cam | evidence: b | last_verified: 2026-11-01 | bo khi: C\n' > "$T/m/ui-expert.md"
    t "khang dinh khac nhau -> khong WARN trung" 0 "PASS agent-memory-verify" "trung khang dinh"
    # [v2] lich su git: can git
    if command -v git >/dev/null 2>&1; then
      ( cd "$T" && git init -q . && git config user.email t@t && git config user.name t \
        && { echo '# x'; for i in 1 2 3 4 5; do e "$i" "muc lich su $i"; done; } > m/ui-expert.md \
        && git add -A && git commit -qm base --no-verify )
      # chong-oan 4: them ma ke tiep + sua noi dung muc cu + xoa 1 muc -> qua
      { echo '# x'; for i in 1 2 4; do e "$i" "muc lich su $i"; done; e 5 "muc lich su 5 da sua noi dung"; e 6 "muc moi dung ma ke tiep"; } > "$T/m/ui-expert.md"
      t "them ma ke tiep + sua + xoa tung dong -> qua" 0 "PASS agent-memory-verify" "viet lai ca file"
      # M-003 bi xoa o mot commit truoc, roi ma 3 duoc dung lai cho khang dinh khac
      ( cd "$T" && { echo '# x'; for i in 1 2 4 5; do e "$i" "muc lich su $i"; done; } > m/ui-expert.md \
        && git add -A && git commit -qm "xoa M-003" --no-verify )
      { echo '# x'; for i in 1 2 4 5; do e "$i" "muc lich su $i"; done; e 3 "tai dung ma da xoa"; } > "$T/m/ui-expert.md"
      t "tai dung ma da xoa -> BLOCK" 1 "tai dung"
      ( cd "$T" && { echo '# x'; for i in 1 2 3 4 5; do e "$i" "muc lich su $i"; done; } > m/ui-expert.md \
        && git add -A && git commit -qm "khoi phuc" --no-verify )
      { echo '# x'; e 6 "viet lai a"; e 7 "viet lai b"; } > "$T/m/ui-expert.md"
      t "mat qua nua muc (viet lai ca file) -> WARN, KHONG chan" 0 "viet lai ca file"
      # chong-oan 5: file moi chua tung commit -> khong so lich su
      { echo '# x'; e 1 "file moi chua commit"; } > "$T/m/verifier.md"
      { echo '# x'; for i in 1 2 3 4 5; do e "$i" "muc lich su $i"; done; } > "$T/m/ui-expert.md"
      t "file moi chua commit -> qua" 0 "PASS agent-memory-verify"
    else echo "SKIP: fixture lich su (khong co git)"; fi
    # [v2] --stats: dem lan sua theo vai + thang
    mkdir -p "$T/docs/learning"
    printf '{"at":"2026-09-02T00:00:00Z","agent":"ui-expert"}\n{"at":"2026-09-20T00:00:00Z","agent":"ui-expert"}\n{"at":"2026-10-05T00:00:00Z","agent":"ui-expert"}\n{"at":"2026-10-06T00:00:00Z"}\n' > "$T/docs/learning/events.jsonl"
    MODE=--stats t "--stats dem sua theo thang" 0 "| ui-expert | 5 | 0 | 2026-09:2 2026-10:1 |"
    MODE=--stats t "--stats vai chua co event -> gach" 0 "| verifier | 1 | 0 | - |"
    echo "--- self-test: $([ $RC -eq 0 ] && echo ALL PASS || echo CO FAIL) ---"; exit $RC ;;
  --stats) run_stats ;;
  *) run_all ;;
esac
