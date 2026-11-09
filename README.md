## SUSE (Multi-Liux) Manager reposync-watcher tool
<p>A bash script to streamline watching and debugging repo sync in SUSE Manager. Compatible with 5.x and newer.</p>
<p>How to use: copy the reposync-watch.sh file to the SUSE Manager **host** (not the uyuni-server container).<br>
Make sure it's executable<br>
<code> chmod +x reposync-watch.sh</code><br>
and run by typing<br>
<code> ./reposync-watch.sh</code><br></p>
<p>Optionally, make it a system "command" for ease of use:<br>
<code> mv reposync-watch.sh /usr/local/bin/reposync-watch</code>
</p>
