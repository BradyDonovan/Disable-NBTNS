# Disable-NBTNS
Disables NetBIOS over TCP/IP on every system interface.

# Instructions
Execute the script in any fashion you'd like. Must run as Administrator, so it's ideal for GPO or some kind of elevated configuration management (SCCM?) to handle execution.  
`powershell.exe -File Disable.NBTNS.ps1`

# Logging
There is a log that is written to C:\Windows\Temp\ that will list all interfaces found & modified. The file name will be along the lines of `Disable-NBTNS$($datetime).log`, with `$datetime` being in `ddMMyyyyhhmmss` format. Example: `Disable-NBTNS19042019111636.log`

Happy hardening!
