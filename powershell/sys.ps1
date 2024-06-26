# env variables
function env_get {
    param(
        [string]$name,
        [System.EnvironmentVariableTarget]$context = [System.EnvironmentVariableTarget]::User
    )
    [System.Environment]::GetEnvironmentVariable($name, $context)
}


function env_set {
    param(
        [string]$name,
        [string]$value,
        [switch]$persist,
        [System.EnvironmentVariableTarget]$context = [System.EnvironmentVariableTarget]::User
    )
    if ($persist) {
        $old = env_get $name $context
        [System.Environment]::SetEnvironmentVariable($name, $value, $context)
        $old
    } else {
        Set-Item "env:$name" $value
    }
}


function env_del {
    param(
        [string]$name,
        [switch]$persist,
        [System.EnvironmentVariableTarget]$context = [System.EnvironmentVariableTarget]::User
    )
    env_set -name $name -value $null -context $context --persist:$persist
}


# path env variable
function env_get_path {
    param(
        [System.EnvironmentVariableTarget]$context = [System.EnvironmentVariableTarget]::User
    )
    (env_get -name "path" -context $context) -split ";" | where-object {$_ -ne ""}
}


function _env_set_path {
    param(
        [String[]]$paths,
        [switch]$persist,
        [System.EnvironmentVariableTarget]$context = [System.EnvironmentVariableTarget]::User
    )
    $joined = ($paths -join ";") + ";"
    env_set -name "path" -value $joined -persist:$($persist) -context $context
    $pretty_paths = $paths -join "`n"
    write-warning "changed path on $context with persists $persist with the following:`n$pretty_paths"
}


function env_add_path {
    param(
        [string]$path,
        [switch]$persist,
        [System.EnvironmentVariableTarget]$context = [System.EnvironmentVariableTarget]::User
    )
    $path_env = env_get_path -context $context
    if ($path -notin $path_env) {
        $path_env = @($path) + $path_env
        _env_set_path -paths $path_env -persist:$($persist) -context $context
    }
}


function env_del_path {
    param(
        [string]$path,
        [switch]$persist,
        [System.EnvironmentVariableTarget]$context = [System.EnvironmentVariableTarget]::User
    )
    $path_env = env_get_path -context $context
    if ($path -in $path_env) {
        $path_env = $path_env | Where-Object { $_ -ne $path }
        _env_set_path -paths $path_env -persist:$($persist) -context $context
    }
}
