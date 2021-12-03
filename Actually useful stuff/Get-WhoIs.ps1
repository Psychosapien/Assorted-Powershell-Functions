Function Get-WhoIs {
    [cmdletbinding()]
    [OutputType("WhoIsResult")]
    Param (
        [parameter(Position = 0,
            Mandatory,
            HelpMessage = "Enter an IPV4 address to lookup with WhoIs",
            ValueFromPipeline,
            ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern("^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$")]
         [ValidateScript( {
            #verify each octet is valid to simplify the regex
                $test = ($_.split(".")).where({[int]$_ -gt 254})
                if ($test) {
                    Throw "$_ does not appear to be a valid IPv4 address"
                    $false
                }
                else {
                    $true
                }
            })]
        [string]$IPAddress
    )

    Begin {
        Write-Verbose "Starting $($MyInvocation.Mycommand)"
        $baseURL = 'http://whois.arin.net/rest'
        #default is XML anyway
        $header = @{"Accept" = "application/xml"}

    } #begin

    Process {
        Write-Verbose "Getting WhoIs information for $IPAddress"
        $url = "$baseUrl/ip/$ipaddress"
        Try {
            $r = Invoke-Restmethod $url -Headers $header -ErrorAction stop
            Write-verbose ($r.net | Out-String)
        }
        Catch {
            $errMsg = "Sorry. There was an error retrieving WhoIs information for $IPAddress. $($_.exception.message)"
            $host.ui.WriteErrorLine($errMsg)
        }

        if ($r.net) {
            Write-Verbose "Creating result"
            [pscustomobject]@{
                PSTypeName             = "WhoIsResult"
                IP                     = $ipaddress
                Name                   = $r.net.name
                RegisteredOrganization = $r.net.orgRef.name
                City                   = (Invoke-RestMethod $r.net.orgRef.'#text').org.city
                StartAddress           = $r.net.startAddress
                EndAddress             = $r.net.endAddress
                NetBlocks              = $r.net.netBlocks.netBlock | foreach-object {"$($_.startaddress)/$($_.cidrLength)"}
                Updated                = $r.net.updateDate -as [datetime]
            }
        } #If $r.net
    } #Process

    End {
        Write-Verbose "Ending $($MyInvocation.Mycommand)"
    } #end
}
# SIG # Begin signature block
# MIII2wYJKoZIhvcNAQcCoIIIzDCCCMgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU0o6RVs4cqfLF5gomXg4AWLRH
# +6SgggYzMIIGLzCCBRegAwIBAgIKERM1LAABAAABvTANBgkqhkiG9w0BAQsFADBj
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
# DQEJBDEWBBRmXqDZ2bep/3ED273UM3POAyI6kjANBgkqhkiG9w0BAQEFAASCAQBP
# o0fvBl/9MsFHgiUGSf96EWRD7+3Jok6Kwasyq3piaAuYcieEHqfUYFGo+Mja+9S0
# /rNWM9tmLtxfgbfX0hehS1CUT0b3UDkNSMCeWnj+Hwgl7lkWv7/IQj/BahS9XYGQ
# WhfmQh4l23U3mVoCOrtgeOwrWM9Gor9LVeuykdnSpzBOTAfzEYt2QoU373+Sy+XW
# aPZo/yjqG8lvL4gNZGI9/zQcgBwmWI0Flb4MZKsXgd6DJdr61OLzdX3Xk5crBNNq
# YMZYEESQw9UedBQGkkd90rnasIlg3tPG8q6oD2WUj/TN4dIdN/xrb4YWm1XOHM8I
# ChexsTSP68rgldO+614W
# SIG # End signature block
