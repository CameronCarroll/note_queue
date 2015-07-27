cammy corner
=============

July 22, 2015
---------------
So I want a server that I can send POST requests to with my journal data.
This is an attempt to reduce friction even further, so that I don't even have to boot up Linux or even get onto my laptop in order to write to the journal.
I want to be able to send entries to the server to await download from my laptop.
I guess it should be deleted from the server afterwards? I don't really want it to be hanging out online.

So we should just accept POST requests with the message data, along with a date/time, and a secret pass. Then we should later be able to do a get request from my Linux and download the messages that I posted since last booting that up.

I guess I'll just build it now and leave the problem of securing it to later.
