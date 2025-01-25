#------------- Original Author: Strawberry --------------
#--------------- Extra thanks to otu  -------------------
#---------------- Discord: exec_noir --------------------

$logFilePath = ".\ChatTranslationOutput_1.log"

function TranslateAndLog {
    param (
        [string]$lang,
        [string]$text
    )

    # check for "] :" or "]:"
    if ($text -match "(.*?[\]:])\s*(.*)") {
        $prefix = $matches[1]  # before "] :" or "]:"
        $message = $matches[2]  # after "] :" or "]:"
       
        $prefix = $prefix -replace "\s+", ""
        function translateThisGoogle {
            param (
                [string]$translate,
                [string]$text
            )
            $Uri = "https://translate.googleapis.com/translate_a/single?client=gtx&sl=auto&tl=$translate&dt=t&q=$text"
            $Response = Invoke-RestMethod -Uri $Uri -Method Get
            return $Response[0].SyncRoot | ForEach-Object { $_[0] }
        }
        $translation = ""
        if ($message.Trim() -ne "") {
            $translation = translateThisGoogle -translate $lang -text $message
        } else {
            $translation = $message 
        }
        $logEntry = "$prefix $translation".Trim()
        Add-Content -Path $logFilePath -Value $logEntry
    }
}
function ProcessChatLog {
    $pathFile = 'ChatTranslationInput_1.log'
    if (Test-Path $pathFile) {
        Get-Content -Path $pathFile -Wait -Tail 0 -Encoding UTF8 | ForEach-Object {
		    #change "en" here to whatever you want
			#maybe make this an in-game setting somehow? idk
            if ($_ -ne "") {
                TranslateAndLog -lang "en" -text $_
            }
        }
    } else {
        Write-Host "Chat log file not found: $pathFile"
    }
}
ProcessChatLog