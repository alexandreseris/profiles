function function_definition {
	<#
	.SYNOPSIS
		return the code of the function passed as parameter
	#>
	param(
		[string]$function_name
	)
	return (get-command $function_name).definition
}


function date_format {
	<#
	.SYNOPSIS
		function to format a date (current date by default with iso 8601)
	#>
	param(
		[Parameter(Mandatory = $false)][DateTime]$date = $(get-date),
		[Parameter(Mandatory = $false)][string]$date_format = 'yyyy-MM-ddTHH:mm:ss.fffffffK'
	)
	$date.ToString($date_format)
}


function hashtable_to_custom_object {
	<#
	.SYNOPSIS
		wrapper to convert hashtable to custom object
	#>
	param (
		[Hashtable]$hashtable
	)
	$object = New-Object PSObject
	$hashtable.GetEnumerator() | ForEach-Object { 
		Add-Member -inputObject $object -memberType NoteProperty -name $_.Name -value $_.Value
	}
	return $object
}
