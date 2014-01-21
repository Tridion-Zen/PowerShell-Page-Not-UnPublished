#
cls
write-host "Wait.....!"
$tcm = get-content "PATH\CONFIG_URL.TXT" # e.g. textfile with the CMS CoreService URL: http://SERVER/webservices/coreservice2011.svc 
$uid = get-content "PATH\CONFIG_UID.TXT" # e.g. textfile with the Tridion user using the CoreService: DOMAIN\USERNAME 
$pwd = get-content "PATH\CONFIG_PWD.TXT" # e.g. textfile with the password for the Tridion user using the CoreService: "Passw0rd!"
$encryptedPass = convertto-securestring $pwd -asplaintext -force
$creds = new-object system.management.automation.pscredential($uid, $encryptedPass)
$client = new-webserviceproxy -uri $tcm -namespace tcm -class core -credential $creds
try {
    write-host "Client   |" $client.url
    write-host "Version  |" $client.getapiversion()
    write-host "User     |" $client.getcurrentuser().title
} catch {
    write-host "Problem  |" $_
    $client.dispose()
    $client = $null
    $creds = $null
}
#
# user editable data, e.g. "tcm:11-22333-66"
$pages = @()
#
$pages | % {
    $page = $client.read($_, $null)
    write-host "Page $($page.id)  $($page.title)  " -nonewline
    
    $publishInfo = $client.GetListPublishInfo($page.id)
    if ($publishInfo) {
        write-host
        $publishInfo | % {
            write-host " $($_.publicationtarget.title) $($_.publishedat) $($_.user.title) " -foregroundcolor red
        }
    } else {
        write-host "not published" -foregroundcolor green
    }
}
#
$client.dispose()
$client = $null
#
# end of script ##
