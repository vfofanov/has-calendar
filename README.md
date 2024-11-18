# Algo-calendar

Generates .ics file from yaml

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
