# 钣金展开-放样展平计算器

面向钣金工、铆工、白铁工、风管加工和现场安装人员的 iPhone 离线买断工具。

## 产品决策

| 项目 | 决策 |
|---|---|
| App 名称 | 钣金展开-放样展平计算器 |
| 项目目录 | `banjin-zhankai` |
| 平台 | iPhone / iOS |
| 首发市场 | 中国区，简体中文 |
| 商业模式 | Paid App，一次买断 |
| 中国区价格 | ¥18 |
| 广告 / 订阅 | 无 |
| 账号 / 后端 | 无 |
| 主分类 | 工具 |
| 次分类 | 效率 |

## 文档

- [产品立项说明](docs/01-product-brief.md)
- [产品需求文档 PRD](docs/02-prd.md)
- [iOS 商品元信息与 ASO](docs/03-ios-metadata-aso.md)
- [App Store Connect 基础字段](docs/04-appstore-connect.md)
- [关键词与竞品依据](docs/05-keyword-evidence.md)

## 首发原则

首发版本只解决一个完整工作：

```text
选择构件
→ 查看示意图并输入尺寸
→ 计算展开尺寸与素线
→ 生成带尺寸的展开图
→ 保存、导出或分享
```

不做账号、云端计算、社区、行情、接单平台和自动续费。计算结果用于辅助放样和下料，实际加工前必须结合图纸、材料、工艺和现场尺寸复核。

## Google Play / Android

Android 项目已加入，applicationId 为 `com.cc.banjinzhankai`。英文 Google Play 素材包含六张真实 Android 截图、图标、横幅和商店文案。

- [上架素材与预览](google-play/README.md)
- [另一台电脑的构建、测试和本地签名步骤](google-play/android-release.md)
- [提交前检查](google-play/release-checklist.md)

```bash
flutter pub get
flutter build apk --debug --target-platform android-arm64 --dart-define=APP_LANGUAGE=en
```

两个计算器的中文构建保持默认；海外 Android 构建需带 `--dart-define=APP_LANGUAGE=en`。
