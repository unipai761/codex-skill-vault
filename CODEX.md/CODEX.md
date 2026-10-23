# Codex Skill Vault 规则

## 目标

维护本机 Codex skills 的可追溯清单、个人维护副本与可重复部署流程。源仓库不默认复制 Codex 缓存、插件运行时或未确认许可的第三方内容。

## 目录约定

- `manifest/`：机器可读的 skill 来源、版本、状态和许可记录。
- `skills/`：仅存放确认可分发、由本人维护的 skill。
- `scripts/`：只读盘点、备份、差异预览和受控部署脚本。
- `docs/`：维护流程与迁移说明。
- `work/`：临时分析文件，按任务清理；不进入 Git。
- `Abstract.md`：本地工作摘要，不进入 Git。

## 命名与格式

- Skill 目录使用其 `SKILL.md` 中声明的稳定名称，目录名使用小写 kebab-case。
- 清单使用 UTF-8 JSON；每个条目必须记录安装来源、版本/提交或未知状态及分发许可状态。
- 脚本使用英文命名和参数，默认只读或 dry-run；覆盖安装前必须生成带时间戳备份并展示差异。

## 维护边界

- 不收集或提交 `.env`、密钥、令牌、密码、用户数据、插件缓存和运行时依赖。
- 未核实许可和上游来源的第三方 skill 只记录元数据，不复制进 `skills/`。
- 本机清单生成不得改动 `C:\Users\33877\.codex` 下的文件。
- GitHub 推送、公开发布、删除文件或修改系统级配置需要用户单独明确授权。

## 验证

- 用 `scripts/inventory.ps1 -Check` 比对本机安装项与清单。
- 修改或部署前运行 `scripts/inventory.ps1 -OutputPath work\inventory.json` 并检查差异。
- 更新后核验每个目标目录包含有效 `SKILL.md`，并复核备份与 Git diff。
