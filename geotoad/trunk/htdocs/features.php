<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>GeoToad Features</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" href="/style-blue.css?2003080901" type="text/css" />
<link rel="stylesheet" href="/hacks.css?2003092601" type="text/css" />
</head>
<body>
<? include("../../header.inc"); ?>
<? include("header.inc"); ?>
<div class="hacktext">
        <div class="hackpagetitle">GeoToad Features</div>
        <h4>Query Types</h4>
   <p>     We allow you to query based 
          on most all the information available in a geocache:</p>
      
      <ul>
        <li> 
          zipcode, 
            state, coordinates
        </li>
        <li>distance from zipcode or coordinates</li>
        <li>filter by difficulty minimum/maximum</li>
        <li>filter by terrain minimum/maximum</li>
        <li>keyword search (not just 
          the title!)</li>
        <li>filter out caches that have or have not  
          been completed by certain people (usually yourself)</li>
        <li>filter by whether or not 
          a cache has ever been found</li>
	<li>filter by the date the cache was placed</li>
	<li>filter by the date the cache was last found</li>
        <li>filter by travelbug</li>
      </ul>
      <h4>Devices</h4>
<p>      Through our various file format 
        support, we allow you to upload your query output to a wide array of devices:
</p>
      <ul>
	<li>Any GPS Unit</li>
        <li><a href="http://www.palm.com/">Palm PDA's</a> via <a
href="http://www.smittyware.com/palm/cachemate/">CacheMate</a> or other tools.
</li>
        <li><a href="http://www.microsoft.com/mobile/pocketpc/default.asp">PocketPC</a></li>
        <li><a href="http://www.apple.com/ipod/">Apple 
          iPod</a></li>
        <li>Cellphone's, such as the 
          <a href="http://www.sonyericsson.com/P800/">Sony-Ericsson P800</a>.</li>
      </ul>
<p>      You may want to checkout the 
        <a href="screenshots.php">screenshots</a> section to see how the output 
        looks like on various devices. </p>
      <h4>Output Formats (Native):</h4>
      <ul>
        <li>GPX XML - for GPS units via <a href="http://www.easygps.com/">EasyGPS</a> or <a href="http://gpsbabel.sourceforge.net/">gpsbabel</a></li>
        <li>web page (HTML) - for portable devices or a web browser</li>
        <li>plain text</li>
        <li>csv - for spreadsheet imports</li>
        <li>gpspoint - <a href="http://gpspoint.dnsalias.net/gpspoint1/">gpspoint</a> 
          datafile</li>
        <li>vcf - contact format, for 
          use with <a href="http://www.apple.com/ipod/">iPod</a>'s, PDA's or cellphones</li>
        <li>easygps - legacy format for EasyGPS</li>
	<li>Tabbed output - for GPS Connect</li>
      </ul>
      <h4>Output Formats through gpsbabel:</h4>
<p>      If you have <a href="http://gpsbabel.sourceforge.net/">gpsbabel</a> 
        installed on your machine, and in the local path, we can make use of many 
        more formats: </p>
      <ul>
        <li>Cetus for PalmOS </li>
        <li>Navitrak DNA marker </li>
        <li>GpsDrive </li>
        <li>GPSman datafile </li>
        <li>GPSPilot for PalmOS </li>
        <li>gpsutil </li>
        <li>Holux gm-100 </li>
        <li> Magellan NAV Companion 
          for PalmOS </li>
        <li>Magellan MapSend software 
          </li>
        <li>MapTech Exchange </li>
        <li>OziExplorer </li>
        <li>Garmin PCX5 </li>
        <li>Microsoft PocketStreets 
          2002 Pushpin </li>
        <li> U.S. Census Bureau Tiger 
          Mapping Service Data </li>
        <li> TopoMapPro Places </li>
        <li>National Geographic Topo 
          </li>
        <li>Delorme Topo USA4/XMap Conduit 
          </li>
      </ul>
      <h4>Output Formats through cmconvert:</h4>
<p>      If you have <a href="http://www.smittyware.com/linux/">cmconvert</a> 
        installed on your machine, and in the local path, we can export data
to CacheMate .pdb format for your Palm Pilot.
</p>

      <h4>Other Cool Stuff</h4>
<P>      GeoToad uses a new P2P webpage caching system named shadowfetch. This 
        makes it so that people who use GeoToad actually share their results with 
        other users. This, along with time delays, helps the fine folks at <a href="http://www.geocaching.com/">Geocaching.com</a> 
        keep their bandwidth costs down and their CPU cycles lower.</p>
</div>

<? include("footer.inc"); ?>
</html>
