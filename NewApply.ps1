function New-Apply {
    [CmdletBinding(SupportsShouldProcess)]
    $pos = Read-Host "Position"
    $emp = Read-Host "Employer"

    $count_path = "$($env:userprofile)\ApplyCount.txt"
    if (![System.IO.File]::Exists($count_path)) {
        Write-Host "$count_path not found."
        return
    }

    $lines = Get-Content $count_path
    if ($lines.Length -ne 1) {
        Write-Host "$count_path must contain exactly one line."
        return
    }

    $ac = [int]$lines + 1
    Set-Content -Path $count_path -Value $ac
    $apply_folder_name = "Apply$($ac)"
    mkdir $apply_folder_name
    $pos | Out-File -FilePath "$($apply_folder_name)/position.txt"
    $emp | Out-File -FilePath "$($apply_folder_name)/employer.txt"
    "cover letter" | Out-File -FilePath "$($apply_folder_name)/cover_letter.txt"
    "john smith`nhr`naddr`naddr" | Out-File -FilePath "$($apply_folder_name)/cover_letter_addr.txt"
    "duties" | Out-File -FilePath "$($apply_folder_name)/duties.txt"
    vim $apply_folder_name
}
