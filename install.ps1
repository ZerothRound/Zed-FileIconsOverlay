[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [Parameter()][string]$IconRoot = "$env:LOCALAPPDATA\ZedFileIcons\file-icons",
    [Parameter()][string]$ProgIdPrefix = "Zed"
)

$ErrorActionPreference = 'Stop'

$IconByExt = @{
    'c'='c.ico'; 'h'='c.ico'; 'm'='c.ico'
    'c++'='cpp.ico'; 'cc'='cpp.ico'; 'cpp'='cpp.ico'; 'cxx'='cpp.ico'; 'h++'='cpp.ico'; 'hh'='cpp.ico'; 'hpp'='cpp.ico'; 'hxx'='cpp.ico'
    'cs'='csharp.ico'; 'cshtml'='csharp.ico'; 'csproj'='csharp.ico'; 'csx'='csharp.ico'
    'css'='css.ico'
    'ascx'='html.ico'; 'asp'='html.ico'; 'aspx'='html.ico'; 'htm'='html.ico'; 'html'='html.ico'; 'jshtm'='html.ico'; 'shtml'='html.ico'; 'xhtml'='html.ico'
    'cjs'='javascript.ico'; 'coffee'='javascript.ico'; 'js'='javascript.ico'; 'jscsrc'='javascript.ico'; 'jshintrc'='javascript.ico'; 'mjs'='javascript.ico'
    'jsx'='react.ico'; 'tsx'='react.ico'
    'ts'='typescript.ico'
    'json'='json.ico'; 'ipynb'='json.ico'
    'md'='markdown.ico'; 'markdown'='markdown.ico'; 'mdoc'='markdown.ico'; 'mdown'='markdown.ico'; 'mdtext'='markdown.ico'; 'mdtxt'='markdown.ico'; 'mdwn'='markdown.ico'; 'mkd'='markdown.ico'; 'mkdn'='markdown.ico'
    'py'='python.ico'; 'pyi'='python.ico'
    'ps1'='powershell.ico'; 'psd1'='powershell.ico'; 'psm1'='powershell.ico'
    'bash'='shell.ico'; 'bash_login'='shell.ico'; 'bash_logout'='shell.ico'; 'bash_profile'='shell.ico'; 'bashrc'='shell.ico'; 'profile'='shell.ico'; 'sh'='shell.ico'; 'zsh'='shell.ico'
    'dtd'='xml.ico'; 'svg'='xml.ico'; 'wxi'='xml.ico'; 'wxl'='xml.ico'; 'wxs'='xml.ico'; 'xaml'='xml.ico'; 'xml'='xml.ico'
    'eyaml'='yaml.ico'; 'eyml'='yaml.ico'; 'yaml'='yaml.ico'; 'yml'='yaml.ico'
    'cfg'='config.ico'; 'cmake'='config.ico'; 'config'='config.ico'; 'containerfile'='config.ico'; 'dockerfile'='config.ico'; 'editorconfig'='config.ico'; 'gitattributes'='config.ico'; 'gitconfig'='config.ico'; 'gitignore'='config.ico'; 'gradle'='config.ico'; 'ini'='config.ico'; 'properties'='config.ico'; 'toml'='config.ico'
    'bowerrc'='bower.ico'
    'go'='go.ico'
    'jade'='jade.ico'
    'jav'='java.ico'; 'java'='java.ico'; 'jsp'='java.ico'
    'less'='less.ico'
    'php'='php.ico'; 'phtml'='php.ico'
    'erb'='ruby.ico'; 'gemspec'='ruby.ico'; 'rb'='ruby.ico'
    'sass'='sass.ico'; 'scss'='sass.ico'
    'sql'='sql.ico'
    'vue'='vue.ico'
}

$ZedExtensions = @(
    'ascx','asp','aspx','bash','bash_login','bash_logout','bash_profile','bashrc','bib','bowerrc',
    'c','c++','cc','cfg','cjs','clj','cljs','cljx','clojure','cls','cmake','code-workspace',
    'coffee','config','containerfile','cpp','cs','cshtml','csproj','css','csv','csx','ctp','cxx',
    'dart','diff','dockerfile','dot','dtd','editorconfig','edn','erb','eyaml','eyml','fs','fsi',
    'fsscript','fsx','gemspec','gitattributes','gitconfig','gitignore','go','gradle','groovy','h',
    'h++','handlebars','hbs','hh','hpp','htm','html','hxx','ini','ipynb','jade','jav','java','js',
    'jscsrc','jshintrc','jshtm','json','jsp','jsx','less','log','lua','m','makefile','markdown',
    'md','mdoc','mdown','mdtext','mdtxt','mdwn','mjs','mk','mkd','mkdn','ml','mli','npmignore',
    'php','phtml','pl','pl6','plist','pm','pm6','pod','pp','profile','properties','ps1','psd1',
    'psgi','psm1','py','pyi','r','rb','rhistory','rprofile','rs','rst','rt','sass','scss','sh',
    'shtml','sql','svg','t','tex','toml','ts','tsx','txt','vb','vue','wxi','wxl','wxs','xaml',
    'xhtml','xml','yaml','yml','zsh'
)

function Invoke-ShellAssociationRefresh {
    $source = @"
using System;
using System.Runtime.InteropServices;

public static class ShellRefresh {
    [DllImport("shell32.dll")]
    public static extern void SHChangeNotify(int wEventId, uint uFlags, IntPtr dwItem1, IntPtr dwItem2);
}
"@
    Add-Type -TypeDefinition $source -ErrorAction SilentlyContinue
    [ShellRefresh]::SHChangeNotify(0x08000000, 0, [IntPtr]::Zero, [IntPtr]::Zero)
}

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$sourceIconRoot = Join-Path $scriptRoot 'file-icons'
if (-not (Test-Path $sourceIconRoot)) {
    throw "Missing bundled file-icons directory next to install.ps1"
}

if ($PSCmdlet.ShouldProcess($IconRoot, 'Copy Zed Explorer file icon assets')) {
    New-Item -Path $IconRoot -ItemType Directory -Force | Out-Null
    Copy-Item -Path (Join-Path $sourceIconRoot '*.ico') -Destination $IconRoot -Force
}

$written = 0
$missingProgIds = @()
foreach ($ext in $ZedExtensions) {
    $progId = "$ProgIdPrefix.$ext"
    $progIdKey = "HKCU:\Software\Classes\$progId"
    if (-not (Test-Path $progIdKey)) {
        $missingProgIds += $progId
        continue
    }

    $iconName = if ($IconByExt.ContainsKey($ext)) { $IconByExt[$ext] } else { 'default.ico' }
    $iconPath = Join-Path $IconRoot $iconName
    $defaultIconKey = Join-Path $progIdKey 'DefaultIcon'

    if ($PSCmdlet.ShouldProcess($defaultIconKey, "Set default icon to $iconPath")) {
        New-Item -Path $defaultIconKey -Force | Out-Null
        Set-Item -Path $defaultIconKey -Value $iconPath
        $written += 1
    }
}

$sourceFileKey = "HKCU:\Software\Classes\${ProgIdPrefix}SourceFile\DefaultIcon"
if (Test-Path "HKCU:\Software\Classes\${ProgIdPrefix}SourceFile") {
    $defaultIcon = Join-Path $IconRoot 'default.ico'
    if ($PSCmdlet.ShouldProcess($sourceFileKey, "Set default icon to $defaultIcon")) {
        New-Item -Path $sourceFileKey -Force | Out-Null
        Set-Item -Path $sourceFileKey -Value $defaultIcon
    }
}

if ($PSCmdlet.ShouldProcess('Explorer', 'Refresh shell associations')) {
    Invoke-ShellAssociationRefresh
}

Write-Host "Zed file icon overlay installed. Updated $written ProgID DefaultIcon entries."
if ($missingProgIds.Count -gt 0) {
    Write-Warning "Skipped $($missingProgIds.Count) missing Zed ProgIDs. Install official Stable Zed with file associations enabled, then rerun this script if needed."
}
Write-Host "If Explorer still shows cached icons, sign out/in or clear the Windows icon cache."
