<p align="center">
  <img src="docs/assets/zclips-logo.png" width="96" alt="zClips Logo">
</p>

# zClips

zClips 是一个简洁的 macOS 状态栏剪贴板工具，用来找回最近复制过的内容。

![zClips 产品截图](docs/assets/zclips-screenshot.png)

## 功能

- 记录文字、图片、文件复制历史
- `Option + Space` 打开或隐藏历史面板
- 支持搜索、分类筛选、收藏
- 点击记录只选中，不会直接覆盖剪贴板
- `Command + C` 或右侧复制按钮复制记录
- 图片可直接用系统预览打开
- 点击其他地方自动隐藏

## 下载

在 Releases 页面下载最新版：

[下载 zClips](https://github.com/stekovinbranturry/light-clip/releases)

安装包命名示例：

```text
zClips-v0.1.1-macOS.zip
```

## 本地打包

```bash
./script/package_app.sh release
```

产物在 `dist/` 目录。
