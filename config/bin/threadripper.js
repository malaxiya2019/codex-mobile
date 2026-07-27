const fs = require('fs');
const path = require('path');
const initSqlJs = require('sql.js');

const CONFIG_PATH = `${process.env.HOME}/.codex/config.toml`;
const DB_PATH = `${process.env.HOME}/.codex/sessions.db`;

let current = '';
let db = null;

function getCurrentProvider() {
  try {
    const config = fs.readFileSync(CONFIG_PATH, 'utf8');
    const match = config.match(/model_provider\s*=\s*"([^"]+)"/);
    return match ? match[1] : '';
  } catch { return ''; }
}

async function updateProvider(provider) {
  if (!db) return;
  try {
    const stmt = db.prepare('UPDATE sessions SET provider = ?');
    stmt.run([provider]);
    stmt.free();
    const data = db.export();
    fs.writeFileSync(DB_PATH, Buffer.from(data));
    console.log(`[Threadripper] 已更新会话 provider 为: ${provider}`);
    current = provider;
  } catch (err) {
    console.error('[Threadripper] 更新失败:', err.message);
  }
}

(async () => {
  try {
    const SQL = await initSqlJs();
    if (fs.existsSync(DB_PATH)) {
      const buf = fs.readFileSync(DB_PATH);
      db = new SQL.Database(buf);
    } else {
      db = new SQL.Database();
      db.run('CREATE TABLE IF NOT EXISTS sessions (id INTEGER PRIMARY KEY, provider TEXT)');
    }

    current = getCurrentProvider();
    if (current) {
      await updateProvider(current);
    }

    fs.watchFile(CONFIG_PATH, { interval: 1000 }, async () => {
      const newProvider = getCurrentProvider();
      if (newProvider && newProvider !== current) {
        await updateProvider(newProvider);
      }
    });

    console.log('[Threadripper] 已启动，监控 config.toml 变化...');
  } catch (err) {
    console.error('[Threadripper] 初始化失败:', err.message);
    process.exit(1);
  }
})();
