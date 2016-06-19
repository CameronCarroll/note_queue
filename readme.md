note queue
==========

* A small suite (three programs) in Ruby.
* Send messages to server from any device: CLI client for Linux has lowest friction, web form for larger breadth.
* Download messages with Linux CLI client, to aggregate your journal on a single computer.

Requirements
=============
Ruby (~2.3)
Vim





Where I left off:
Was implementing the key system...
server needs to generate a cryptorandom ID for the user API key,
and also a cryptorandom secure key of appropriate length for the hash function used in the hmac
we need to make those available in the dash
we need to make sure everything is sent over ssl

then once the website is set up, the api needs to be protected
so before each route, we take the HTTP authorization header, split it up intoclient ID and signature, use the client ID to look up the appropriate secret key, use the secret key plus the request info tho build the signature
if the signatures match, then we let the route do whatever it was going to do

then we need to make those routes only interact with the data for that client ID

then we need to update client programs to sent the authorization header
