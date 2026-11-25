# NOTICE — nguồn ý tưởng đã nội hoá / Idea provenance

> Repo này KHÔNG chứa code hay văn bản sao chép từ các dự án dưới đây. Các luật liên quan là
> **ý tưởng được viết lại hoàn toàn** bằng tiếng Việt, theo cấu trúc và tiêu chí riêng của ai-simple,
> qua hội đồng phản biện 2026-08-13/14 (docs/adr/002). Mỗi luật nội hoá mang mã nguồn-ý-tưởng
> (`PT-*` / `HM-*` / `IMP-*` / `AG-*`) + dòng "ép bởi <enforcer>"; `scripts/rule-enforcer-gate.js` kiểm
> enforcer đó có thật.
>
> QUY TẮC CỦA FILE NÀY: ghi **commit** đối chiếu — CẤM ghi version string hay bất kỳ con số
> đếm-được nào của thượng nguồn (số gate/rule/command). Lý do đo được: số gate tự khai của một
> nguồn từng đi 70 → 57 → 58 trong 48 giờ, và tại đúng commit đối chiếu, hai file trong cùng cây
> ghi hai con số khác nhau. Ta đếm gate của ta.

| Mã | Dự án | License | Commit đối chiếu (ngày) | Ý tưởng đã nội hoá (viết lại — vị trí trong repo) |
|---|---|---|---|---|
| `PT-*` | Ponytail — github.com/DietrichGebert/ponytail | MIT | `2ed6c52` (2026-08-07) | Thang quyết định chống over-engineering, guardrails không-được-lười, marker nợ có điều kiện nâng cấp → `methodology/15`, `templates/CLAUDE.md.template` §Quy tắc viết code, hook 1f |
| `HM-*` | Hallmark — github.com/Nutlope/hallmark | MIT | `13ac0ec` (2026-08-06) | Gate anti-slop phổ quát (metric bịa, fake chrome, focus, contrast-cặp, nested card, caps-leading...) → `skills/ui-design-logic` 06 §2 + 02/03/04, hook 1d |
| `IMP-*` | Impeccable — github.com/pbakaus/impeccable | Apache-2.0 | `ddd23b18` (2026-08-13) | Ý "token ngoài hệ đã khai" (gate type-ramp), semantic HTML, browser surfaces, mode theo mục tiêu người xem (enum Type), motion chỉ transform/opacity → hook 1d + `ui-design-logic` 01 §7, 04 §3/§4b/§6 |
| `AG-*` | The Agency — github.com/msitarzewski/agency-agents | MIT | `8ae6164` (2026-11-08) | Ý "mỗi vai chuyên gia một file agent", ý "người thẩm định mặc định chưa đạt, đòi bằng chứng", ý "agent mang trí nhớ qua phiên" → `templates/*-expert.agent.md.template`, `templates/verifier.agent.md.template`, `templates/agent-memory-README.md.template`; ép bởi `skills/ai-simple-product-dev/agent-memory-verify.sh`. Phần KHÔNG lấy và lý do: `docs/adr/004` |

Nghĩa vụ license (thực dụng, không phải tư vấn pháp lý): MIT/Apache-2.0 ràng buộc việc phân phối
**code/văn bản** của họ — repo này không phân phối thứ đó; file NOTICE này tồn tại vì minh bạch
nguồn ý tưởng là đúng tinh thần cả hai license và vì chính ta cần tra lại khi luật gây tranh cãi.
Copy-check (so bản viết lại với corpus nguồn, ngưỡng trùng <15 từ liên tiếp) chạy tay trước mỗi
lần phát hành có đụng luật nội hoá — kết quả ghi vào docs/adr/002.

Nhịp soát: mỗi quý (`/audit`), so các commit trên với HEAD thượng nguồn — ra đúng 1 dòng kết luận
"có/không ý tưởng mới đáng nội hoá tiếp", không diff chi tiết. Ta chấp nhận tụt sau upstream
(họ commit hàng trăm lần/quý) — đổi lấy việc làm chủ 100% luật đang chạy.
