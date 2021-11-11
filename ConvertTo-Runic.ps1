## You need UTF-8 encoding enabled, do this by following this guide: https://akr.am/blog/posts/using-utf-8-in-the-windows-terminal

$local:youngerRunes = @{
    'F' = 'ᚠ';
    'U' = 'ᚢ';
    '$' = 'ᚦ';
    'A' = 'ᛅ';
    'R' = 'ᚱ';
    'C' = 'ᚴ';
    'K' = 'ᚴ';
    '£' = 'ᚴᚼ'; 
    'Q' = 'ᚴ'; 
    'X' = 'ᚴᛋ';
    'G' = 'ᚴ';
    'V' = 'ᚢ';
    'W' = 'ᚢ';
    'H' = 'ᚼ';
    'N' = 'ᚾ';
    'I' = 'ᛁ';
    'J' = 'ᛋ';
    'Y' = 'ᚢ';
    '#' = 'ᛅ'; 
    'P' = 'ᛒ';
    'Z' = 'ᛋ';
    'S' = 'ᛋ';
    'T' = 'ᛏ';
    'B' = 'ᛒ';
    'E' = 'ᛅ';
    'M' = 'ᛘ';
    'L' = 'ᛚ';
    '?' = 'ᚾ';
    'D' = 'ᛏ';
    'O' = 'ᚬ';
    '<' = 'ᚬ';
    '>' = 'ᛅᛅ';
    " " = 'x';
} 

$local:elderRunes = @{
    'F' = 'ᚠ';
    'U' = 'ᚢ';
    '$' = 'ᚦ';
    'A' = 'ᚨ';
    'R' = 'ᚱ';
    'C' = 'ᚲ';
    'K' = 'ᚲ';
    '£' = 'ᚲᚺ';
    'Q' = 'ᚲ'; 
    'X' = 'ᚲᛊ';
    'G' = 'ᚷ';
    'V' = 'ᚢ';
    'W' = 'ᚹ';
    'H' = 'ᚺ';
    'N' = 'ᚾ';
    'I' = 'ᛁ';
    'J' = 'ᛃ';
    'Y' = 'ᛁ';
    '#' = 'ᛖᛁ';
    'P' = 'ᛈ';
    'Z' = 'ᛉ';
    'S' = 'ᛊ';
    'T' = 'ᛏ';
    'B' = 'ᛒ';
    'E' = 'ᛖ';
    'M' = 'ᛗ';
    'L' = 'ᛚ';
    '?' = 'ᛜ';
    'D' = 'ᛞ';
    'O' = 'ᛟ';
    '<' = 'ᛇ';
    '>' = 'ᛖᚨ';
    " " = 'x';
} 

$local:saxonRunes = @{
    'F' = 'ᚠ';
    'U' = 'ᚢ';
    '$' = 'ᚦ';
    'A' = 'ᚪ';
    'R' = 'ᚱ';
    'C' = 'ᚳ';
    'K' = 'ᚳ';
    '£' = 'ᚳᚻ';
    'Q' = 'ᚳ';
    'X' = 'ᚳᛋ';
    'G' = 'ᚷ';
    'V' = 'ᚡ';
    'W' = 'ᚹ';
    'H' = 'ᚻ';
    'N' = 'ᚾ';
    'I' = 'ᛁ';
    'J' = 'ᛄ';
    'Y' = 'ᛁ';
    '#' = 'ᛖᛁ';
    'P' = 'ᛈ';
    'Z' = 'ᛋ';
    'S' = 'ᛋ';
    'T' = 'ᛏ';
    'B' = 'ᛒ';
    'E' = 'ᛖ';
    'M' = 'ᛘ';
    'L' = 'ᛚ';
    '?' = 'ᛝ';
    'D' = 'ᛞ';
    'O' = 'ᚩ';
    '<' = 'ᛇ';
    '>' = 'ᛠ';
    " " = 'x';
}
function Set-Text {
    $local:string = $args[0]
    $string = $string.ToUpper()
    $string = $string -replace "[^a-zA-Z0-9 ']", ''
    $string = $string.replace('EA','>')
    $string = $string.replace('AE','<')
    $string = $string.replace('NG','?')
    $string = $string.replace('IE','#')
    $string = $string.replace('CH','£')
    $string = $string.replace('TH','$')
    return $string
}
Function ConvertTo-Runic {
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory = $true)]
        [string]$string,
        [ValidateSet("elder", "younger", "saxon")]
        [string]$type = "elder"
    )
    $string = Set-Text $string
    $stringlength = ($string | Measure-Object -Character).Characters
    $i=0 ; while ($i -lt $stringlength) { $youngerstring += $youngerRunes.("$($string[$i])") ; $i++ }
    $i=0 ; while ($i -lt $stringlength) { $elderstring += $elderRunes.("$($string[$i])") ; $i++ }
    $i=0 ; while ($i -lt $stringlength) { $saxonstring += $saxonRunes.("$($string[$i])") ; $i++ }
    if ($type -eq "younger") { $youngerstring | set-clipboard ; return $youngerstring }
    if ($type -eq "elder") { $elderstring | set-clipboard ; return $elderstring }
    if ($type -eq "saxon") { $saxonstring | set-clipboard ; return $saxonstring }
} Set-Alias "Runic" ConvertTo-Runic

filter ConvertTo-RunicYounger {
    $string = $_
    $string = Set-Text $string
    $stringlength = ($string | Measure-Object -Character).Characters
    $i=0 ; while ($i -lt $stringlength) { $youngerstring += $youngerRunes.("$($string[$i])") ; $i++ }
    $youngerstring | Set-Clipboard
    return $youngerstring
} Set-Alias "Younger" ConvertTo-RunicYounger

filter ConvertTo-RunicElder {
    $string = $_
    $string = Set-Text $string
    $stringlength = ($string | Measure-Object -Character).Characters
    $i=0 ; while ($i -lt $stringlength) { $elderstring += $elderRunes.("$($string[$i])") ; $i++ }
    $elderstring | Set-Clipboard
    return $elderstring
} Set-Alias "Elder" ConvertTo-RunicElder

filter ConvertTo-RunicSaxon {
    $string = $_
    $string = Set-Text $string
    $stringlength = ($string | Measure-Object -Character).Characters
    $i=0 ; while ($i -lt $stringlength) { $saxonstring += $saxonRunes.("$($string[$i])") ; $i++ }
    $saxonstring | Set-Clipboard
    return $saxonstring
} Set-Alias "Saxon" ConvertTo-RunicSaxon

function ConvertFrom-Runic {
    param(
        [Parameter(ValueFromPipeline=$true,Mandatory = $true)]
        [string]$string
    )
    $ErrorActionPreference = "SilentlyContinue"
    $Runeselder = @{}
    $Runesyounger = @{}
    $Runessaxon = @{}
    foreach($rune in $ElderRunes.keys) { $Runeselder.add($elderRunes[$rune],$rune) }
    foreach($rune in $YoungerRunes.keys) { $Runesyounger.add($youngerRunes[$rune],$rune) }
    foreach($rune in $SaxonRunes.keys) { $Runessaxon.add($SaxonRunes[$rune],$rune) }
    $ErrorActionPreference = "Continue"
    $stringlength = ($string | Measure-Object -Character).Characters
    $i=0 ; while ($i -lt $stringlength) { $convertstring1 += $Runeselder.("$($string[$i])") ; $i++ }
    $i=0 ; while ($i -lt $stringlength) { $convertstring2 += $Runesyounger.("$($string[$i])") ; $i++ }
    $i=0 ; while ($i -lt $stringlength) { $convertstring3 += $Runessaxon.("$($string[$i])") ; $i++ }
    $convertstring = $convertstring1,$convertstring2,$convertstring3 | Sort-Object length -desc | Select-Object -First 1
    $convertstring = $convertstring.replace('>','EA')
    $convertstring = $convertstring.replace('<','AE')
    $convertstring = $convertstring.replace('?','NG')
    $convertstring = $convertstring.replace('#','IE')
    $convertstring = $convertstring.replace('£','CH')
    $convertstring = $convertstring.replace('$','TH')
    $convertstring = $convertstring.replace('Q','C')
    $convertstring = $convertstring.replace('Y','I')
    $convertstring = $convertstring.replace('V','U')
    $convertstring = $convertstring.ToLower()
    return $convertstring
} Set-Alias "FromRunic" ConvertFrom-Runic

function DeRune {
    $texty = get-clipboard | FromRunic
    $texty | set-clipboard
    return $texty
}

function Runify {
    $texty = Get-Clipboard | Runic
    $texty | Set-Clipboard
    return $texty
}

# SIG # Begin signature block
# MIII2wYJKoZIhvcNAQcCoIIIzDCCCMgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3uP23FM6d2wmFsI644YH2U6Y
# v2igggYzMIIGLzCCBRegAwIBAgIKERM1LAABAAABvTANBgkqhkiG9w0BAQsFADBj
# MRIwEAYKCZImiZPyLGQBGRYCdWsxEjAQBgoJkiaJk/IsZAEZFgJjbzEbMBkGCgmS
# JomT8ixkARkWC3VuaXRlLWdyb3VwMRwwGgYDVQQDExNUaGUgVU5JVEUgR3JvdXAg
# UExDMB4XDTIwMDQwMTA5MTM1NloXDTIyMDQwMTA5MjM1NlowgY8xEjAQBgoJkiaJ
# k/IsZAEZFgJ1azESMBAGCgmSJomT8ixkARkWAmNvMRswGQYKCZImiZPyLGQBGRYL
# dW5pdGUtZ3JvdXAxIjAgBgNVBAsTGUluZnJhc3RydWN0dXJlIE1hbmFnZW1lbnQx
# FzAVBgNVBAsTDkFjY291bnRzIEFkbWluMQswCQYDVQQDEwJUQzCCASIwDQYJKoZI
# hvcNAQEBBQADggEPADCCAQoCggEBAL//ziyRxr4OiQbj2OnQKs0/4WUbB6UYb5ez
# 28PAwOHmEciLvwPDEt7YDkdiU95rO1YqtmU+p0Rfk+A5JB2+GUzFV9jiBHSuD5Fn
# D2KxNcAtI6JiRCi1UbgVuDtVADYSUIYQ7rO4GPuHXTkZXp/QJQk+CQ5jCzjbnVFa
# JuFJb8LftrER6zwZf257r1eI+bH4/2AwTyLY5fIT7KtDmnkx84AsCYsZ2qZjJY79
# OwB2miyNqZ3PA8Ody7ckpBqI9s7x15MZkZ39o2a1cxtfRIJrQfr5s1oucckB+tGv
# MgKCIKnmUaRZXeuEo5FU5PR5jmx/AOwSnF7LPacNuOAszpADtzECAwEAAaOCArYw
# ggKyMD0GCSsGAQQBgjcVBwQwMC4GJisGAQQBgjcVCIfIrmGBk4gCgeGTK4WH3VuB
# pIBwgXeD26c15aA3AgFkAgEEMBMGA1UdJQQMMAoGCCsGAQUFBwMDMA4GA1UdDwEB
# /wQEAwIHgDAbBgkrBgEEAYI3FQoEDjAMMAoGCCsGAQUFBwMDMB0GA1UdDgQWBBQf
# puiwPXpN1vA1xapdy9XRrvpieDAfBgNVHSMEGDAWgBT52xEVe7wLpSLqGvpvO71c
# vPpiCzCB5gYDVR0fBIHeMIHbMIHYoIHVoIHShoHPbGRhcDovLy9DTj1UaGUlMjBV
# TklURSUyMEdyb3VwJTIwUExDKDEpLENOPUFQVVBCMDFXQ0EsQ049Q0RQLENOPVB1
# YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRp
# b24sREM9dW5pdGUtZ3JvdXAsREM9Y28sREM9dWs/Y2VydGlmaWNhdGVSZXZvY2F0
# aW9uTGlzdD9iYXNlP29iamVjdENsYXNzPWNSTERpc3RyaWJ1dGlvblBvaW50MIHU
# BggrBgEFBQcBAQSBxzCBxDCBwQYIKwYBBQUHMAKGgbRsZGFwOi8vL0NOPVRoZSUy
# MFVOSVRFJTIwR3JvdXAlMjBQTEMsQ049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNl
# cnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3VyYXRpb24sREM9dW5pdGUtZ3Jv
# dXAsREM9Y28sREM9dWs/Y0FDZXJ0aWZpY2F0ZT9iYXNlP29iamVjdENsYXNzPWNl
# cnRpZmljYXRpb25BdXRob3JpdHkwLwYDVR0RBCgwJqAkBgorBgEEAYI3FAIDoBYM
# FFRDQHVuaXRlLWdyb3VwLmNvLnVrMA0GCSqGSIb3DQEBCwUAA4IBAQCIkTRzdX0M
# zHPdpx4xbx3Xg3hh53Bsp4pdc4xgLAmspB4et/WYOJEdo/gOkIOUnG/UWyAnPq5c
# FYXqdLJI4cHlPMF8mbek8T+2pVq8f0h82Y2ke9sWsLpSC7Lz78T7t2W5lCLPNDRe
# qTbjaRyAw//lCF/Ft4ixncaOrUyBh4YwaUfXi1AbTRbKd5DkR/D3L6xlAAfiB5UG
# VtlEBZSyFYl7PcI3jOXaabbkjT9NTbUh47/42OkOcvVGYdImvipSaPgO2/ZH2LvZ
# 8YU6ZXilnRStmmJGh6RE9pxReuY1FTbcGOHX9uf6ovCSmNJKmi69Ycafj2abtUa3
# KW7Jm+Y5wHXKMYICEjCCAg4CAQEwcTBjMRIwEAYKCZImiZPyLGQBGRYCdWsxEjAQ
# BgoJkiaJk/IsZAEZFgJjbzEbMBkGCgmSJomT8ixkARkWC3VuaXRlLWdyb3VwMRww
# GgYDVQQDExNUaGUgVU5JVEUgR3JvdXAgUExDAgoREzUsAAEAAAG9MAkGBSsOAwIa
# BQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgor
# BgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3
# DQEJBDEWBBSnIBlFaPUN7SE1i0zjzNrPJZU7GTANBgkqhkiG9w0BAQEFAASCAQAJ
# lZ5fqjwJ748Y7IaQ1POolHE156Kx0TTfoWAWt48Tnlpw5NAaKo8WQ2lZb4uUV8uH
# jrC/68QnIWS++s8a8wf59QkgyLmTWp5ZOWj+eIQNnmWnSaQb2NNp3aXtP1hSGQ8w
# NR71DdWtgIvtrna2w6GfzpVEXLV6B/AZfYtIygN5DDRoqEAQZUUEhq5wznWFnfMr
# qQeRdfivOxzOa0SxJVcdgP4QtSwbtvfNQMXtM4I8pCBC8MP15rfUcSx9gzQu6eG3
# 8XLLycSbzhzzvKyFQamfgEOgnMSr0dF2z/MlE0bD1ROjrBEKhyb2SEi9cmc0uFNh
# IbPBDGhYtVWz3nh/EBpa
# SIG # End signature block
