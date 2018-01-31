# scan

This is a perl wrapper around nmap to try and make the results a bit more human readable (it also does some work around working out what subnet to scan.)

You'll want to run this on the host network I suspect

    docker run \
       -it \
       --network=host \
       martinjohn/scan
