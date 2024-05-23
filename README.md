# owndyndns
Dynamic DNS client solution intended to be used with Aware Soft DNS API. If you don't have an API key you can't use this as is. If you're interested for more details shoot us an email at contact@aware.ro.

# other usage
You might find this useful as a starting point if you need a custom lightweight DNS client and don't want to start from scratch. Implementation is pretty short, with some bash skills you should be able to change the script to your particular use case.

# installation
* This section assumes you have an API key for the Aware DNS API.
* Copy the key into `/etc/owndns.key`
* Clone the repo, change dir into it and run `./install`
```
git clone https://github.com/AwareRO/owndyndns.git
cd owndyndns
./install
```
* If you need to uninstall the software inside the repo dir run `./uninstall`
