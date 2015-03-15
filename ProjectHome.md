# Latest version: 3.22.3 - see CurrentVersion #

# News: Download now via Google Drive #
  * See links. Download links for previous releases are also available from the "releases.json" file.

# Breaking News: GeoToad 3.21.x broken by 2014-10-14 site update, use 3.22 instead #
  * GC site update changed the location of user preferences (which are necessary for unambiguous parsing of dates)
  * _**GeoToad 3.22.0 is supposed to fix this.**_. (Release date: 2014-10-17.)

# Breaking News: No uploads to Google Code "Downloads" possible anymore #
  * There had been rumours long ago that Downloads would be deprecated - this seems to have happened now. Please download from SVN `branches/downloads/files` (2014-03-25)

# Breaking News: GeoToad 3.19.x broken by 2014-01-14 site update #
  * GC site update (to be exact, "Web.HotFix\_20140113.2") changed the internal representation of a few fields that are parsed by GeoToad, resulting in trailing whitespace (including a CR/LF combo) in the "cache owner" string.
  * _**GeoToad 3.20.0 fixes this.**_. (Release date: 2014-01-16.)


# Important News #
  * Watch the CurrentVersion wiki page for news about releases!


---


# What is it? #

GeoToad is a tool for serious <a href='http://www.geocaching.com'>geocachers</a>. It lets you make advanced queries to find the perfect caches to hit on your day out, and export them to any imaginable format. Here is what it can do:

  * On-demand queries for geocaches based on 15 different constraints: query type, distance, difficulty, terrain, fun factor, size, type, unfound, trackables, cache age, last found date, title, description, found by, cache creator.
  * Outputs cache listing and details to HTML, GPX, CSV, VCF, Text, Ozi, MXF, Tiger, GPSPoint, etc.
  * Integrated with <a href='http://www.gpsbabel.org/'>GPSBabel</a> to output to  <a href='http://earth.google.com/'>Google Earth</a> (KML), and dozens of other formats.
  * Optional automatic waypoint names like "`TheBookOfMozilla`" instead of "`GCABE4`"
  * Runs on Windows, Mac OS X, Linux, and other UNIX flavors!
  * It's Opensource!

GeoToad has been around since 2002, and is written using the <a href='http://www.ruby-lang.org/'>Ruby Programming Language</a>. We're looking for new people to join in and help develop, debug, and maintain the code. Patches welcome!

# Screenshot (of an older version) #
![http://geotoad.googlecode.com/files/geotoad-3.14.1-Mac.png](http://geotoad.googlecode.com/files/geotoad-3.14.1-Mac.png)