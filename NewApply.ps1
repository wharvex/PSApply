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

    # Get job search path file contents.
    # This file should contain the path to your `JobSearch` folder that contains all your templates,
    # previous applications, etc.
    $job_search_path_file_content = & $get_and_verify_file_content("JobSearchPath.txt")
    if ($null -eq $job_search_path_file_content) {
        return
    }

    # Get the largest integer suffix of the `Apply` folder names.
    $max_apply_folder_suffix = $(Get-ChildItem $job_search_path_file_content `
    | Select-Object -ExpandProperty Name `
    | Where-Object {$_ -match '^Apply*'} `
    | Select-Object @{Name='suffixes';Expression={[int]$_.Substring(5)}}).suffixes `
    | Measure-Object -Maximum

    # Update ApplyCount.
    if ($null -eq $max_apply_folder_suffix.Maximum) {
        $new_apply_count = 1
    } else {
        $new_apply_count = $max_apply_folder_suffix.Maximum + 1
    }

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
    Copy-Item -Path "$($job_search_path)\resumes\ats_resume_projects.docx" -Destination "$($apply_folder_path)\Resume.docx"
    Copy-Item -Path "$($job_search_path)\CoverLetters\new_template.docx" -Destination "$($apply_folder_path)\CoverLetter.docx"
    Copy-Item -Path "$($job_search_path)\EmailTemplate.txt" -Destination "$($apply_folder_path)\Email.txt"

    # Create files from user input.
    $pos | Out-File -FilePath "$($apply_folder_path)\Position.txt"
    $emp | Out-File -FilePath "$($apply_folder_path)\Employer.txt"
    $loc | Out-File -FilePath "$($apply_folder_path)\Location.txt"
    $sal | Out-File -FilePath "$($apply_folder_path)\Salary.txt"
    $dis | Out-File -FilePath "$($apply_folder_path)\DiscoveredThru.txt"

    # Create other files.
    "address" | Out-File -FilePath "$($apply_folder_path)\CoverLetterAddr.txt"
    "Can you identify the top 5-10 keywords/skills from this job description?" `
    | Out-File -FilePath "$($apply_folder_path)\Description.txt"
    "keywords" | Out-File -FilePath "$($apply_folder_path)\Keywords.txt"

    # Open environment.
    Start-Process "$($apply_folder_path)\Resume.docx"
    Start-Process "$($job_search_path)\resumes\ats_resume_options.docx"
    Start-Process "$($apply_folder_path)\CoverLetter.docx"
    Set-Location $job_search_path
    vim .
}

# For debugging in VS Code.
if ($env:TERM_PROGRAM -eq "vscode") {
    New-Apply
}
