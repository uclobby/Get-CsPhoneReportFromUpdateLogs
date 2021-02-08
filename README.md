# Get-CsPhoneReportFromUpdateLogs
This script read the RequestHandlerAuditLog and creates a file with the unique phones on them, using the MAC Address as unique identifier.

Usage:
<br>Get-CsPhoneReportFromUpdateLogs.ps1

-LogFolder (required)
<br>We need to specify the update log locations, this can be local or network share.

-OutputFile (optional)
<br>This allows to specify a different output file, the default is in the script location.

-Days (optional)
<br>By default the script reads files newer than 30 days.

Change Log
<br>v1.0 – 2021/02/08 - Initial release
