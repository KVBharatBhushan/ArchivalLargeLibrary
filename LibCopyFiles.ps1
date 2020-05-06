#Load SharePoint CSOM Assemblies
write-host -f Yellow "Nested Folder and Files Copying Started" 
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"


#Config Login Details with Password Protection
$User = "O365admin@crossshare.net"
$PWord = ConvertTo-SecureString -String "Cambay#0987" -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord
  
#Function to Copy a File
Function Copy-SPOFile([String]$SourceSiteURL, [String]$SourceFileURL, [String]$TargetFileURL)
{
    Try{
        #Setup the context
        #$Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SourceSiteURL)
        #$Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Credentials.Username, $Credentials.Password)
        #Setup the context
        $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
    
        $Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Credential.UserName,$Credential.Password)
      
        #Copy the File
        $MoveCopyOpt = New-Object Microsoft.SharePoint.Client.MoveCopyOptions
        $Overwrite = $True
        [Microsoft.SharePoint.Client.MoveCopyUtil]::CopyFile($Ctx, $SourceFileURL, $TargetFileURL, $Overwrite, $MoveCopyOpt)
        $Ctx.ExecuteQuery()
  
        Write-host -f Green $TargetFileURL" - File Copied Successfully!"
    }
    Catch {
    write-host -f Red "Error Copying the File!" $_.Exception.Message
    }
}

$RootSiteURL = "https://crosssharenet.sharepoint.com"
$SourceSiteURL="https://crosssharenet.sharepoint.com/sites/classictest"
$TargetSiteURL = "https://crosssharenet.sharepoint.com/sites/testsitearchival"
$SourceSitePath = "/sites/classictest/"
$TargetSitePath = "/sites/testsitearchival/"
$SourceDocLibURL = "/PnPCopytoLib"
$TargetDocLibURL = "/FlowArchiveLib2"
#$TargetDocLibURL = "/FlowArchiveLib2/April_3rdWeek"

#$Credentials = Get-Credential
Connect-PnPOnline -Url $TargetSiteURL -Credentials $Credential

$CSVPath = "D:\LibraryDocumentsInventory.csv"

Import-Csv $CSVPath | ForEach-Object {
    
    $SourceFileURL = $RootSiteURL + $_.RelativeURL
    
    $temp = ($_.RelativeURL).Replace($SourceDocLibURL,$TargetDocLibURL)   
    $temp = ($temp).Replace($SourceSitePath,$TargetSitePath)
    $TargetFileURL = $RootSiteURL + $temp    
    $temp = ($temp).Replace($TargetSitePath,"")
       
    $temp = ($temp).Replace("/"+$_.FileName,"")    
   
    if($TargetDocLibURL -ne "/"+$temp){
        Resolve-PnPFolder -SiteRelativePath $temp
    }
    #Call the function to Copy the File
    Copy-SPOFile $SourceSiteURL $SourceFileURL $TargetFileURL
}
