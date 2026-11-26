# ADR 004 — Agent chuyên gia vỏ mỏng + bộ nhớ theo vai trong git (đánh giá agency-agents, không cài)

- **Ngày**: 2026-11-25 · **Trạng thái**: PROPOSED trên nhánh `feat/expert-agents-memory` (chờ owner duyệt merge) · **Thi công**: v1.27.0
- **Nguồn đánh giá**: github.com/msitarzewski/agency-agents tại commit `8ae6164` (2026-11-08), MIT.
- **Quy trình**: một phiên, đọc repo nguồn + đo bằng lệnh. KHÔNG qua hội đồng nhiều agent — ghi rõ để không bị đọc nhầm là án lệ hội đồng.

## Quyết định

Không cài agency-agents. Nội hoá ba ý, viết lại:

1. **Mỗi vai chuyên gia một file agent** — nhưng là vỏ mỏng: vai, ranh giới, dạng trả về. Chuyên môn ở lại trong skill (`ba-flow-logic`, `ui-design-logic`, `ui-ux-triage`, `security-logic`). Bốn agent: `ba-expert`, `ui-expert`, `security-expert`, `verifier`.
2. **Người thẩm định mặc định "chưa đạt"** → `verifier`: lấy tiêu chí từ spec, tự chạy lệnh, lời kể không phải bằng chứng.
3. **Agent có trí nhớ qua phiên** → `docs/agent-memory/<vai>.md`, là file trong git, mỗi mục một dòng có mã + `evidence` + `last_verified` + `bỏ khi`, trần 40 mục, có cổng máy `agent-memory-verify.sh`.

Số bản sắc (nguyên tắc / lớp / skill) KHÔNG đổi: agent là cách đóng gói vai, không phải skill hay nguyên tắc mới.

## Đo được gì ở nguồn (tại `8ae6164`)

| Điều đo | Lệnh | Kết quả |
|---|---|---|
| File có mục "Learning & Memory" | `grep -rlE '^## .*(Learning\|Memory)' --include='*.md' . \| wc -l` | 262 |
| Bộ nhớ thật nằm ở đâu | đọc `integrations/mcp-memory/README.md` | một MCP server ngoài, không kèm theo repo; README chỉ yêu cầu server có 4 tool `remember/recall/rollback/search` |
| Lint agent kiểm gì | đọc `scripts/lint-agents.sh` | frontmatter `name/description/color` là lỗi; các mục nội dung chỉ cảnh báo |
| Cỡ file agent | `wc -l engineering/*.md testing/*.md` | khoảng 200–700 dòng mỗi file |

## Phản biện — vì sao không lấy nguyên

- **"Memory" phần lớn là văn tả vai.** Dòng "You remember…" trong file agent không lưu gì. Phần lưu thật giao cho một MCP server người dùng tự tìm, với chỉ dẫn để mô hình tự quyết nhớ gì. Không có bằng chứng, không hạn dùng, không phạm vi, không nằm trong git nên không duyệt được và không đồng bộ giữa hai máy. Với hệ này đó là đúng lỗi nguyên tắc 12 đã nêu: tiền đề cũ không đánh dấu thì agent vẫn tin.
- **Persona không phải chuyên môn.** Chuyên môn trong file agent là danh sách chung của nghề, cộng giả định stack cứng: `testing-reality-checker.md` chạy `ls resources/views` và một script chụp ảnh không có ở project của ta. Chép về là có lệnh ma.
- **Chép luật vào từng agent là hai nguồn sự thật.** Skill đổi thì agent lệch (bài học #08/#10: copy = drift). Vì vậy agent ở đây chỉ trỏ tới `SKILL.md`.
- **Đội hình lớn tốn routing.** Mỗi agent thêm một description vào context của mọi phiên; vai trùng nhau làm việc chọn agent kém đi. Ta chỉ thêm vai nào đã có skill + cổng máy đứng sau.
- **Điểm mạnh thật của nguồn, ta chưa cần:** một nguồn → convert sang nhiều công cụ với test đầu ra từng byte; manifest phân khu đối chiếu thư mục trên đĩa. Ghi nhận, không làm lúc này vì ta mới có bốn agent.

## Vì sao bộ nhớ là file trong `docs/`, không dùng `memory:` của Claude Code

Đo trên binary Claude Code 2.1.331 (`strings | grep agent-memory`): frontmatter `memory` của subagent có ba phạm vi, `project` lưu ở `.claude/agent-memory/<agentType>/`. Tính năng có thật, nhưng không dùng vì:
- dạng ghi do harness quyết, ta không ép được một-dòng-có-bằng-chứng;
- chỉ Claude Code đọc; file trong `docs/` thì công cụ nào cũng đọc được bằng một lệnh Read;
- chưa đo hành vi nạp (giới hạn dòng, thứ tự) nên không được ghi thành lời hứa.

Đổi lại: agent tốn một lần Read đầu việc.

## Lời bảo đảm và chỗ hở (nói thẳng)

- Máy kiểm **hình dạng** mục nhớ. Bằng chứng có đúng không là việc của `verifier` và người duyệt diff.
- Agent có đọc bộ nhớ và skill đầu việc hay không là prompt-level, chưa có cổng máy.
- `agent-memory-verify.sh` chạy trong `npm test` và `doctor`; **chưa nối pre-commit** và thư mục `docs/agent-memory/` **chưa nằm trong phạm vi lint prompt-injection** của hook. Nợ: nối cả hai sau khi chạy thử trên ForFish ít nhất hai tuần không chặn oan (đổi hook là YELLOW).
- Chưa có số đo hiệu quả (agent có bộ nhớ làm ít sai hơn không). Điều kiện rollback: sau một quý, nếu file bộ nhớ ở project tiêu thụ trống hoặc toàn mục SUSPECT không ai soát → gỡ bộ nhớ, giữ agent.

## Phản biện vòng 2 (cùng ngày, trước khi merge)

Đối chiếu lại agency-agents (HEAD vẫn `8ae6164`, 170.199★ đo qua GitHub API ngày 2026-11-25) và khảo sát khoảng 40 repo về bộ nhớ agent (letta-code, mem0, Graphiti, cognee, MemOS, LangMem, claude-mem, basic-memory), cách tự cải thiện (ACE, DSPy/GEPA, Reflexion, Voyager) và framework điều phối team (crewAI, LangGraph, MetaGPT, agno). Kết luận vòng 1 giữ nguyên: không cài framework nào, bộ nhớ là file trong git. Bốn chỗ hở được vá:

| Chỗ hở của vòng 1 | Vá | Nguồn ý tưởng |
|---|---|---|
| Bước "đọc SKILL.md" chỉ là lời dặn trong prompt; ở repo nguồn đường `.claude/skills/...` còn không tồn tại | Frontmatter `skills:` → Claude Code tự nạp skill vào context agent. Đo trên binary 2.1.331 (`strings`): schema có `skills` "Array of skill names to preload into the agent context". Giữ đường dự phòng Read cho công cụ khác và cho repo nguồn (`skills/<tên>/SKILL.md`) | Docs sub-agents của Claude Code |
| Giao thức nói "không tái dùng mã" nhưng máy không kiểm | `agent-memory-verify.sh` so với HEAD: mã mới ≤ mã lớn nhất ở HEAD → FAIL | — |
| Không có gì ngăn AI viết lại cả file nhớ (mòn chi tiết, mất bằng chứng) | Luật "sửa từng dòng" + WARN khi mất quá nửa số mục so với HEAD | ACE (Agentic Context Engineering): delta update thay vì viết lại, chống "context collapse" |
| "Agent giỏi lên theo thời gian" không đo được | Event `/learn` có trường `agent`; `agent-memory-verify.sh --stats` đếm số lần user sửa từng vai theo tháng | Không nguồn nào trong khảo sát đo chỉ số này — các nguồn chỉ đo benchmark |
| Một sự thật ghi ở hai vai sẽ lệch nhau | WARN khi cùng khẳng định nằm ở ≥ 2 file vai | Bài học #08/#10: copy = drift |

Không làm (có lý do):
- **Bộ đếm helpful/harmful từng mục kiểu ACE**: agent phải tự cập nhật số đếm sau mỗi việc → prompt-level, dễ thành số tự chấm. Thay bằng số đo từ event `/learn` (user thật sửa).
- **Thêm agent UX / user-flow riêng**: user flow nằm trong `ba-flow-logic`, UX nằm trong `ui-design-logic` + `ui-ux-triage`. Tách vai không có skill riêng đứng sau chỉ thêm chi phí chọn agent.
- **Dùng `memory:` của Claude Code**: lý do vòng 1 vẫn đúng. Docs nay xác nhận hành vi nạp (200 dòng hoặc 25KB đầu `MEMORY.md`), nhưng dạng ghi vẫn do harness quyết và chỉ Claude Code đọc.
- **Nối pre-commit**: giữ điều kiện vòng 1 (chạy thử trên ForFish hai tuần không chặn oan).

Chỗ hở còn lại (nêu tên):
- Kiểm tái dùng mã chỉ so với một mốc (HEAD): xoá đúng mã lớn nhất rồi dùng lại chính số đó ở commit sau thì không bắt được.
- `--stats` chỉ đúng khi `/learn` được chạy và ghi `agent`. Không chạy `/learn` thì bảng trống, không có nghĩa là không ai sửa.
- Nạp sẵn hai skill UI làm context ui-expert tăng khoảng 43KB mỗi lần gọi (trước đây agent chỉ Read một trong hai).
