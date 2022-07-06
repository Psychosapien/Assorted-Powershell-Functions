filter OWOinate {
    $Text = Get-Clipboard
    $text -replace "r", "w"`
        -replace "R", "W"`
            
}

function Get-Emoji {
      
    $codes = ((invoke-webrequest https://emoji-api.com/emojis?access_key=ebaf054cbe9a36b1454a0541a96d3a9fe2d152a5).content | ConvertFrom-Json).codePoint

    $code = $codes.split(" ")

    $FullUnicode = "$(get-random $code)"
    $StrippedUnicode = $FullUnicode -replace 'U\+',''
    $UnicodeInt = [System.Convert]::toInt32($StrippedUnicode,16)
    [System.Char]::ConvertFromUtf32($UnicodeInt)
  
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

        $RollDice = Get-Random -Minimum 1 -Maximum 1000

        if ($RollDice -lt 800) {
            $collection.Insert($n, "$(get-random $sadness)")
        } else {

            $EmojiCount = Get-random -Minimum 1 -Maximum 7
            $i = 1
            $EmojiArray = @()

            for ($i = 0; $i -lt $EmojiCount; $i++) {

                $EmojiArray += Get-Emoji
            }

            foreach ($emoji in $EmojiArray) {
                $collection.Insert($n, $Emoji)
            }
            
        }
        $n = $n + (get-random -min 5 -max 18)
    }

    until ($error)

    $collection = $collection -join " " 
    $collection | Set-Clipboard

    Write-host "I've copied this $(get-random $swears)ing monstrocity to your clipboard. You should really be evaluating the life choices that have led you to this" -ForegroundColor Red
    Get-Clipboard
}
