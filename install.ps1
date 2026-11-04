#Requires -Version 5.1
# Installs Obel Mono for the current user (no admin needed) and applies the Glass Glow
# theme to every Windows Terminal install found. settings.json is backed up first.

$ErrorActionPreference = 'Stop'
$fontUrl = 'https://typographic.systems/download/ObelMono-1.000-ttf.zip'

function Install-ObelMono {
    $fontDir = "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    $fonts = @{
        'ObelMono[wght].ttf'        = 'Obel Mono Regular (TrueType)'
        'ObelMono-Italic[wght].ttf' = 'Obel Mono Italic (TrueType)'
    }

    $missing = @($fonts.Keys | Where-Object { -not (Test-Path -LiteralPath "$fontDir\$_") })
    if ($missing.Count -eq 0) {
        Write-Host 'Obel Mono is already installed.'
        return
    }

    Write-Host 'Downloading Obel Mono...'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $temp = Join-Path $env:TEMP ("obel-mono-" + [Guid]::NewGuid())
    New-Item -ItemType Directory -Path $temp | Out-Null
    try {
        Invoke-WebRequest -Uri $fontUrl -OutFile "$temp\font.zip" -UseBasicParsing
        Expand-Archive -LiteralPath "$temp\font.zip" -DestinationPath "$temp\font"

        Add-Type -Name FontApi -Namespace GlassGlow -MemberDefinition @'
[DllImport("gdi32.dll", CharSet=CharSet.Unicode)] public static extern int AddFontResourceW(string f);
[DllImport("user32.dll", CharSet=CharSet.Unicode)] public static extern IntPtr SendMessageTimeoutW(IntPtr h, uint m, IntPtr w, string l, uint fl, uint t, out IntPtr r);
'@
        New-Item -ItemType Directory -Force -Path $fontDir | Out-Null
        $registry = 'HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Fonts'
        if (-not (Test-Path $registry)) { New-Item -Path $registry -Force | Out-Null }

        foreach ($name in $missing) {
            $target = "$fontDir\$name"
            Copy-Item -LiteralPath "$temp\font\ObelMono-1.000-ttf\variable\$name" -Destination $target
            New-ItemProperty -Path $registry -Name $fonts[$name] -Value $target -PropertyType String -Force | Out-Null
            [GlassGlow.FontApi]::AddFontResourceW($target) | Out-Null
        }

        # Tell running apps that the font list changed (HWND_BROADCAST, WM_FONTCHANGE).
        $result = [IntPtr]::Zero
        [GlassGlow.FontApi]::SendMessageTimeoutW([IntPtr]0xffff, 0x001D, [IntPtr]::Zero, $null, 2, 2000, [ref]$result) | Out-Null
        Write-Host 'Installed Obel Mono.'
    }
    finally {
        Remove-Item -LiteralPath $temp -Recurse -Force
    }
}

function Set-Property($object, $name, $value) {
    if ($object.PSObject.Properties[$name]) { $object.$name = $value }
    else { $object | Add-Member -NotePropertyName $name -NotePropertyValue $value }
}

# settings.json may contain comments and trailing commas, which ConvertFrom-Json rejects
# on Windows PowerShell. Each pattern matches strings first so their contents are kept.
function ConvertFrom-Jsonc($text) {
    $string = '"(?:\\.|[^"\\])*"'
    $text = [regex]::Replace($text, "($string)|//[^\r\n]*|/\*[\s\S]*?\*/", '$1')
    $text = [regex]::Replace($text, "($string)|,(?=\s*[}\]])", '$1')
    return $text | ConvertFrom-Json
}

function Add-GlassTheme($stateDir, $theme) {
    $settingsPath = "$stateDir\settings.json"
    $shaderPath = "$stateDir\glass-glow.hlsl"
    Copy-Item -LiteralPath "$PSScriptRoot\glass-glow.hlsl" -Destination $shaderPath -Force

    if (Test-Path -LiteralPath $settingsPath) {
        $settings = ConvertFrom-Jsonc ([IO.File]::ReadAllText($settingsPath))
        $backup = "$settingsPath.glass-backup-$(Get-Date -Format yyyyMMdd-HHmmss)"
        Copy-Item -LiteralPath $settingsPath -Destination $backup
        Write-Host "Backed up settings to $backup"
    }
    else {
        $settings = New-Object PSObject
    }

    if (-not $settings.PSObject.Properties['profiles']) {
        Set-Property $settings 'profiles' (New-Object PSObject)
    }
    if (-not $settings.profiles.PSObject.Properties['defaults']) {
        Set-Property $settings.profiles 'defaults' (New-Object PSObject)
    }
    foreach ($property in $theme.profileDefaults.PSObject.Properties) {
        Set-Property $settings.profiles.defaults $property.Name $property.Value
    }
    Set-Property $settings.profiles.defaults 'experimental.pixelShaderPath' $shaderPath

    $schemes = @($settings.schemes | Where-Object { $_ -and $_.name -ne $theme.scheme.name }) + $theme.scheme
    $themes = @($settings.themes | Where-Object { $_ -and $_.name -ne $theme.theme.name }) + $theme.theme
    Set-Property $settings 'schemes' $schemes
    Set-Property $settings 'themes' $themes
    Set-Property $settings 'theme' $theme.theme.name

    [IO.File]::WriteAllText($settingsPath, ($settings | ConvertTo-Json -Depth 32))
    Write-Host "Applied Glass Glow to $settingsPath"
}

$stateDirs = @(
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
    "$env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState"
    "$env:LOCALAPPDATA\Microsoft\Windows Terminal"
) | Where-Object { Test-Path -LiteralPath $_ }

if (-not $stateDirs) {
    throw 'Windows Terminal settings folder not found. Install Windows Terminal, open it once, then run this again.'
}

Install-ObelMono
$theme = [IO.File]::ReadAllText("$PSScriptRoot\glass-theme.json") | ConvertFrom-Json
foreach ($dir in $stateDirs) { Add-GlassTheme $dir $theme }
Write-Host 'Done. Close all Windows Terminal windows and reopen them.'
