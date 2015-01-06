Invoke-SqlcmdEx
===============

Normal **sqlcmd.exe** and **Invoke-Sqlcmd** cmdlet don't report error lines correctly if there are GO statements in the sql file.

See http://stackoverflow.com/questions/27785390/get-real-sql-error-line-number for more details

The goal of this project is to provide a way to run any SQLCMD-compatible script and report the real error line
