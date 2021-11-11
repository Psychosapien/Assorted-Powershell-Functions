filter OWOinate {
    $Text = Get-Clipboard
    $text -replace "r", "w"`
        -replace "R", "W"`
            
}

function OWO {

    $error. clear()
    $ErrorActionPreference = "silentlycontinue"

    $swears = ((Invoke-WebRequest -URI "https://swearylistofswears.azurewebsites.net/swears.html").Content).split() | Select-Object -Unique
    $sadness = ((Invoke-WebRequest -URI "https://swearylistofswears.azurewebsites.net/owo.html").Content).split(':') | Select-Object -Unique

    $w = Get-Clipboard | OWOinate

    $l = $w.split(" ")
    $collection = { $l }.invoke()
    $n = get-random -Maximum 9
    
    do {
        $collection.Insert($n, "$(get-random $sadness)")
        $n = $n + (get-random -min 5 -max 18)
    }

    until ($error)

    $collection = $collection -join " " 
    $collection | Set-Clipboard

    Write-host "I've copied this $(get-random $swears)ing monstrocity to your clipboard. You should really be evaluating the life choices that have led you to this" -ForegroundColor Red
    Get-Clipboard
}