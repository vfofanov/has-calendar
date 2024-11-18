# Algo-calendar

Generates .ics file from yaml

## Prerequisites 
For run generation 
1. Install [PowerShell](https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell?view=powershell-7.4)
2. Install [powershell-yaml](https://www.powershellgallery.com/packages/powershell-yaml)
   ```shell
   Install-Module -Name powershell-yaml
   ```
3. (Optional)If you have problems to install `powershell-yaml`. Run a script bellow and rerun the script 2. 
   ```shell
   Unregister-PackageSource -Name PSGallery
   Register-PSRepository -Default -InstallationPolicy Trusted
   ```
   
## Usage
1. Apply changes to `Schedule.yml`

| Param         | Description                                                                                                              |
      |---------------|--------------------------------------------------------------------------------------------------------------------------|
| `startWeekDate` | One of a dates on Week 0. (eg. `Monday` on `Week 0`). <br/>Events' dates will be relative based on Week 0 Monday's date. |
| `timezone`      | Timezone of the calendar. <br/>All the events `startTime` and `endTime` relative to the timezone.                        |
| `params`        | Shared key-values that can be used as place holders in event description                                                 |

2. Run generator
    ```shell
    ./CalendarGenerator.ps1 -InputFile ".\Schedule.yml"
    ```
3. Create new Google calendar.
4. Import `Schedule.yml` to newly created calendar.  _NOTE: Better to import to new calendar - it's easy to delete whole calendar))_
   ![Image](Import.png)
