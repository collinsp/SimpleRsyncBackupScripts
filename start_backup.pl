#!/usr/bin/perl

use strict;
use FindBin qw($Bin);

sub now {
  my @x = localtime; $x[5]+=1900; $x[4]+=1;
  return sprintf("%04d%02d%02d%02d%02d%02d",$x[5],$x[4],$x[3],$x[2],$x[1],$x[0]);
}
sub LOG {
  print STDERR now().' '.join(' ', @_)."\n";
}
mkdir "$Bin/BACKUPS/" unless -d "$Bin/BACKUPS/";

my $dt = now();

print STDERR "\n\n";

my %CONFIG;

open my $fh, "< $Bin/config";
if (! $fh) {
  print "config does not exist";
  exit(-1);
}
while (<$fh>) {
  chomp;
  next unless /\w/ || /^\s*\#/;
  my $rsync_cmd = $_;
  my $site;
  if ($rsync_cmd =~ s/\s*(\w+)\s*\:\s*//) {
    $site = $1;
  }
  if ($site eq '') {
    print "could not find site in $rsync_cmd\n";
    next;
  }
  $rsync_cmd .= " current";

  mkdir "$Bin/BACKUPS/$site" unless -d "$Bin/BACKUPS/$site";
  chdir "$Bin/BACKUPS/$site";
  LOG("started backup for", $site, $dt);
  my $rv = system($rsync_cmd);
  if ($rv != 0) {
    LOG("ERROR: rsync command: $rsync_cmd failed with rv = $rv");
  } else {
    system("cp", "-al", 'current', $dt);
  }
}
LOG('done');
