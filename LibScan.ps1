#Getting NestedFolder and Files for Archival Process on a CSV File
#Load SharePoint CSOM Assemblies
write-host -f Yellow "Scanning Large Library with Nested Folder and Files Started" 
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
     
#Config Parameters
$SiteURL= "https://samplesharenet.sharepoint.com/sites/classictest"
$ListName = "PnPCopytoLib"
$CSVPath = "D:\LibraryDocumentsInventory.csv"


#Config Login Details with Password Protection
$User = "O365admin@sampleshare.net"
$PWord = ConvertTo-SecureString -String "*******" -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord


 
Try {

    #Setup the context
    $Ctx = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
    
    $Ctx.Credentials = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Credential.UserName,$Credential.Password)
     
    #Get the Document Library
    $List =$Ctx.Web.Lists.GetByTitle($ListName)
     
    #Define CAML Query to Get All Files
   $Query = New-Object Microsoft.SharePoint.Client.CamlQuery
   

                        $Query.ViewXml = "@<View Scope='RecursiveAll'>                             
                           <Query>
                                <Where>
                                    <And>
                                    <Eq><FieldRef Name='FSObjType' /><Value Type='Integer'>0</Value></Eq>
                                    
                                
                                    <Or>
                                    
                                    <Eq><FieldRef Name='ArchivalFlag' /><Value Type='Choice'>Yes</Value></Eq>
                                    
                                    <Lt><FieldRef Name='Created' /><Value Type='DateTime' IncludeTimeValue='True'>" + (get-date).adddays(-180).ToString("yyyy-MM-ddTHH:mm:ssZ") + "</Value></Lt>
                                    </Or>
                                    </And>
                                </Where>
                                
                            </Query>
                        </View>"


    #powershell sharepoint online list all documents
    $ListItems = $List.GetItems($Query)
    $Ctx.Load($ListItems)
    $Ctx.ExecuteQuery()
 
    $DataCollection = @()
    #Iterate through each document in the library
    ForEach($ListItem in $ListItems)
    {
        #Collect data       
        $Data = New-Object PSObject -Property ([Ordered] @{
            FileName  = $ListItem.FieldValues["FileLeafRef"]
            RelativeURL = $ListItem.FieldValues["FileRef"]
            CreatedBy = $ListItem.FieldValues["Created_x0020_By"]
            CreatedOn = $ListItem.FieldValues["Created"]
            ModifiedBy = $ListItem.FieldValues["Modified_x0020_By"]
            ModifiedOn = $ListItem.FieldValues["Modified"]
            FileSize = $ListItem.FieldValues["File_x0020_Size"]
        })
        $DataCollection += $Data
    }
    $DataCollection
 
    #Export Documents data to CSV
    $DataCollection | Export-Csv -Path $CSVPath -Force -NoTypeInformation
    Write-host -f Green "Documents Data Exported to CSV!"
}
Catch {
    write-host -f Red "Error:" $_.Exception.Message
}
