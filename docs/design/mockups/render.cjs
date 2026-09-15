// Mclash 设计稿截图脚本
// 运行: NODE_PATH=/opt/homebrew/lib/node_modules node render.cjs
// 输出: docs/design/img/*.png  （每个 .stage 一张，按 .cap 文案命名）
const { chromium } = require('playwright');
const path = require('path');
const fs = require('fs');

const DIR = __dirname;
const OUT = path.join(DIR, '..', 'img');

function slug(s) {
  return s
    .replace(/[★🎨·]/g, '')
    .replace(/\s+/g, '-')
    .replace(/[（）()【】\/\\:*?"<>|]/g, '')
    .replace(/-+/g, '-')
    .replace(/^-|-$/g, '');
}

async function shoot(browser, file, prefix, scale) {
  const page = await browser.newPage({
    viewport: { width: 1400, height: 1000 },
    deviceScaleFactor: scale,
  });
  await page.goto('file://' + path.join(DIR, file));
  await page.waitForTimeout(1200); // 等字体加载
  const stages = await page.$$('.stage');
  let i = 0;
  for (const el of stages) {
    const cap = await el.evaluate((n) => {
      const c = n.querySelector('.cap');
      return c ? c.textContent.trim() : '';
    });
    const name = `${prefix}-${String(++i).padStart(2, '0')}-${slug(cap)}.png`;
    await el.screenshot({ path: path.join(OUT, name) });
    console.log('✓', name, '—', cap);
  }
  // 整页总览
  await page.screenshot({ path: path.join(OUT, `${prefix}-00-总览.png`), fullPage: true });
  console.log('✓', `${prefix}-00-总览.png`);
  await page.close();
}

(async () => {
  fs.mkdirSync(OUT, { recursive: true });
  const browser = await chromium.launch({ channel: 'chrome', headless: true });
  await shoot(browser, 'mobile.html', 'mobile', 2);
  await shoot(browser, 'desktop.html', 'desktop', 2);
  await shoot(browser, 'index.html', 'overview', 2);
  await browser.close();
  console.log('\n输出目录:', OUT);
  console.log('文件数:', fs.readdirSync(OUT).filter((f) => f.endsWith('.png')).length);
})();
