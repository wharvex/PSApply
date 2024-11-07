function New-Apply {
    [CmdletBinding(SupportsShouldProcess)]
    $pos = Read-Host "Position"
    $emp = Read-Host "Employer"
    $loc = Read-Host "Location"
    $sal = Read-Host "Salary"
    $dis = Read-Host "Discovered Through"

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

    # Update ApplyCount
    $ac = [int]$lines + 1
    Set-Content -Path $count_path -Value $ac
    $apply_folder_name = "Apply$($ac)"

    # Create the apply folder
    mkdir $apply_folder_name

    Copy-Item -Path .\resumes\resume_main.pptx -Destination "$($apply_folder_name)/resume.pptx"
    Copy-Item -Path .\CoverLetters\NewTemplate.txt -Destination "$($apply_folder_name)/cover_letter.txt"
    Copy-Item -Path .\CoverLetters\NewTemplate.docx -Destination "$($apply_folder_name)/cover_letter.docx"
    $pos | Out-File -FilePath "$($apply_folder_name)/position.txt"
    $emp | Out-File -FilePath "$($apply_folder_name)/employer.txt"
    $loc | Out-File -FilePath "$($apply_folder_name)/location.txt"
    $sal | Out-File -FilePath "$($apply_folder_name)/salary.txt"
    $dis | Out-File -FilePath "$($apply_folder_name)/disc_thru.txt"
    "john smith`nhr`naddr`naddr" | Out-File -FilePath "$($apply_folder_name)/cover_letter_addr.txt"
    "description" | Out-File -FilePath "$($apply_folder_name)/description.txt"
    "required skills" | Out-File -FilePath "$($apply_folder_name)/required_skills.txt"
    "preferred skills" | Out-File -FilePath "$($apply_folder_name)/preferred_skills.txt"
    "applied on" | Out-File -FilePath "$($apply_folder_name)/applied_on.txt"
    vim $apply_folder_name
}
