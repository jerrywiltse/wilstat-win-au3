# wilstat-win-au3
Automatically exported from code.google.com/p/wilstat-win-au3
Wilstat is a client/server application pair I created with AutoIt to allow clients an efficient and flexible way to load balance across multiple windows terminal servers running Windows Server 2003. It requires the installation of a very lightweight system service (Wilstat Daemon: WilstatD.exe) on each server. It then requires users to install a lightweight client which connects to WilstatD to look for open sessions, find the server with least users, and then launches MSTSC via commandline with the parameters to connect to the selected server.

If I get any interest, I'll post screenshots and more documentation. It was my most advanced project to date and I don't have time to document it properly.

Here are basic usage instructions:

* Install WilstatD on your servers
* Install WilstatA for your clients
* If you have internet users, you need to forward two ports per server
* One port for Wilstat, and one for RDP
* Your clients will need those port numbers when adding servers to their list
* If your users are internal LAN users, your life is easy, just add different IP's with the default ports.


NOTE: MSTSC V6 really jacked this thing up and I tried to code around it with mixed results. Sorry if you have trouble. It all relates to stored credential settings and "Default.rdp" and all that. IMHO, MS really screwed the pooch on this release from an API perspective.
