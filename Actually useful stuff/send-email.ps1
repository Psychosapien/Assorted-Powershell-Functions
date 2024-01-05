param (
    [string]$To,
    [string]$From,
    [string]$ccRecipients,
    [string]$bccRecipients,
    [string]$Subject,
    [string]$Body
)

# Build an ouput object to return the status of the script
$GlobalResult = New-Object psobject
add-member -InputObject $GlobalResult -MemberType NoteProperty -Name success -Value $False -TypeName boolean

$Error.Clear()
$ErrorActionPreference = "Stop"

# Encapsulate everything in a try/catch block to return error status if anything goes wrong
try {

    # Formatting the variables for use in the script
    [Array]$ToArray = $To.split(",")
    [Array]$ccRecipientsArray = $ccRecipients.Split(",")
    [Array]$bccRecipientsArray = $bccRecipients.Split(",")


    # Connection is done with a certificate provided by the CA
    $MgConnectParams = @{
        ClientId              = "AZURE SERVICE PRINCIPAL ID"
        TenantId              = "AZURE AD TENANT ID"
        CertificateThumbprint = 'THUMBPRINT FOR CERT'
    }

    # Connect to MS Graph for the emails
    $connectToGraph = Connect-Graph @MgConnectParams

    # A little function to create the recipient arrays
    Function ConvertTo-IMicrosoftGraphRecipient {
        [cmdletbinding()]
        Param(
            [array]$SmtpAddresses        
        )
        foreach ($address in $SmtpAddresses) {
            @{
                EmailAddress = @{Address = $address }
            }    
        }    
    }

    # Build the body for the email request

    # Start with recipients
    [array]$toRecipients = ConvertTo-IMicrosoftGraphRecipient -SmtpAddresses $ToArray 
    [array]$CC = ConvertTo-IMicrosoftGraphRecipient -SmtpAddresses $ccRecipientsArray
    [array]$BCC = ConvertTo-IMicrosoftGraphRecipient -SmtpAddresses $bccRecipientsArray 
    
    # Slap the body in there
    $htmlBody = @{
        ContentType = 'html'
        Content     = $body  
    }

    # Now we glue it all together as a series of hashtables
    $emailBody += @{subject = $Subject }
    $emailBody += @{ToRecipients = $toRecipients }  

    # We only need CC and BCC if it is provided t the script, otherwise it breaks things
    if ($ccRecipients) {
        $emailBody += @{CcRecipients = $CC }    
    }

    if ($bccRecipients) {
        $emailBody += @{BccRecipients = $BCC }    
    }

    # Add the body of the e-mail, allowing for HTML code
    $emailBody += @{body = $htmlBody }

    # Final body constrtuction, what a hot bod
    $bodyParameter += @{'message' = $emailBody }
    $bodyParameter += @{'saveToSentItems' = $true }

    # Boom, now we send
    Send-MgUserMail -UserId "$From" -BodyParameter $bodyParameter

    $GlobalResult.success = $true
}
catch {
    add-member -InputObject $GlobalResult -MemberType NoteProperty -Name ErrorLine -Value $error.invocationinfo.ScriptLineNumber -TypeName string
    add-member -InputObject $GlobalResult -MemberType NoteProperty -Name ErrorLinePos -Value $error.invocationinfo.OffsetInLine -TypeName string
    add-member -InputObject $GlobalResult -MemberType NoteProperty -Name ErrorCMD -Value $error.invocationinfo.Line -TypeName string
    add-member -InputObject $GlobalResult -MemberType NoteProperty -Name ErrorException -Value $error.Exception.message -TypeName string
}

Write-Output $GlobalResult | convertto-json