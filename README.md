# Mirage 阿搭视觉创作

Mirage 的 AI 实测与自动化内容视觉资产项目。以「阿搭」河狸搭建员为统一角色，维护角色身份、视觉规则、创作流程与审稿反馈。

## 项目目标

- 统一阿搭 IP 的角色识别与品牌视觉语言。
- 将内容主题转化为头像、横幅、封面、流程配图、信息图与介绍卡。
- 保持角色脸型、毛色、扁尾、马甲和橙色夹子等识别特征。
- 将有效审稿反馈沉淀为可复用规则。
- 明确区分候选/已审定、已生成/已应用、已验证/未验证。

## 目录

- SKILL.md：Mirage 阿搭视觉创作入口。
- references/：视觉规则、研究笔记、素材工作流与反馈规范。
- assets/：阿搭角色参考图、品牌图与其他视觉资产。
- scripts/：Windows 本地自动同步脚本。
- .github/workflows/：基础 Skill 元数据检查。

## 当前默认视觉风格

**暖白科技 3D 品牌风格（V1.1）**：暖白背景、淡紫几何渐变、Mirage 橙紫点缀、高质感阿搭 3D 主体、短标题、少量线性图标与充足留白。详细规范见 [references/visual-rules.md](references/visual-rules.md) 和 [风格预设](references/style-presets/warm-white-tech-3d.md)。

![阿搭暖白科技 3D 风格参考](assets/style-references/ada-warm-white-tech-3d-v1.1.jpg)

## Windows 自动同步

本仓库使用本地文件监听，而不是把本地文件误认为会自动出现在 GitHub 上。首次安装需要在 Windows 上运行一次安装脚本；之后脚本会监听本地 Skill 目录，检测到文件新增、修改或删除后，等待短暂静默时间，再自动提交并推送到 main。

默认本地源目录：
C:\Users\<当前用户>\.codex\skills\mirage-visual-creator

默认仓库工作目录：
C:\Users\<当前用户>\source\mirage-visual-creator

在 Windows PowerShell 中运行：

    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
    & "$env:USERPROFILE\source\mirage-visual-creator\scripts\install-auto-sync.ps1"

首次推送需要通过 Git Credential Manager 完成 GitHub 登录授权。脚本不会把 Personal Access Token 写入仓库，也不会把密钥文件同步到 GitHub。

卸载登录启动任务：

    Unregister-ScheduledTask -TaskName "MirageVisualCreatorAutoSync" -Confirm:$false

## 安全与发布

当前仓库为 Public。提交前请确认文件适合公开。脚本会排除常见密钥、凭据和环境配置文件；.gitignore 也提供额外保护。不要把 API Key、Token、Cookie、账号导出或私人数据放入 assets/ 或 references/。

## 当前导入说明

首次仓库引导已上传当前可读取的 Skill 入口文件与同步基础设施。完整 references/ 和 assets/ 需要从 Windows 本地 Skill 源目录同步；具体缺项见 IMPORT_STATUS.md。不要将缺失的源文件当作已经上传。
