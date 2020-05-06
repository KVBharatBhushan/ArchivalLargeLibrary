#Config Login Details with Password Protection
$User = "O365admin@crossshare.net"
$PWord = ConvertTo-SecureString -String "Cambay#0987" -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord

$SourceSiteURL="https://crosssharenet.sharepoint.com/sites/classictest"
Connect-PnPOnline -Url $SourceSiteURL -Credentials $Credential

$CSVPath = "D:\LibraryDocumentsInventory.csv"

Import-Csv $CSVPath | ForEach-Object {    
    Remove-PnPFile -ServerRelativeUrl $_.RelativeURL  -force
}
