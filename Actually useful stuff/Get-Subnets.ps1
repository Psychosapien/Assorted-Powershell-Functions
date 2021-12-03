function Get-Subnets { 
 
    Param( 
        [Parameter(Mandatory = $true)] 
        [array] $Subnets 
    ) 

    foreach ($subnet in $subnets) { 
     
        #Split IP and subnet 
        $IP = ($Subnet -split "\/")[0] 
        $SubnetBits = ($Subnet -split "\/")[1] 
     
        #Convert IP into binary 
        #Split IP into different octects and for each one, figure out the binary with leading zeros and add to the total 
        $Octets = $IP -split "\." 
        $IPInBinary = @() 
        foreach ($Octet in $Octets) { 
            #convert to binary 
            $OctetInBinary = [convert]::ToString($Octet, 2) 
             
            #get length of binary string add leading zeros to make octet 
            $OctetInBinary = ("0" * (8 - ($OctetInBinary).Length) + $OctetInBinary) 

            $IPInBinary = $IPInBinary + $OctetInBinary 
        } 
        $IPInBinary = $IPInBinary -join "" 

        #Get network ID by subtracting subnet mask 
        $HostBits = 32 - $SubnetBits 
        $NetworkIDInBinary = $IPInBinary.Substring(0, $SubnetBits) 
     
        #Get host ID and get the first host ID by converting all 1s into 0s 
        $HostIDInBinary = $IPInBinary.Substring($SubnetBits, $HostBits)         
        $HostIDInBinary = $HostIDInBinary -replace "1", "0" 

        #Work out all the host IDs in that subnet by cycling through $i from 1 up to max $HostIDInBinary (i.e. 1s stringed up to $HostBits) 
        #Work out max $HostIDInBinary 
        $imax = [convert]::ToInt32(("1" * $HostBits), 2) - 1 

        $IPs = @() 

        #Next ID is first network ID converted to decimal plus $i then converted to binary 
        For ($i = 1 ; $i -le $imax ; $i++) { 
            #Convert to decimal and add $i 
            $NextHostIDInDecimal = ([convert]::ToInt32($HostIDInBinary, 2) + $i) 
            #Convert back to binary 
            $NextHostIDInBinary = [convert]::ToString($NextHostIDInDecimal, 2) 
            #Add leading zeros 
            #Number of zeros to add  
            $NoOfZerosToAdd = $HostIDInBinary.Length - $NextHostIDInBinary.Length 
            $NextHostIDInBinary = ("0" * $NoOfZerosToAdd) + $NextHostIDInBinary 

            #Work out next IP 
            #Add networkID to hostID 
            $NextIPInBinary = $NetworkIDInBinary + $NextHostIDInBinary 
            #Split into octets and separate by . then join 
            $IP = @() 
            For ($x = 1 ; $x -le 4 ; $x++) { 
                #Work out start character position 
                $StartCharNumber = ($x - 1) * 8 
                #Get octet in binary 
                $IPOctetInBinary = $NextIPInBinary.Substring($StartCharNumber, 8) 
                #Convert octet into decimal 
                $IPOctetInDecimal = [convert]::ToInt32($IPOctetInBinary, 2) 
                #Add octet to IP  
                $IP += $IPOctetInDecimal 
            } 

            #Separate by . 
            $IP = $IP -join "." 
            $IPs += $IP 

             
        } 

        $SubnetTable = New-Object psobject
        add-member -InputObject $SubnetTable -MemberType NoteProperty -Name Subnet -Value "$subnet"
        add-member -InputObject $SubnetTable -MemberType NoteProperty -Name "Start Address" -Value "$($IPs[0])"
        add-member -InputObject $SubnetTable -MemberType NoteProperty -Name "End Address" -Value "$($IPs[$IPs.count -1])"
        
        $SubnetTable
    } 
} 
# SIG # Begin signature block
# MIII2wYJKoZIhvcNAQcCoIIIzDCCCMgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUaKwJiYzg2S0LAG1yWe4zWnRG
# rk6gggYzMIIGLzCCBRegAwIBAgIKERM1LAABAAABvTANBgkqhkiG9w0BAQsFADBj
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
# DQEJBDEWBBR+3ABeHMYGhqhJEXBKSUw3VG/BxzANBgkqhkiG9w0BAQEFAASCAQBs
# xtO9pzrly0qtHipN3XtlR+hs22TjEk3vSni/NCHWCrpm6VOfA0YAScwjyrFkCS5g
# aSwv6Go67v/mHgtko1g/LE0Gt5QUUJ3FDfBaiDDFwrKdgtCBU2c6+Os6XjLcQjj8
# Pj+CKKbQVcT0hR7kZiaoVHDqZQ1S5lM3Sw97Uom9rMg3YZ98DXaK6od9Zmj99IyK
# a3Hn6lsUMf3F4I9Anmg7pB/yR0uA7fO40ImQSFZQj1VBmLapcWwjr5jGMK1KVZRr
# hBkO/4kaSVgxpoXbqD7bw+R9Ia1opPPpl6KU+FiVnBqxmNxH1GHfhhN5z7TVtXIi
# oV6pQIiRMRgvwwx+xkg9
# SIG # End signature block
