Function Measure-NetworkSpeed{
    # The test file has to be a 50MB file for the math to work. If you want to change sizes, modify the math to match

    $Result = New-Object psobject
    add-member -InputObject $Result -MemberType NoteProperty -Name Time -Value (Get-Date -Format dd/MM/yyy-HH:MM)
    add-member -InputObject $Result -MemberType NoteProperty -Name Speed -Value ""
    
    $TestFile  = 'http://swearierlistofswears.azurewebsites.net/50MB.zip'
    $TempFile  = Join-Path -Path $env:TEMP -ChildPath 'testfile.tmp'
    $WebClient = New-Object Net.WebClient
    $TimeTaken = Measure-Command { $WebClient.DownloadFile($TestFile,$TempFile) } | Select-Object -ExpandProperty TotalSeconds
    $SpeedMbps = (50 / $TimeTaken) * 8
    $Speed = "{0:N2}" -f ($SpeedMbps)
    $truespeed = [int]$Speed
    $Result.Speed = $truespeed
    Remove-Item $TempFile

    $Result

}

$SpeedCheckFolder = "C:\Powershell\SpeedChecks"
$currentSpeed = Measure-NetworkSpeed

if ($currentSpeed.Speed -lt 450) {
    $currentSpeed | Export-Csv "$($SpeedCheckFolder)\$(Get-Date -Format ddMMyyy-HHMMss).csv" -NoTypeInformation
}

$PreviousSpeedCheck = Get-ChildItem $SpeedCheckFolder
$LastCheck = $PreviousSpeedCheck | Sort-Object lastwritetime -Descending | Select-Object lastwritetime -First 1 
$twoHoursAgo = (Get-date).AddHours(-2)

if ($LastCheck.LastWriteTime -lt $twoHoursAgo) {
    Remove-Item $SpeedCheckFolder/*.csv
}

if ($PreviousSpeedCheck.count -eq 5) {

    $AllSpeedChecks = @()

    foreach ($check in $PreviousSpeedCheck) {

        $i = Import-Csv $check.fullName
        $AllSpeedChecks += $i
    }

    $username = "thewholefam23@gmail.com"
    $password = Get-Content "C:\Powershell\gmailEncrypted.txt"  | ConvertTo-SecureString
    $credential = New-Object System.Management.Automation.PsCredential($username,$password)

    #$to = "supportdesk@truespeed.com"
    $to = "com@tolyer.co.uk"
    $Subject = "28767 - Poor Connection Speed on $(Get-date -Format dd/MM/yyyy)"
    $SMTP = "smtp.gmail.com"

    $Body = "<p>Account Number: 28767</p>
    <p><br></p>
    <p>Hello there,</p>
    <p>I am contacting you to advise that for 5 sequential hours, my internet speed has been far below the advertised speeds.</p>
    <p>I am currently paying for a 500Mbps contract with yourselves and as such, would like to make sure I&apos;m getting this speed reliably.</p>
    <p>The last 5 hours of speed tests have shown speeds of:</p>
    <p>$(Foreach ($i in $AllSpeedChecks) {
            "$($i.Time) $($i.Speed)Mbps<br>"
        }
    )
    <p>This network test has been run from a computer that is directly connected to the modem via CAT6 cabling.</p>
    <p>Please let me know if there is any further information you require.</p>
    <p>Kind regards,</p>
    <p>Tom Colyer</p>"

    Send-MailMessage -From $username -to $to -Subject $Subject -body $Body -SmtpServer $SMTP -UseSsl -Port 587 -Credential $credential -BodyAsHtml

    "Sent email"

    Remove-Item $SpeedCheckFolder/*.csv

}
