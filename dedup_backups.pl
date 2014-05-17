#!/usr/bin/perl

use strict;
use FindBin qw($Bin);

sub cmd {
  my @cmd = @_;
  my $rv = system(@cmd);
  if ($rv != 0) {
    print STDERR "WARNING cmd: ".join(' ', @cmd)." RV: $rv\n";
  }
}

sub merge {
  my @files = @_;
  my $filea = shift @files;
  my $inodea; (undef,$inodea) = stat($filea);

  while ($#files > -1) {
    my $fileb = pop @files;
    my $inodeb; (undef,$inodeb) = stat($fileb);
    next if $inodea == $inodeb;

    print "merge $filea $fileb inode($inodea != $inodeb)\n";

    # copy fileb attributes to tmp file
    cmd("cp", "--attributes-only", "--archive", $fileb, ".tmpfileattribs");

    # hard link filea to fileb
    cmd("cp", "-f", "-l", $filea, $fileb);

    # restore fileb attribs from tmp file
    # bug in cp - truncates file
    # cmd("cp", "--attributes-only", "--archive", ".tmpfileattribs", $fileb);
    cmd("chown","--reference=.tmpfileattribs",$fileb);
    cmd("chmod","--reference=.tmpfileattribs",$fileb);
    cmd("touch","--reference=.tmpfileattribs",$fileb);
  }
  unlink(".tmpfileattribs");
}

sub dedup {
  my ($dir) = @_;
  $dir = '.' if $dir eq '';
  my @dups = `fdupes -q -r $dir`;
  my @files;
  foreach my $line (@dups) {
    chomp $line;
    if ($line ne '') {
      push @files, $line;
    } else {
      merge(@files);
      @files = ();
    }
  }
  merge(@files) if $#files > -1;
}

sub main {
  chdir "$Bin/BACKUPS";
  dedup(); 
}
main() unless caller;

