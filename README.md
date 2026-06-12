# Zed Windows File Icons Overlay

[中文](#中文) | [English](#english)

## 中文

让 Windows 资源管理器中由官方 Stable Zed 关联的源码文件显示更细分的文件类型图标，而不是全部显示同一个 Zed 图标。

仓库简介：

> Windows Explorer file-icon overlay for official Stable Zed, using VS Code-style `.ico` assets and per-extension `DefaultIcon` registry entries.

### 适用范围

- 仅面向 Windows 上的官方 Stable Zed。
- 只影响 Windows 资源管理器里的文件图标。
- 不修改 Zed 编辑器内部的 Project Panel / 文件树图标主题。
- 不修改 Windows 受保护的 `UserChoice` 默认应用哈希。

### 使用方法

下载或解压本仓库后，在 PowerShell 中进入仓库目录运行：

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\install.ps1
```

脚本会：

- 复制图标到 `%LOCALAPPDATA%\ZedFileIcons\file-icons`。
- 为已有的 `HKCU\Software\Classes\Zed.<ext>\DefaultIcon` 写入对应 `.ico` 路径。
- 通知 Explorer 刷新文件关联。

如果 Explorer 仍显示旧图标，请注销并重新登录，或清理 Windows 图标缓存。

### 卸载

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\uninstall.ps1
```

卸载脚本只删除本覆盖包写入的 `DefaultIcon` 键和复制到本机的图标目录。

### Zed 更新后是否需要重跑

不一定每次都需要。官方 Zed 更新如果没有重写文件关联，图标会继续保留；如果更新后图标变回默认 Zed 图标，重新运行 `install.ps1` 即可。脚本是幂等的，可以重复运行。

### 说明

本项目是个人使用的覆盖补丁，不是 Zed 官方项目。图标资产来自本地 VS Code 风格 `.ico` 文件包；请在符合相关许可的前提下使用和分发。

## English

Show more specific file-type icons in Windows Explorer for source files associated with official Stable Zed, instead of showing the same Zed icon for every associated file.

Repository description:

> Windows Explorer file-icon overlay for official Stable Zed, using VS Code-style `.ico` assets and per-extension `DefaultIcon` registry entries.

### Scope

- Targets official Stable Zed on Windows only.
- Affects Windows Explorer file icons only.
- Does not change Zed's in-app Project Panel or file-tree icon theme.
- Does not modify Windows protected `UserChoice` default-app hashes.

### Usage

Download or extract this repository, open PowerShell in the repository directory, then run:

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\install.ps1
```

The installer script will:

- Copy icons to `%LOCALAPPDATA%\ZedFileIcons\file-icons`.
- Set matching `.ico` paths under `HKCU\Software\Classes\Zed.<ext>\DefaultIcon`.
- Notify Explorer to refresh shell associations.

If Explorer still shows cached icons, sign out and back in, or clear the Windows icon cache.

### Uninstall

```powershell
Set-ExecutionPolicy -Scope Process Bypass -Force
.\uninstall.ps1
```

The uninstall script removes only the `DefaultIcon` keys written by this overlay and the copied local icon directory.

### Do I Need To Re-run This After Updating Zed?

Not always. If the official Zed updater does not rewrite file associations, the icons should stay. If Explorer falls back to the default Zed icon after an update, run `install.ps1` again. The script is idempotent.

### Notes

This is a personal overlay patch and is not affiliated with the official Zed project. The icon assets come from a local VS Code-style `.ico` bundle; use and redistribute them only when allowed by the relevant licenses.
