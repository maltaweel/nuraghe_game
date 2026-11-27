// Headless phone test of the web export. Usage: node tests/web_test.js <url> <outdir> <mode: win|lose>
// Needs playwright-core (NODE_PATH) and a system chromium. Taps real screen coordinates of Godot buttons,
// read from the ?autotest probe (main.gd), so input goes through the normal touch path.
const { chromium } = require('playwright-core');
const fs = require('fs');
const [url, out, mode] = process.argv.slice(2);
fs.mkdirSync(out, { recursive: true });
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
(async () => {
  const browser = await chromium.launch({ executablePath: '/usr/bin/chromium',
    args: ['--no-sandbox', '--use-angle=swiftshader', '--enable-unsafe-swiftshader', '--ignore-gpu-blocklist'] });
  const ctx = await browser.newContext({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 2, isMobile: true,
    hasTouch: true, acceptDownloads: true, locale: 'en-GB' });
  const page = await ctx.newPage();
  const requests = [];
  page.on('request', (r) => requests.push(r.url()));
  page.on('console', (m) => { if (m.type() === 'error' || m.text().includes('ERROR')) console.log('console:', m.text()); });
  const t0 = Date.now();
  await page.goto(url + '?autotest', { waitUntil: 'load' });
  await page.waitForFunction(() => typeof window.nuraghe_probe === 'function', null, { timeout: 120000 });
  console.log('loaded in', (Date.now() - t0) / 1000, 's');
  const dpr = await page.evaluate(() => window.devicePixelRatio);
  async function probe() {
    await page.evaluate(() => window.nuraghe_probe());
    return JSON.parse(await page.evaluate(() => window.nuraghe_out));
  }
  async function tap(text, nth = 0) {
    const p = await probe();
    let bs = p.buttons.filter((b) => b.text === text);
    if (bs.length <= nth) bs = p.buttons.filter((b) => b.text.startsWith(text));
    if (bs.length <= nth) return false;
    await page.touchscreen.tap(bs[nth].x / dpr, bs[nth].y / dpr);
    await sleep(350);
    return true;
  }
  const shot = async (name) => { await sleep(500); await page.screenshot({ path: `${out}/${name}.png` }); console.log('shot', name); };
  await sleep(1500);
  await shot('01_menu');
  await tap('Level 1');
  await shot('02_level_intro');
  await tap('Next');
  const q = mode === 'win' ? 'near' : 'far';
  const h = mode === 'win' ? 'rollers' : 'sledge';
  const l = mode === 'win' ? 'stair' : 'ramp';
  await shot('03_choose_quarry');
  if (mode === 'win') { await tap('Source', 1); await shot('04_source_card_far_quarry'); await tap('Close'); }
  await tap('Choose', q === 'near' ? 0 : 1);
  if (mode === 'win') { await shot('05_choose_haul'); await tap('Source', 2); await shot('06_source_card_oxen'); await tap('Close'); }
  await tap('Choose', ['sledge', 'rollers', 'oxen'].indexOf(h));
  if (mode === 'win') await shot('07_choose_lift');
  await tap('Choose', ['lever', 'stair', 'ramp', 'pulley'].indexOf(l));
  await shot(`08_start_${mode}`);
  await tap('Start building');
  await tap('x1'); await tap('x2');
  if (mode === 'win') { for (let k = 0; k < 6; k++) await tap('+1'); }
  let midShot = false, askShot = false, reqShot = false, lastAsk = -10;
  for (let i = 0; i < 3000; i++) {
    const p = await probe();
    const s = p.state;
    const texts = p.buttons.map((b) => b.text);
    if (texts.includes('Try other choices')) break;
    if (texts.includes('Send them builders')) {
      if (!reqShot) { await shot(`11_request_${mode}`); reqShot = true; }
      await tap(mode === 'win' ? 'Send them builders' : 'Refuse');
      continue;
    }
    if (texts.includes('Start building')) { await tap('Start building'); continue; }
    if (texts.includes('OK')) { await tap('OK'); continue; }
    if (mode === 'win' && s.builders < 16 && !s.modal && s.stores > 300) { await tap('+5'); }
    if (mode === 'win' && !s.modal && s.day - lastAsk >= 1 && (midShot || s.day < 68)) {
      lastAsk = s.day;
      await tap('Ask a village');
      const p2 = await probe();
      if (!askShot) { await shot('10_ask_help'); askShot = true; }
      if (p2.buttons.some((b) => b.text === 'Ask')) await tap('Ask');
      else await tap('Close');
      continue;
    }
    if (!midShot && s.day >= 70 && !s.modal) {
      await tap('Pause'); const pc = await probe();
      if (!pc.state.modal) { await shot(`09_midgame_${mode}`); midShot = true; }
      await tap('Play'); continue;
    }
    await sleep(250);
    if (i % 20 === 0) console.log('day', s.day, 'built', (s.progress * 100).toFixed(0), 'stores', Math.round(s.stores), 'builders', s.builders);
  }
  await sleep(800);
  await shot(`12_end_${mode}`);
  // scroll to the strategy record
  await page.touchscreen.tap(195, 400);
  await page.mouse.move(195, 600); await page.mouse.wheel(0, 1400); await sleep(800);
  await shot(`13_end_${mode}_strategy`);
  const p = await probe();
  fs.writeFileSync(`${out}/strategy_${mode}.json`, p.record);
  const dl = page.waitForEvent('download', { timeout: 8000 }).catch(() => null);
  await tap('Save as file');
  const d = await dl;
  if (d) { await d.saveAs(`${out}/download_${mode}.json`); console.log('download ok', d.suggestedFilename()); }
  const ext = requests.filter((u) => !u.startsWith(url.replace(/\/[^/]*$/, '')));
  console.log('result', JSON.parse(p.record).outcome.result, 'days', JSON.parse(p.record).outcome.working_days,
    'requests', requests.length, 'non-local', ext.length, ext.slice(0, 5));
  const storage = await page.evaluate(async () => ({ cookies: document.cookie, ls: localStorage.length,
    idb: (indexedDB.databases ? (await indexedDB.databases()).map((d) => d.name) : 'n/a'),
    caches: (await caches.keys()) }));
  console.log('storage', JSON.stringify(storage));
  await browser.close();
})().catch((e) => { console.error(e); process.exit(1); });
