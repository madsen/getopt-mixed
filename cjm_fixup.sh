#!/bin/sh
chmod a+w -R $1
perl /util/bin/vernum.pl -pd3 $1 lib/Getopt/Mixed.pm README
gnufind $1 -type f -exec flip -uv \{\} \;
chmod a-w -R $1
