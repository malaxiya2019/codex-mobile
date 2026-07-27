#!/bin/bash
# 给 Termux 源码注入 ChinaCode 配置
set -e

cd termux-app

# ============================================
# 1. 修复新版 AGP/Gradle 兼容性
# ============================================
echo "📝 修复 AGP 兼容性..."

sed -i 's/compileSdkVersion project.properties.compileSdkVersion.toInteger()/compileSdk project.properties.compileSdkVersion.toInteger()/' \
  app/build.gradle

sed -i 's/compileSdkVersion project.properties.compileSdkVersion.toInteger()/compileSdk project.properties.compileSdkVersion.toInteger()/' \
  termux-shared/build.gradle

# ============================================
# 2. 改包名（安装包名）和显示名称
# ============================================
echo "📝 修改包名为 com.chinacode.mobile..."

# 2a. TermuxConstants.java - 改 TERMUX_PACKAGE_NAME（影响 PREFIX 路径）
sed -i 's/TERMUX_PACKAGE_NAME = "com\.termux"/TERMUX_PACKAGE_NAME = "com.chinacode.mobile"/' \
  termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java

# 2b. app/build.gradle - 添加 applicationId
sed -i '/minSdkVersion/i\        applicationId "com.chinacode.mobile"' \
  app/build.gradle

# 2c. app/build.gradle - 改 manifestPlaceholders
sed -i 's/manifestPlaceholders\.TERMUX_PACKAGE_NAME = "com\.termux"/manifestPlaceholders.TERMUX_PACKAGE_NAME = "com.chinacode.mobile"/' \
  app/build.gradle
sed -i 's/manifestPlaceholders\.TERMUX_APP_NAME = "Termux"/manifestPlaceholders.TERMUX_APP_NAME = "ChinaCode"/' \
  app/build.gradle

# 2d. app strings.xml
sed -i 's/ENTITY TERMUX_PACKAGE_NAME "com\.termux"/ENTITY TERMUX_PACKAGE_NAME "com.chinacode.mobile"/' \
  app/src/main/res/values/strings.xml
sed -i 's/ENTITY TERMUX_APP_NAME "Termux"/ENTITY TERMUX_APP_NAME "ChinaCode"/' \
  app/src/main/res/values/strings.xml

# 2e. termux-shared strings.xml
sed -i 's/ENTITY TERMUX_PACKAGE_NAME "com\.termux"/ENTITY TERMUX_PACKAGE_NAME "com.chinacode.mobile"/' \
  termux-shared/src/main/res/values/strings.xml
sed -i 's/ENTITY TERMUX_APP_NAME "Termux"/ENTITY TERMUX_APP_NAME "ChinaCode"/' \
  termux-shared/src/main/res/values/strings.xml

# ============================================
# 3. 添加 CodexMobileSetup.java（首次启动设置）
#    从 assets 解压 bootstrap.tar.gz 到 PREFIX
#    从 assets 解压 setup.tar.gz 到 HOME
#    在 TermuxService 检查 PREFIX 之前执行
# ============================================
echo "📝 注入首次启动配置 (CodexMobileSetup)..."

mkdir -p app/src/main/java/com/termux/app
cat > app/src/main/java/com/termux/app/CodexMobileSetup.java << 'JAVA'
package com.termux.app;

import android.content.res.AssetManager;
import java.io.*;

public class CodexMobileSetup {
    public static void install(File filesDir, AssetManager am) {
        try {
            File prefixDir = new File(filesDir, "usr");
            File loginFile = new File(prefixDir, "bin/login");

            // 第一步：解压 bootstrap（如果 login 不存在）
            if (!loginFile.exists()) {
                prefixDir.mkdirs();
                extractTarGz(am, "codex-mobile/bootstrap.tar.gz", prefixDir);
                // 确保 login 可执行
                if (loginFile.exists()) {
                    loginFile.setExecutable(true, false);
                }
                // 递归设置 bin 目录下所有文件可执行
                setBinExecutable(prefixDir);
            }

            // 第二步：解压 home 配置
            File homeDir = new File(filesDir, "home");
            File marker = new File(homeDir, ".chinacode-done");
            if (!marker.exists()) {
                homeDir.mkdirs();
                extractTarGz(am, "codex-mobile/setup.tar.gz", homeDir);
                try { marker.createNewFile(); } catch (Exception ignored) {}
            }
        } catch (Exception ignored) {}
    }

    private static void extractTarGz(AssetManager am, String assetPath, File destDir) throws IOException {
        InputStream in = am.open(assetPath);
        File tmp = File.createTempFile("chinacode-", ".tar.gz");
        FileOutputStream out = new FileOutputStream(tmp);
        byte[] buf = new byte[8192];
        int len;
        while ((len = in.read(buf)) != -1) out.write(buf, 0, len);
        out.close();
        in.close();

        try {
            Process p = Runtime.getRuntime().exec(
                new String[]{"tar", "xzf", tmp.getAbsolutePath(), "-C", destDir.getAbsolutePath()}
            );
            p.waitFor();
        } finally {
            tmp.delete();
        }
    }

    private static void setBinExecutable(File prefixDir) {
        File binDir = new File(prefixDir, "bin");
        if (binDir.isDirectory()) {
            File[] files = binDir.listFiles();
            if (files != null) {
                for (File f : files) {
                    f.setExecutable(true, false);
                }
            }
        }
    }
}
JAVA

# ============================================
# 4. 在 TermuxService.onCreate() 最开头注入
#    确保在 PREFIX 检查之前执行
# ============================================
echo "📝 注入 Service 钩子 (onCreate 开头)..."
sed -i '/super.onCreate();/a\        CodexMobileSetup.install(getFilesDir(), getAssets());' \
  app/src/main/java/com/termux/app/TermuxService.java 2>/dev/null || true

echo ""
echo "✅ 补丁完成！"
echo "   包名(applicationId): com.chinacode.mobile"
echo "   应用名: ChinaCode"
echo "   PREFIX: 独立 (/data/data/com.chinacode.mobile/files/usr)"
echo "   内置 bootstrap: ✅ 首次启动自动从 APK 解压"
echo "   内置配置: ✅ 首次启动自动解压到 home"
