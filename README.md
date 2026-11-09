## SUSE (Multi-Liux) Manager reposync-watcher tool
A bash script to streamline watching and debugging repo sync in SUSE Manager. Compatible with 5.x and newer.

### What does it do?

- It identifies the repo currently being synchronised and follows its log. Displays up to 10 recent log entries.
- If it encounters any error entries it sticks them at the top so they don't get pushed out by rapidly coming new messages.
- Has a simple % disk full indicator that checks the container volume.
- Shows you the exact command to kill the current sync process in case it gets stuck (server will then automatically move on to the next repo in the queue, if there are any).

Has an activity indicator so that you can tell that the script is working even if messages stop coming for a while. Refreshes every 2s so as not to swamp the server.

### How to use
Copy the reposync-watch.sh file to the SUSE Manager **host** (not the _uyuni-server_ container).


Make sure it's executable
>chmod +x reposync-watch.sh

and run by typing
>./reposync-watch.sh

Optionally, make it a system "command" for ease of use:
>mv reposync-watch.sh /usr/local/bin/reposync-watch


