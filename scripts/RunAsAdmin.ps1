param(
    [string]$ScriptToRun
)

Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$ScriptToRun`""