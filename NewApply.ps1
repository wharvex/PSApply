function New-Apply {
    [CmdletBinding(SupportsShouldProcess)]

    # Read input data from user.
    $pos = Read-Host "Position"
    $emp = Read-Host "Employer"
    $loc = Read-Host "Location"
    $sal = Read-Host "Salary"
    $dis = Read-Host "Discovered Through"

    # Get current count.
    $count_path = "$($env:userprofile)\ApplyCount.txt"
    if (![System.IO.File]::Exists($count_path)) {
        Write-Host "$count_path not found."
        return
    }
    $count_file_contents = Get-Content $count_path

    # If the file contains more than one line, its type will be System.Object[]
    $count_file_contents_type = $count_file_contents.GetType()
    if ($count_file_contents_type -ne [System.String]) {
        Write-Host "$count_path must contain exactly one line."
        return
    }

    # Update ApplyCount
    $new_apply_count = [int]$count_file_contents + 1
    Set-Content -Path $count_path -Value $new_apply_count
    $apply_folder_name = "Apply$($new_apply_count)"

    # Create the apply folder
    # TODO: Do an error check here.
    mkdir $apply_folder_name

    # Create all necessary files.
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

    # Open the apply folder in vim.
    vim $apply_folder_name
}

# For debugging in VS Code.
if ($env:TERM_PROGRAM -eq "vscode") {
    New-Apply
}