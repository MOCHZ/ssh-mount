README
ssh-mount is a simple script for mounting with sshfs.
This is a proof of concept script I wrote to easily be able to mount external partitions through sshfs.

Why? Because updating a milion aliases on various computers is a pain,
much easier to just update a single config file once in a while.

To anyone that feels it will benefit them, you are welcome :-)

USAGE

ssh-mount.pl -s <SERVER_NAME>

-s | --specific <SERVER_NAME>          Mounts a given server in ~/.ssh-mounts/serverlist
-all                                   Mounts all servers in ~/.ssh-mounts/serverlist
-a | --available                       Show available servers to mount
-h | --help                            Show this help message
