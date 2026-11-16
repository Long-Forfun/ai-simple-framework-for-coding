#!/usr/bin/env node
/**
 * ui-fingerprint — ĐO "vẻ AI" của code giao diện trên cả repo (v1.28.0).
 *
 * Vì sao tồn tại: lời than số một là "UI ra AI style", nhưng trước bản này hệ không có con số nào
 * cho nó. Hook 1d chỉ soi DÒNG THÊM của từng commit; checklist 06 §2 chấm bằng mắt từng màn.
 * Không ai trả lời được "repo này lệch luật màu/hình bao xa, tháng này tốt hơn tháng trước không".
 *
 * Đây là BÁO CÁO, không phải cổng: luôn exit 0, không in BLOCK/WARN, không nằm trong đường commit.
 * Các mẫu dưới là heuristic grep — đủ để so trước/sau và cho Critic đọc, không đủ để chặn ai.
 * Mốc so sánh là luật của ui-design-logic (ref 04 §1, §3, §4), không phải gu.
 *
 * Dùng:  ai-simple ui-fingerprint [thư-mục] [--json]      |   node lib/ui-fingerprint.js --self-test
 */
'use strict';
const fs = require('fs');
const path = require('path');

const SKIP = /^(node_modules|\.git|dist|build|out|\.next|\.nuxt|android|ios|_generated|coverage|vendor|test-reports|\.vercel)$/;
const UI_EXT = /\.(tsx|jsx|vue|svelte|html)$/;
const NOT_UI = /\.(test|spec|stories)\./;
const NEUTRAL = new Set(['slate', 'gray', 'zinc', 'neutral', 'stone']);
const FAMILY = /\b(?:bg|text|border|ring|from|to|via|fill|stroke)-(slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose)-\d{2,3}\b/g;

// Mỗi mẫu: [khoá, regex, luật gốc]. Đếm số lần xuất hiện / 1000 dòng code UI.
const PATTERNS = [
  ['gradient-nen', /bg-gradient-to-|linear-gradient\(|radial-gradient\(/g, 'gradient trang trí vô cớ — 06 §2'],
  ['gradient-chu', /text-transparent/g, 'gradient trên chữ, không đo được contrast — 04 §1 (hook 1d-g chặn dòng mới)'],
  ['ho-tim', /\b(?:bg|text|border|ring|from|to|via)-(?:purple|violet|indigo|fuchsia)-\d{2,3}\b/g, 'họ tím/chàm mặc định của công cụ sinh UI — chỉ hợp lệ khi là accent đã chốt'],
  ['bo-goc-lon', /\brounded-(?:2xl|3xl)\b/g, 'bo góc lớn dùng tràn lan — 04 §4'],
  ['bong-nang', /\bshadow-(?:lg|xl|2xl)\b/g, 'bóng nặng — 04 §4'],
  ['kinh-mo', /\bbackdrop-blur/g, 'kính mờ trang trí — 04 §4'],
  ['phong-khi-re', /\bhover:scale-/g, 'phóng to khi rê chuột — 04 §6 (hook 1d-l nhắc ở dòng mới)'],
  ['emoji', /[\u{1F300}-\u{1FAFF}\u{2728}\u{2B50}\u{2705}\u{274C}]/gu, 'emoji làm icon/trang trí — 04 §3'],
  ['mau-roi', /-\[#[0-9a-fA-F]{3,8}\]|style=\{\{[^}]*#[0-9a-fA-F]{3,8}/g, 'màu hex rời ngoài token — 04 §5'],
];

function walk(dir, out) {
  let ents;
  try { ents = fs.readdirSync(dir, { withFileTypes: true }); } catch { return out; }
  for (const e of ents) {
    if (SKIP.test(e.name)) continue;
    const p = path.join(dir, e.name);
    if (e.isDirectory()) walk(p, out); else out.push(p);
  }
  return out;
}

function measure(root) {
  const files = walk(root, []);
  const ui = files.filter((f) => UI_EXT.test(f) && !NOT_UI.test(f));
  const counts = Object.fromEntries(PATTERNS.map(([k]) => [k, 0]));
  const fam = new Set();
  let loc = 0;
  for (const f of ui) {
    let t; try { t = fs.readFileSync(f, 'utf8'); } catch { continue; }
    loc += t.split('\n').length;
    for (const [k, re] of PATTERNS) counts[k] += (t.match(re) || []).length;
    for (const m of t.matchAll(FAMILY)) fam.add(m[1]);
  }
  const neutral = [...fam].filter((x) => NEUTRAL.has(x)).sort();
  const chroma = [...fam].filter((x) => !NEUTRAL.has(x)).sort();
  const per = (n) => (loc ? +(1000 * n / loc).toFixed(2) : 0);
  return {
    root, uiFiles: ui.length, loc,
    neutralFamilies: neutral, chromaFamilies: chroma,
    perKloc: Object.fromEntries(PATTERNS.map(([k]) => [k, per(counts[k])])),
    counts,
  };
}

function report(m) {
  const L = [];
  L.push(`── ui-fingerprint ${m.root}`);
  if (m.uiFiles === 0) { L.push('  không thấy file giao diện (.tsx/.jsx/.vue/.svelte/.html) — bỏ qua'); return L.join('\n'); }
  L.push(`  ${m.uiFiles} file giao diện · ${m.loc} dòng`);
  // Luật 04 §1: 1 neutral ramp + 1 accent + 4 màu semantic (+ 1 palette riêng nếu có chart nhiều series).
  L.push(`  họ màu neutral: ${m.neutralFamilies.length} (luật: 1)${m.neutralFamilies.length ? ' — ' + m.neutralFamilies.join(', ') : ''}`);
  L.push(`  họ màu có sắc: ${m.chromaFamilies.length} (luật: 1 accent + 4 semantic = 5, chưa tính palette chart)${m.chromaFamilies.length ? ' — ' + m.chromaFamilies.join(', ') : ''}`);
  L.push('  mẫu / 1000 dòng (0 là sạch):');
  for (const [k, , rule] of PATTERNS) if (m.counts[k]) L.push(`    ${k.padEnd(13)} ${String(m.perKloc[k]).padStart(6)}  (${m.counts[k]} chỗ) — ${rule}`);
  if (PATTERNS.every(([k]) => !m.counts[k])) L.push('    (không mẫu nào xuất hiện)');
  L.push('  Báo cáo, không phải cổng: họ màu đặt qua token CSS (var(--…)) không được đếm ở đây — repo dùng token thuần ra 0 họ là ĐÚNG.');
  return L.join('\n');
}

function selfTest() {
  const os = require('os');
  let rc = 0;
  const ok = (n, c) => { console.log(`${c ? 'PASS' : 'FAIL'}: ${n}`); if (!c) rc = 1; };
  const d = fs.mkdtempSync(path.join(os.tmpdir(), 'uifp-'));
  const w = (rel, c) => { const p = path.join(d, rel); fs.mkdirSync(path.dirname(p), { recursive: true }); fs.writeFileSync(p, c); };
  // repo không có UI → không đếm gì, không throw
  let m = measure(d);
  ok('repo không có file giao diện → 0 file, báo "bỏ qua" (chống-oan repo backend)', m.uiFiles === 0 && /bỏ qua/.test(report(m)));
  // UI sạch dùng token thuần → mọi số 0 (chống-oan quan trọng nhất)
  w('src/Clean.tsx', '<button type="button" className="bg-primary text-foreground rounded-md shadow-sm">Lưu</button>\n');
  m = measure(d);
  ok('UI dùng token thuần → 0 họ màu, 0 mẫu (không bắt oan)', m.chromaFamilies.length === 0 && m.neutralFamilies.length === 0 && PATTERNS.every(([k]) => m.counts[k] === 0));
  // UI kiểu AI mặc định
  w('src/Slop.tsx', '<div className="bg-gradient-to-r from-purple-500 to-indigo-600 rounded-3xl shadow-2xl backdrop-blur hover:scale-105">\n<h1 className="text-transparent bg-clip-text">✨ Xin chào</h1>\n<p className="text-gray-500 text-slate-400 text-[#ff0000]">x</p>\n</div>\n');
  m = measure(d);
  ok('đếm đúng: gradient nền + chữ, họ tím, bo góc, bóng, kính mờ, phóng, emoji, màu rời',
    m.counts['gradient-nen'] === 1 && m.counts['gradient-chu'] === 1 && m.counts['ho-tim'] === 2 && m.counts['bo-goc-lon'] === 1
    && m.counts['bong-nang'] === 1 && m.counts['kinh-mo'] === 1 && m.counts['phong-khi-re'] === 1 && m.counts['emoji'] === 1 && m.counts['mau-roi'] === 1);
  ok('đếm họ màu: 2 neutral (gray, slate) + 2 có sắc (indigo, purple)', m.neutralFamilies.join() === 'gray,slate' && m.chromaFamilies.join() === 'indigo,purple');
  // thư mục bị bỏ qua + file test
  w('node_modules/x/Bad.tsx', '<div className="from-purple-500 rounded-3xl" />\n');
  w('src/Slop.test.tsx', '<div className="from-pink-500" />\n');
  const m2 = measure(d);
  ok('bỏ qua node_modules và file *.test.* (số không đổi)', m2.counts['ho-tim'] === 2 && !m2.chromaFamilies.includes('pink'));
  ok('báo cáo không in BLOCK/WARN (là báo cáo thuần)', !/BLOCK|WARN/.test(report(m2)));
  fs.rmSync(d, { recursive: true, force: true });
  console.log(rc ? 'ui-fingerprint self-test: CÓ FAIL' : 'ui-fingerprint self-test: ALL PASS');
  process.exit(rc);
}

function main(argv) {
  if (argv.includes('--self-test')) return selfTest();
  const dir = argv.find((a) => !a.startsWith('--')) || '.';
  const m = measure(dir);
  console.log(argv.includes('--json') ? JSON.stringify(m, null, 1) : report(m));
  process.exit(0);
}

module.exports = { measure, report, main };
if (require.main === module) main(process.argv.slice(2));
