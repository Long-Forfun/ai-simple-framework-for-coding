# Chấm điểm SẢN PHẨM ai-simple (cho maintainer)

> Khác `/audit` (chấm 1 **project áp dụng** ai-simple theo applicability). Đây chấm **chính sản phẩm** — 15 nguyên tắc + CLI + 5 skill — trả lời "ai-simple đang tốt tới đâu, chỗ nào yếu nhất, sửa gì trước". Thiết kế qua hội đồng team-agent (3 đề xuất → 6 phản biện → judge → synthesize → Red-Skeptic; winner: **machine-first**).

## Triết lý

Điểm = **số GATE máy chạy lại được đang xanh** — mỗi gate tự bào chữa bằng một class bug ĐÃ TỪNG xảy ra (tarball vỡ v1.4.1, Windows vỡ v1.5.0, First-win fail B1 v1.6.0, hook 100× chậm lọt tới ForFish v1.19, manifest thiếu trong tarball v1.22), không gate nào tồn tại vì "nghe có vẻ nên đo". **Không trọng số, không /100**: báo cáo là bảng gate đỏ/xanh + đếm thô — danh sách gate đỏ CHÍNH LÀ "sửa gì trước". Điểm LLM (eval hành vi) **không bao giờ vào mẫu số** — chỉ ADVISORY có điều kiện chốt số tường minh (xem A2).

## 6 GATE máy + 2 lớp ADVISORY

| # | Gate | Đo gì | Lệnh | Trạng thái |
|---|------|-------|------|-----------|
| **G1** | Self-test hợp nhất | hook 13 khối song song (60 PASS) + report + **5/5** skill-verifier + identity-manifest (quét packaged surface) + skills-yaml + cross-cut + update-channel + NT13 + eval-runner + mutation-suite + perf-budget | `npm test` (`test:fast` bỏ job nặng) | ✅ implemented |
| **G2** | Stranger-path E2E | pack→cài tarball→CLI sống→**self-test bản cài không ENOENT**→init→doctor→First-win CHẶN + 10 commit sạch 0 chặn oan + secret/injection chặn + update giữ CONFIG | `npm run stranger-path` (`scripts/stranger-path.js`) | ✅ implemented |
| **G3** | Ship-gate | require-coverage + **runtime-file-coverage** (`path.join(PKG_ROOT,…)`) + template-coverage + link-check trên tarball | `npm run ship-gate` (`prepublishOnly`) | ✅ implemented |
| **G4** | Docs-lint + Dogfood | hook tự cài + đồng bộ template + version-stamp + docs sống không over-claim | `npm run dogfood-gate` | ✅ implemented |
| **G5** | CI matrix 3 OS | G1–G4 + rule-enforcer xanh trên ubuntu + windows + macos (macos thêm 2026-10-20 — xanh local, chờ lượt CI đầu) | `.github/workflows/gates.yml` | ✅ implemented |
| **G6** | Performance budget | hook trên repo 20 doc × 4 covers-path ≤ 20s (regression 100× v1.19 là lý do tồn tại) | `node scripts/perf-budget.js` (trong `npm test` + `gates`) | ✅ implemented (~9–14s) |
| A1 | Security-mutation | 12 ca đột biến security-verify: 0 false-pass / 0 false-block | `sh scripts/mutation-suite.sh` (trong `npm test`) | ✅ built — ADVISORY theo triết lý, nhưng chạy như gate |
| A2 | Eval ngữ nghĩa 5 skill | 34 case × control/treatment × ≥2 judge mù; `--report` chỉ in con số khi đủ 3 điều kiện (phủ 34 / từng case ≥2 vòng đủ / inter-rater ≥80%) | `node scripts/eval-runner.js --report`; giao thức `docs/baseline/semantic-ab-protocol.md`; artifact thô `docs/baseline/semantic-runs/` | ✅ built — ADVISORY, kết quả là "internal recorded result", không phải benchmark ngoài |

## Cách chạy + ngưỡng hành động

- **Local trước publish**: `npm run gates` (G1+G3+G4+G6+rule-enforcer) → `npm run stranger-path` (G2). `prepublishOnly` tự chạy khi `npm publish`.
- **Mỗi push**: CI matrix chạy toàn bộ trên 3 OS.
- **Bất kỳ GATE đỏ → KHÔNG publish.** Nhiều gate đỏ → sửa theo chi-phí-thấp-nhất.
- **Chống bão hoà**: mỗi **lời hứa MỚI** trong README/SKILL phải kèm 1 kịch bản mới trong G2.
- File này nằm trong identity scan (đổi số bản sắc thì đây phải đổi theo, không thì gate đỏ).

## Backlog (còn lại theo thứ tự tác động/effort)

1. **Judge khác họ mô hình cho A2** — hiện thí sinh và judge cùng họ; giao thức không đổi, chỉ đổi `--judge`.
2. **Sửa rubric ở các ô còn bất đồng `pass`/`partial`** — chỗ lệch là rubric mơ hồ, không phải agent kém.
3. **Ngân sách tổng cho `test:fast`** — hiện chỉ G6 có trần; full self-test còn vài phút trên Windows.
4. **Context-benchmark quý** — đắt nhất, ADVISORY; fixture repo dựng bằng `ai-simple init`, answer-key máy, pin model.
