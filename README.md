## retaliation.rb - Launching Missiles at your Coworkers

* Heavily based on [retaliation.py](https://github.com/codedance/Retaliation), a python API for the same product which comes with Jenkins integration


### Summary

retaliation.rb is (so far) a comprehensive Ruby API for controlling a small foam-missile turret. Intended for use against coworkers who break the build, it responds to a wide variety of commands to control movement, targeting,
and firing. Separately, it will integrate with our TeamCity server to automatically target offenders.

### Hardware

Compatible with the Thunder and Storm OICW missile launchers from [DreamCheeky](http://www.dreamcheeky.com/thunder-missile-launcher). Note that you can pick the Thunder up for less from [ThinkGeek](http://www.thinkgeek.com/geektoys/warfare/8a0f/?srp=2), but ThinkGeek's marketing copy (as of 20Jan2012) is wrong, despite my efforts to correct them; it is the exact same product offered by DreamCheeky. The Launcher has 270 degrees of horizontal rotation, about 20 degrees of vertical, and incredibly inaccurate darts. It can be ceiling-mounted, though it doesn't work as well that way.

### Installation

API is built using the ruby-usb library, which is a bit of a maintenance nightmare but appears to be the best available option. My work machine is a Mac, and in the office we're running the launchers off of a Mac Mini, so
installation instructions are for OS X. I expect it's considerably easier on Linux, I may someday bring a launcher home so I can write up installation instructions for Ubuntu. Aside from ruby-usb, there is no installation required for the Launcher, it's plug-and-play.

Installation instructions taken from [here](http://www.jedi.be/blog/2009/11/11/ruby-usb-libusb/).

1. Install libusb-compat via MacPorts. (I tried installing from source, couldn't get it to work, strongly recommend MacPorts here).
2. Download ruby-usb: http://www.a-k-r.org/ruby-usb/
3. Open up the ruby-usb code, and replace extconf.rb with the following:

    ```ruby
    require 'mkmf' 
    find_header("usb.h", "/opt/local/include") 
    find_library("usb", nil, "/opt/local/lib") 
    have_library("usb", "usb_init") 
    create_makefile('usb')
    ```

4. Run the following: ARCHFLAGS="-arch i386" ruby extconf.rb
5. make
6. make install (might need rvmsudo)
7. Should be working.

The API should work fine as long as your missile launcher is plugged in. You can use multiple launchers at the same time, though telling them apart might be tricky.
