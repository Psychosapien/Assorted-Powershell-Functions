Function Get-Pub {

    [CmdletBinding()]
    param (
        [Parameter()]
        [String]$IWantToEat = "Pub",
        [String]$WhereAreYou = "BS1 6FL",
        [String]$HowFarCanYouBeBotheredToWalk = 1000,
        [Switch]$UseCurrentLocation, ## This is buggy as fuck
        [Switch]$ICanDriveThere ## This is buggy as fuck

    )

    begin {

        if (Get-Module -ListAvailable -Name GoogleMap) {
            Write-Host "Module exists"
        } else {
            Install-module GoogleMap -AllowClobber
        }

        $GoogleAPIKey = "ENTERYOURAPIKEYHERE"

        $env:GoogleGeocode_API_Key = $GoogleAPIKey
        $env:GooglePlaces_API_Key = $GoogleAPIKey
        $env:GoogleDistance_API_Key = $GoogleAPIKey
        $env:GoogleDirection_API_Key = $GoogleAPIKey
        $env:GoogleGeoloc_API_Key = $GoogleAPIKey
    }
    process {
        $swears = ((Invoke-WebRequest -URI "https://swearylistofswears.azurewebsites.net/swears.html").Content).split() | Select-Object -Unique

        if ($UseCurrentLocation) {
            $Current = Get-GeoLocation
    
            $Location = Get-GeoCoding -Address $Current[$current.length - 1]    
        }
        else {
            $Location = Get-GeoCoding -Address $WhereAreYou
        }
    
        $Pub = Get-Random -InputObject (Get-NearbyPlace -Coordinates "$($Location.Latitude),$($Location.Longitude)" -Keyword $IWantToEat -radius $HowFarCanYouBeBotheredToWalk)

        if (!$Pub) {
            Write-Error "I can't fucking find anything for you, try asking for a less obscure thing to eat..."

            Break
        }
    
        if ($ICanDriveThere) {
            $distance = Get-Distance -From "$($Location.Latitude),$($Location.Longitude)" -To $pub.Coordinates -Mode Driving
        } else {
            $distance = Get-Distance -From "$($Location.Latitude),$($Location.Longitude)" -To $pub.Coordinates -Mode walking
        }
    
        $ChoicePhrases = @(
            "Why don't you just fucking choose $($Pub.name), you $(Get-random $swears).",
            "Don't be such a $(Get-random $swears), go to $($Pub.name).",
            "Only a $(Get-random $swears) wouldn't want to go to $($Pub.name).",
            "If you don't go to $($Pub.name), then you are a proper $(Get-random $swears)."
        )
    }
    
    end {
        Write-host "$(Get-random $ChoicePhrases)`n" -ForegroundColor Green
        write-host "It is only a $($Distance.Time -replace "s",'') walk.`n" -ForegroundColor Green
    
        $YesOrNo = Read-Host "Would you like directions? (y/n)"
        while ("y", "n" -notcontains $YesOrNo ) {
            $YesOrNo = Read-Host "Would you like directions? (y/n)"
        }
    
        if ($YesOrNo -eq "y") {
    
            Write-Host "`nNo problem, here you go...`n" -ForegroundColor Cyan
    
            (Get-Direction -From "$($Location.Latitude),$($Location.Longitude)"  -To $pub.Coordinates -Mode walking).Instructions
        }
    }
}