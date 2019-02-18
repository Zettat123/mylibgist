#!/usr/bin/perl


($ENV{LIBGISTHOME}) || die "runtests: must set LIBGISTHOME \n";

$ENV{PATH} = "$ENV{LIBGISTHOME}/src/cmdline:" . $ENV{PATH};

$names = "SR-tree_point";
$extns = "sr_point_ext";
$loads = "2d_pt_bulk";
$sorts = "2d_pt_bulk";

$loadonly = 0; # false
$bulkload = 1; # true
$nodiff = 0; #false
$noinsert = 0; #false

$pref = $extns;
$pref =~ s/_ext//;

  # insertion loaded ...

$tbl = $pref."tbl";
$out = $pref.".out";
$std = $pref.".std";

  # bulk loaded ...
  
$btbl = $tbl.".bulk";
$bout = $out.".bulk";
$bstd = $std.".bulk";

  # query file
  
$qry = $pref.".qry";

print "\t Testing insertion loading ... \n";

open(GISTCMD, "| gistcmdline -s > $out ") 
      || die "\t Error in running gistcmdline.";

print GISTCMD "set echo 0 \n"
      || die "\t Error turning off echo.";

print GISTCMD "create $tbl $extns\n" 
      || die "\t Error creating $tbl.";

open(LOADFILE, $loads) 
      || die "\t Error opening $loads.";

while (<LOADFILE>) {
  s/^/insert $tbl /;
  print GISTCMD $_ || die "\t Error: $_.";
}

print GISTCMD "check $tbl \n"
      || die "\t Error checking $tbl.";
  
print GISTCMD "quit \n"
      || die "\t Error quitting.";

close(GISTCMD);
close(LOADFILE);

print "\t Running queries ... \n";

open(GISTCMD, "| gistcmdline -s > $out ") 
    || die "\t Error in running gistcmdline.";

print GISTCMD "open $tbl \n"
    || die "\t Error opening $tbl.";

print GISTCMD "check $tbl \n" 
    || die "\t Error checking $tbl.";

open(QRYFILE, $qry) 
    || die "\t Error opening $loads.";

while (<QRYFILE>) {
  s/_TBLNAME_/$tbl/;
  print GISTCMD $_ || die "\t Error: $_.";
}

print GISTCMD "check $tbl \n"
    || die "\t Error checking $tbl.";
  
print GISTCMD "quit \n"
    || die "\t Error quitting.";

close(GISTCMD);
close(QRYFILE);

print "\t Checking answers ... \n";
      
open(ANSWER, $out) || die "Couldn't open $out.";
open(STANDARD, $std) || die "Couldn't open $std";
@answers = <ANSWER>;
@standard = <STANDARD>;
@answers = sort(@answers);
@standard = sort(@standard);
      
$j = @answers; $k = @standard;
($j == $k) || die "\t Answers don't match lengths:: $j != $k. \n";
for ($j = 0; $j < @answers; $j++) {
  ($answers[$j] eq $standard[$j]) 
	  || die "\t Answers don't match:: $answers[$j] :: $standard[$j]. \n";
}

close(ANSWER);
close(STANDARD);

(unlink $tbl) || die "Couldn't delete table.";
