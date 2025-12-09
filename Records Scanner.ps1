<#
This script was created to help prevent accidental data loss, deletion, or destruction amdist the company's Windows 10 to Windows 11 upgrade.
Many users, especially full time staff, have a large number of files stored on their deprecated devices. While thorough manual inspection 
by the end user is still highly recommended, this script is designed to provide an extra safegaurd from accidental destruction by highlighting 
files or directories that may contain critical, long-term records that the organization must retain to ensure legal compliance.

This script will recursively search all the file and directory names within a target directory on a drive and compare the file names
with a list of keywords to identify important records. The end user or technician will EVENTUALLY have the ability to add keywords 
that are specific to their use case and file naming convention. 
#>

$directory = $pwd

#############################################
# KEYWORD LIST
#############################################

# General 
$testKeywords = @("waiver", "statement", "resume", "liability", "release")
$10GeneralKeywords = @("agreement", 
    "audit", 
    "compliance", 
    "confidential", 
    "contract", 
    "invoice", 
    "legal", 
    "policy", 
    "report", 
    "tax")
$25GeneralKeywords = @("agenda", 
    "agreement", 
    "application", 
    "audit", 
    "budget", 
    "compliance", 
    "confidential", 
    "contract", 
    "credentials", 
    "financial", 
    "insurance", 
    "invoice", 
    "legal", 
    "license", 
    "meeting", 
    "minutes", 
    "payroll", 
    "policy", 
    "receipt", 
    "regulation", 
    "report", 
    "settlement", 
    "statement", 
    "tax", 
    "waiver")
$50GeneralKeywords = @("agenda", 
    "agreement", 
    "application", 
    "arbitration", 
    "audit", 
    "balance", 
    "benefits", 
    "budget", 
    "bylaw", 
    "compliance", 
    "confidential", 
    "contract", 
    "credentials", 
    "credit", 
    "debit", 
    "deposition", 
    "due diligence", 
    "election", 
    "employee", 
    "financial", 
    "governance", 
    "insurance", 
    "intellectual property", 
    "invoice", 
    "legal", 
    "license", 
    "litigation", 
    "manual", 
    "meeting", 
    "minutes", 
    "NDA", 
    "payroll", 
    "performance", 
    "personnel", 
    "policy", 
    "privileged", 
    "receipt", 
    "regulation", 
    "report", 
    "risk", 
    "safety", 
    "schedule", 
    "settlement", 
    "statement", 
    "subpoena", 
    "tax", 
    "termination", 
    "training", 
    "vendor", 
    "waiver", 
    "warranty", 
    "work order")

# Department
$HR = @("ADA", 
    "application", 
    "benefits", 
    "compensation", 
    "contract", 
    "disciplinary", 
    "EEO", 
    "employee", 
    "evaluation", 
    "FMLA", 
    "health", 
    "insurance", 
    "medical", 
    "payroll", 
    "performance", 
    "personnel", 
    "resume", 
    "review", 
    "salary", 
    "termination")
$FS = @("accounts payable", 
    "accounts receivable", 
    "audit", 
    "balance sheet", 
    "bank", 
    "bill", 
    "budget", 
    "compliance", 
    "credit", 
    "debit", 
    "financial report", 
    "forecast", 
    "invoice", 
    "IRS", 
    "ledger", 
    "reconciliation", 
    "receipt", 
    "statement", 
    "tax", 
    "trial balance")
$IT = @("backup", 
    "breach", 
    "configuration", 
    "credentials", 
    "disaster recovery", 
    "encryption", 
    "firewall", 
    "incident report", 
    "license", 
    "network", 
    "patch", 
    "password", 
    "restore", 
    "security", 
    "settings", 
    "software agreement", 
    "system logs")
$MDPR = @("advertisement", 
    "announcement", 
    "branding", 
    "campaign", 
    "event", 
    "logo", 
    "marketing", 
    "media", 
    "newsletter", 
    "partnership", 
    "press release", 
    "promotion", 
    "public statement", 
    "social media", 
    "sponsorship",
    "template")
$customerServices = @("agreement", 
    "billing", 
    "class", 
    "complaint", 
    "contract", 
    "customer feedback", 
    "health form", 
    "invoice", 
    "liability", 
    "membership", 
    "payment", 
    "schedule", 
    "trainer", 
    "waiver")
$studGov = ("agenda", 
    "ballot", 
    "budget", 
    "bylaws", 
    "candidate", 
    "charter", 
    "constitution", 
    "election", 
    "event", 
    "funding", 
    "initiative", 
    "meeting minutes", 
    "program")
$CC = @("allergy", 
    "application", 
    "behavior log", 
    "consent form", 
    "curriculum", 
    "emergency contact", 
    "enrollment", 
    "immunization", 
    "incident report", 
    "lesson plan", 
    "medical", 
    "registration")
$CnE = @("agenda", 
    "attendee list", 
    "budget", 
    "contract", 
    "invoice", 
    "marketing", 
    "payment", 
    "program", 
    "promotion", 
    "registration", 
    "schedule", 
    "sponsorship", 
    "vendor")
$custodial = @("cleaning schedule", 
    "compliance", 
    "equipment", 
    "hazard", 
    "incident report", 
    "inspection", 
    "inventory", 
    "OSHA", 
    "safety", 
    "supplies")
$maintenance = @("compliance", 
    "equipment", 
    "incident report", 
    "inspection", 
    "log", 
    "manual", 
    "repair", 
    "safety", 
    "schedule", 
    "service", 
    "warranty", 
    "work order")
$legal = @("agreement", 
    "arbitration", 
    "brief", 
    "compliance", 
    "confidential", 
    "contract", 
    "copyright", 
    "court", 
    "deposition",
    "disclosure", 
    "due diligence", 
    "intellectual property", 
    "lawsuit", 
    "legal opinion", 
    "litigation", 
    "mediation", 
    "MOU", 
    "NDA", 
    "non-disclosure", 
    "patent", 
    "pleading", 
    "privileged", 
    "regulation", 
    "risk assessment", 
    "settlement", 
    "statute", 
    "subpoena", 
    "terms", 
    "trademark")

# Create a variable to hold the final keywords list
$keywords = [System.Collections.Generic.List[string]]::new()

# Populate the keywords list with a preset array
foreach ($element in $testKeywords) {
    $keywords.Add($element)
}

# Optional: Display the list
$keywords

<# 
TODO: 
    Prompt for adding additional keywords
    Duplicate checker
    Display count for each keyword 
    Department specific keyword lists
    Select verbosity
        Keywords found or not?
        Keyword Count
        Directories only
            Of directories with keyword matches in name, more granular search of files
        Directories and files
    Backed up or not?
    Generate a report
#>

#############################################
# SCAN ALL FILES AND DIRECTORIES
#############################################

# Save all files and directories as a variable
$items = Get-ChildItem -Path $directory -Recurse | Sort-Object Name

#############################################
# KEYWORD MATCH COUNT
#############################################

# Count the number of times a keyword match is found columns: keyword, total, directories only, files only
$keywordCount = New-Object 'object[,]' $keywords.Count,4 

# For each keyword, find total, file, and directory match counts
for ($i=0; $i -lt $keywords.Count; ++$i) {
    Write-Host "Searching for $($keywords[$i])" # Search all file and directory names for matches of each word
    $matches = $items | Where-Object { $_.Name -match $keywords[$i] } # Save all files and directories with a keyword match into the matches variable
    $keywordCount[$i,0] = $keywords[$i] # Specify which keyword found the match
    $keywordCount[$i,1] = $matches.Count # Total matches
    $keywordCount[$i,2] = ($matches | Where-Object { -not $_.PSIsContainer }).Count # File matches
    $keywordCount[$i,3] = ($matches | Where-Object { $_.PSIsContainer }).Count # Directory matches
}


# Convert to custom PowerShell objects to display as a table
#$headers = @("Keyword", "Total Matches", "Files", "Folders")
$keywordTable = for ($i = 0; $i -lt $keywordCount.GetLength(0); $i++) {
    [PSCustomObject]@{
        "Keyword"       = $keywordCount[$i,0]
        "Total Matches" = $keywordCount[$i,1]
        "Files"         = $keywordCount[$i,2]
        "Folders"       = $keywordCount[$i,3]
    }
}

# Display as table
$keywordTable | Format-Table -AutoSize

#############################################
# MATCHED ITEM NAMES
#############################################

<# Recursively search directories and files for keyword matches
Write-Host "Recursively searching for keyword matches within $($directory)."
foreach ($keyword in $keywords) {
    $items | Where-Object { $_.Name -match $keyword } | Select-Object Name
}
#>

# For each item, check if any of the keywords are within the item name
foreach ($item in $items) {
    foreach ($keyword in $keywords) {
        if ($item.Name -match $keyword) {
            Write-Host "$($item.Name)"
        }
    }
}

#https://github.com/That-Bearded-IT-Guy/C-Cleanup-Script/blob/main/C-Drive-Cleanup.ps1
