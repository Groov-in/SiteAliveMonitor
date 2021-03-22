# Site Alive Monitor Script.

Site Alive Monitor Script is written in Bash shell script.

Monitor the life and death of your site using PING, PORT, HTML, and SMTP protocols.

https://groov-in.github.io/SiteAliveMonitor/

## Getting started

```bash
# git clone https://github.com/Groov-in/SiteAliveMonitor.git
# cd SiteAliveMonitor

# cp -a site_alive_monitor.sh path/to/.
# cp -a site_alive_monitor.conf.sample path/to/my_site_alive_monitor.conf

# vi path/to/my_site_alive_monitor.conf
(Edit...)

# path/to/site_alive_monitor.sh path/to/my_site_alive_monitor.conf
```
crontab examples:
Site check every 5 minutes.
*/5 * * * * root path/to/site_alive_monitor.sh path/to/my_site_alive_monitor.conf

## License
[MIT License](https://github.com/Groov-in/SiteAliveMonitor/blob/main/LICENSE)
