## SUSE (Multi-Liux) Manager reposync-watcher tool
A bash script to streamline watching and debugging repo sync in SUSE Manager. Compatible with 5.x and newer.
How to use: copy the reposync-watch.sh file to the SUSE Manager *host* (not the uyuni-server container).
Make sure it's executable
> chmod +x reposync-watch.sh
and run by typing
> ./reposync-watch.sh
Optionally, make it a system "command" for ease of use:
> mv reposync-watch.sh /usr/local/bin/reposync-watch
