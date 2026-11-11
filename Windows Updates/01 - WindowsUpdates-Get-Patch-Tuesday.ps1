function Get-PatchTuesday {
    $Month = Get-Date -Format 'MMMM'
    switch ((Get-Date -Day 1).DayOfWeek) {
        'Tuesday'   {return "Patch Tuesday is on $Month 8th"}
        'Monday'    {return "Patch Tuesday is on $Month 9th"}
        'Sunday'    {return "Patch Tuesday is on $Month 10th"}
        'Saturday'  {return "Patch Tuesday is on $Month 11th"}
        'Friday'    {return "Patch Tuesday is on $Month 12th"}
        'Thursday'  {return "Patch Tuesday is on $Month 13th"}
        'Wednesday' {return "Patch Tuesday is on $Month 14th"}
    }
}

New-Alias -Name gpt -Value Get-PatchTuesday
