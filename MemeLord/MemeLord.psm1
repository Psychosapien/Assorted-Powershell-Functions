function Key-Check {
    
    . $PSScriptRoot/Config.ps1

    if ($null -eq $Properties.Username) {
        $username = Read-Host "Please enter your username"
        $textToAdd = "Username = " + '"' + "$username" + '"'
        $fileContent = Get-Content $PSScriptRoot/Config.ps1
        $fileContent[1] += $textToAdd
        $fileContent | Set-Content $PSScriptRoot/Config.ps1   
    }

    if ($null -eq ($Password = $Properties.Password | ConvertTo-SecureString)) {
        $Password = Read-Host "Please enter your password" -assecurestring | convertfrom-securestring
        $textToAdd = "Password = " + '"' + "$Password" + '"'
        $fileContent = Get-Content $PSScriptRoot/Config.ps1
        $fileContent[2] += $textToAdd
        $fileContent | Set-Content $PSScriptRoot/Config.ps1    
    }

    . $PSScriptRoot/Config.ps1

    $Username = "$Properties.Username"
    $Password = $Properties.Password | ConvertTo-SecureString
    $Credentials = New-Object System.Management.Automation.PSCredential($Username, $Password)
}

function Invoke-MemeLord {
    [CmdletBinding()]
    param (
        [string]$TopText = "",
        [string]$BottomText = "",
        [string]$MiddleText = "",
        [string]$MemeSearch,
        [string]$SavePath
    )

    Key-Check

    . $PSScriptRoot/Config.ps1

    $Username = "$Properties.Username"
    $Password = $Properties.Password | ConvertTo-SecureString
    $Credentials = New-Object System.Management.Automation.PSCredential($Username, $Password)


    filter ConvertTo-Spongebob {
        $i = 0
        while ($i -lt (($_ | Measure-Object -Character).Characters)) { if ($i % 2 -eq 0) { $newstring += ($_[$i]).toString().toUpper() } else { $newstring += $_[$i] } ; $i++ }
        return $newstring
    }

    $MemeList = Invoke-RestMethod -Uri "https://api.imgflip.com/get_memes"
    $MemeID = $MemeList.data.memes | Where-Object Name -Like "*$MemeSearch*"
    $MemeID = $MemeID.id
    if ($MemeID.Count -gt 1) {
        $MemeID = $MemeID | Select-Object id, name, url | Out-GridView -OutputMode Single
        $MemeID = $MemeID.id
    }
    if (!$MemeID) { return "Unable to find MemeSearch like $MemeSearch" }
    
    $memeparams = @{
        template_id      = $MemeID
        username         = $Credentials.UserName
        password         = $Credentials.GetNetworkCredential().Password
        'boxes[0][text]' = $TopText
        'boxes[1][text]' = $MiddleText
        'boxes[2][text]' = $BottomText
    }
    
    $response = Invoke-RestMethod 'https://api.imgflip.com/caption_image' -Method Post -Body $memeparams
    #Build PSObject with response
    $finishedMeme = new-object psobject
    if ($response.success -like "False") { $finishedMeme | Add-Member -MemberType NoteProperty -Name 'response' -Value $response.error_message }
    $finishedMeme | Add-Member -MemberType NoteProperty -Name 'Url' -Value $response.data.url    
    $finishedMeme

    $source = $finishedMeme.Url
    $filename = "$($env:appdata)\temp.jpeg"
    Invoke-WebRequest $source -OutFile $filename
    

    [Reflection.Assembly]::LoadWithPartialName('System.Drawing');
    [Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms');

    $file = get-item($filename);
    $img = [System.Drawing.Image]::Fromfile($file);
    [System.Windows.Forms.Clipboard]::SetImage($img);
    $img.Dispose()

    if ($SavePath) {
        Move-Item $filename $SavePath
    }
    else {
        Remove-Item -Path $filename
    }
}

Run to update .psd1
<#
$manifest = @{
    Path       = '.\MemeLord.psd1'
    RootModule = 'MemeLord.psm1' 
    Author     = 'Tom Colyer'
}
New-ModuleManifest @manifest
#>
