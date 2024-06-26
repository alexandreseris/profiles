function _base_auto_complete {
    param([string[]]$values, [string]$guess)
    $starting_match = $values | Where-Object { $_ -like "$guess*" }
    foreach ($match_val in $starting_match) {
        $match_val
    }
    $yolo_match = $values | Where-Object { $_ -like "*$guess*" -and $_ -notin $starting_match }
    foreach ($match_val in $yolo_match) {
        $match_val
    }
}


function _autocomplete_example {
    param(
        [System.String]$commandName,
        [System.String]$parameterName,
        [System.String]$wordToComplete,
        [System.Management.Automation.Language.CommandAst]$commandAst,
        [System.Collections.Hashtable]$fakeBoundParameters
    )
    $data = @() # retrieve some data
    _base_auto_complete $data $wordToComplete
}
