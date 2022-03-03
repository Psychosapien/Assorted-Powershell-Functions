function Get-Hackerman {
    [CmdletBinding()]
    param (
        [ValidateSet("Green", "Cyan", "Red", "Magenta", "Yellow", "White")]
        [string]$colour,
        [string]$Duration
    )
    
    begin {
        
    }
    
    process {
        for ($i = 0; $i -lt $Duration; $i++) {

            $Line = @()
        
            $Count = get-random -Minimum 10 -Maximum 250
        
            for ($i = 0; $i -lt $Count; $i++) {
                $Uni = $([char](Get-Random -Minimum 1 -Maximum 2000))
                $Line += $Uni
            }
        
            $Sleep = get-random -Minimum 1 -Maximum 100
        
            Write-Host $line -ForegroundColor $colour
        
            Start-Sleep -Milliseconds $sleep
        }
    }
    
    end {
        
    }
}

