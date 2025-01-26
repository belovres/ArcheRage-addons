#------------- Original Author: Strawberry --------------
#--------------- Extra thanks to otu  -------------------
#---------------- Discord: exec_noir --------------------

param (
    [string]$lang = "en" #default is english
)

Add-Type -AssemblyName "System.Web"

$logFilePath = ".\ChatTranslationOutput_1.log"

function TranslateAndLog {
    param (
        [string]$lang,
        [string]$text
    )

    # check for "] :" or "]:"
    if ($text -match "(.*?\].*?\])\s*(.*)") {
        $prefix = $matches[1]  # before "] :" or "]:"
        $message = $matches[2]  # after "] :" or "]:"
        #Write-Host "The value of myVar is: $prefix and $message"
        # zone changes can just be skipped
        if ($message -match "@motherfaction|@zonegroupname|@coordinates") {
            return
        }

        $encodedMessage = [System.Web.HttpUtility]::UrlEncode($message)

        function translateThisGoogle {
            param (
                [string]$translate,
                [string]$text
            )
            $Uri = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$translate&dt=t&q=$text"
            $Response = Invoke-RestMethod -Uri $Uri -Method Get
            return $Response[0].SyncRoot | ForEach-Object { $_[0] }
        }

        $translation = translateThisGoogle -translate $lang -text $encodedMessage
        $translation = [System.Web.HttpUtility]::UrlDecode($translation)

        # don't print untranslated strings
        if ($translation -ne $message) {
            $logEntry = "$prefix $translation".Trim()
            try {
                Add-Content -Path $logFilePath -Value $logEntry -ErrorAction Stop -Encoding UTF8
            } catch {
                Write-Host "Error writing to log file: $_" -ForegroundColor Red
                exit 1
            }
        }
    }
}

function ProcessChatLog {
    $pathFile = 'ChatTranslationInput_1.log'
    if (Test-Path $pathFile) {
        Get-Content -Path $pathFile -Wait -Tail 0 -Encoding UTF8 | ForEach-Object {
            if ($_ -ne "") { #todo: add this as variable to bat
                TranslateAndLog -lang $lang -text $_
            }
        }
    } else {
        Write-Host "Chat log file not found: $pathFile"
        exit 2
    }
}

try {
    ProcessChatLog
} catch {
    Write-Host "Unexpected error: $_" -ForegroundColor Red
    exit 3
}
