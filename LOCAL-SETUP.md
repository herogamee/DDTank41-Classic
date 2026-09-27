# DDTank 4.1 Local Bootstrap

Branch `local-bootstrap` keeps `main` aligned with SkelletonX while fixing confirmed localhost blockers.

## Databases

Restore:

- `Db/Db_Membership_20200702.BAK` as `Db_Membership`
- `Db/Db_Tank_20200702.BAK` as `Db_Tank`
- `Db/Db_Tank41.BAK` as `Db_Tank41`

Then run `Local/Db_Count-Minimal.sql`. The upstream source references `Db_Count` but does not include its backup.

## Configure

PowerShell:

    Set-ExecutionPolicy -Scope Process Bypass
    .\Local\local-bootstrap.ps1 -SqlServer ".\SQLEXPRESS" -SqlUser "sa" -SqlPassword "YOUR_LOCAL_SA_PASSWORD"

The SQL password is supplied at runtime and is not committed.

## Build

Open `Source Server/DDTank 4.1.sln` in Visual Studio. Install the required .NET Framework targeting packs if Visual Studio reports a missing target framework.

Startup order:

1. Center.Service
2. Fighting.Service
3. Road.Service
4. IIS Request application at `/request`
5. Web application at `/`

Known ports: Road 9200, Center 9202, Fighting 9208, Center WCF HTTP 2008, Center WCF net.tcp 2009.

Do not merge into `main` until login/PvP/PvE/Pet/Farm/Forge/Guild/Marriage smoke tests pass.
