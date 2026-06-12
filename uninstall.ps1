[CmdletBinding(SupportsShouldProcess = $true)]
Param(
    [Parameter()][string]$IconRoot = "$env:LOCALAPPDATA\ZedFileIcons\file-icons",
    [Parameter()][string]$ProgIdPrefix = "Zed"
)

$ErrorActionPreference = 'Stop'

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

$removed = 0
foreach ($ext in $ZedExtensions) {
    $defaultIconKey = "HKCU:\Software\Classes\$ProgIdPrefix.$ext\DefaultIcon"
    if (Test-Path $defaultIconKey) {
        if ($PSCmdlet.ShouldProcess($defaultIconKey, 'Remove overlay DefaultIcon key')) {
            Remove-Item -Path $defaultIconKey -Recurse -Force
            $removed += 1
        }
    }
}

$sourceFileKey = "HKCU:\Software\Classes\${ProgIdPrefix}SourceFile\DefaultIcon"
if (Test-Path $sourceFileKey) {
    if ($PSCmdlet.ShouldProcess($sourceFileKey, 'Remove overlay SourceFile DefaultIcon key')) {
        Remove-Item -Path $sourceFileKey -Recurse -Force
    }
}

$iconParent = Split-Path -Parent $IconRoot
if (Test-Path $iconParent) {
    if ($PSCmdlet.ShouldProcess($iconParent, 'Remove copied Zed file icon assets')) {
        Remove-Item -Path $iconParent -Recurse -Force
    }
}

if ($PSCmdlet.ShouldProcess('Explorer', 'Refresh shell associations')) {
    Invoke-ShellAssociationRefresh
}

Write-Host "Zed file icon overlay removed. Removed $removed DefaultIcon keys."
