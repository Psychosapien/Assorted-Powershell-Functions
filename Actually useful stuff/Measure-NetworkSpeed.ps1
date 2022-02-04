Function Measure-NetworkSpeed{
    # The test file has to be a 50MB file for the math to work. If you want to change sizes, modify the math to match
    $TestFile  = 'http://swearierlistofswears.azurewebsites.net/50MB.zip'
    $TempFile  = Join-Path -Path $env:TEMP -ChildPath 'testfile.tmp'
    $WebClient = New-Object Net.WebClient
    $TimeTaken = Measure-Command { $WebClient.DownloadFile($TestFile,$TempFile) } | Select-Object -ExpandProperty TotalSeconds
    $SpeedMbps = (50 / $TimeTaken) * 8
    $Message = "{0:N2} Mbit/sec" -f ($SpeedMbps)
    $Message
    Remove-Item $TempFile
}

Measure-NetworkSpeed