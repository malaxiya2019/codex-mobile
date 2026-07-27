#!/bin/bash
# 给 Termux 源码注入 ChinaCode 配置
set -e

cd termux-app

# ============================================
# 1. 修复新版 AGP/Gradle 兼容性
# ============================================
echo "📝 修复 AGP 兼容性..."

# 1a. app/build.gradle: compileSdkVersion → compileSdk
sed -i 's/compileSdkVersion project.properties.compileSdkVersion.toInteger()/compileSdk project.properties.compileSdkVersion.toInteger()/' \
  app/build.gradle

# 1b. termux-shared/build.gradle: compileSdkVersion → compileSdk
sed -i 's/compileSdkVersion project.properties.compileSdkVersion.toInteger()/compileSdk project.properties.compileSdkVersion.toInteger()/' \
  termux-shared/build.gradle

# ============================================
# 2. 改包名和应用名（实现与原版 Termux 共存）
# ============================================
echo "📝 修改包名为 com.chinacode.mobile..."

# 2a. TermuxConstants.java
sed -i 's/TERMUX_PACKAGE_NAME = "com\.termux"/TERMUX_PACKAGE_NAME = "com.chinacode.mobile"/' \
  termux-shared/src/main/java/com/termux/shared/termux/TermuxConstants.java

# 2b. app/build.gradle - 添加 applicationId（在 defaultConfig 块内）
sed -i '/minSdkVersion/i\        applicationId "com.chinacode.mobile"' \
  app/build.gradle

# 2c. app/build.gradle - 改 manifestPlaceholders
sed -i 's/manifestPlaceholders\.TERMUX_PACKAGE_NAME = "com\.termux"/manifestPlaceholders.TERMUX_PACKAGE_NAME = "com.chinacode.mobile"/' \
  app/build.gradle
sed -i 's/manifestPlaceholders\.TERMUX_APP_NAME = "Termux"/manifestPlaceholders.TERMUX_APP_NAME = "ChinaCode"/' \
  app/build.gradle

# 2d. 改 namespace
sed -i 's/namespace "com\.termux"/namespace "com.chinacode.mobile"/' \
  app/build.gradle 2>/dev/null || true

# 2e. app strings.xml
sed -i 's/ENTITY TERMUX_PACKAGE_NAME "com\.termux"/ENTITY TERMUX_PACKAGE_NAME "com.chinacode.mobile"/' \
  app/src/main/res/values/strings.xml
sed -i 's/ENTITY TERMUX_APP_NAME "Termux"/ENTITY TERMUX_APP_NAME "ChinaCode"/' \
  app/src/main/res/values/strings.xml

# 2f. termux-shared strings.xml
sed -i 's/ENTITY TERMUX_PACKAGE_NAME "com\.termux"/ENTITY TERMUX_PACKAGE_NAME "com.chinacode.mobile"/' \
  termux-shared/src/main/res/values/strings.xml
sed -i 's/ENTITY TERMUX_APP_NAME "Termux"/ENTITY TERMUX_APP_NAME "ChinaCode"/' \
  termux-shared/src/main/res/values/strings.xml

# ============================================
# 3. 添加首次启动设置注入
# ============================================
echo "📝 注入首次启动配置..."
mkdir -p app/src/main/java/com/termux/app
cat > app/src/main/java/com/termux/app/CodexMobileSetup.java << 'JAVA'
package com.termux.app;

import android.content.res.AssetManager;
import java.io.*;

public class CodexMobileSetup {
    public static void install(File homeDir, AssetManager am) {
        try {
            File marker = new File(homeDir, ".chinacode-done");
            if (marker.exists()) return;

            InputStream in = am.open("codex-mobile/setup.tar.gz");
            File tmp = new File(homeDir, ".chinacode-setup.tar.gz");
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

# ============================================
# 4. 在 TermuxService.onCreate() 尾部注入调用
# ============================================
echo "📝 注入 Service 钩子..."
sed -i '/SystemEventReceiver.registerPackageUpdateEvents(this);/a\        CodexMobileSetup.install(new java.io.File(getFilesDir(), "home"), getAssets());' \
  app/src/main/java/com/termux/app/TermuxService.java 2>/dev/null || true

echo ""
echo "✅ 补丁完成！"
echo "   包名: com.chinacode.mobile"
echo "   应用名: ChinaCode"
echo "   已注入首次启动配置"
