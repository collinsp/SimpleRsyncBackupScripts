#!/usr/bin/perl

use strict;
use FindBin qw($Bin);

chdir $Bin;
my @lines = `du -h --max-depth=2 BACKUPS`;
@lines = sort map { /^(\S+)\s+(.*)$/; "$2\t$1" } @lines;
print join("\n", @lines)."

# to delete a backup set:
rm -rf BACKUPS/backupname/20140517134528

";
