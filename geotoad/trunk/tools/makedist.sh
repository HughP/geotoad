#!/bin/sh
# Builds a new release of geotoad
# $Id: makedist.sh,v 1.3 2002/04/23 04:05:41 helix Exp $

cd ..
VERSION=`cat VERSION`

DIST="geotoad-$VERSION"
LONGDIST="$DIST"
rm -Rf /tmp/$DIST
mkdir /tmp/$DIST
cp -R TODO.txt COPYRIGHT.txt geocache /tmp/$DIST
sed s/"%VERSION%"/"$VERSION"/g CLI/geotoad.rb > /tmp/$DIST/geotoad.rb
sed s/"%VERSION%"/"$VERSION"/g CLI/README.txt > /tmp/$DIST/README.txt
chmod 755 /tmp/$DIST/*.rb
rm /tmp/$DIST/**/*~ 2>/dev/null
rm /tmp/$DIST/*/._* 2>/dev/null
rm -Rf /tmp/$DIST/**/CVS 2>/dev/null
rm -Rf /tmp/$DIST/**/.svn 2>/dev/null

svn log -v > /tmp/$DIST/ChangeLog.txt

cd /tmp
tar -zcvf $LONGDIST.tgz $DIST
scp $LONGDIST.tgz home.toadstool.sh:/www/toadstool.sh/htdocs/hacks/geotoad/files/
echo "http://home.toadstool.sh/hacks/geotoad/files/$LONGDIST.tgz"

