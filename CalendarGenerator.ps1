param(
    [string]$InputFile
)

# Import the necessary module
Import-Module powershell-yaml

function ConvertTo-UTC
{
    param([datetime]$dateTime, [string]$timezone)

    $timezoneInfo = [System.TimeZoneInfo]::FindSystemTimeZoneById($timezone)
    $dateTime = [System.TimeZoneInfo]::ConvertTimeToUtc($dateTime, $timezoneInfo)
    return $dateTime
}

function Parse-Yaml
{
    param (
        [string]$YamlPath
    )
    $YamlContent = Get-Content -Path $YamlPath -Raw
    $YamlData = ConvertFrom-Yaml -Yaml $YamlContent
    return $YamlData
}


function Generate-ICS
{
    param(
        [string]$InputFile
    )

    # Read YAML data
    $yamlContent = Parse-Yaml $InputFile

    # Extract values from YAML
    $calName = if ($yamlContent.calName)
    {
        $yamlContent.calName
    }
    else
    {
        [System.IO.Path]::GetFileNameWithoutExtension($inputFile)
    }
    $startWeekDate = if ($yamlContent.startWeekDate)
    {
        [datetime]::ParseExact($yamlContent.startWeekDate, 'yyyy-MM-dd', $null)
    }
    else
    {
        [datetime]::ParseExact((Read-Host "Enter the start date of Week 0 (yyyy-MM-dd)"), 'yyyy-MM-dd', $null)
    }
    $timezone = $yamlContent.timezone
    $gmt = $yamlContent.gmt
    $params = $yamlContent.params
    $events = $yamlContent.events

    # Calculate start date (first Monday of the week)
    $dayOfWeek = (6 + [int]$startWeekDate.DayOfWeek) % 7
    $startDate = $startWeekDate.AddDays(-$dayOfWeek)

    Write-Host "Start week date is $($startWeekDate.ToString('yyyy-MM-dd') )"
    Write-Host "Start week date is day of week # $( $dayOfWeek )) ($( $startWeekDate.DayOfWeek ))"
    Write-Host "Start date(day 0 week 0) is $($startDate.ToString('yyyy-MM-dd') )"

    $icsContent = @"
BEGIN:VCALENDAR
VERSION:2.0
CALSCALE:GREGORIAN
METHOD:PUBLISH
X-WR-CALNAME:$calName
X-WR-TIMEZONE:$timezone
"@

    # Process each event
    foreach ($event in $events)
    {
        $summary = $event.event.summary
        $week = $event.event.week
        $day = $event.event.day

        Write-Host "Event data { day:$( $day ), week:$( $week ), startTime: $( $event.event.startTime ), endTime: $( $event.event.endTime )}"

        $startTime = [datetime]::ParseExact("$($startDate.AddDays($week * 7 + $day).ToString('yyyy-MM-dd') ) $( $event.event.startTime )", 'yyyy-MM-dd HH:mm', $null)
        $endTime = [datetime]::ParseExact("$($startDate.AddDays($week * 7 + $day).ToString('yyyy-MM-dd') ) $( $event.event.endTime )", 'yyyy-MM-dd HH:mm', $null)

        # Convert to UTC
        $startTimeUTC = ConvertTo-UTC -dateTime $startTime -timezone $timezone
        $endTimeUTC = ConvertTo-UTC -dateTime $endTime -timezone $timezone

        $description = $event.event.desc
        foreach ($param in $params)
        {
            $value = $param.value.Trim(" ", "`r", "`n", "`t")
            $description = $description.Replace("{{$( $param.param )}}", $value)
        }
        
        $description = $description.Trim(" ", "`r", "`n", "`t")
        $description = $description.Replace("`r", "")
        $description = $description.Replace("`n", "<br>")

        $icsContent += @"

BEGIN:VEVENT
SUMMARY:$summary
DTSTART:$($startTimeUTC.ToString('yyyyMMddTHHmmssZ') )
DTEND:$($endTimeUTC.ToString('yyyyMMddTHHmmssZ') )
DESCRIPTION:$description
END:VEVENT
"@
    }

    $icsContent += @"

END:VCALENDAR
"@

    # Save to .ics file
    $outputFile = [System.IO.Path]::ChangeExtension($inputFile, '.ics')
    $icsContent | Out-File -FilePath $outputFile -Force -Encoding UTF8
    Write-Host "ICS file saved to: $outputFile"
}

# Main function call
Generate-ICS -InputFile $InputFile
