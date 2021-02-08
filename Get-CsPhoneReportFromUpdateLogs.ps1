<#
.DESCRIPTION
	This script read the RequestHandlerAuditLog and creates a file with the unique phones on them, using the MAC Address as unique identifier.
 
.NOTES
  Version      	   		: 1.0
  Author    			: David Paulino https://uclobby.com
  
#>

[CmdletBinding()]
param(
[parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true)]
    [string] $LogFolder,
[parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true)]
    [string] $OutputFile,
[parameter(ValueFromPipeline = $false, ValueFromPipelineByPropertyName = $true)]
	[int] $Days
)

$startTime=Get-Date;
$Phones =@{}
$totalEntries = 0
$filesProc = 0

#Default is files newer than 30 days.
if(!($Days)){
    $Days = 30
} 
$fromDateFiles =  (Get-Date).AddDays(-$Days)
Write-Host "Reading files from" $fromDateFiles -ForegroundColor DarkGreen

$logFiles = Get-ChildItem $LogFolder | Where-Object {($_.LastWriteTime -gt $fromDateFiles ) } | Sort-Object  LastWriteTime -Descending 
$filesTotal = $logFiles.Count

foreach($logFile in $logFiles){

    if( (Get-Content $logFile.PSPath  -First 1).StartsWith("Logging DateTime,")){

        $lines = Import-Csv -Path $logFile.PSPath

        $filesProc++
        $statusMsg = "File: " + $filesProc + " of " + $filesTotal + " - " + $logFile.Name

        Write-Progress -Activity 'Phone Report From Log - Please wait, good things take time.' -Status $statusMsg -PercentComplete ((($filesProc) / $filesTotal ) * 100)

        foreach($Phone in $lines){
            $totalEntries++ 

            $PhoneInfo = New-Object PSObject -Property @{            
                MACAddress = $Phone.'Mac Address'
                Vendor = $Phone.Vendor
                Model = $Phone.Model
                Revision = $Phone.Revision
                LastLogging = $Phone.'Logging DateTime'
                IPAddress = $Phone.'User Host Address'}

            if($Phones.ContainsKey($PhoneInfo.MACAddress)){
                #We need to compare which entry is newer. We only want to store the LastLogging
                $tmpPhoneInfo = $Phones[$PhoneInfo.MACAddress]
                if($tmpPhoneInfo.LastLogging -lt $PhoneInfo.LastLogging){
                    $Phones.Set_Item($PhoneInfo.MACAddress, $PhoneInfo)
                }
            } else {
                #New entry so we simply add it.
                $Phones.add($PhoneInfo.MACAddress, $PhoneInfo)
            }
        }
    } else {
        Write-Host "Skipping non log file:" $logFile.Name  -ForegroundColor Yellow
    }
}

if($OutputFile) {

} else {
    
 $OutputFile = (Get-Location).Path + "\" + "PhoneReportLog_" + $Days + "_"+ (Get-Date -Format ([cultureinfo]::CurrentCulture.DateTimeFormat).ShortDatePattern).Replace('/','-') + ".csv"

}

Write-Host "Processed files " $filesTotal 

if($Phones.Count -gt 0){
    Write-Host "Total Phone Entries" $totalEntries
    Write-Host "Unique Phones" $Phones.Count 
    Write-Host "Output file:" $OutputFile
    $Phones.Values | Select MACAddress, Vendor, Model, IPAddress, LastLogging | Export-Csv $OutputFile -NoTypeInformation
}

$endTime=Get-Date
$totalTime= [math]::round(($endTime - $startTime).TotalSeconds,2)
Write-Host "Execution time:" $totalTime "seconds." -ForegroundColor Cyan