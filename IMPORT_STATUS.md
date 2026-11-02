# 首次导入状态

本文件记录本次可用资料快照的导入边界，不代表完整项目已经全部上传。

## 已导入
- SKILL.md：当前可读取的 Mirage 阿搭视觉创作入口文件。

## 尚待从 Windows 本地源目录导入
入口 Skill 明确引用以下文件，但它们未出现在当前可读取的 Library 文件清单中，因此没有伪造或用占位内容冒充原文件：

- references/visual-rules.md
- references/learning-notes.md
- references/sources.json
- references/asset-workflows.md
- references/review-and-feedback.md
- assets/adap-character-reference.png

运行 scripts/install-auto-sync.ps1 后，脚本会从本地 Skill 目录复制真实文件；当上述文件全部存在时，此状态文件会自动移除。

## 重要
不要把本次引导提交视为完整的视觉资产备份。完整性以本地同步后的 GitHub 文件树为准。
