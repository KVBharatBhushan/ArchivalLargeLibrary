#Config Login Details with Password Protection
$User = "O365admin@sampleshare.net"
$PWord = ConvertTo-SecureString -String "*********" -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord

$SourceSiteURL="https://samplesharenet.sharepoint.com/sites/classictest"
Connect-PnPOnline -Url $SourceSiteURL -Credentials $Credential

$CSVPath = "D:\LibraryDocumentsInventory.csv"

Import-Csv $CSVPath | ForEach-Object {    
    Remove-PnPFile -ServerRelativeUrl $_.RelativeURL  -force
}
