function Get-Image {
    [CmdletBinding()]
    param (
        [switch]$RandomQuote,
        [string]$Text
    )
    
    begin {
        if ($RandomQuote) {
            $Text = Get-Quote
        }

        $progresspreference = "silentlyContinue"
    }
    
    process {
        $Header = @{ Authorization = "563492ad6f917000010000019142f114c9664f5aaf3a03c69726add5" }

        $PageNum = get-random -Minimum 1 -Maximum ((Invoke-WebRequest -Uri "https://api.pexels.com/v1/search?query=nature&orientation=square&per_page=1" -Headers $Header).Content | convertfrom-json).Total_results
        $Url = ((Invoke-WebRequest -Uri "https://api.pexels.com/v1/search?query=nature&orientation=square&per_page=1&page=$($PageNum)" -Headers $Header).Content | Convertfrom-Json).photos.id

        $getImage = Invoke-WebRequest -Uri "https://api.pexels.com/v1/photos/$Url" -Headers $Header

        $ImageURL = ($getImage.Content | ConvertFrom-Json).src.large2x

        $ImageURL = [System.Web.HttpUtility]::UrlEncode($ImageURL) 

        $Text = [System.Web.HttpUtility]::UrlEncode($Text) 

        $CompiledImage = "https://textoverimage.moesif.com/image?image_url=$ImageURL&overlay_color=00000089&text=$Text&text_color=fbfbfbff&text_size=64&y_align=middle&x_align=left"

        $filename = "$($env:appdata)\temp.jpeg"
        Invoke-WebRequest $CompiledImage -OutFile $filename
        
        [Reflection.Assembly]::LoadWithPartialName('System.Drawing')
        [Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    
        $file = get-item($filename)
        $img = [System.Drawing.Image]::Fromfile($file)
        [System.Windows.Forms.Clipboard]::SetImage($img)
        $img.Dispose()  

    }
    
    end {
        Write-host "Image has been copied to your clipboard..."
        remove-item -Path $filename -force  
    }
}