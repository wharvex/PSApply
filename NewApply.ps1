function New-Apply {
    [CmdletBinding(SupportsShouldProcess)]

    # Read input data from user.
    $pos = Read-Host "Position"
    $emp = Read-Host "Employer"
    $loc = Read-Host "Location"
    $sal = Read-Host "Salary"
    $dis = Read-Host "Discovered Through"

    $get_and_verify_file_content = {
        param($file_name)

        # Get file content.
        $file_path = "$($env:userprofile)\$file_name"
        if (!(Test-Path $file_path)) {
            Write-Host "$file_path not found. Exiting..."
            return $null
        }
        $content = Get-Content $file_path

        # Verify file contains at least one line.
        if ($null -eq $content) {
            Write-Host "$file_path is empty. Exiting..."
            return $null
        }

        # Verify file content is exactly one line.
        # If the file contains more than one line, the type of its contents is `System.Object[]`.
        $content_type = $content.GetType()
        if ($content_type -ne [System.String]) {
            Write-Host "$file_path must contain exactly one line. Exiting..."
            return $null
        }
        return $content
    }

    # Get count file content.
    $count_file_content = & $get_and_verify_file_content("ApplyCount.txt")
    if ($null -eq $count_file_content) {
        return
    }

    # Get job search path file contents.
    # This file should contain the path to your `JobSearch` folder that contains all your templates,
    # previous applications, etc.
    $job_search_path_file_content = & $get_and_verify_file_content("JobSearchPath.txt")
    if ($null -eq $job_search_path_file_content) {
        return
    }

    # Update ApplyCount.
    $new_apply_count = [int]$count_file_content + 1
    Set-Content -Path "$($env:userprofile)\ApplyCount.txt" -Value $new_apply_count

    # Set path variables.
    $job_search_path = $job_search_path_file_content
    $apply_folder_name = "Apply$($new_apply_count)"
    $apply_folder_path = "$job_search_path\$apply_folder_name"

    # Create the apply folder.
    if (Test-Path $apply_folder_path) {
        Write-Host "$apply_folder_path already exists. Please adjust your count file."
        return
    }
    mkdir $apply_folder_path

    # Create files from templates.
    Copy-Item -Path "$($job_search_path)\Resumes\Template.pptx" -Destination "$($apply_folder_path)\Resume.pptx"
    Copy-Item -Path "$($job_search_path)\CoverLetters\Template.txt" -Destination "$($apply_folder_path)\CoverLetter.txt"
    Copy-Item -Path "$($job_search_path)\CoverLetters\Template.docx" -Destination "$($apply_folder_path)\CoverLetter.docx"

    # Create files from user input.
    $pos | Out-File -FilePath "$($apply_folder_path)\Position.txt"
    $emp | Out-File -FilePath "$($apply_folder_path)\Employer.txt"
    $loc | Out-File -FilePath "$($apply_folder_path)\Location.txt"
    $sal | Out-File -FilePath "$($apply_folder_path)\Salary.txt"
    $dis | Out-File -FilePath "$($apply_folder_path)\DiscoveredThru.txt"

    # Create other files.
    "john smith`nhr`naddr`naddr" | Out-File -FilePath "$($apply_folder_path)\CoverLetterAddr.txt"
    "description" | Out-File -FilePath "$($apply_folder_path)\Description.txt"
    "required skills" | Out-File -FilePath "$($apply_folder_path)\RequiredSkills.txt"
    "preferred skills" | Out-File -FilePath "$($apply_folder_path)\PreferredSkills.txt"
    "applied on" | Out-File -FilePath "$($apply_folder_path)\AppliedOn.txt"

    # Open environment.
    Start-Process "$($apply_folder_path)\Resume.pptx"
    Start-Process "$($job_search_path)\Resumes\TemplateOptions.pptx"
    Start-Process "$($apply_folder_path)\CoverLetter.docx"
    Set-Location $job_search_path
    vim .
}

# For debugging in VS Code.
if ($env:TERM_PROGRAM -eq "vscode") {
    New-Apply
}

