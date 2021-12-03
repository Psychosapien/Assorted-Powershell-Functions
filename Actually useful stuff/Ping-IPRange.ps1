function Ping-IPRange {
    <#
    .SYNOPSIS
        Sends ICMP echo request packets to a range of IPv4 addresses between two given addresses.

    .DESCRIPTION
        This function lets you sends ICMP echo request packets ("pings") to 
        a range of IPv4 addresses using an asynchronous method.

        Therefore this technique is very fast but comes with a warning.
        Ping sweeping a large subnet or network with many swithes may result in 
        a peak of broadcast traffic.
        Use the -Interval parameter to adjust the time between each ping request.
        For example, an interval of 60 milliseconds is suitable for wireless networks.
        The RawOutput parameter switches the output to an unformated
        [System.Net.NetworkInformation.PingReply[]].

    .INPUTS
        None
        You cannot pipe input to this funcion.

    .OUTPUTS
        The function only returns output from successful pings.

        Type: System.Net.NetworkInformation.PingReply

        The RawOutput parameter switches the output to an unformated
        [System.Net.NetworkInformation.PingReply[]].

    .NOTES
        Author  : G.A.F.F. Jakobs
        Created : August 30, 2014
        Version : 6

    .EXAMPLE
        Ping-IPRange -StartAddress 192.168.1.1 -EndAddress 192.168.1.254 -Interval 20

        IPAddress                                 Bytes                     Ttl           ResponseTime
        ---------                                 -----                     ---           ------------
        192.168.1.41                                 32                      64                    371
        192.168.1.57                                 32                     128                      0
        192.168.1.64                                 32                     128                      1
        192.168.1.63                                 32                      64                     88
        192.168.1.254                                32                      64                      0

        In this example all the ip addresses between 192.168.1.1 and 192.168.1.254 are pinged using 
        a 20 millisecond interval between each request.
        All the addresses that reply the ping request are listed.

    .LINK
        http://gallery.technet.microsoft.com/Fast-asynchronous-ping-IP-d0a5cf0e

    #>
    [CmdletBinding(ConfirmImpact='Low')]
    Param(
        [parameter(Mandatory = $true, Position = 0)]
        [System.Net.IPAddress]$StartAddress,
        [parameter(Mandatory = $true, Position = 1)]
        [System.Net.IPAddress]$EndAddress,
        [int]$Interval = 30,
        [Switch]$RawOutput = $false
    )

    $timeout = 2000

    function New-Range ($start, $end) {

        [byte[]]$BySt = $start.GetAddressBytes()
        [Array]::Reverse($BySt)
        [byte[]]$ByEn = $end.GetAddressBytes()
        [Array]::Reverse($ByEn)
        $i1 = [System.BitConverter]::ToUInt32($BySt,0)
        $i2 = [System.BitConverter]::ToUInt32($ByEn,0)
        for($x = $i1;$x -le $i2;$x++){
            $ip = ([System.Net.IPAddress]$x).GetAddressBytes()
            [Array]::Reverse($ip)
            [System.Net.IPAddress]::Parse($($ip -join '.'))
        }
    }

    $IPrange = New-Range $StartAddress $EndAddress

    $IpTotal = $IPrange.Count

    Get-Event -SourceIdentifier "ID-Ping*" | Remove-Event
    Get-EventSubscriber -SourceIdentifier "ID-Ping*" | Unregister-Event

    $IPrange | ForEach-Object{

        [string]$VarName = "Ping_" + $_.Address

        New-Variable -Name $VarName -Value (New-Object System.Net.NetworkInformation.Ping)

        Register-ObjectEvent -InputObject (Get-Variable $VarName -ValueOnly) -EventName PingCompleted -SourceIdentifier "ID-$VarName"

        (Get-Variable $VarName -ValueOnly).SendAsync($_,$timeout,$VarName)

        Remove-Variable $VarName

        try{

            $pending = (Get-Event -SourceIdentifier "ID-Ping*").Count

        }catch [System.InvalidOperationException]{}

        $index = [array]::indexof($IPrange,$_)

        Write-Progress -Activity "Sending ping to" -Id 1 -status $_.IPAddressToString -PercentComplete (($index / $IpTotal)  * 100)

        Write-Progress -Activity "ICMP requests pending" -Id 2 -ParentId 1 -Status ($index - $pending) -PercentComplete (($index - $pending)/$IpTotal * 100)

        Start-Sleep -Milliseconds $Interval
    }

    Write-Progress -Activity "Done sending ping requests" -Id 1 -Status 'Waiting' -PercentComplete 100 

    While($pending -lt $IpTotal){

        Wait-Event -SourceIdentifier "ID-Ping*" | Out-Null

        Start-Sleep -Milliseconds 10

        $pending = (Get-Event -SourceIdentifier "ID-Ping*").Count

        Write-Progress -Activity "ICMP requests pending" -Id 2 -ParentId 1 -Status ($IpTotal - $pending) -PercentComplete (($IpTotal - $pending)/$IpTotal * 100)
    }

    if($RawOutput){

        $Reply = Get-Event -SourceIdentifier "ID-Ping*" | ForEach-Object { 
            If($_.SourceEventArgs.Reply.Status -eq "Success"){
                $_.SourceEventArgs.Reply
            }
            Unregister-Event $_.SourceIdentifier
            Remove-Event $_.SourceIdentifier
        }

    }else{

        $Reply = Get-Event -SourceIdentifier "ID-Ping*" | ForEach-Object { 
            If($_.SourceEventArgs.Reply.Status -eq "Success"){
                $_.SourceEventArgs.Reply | Select-Object @{
                      Name="IPAddress"   ; Expression={$_.Address}},
                    @{Name="Bytes"       ; Expression={$_.Buffer.Length}},
                    @{Name="Ttl"         ; Expression={$_.Options.Ttl}},
                    @{Name="ResponseTime"; Expression={$_.RoundtripTime}}
            }
            Unregister-Event $_.SourceIdentifier
            Remove-Event $_.SourceIdentifier
        }
    }
    if($Null -eq $Reply){
        Write-Verbose "Ping-IPrange : No ip address responded" -Verbose
    }

    return $Reply
}
# SIG # Begin signature block
# MIII2wYJKoZIhvcNAQcCoIIIzDCCCMgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUd9MnILbBz7T0FR8v/8Yw8MpI
# KEugggYzMIIGLzCCBRegAwIBAgIKERM1LAABAAABvTANBgkqhkiG9w0BAQsFADBj
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
# DQEJBDEWBBT+hPq7RpRHHWs227CR4bIb0wrzlTANBgkqhkiG9w0BAQEFAASCAQBp
# 0tstXAC7z4UFXfD4t5GjJBv0l7ujki2eTZ5NnJpWcoJ0zgqU+3mMPFR0rMm4sVCv
# vot3a/aKA7FYpnUehsEgQSnullWzOZjMxIv3QHo9fYv3JxFDWjKcMxZBe/3tgDs8
# v1BFp06brriz+jBjE3ilAhije19fujWoXMirL6QDffnP+DoNtNA1zWcpMX/gjKCM
# PIrBtoPKlEmu3X3+yUocEfBY/Wq6ZYvzAZyuY+bcKQN8g1aqfFpGBeZdcnX14XVZ
# FIbZyPpHJ09r5i/EXTs+z/V7uQKI/vK7NIr2ctvqKu8H1vzVY6gaRoHwYvWVILzt
# XuNo1skMJR4ILd1Gfg7C
# SIG # End signature block
