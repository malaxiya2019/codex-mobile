#!/bin/bash
# 给 Termux 源码注入 Codex Mobile 配置
set -e

cd termux-app

# 1. 添加 CodexMobileSetup.java
mkdir -p app/src/main/java/com/termux/app
cat > app/src/main/java/com/termux/app/CodexMobileSetup.java << 'JAVA'
package com.termux.app;

import android.content.res.AssetManager;
import java.io.*;

public class CodexMobileSetup {
    public static void install(File homeDir, AssetManager am) {
        try {
            File marker = new File(homeDir, ".codex-mobile-done");
            if (marker.exists()) return;

            // 从 assets 读取 setup.tar.gz 并解压到 home 目录
            InputStream in = am.open("codex-mobile/setup.tar.gz");
            File tmp = new File(homeDir, ".codex-mobile.tar.gz");
            FileOutputStream out = new FileOutputStream(tmp);
            byte[] buf = new byte[8192];
            int len;
            while ((len = in.read(buf)) != -1) out.write(buf, 0, len);
            out.close();
            in.close();

            Process p = Runtime.getRuntime().exec(
                new String[]{"tar", "xzf", tmp.getAbsolutePath(), "-C", homeDir.getAbsolutePath()}
            );
            p.waitFor();
            tmp.delete();
            marker.createNewFile();
        } catch (Exception ignored) {}
    }
}
JAVA

# 2. 在 TermuxService.onCreate() 尾部注入调用
#    目标行: SystemEventReceiver.registerPackageUpdateEvents(this);
#    在其后插入: CodexMobileSetup.install(...)
sed -i '/SystemEventReceiver.registerPackageUpdateEvents(this);/a\        CodexMobileSetup.install(new java.io.File(getFilesDir(), "home"), getAssets());' \
  app/src/main/java/com/termux/app/TermuxService.java 2>/dev/null || true

echo "✅ 补丁完成"
