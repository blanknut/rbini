# W&W 32K RAMBOX Initialization ROM

This is my attempt to re-initialize a corrupted W&W 32K RAMBOX. If you are not
familiar with this device, this project is most probably not for you.
If you are looking for re-initializing a W&W HP-41CY, please have a look at my
related project
[HP-41CY Initialization ROM](https://github.com/blanknut/rb2ini)

Please note:

*THIS SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, FOR EDUCATIONAL
AND NON-COMMERCIAL USE ONLY. USE IT AT YOUR OWN RISK.*

Furthermore, I can only provide limited support as I have a
life besides HP calculators :-)

## Project Organization
If you want to build the ROM image by yourself, please note that the build
process is based on my
[MCODE project setup](https://github.com/blanknut/mcode-project-osx)
for macOS. I don't want to repeat the details here.

Unless you don't intend to change the sources, you can just use the ROM images
in subfolder `./rom`.

## Usage

### Prerequisites
For the re-initialization process you'll need a
[CLONIX module](http://www.clonix41.org/)
and an appropriate programmer.

### CLONIX Configuration
Program a CLONIX module using the following configuration:

| Page | Content                             |
| ---- | ----------------------------------- |
| #4   | rbini.rom                           |
| #8   | Any 4K ROM, e.g., Math              |
| #9   | 32K RAMBOX O/S                      |

### Re-initialization Procedure
Prepare your RAMBOX for re-initialization:
* Configure the default mapping for the first two RAM pages on your 32K RAMBOX:
  Set DIP switches A1-A4 to ON/OFF/OFF/OFF (maps first RAM page to page 8) and
  A5-A8 to ON/OFF/OFF/ON (maps second RAM page to page 9).
* Disable write protection for all RAM pages:
  Set DIP switches B1-B8 to ON.

Prepare your HP-41 calculator for re-initialization:
* Turn it off.
* Remove all modules.
* Insert the CLONIX module into any port (except port 4 of course).
* Connect your 32K RAMBOX.

Before continuing please note that the whole RAMBOX will be cleared!
However, this shouldn't be a problem if your RAMBOX is really corrupted.

Now it's time to turn on your HP-41 calculator. The re-initialization program
starts automatically and shows the following progress:

> &#50883;9ABCDEF&#10033;8

If not, then:
* your 32K RAMBOX might be in a state which is not properly handled by this
  re-initialization module (sorry), or
* there is a hardware problem (ouch).

At the end of a successful re-initialization process, the calculator powers
off automatically. Remove the CLONIX module and write protect RAM page 8, i.e.,
set DIP switch B1 to OFF. This page contains the RAMBOX O/S and you most probably
do not want to overwrite it.

If you encounter any issues please drop me a note. Maybe it helps to improve
this module. Of course, any comments or suggestions are welcome.

## Implementation Notes
The re-initialization of a 32K RAMBOX is straight forward because no bank switching
is involved as with the RAMBOX2/41CY. We just need to clear all the RAM pages and
copy the 32K RAMBOX O/S to page 8.

## References
I guess you already know the following web sites:
* [The HP-41 Archive](http://hp41.org/) web site contains _a lot_ of interesting
  information about the HP-41 calculator.
* If you have any questions about HP calculators have a look at the forum on
  [The Museum of HP Calculators](http://hpmuseum.org/). There are many friendly
  HP calculator enthusiasts that are willing to share their knowledge and
  experience.
* The [CLONIX](http://www.clonix41.org) module is one of the best add-ons you can
  buy for your Series 41 calculator and worth every penny.


