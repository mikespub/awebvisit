#!/usr/local/bin/perl
#
# --> adapt according to your own path to perl5. Do NOT use option -w !
#
# Do not change the following line
$helpmsg = <<'EOF';
###########################################################################
#
# NAME
#
#	aWebVisit Version 0.1.6c, 08/01/2002
#
# AUTHOR
#
#	Copyright (C) 1999-2002, Michel Dalle (awebvisit@mikespub.net)
#
# DISTRIBUTION AND LICENSE
#
#	http://mikespub.net/tools/aWebVisit/
#
#	This program is free software; you can redistribute it and/or
#	modify it under the terms of the GNU General Public License
#	as published by the Free Software Foundation; either version 2
#	of the License, or (at your option) any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program; if not, write to the Free Software
#	Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307,
#	USA.
#
# PURPOSE
#
#	Reads the Web server logfile(s) and extracts visitor information
#	like :
#		- the most commonly used ENTRY, TRANSIT, EXIT and HIT & RUN
#		  pages of your website
#		- the most frequently followed INCOMING, INTERNAL, OUTGOING
#		  and IN & OUT links of your website
#		- the average DURATION of each visit
#		- the average number of PAGES viewed PER VISIT
#		- the average TIME SPENT on each page
#		- the path of the LONGEST VISIT (in time and/or hits)
#		- ...
#
#	The visitor information is stored in HTML pages in a directory
#	of your choice (see configuration below).
#
#	A companion program called aWebVisit-Map allows you to click on a
#	page and follow all the links to and from that page (CGI).
#
# REMARKS AND LIMITATIONS
#
#	This script does not intend to provide "standard" web statistics like
#	the number of hits per day, the status codes, the distribution per
#	domain, etc. There are more than enough programs available for that !
#
#	The script accepts logfiles in the Common Log Format (CLF) or NCSA
#	Combined format. Other formats can be used if you modify the
#	appropriate fields in the script below.
#
#	Images (URLs of type .gif or .jpg) are normally ignored, except as
#	being part of an on-going visit. URLs with anchor points
#	(http://...#..) are treated as separate pages, but URLs with
#	parameters (http://...?..) are treated as a single page.
#
#	This script is not useful for sites having only a few "hits" per
#	day, since there must be a sufficient number of visits to extract
#	significant statistics. You might as well directly read the logfile.
#
#	It is also not intended for sites having millions of hits per day
#	or millions of pages on their website(s), since reading the logfiles
#	and generating the statistics can take some time (e.g. for a logfile
#	of 65 MB, aWebVisit takes about 11 minutes on a PC). There may be some
#	more professional packages supporting this type of websites.
#
#	Note that clients behind proxy servers cannot be differentiated based
#	on a web server logfile (unless you use authentication). This is not
#	a bad limitation if the number of log entries is sufficiently large.
#
#	You can change all this in the script below (and send me a mail).
#
# EXAMPLES OF USE
#
#	awebvisit logfile
#	perl awebvisit logfile
#	awebvisit logfile.*Jan*
#	grep that_client logfile | awebvisit
#
# HISTORY
#
#	0.1.6c 08/01/2002 Now available under GNU GPL license
#
#	0.1.6b 18/02/99	Minor bug fix for exclude_visit and include_visit
#
#	0.1.6 17/02/99	+Companion program aWebVisit-Map to travel through the
#			 pages and see the links to and from each page (CGI) !
#			+Modified contents of statistics file for aWebVisit-Map
#			+Configurable removal and/or replacement of some parts
#			 of URLs (parameters, anchor points, long paths, ...)
#			+Configurable exclusion/inclusion of visit entry-points
#			 (e.g. robots should start with '/robots.txt')
#			+Configurable exclusion/inclusion of hosts (networks,
#			 domains, ...)
#			+Configurable exclusion/inclusion of URLs
#
#	0.1.5 07/02/99	+Create graphical maps of entries, exits and transits
#			+Support visits that cross midnight (assuming days
#			 follow each other without gaps in the logfiles)
#			+Review table outputs
#			+Drastically reduce memory requirements for big files
#
#	0.1.4 31/01/99	+Separate links into incoming, internal, outgoing and
#			 in&out links
#			+Add status information
#			+Add 1st level flow map
#			+Rewrite statistics code
#			+First try at entry and exit trees
#
#	0.1.3 24/01/99	+Separate hit & runs from entry and exit points
#			+Add transit points
#			+Add rank percentages
#
#	0.1.2 23/01/99	+Add least used entry and exit points
#			+Streamline table outputs
#			+Add some explanations
#
#	0.1.1 20/01/99	Generate HTML output
#
#	0.1.0 18/01/99	First public version
#
# FUTURE
#
#	This is probably as far as it goes, unless you send your suggestions
#	and wishes to (awebvisit@mikespub.net)...
#
#	E.g. take into account status code changes during a visit.
#
###########################################################################
EOF
# Do not change the previous line
#
# CONFIGURATION FOR aWebVisit
#
# The configuration is divided into 5 sections :
#
#	1. Global Settings
#	2. Layout Definition
#	3. Logfile Analysis
#	4. Data Export
#	5. Web Map Configuration
#
# Hint:	you can start by checking 1.a., 5.a. and 5.b. now, and then try
#	changing the other ones later on.
#	Option 3.a. is an interesting one too : it determines which URL types
#	to exclude or include (images, RealAudio, style-sheets, java, ...).
#

#==========================================================================
#
# 1. Global Settings
#
#==========================================================================

#=======
# 1.a.	Output directory for the aWebVisit reports
#	- change this to a directory containing your HTML documents, or some
#	specific sub-directory.
#=======

$outdir = ".";
#$outdir = "../docs";
#$outdir = "../docs/awv";

#=======
# 1.b.	Output filenames
#	The script generates output files with the following names :
#	<name>f.html <name>i.html <name>s.html <name>1.html <name>2.html...
#	- change this if these names already appear in the output directory.
#=======

$name = "awebvisit";
#$name = "awv_";

# Hint:	if you intend to place the aWebVisit reports in a separate directory,
#	copy <name>f.html to index.html (or whatever your default page is)
#	after running awebvisit. That makes it easier to get to the reports
#	from your browser... (on Unix, you could also create a soft link)

#=======
# 1.c.	Visit timeout (in seconds)
#	- change this if you want to allow a different "sleeping time"
#	(Some people use 30 minutes, others use 5 minutes)
#=======

$timeout = 450;
#$timeout = 600;

#==========================================================================
#
# 2. Layout Definition
#
#==========================================================================

#=======
# 2.a.	HTML Background Color
#	- change this to your favorite background color
#=======

$bgcolor = "#FFEEDD";
#$bgcolor = "#A0E0FF";

#=======
# 2.b.	Background Color for highlighted columns in tables
#	- change this to your favorite highlight color
#=======

$highcolor = "#CCFFCC";
#$highcolor = "#FFEEDD";

#=======
# 2.c.	Display Top N pages only
#	- change this if you want to see more pages in each table
#=======

$toppages = 20;
#$toppages = 30;

#=======
# 2.d.	Display Top N links only
#	- change this if you want to see more links in each table
#=======

$toplinks = 100;
#$toplinks = 120;

#==========================================================================
#
# 3. Logfile Analysis
#
#==========================================================================

#//////////////////////////////////////////////////////////////////////////
# Introduction to regular expressions (used for pattern matching below)
#
# '|' means a logical OR.
# '(' and ')' can enclose different OR choices
# '^' means the start of the string (URL, host, ...)
# '$' means the end of the string (URL, host, ...)
# '\' is used before any character that is not alphanumeric : '\.', '\/', '\?'
#//////////////////////////////////////////////////////////////////////////

#=======
# 3.a.	Exclude 'images' / include 'pages', i.e. URLs matching the following
#	pattern
#	- change this if you want to exclude other URLs (e.g. java, testpages)
#
#	NOTE : this replaces variable '$exclude' of aWebVisit 0.1.5 !!
#=======

$exclude_url = '\.(gif|jpg)$';
#$exclude_url = '';

# Example - exclude .gif, .jpg, .css and .js pages, and all URLs starting with
# /test or located under /stats/awv/
#
#$exclude_url = '\.(gif|jpg|css|js)$|^\/(test|stats\/awv\/)';

# Or:	If you only want to INCLUDE certain URLs, leave the $exclude_url blank
#	and use the $include_url below :

$include_url = '';
#$include_url = '\.(htm|html)$';

#=======
# 3.b.	Exclude/include visits from specific hosts, e.g. from your own system
#	- leave blank if you don't want to exclude any hosts
#=======

$exclude_host = '';

# Example - remove host 127.0.0.1, all hosts from network 150.93.* and from
# domain *.abc.com (this only works if your logfile contains domain names) :
#
#$exclude_host = '^127\.0\.0\.1$|^150\.93\.|\.abc\.com$';

# Hint:	it is actually faster to remove all undesired hosts from the logfiles
#	BEFORE aWebVisit analyses them. On Unix, use something like :
#	grep -v "exclude_me.com" <logfile(s)> | awebvisit

# Or:	if you only want to INCLUDE certain hosts, leave the $exclude_host
#	blank and use the $include_host below :

$include_host = '';
#$include_host = '^150\.93\.|\.abc\.com$';

# Hint:	it is actually faster to select all desired hosts from the logfiles
#	BEFORE aWebVisit analyses them. On Unix, use something like :
#	grep "include_me.com" <logfile(s)> | awebvisit

#=======
# 3.c.	Exclude/include visits with an entry point that matches this pattern
#	Typically used for excluding visits from 'clean' robots, i.e.
#	those starting with asking for '/robots.txt'.
#	- leave blank if you don't mind including robot visits, or replace
#	if you want to exclude visits starting at a certain page...
#=======

$exclude_visit = '^\/robots.txt$';
#$exclude_visit = '';

# Or:	if you only want to INCLUDE certain entry points, leave the
#	$exclude_visit blank and use the $include_visit below :

$include_visit = '';
#$include_visit = '^\/spanish\/index.html$';

#=======
# 3.d.	Remove whatever matches the following pattern from each URL
#	- change this if you want to exclude anchor points, include some
#	CGI parameters, remove some irrelevant parts from long URLs, ...
#=======

# this removes all parameters from URLs (http://...?.. --> http://...)
$remove_from_url = '\?.*$';
#$remove_from_url = '';

# Example : remove anchor points, remove all CGI parameters except for the
# first one (before the first '&'), or remove '/a_long/useless/path' from
# each URL (whatever matches first is done, the rest is ignored !)
#
#$remove_from_url = '#.*$|&.*$|\/a_long\/useless\/path';

#=======
# 3.e.	Replace whatever matches the first pattern with the second one
#	for each URL - typically used to replace '.../' with '.../index.html'
#	(or whatever your default page is)
#	- leave blank if no replacements are required
#=======


%replace_url = (
#format:'replace' 	=> 'with',
#	'\/$'		=> '\/index.html',
#	'^\/this_very_long_dir\/'	=> '\/that\/',
);

# Hint:	don't try to replace too many URLs, since this may take some time...
#	It may be better to replace the URLs in the logfiles BEFORE aWebVisit
#	analyses them.

#==========================================================================
#
# 4. Data Export
#
#==========================================================================

#=======
# 4.a.	Export data to file (in delimited format) - leave blank otherwise
#	- save the data of all URLs and links in delimited format
#=======

$csvfile = $name . ".data";
#$csvfile = '';

#=======
# 4.b.	Export statistics to file - leave blank otherwise
#	- save the aWebVisit statistics for aWebVisit-Map
#=======

$statfile = $name . ".stat";
#$statfile = '';

# Hint:	make sure aWebVisit-Map uses the same statistics file !

#=======
# 4.c.	Delimiter for data and statistics file - usually a tab is safest
#	- change if your analysing tool and/or DB cannot use this deliminer
#=======

$delim = "\t";
#$delim = "|";

# Hint:	make sure aWebVisit-Map uses the same delimiter !

#==========================================================================
#
# 5. Web Map Configuration
#
#==========================================================================

#=======
# 5.a.	Location of the FLY program for graphics - leave blank if not there
#	You can get pre-compiled binaries for Windows 95 & NT, various UNIXes,
#	and other platforms at http://www.unimelb.edu.au/fly/
#=======

$flyprog = '';
#$flyprog = '/usr/local/bin/fly';
#$flyprog = 'd:\\perl\\fly-1.6.0\\fly.exe';

#=======
# 5.b.	Exact URL of the aWebVisit-Map CGI - leave blank if not installed
#	(but you should !)
#=======

$cgiprog = '';
#$cgiprog = '/cgi-bin/awv-map.cgi';

#=======
# 5.c.	Number of entry pages to be shown in the web maps
#	- better try it out before changing this
#=======

$topentries = 7;
#$topentries = 10;

#=======
# 5.d.	Number of transit pages to be shown in the web maps
#	- better try it out before changing this
#=======

$toptransits = 12;
#$toptransits = 15;

#=======
# 5.e.	Number of exit pages to be shown in the web maps
#	- better try it out before changing this
#=======

$topexits = 7;
#$topexits = 10;

#
# END OF CONFIGURATION FOR aWebVisit
#
###########################################################################

# Do not change anything below this line unless you have taken a back-up...

###########################################################################
#
# Check whether aWebVisit can work with the current configuration
#

if ($ENV{'REQUEST_METHOD'} ne "") {
	print STDOUT "Content-type: text/html\n\n";
	print STDOUT "<HTML><HEAD><TITLE>aWebVisit Warning</TITLE></HEAD>\n";
	print STDOUT "<BODY BGCOLOR=\"$bgcolor\">\n";
	print STDOUT "<H1>aWebVisit Warning</H1>\n";
	print STDOUT "This program is NOT meant to be used as a CGI script !<P>\n";
	print STDOUT "Run this program from a command line first, and then call 'awv-map.cgi' from your browser\n";
	print STDOUT "to walk through your webpages and analyse the links to and from each page...<P>\n";
	print STDOUT "</BODY></HTML>\n";
	exit;
}

if (defined($outdir) && $outdir ne "") {
	if (!-d $outdir) {
		die "The output directory '$outdir' does not exist !\nCheck the '\$outdir' variable in the aWebVisit configuration.\n";
	}
}
else {
	die "Please specify an output directory '\$outdir' for aWebVisit.\nUsing the root directory is not allowed...\n";
}

foreach $type ("t","f","i","s","c","h","e") {
	$file{$type} = $outdir . "/" . $name . $type . ".html";
	$ref{$type} = $name . $type . ".html";
}

for ($type = 1; $type <= 26; $type++) {
	$file{$type} = $outdir . "/" . $name . $type . ".html";
	$ref{$type} = $name . $type . ".html";
}

open(FILE,">$file{'t'}") || die "aWebVisit can't create output files in directory '$outdir' !\nMake sure the directory exists and has the appropriate access rights...";
print FILE $$;
close(FILE);

if (defined($flyprog) && $flyprog ne "") {
	&init_maps(0);
}
elsif (!defined($flyprog)) {
	$flyprog = "";
}

if (!defined($cgiprog)) {
	$cgiprog = "";
}

sub _make_rule {
	my($toreplace,$key,$val);

	$toreplace = "";
	while (($key,$val) = each %replace_url) {
		$toreplace .= "\$url =~ s/$key/$val/;\n";
	}
	$replace_func = eval " sub { $toreplace } ";
	die "\nThe replacement rule for URLs is incorrect :\n$toreplace\nCheck the \%replace_url variable in your configuration...\n" if $@;
}

_make_rule();

$doreplace = keys %replace_url;

###########################################################################
#
# Read the logfile entries
#

# Usual format of the logfile :
#
# myhost - - [20/Jan/1999:21:42:52 +0100] "GET / HTTP/1.0" 200 1486
#    0   1 2           3              4     5  6    7       8    9 ...
#
# Additional fields like referrer, user-agent, cookie etc. are ignored
#
# If you use logfiles of another format (e.g. IIS), you can change the
# regular expression in the loop below...

print STDERR "Reading logfile entries...\n";
$timestart = time;

$entries = 0;
$line = 1;
$session = 0;
$skip = 0;
#$sep = ' ';
$sep = '\s+';
$curdate = "";
$day = -1;
$oldsec = 0;
while (<>) {
	chomp;
	if (/^$/ || /^format=/i) {
		next;
	}
	$entries++;
	if ($entries % 5000 == 0) {
		print STDERR "Line $entries\n";
	}

	unless (($host,$date,$hour,$min,$sec,$url,$status) = /^(\S+)$sep\S+$sep\S+$sep\[([^:]+):(\d+):(\d+):(\d+).*\]$sep\"\S+$sep(\S+)$sep\S+\"$sep(\S+)$sep\S+/o ) {
		$skipentry = $_;
		$skip++;
		next;
	}

	if ($exclude_host && $host =~ /$exclude_host/io) {
		$sumhost++;
		next;
	}
	elsif ($include_host && $host !~ /$include_host/io) {
		$sumhost++;
		next;
	}

	if ($remove_from_url) {
		$url =~ s/$remove_from_url//o;
	}

	if ($doreplace > 0) {
		&{$replace_func};
	}

	$totstatus{$status}++;
	if ($status ne "200" && $status ne "304") {
		$toterr{"$status $url"}++;
	}

	if (!defined($startdate)) {
		$startdate = "$date:$hour:$min:$sec";
	}

	if ($curdate ne $date) {
		$day++;
		$curdate = $date;
	}

	$newsec = ((($day * 24) + $hour) * 60 + $min) * 60 + $sec;

# house-cleaning...
	if ($newsec > $oldsec + 1.5 * $timeout) {
		while (($key,$val) = each %lasttime) {
			if ($newsec > $val + $timeout) {
				&check_session($lastsession{$key});
			}
		}
		$oldsec = $newsec;
	}

	if (!defined($lasttime{$host}) || $newsec > $lasttime{$host} + $timeout) {
		if (defined($lastsession{$host})) {
			&check_session($lastsession{$host});
		}
		$sessionkey = "$host $date:$hour:$min:$sec";
		$sessionval{$sessionkey} = "";
		$lastsession{$host} = $sessionkey;
		$cursession = $sessionkey;
		$session++;
	}
	else {
		$cursession = $lastsession{$host};
	}

	if ($exclude_url && $url =~ /$exclude_url/io) {
		$sumimage++;
	}
	elsif ($include_url && $url !~ /$include_url/io) {
		$sumimage++;
	}
	else {
		$sessionval{$cursession} .= "$newsec $status $url\n";
		$pageurl{$url}++;
	}

	$lasttime{$host} = $newsec;

	$line++;
}
$enddate = "$date:$hour:$min:$sec";
$line--;

undef %lasttime;
undef %lastsession;

foreach $sessionkey (keys %sessionval) {
	&check_session($sessionkey);
}

undef %sessionval;

$timestop = time;
print STDERR "--> ", $timestop - $timestart, "\n";

###########################################################################
#
# Routine for extracting visit information from sessions
#

sub check_session {
	my($sessionkey) = @_;
	my($time1,$status1,$url1);
	my($time2,$status2,$url2);
	my($time0,$host,$date);

	@sessionlist = split(/\n/,$sessionval{$sessionkey});
	($time1,$status1,$url1) = split(' ',$sessionlist[0]);
	if ($time1 eq "") {
		$sumnull++;
		delete $sessionval{$sessionkey};
		($host,$date) = split(/ /,$sessionkey);
		delete $lasttime{$host};
		delete $lastsession{$host};
		return;
	}
	if ($exclude_visit && $url1 =~ /$exclude_visit/io) {
		$sumrobot++;
		delete $sessionval{$sessionkey};
		($host,$date) = split(/ /,$sessionkey);
		delete $lasttime{$host};
		delete $lastsession{$host};
		return;
	}
	elsif ($include_visit && $url1 !~ /$include_visit/io) {
		$sumrobot++;
		delete $sessionval{$sessionkey};
		($host,$date) = split(/ /,$sessionkey);
		delete $lasttime{$host};
		delete $lastsession{$host};
		return;
	}
	if ($#sessionlist == 0) {
		$hitrunurl{$url1}++;
	}
	else {
		$time0 = $time1;
		$entryurl{$url1}++;
		($time2,$status2,$url2) = split(' ',$sessionlist[1]);
		$totlink{"$url1 $url2"}++;
		$timediff = $time2 - $time1;
		$timeval{$url1} += $timediff;
		$timeurl{$url1}++;
		if ($#sessionlist == 1) {
			$inoutlink{"$url1 $url2"}++;
		}
		else {
			$inlink{"$url1 $url2"}++;
			$time1 = $time2;
			$status1 = $status2;
			$url1 = $url2;
			for ($j = 2; $j < $#sessionlist; $j++) {
				($time2,$status2,$url2) = split(' ',$sessionlist[$j]);
				$key = "$url1 $url2";
				$totlink{$key}++;
				$internlink{$key}++;
				$timediff = $time2 - $time1;
				$timeval{$url1} += $timediff;
				$timeurl{$url1}++;
				$transiturl{$url1}++;
				$time1 = $time2;
				$status1 = $status2;
				$url1 = $url2;
			}
			($time2,$status2,$url2) = split(' ',$sessionlist[$#sessionlist]);
			$key = "$url1 $url2";
			$totlink{$key}++;
			$outlink{$key}++;
			$timediff = $time2 - $time1;
			$timeval{$url1} += $timediff;
			$timeurl{$url1}++;
			$transiturl{$url1}++;
		}
		$exiturl{$url2}++;

		$duration = $time2 - $time0;
		if (!defined($minduration) || $minduration > $duration) {
			$minduration = $duration;
		}
		if (!defined($maxduration) || $maxduration < $duration) {
			$maxduration = $duration;
			$maxdurationkey = $sessionkey;
			$maxdurationval = $sessionval{$sessionkey};
		}
		$sumduration += $duration;
		$durationcount++;
	}

	$numsteps = $#sessionlist + 1;
	if (!defined($minstep) || $minstep > $numsteps) {
		$minstep = $numsteps;
	}
	if (!defined($maxstep) || $maxstep < $numsteps) {
		$maxstep = $numsteps;
		$maxstepkey = $sessionkey;
		$maxstepval = $sessionval{$sessionkey};
	}
	$sumstep += $numsteps;
	$stepcount++;

	delete $sessionval{$sessionkey};
	($host,$date) = split(/ /,$sessionkey);
	delete $lasttime{$host};
	delete $lastsession{$host};
}

###########################################################################
#
# Check whether aWebVisit has something to work on
#

print STDERR "Read $entries entries from $startdate to $enddate\n";
if ($skip == 1) {
	print STDERR "\nWarning : $skip entry was skipped because it had the wrong format :\n$skipentry\n\n";
}
elsif ($skip > 1) {
	print STDERR "\nWarning : $skip entries were skipped because they had the wrong format. Example :\n$skipentry\n\n";
}

if ($line == 0) {
	print STDERR "\nNo valid logfile entries were recognised...\n";
	print STDERR "Make sure the logfile is in Common Logfile Format or Extended Logfile Format.\n";
	print STDERR "If not, you can adapt aWebVisit to your own logfile format (and send me a copy).\n";
	exit;
}


print STDERR "Extracting page and link information for $session sessions...\n";
$timestart = time;

if ($stepcount > 0) {
	$avgstep = sprintf("%.1f",$sumstep / $stepcount);
}
else {
	$avgstep = sprintf("%.1f",0);
	$minstep = "-";
	$maxstep = "-";
	$maxstepkey = "";
	$maxstepval = "";
}

if ($durationcount > 0) {
	$avgduration = sprintf("%.1f",$sumduration / $durationcount);
}
else {
	$avgduration = sprintf("%.1f",0);
	$minduration = "-";
	$maxduration = "-";
	$maxdurationkey = "";
	$maxdurationval = "";
}

$timestop = time;
#print STDERR "--> ", $timestop - $timestart, "\n";

print STDERR "Found $stepcount sessions containing at least one page\n";

###########################################################################
#
# Routine for generating page and link statistics, including top N series
#

sub getstats {
	my($h_ref,$lt_ref,$lb_ref,$nr) = @_;
	my($key,$val);
	my($count,$sum,$avg,$min,$max,$maxkey);
	my(@tmplist);
	my($i,$j,$k);
	my($pct_of_count,$pct_of_sum,$pct_of_max);
	my($topcount,$topsum);

	$count = 0;
	$sum = 0;
	@$lt_ref = ();
	@$lb_ref = ();
	@tmplist = ();
	while (($key, $val) = each %$h_ref) {
		if (!defined($min) || $min > $val) {
			$min = $val;
		}
		if (!defined($max) || $max < $val) {
			$max = $val;
			$maxkey = $key;
		}
		$sum += $val;
		if ($count < $nr) {
			push(@tmplist, $key);
			if ($count == $nr - 1) {
				foreach $key (sort {$$h_ref{$b} <=> $$h_ref{$a}} @tmplist) {
					push(@$lt_ref,$key);
				}
				foreach $key (sort {$$h_ref{$a} <=> $$h_ref{$b}} @tmplist) {
					push(@$lb_ref,$key);
				}
				undef @tmplist;
				$k = $#{$lt_ref};
			}
			$count++;
			next;
		}
		if ($val < $$h_ref{$$lt_ref[$k]}) {
		}
		elsif ($val > $$h_ref{$$lt_ref[0]}) {
			pop(@$lt_ref);
			unshift(@$lt_ref,$key);
		}
		else {
			for ($i = 1; $i < $k; $i++) {
				if ($val > $$h_ref{$$lt_ref[$i]}) {
					last;
				}
			}
			splice(@$lt_ref,$i,0,$key);
			pop(@$lt_ref);
		}
		if ($val > $$h_ref{$$lb_ref[$k]}) {
		}
		elsif ($val < $$h_ref{$$lb_ref[0]}) {
			pop(@$lb_ref);
			unshift(@$lb_ref,$key);
		}
		else {
			for ($i = 1; $i < $k; $i++) {
				if ($val < $$h_ref{$$lb_ref[$i]}) {
					last;
				}
			}
			splice(@$lb_ref,$i,0,$key);
			pop(@$lb_ref);
		}
		$count++;
	}
	if ($count > 0) {
		$avg = sprintf("%.1f",$sum / $count);
		if ($count < $nr) {
			foreach $key (sort {$$h_ref{$b} <=> $$h_ref{$a}} @tmplist) {
				push(@$lt_ref,$key);
			}
			foreach $key (sort {$$h_ref{$a} <=> $$h_ref{$b}} @tmplist) {
				push(@$lb_ref,$key);
			}
			undef @tmplist;
		}
		$pct_of_count = sprintf("%.1f", $ref_count > 0 ? $count / $ref_count * 100.0 : 100.0);
		$pct_of_sum = sprintf("%.1f", $ref_sum > 0 ? $sum / $ref_sum * 100.0 : 100.0);
		$pct_of_max = sprintf("%.1f", $max / $sum * 100.0);
		$topsum = 0;
		foreach $key (@$lt_ref) {
			$topsum += $$h_ref{$key};
		}
		$topcount = $#{$lt_ref} + 1;
		$topcount = $count > 0 ? sprintf("%.1f", $topcount / $count * 100.0) : "-";
		$topsum = $sum > 0 ? sprintf("%.1f", $topsum / $sum * 100.0) : "-";
	}
	else {
		$avg = "-";
		$min = "-";
		$max = "-";
		$maxkey = "";
		$pct_of_count = "-";
		$pct_of_sum = "-";
		$pct_of_max = "-";
		$topcount = "-";
		$topsum = "-";
	}
	return($count,$sum,$avg,$min,$max,$maxkey,$pct_of_count,$pct_of_sum,$pct_of_max,$topcount,$topsum);
}

###########################################################################
#
# Get page statistics
#

print STDERR "Calculating page statistics...\n";
$timestart = time;

# 0 : number of different (entry/...) pages
# 1 : number of hits on (entry/...) pages
# 2 : average number of hits per (entry/...) page
# 3 : minimum number of hits for one (entry/...) page
# 4 : maximum number of hits for one (entry/...) page
# 5 : URL of (entry/...) page with maximum number of hits

# 6 : % of all pages are (entry/...) pages
# 7 : (entry/...) pages get % of all hits
# 8 : max (entry/...) page gets % of all hits on (entry/...) pages

# 9 : top N (entry/...) pages represent % of all (entry/...) pages
# 10 : hits on top N (entry/...) pages account for % of all hits on (entry/...) pages

$ref_count = 0;
$ref_sum = 0;
@pagestat = &getstats(\%pageurl,\@pagetop,\@pagebot,$toppages);
$ref_count = $pagestat[0];
$ref_sum = $pagestat[1];

@entrystat = &getstats(\%entryurl,\@entrytop,\@entrybot,$toppages);
@transitstat = &getstats(\%transiturl,\@transittop,\@transitbot,$toppages);
@exitstat = &getstats(\%exiturl,\@exittop,\@exitbot,$toppages);
@hitrunstat = &getstats(\%hitrunurl,\@hitruntop,\@hitrunbot,$toppages);

$timestop = time;
#print STDERR "--> ", $timestop - $timestart, "\n";

###########################################################################
#
# Get time statistics
#

#
# 1. Walk through timeval once to get the sum, and then modify the timeval...
#

print STDERR "Calculating time statistics...\n";
$timestart = time;

$sumtime = 0;
$sumtimeval = 0;
$timevalcount = 0;
while (($key,$value) = each %timeval) {
	$sumtimeval += $value;
	$sumtime += $timeurl{$key};
	$timeval{$key} = sprintf("%.1f",$value / $timeurl{$key});
	$timevalcount++;
}
if ($sumtime > 0) {
	$avgtimeval = sprintf("%.1f",$sumtimeval / $sumtime);
}
else {
	$avgtimeval = "-";
}
if ($timevalcount > 0) {
	$avgtime = sprintf("%.1f",$sumtime / $timevalcount);
}
else {
	$avgtime = "-";
}

#
# 2. Find min, max, maxkey and make top (the rest is irrelevant after modifying timeval)
#

@timestat = &getstats(\%timeval,\@timetop,\@timebot,$toppages);

$timestat[0] = $timevalcount;
$timestat[1] = $sumtime; # total number of hits, NOT total time spent !
$timestat[2] = $avgtimeval; # NOT avg number of hits, but avg time spent !

$timestat[10] = 0;
foreach $key (@timetop) {
	$timestat[10] += $timeurl{$key}; # NOT timeval !
}
$timestat[9] = $#timetop + 1;

$timestat[9] = $timestat[0] > 0 ? sprintf("%.1f", $timestat[9] / $timestat[0] * 100.0) : "-";
$timestat[10] = $timestat[1] > 0 ? sprintf("%.1f", $timestat[10] / $timestat[1] * 100.0) : "-";

$timestop = time;
#print STDERR "--> ", $timestop - $timestart, "\n";

###########################################################################
#
# Get link statistics
#

print STDERR "Calculating link statistics...\n";
$timestart = time;

# 0 : number of different (incoming/...) links
# 1 : number of hits on (incoming/...) links
# 2 : average number of hits per (incoming/...) link
# 3 : minimum number of hits for one (incoming/...) link
# 4 : maximum number of hits for one (incoming/...) link
# 5 : From/To URLs of (incoming/...) link with maximum number of hits

# 6 : % of all links are (incoming/...) links
# 7 : (incoming/...) links get % of all hits
# 8 : max (incoming/...) link gets % of all hits on (incoming/...) links

# 9 : top N (incoming/...) links represent % of all (incoming/...) links
# 10 : hits on top N (incoming/...) links account for % of all hits on (incoming/...) links

$ref_count = 0;
$ref_sum = 0;
@linkstat = &getstats(\%totlink,\@linktop,\@linkbot,$toplinks);
$ref_count = $linkstat[0];
$ref_sum = $linkstat[1];

@instat = &getstats(\%inlink,\@intop,\@inbot,$toplinks);
@internstat = &getstats(\%internlink,\@interntop,\@internbot,$toplinks);
@outstat = &getstats(\%outlink,\@outtop,\@outbot,$toplinks);
@inoutstat = &getstats(\%inoutlink,\@inouttop,\@inoutbot,$toplinks);

# 11 : From URL
# 12 : To URL

push( @linkstat, split(' ',$linkstat[5]) );
push( @instat, split(' ',$instat[5]) );
push( @internstat, split(' ',$internstat[5]) );
push( @outstat, split(' ',$outstat[5]) );
push( @inoutstat, split(' ',$inoutstat[5]) );

$timestop = time;
#print STDERR "--> ", $timestop - $timestart, "\n";

###########################################################################
#
# Routines for creating the output files
#

#
# Some page layout routines
#

sub open_page {
	my($type,$title) = @_;

	print STDERR "$type ";
	open(FILE,">$file{$type}") || die "Can't create output file of type $type : '$file{$type}'...";
	select(FILE);$|=1;select(STDOUT);

	print FILE "<HTML>\n";
	print FILE "<HEAD>\n";
	print FILE "<TITLE>\n";
	print FILE "	aWebVisit - $title (from $startdate to $enddate)\n";
	print FILE "</TITLE>\n";
	print FILE "</HEAD>\n";
}

sub close_page {
	print FILE "</HTML>\n";
	close(FILE);
}

#
# Some body layout routines
#

sub open_body {
	my($type,$title) = @_;

	&open_page($type,$title);

	print FILE "<BODY BGCOLOR=\"$bgcolor\">\n";
	if ($type eq "i") {
		$navigbar = 0;
	}
	elsif ($type eq "s") {
		print FILE "<A NAME=\"top\"></A>\n";
		$navigbar = 1;
	}
	else {
		print FILE "<A NAME=\"top\"></A>\n";
		$navigbar = 2;
	}
	print FILE "	<H1>aWebVisit - $title</H1>\n";
	print FILE "(from $startdate to $enddate)<HR>\n";
	if ($navigbar == 2) {
		print FILE "<A HREF=\"$ref{'s'}\">Back to Summary</A><P>\n";
	}
}

sub close_body {
	if ($navigbar == 2) {
		print FILE "<BR><A HREF=\"$ref{'s'}\">Back to Summary</A> - <A HREF=\"#top\">Back to top</A>\n";
	}
	elsif ($navigbar == 1) {
		print FILE "<BR><A HREF=\"#top\">Back to top</A>\n";
	}
	print FILE "<HR>Created with <A HREF=\"http://mikespub.net/tools/aWebVisit/\" TARGET=\"_top\">aWebVisit 0.1.6</A> on $timestamp\n";
	print FILE "</BODY>\n";

	&close_page();
}

#
# Some table layout routines
#

sub open_table {
	my(@tdef) = @_;
	my(@data,$i);

	for $i (0 .. $#{$tdef[0]}) {
		$tdef[0][$i] = "" 	if !defined($tdef[0][$i]);
		$tdef[1][$i] = "left" 	if !defined($tdef[1][$i]);
		$tdef[2][$i] = 0 	if !defined($tdef[2][$i]);
	}

	@th = ();
	@tr = ();
	@tf = ();
	$i = 0;
# header : ... - center - center - ... - left
	if ($tdef[1][$i] ne "left") {
		$th[$i] = "<TR>\n\t<TH ALIGN=\"center\"";
	}
	else {
		$th[$i] = "<TR>\n\t<TH ALIGN=\"$tdef[1][$i]\"";
	}
	$th[$i] .= " BGCOLOR=\"$highcolor\">";
	$tr[$i] = "<TR>\n\t<TD ALIGN=\"$tdef[1][$i]\"";
	$tr[$i] .= $tdef[2][$i] ? " BGCOLOR=\"$highcolor\">" : ">";
	$tf[$i] = "<TR>\n\t<TD ALIGN=\"$tdef[1][$i]\"";
	$tf[$i] .= " BGCOLOR=\"$highcolor\"><B>";
	for $i (1 .. $#{$tdef[0]}) {
		if ($i < $#{$tdef[0]} && $tdef[1][$i] ne "left") {
			$th[$i] = "</TH>\n\t<TH ALIGN=\"center\"";
		}
		else {
			$th[$i] = "</TH>\n\t<TH ALIGN=\"left\"";
		}
		$th[$i] .= " BGCOLOR=\"$highcolor\">";
		$tr[$i] = "</TD>\n\t<TD ALIGN=\"$tdef[1][$i]\"";
		$tr[$i] .= $tdef[2][$i] ? " BGCOLOR=\"$highcolor\">" : ">";
		$tf[$i] = "</B></TD>\n\t<TD ALIGN=\"$tdef[1][$i]\"";
		$tf[$i] .= " BGCOLOR=\"$highcolor\"><B>";
	}
	$i = $#{$tdef[0]} + 1;
	$th[$i] = "</TH>\n</TR>\n";
	$tr[$i] = "</TD>\n</TR>\n";
	$tf[$i] = "</B></TD>\n</TR>\n";

	print FILE "<TABLE BORDER=\"1\" CELLPADDING=\"5\" CELLSPACING=\"0\">\n";

	if (defined($tdef[0][0]) && length($tdef[0][0]) > 0) {
		&print_th(@{$tdef[0]});
	}
}

sub close_table {
	print FILE "</TABLE><P>\n";
}

sub print_th {
	my(@tdata) = @_;

	&print_trow(\@th,\@tdata);
}

sub print_tr {
	my(@tdata) = @_;

	&print_trow(\@tr,\@tdata);
}

sub print_tf {
	my(@tdata) = @_;

	&print_trow(\@tf,\@tdata);
}

sub print_trow {
	my($type,$data) = @_;
	my(@tline,$i);

	@tline = ( $$type[0] );
	for $i (0 .. $#{$data}) {
		push( @tline , $$data[$i] ne "" ? $$data[$i] : "&nbsp;" , $$type[$i+1] );
	}
	print FILE @tline;
}

sub make_table {
	my(@table) = @_;
	my(@def,@row,$i,$j);

	@def = ();
	for $i (0 .. 2) {
		push( @def, [ @{$table[$i]} ] );
	}

	&open_table(@def);

	for $i (3 .. $#table - 1) {
		&print_tr( @{$table[$i]} );
	}
	if ($table[$#table][0] ne "") {
		&print_tf( @{$table[$#table]} );
	}

	&close_table();
}

#
# Some formatting routines
#

sub time2hms {
	my($time) = @_;
	my($day,$hour,$min,$sec);

	$day = int($time / 60 / 60 / 24);
	$time -= $day * 60 * 60 * 24;
	$hour = int($time / 60 / 60);
	$time -= $hour * 60 * 60;
	$min = int($time / 60);
	$time -= $min * 60;
	$sec = $time;
	$time = sprintf("%2.2d:%2.2d:%2.2d",$hour,$min,$sec);
	$time;
}

# not used - ugly
sub commas {
	my($val) = @_;

	1 while $val =~ s/(.*\d)(\d\d\d)/$1,$2/;
	$val;
}

#
# Some page statistics routines
#

sub open_tpage {
	my($col) = @_;
	my(@def,@data,$i);

	@def = (
		[ "Hit<BR>Count", "Entry<BR>Page", "Transit<BR>Page", "Exit<BR>Page", "Hit&amp;Run<BR>Page", "Time<BR>(sec)", "Rank<BR>(%)", "Page" 	],
		[ "right"	, "right"	, "right"	, "right"	, "right"		, "right"	, "right"	, "left"	],
		[ 0		, 0		, 0		, 0		, 0			, 0		, 1		, 0		],
	);

	$def[2][$col] = 1;

	&open_table(@def);

	@data = ( $pagestat[0], $entrystat[0], $transitstat[0], $exitstat[0], $hitrunstat[0], $timestat[0], "-", "Number of Pages" );
	&print_tr(@data);
	@data = ( $pagestat[2], $entrystat[2], $transitstat[2], $exitstat[2], $hitrunstat[2], $timestat[2], "-", "Average Hits per Page" );
	&print_tr(@data);
	@data = ( $pagestat[1], $entrystat[1], $transitstat[1], $exitstat[1], $hitrunstat[1], $timestat[1], "100.0", "Total Hit Count" );
	&print_tf(@data);
}

sub print_tpage {
	my($rank,$url) = @_;
	my(@data);

	@data = (
		$pageurl{$url},
		defined($entryurl{$url})   ? $entryurl{$url}   : "-",
		defined($transiturl{$url}) ? $transiturl{$url} : "-",
		defined($exiturl{$url})    ? $exiturl{$url}    : "-",
		defined($hitrunurl{$url})  ? $hitrunurl{$url}  : "-",
		defined($timeval{$url})  ? $timeval{$url}  : "-",
		$rank,
		"<A HREF=\"$url\">$url</A>",
	);

	&print_tr(@data);
}

sub close_tpage {
	my($count) = @_;
	my(@data);

	if ($count > 0) {
		@data = ( $pagestat[1], $entrystat[1], $transitstat[1], $exitstat[1], $hitrunstat[1], $timestat[1], "100.0", "Total Hit Count" );
		&print_tf(@data);
	}

	&close_table();
}

# page (col = 0) -> no stats compared to total
# time (col = 5) -> slightly different layout
sub make_tpage {
	my($type,$title,$descr,$col,$list_ref,$stat_ref,$url_ref) = @_;
	my($page,@curtotal);

	&open_body($type,$title);
	if ($$stat_ref[0] == 0) {
		print FILE "There are no <B>$descr</B> on your website !\n";
	}
	elsif ($$stat_ref[0] > $toppages) {
		print FILE "The following $toppages pages are the <B>$descr</B> on your website.\n";
		print FILE "They account for <B>$$stat_ref[10] %</B> of all page hits of this type,\n";
		print FILE "and represent $$stat_ref[9] % of all pages of this type.\n";
	}
	else {
		print FILE "The following $$stat_ref[0] pages are the <B>$descr</B> on your website.\n";
		print FILE "There are no other pages of this type.\n";
	}
	if ($col == 5) {
		print FILE "<P>Note that time statistics are only available for entry and transit pages. So if a page is usually an exit point, its time information may be unreliable...\n";
	}
	print FILE "<P>\n";

	&open_tpage($col);

	for $i (0 .. 5) {
		$curtotal[$i] = 0;
	}
	foreach $page (@$list_ref) {
		$nr = $col != 5 ? sprintf("%.1f", $$url_ref{$page} / $$stat_ref[1] * 100.0) : "-";
		&print_tpage($nr,$page);
		$curtotal[0] += $pageurl{$page};
		$curtotal[1] += $entryurl{$page};
		$curtotal[2] += $transiturl{$page};
		$curtotal[3] += $exiturl{$page};
		$curtotal[4] += $hitrunurl{$page};
		$curtotal[5] += $timeurl{$page}; # not timeval !
	}
	if ($$stat_ref[1] > 0) {
		push( @curtotal, sprintf("%.1f", $curtotal[$col] / $$stat_ref[1] * 100.0));
		push( @curtotal, "Current Hit Count");
		&print_tr(@curtotal);
	}

	&close_tpage($$stat_ref[0]);

	&close_body();
}

#
# Some link statistics routines
#

sub open_tlink {
	my($col) = @_;
	my(@def,@data);

	@def = (
		[ "Link<BR>Count","Incoming<BR>Link","Internal<BR>Link","Outgoing<BR>Link","In&amp;Out<BR>Link","Rank<BR>(%)","From Page","To Page"	],
		[ "right"	, "right"	, "right"	, "right"		, "right"	, "right"	, "left"	, "left"	],
		[ "0"		, "0"		, "0"		, "0"			, "0"		, "1"		, "0"		, "0"		],
	);

	$def[2][$col] = 1;

	&open_table(@def);

	@data = ( $linkstat[0], $instat[0], $internstat[0], $outstat[0], $inoutstat[0], "-", "Number of Links", "" );
	&print_tr(@data);
	@data = ( $linkstat[2], $instat[2], $internstat[2], $outstat[2], $inoutstat[2], "-", "Average Hits per Link", "" );
	&print_tr(@data);
	@data = ( $linkstat[1], $instat[1], $internstat[1], $outstat[1], $inoutstat[1], "100.0", "Total Hit Count", "" );
	&print_tf(@data);
}

sub print_tlink {
	my($rank,$link) = @_;
	my($from,$to,@data);

	($from,$to)=split(' ',$link);
	@data = (
		$totlink{$link},
		defined($inlink{$link})     ? $inlink{$link}     : "-",
		defined($internlink{$link}) ? $internlink{$link} : "-",
		defined($outlink{$link})    ? $outlink{$link}    : "-",
		defined($inoutlink{$link})  ? $inoutlink{$link}  : "-",
		$rank,
		"<A HREF=\"$from\">$from</A>",
		"<A HREF=\"$to\">$to</A>",
	);

	&print_tr(@data);
}

sub close_tlink {
	my($count) = @_;
	my(@data);

	if ($count > 0) {
		@data = ( $linkstat[1], $instat[1], $internstat[1], $outstat[1], $inoutstat[1], "100.0", "Total Hit Count", "" );
		&print_tf(@data);
	}

	&close_table();
}

# link (col = 0) -> no stats compared to total
sub make_tlink {
	my($type,$title,$descr,$col,$list_ref,$stat_ref,$link_ref) = @_;
	my($link,@curtotal);

	&open_body($type,$title);
	if ($$stat_ref[0] == 0) {
		print FILE "There are no <B>$descr</B> on your website !\n";
	}
	elsif ($$stat_ref[0] > $toplinks) {
		print FILE "The following $toplinks links are the <B>$descr</B> on your website.\n";
		print FILE "They account for <B>$$stat_ref[10] %</B> of all link hits of this type,\n";
		print FILE "and represent $$stat_ref[9] % of all links of this type.\n";
	}
	else {
		print FILE "The following $$stat_ref[0] links are the <B>$descr</B> on your website.\n";
		print FILE "There are no other links of this type.\n";
	}
	print FILE "<P>\n";

	for $i (0 .. 4) {
		$curtotal[$i] = 0;
	}
	&open_tlink($col);
	foreach $link (@$list_ref) {
		$nr = sprintf("%.1f", $$link_ref{$link} / $$stat_ref[1] * 100.0);
		&print_tlink($nr,$link);
		$curtotal[0] += $totlink{$link};
		$curtotal[1] += $inlink{$link};
		$curtotal[2] += $internlink{$link};
		$curtotal[3] += $outlink{$link};
		$curtotal[4] += $inoutlink{$link};
	}
	if ($$stat_ref[1] > 0) {
		push( @curtotal, sprintf("%.1f", $curtotal[$col] / $$stat_ref[1] * 100.0));
		push( @curtotal, "Current Hit Count", "");
		&print_tr(@curtotal);
	}
	&close_tlink($$stat_ref[0]);

	&close_body();
}

#
# Some visit statistics routines
#

sub open_lvisit {
	my($status);

	print FILE "<PRE>\n";
	print FILE "Unusual status codes are marked in <B>bold</B>.\nAs a reminder, here is their meaning :\n\n";
	print FILE "Status\tDescription\n";
	for $status (sort keys %totstatus) {
		if ($status ne "200" && $status ne "304") {
			print FILE "<B>$status</B>\t$statcodes{$status}\n";
		}
		else {
			print FILE "$status\t$statcodes{$status}\n";
		}
	}
	print FILE "\nStep\tTime\t\tStatus\tPage\n";
}

sub print_lvisit {
	my($nr,$time,$status,$url) = @_;

	$nr = sprintf("%4.4d",$nr+1);
	$time = &time2hms($time);
	if ($status ne "200" && $status ne "304") {
		print FILE "$nr\t$time\t<B>$status</B>\t<A HREF=\"$url\">$url</A>\n";
	}
	else {
		print FILE "$nr\t$time\t$status\t<A HREF=\"$url\">$url</A>\n";
	}
}

sub close_lvisit {
	print FILE "</PRE><P>\n";
}

###########################################################################
#
# Create output files
#

print STDERR "Generating output files...\n";
$timestamp = localtime(time);

#
# Main Frame
#

&open_page("f","Reports");
print FILE "<FRAMESET FRAMEBORDER=\"1\" FRAMESPACING=\"0\" FRAMEPADDING=\"0\" COLS=\"26%,*\">\n";
#print FILE "	<FRAME SRC=\"$ref{i}\" NAME=\"awv_l\" SCROLLING=\"auto\">\n";
print FILE "	<FRAME SRC=\"$ref{'i'}\" NAME=\"awv_l\" SCROLLING=\"no\">\n";
print FILE "	<FRAME SRC=\"$ref{'s'}\" NAME=\"awv_r\" SCROLLING=\"auto\">\n";
print FILE "	<NOFRAMES>\n";
print FILE "		<BODY BGCOLOR=\"$bgcolor\">\n";
print FILE "		Warning, your browser does not support frames, but we need them !<P>\n";
print FILE "		Please upgrade your IT manager...";
print FILE "<HR>Created with <A HREF=\"http://mikespub.net/tools/aWebVisit/\" TARGET=\"_top\">aWebVisit 0.1.6</A> on $timestamp\n";
print FILE "		</BODY>\n";
print FILE "	</NOFRAMES>\n";
print FILE "</FRAMESET>\n";
&close_page();

#
# Index
#

&open_page("i","Reports");
print FILE "<BODY BGCOLOR=\"$bgcolor\">\n";
print FILE "	<B>aWebVisit Reports :</B><P>\n";

print FILE "<PRE>\n";
print FILE "- <A HREF=\"$ref{'s'}\" TARGET=\"awv_r\">Summary</A>\n";
if ($cgiprog ne "") {
	print FILE "- <A HREF=\"$cgiprog\" TARGET=\"_top\">Detailed Web Maps</A>\n";
}
elsif ($flyprog ne "") {
	print FILE "- <A HREF=\"$ref{'m'}\" TARGET=\"_top\">Global Web Maps</A>\n";
}
print FILE "\n";
print FILE "- Visited Pages :  <A HREF=\"$ref{2}\" TARGET=\"awv_r\">-</A> <A HREF=\"$ref{1}\" TARGET=\"awv_r\">+</A>\n";
print FILE "  1. Entry     (<A HREF=\"$ref{4}\" TARGET=\"awv_r\">-</A>) (<A HREF=\"$ref{3}\" TARGET=\"awv_r\">+</A>)\n";
print FILE "  2. Transit   (<A HREF=\"$ref{6}\" TARGET=\"awv_r\">-</A>) (<A HREF=\"$ref{5}\" TARGET=\"awv_r\">+</A>)\n";
print FILE "  3. Exit      (<A HREF=\"$ref{8}\" TARGET=\"awv_r\">-</A>) (<A HREF=\"$ref{7}\" TARGET=\"awv_r\">+</A>)\n";
print FILE "  4. Hit&amp;Run   (<A HREF=\"$ref{10}\" TARGET=\"awv_r\">-</A>) (<A HREF=\"$ref{9}\" TARGET=\"awv_r\">+</A>)\n";
print FILE "\n";
print FILE "- Followed Links : <A HREF=\"$ref{14}\" TARGET=\"awv_r\">-</A> <A HREF=\"$ref{13}\" TARGET=\"awv_r\">+</A>\n";
print FILE "  1. Incoming  (<A HREF=\"$ref{16}\" TARGET=\"awv_r\">-</A>) (<A HREF=\"$ref{15}\" TARGET=\"awv_r\">+</A>)\n";
print FILE "  2. Internal  (<A HREF=\"$ref{18}\" TARGET=\"awv_r\">-</A>) (<A HREF=\"$ref{17}\" TARGET=\"awv_r\">+</A>)\n";
print FILE "  3. Outgoing  (<A HREF=\"$ref{20}\" TARGET=\"awv_r\">-</A>) (<A HREF=\"$ref{19}\" TARGET=\"awv_r\">+</A>)\n";
print FILE "  4. In&amp;Out    (<A HREF=\"$ref{22}\" TARGET=\"awv_r\">-</A>) (<A HREF=\"$ref{21}\" TARGET=\"awv_r\">+</A>)\n";
print FILE "\n";
print FILE "- Time per Page :  <A HREF=\"$ref{12}\" TARGET=\"awv_r\">-</A> <A HREF=\"$ref{11}\" TARGET=\"awv_r\">+</A>\n";
print FILE "\n";
print FILE "- Longest Visit (<A HREF=\"$ref{23}\" TARGET=\"awv_r\">Hits</A>)\n";
print FILE "- Longest Visit (<A HREF=\"$ref{24}\" TARGET=\"awv_r\">Time</A>)\n";
print FILE "- <A HREF=\"$ref{'e'}\" TARGET=\"awv_r\">Status Codes</A>\n";
if ($flyprog eq "" && $cgiprog eq "") {
	print FILE "- Old <A HREF=\"$ref{25}\" TARGET=\"awv_r\">Entry</A> / <A HREF=\"$ref{26}\" TARGET=\"awv_r\">Exit</A> Trees\n";
}
print FILE "\n";
print FILE "- <A HREF=\"$ref{'c'}\" TARGET=\"awv_r\">Configuration</A>\n";
print FILE "- <A HREF=\"$ref{'h'}\" TARGET=\"awv_r\">Help</A>\n";
print FILE "</PRE>\n";

&close_body();

#
# Configuration
#

&open_body("c","Configuration");

$replace_str = "";
while (($key,$val) = each %replace_url) {
	$replace_str .= "'$key' => '$val'<BR>\n";
}

print FILE "<H2>Current configuration of aWebVisit</H2>\n";
@rows = (
	[ "Option"	, "Description"				, "Variable"		, "Value"	],
	[ "right"	, "left"				, "left"		, "left"	],
	[ 0		, 0					, 0			, 0		],
	[ "<B>1.</B>"	, "<B>Global Settings</B>"		, ""			, ""		],
	[ "1.a."	, "Output directory for the reports"	, '$outdir'		, "'$outdir'"	],
	[ "1.b."	, "Name of the output files<BR>(&lt;name&gt;*.html,&lt;name&gt;*.gif)"	, '$name'		, "'$name'"	],
	[ "1.c."	, "Visit timeout in seconds"		, '$timeout'		, $timeout	],
	[ ""		, ""					, ""			, ""		],
	[ "<B>2.</B>"	, "<B>Layout Definition</B>"		, ""			, ""		],
	[ "2.a."	, "Background color"			, '$bgcolor'		, $bgcolor	],
	[ "2.b."	, "Highlight color"			, '$highcolor'		, $highcolor	],
	[ "2.c."	, "Number of pages per table"		, '$toppages'		, $toppages	],
	[ "2.d."	, "Number of links per table"		, '$toplinks'		, $toplinks	],
	[ ""		, ""					, ""			, ""		],
	[ "<B>3.</B>"	, "<A NAME=\"img\"><B>Logfile Analysis</B></A>"		, ""			, ""		],
$exclude_url ne "" ?
	[ "3.a."	, "Exclusion pattern for 'images'"	, '$exclude_url'	, "'$exclude_url'"	]
:
($include_url ne "" ?
	[ "3.a."	, "Inclusion pattern for 'images'"	, '$include_url'	, "'$include_url'"	]
:
	[ "3.a."	, "Exclusion/inclusion pattern for 'images'"	, '$exclude_url<BR>$include_url'	, "none"	]
),
$exclude_host ne "" ?
	[ "3.b."	, "Exclusion pattern for hosts"		, '$exclude_host'	, "'$exclude_host'"	]
:
($include_host ne "" ?
	[ "3.b."	, "Inclusion pattern for hosts"		, '$include_host'	, "'$include_host'"	]
:
	[ "3.b."	, "Exclusion/inclusion pattern for hosts"	, '$exclude_host<BR>$include_host'	, "none"	]
),
$exclude_visit ne "" ?
	[ "3.c."	, "Exclusion pattern for visits (e.g. robots)"	, '$exclude_visit'	, "'$exclude_visit'"	]
:
($include_visit ne "" ?
	[ "3.c."	, "Inclusion pattern for visits (e.g. entry point)"	, '$include_visit'	, "'$include_visit'"	]
:
	[ "3.c."	, "Exclusion/inclusion pattern for visits"	, '$exclude_visit<BR>$include_visit'	, "none"	]
),
	[ "3.d."	, "Remove this pattern from each URL"	, '$remove_from_url'	, "'$remove_from_url'"	],
	[ "3.e."	, "Replace these patterns in each URL"	, '%replace_url'	, "$replace_str"	],
	[ ""		, ""					, ""			, ""		],
	[ "<B>4.</B>"	, "<B>Data Export</B>"			, ""			, ""		],
	[ "4.a."	, "Save data to this file"		, '$csvfile'		, $csvfile	],
	[ "4.b."	, "Save statistics to this file"	, '$statfile'		, $statfile	],
	[ "4.c."	, "Use this delimiter for the files"	, '$delim'		, "<PRE>'$delim'</PRE>"	],
	[ ""		, ""					, ""			, ""		],
	[ "<B>5.</B>"	, "<A NAME=\"fly\"><B>Web Map Configuration</B></A>", ""	, ""		],
	[ "5.a."	, "Location of the <I>fly</I> program"	, '$flyprog'		, "'$flyprog'"	],
	[ "5.b."	, "URL of the aWebVisit-Map CGI"	, '$cgiprog'		, "'$cgiprog'"	],
	[ "5.c."	, "Number of entry pages per web map"	, '$topentries'		, $topentries	],
	[ "5.d."	, "Number of transit pages per web map"	, '$toptransits'	, $toptransits	],
	[ "5.e."	, "Number of exit pages per web map"	, '$topexits'		, $topexits	],
	[ ""		, ""					, ""			, ""		],
);
&make_table(@rows);

print FILE "You can change the configuration directly in the aWebVisit script...<P>\n";

&close_body();

#
# Help
#

&open_body("h","Help");

print FILE "<H2>1. Pages, links and visits in aWebVisit</H2>\n";

print FILE "Webserver logfiles contain all <B>hits</B> to your webserver over a certain period of time.\n";
print FILE "aWebVisit assumes that all hits from the same host (within a certain timeout period) are part of the same <B>visit</B> (*).<P>\n";

print FILE "For each visit, aWebVisit then determines which page was hit first (<B>entry page</B>) and which page was hit last (<B>exit page</B>).\n";
print FILE "All other pages hit during a visit are called <B>transit pages</B>.\n";
print FILE "Since visitors may go back to the same page several times during a visit, a single webpage on your website may be counted once as an entry page,\n";
print FILE "several times as a transit page and/or once as an exit page.<BR>\n";
print FILE "A special case is where only one page is hit during a visit. That page is called a <B>hit&amp;run page</B>.<P>\n";

print FILE "During a visit, aWebVisit also analyses the path followed by the visitor from one page to the next.\n";
print FILE "Links followed from entry pages are called <B>incoming links</B>, while links going to an exit page are called <B>outgoing links</B>.\n";
print FILE "The other links followed during a visit are called <B>internal links</B>.<BR>\n";
print FILE "Again, a special case is where a visitor goes directly from an entry page to an exit page. That link is called an <B>In&amp;Out link</B>.<P>\n";

print FILE "The different types of visits distinguished by aWebVisit are shown in the table below :<P>\n";

if ($flyprog eq "") {
	@rows = (
		[ "Hits / Visit", "0"		, "1"			, "2"				, "3"			, "more"			],
		[ "left"	, "center"	, "center"		, "center"			, "center"		, "center"			],
		[ 1		, 0		, 0			, 0				, 0			, 0				],
		[ "Hit #1"	, "(images)"	, "Hit&amp;Run Page"	, "Entry Page"			, "Entry Page"		, "Entry Page"			],
		[ ""		, ""		, ""			, "<I>In&amp;Out Link</I>"	, "<I>Incoming Link</I>", "<I>Incoming Link</I>"	],
		[ "Hit #2"	, ""		, ""			, "Exit Page"			, "Transit Page"	, "Transit Page"		],
		[ "..."		, ""		, ""			, ""				,"<I>Outgoing Link</I>"	, "<I>Internal Link(s)</I>"	],
		[ "Hit #n-1"	, ""		, ""			, ""				, "Exit Page"		, "Transit Page"		],
		[ ""		, ""		, ""			, ""				, ""			, "<I>Outgoing Link</I>"	],
		[ "Hit #n"	, ""		, ""			, ""				, ""			, "Exit Page"			],
		[ ""		, ""		, ""			, ""				, ""			, ""				],
	);
	&make_table(@rows);
}
else {
	@nodes = (
		[ "Entry"	, 160	, 80	], # node 0
		[ "Transit"	, 260	, 180	], # node 1
		[ "Exit"	, 160	, 280	], # node 2
		[ "Hit&Run"	, 60	, 80	], # node 3
	);

	@links = (
		[""		, ""	, 0	, undef	, undef	, 2],
		["Incoming"	, 0	, 1	, undef	, undef	, 2],
		["Internal"	, 1	, 1	, undef	, undef	, 1],
		["Outgoing"	, 1	, 2	, undef	, undef	, 3],
		["In&Out"	, 0	, 2	, undef	, undef	, 4],
		[""		, 2	, ""	, undef	, undef	, 3],
		[""		, ""	, 3	, undef	, undef	, 7],
	);

	$imgwidth = 400;
	$imgheight = 360;

	&make_nodeimg("30",$imgwidth,$imgheight);
	&add_imgmap("30",$imgwidth,$imgheight);
}

print FILE "Image hits are discarded, as specified in the <A HREF=\"$ref{'c'}#img\">configuration</A>.<P>\n";

print FILE "(*) Note that this assumption may not be correct if clients hit your website from behind proxy servers... Then you'll need more data to\n";
print FILE "reveal the most common paths through your website, or expand aWebVisit to use other characteristics like cookies or session IDs.<P>\n";

print FILE "Have a look at the <A HREF=\"http://mikespub.net/tools/aWebVisit/\" TARGET=\"_top\">homepage of aWebVisit</A> for additional information...<P>\n";

print FILE "<A NAME=\"fly\"></A>\n";
print FILE "<H2>2. Using <I>fly</I> to create graphics with aWebVisit</H2>\n";
print FILE "A picture says more than a thousand words (or numbers).\n";
print FILE "Try the new <B>graphical webmaps</B> that aWebVisit can generate by downloading the <I>fly</I> program !\n";
print FILE "<P>It's really easy to set up (and it's for free) :<P>\n";
print FILE "<OL><LI>install the <A HREF=\"http://www.unimelb.edu.au/fly/\">right version of <I>fly</I></A> (Windows 95/NT, various UNIXes, ...), and\n";
print FILE "<LI><A HREF=\"$ref{'c'}#fly\">tell aWebVisit</A> where to find it.\n";
print FILE "</OL>You'll see the difference...<P>\n";
print FILE "Even better now is the companion program <A HREF=\"http://mikespub.net/tools/aWebVisit/\">aWebVisit-Map</A>.\n";
print FILE "It's a CGI that allows you to walk through your website and follow the links from one page to the next one...<P>\n";

print FILE "<H2>3. Terminology used in aWebVisit</H2>\n";

@rows = (
	[ "Term"	, "Description"	],
	[ "right"	, "left"	],
	[ 0		, 0		],
	[ "'image'"	, "Any URL that IS excluded by matching /$exclude_url/i. This can be changed in the configuration." ],
	[ "'page'"	, "Any URL that is NOT excluded by the script. URLs with anchor points (http://...#..) are treated as separate pages, but URLs with parameters (http://...?..) are not." ],
	[ "Hit Count"	, "Number of times this page is visited ('hit')" ],
	[ "Entry Page"	, "Number of times this page is used as an entry point to this website" ],
	[ "Exit Page"	, "Number of times this page is used as an exit point from this website" ],
	[ "Transit Page"	, "Number of times this page is part of an on-going visit rather than the entry or exit point of it" ],
	[ "Hit&amp;Run Page"	, "Number of times this page is the only one visited in a single session. This does not include any images that are excluded by the script." ],
	[ "Time (sec)"	, "Average time spent on this page (only for entry and transit pages). This includes download time, reading time, time spent viewing 'images' from this page, coffee breaks shorter than the timeout of $timeout seconds, etc. That's why aWebVisit needs a sufficiently large sample to work on..." ],
	[ "Rank (%)"	, "Rank in the Top (or Bottom) $toppages pages or $toplinks links. The number of entries can be changed in the configuration." ],
	[ "Page"	, "The URL of the page" ],
	[ "Link Count"	, "Number of times this link is followed on your website" ],
	[ "Incoming Link"	, "Number of times this link is followed from an entry page" ],
	[ "Internal Link"	, "Number of times this link is followed somewhere inside your website" ],
	[ "Outgoing Link"	, "Number of times this link is followed to an exit page" ],
	[ "In&amp;Out Link"	, "Number of times this link is followed from an entry page directly to an exit page" ],
	[ "From Page"	, "The starting page of the link" ],
	[ "To Page"	, "The destination page of the link" ],
	[ ""		, ""		 ],
);
&make_table(@rows);

print FILE "<H2>4. About aWebVisit</H2>\n";
print FILE "<PRE>\n";
print FILE $helpmsg;
print FILE "</PRE>\n";

&close_body();

#
# Summary
#

&open_body("s","Summary");

print FILE "<H2>1. Introduction</H2>\n";
print FILE "aWebVisit extracts visitor information from WWW logfiles. For each visit, your web <B>pages</B> are then classified as an <B>entry</B>, <B>transit</B>, <B>exit</B> and/or <B>hit&run</B> page.\n";
print FILE "The <I><B>links</B></I> followed during the visit to your website are classified as <I><B>incoming</B></I>, <I><B>internal</B></I>, <I><B>outgoing</B></I> and/or <I><B>in&out</B></I> links.\n";
print FILE "If you are not familiar with these concepts, you will find more detailed explanations in the <A HREF=\"$ref{'h'}\">Help</A> file.<P>\n";

print FILE "The <B>flow of visitors</B> through your website can be summarised as follows :<P>\n";

if ($flyprog eq "") {
	@rows = (
	[ ""		, ""		, ""		, ""		, ""		, ""		],
	[ "center"	, "center"	, "center"	, "center"	, "center"	, "center"	],
	[ 0		, 0		, 0		, 0		, 0		, 0		],
	[ "(excluded)<BR>$sumnull"	, "<A HREF=\"$ref{9}\"><B>Hit&amp;Run</B></A><BR>$hitrunstat[1]"	, "<A HREF=\"$ref{3}\"><B>Entry</B></A><BR>$entrystat[1]"	, ""	, ""	, ""	],
	[ ""	, ""	, "."	, "<A HREF=\"$ref{15}\"><I>Incoming</I></A><BR>$instat[1]"	, ""	, ""	],
	[ ""	, ""	, "<A HREF=\"$ref{21}\"><I>In&amp;Out</I></A><BR>$inoutstat[1]"	, ""	, "<A HREF=\"$ref{5}\"><B>Transit</B></A><BR>$transitstat[1]"	, "<A HREF=\"$ref{17}\"><I>Internal</I></A><BR>$internstat[1]"	],
	[ ""	, ""	, "."	, "<A HREF=\"$ref{19}\"><I>Outgoing</I></A><BR>$outstat[1]"	, ""	, ""	],
	[ ""	, ""	, "<A HREF=\"$ref{7}\"><B>Exit</B></A><BR>$exitstat[1]"	, ""	, ""	, ""	],
	[ ""		, ""		, ""		, ""		, ""		, ""		],
	);

	&make_table(@rows);
	print FILE "Try using the <A HREF=\"$ref{'h'}#fly\"><I>fly</I> program</A> to create <B>graphical webmaps</B> with aWebVisit !\n";
	print FILE "<BR>Some limited <A HREF=\"$ref{25}\">entry</A> and <A HREF=\"$ref{26}\">exit</A> trees are available.\n";
}
else {
	@nodes = (
		[ "Entry"	, 160	, 80	, $ref{3}	], # node 0
		[ "Transit"	, 260	, 180	, $ref{5}	], # node 1
		[ "Exit"	, 160	, 280	, $ref{7}	], # node 2
		[ "Hit&Run"	, 60	, 80	, $ref{9}	], # node 3
	);

	@links = (
		[$entrystat[1]	, ""	, 0	, undef		, undef		, 2],
		[$instat[1]	, 0	, 1	, $ref{15}	, "Incoming"	, 2],
		[$internstat[1]	, 1	, 1	, $ref{17}	, "Internal"	, 1],
		[$outstat[1]	, 1	, 2	, $ref{19}	, "Outgoing"	, 3],
		[$inoutstat[1]	, 0	, 2	, $ref{21}	, "In&Out"	, 4],
		[$exitstat[1]	, 2	, ""	, undef		, undef		, 3],
		[$hitrunstat[1]	, ""	, 3	, undef		, undef		, 7],
	);

	$imgwidth = 400;
	$imgheight = 360;

	&make_nodeimg("31",$imgwidth,$imgheight);
	&add_imgmap("31",$imgwidth,$imgheight);

	if ($cgiprog eq "") {
		print FILE "Some global <A HREF=\"$ref{'m'}\" TARGET=\"_top\">web maps</A> are available.\n";
		print FILE "Try using <A HREF=\"http://mikespub.net/tools/aWebVisit/\" TARGET=\"_top\">aWebVisit-Map</A> for individual page maps...\n";
	}
	else {
		print FILE "More detailed <A HREF=\"$cgiprog\" TARGET=\"_top\">web maps</A> are also available !\n";
	}
}

print FILE "<H2>2. Logfile Information</H2>\n";
@rows = (
	[ ""			, ""		],
	[ "left"		, "right"	],
	[ 0			, 0		],
	[ "Start date"		, $startdate	],
	[ "End date"		, $enddate	],
	[ "'Page' hits"		, $pagestat[1]	],
	[ "'Image' hits"	, $sumimage	],
	[ "Hits from excluded hosts"	, $sumhost	],
	[ "Skipped entries"	, $skip		],
	[ "Valid entries"	, $line		],
	[ ""			, ""		],
);
&make_table(@rows);

$nr = sprintf("%.1f",$pagestat[1] / $line * 100.0);
print FILE "The 'page' hits represent <B>$nr %</B> of all valid hits on your website.\n";
print FILE "The 'image' hits are excluded as specified in the current <A HREF=\"$ref{'c'}#img\">configuration</A> of aWebVisit.\n";
if ($nr > 80) {
	print FILE "You may want to exclude other types of pages (e.g. RealAudio, counters, ...) in a next run...\n";
}
elsif ($nr < 20) {
	print FILE "You may want to include some of the 'images' in a next run...\n";
}
else {
	print FILE "You do not need to include or exclude other types of pages for the moment...\n";
}
print FILE "<P>\n";

if ($line < 10000) {
	print FILE "This is probably not a large enough sample for statistical analysis. Please use logfiles covering a longer period of time...\n";
}
elsif ($line > 1000000) {
	print FILE "This is probably more than enough for statistical analysis ! You may want to use smaller logfiles in the future to speed up processing...\n";
}
else {
	print FILE "This is probably a good number for statistical analysis : enough samples to be useful, but small enough to be processed quickly...\n";
}
print FILE "<P>\n";

print FILE "<H2>3. Visit Information</H2>\n";
@rows = (
	[ "Visit Type"				, "Visit<BR>Count"	, "Visits<BR>(%)"					],
	[ "left"				, "right"		, "right"						],
	[ 0					, 0			, 1							],
	[ "Normal visits (> 2 hits)"		, $instat[1]		, sprintf("%.1f", $instat[1] / $session * 100.0)		],
	[ "In &amp; Out visits (2 hits)"	, $inoutstat[1]		, sprintf("%.1f", $inoutstat[1] / $session * 100.0)		],
	[ "Hit &amp; Run visits (1 hit)"	, $hitrunstat[1]		, sprintf("%.1f", $hitrunstat[1] / $session * 100.0)	],
	[ "Discarded visits (0 hits)"		, $sumnull		, sprintf("%.1f", $sumnull / $session * 100.0)		],
	[ "Excluded visits (e.g. robots)"	, $sumrobot		, sprintf("%.1f", $sumrobot / $session * 100.0)		],
	[ "Total visits"			, $session		, "100.0"						],
);
&make_table(@rows);

$nr = sprintf("%.1f",$durationcount / $session * 100.0);
print FILE "<B>$nr %</B> of your visitors visit at least two pages on your site, which is ";
if ($nr > 75) {
	print FILE "pretty good !\n";
	print FILE "Have a closer look at the <A HREF=\"$ref{5}\">transit</A> pages and see if you might keep them even longer...\n";
}
elsif ($nr > 50) {
	print FILE "okay.\n";
	print FILE "Have a closer look at the <A HREF=\"$ref{7}\">exit</A> pages and see if you might keep them from leaving...\n";
}
elsif ($nr > 25) {
	print FILE "not so good.\n";
	print FILE "Have a closer look at the <A HREF=\"$ref{3}\">entry</A> pages and see if you might keep them for a while...\n";
}
else {
	print FILE "pretty bad !\n";
	print FILE "Have a closer look at the <A HREF=\"$ref{9}\">hit & run</A> pages and see if you might keep them on your site...\n";
}
print FILE "<P>\n";

$mintime = &time2hms($minduration);
$avgtime = &time2hms($avgduration);
$maxtime = &time2hms($maxduration);

($host_h,$date_h) = split(' ',$maxstepkey);
($host_d,$date_d) = split(' ',$maxdurationkey);

@rows = (
	[ "Visit Statistics"	, "Page hits<BR>per visit"		, "Elapsed time<BR>per visit"		, "Time per<BR>page (sec)"			],
	[ "left"		, "right"				, "right"				, "right"					],
	[ 0			, 0					, 0					, 0						],
	[ "Minimum"		, $minstep				, $mintime				, "<A HREF=\"$ref{12}\">$timestat[3]</A>"	],
	[ "Average"		, $avgstep				, $avgtime				, $timestat[2]					],
	[ "Maximum"		, "<A HREF=\"$ref{23}\">$maxstep</A>"	, "<A HREF=\"$ref{24}\">$maxtime</A>"	, "<A HREF=\"$ref{11}\">$timestat[4]</A>"	],
	[ ""			, ""					, ""					, ""						],
);
&make_table(@rows);

$nr = sprintf("%.1f",$avgstep / $pagestat[0] * 100.0);
print FILE "The average visit reaches <B>$nr %</B> of all pages (including returns to the same page).<P>\n";
print FILE "The longest visit in number of hits was from <A HREF=\"$ref{23}\">host $host_h on $date_h</A>.<BR>\n";
if ($maxstepkey == $maxdurationkey) {
	print FILE "It was also the longest visit in duration.<P>\n";
}
else {
	print FILE "The longest visit in duration was from <A HREF=\"$ref{24}\">host $host_d on <BR>$date_d</A>.<P>\n";
}

print FILE "<H2>4. Page Information</H2>\n";

print FILE "The most important page statistics are given in the table below :<P>\n";

@rows = (
	[ "Page Type"	, "Hit<BR>Count"	, "Hits<BR>(%)"		, ""		, "Page<BR>Count"	, "Pages<BR>(%)"	, ""		, "Min.<BR>Hits"				, "Avg.<BR>Hits"	, "Max.<BR>Hits"				, "Max.<BR>(%)"		, "Max. Hits - Page"					],
	[ "left"	, "right"		, "right"		, "center"	, "right"		, "right"		, "center"	, "right"					, "right"		, "right"					, "right"		, "left"						],
	[ 0		, 0			, 1			, 0		, 0			, 1			, 0		, 0						, 0			, 0						, 1			, 0							],
	[ "Entry"	, $entrystat[1]		, $entrystat[7]		, ""		, $entrystat[0]		, $entrystat[6]		, ""		, "<A HREF=\"$ref{4}\">$entrystat[3]</A>"	, $entrystat[2]		, "<A HREF=\"$ref{3}\">$entrystat[4]</A>"	, $entrystat[8]		, "<A HREF=\"$entrystat[5]\">$entrystat[5]</A>"		],
	[ "Transit"	, $transitstat[1]	, $transitstat[7]	, ""		, $transitstat[0]	, $transitstat[6]	, ""		, "<A HREF=\"$ref{6}\">$transitstat[3]</A>"	, $transitstat[2]	, "<A HREF=\"$ref{5}\">$transitstat[4]</A>"	, $transitstat[8]	, "<A HREF=\"$transitstat[5]\">$transitstat[5]</A>"	],
	[ "Exit"	, $exitstat[1]		, $exitstat[7]		, ""		, $exitstat[0]		, $exitstat[6]		, ""		, "<A HREF=\"$ref{8}\">$exitstat[3]</A>"	, $exitstat[2]		, "<A HREF=\"$ref{7}\">$exitstat[4]</A>"	, $exitstat[8]		, "<A HREF=\"$exitstat[5]\">$exitstat[5]</A>"		],
	[ "Hit&amp;Run"	, $hitrunstat[1]	, $hitrunstat[7]	, ""		, $hitrunstat[0]	, $hitrunstat[6]	, ""		, "<A HREF=\"$ref{10}\">$hitrunstat[3]</A>"	, $hitrunstat[2]	, "<A HREF=\"$ref{9}\">$hitrunstat[4]</A>"	, $hitrunstat[8]	, "<A HREF=\"$hitrunstat[5]\">$hitrunstat[5]</A>"	],
	[ "Total"	, $pagestat[1]		, $pagestat[7]		, ""		, $pagestat[0]		, $pagestat[6]		, ""		, "<A HREF=\"$ref{2}\">$pagestat[3]</A>"	, $pagestat[2]		, "<A HREF=\"$ref{1}\">$pagestat[4]</A>"	, $pagestat[8]		, "<A HREF=\"$pagestat[5]\">$pagestat[5]</A>"		],
);
&make_table(@rows);

print FILE "<B>It is worthwhile spending some time on this table.</B> Notice for instance that of the $pagestat[1] page visits,\n";
if ($hitrunstat[7] ne "-") {
	print FILE "<B>$hitrunstat[7] %</B> are hit & runs.\n";
}
else {
	print FILE "<B>$transitstat[7] %</B> are visits in transit, i.e. somewhere inside your website.\n";
}
print FILE "Or that of the $pagestat[0] different pages on your website,\n";
if ($exitstat[6] > $entrystat[6]) {
	print FILE "<B>$exitstat[6] %</B> are used as an exit page at least once.<P>\n";
}
else {
	print FILE "<B>$entrystat[6] %</B> are used as an entry page at least once.<P>\n";
}
print FILE "Based on the $entrystat[1] entries to your website, you can also see that <B>$entrystat[8] %</B> of your visitors use page\n";
print FILE "<A HREF=\"$entrystat[5]\">$entrystat[5]</A> to enter your site, and <B>$exitstat[8] %</B> use ";
if ($entrystat[5] eq $exitstat[5]) {
	print FILE "the same page";
}
else {
	print FILE "page <A HREF=\"$exitstat[5]\">$exitstat[5]</A>";
}
print FILE " right before leaving your website.\n";
if ($hitrunstat[5] ne "") {
	if ($hitrunstat[5] eq $entrystat[5]) {
		print FILE "And the same entry page is also";
	}
	elsif ($hitrunstat[5] eq $exitstat[5]) {
		print FILE "And the same exit page is also";
	}
	else {
		print FILE "And page <A HREF=\"$hitrunstat[5]\">$hitrunstat[5]</A> is";
	}
	print FILE " responsible for <B>$hitrunstat[8] %</B> of the hit & runs.\n";
}
else {
	print FILE "There are no hit & run pages.\n";
}
print FILE "<P>\n";

print FILE "<H2>5. Link Information</H2>\n";

print FILE "The most important link statistics are given in the table below :<P>\n";

@rows = (
	[ "Link Type"	, "Hit<BR>Count"	, "Hits<BR>(%)"		, ""		, "Link<BR>Count"	, "Links<BR>(%)"	, ""		, "Min.<BR>Hits"				, "Avg.<BR>Hits"	, "Max.<BR>Hits"				, "Max.<BR>(%)"		, "Max. Hits - From Page"				, "Max. Hits - To Page"					],
	[ "left"	, "right"		, "right"		, "center"	, "right"		, "right"		, "center"	, "right"					, "right"		, "right"					, "right"		, "left"						, "left"						],
	[ 0		, 0			, 1			, 0		, 0			, 1			, 0		, 0						, 0			, 0						, 1			, 0							, 0							],
	[ "Incoming"	, $instat[1]		, $instat[7]		, ""		, $instat[0]		, $instat[6]		, ""		, "<A HREF=\"$ref{16}\">$instat[3]</A>"		, $instat[2]		, "<A HREF=\"$ref{15}\">$instat[4]</A>"		, $instat[8]		, "<A HREF=\"$instat[11]\">$instat[11]</A>"		, "<A HREF=\"$instat[12]\">$instat[12]</A>"		],
	[ "Internal"	, $internstat[1]	, $internstat[7]	, ""		, $internstat[0]	, $internstat[6]	, ""		, "<A HREF=\"$ref{18}\">$internstat[3]</A>"	, $internstat[2]	, "<A HREF=\"$ref{17}\">$internstat[4]</A>"	, $internstat[8]	, "<A HREF=\"$internstat[11]\">$internstat[11]</A>"	, "<A HREF=\"$internstat[12]\">$internstat[12]</A>"	],
	[ "Outgoing"	, $outstat[1]		, $outstat[7]		, ""		, $outstat[0]		, $outstat[6]		, ""		, "<A HREF=\"$ref{20}\">$outstat[3]</A>"	, $outstat[2]		, "<A HREF=\"$ref{19}\">$outstat[4]</A>"	, $outstat[8]		, "<A HREF=\"$outstat[11]\">$outstat[11]</A>"		, "<A HREF=\"$outstat[12]\">$outstat[12]</A>"		],
	[ "In&amp;Out"	, $inoutstat[1]		, $inoutstat[7]		, ""		, $inoutstat[0]		, $inoutstat[6]		, ""		, "<A HREF=\"$ref{22}\">$inoutstat[3]</A>"	, $inoutstat[2]		, "<A HREF=\"$ref{21}\">$inoutstat[4]</A>"	, $inoutstat[8]		, "<A HREF=\"$inoutstat[11]\">$inoutstat[11]</A>"	, "<A HREF=\"$inoutstat[12]\">$inoutstat[12]</A>"	],
	[ "Total"	, $linkstat[1]		, $linkstat[7]		, ""		, $linkstat[0]		, $linkstat[6]		, ""		, "<A HREF=\"$ref{14}\">$linkstat[3]</A>"	, $linkstat[2]		, "<A HREF=\"$ref{13}\">$linkstat[4]</A>"	, $linkstat[8]		, "<A HREF=\"$linkstat[11]\">$linkstat[11]</A>"		, "<A HREF=\"$linkstat[12]\">$linkstat[12]</A>"		],
);
&make_table(@rows);

print FILE "Interpretation of this table is similar to the one above.\n";
print FILE "Note that redirects by your web server will also appear as links, and that frames will generate links between the main frame and its children.<P>\n";

$nr = sprintf("%.1f",$linkstat[0] / $pagestat[0]);
print FILE "Since $pagestat[0] different pages were visited and $linkstat[0] different links were followed on your website, we can say that visitors usually follow <B>$nr links per page</B>.\n";
if ($nr > 5) {
	print FILE "This means that visitors often use the available hyperlinks on your site.\n";
}
elsif ($nr > 2) {
	print FILE "This means that visitors do not use many hyperlinks on your site.\n";
}
else {
	print FILE "This means that you may not have enough hyperlinks on your site, or that they are hardly ever used.\n";
}


print FILE "<H2>6. Status Information</H2>\n";

#
# From chklog.pl, Jason Mathews, 5/95
# See URL http://ednet.gsfc.nasa.gov/Mathews/webtools/
#

%statcodes = (

# LEVEL 100

	  100,'Continue',
	  101,'Switching Protocols',

# LEVEL 200

	  200,'Okay',
	  201,'Created',
	  202,'Accepted',
	  203,'Non-Authoritative Information',
	  204,'No Content',
	  205,'Reset Content',
	  206,'Partial Content',

# LEVEL 300

	  301,'Moved',
	  302,'Redirected Requests',
	  303,'Method',
	  304,'Not modified',
	  305,'Use Proxy',

# LEVEL 400

	  400,'Bad request',
	  401,'Unauthorized Requests',
	  402,'Payment Required',
	  403,'Forbidden Requests',
	  404,'Not Found Requests',
	  405,'Method not allowed',
	  # Apache
	  406,'Not Acceptable',
	  407,'Proxy Authentication Required',
	  408,'Request Time-out',
	  409,'Conflict',
	  410,'Gone',
	  411,'Length Required',
	  412,'Precondition Failed',
	  413,'Request Entity Too Large',
	  414,'Request-URI Too Large',
	  415,'Unsupported Media Type',

# LEVEL 500

	  500,'Server Error',
	  501,'Not Implemented Requests',
	  502,'Service temporarily overloaded',
	  503,'Service Unavailable',
	  504,'Gateway timeout',
	  505,'HTTP Version Not Supported',
	  506,'Variant Also Varies',
);

# for ALL hits, including images... !?

@def = (
	[ "Code"	, "Description"	, "Hit<BR>Count", "Hits<BR>(%)"	],
	[ "left"	, "left"	, "right"	, "right"	],
	[ 0		, 0		, 0		, 1		],
);

&open_table(@def);
$sum = 0;
for $status (sort keys %totstatus) {
	&print_tr( $status , $statcodes{$status} , $totstatus{$status} , sprintf("%.1f", $totstatus{$status} / $line * 100.0) );
	$sum += $totstatus{$status};
}
&print_tf( "Total" , "" , $sum , "100.0" );
&close_table();

$nr = sprintf("%.1f", ($totstatus{200} + $totstatus{304}) / $sum * 100.0);
print FILE "The 'usual' status codes, i.e. 200 ($statcodes{200}) and 304 ($statcodes{304}), represent <B>$nr %</B> of all hits.<BR>\n";
print FILE "The others are examined in more detail <A HREF=\"$ref{'e'}\">here</A>.<BR>\n";

&close_body();

#
# Status Codes (except 200 and 304)
#

&open_body("e","Status Codes");

print FILE "The following list shows both 'page' and 'image' hits for all status codes except 200 ($statcodes{200}) and 304 ($statcodes{304}).<P>\n";
print FILE "You can check the exact cause for error codes in the error logfiles on your webserver.<P>\n";

sub by_status {
	($stata,$urla) = split(' ',$a);
	($statb,$urlb) = split(' ',$b);
	if ($stata eq $statb) {
		if ($toterr{$b} == $toterr{$a}) {
			$urla cmp $urlb;
		}
		else {
			$toterr{$b} <=> $toterr{$a};
		}
	}
	else {
		$stata cmp $statb;
	}
}

print FILE "<PRE>";
$oldstatus = "";
for $key (sort by_status keys %toterr) {
	($status,$url) = split(' ',$key);
	if ($status ne $oldstatus) {
		print FILE "\nStatus $status ($statcodes{$status}) : $totstatus{$status}\n";
	}
	print FILE "\t$toterr{$key}\t<A HREF=\"$url\">$url</A>\n";
	$oldstatus = $status;
}
print FILE "</PRE><P>\n";

&close_body();

#
# Page Statistics
#

@def = ( #type	#title			#descr					#col	#list_ref	#stat_ref	#url_ref
	[ 1	, "Most Visited"	, "most visited pages overall"		, 0	, \@pagetop	, \@pagestat	, \%pageurl	],
	[ 2	, "Least Visited"	, "least visited pages overall"		, 0	, \@pagebot	, \@pagestat	, \%pageurl	],
	[ 3	, "Most Entries"	, "most frequently used entry points"	, 1	, \@entrytop	, \@entrystat	, \%entryurl	],
	[ 4	, "Least Entries"	, "least frequently used entry points"	, 1	, \@entrybot	, \@entrystat	, \%entryurl	],
	[ 5	, "Most Transits"	, "most frequently used transit points"	, 2	, \@transittop	, \@transitstat	, \%transiturl	],
	[ 6	, "Least Transits"	, "least frequently used transit points", 2	, \@transitbot	, \@transitstat	, \%transiturl	],
	[ 7	, "Most Exits"		, "most frequently used exit points"	, 3	, \@exittop	, \@exitstat	, \%exiturl	],
	[ 8	, "Least Exits"		, "least frequently used exit points"	, 3	, \@exitbot	, \@exitstat	, \%exiturl	],
	[ 9	, "Most Hit&amp;Runs"	, "most frequent hit&amp;run pages"	, 4	, \@hitruntop	, \@hitrunstat	, \%hitrunurl	],
	[ 10	, "Least Hit&amp;Runs"	, "least frequent hit&amp;run pages"	, 4	, \@hitrunbot	, \@hitrunstat	, \%hitrunurl	],
	[ 11	, "Most Time Spent"	, "pages where visitors spent most time"	, 5	, \@timetop	, \@timestat	, \%timeval	],
	[ 12	, "Least Time Spent"	, "pages where visitors spent least time"	, 5	, \@timebot	, \@timestat	, \%timeval	],
);

for $i (0 .. $#def) {
	&make_tpage(@{$def[$i]});
}


#
# Link Statistics
#

@def = ( #type	#title			#descr						#col	#list_ref	#stat_ref	#link_ref
	[ 13	, "Most Followed"	, "most frequently followed links overall"	, 0	, \@linktop	, \@linkstat	, \%totlink	],
	[ 14	, "Least Followed"	, "least frequently followed links overall"	, 0	, \@linkbot	, \@linkstat	, \%totlink	],
	[ 15	, "Most Incoming"	, "most frequently followed incoming links"	, 1	, \@intop	, \@instat	, \%inlink	],
	[ 16	, "Least Incoming"	, "least frequently followed incoming links"	, 1	, \@inbot	, \@instat	, \%inlink	],
	[ 17	, "Most Internal"	, "most frequently followed internal links"	, 2	, \@interntop	, \@internstat	, \%internlink	],
	[ 18	, "Least Internal"	, "least frequently followed internal links"	, 2	, \@internbot	, \@internstat	, \%internlink	],
	[ 19	, "Most Outgoing"	, "most frequently followed outgoing links"	, 3	, \@outtop	, \@outstat	, \%outlink	],
	[ 20	, "Least Outgoing"	, "least frequently followed outgoing links"	, 3	, \@outbot	, \@outstat	, \%outlink	],
	[ 21	, "Most In&amp;Out"	, "most frequently followed in&amp;out links"	, 4	, \@inouttop	, \@inoutstat	, \%inoutlink	],
	[ 22	, "Least In&amp;Out"	, "least frequently followed in&amp;out links"	, 4	, \@inoutbot	, \@inoutstat	, \%inoutlink	],
);

for $i (0 .. $#def) {
	&make_tlink(@{$def[$i]});
}

#
# Longest Visit (in Hits)
#

&open_body("23","Longest Visit (in Hits)");
($host,$datetime) = split(' ',$maxstepkey);
print FILE "The longest visit to this website (in number of page hits) was made by host <B>$host</B> on <B>$datetime</B>. ";
print FILE "It includes $maxstep page hits\n";
undef @sessionlist;
@sessionlist = split(/\n/,$maxstepval);
($time1,$status1,$url1) = split(' ',$sessionlist[0]);
($time2,$status2,$url2) = split(' ',$sessionlist[$#sessionlist]);
$time = &time2hms($time2-$time1);
$nr = sprintf("%.1f",($time2-$time1) / $#sessionlist);
print FILE "and lasts for $time, with an average of $nr seconds per step.<P>\n";

&open_lvisit();
for ($i = 0; $i <= $#sessionlist; $i++) {
	($time,$status,$url) = split(' ',$sessionlist[$i]);
	&print_lvisit($i,$time,$status,$url);
}
&close_lvisit();

&close_body();

#
# Longest Visit (in Time)
#

&open_body("24","Longest Visit (in Time)");
($host,$datetime) = split(' ',$maxdurationkey);
$time = &time2hms($maxduration);
print FILE "The longest visit to this website (in total time spent) was made by host <B>$host</B> on <B>$datetime</B>. ";
print FILE "It lasts for $time\n";
undef @sessionlist;
@sessionlist = split(/\n/,$maxdurationval);
$nr = sprintf("%.1f",($maxduration) / $#sessionlist);
print FILE "and includes $#sessionlist page hits, with an average of $nr seconds per step.<P>\n";

&open_lvisit();
for ($i = 0; $i <= $#sessionlist; $i++) {
	($time,$status,$url) = split(' ',$sessionlist[$i]);
	&print_lvisit($i,$time,$status,$url);
}
&close_lvisit();
&close_body();

if ($flyprog eq "") {
	#
	# Entry Tree
	#

	&open_body("25","Entry Tree");
	print FILE "The following list shows the most frequently used <B>entry pages</B> with their most frequently followed <B>incoming and in&amp;out links</B>.\n";
	print FILE "This area of aWebVisit is now replaced by the <A HREF=\"http://mikespub.net/tools/aWebVisit/\">aWebVisit-Map</A> CGI program.<P>\n";
	print FILE "<PRE>\n";

	print FILE "\nEntry : $entrystat[1] hits - $entrystat[0] pages\n\n";
	for $i (0 .. $#entrytop) {
		print FILE "From entry page :\n";
		print FILE "$entryurl{$entrytop[$i]}\t<A HREF=\"$entrytop[$i]\">$entrytop[$i]</A>\n";
		print FILE "\t\tTo transit pages :\n";
		for $j (0 .. $#intop) {
			($from,$to) = split(/ /,$intop[$j]);
			if ($from eq $entrytop[$i]) {
				print FILE "\t\t$inlink{$intop[$j]}\t<A HREF=\"$to\">$to</A>\n";
			}
		}
		print FILE "\tTo exit pages :\n";
		for $j (0 .. $#inouttop) {
			($from,$to) = split(/ /,$inouttop[$j]);
			if ($from eq $entrytop[$i]) {
				print FILE "\t$inoutlink{$inouttop[$j]}\t<A HREF=\"$to\">$to</A>\n";
			}
		}
		print FILE "\n";
	}

	print FILE "</PRE><P>\n";
	&close_body();

	#
	# Exit Tree
	#

	&open_body("26","Exit Tree");
	print FILE "The following list shows the most frequently used <B>exit pages</B> with their most frequently followed <B>outgoing and in&amp;out links</B>.\n";
	print FILE "This area of aWebVisit is now replaced by the <A HREF=\"http://mikespub.net/tools/aWebVisit/\">aWebVisit-Map</A> CGI program.<P>\n";
	print FILE "<PRE>\n";

	print FILE "\nExit : $exitstat[1] hits - $exitstat[0] pages\n\n";
	for $i (0 .. $#exittop) {
		print FILE "\tFrom entry pages :\n";
		for $j (0 .. $#inouttop) {
			$k = $#inouttop - $j;
			($from,$to) = split(/ /,$inouttop[$k]);
			if ($to eq $exittop[$i]) {
				print FILE "\t$inoutlink{$inouttop[$k]}\t<A HREF=\"$from\">$from</A>\n";
			}
		}
		print FILE "\t\tFrom transit pages :\n";
		for $j (0 .. $#outtop) {
			$k = $#outtop - $j;
			($from,$to) = split(/ /,$outtop[$k]);
			if ($to eq $exittop[$i]) {
				print FILE "\t\t$outlink{$outtop[$k]}\t<A HREF=\"$from\">$from</A>\n";
			}
		}
		print FILE "To exit page :\n";
		print FILE "$exiturl{$exittop[$i]}\t<A HREF=\"$exittop[$i]\">$exittop[$i]</A>\n";
		print FILE "\n";
	}

	print FILE "</PRE><P>\n";
	&close_body();

} # flyprog

print STDERR "\n";

###########################################################################
#
# Save data to file
#

if (defined($csvfile) && length($csvfile) > 0) {
	print STDERR "Saving data to file '$outdir/$csvfile'...\n";

	open(FILE,">$outdir/$csvfile") || die "can't open data file $csvfile\n";
	print FILE join($delim,"Logfile",$startdate,$enddate,"evaluated on",$timestamp) . "\n";
	print FILE "Created with <A HREF=\"http://mikespub.net/tools/aWebVisit/\" TARGET=\"_top\">aWebVisit 0.1.6</A> on $timestamp\n";
	print FILE "\n";

	print FILE join($delim,"Page","Total","Entry","Transit","Exit","Hit&Run","AvgTime") . "\n";
	while (($key,$value) = each %pageurl) {
		print FILE join($delim,$key,$pageurl{$key},$entryurl{$key},$transiturl{$key},$exiturl{$key},$hitrunurl{$key},$timeval{$key}) . "\n";
	}
	print FILE join($delim,"Total Count",$pagestat[1],$entrystat[1],$transitstat[1],$exitstat[1],$hitrunstat[1],$timestat[1]) . "\n";
	print FILE join($delim,"Total Pages",$pagestat[0],$entrystat[0],$transitstat[0],$exitstat[0],$hitrunstat[0],$timestat[0]) . "\n";
	print FILE join($delim,"Average per Page",$pagestat[2],$entrystat[2],$transitstat[2],$exitstat[2],$hitrunstat[2],$timestat[2]) . "\n";
	print FILE join($delim,"Minimum",$pagestat[3],$entrystat[3],$transitstat[3],$exitstat[3],$hitrunstat[3],$timestat[3]) . "\n";
	print FILE join($delim,"Maximum",$pagestat[4],$entrystat[4],$transitstat[4],$exitstat[4],$hitrunstat[4],$timestat[4]) . "\n";

	print FILE "\n";

	print FILE join($delim,"From Page","To Page","Total","Incoming","Internal","Outgoing","In&Out") . "\n";
	while (($key,$value) = each %totlink) {
		($from,$to) = split(' ',$key);
		print FILE join($delim,$from,$to,$totlink{$key},$inlink{$key},$internlink{$key},$outlink{$key},$inoutlink{$key}) ."\n";
	}
	print FILE join($delim,"Total Count","Total",$linkstat[1],$instat[1],$internstat[1],$outstat[1],$inoutstat[1]) . "\n";
	print FILE join($delim,"Total Links","Links",$linkstat[0],$instat[0],$internstat[0],$outstat[0],$inoutstat[0]) . "\n";
	print FILE join($delim,"Average per Link","Average",$linkstat[2],$instat[2],$internstat[2],$outstat[2],$inoutstat[2]) . "\n";
	print FILE join($delim,"Minimum","Minimum",$linkstat[3],$instat[3],$internstat[3],$outstat[3],$inoutstat[3]) ."\n";
	print FILE join($delim,"Maximum","Maximum",$linkstat[4],$instat[4],$internstat[4],$outstat[4],$inoutstat[4]) ."\n";

	print FILE "\n";
	close(FILE); 
}

###########################################################################
#
# Save statistics to file - NEEDED FOR aWebVisit-Map !!!
#

if (defined($statfile) && length($statfile) > 0) {
	print STDERR "Saving statistics to file '$outdir/$statfile'...\n";

	open(FILE,">$outdir/$statfile") || die "can't open statistics file $statfile\n";
	print FILE join($delim,"Logfile",$startdate,$enddate,"evaluated on",$timestamp) . "\n";
	print FILE "Created with <A HREF=\"http://mikespub.net/tools/aWebVisit/\" TARGET=\"_top\">aWebVisit 0.1.6</A> on $timestamp\n";
	print FILE "\n";

	print FILE join($delim,"Pages",@pagestat) . "\n";
	foreach $page (@pagetop) {
		print FILE join($delim,$page,$pageurl{$page},$timeval{$page}) . "\n";
	}
	print FILE join($delim,"Entries",@entrystat) . "\n";
	foreach $page (@entrytop) {
		print FILE join($delim,$page,$entryurl{$page},$timeval{$page}) . "\n";
	}
	print FILE join($delim,"Transits",@transitstat) . "\n";
	foreach $page (@transittop) {
		print FILE join($delim,$page,$transiturl{$page},$timeval{$page}) . "\n";
	}
	print FILE join($delim,"Exits",@exitstat) . "\n";
	foreach $page (@exittop) {
		print FILE join($delim,$page,$exiturl{$page},$timeval{$page}) . "\n";
	}
	print FILE join($delim,"Hit&Runs",@hitrunstat) . "\n";
	foreach $page (@hitruntop) {
		print FILE join($delim,$page,$hitrunurl{$page},$timeval{$page}) . "\n";
	}
	print FILE "\n";

	print FILE join($delim,"Links",@linkstat) . "\n";
	foreach $link (@linktop) {
		($from,$to) = split(/ /,$link);
		print FILE join($delim,$from,$to,$totlink{$link},$pageurl{$from},$pageurl{$to}) . "\n";
	}
	print FILE join($delim,"Incoming",@instat) . "\n";
	foreach $link (@intop) {
		($from,$to) = split(/ /,$link);
		print FILE join($delim,$from,$to,$inlink{$link},$entryurl{$from},$transiturl{$to}) . "\n";
	}
	print FILE join($delim,"Internal",@internstat) . "\n";
	foreach $link (@interntop) {
		($from,$to) = split(/ /,$link);
		print FILE join($delim,$from,$to,$internlink{$link},$transiturl{$from},$transiturl{$to}) . "\n";
	}
	print FILE join($delim,"Outgoing",@outstat) . "\n";
	foreach $link (@outtop) {
		($from,$to) = split(/ /,$link);
		print FILE join($delim,$from,$to,$outlink{$link},$transiturl{$from},$exiturl{$to}) . "\n";
	}
	print FILE join($delim,"In&Out",@inoutstat) . "\n";
	foreach $link (@inouttop) {
		($from,$to) = split(/ /,$link);
		print FILE join($delim,$from,$to,$inoutlink{$link},$entryurl{$from},$exiturl{$to}) . "\n";
	}
	print FILE "\n";

	print FILE join($delim,"Time",@timestat) . "\n";
	foreach $page (@timetop) {
		print FILE join($delim,$page,$timeurl{$page},$timeval{$page}) . "\n";
	}

	print FILE "\n";
	close(FILE); 
}

###########################################################################
#
# End of aWebVisit
#

print STDERR "The aWebVisit reports can now be viewed at '$file{f}'\n";

if ($flyprog eq "" || $cgiprog ne "") {
	if ($cgiprog ne "") {
		print STDERR "The web maps can be viewed from URL '$cgiprog'\n";
	}
	else {
		print STDERR "The 'fly' program is not configured, so there are no web maps available...\n";
	}
	exit;
}

#
# End of aWebVisit
#
###########################################################################
#

# This is a reduced version of the aWebVisit-Map program, that allows you
# to travel through your website and analyse the links to and from each page.
#
# You can get the full CGI program from the same place as aWebvisit :
#	http://mikespub.net/tools/aWebVisit/
#
# Just make sure that aWebVisit saves the visit statistics to some file first!

#
###########################################################################
#
# For more information about aWebVisit-Map, see its script...
#
###########################################################################
#

###########################################################################
#
# Initialise the maps
#

sub init_maps {
	if (defined($flyprog) && $flyprog ne "") {
		if (!-x $flyprog) {
			die "The FLY program '$flyprog' is not available or executable !\nCheck the '\$flyprog' variable in the aWebVisit configuration.\n";
		}
	}
	elsif (!defined($flyprog)) {
		die "The FLY program '$flyprog' is not defined !\nCheck the '\$flyprog' variable in the aWebVisit configuration.\n";
	}

	foreach $type ("t","f","m","o") {
		$file{$type} = $outdir . "/" . $name . $type . ".html";
		$ref{$type} = $name . $type . ".html";
	}

	for ($type = 30; $type < 35; $type++) {
		$file{$type} = $outdir . "/" . $name . $type . ".html";
		$ref{$type} = $name . $type . ".html";
		$imgfile{$type} = $outdir . "/" . $name . $type . ".gif";
		$imgref{$type} = $name . $type . ".gif";
	}

	#
	# Initialise fly variables
	#

	&init_fly();

}

###########################################################################
#
# Routines for creating generic images
#

sub init_fly {
	%flyfonts = (
		'tiny',		[ 5 , 8  ],
		'small',	[ 6 , 12 ],
		'medium',	[ 7 , 13 ],
		'large',	[ 8 , 16 ],
		'giant',	[ 9 , 15 ], # 15 ?
	);

	$flyratio = 0.7;

	@flycolor = (
		[ 0	, 0	, 0	],
		[ 0	, 0	, 225	],
		[ 63	, 175	, 63	],
#		[ 0	, 255	, 0	],
		[ 225	, 0	, 0	],
		[ 232	, 232	, 0	],
		[ 255	, 0	, 205	],
		[ 0	, 205	, 255	],
		[ 159	, 159	, 159	],
		[ 95	, 159	, 255	],
		[ 95	, 255	, 159	],
		[ 255	, 95	, 159	],
		[ 230	, 230	, 95	],
		[ 255	, 95	, 255	],
		[ 95	, 255	, 255	],
		[ 159	, 95	, 255	],
		[ 159	, 255	, 95	],
		[ 255	, 159	, 95	],
	);
}

sub open_fly {
	my($infile,$width,$height) = @_;

	open(FLY,"> $infile");
	print FLY "new\n";
	print FLY "size $width,$height\n";
	print FLY "fill 1,1,203,255,255\n";

	@maps = ();
}

sub close_fly {
	my($infile,$outfile) = @_;

	close(FLY);

	system("$flyprog -q -i $infile -o $outfile");

	unlink($infile);
}

sub fly_text {
	my($type,$text,$x,$y,$ref,$alt,$col,$size) = @_;
	my($width,$height,$x1,$y1);

	if(!defined($size)) {
		$size = "medium";
	}
	$xchar = $flyfonts{$size}[0];
	$ychar = $flyfonts{$size}[1];

	$width = length($text) * $xchar;
	$height = $ychar;

	if ($type == 1) { # align center
		$x1 = $x - $width/2;
	}
	elsif ($type == 2) { # align left
		$x1 = $x;
	}
	else { # align right
		$x1 = $x - $width;
	}
	$y1 = $y - $height / 2;
	if (defined($col) && defined(@flycolor)) {
		print FLY "string $flycolor[$col][0],$flycolor[$col][1],$flycolor[$col][2],$x1,$y1,$size,$text\n";
	}
	else {
		print FLY "string 0,0,0,$x1,$y1,$size,$text\n";
	}

	if (defined($ref)) {
		push( @maps, [ $ref, $alt, "rect", int($x1 - 5), int($y1 - 5), int($x1 + $width + 5), int($y1 + $height + 5) ] );
	}
}

sub fly_line {
	my($text,$x1,$y1,$x2,$y2,$ref,$alt,$col,$size) = @_;
	my($xmid,$ymid,$hypot);

	if (defined($col) && defined(@flycolor)) {
		print FLY "line $x1,$y1,$x2,$y2,$flycolor[$col][0],$flycolor[$col][1],$flycolor[$col][2]\n";
	}
	else {
		print FLY "line $x1,$y1,$x2,$y2,0,0,0\n";
	}
	$xmid = ($x1 + $x2) / 2;
	$ymid = ($y1 + $y2) / 2;

	if (defined($text) && $text ne "") {
		&fly_text(1,$text,$xmid,$ymid,$ref,$alt,$col,$size);
	}

	if (defined($ref)) {
		$hypot = sqrt(($x2 - $x1)**2 + ($y2 - $y1)**2);
		$xmid = 5 * ($y2 - $y1) / $hypot;
		$ymid = 5 * ($x2 - $x1) / $hypot;
		push( @maps, [ $ref, $alt, "poly", int($x1 + $xmid), int($y1 - $ymid), int($x1 - $xmid), int($y1 + $ymid), int($x2 - $xmid), int($y2 + $ymid), int($x2 + $xmid), int($y2 - $ymid) ] );
	}
}

#
# Routines for creating images with generic nodes and links
#

sub fly_node {
	my($text,$x,$y,$textlen,$ref,$alt) = @_;
	my($width,$height,$xchar,$ychar,$xyratio);

	$xchar = $flyfonts{medium}[0];
	$ychar = $flyfonts{medium}[1];
	$xyratio = $flyratio;

	$width = ($textlen + 4) * $xchar;
	$height = $width * $xyratio;
	print FLY "ellipse $x,$y,$width,$height,0,0,0\n";
	print FLY "fill $x,$y,255,255,255\n";

	if (defined($text) && $text ne "") {
		&fly_text(1,$text,$x,$y);
	}

	if (defined($ref)) {
		push( @maps, [ $ref, $alt, "rect", int($x - $width / 2), int($y - $height / 2), int($x + $width / 2), int($y + $height / 2) ] );
	}
}

sub get_maxnode {
	my($noderef) = @_;
	my($i,$text,$maxlen);

	$maxlen = 0;
	for $i (0 .. $#{$noderef}) {
		$text = $$noderef[$i][0];
		if ($maxlen < length($text)) {
			$maxlen = length($text);
		}
	}
	return($maxlen);
}

sub make_nodes {
	my($noderef) = @_;
	my($maxlen,$i,$text,$x,$y,$ref,$alt);

	$maxlen = &get_maxnode($noderef);

	for $i (0 .. $#{$noderef}) {
		($text,$x,$y,$ref,$alt) = @{$$noderef[$i]};
		&fly_node($text,$x,$y,$maxlen,$ref, defined($alt) ? $alt : $text );
	}
}

sub make_links {
	my($noderef,$linkref) = @_;
	my($xchar,$ychar,$xyratio,$maxlen,$width,$height);
	my($i,$text,$node1,$node2,$ref,$alt);
	my($x1,$y1,$x2,$y2,$xdiff,$ydiff,$rad,$deg,$start,$end,$awidth,$aheight);

	$xchar = $flyfonts{medium}[0];
	$ychar = $flyfonts{medium}[1];
	$xyratio = $flyratio;

	$maxlen = &get_maxnode($noderef);

	$width = ($maxlen+4) * $xchar / 2;
	$height = $width * $xyratio;

	for $i (0 .. $#{$linkref}) {
		($text,$node1,$node2,$ref,$alt,$col) = @{$$linkref[$i]};
		if ($node1 eq "") {
			$x2 = $$noderef[$node2][1];
			$y2 = $$noderef[$node2][2] - $height;
			$x1 = $x2;
			$y1 = $y2 - 80 + $height;
			&fly_line($text,$x1,$y1,$x2,$y2, defined($ref) ? $ref : $$noderef[$node2][3], defined($alt) ? $alt : "--&gt; $$noderef[$node2][0]",$col);
			$x1 = $x2 - 4;
			$y1 = $y2 - 5;
			&fly_line("",$x1,$y1,$x2,$y2,undef,undef,$col);
			$x1 = $x2 + 4;
			$y1 = $y2 - 5;
			&fly_line("",$x1,$y1,$x2,$y2,undef,undef,$col);
		}
		elsif ($node2 eq "") {
			$x1 = $$noderef[$node1][1];
			$y1 = $$noderef[$node1][2] + $height;
			$x2 = $x2;
			$y2 = $y1 + 80 - $height;
			&fly_line($text,$x1,$y1,$x2,$y2, defined($ref) ? $ref : $$noderef[$node1][3], defined($alt) ? $alt : "$$noderef[$node1][0] --&gt;",$col);
			$x1 = $x2 - 4;
			$y1 = $y2 - 5;
			&fly_line("",$x1,$y1,$x2,$y2,undef,undef,$col);
			$x1 = $x2 + 4;
			$y1 = $y2 - 5;
			&fly_line("",$x1,$y1,$x2,$y2,undef,undef,$col);
		}
		elsif ($node1 == $node2) {
			$x1 = $$noderef[$node1][1];
			$y1 = $$noderef[$node1][2];
		# cross between circle and ellipse at 45 deg
		#	$rad = 2 * sqrt(2) * $xyratio * $height / (1 + $xyratio**2);
		#	$xdiff = $width;
		#	$start = 225;
		#	$end = 135;
		# cross between camel and elephant at my place
			$rad = sqrt(($width**2 + $height**2)/2);
			$xdiff = $width * sqrt(2);
			$deg = atan2($height,$width) * 45 / atan2(1,1);
			$start = 180 + $deg;
			$end = 180 - $deg;
			$awidth = 2 * $rad;
			$aheight = 2 * $rad;
		# from border of node
			if (defined($ref)) {
				push( @maps, [ $ref, defined($alt) ? $alt : "$$noderef[$node1][0] --&gt; $$noderef[$node2][0]", "rect", int($x1 + $width + 1), int($y1 - $rad), int($x1 + $xdiff + $rad), int($y1 + $rad) ] );
			}
			$x1 += $xdiff;
			if (defined($col) && defined(@flycolor)) {
				print FLY "arc $x1,$y1,$awidth,$aheight,$start,$end,$flycolor[$col][0],$flycolor[$col][1],$flycolor[$col][2]\n";
			}
			else {
				print FLY "arc $x1,$y1,$awidth,$aheight,$start,$end,0,0,0\n";
			}
			$x1 += $rad;
			&fly_text(1,$text,$x1,$y1,$ref,$alt,$col);
		}
		else {
			$x1 = $$noderef[$node1][1];
			$y1 = $$noderef[$node1][2];
			$x2 = $$noderef[$node2][1];
			$y2 = $$noderef[$node2][2];
		# intersection of line with ellipse
			$root = sqrt(($xyratio**2) * (($x2-$x1)**2) + ($y2-$y1)**2);
			$xdiff = $height * ($x2 - $x1) / $root;
			$ydiff = $height * ($y2 - $y1) / $root;
			$x1 += $xdiff;
			$y1 += $ydiff;
			$x2 -= $xdiff;
			$y2 -= $ydiff;
			&fly_line($text,$x1,$y1,$x2,$y2,$ref,defined($alt) ? $alt : "$$noderef[$node1][0] --&gt; $$noderef[$node2][0]",$col);
		}
	}
}

sub make_nodeimg {
	my($type,$width,$height) = @_;

	&open_fly($file{t},$width,$height);
	&make_nodes(\@nodes);
	&make_links(\@nodes,\@links);
	&close_fly($file{t},$imgfile{$type});
}

#
# Routines for creating images with page boxes and web links
#

sub fly_box {
	my($type,$text,$val,$x,$y,$ref,$alt,$arrow,$col) = @_;
	my($xchar,$ychar,$width,$height,$x1,$y1,$x2,$y2,$offset,$part);
	my($leftx,$rightx,$topy,$bottomy);

	$xchar = $flyfonts{small}[0];
	$ychar = $flyfonts{small}[1];

	if ($type < 3) { # wrap text
		$maxtext = 8;
		$width = ($maxtext + 2) * $xchar;
		$height = int((length($text) - 1) / $maxtext);
		$height = $height * ($ychar+2);
		$x1 = $x - $width / 2;
		$x2 = $x + $width / 2;
		if ($type == 1) { # align bottom
			$y1 = $y - $height - $ychar - 4;
			$y2 = $y;
			if ($val > 0) {
				&fly_line($val,$x,$y1-50,$x,$y1,undef,undef,$col);
				if ($arrow == 1 || $arrow == 3) { # to node
					&fly_line("",$x+4,$y1-5,$x,$y1,undef,undef,$col);
					&fly_line("",$x-4,$y1-5,$x,$y1,undef,undef,$col);
				}
				if ($arrow == 2 || $arrow == 3) { # from node
					&fly_line("",$x+4,$y1-45,$x,$y1-50,undef,undef,$col);
					&fly_line("",$x-4,$y1-45,$x,$y1-50,undef,undef,$col);
				}
			}
		}
		elsif ($type == 2) { # align top
			$y1 = $y;
			$y2 = $y + $height + $ychar + 4;
			if ($val > 0) {
				&fly_line($val,$x,$y2,$x,$y2+50,undef,undef,$col);
				if ($arrow == 1 || $arrow == 3) { # to node
					&fly_line("",$x+4,$y2+5,$x,$y2,undef,undef,$col);
					&fly_line("",$x-4,$y2+5,$x,$y2,undef,undef,$col);
				}
				if ($arrow == 2 || $arrow == 3) { # from node
					&fly_line("",$x+4,$y2+45,$x,$y2+50,undef,undef,$col);
					&fly_line("",$x-4,$y2+45,$x,$y2+50,undef,undef,$col);
				}
			}
		}
		else { # align middle + keep position in left/right x & top/bottom y
			$y1 = $y - ($height + $ychar + 4)/2;
			$y2 = $y + ($height + $ychar + 4)/2;
			# no value or arrow supported
		}
		print FLY "rect $x1,$y1,$x2,$y2,0,0,0\n";
		$leftx = $x1;
		$rightx = $x2;
		$topy = $y1;
		$bottomy = $y2;
		if (defined($ref)) {
			push( @maps, [ $ref, $alt, "rect", $x1, $y1, $x2, $y2 ] );
		}
		$y = $y1 + 2;
		print FLY "fill $x,$y,255,255,255\n";
		$offset = 0;
		while ($offset < length($text)) {
			$part = substr($text,$offset,$maxtext);
			$width = length($part) * $xchar;
			$x1 = $x - $width / 2;
			$y1 = $y;
			print FLY "string 0,0,0,$x1,$y1,small,$part\n";
			$offset += $maxtext;
			$y += $ychar + 2;
		}
	}
	elsif ($type == 3) { # no wrap, align left
		$width = (length($text) + 2) * $xchar;
		$x1 = $x;
		$x2 = $x + $width;
		$y1 = $y - $ychar / 2 - 2;
		$y2 = $y + $ychar / 2 + 2;
		print FLY "rect $x1,$y1,$x2,$y2,0,0,0\n";
		$leftx = $x1;
		$rightx = $x2;
		$topy = $y1;
		$bottomy = $y2;
		if (defined($ref)) {
			push( @maps, [ $ref, $alt, "rect", $x1, $y1, $x2, $y2 ] );
		}
		$x1 = $x + $width / 2;
		$y1 = $y;
		print FLY "fill $x1,$y1,255,255,255\n";
		$x1 = $x + $xchar;
		$y1 = $y - $ychar / 2;
		print FLY "string 0,0,0,$x1,$y1,small,$text\n";
		if ($val > 0) {
			$x1 = $x + $width;
			$y1 = $y;
			$x2 = $x1 + 60;
			$y2 = $y1;
			&fly_line($val,$x1,$y1,$x2,$y2,undef,undef,$col);
			if ($arrow == 1 || $arrow == 3) { # to node
				&fly_line("",$x1+5,$y1-3,$x1,$y1,undef,undef,$col);
				&fly_line("",$x1+5,$y1+3,$x1,$y1,undef,undef,$col);
			}
			if ($arrow == 2 || $arrow == 3) { # from node
				&fly_line("",$x2-5,$y2-3,$x2,$y2,undef,undef,$col);
				&fly_line("",$x2-5,$y2+3,$x2,$y2,undef,undef,$col);
			}
		}
	}
	elsif ($type == 4) { # no wrap, align right
		$width = (length($text) + 2) * $xchar;
		$x1 = $x - $width;
		$x2 = $x;
		$y1 = $y - $ychar / 2 - 2;
		$y2 = $y + $ychar / 2 + 2;
		print FLY "rect $x1,$y1,$x2,$y2,0,0,0\n";
		$leftx = $x1;
		$rightx = $x2;
		$topy = $y1;
		$bottomy = $y2;
		if (defined($ref)) {
			push( @maps, [ $ref, $alt, "rect", $x1, $y1, $x2, $y2 ] );
		}
		$x1 = $x - $width / 2;
		$y1 = $y;
		print FLY "fill $x1,$y1,255,255,255\n";
		$x1 = $x - $width + $xchar;
		$y1 = $y - $ychar / 2;
		print FLY "string 0,0,0,$x1,$y1,small,$text\n";
		if ($val > 0) {
			$x1 = $x - $width;
			$y1 = $y;
			$x2 = $x1 - 60;
			$y2 = $y1;
			&fly_line($val,$x1,$y1,$x2,$y2,undef,undef,$col);
			if ($arrow == 1 || $arrow == 3) { # to node
				&fly_line("",$x1-5,$y1-3,$x1,$y1,undef,undef,$col);
				&fly_line("",$x1-5,$y1+3,$x1,$y1,undef,undef,$col);
			}
			if ($arrow == 2 || $arrow == 3) { # from node
				&fly_line("",$x2+5,$y1-3,$x2,$y2,undef,undef,$col);
				&fly_line("",$x2+5,$y1+3,$x2,$y2,undef,undef,$col);
			}
		}
	}
	elsif ($type == 5) { # no wrap, vertical text, align bottom
		$height = (length($text) + 2) * $xchar;
		$x1 = $x - $ychar / 2 - 2;
		$x2 = $x + $ychar / 2 + 2;
		$y1 = $y - $height;
		$y2 = $y;
		print FLY "rect $x1,$y1,$x2,$y2,0,0,0\n";
		$leftx = $x1;
		$rightx = $x2;
		$topy = $y1;
		$bottomy = $y2;
		if (defined($ref)) {
			push( @maps, [ $ref, $alt, "rect", $x1, $y1, $x2, $y2 ] );
		}
		$x1 = $x;
		$y1 = $y - $height/2;
		print FLY "fill $x1,$y1,255,255,255\n";
		$x1 = $x - $ychar / 2;
		$y1 = $y - $xchar;
		print FLY "stringup 0,0,0,$x1,$y1,small,$text\n";
		if ($val > 0) {
			$x1 = $x;
			$y1 = $y - $height;
			$x2 = $x1;
			$y2 = $y1 - 50;
			&fly_line($val,$x1,$y1,$x2,$y2,undef,undef,$col);
			if ($arrow == 1 || $arrow == 3) { # to node
				&fly_line("",$x1+4,$y1-5,$x1,$y1,undef,undef,$col);
				&fly_line("",$x1-4,$y1-5,$x1,$y1,undef,undef,$col);
			}
			if ($arrow == 2 || $arrow == 3) { # from node
				&fly_line("",$x2+4,$y2+5,$x2,$y2,undef,undef,$col);
				&fly_line("",$x2-4,$y2+5,$x2,$y2,undef,undef,$col);
			}
		}
	}
	elsif ($type == 6) { # no wrap, vertical text, align top
		$height = (length($text) + 2) * $xchar;
		$x1 = $x - $ychar / 2 - 2;
		$x2 = $x + $ychar / 2 + 2;
		$y1 = $y;
		$y2 = $y + $height;
		print FLY "rect $x1,$y1,$x2,$y2,0,0,0\n";
		$leftx = $x1;
		$rightx = $x2;
		$topy = $y1;
		$bottomy = $y2;
		if (defined($ref)) {
			push( @maps, [ $ref, $alt, "rect", $x1, $y1, $x2, $y2 ] );
		}
		$x1 = $x;
		$y1 = $y + $height/2;
		print FLY "fill $x1,$y1,255,255,255\n";
		$x1 = $x - $ychar / 2;
		$y1 = $y + $height - $xchar;
		print FLY "stringup 0,0,0,$x1,$y1,small,$text\n";
		if ($val > 0) {
			$x1 = $x;
			$y1 = $y + $height;
			$x2 = $x1;
			$y2 = $y1 + 50;
			&fly_line($val,$x1,$y1,$x2,$y2,undef,undef,$col);
			if ($arrow == 1 || $arrow == 3) { # to node
				&fly_line("",$x1+4,$y1+5,$x1,$y1,undef,undef,$col);
				&fly_line("",$x1-4,$y1+5,$x1,$y1,undef,undef,$col);
			}
			if ($arrow == 2 || $arrow == 3) { # from node
				&fly_line("",$x2+4,$y2-5,$x2,$y2,undef,undef,$col);
				&fly_line("",$x2-4,$y2-5,$x2,$y2,undef,undef,$col);
			}
		}
	}
	elsif ($type == 7) { # no wrap, align center
		$width = (length($text) + 2) * $xchar;
		$x1 = $x - $width / 2;
		$x2 = $x + $width / 2;
		$y1 = $y - $ychar / 2 - 2;
		$y2 = $y + $ychar / 2 + 2;
		print FLY "rect $x1,$y1,$x2,$y2,0,0,0\n";
		$leftx = $x1;
		$rightx = $x2;
		$topy = $y1;
		$bottomy = $y2;
		if (defined($ref)) {
			push( @maps, [ $ref, $alt, "rect", $x1, $y1, $x2, $y2 ] );
		}
		$x1 = $x;
		$y1 = $y;
		print FLY "fill $x1,$y1,255,255,255\n";
		$x1 = $x - $width / 2 + $xchar;
		$y1 = $y - $ychar / 2;
		print FLY "string 0,0,0,$x1,$y1,small,$text\n";
		# no value or arrow supported
	}
	return($leftx,$topy,$rightx,$bottomy);
}

#
# Routines for creating companion HTML pages and image maps
#

sub add_imgmap {
	my($type,$width,$height) = @_;
	my($i,$j,$k);

	print FILE "<CENTER>\n";
	print FILE "<IMG SRC=\"$imgref{$type}\" USEMAP=\"#awebmap\" BORDER=\"0\" WIDTH=\"$width\" HEIGHT=\"$height\">\n";
	print FILE "<MAP NAME=\"awebmap\">\n";
	for $i (0 .. $#maps) {
		print FILE "<AREA HREF=\"$maps[$i][0]\" ALT=\"$maps[$i][1]\" SHAPE=\"$maps[$i][2]\" COORDS=\"";
		if ($#{$maps[$i]} > 2) {
			for $j (3 .. $#{$maps[$i]}) {
				$k = int($maps[$i][$j]);
				print FILE "$k,";
			}
		}
		print FILE "\">\n";
	}
	print FILE "</MAP>\n";
	print FILE "</CENTER>\n";
	print FILE "<P>\n";
}

sub make_map {
	my($type,$title,$width,$height) = @_;

	open(FILE,">$file{$type}") || die "Can't create output file of type $type : '$file{$type}'...";
	select(FILE);$|=1;select(STDOUT);

	print FILE "<HTML>\n";
	print FILE "<HEAD>\n";
	print FILE "<TITLE>\n";
	print FILE "	aWebVisit - $title (from $startdate to $enddate)\n";
	print FILE "</TITLE>\n";
	print FILE "</HEAD>\n";

	print FILE "<BODY BGCOLOR=\"$bgcolor\">\n";

	&add_imgmap($type,$width,$height);

	print FILE "<P>\n";
	print FILE "<HR>Created with <A HREF=\"http://mikespub.net/tools/aWebVisit/\" TARGET=\"_top\">aWebVisit 0.1.6</A> on $timestamp\n";
	print FILE "</BODY>\n";
	print FILE "</HTML>\n";
	close(FILE);
}

###########################################################################
#
# Create web maps
#

print STDERR "Generating web maps...\n";
$timestamp = localtime(time);

$type = "m";
$title = "Web Maps";
open(FILE,">$file{$type}") || die "Can't create output file of type $type : '$file{$type}'...";
select(FILE);$|=1;select(STDOUT);
print FILE "<HTML>\n";
print FILE "<HEAD>\n";
print FILE "<TITLE>\n";
print FILE "	aWebVisit - $title (from $startdate to $enddate)\n";
print FILE "</TITLE>\n";
print FILE "</HEAD>\n";
print FILE "<FRAMESET FRAMEBORDER=\"1\" FRAMESPACING=\"0\" FRAMEPADDING=\"0\" ROWS=\"50,*\">\n";
print FILE "	<FRAME SRC=\"$ref{'o'}\" NAME=\"awm_t\" SCROLLING=\"no\">\n";
print FILE "	<FRAME SRC=\"$ref{31}\" NAME=\"awm_b\" SCROLLING=\"auto\">\n";
print FILE "	<NOFRAMES>\n";
print FILE "		<BODY BGCOLOR=\"$bgcolor\">\n";
print FILE "		Warning, your browser does not support frames, but we need them !<P>\n";
print FILE "		Please upgrade your IT manager...";
print FILE "<HR>Created with <A HREF=\"http://mikespub.net/tools/aWebVisit/\" TARGET=\"_top\">aWebVisit 0.1.6</A> on $timestamp\n";
print FILE "		</BODY>\n";
print FILE "	</NOFRAMES>\n";
print FILE "</FRAMESET>\n";
print FILE "</HTML>\n";
close(FILE);

$type = "o";
$title = "Overview of Maps";
open(FILE,">$file{$type}") || die "Can't create output file of type $type : '$file{$type}'...";
select(FILE);$|=1;select(STDOUT);
print FILE "<HTML>\n";
print FILE "<HEAD>\n";
print FILE "<TITLE>\n";
print FILE "	aWebVisit - $title (from $startdate to $enddate)\n";
print FILE "</TITLE>\n";
print FILE "</HEAD>\n";
print FILE "<BODY BGCOLOR=\"$bgcolor\">\n";
print FILE "<CENTER>\n";
print FILE "[ <A HREF=\"$ref{'f'}\" TARGET=\"_top\">Back to aWebVisit Reports</A> |\n";
print FILE "<A HREF=\"$ref{31}\" TARGET=\"awm_b\">Global View</A> |\n";
print FILE "<A HREF=\"$ref{32}\" TARGET=\"awm_b\">Entry Map</A> |\n";
print FILE "<A HREF=\"$ref{34}\" TARGET=\"awm_b\">Transit Map</A> |\n";
print FILE "<A HREF=\"$ref{33}#bottom\" TARGET=\"awm_b\">Exit Map</A> ]\n";
print FILE "</CENTER>\n";
print FILE "</HTML>\n";
close(FILE);

#
# Make Generic Web Map
#

@nodes = (
	[ "Entry"	, 160	, 80	, $ref{32}	], # node 0
	[ "Transit"	, 260	, 180	, $ref{34}	], # node 1
	[ "Exit"	, 160	, 280	, $ref{33}	], # node 2
	[ "Hit&Run"	, 60	, 80	], # node 3
);

@links = (
	[""		, ""	, 0	, undef		, undef		, 2],
	["Incoming"	, 0	, 1	, $ref{32}	, "Incoming"	, 2],
	["Internal"	, 1	, 1	, $ref{34}	, "Internal"	, 1],
	["Outgoing"	, 1	, 2	, $ref{33}	, "Outgoing"	, 3],
	["In&Out"	, 0	, 2	, undef		, undef		, 4],
	[""		, 2	, ""	, undef		, undef		, 3],
	[""		, ""	, 3	, undef		, undef		, 7],
);

$imgwidth = 400;
$imgheight = 360;

&make_nodeimg("30",$imgwidth,$imgheight);
&make_map("30","Introduction to Web Maps",$imgwidth,$imgheight);

#
# Make Global View Map
#

@nodes = (
	[ "Entry"	, 160	, 80	, $ref{32}		],
	[ "Transit"	, 260	, 180	, $ref{34}		],
	[ "Exit"	, 160	, 280	, "$ref{33}#bottom"	],
	[ "Hit&Run"	, 60	, 80	, undef			, "No Map"	],
);

@links = (
	[$entrystat[1]	, ""	, 0	, undef			, undef		, 2],
	[$instat[1]	, 0	, 1	, $ref{32}		, "Incoming"	, 2],
	[$internstat[1]	, 1	, 1	, $ref{34}		, "Internal"	, 1],
	[$outstat[1]	, 1	, 2	, "$ref{33}#bottom"	, "Outgoing"	, 3],
	[$inoutstat[1]	, 0	, 2	, undef			, "In&Out"	, 4],
	[$exitstat[1]	, 2	, ""	, undef			, undef		, 3],
	[$hitrunstat[1]	, ""	, 3	, undef			, undef		, 7],
);

$imgwidth = 400;
$imgheight = 360;

&make_nodeimg("31",$imgwidth,$imgheight);
&make_map("31","Global View Map",$imgwidth,$imgheight);

$tmpfile = $file{'t'};

#
# Create Entry Map
#

&reset_map();
&make_topentry();

#
# Create Exit Map
#

&reset_map();
&make_topexit();

#
# Create Transit Map
#

&reset_map();
&make_toptransit();

print STDERR "The global web maps can now be viewed at '$file{'m'}'\n";

exit;

sub reset_map {
	undef %topnode;
	undef %rightnode;
	undef %bottomnode;

	undef %topX;
	undef %topY;
	undef %rightX,
	undef %rightY;
	undef %bottomX;
	undef %bottomY;
}

#
# Sorting routines
#

sub sort_by_topurl {
	my($topref,$urlref) = @_;
	my(@sorted);

	@sorted = sort {
		if ($$urlref{$b} == $$urlref{$a}) {
			$a cmp $b;
		}
		else {
			$$urlref{$b} <=> $$urlref{$a};
		}
	} @{$topref};

	return(@sorted);
}

sub sort_by_nodeurl {
	my($noderef,$urlref) = @_;
	my(@sorted);

	@sorted = sort {
		if ($$noderef{$b} == $$noderef{$a}) {
			if ($$urlref{$b} == $$urlref{$a}) {
				$a cmp $b;
			}
			else {
				$$urlref{$b} <=> $$urlref{$a};
			}
		}
		else {
			$$noderef{$b} <=> $$noderef{$a};
		}
	} keys %{$noderef};
	return(@sorted);
}

#
# Routines for checking the width or height of URLs
#

sub check_urlheight {
	my($ychar,$height);

	$ychar = $flyfonts{small}[1];

	$height = int((length($url) - 1) / 8);
	$height = $height * ($ychar+2);

	return $height;
}

sub check_nodeheight {
	my($noderef,$urlref,$nodecount,$minheight) = @_;
	my($ychar,$i,$maxlen,$node,$height);

	$ychar = $flyfonts{small}[1];

	$i = 0;
	$maxlen = 0;
	foreach $node (&sort_by_nodeurl($noderef,$urlref)) {
		if ($i >= $nodecount) {
			last;
		}
		if ($maxlen < length($node)) {
			$maxlen = length($node);
		}
		$i++;
	}
	$height = ($maxlen - 1) / 8;
	$height = $height * ($ychar + 2) + 60;
	if ($height < $minheight) {
		$height = $minheight;
	}
	return $height;
}

sub check_nodewidth {
	my($noderef,$urlref,$nodecount,$minwidth) = @_;
	my($xchar,$i,$maxlen,$node,$width);

	$xchar = $flyfonts{small}[0];

	$i = 0;
	$maxlen = 0;
	foreach $node (&sort_by_nodeurl($noderef,$urlref)) {
		if ($i >= $nodecount) {
			last;
		}
		if ($maxlen < length($node)) {
			$maxlen = length($node);
		}
		$i++;
	}
	$width = ($maxlen + 2) * $xchar + 60;
	if ($width < $minwidth) {
		$width = $minwidth;
	}
	return $width;
}

#
# Show Title on Map
#

sub map_title {
	my($title) = @_;

	$x = 20;
	$y = 20;
	&fly_text(2,"$title",$x,$y);
	&fly_text(2,"(from $startdate",$x,$y+20,undef,undef,undef,"small");
	&fly_text(2,"to $enddate)",$x,$y+35,undef,undef,undef,"small");
	$y = $imgheight - 20;
	&fly_text(2,"Created with aWebVisit-Map 0.1.6",$x,$y,"http://mikespub.net/tools/aWebVisit/",undef,undef,"small");
}

#
# TOP ENTRIES
#

sub make_topentry {

#
# Get values
#
	$i = 0;
	foreach $node (&sort_by_topurl(\@entrytop,\%entryurl)) {
		if ($i >= $topentries) {
			last;
		}
		$topnode{$node} = $entryurl{$node};
		$i++;
	} 
	foreach $link (@intop) {
		($from,$to) = split(/ /,$link);
		if (defined($topnode{$from})) {
			$rightnode{$to} += $inlink{$link};
		}
	}
	foreach $link (@inouttop) {
		($from,$to) = split(/ /,$link);
		if (defined($topnode{$from})) {
			$bottomnode{$to} += $inoutlink{$link};
		}
	}

	$topcount = keys %topnode;
	$rightcount = keys %rightnode;
	$bottomcount = keys %bottomnode;

	if ($topcount > $topentries) {
		$topcount = $topentries;
	}
	if ($rightcount > $toptransits) {
		$rightcount = $toptransits;
	}
	if ($bottomcount > $topexits) {
		$bottomcount = $topexits;
	}

	$maxcount = $topcount > $bottomcount ? $topcount : $bottomcount;
#
# Determine image size
#

	$leftwidth = 70;
	$midwidth = $maxcount * 70;
	$rightwidth = &check_nodewidth(\%rightnode,\%transiturl,$rightcount,200);
	$imgwidth = $leftwidth + $midwidth + $rightwidth;

	$topheight = &check_nodeheight(\%topnode,\%entryurl,$topcount,140);
	$topheight += 30;
	$breakheight = 40;
	$midheight = $rightcount * 30;
	$bottomheight = &check_nodeheight(\%bottomnode,\%exiturl,$bottomcount,140);
	$imgheight = $topheight + $breakheight + $midheight + $bottomheight;

	&open_fly($tmpfile,$imgwidth,$imgheight);

#
# Show Title
#
	&map_title("Top Entry Pages");

#
# Show Buttons
#
#	$midx = $imgwidth / 2;
#	&map_buttons("");

#
# FROM ENTRY
#

	$x = $leftwidth;
	$y = $topheight;
	$topsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%topnode,\%entryurl)) {
		if ($i >= $topcount) {
			last;
		}
		&fly_box(1,$node,$entryurl{$node},$x,$y,"$node",undef,1,2);
		$topX{$node} = $x;
		$topY{$node} = $y;
		$topNr{$node} = $i;
		if (substr($entryurl{$node},0,1) ne "<") {
			$topsum += $entryurl{$node};
		}
		$x += 70;
		$i++;
	}

#
# TO EXIT
#
	$x = $leftwidth;
	$y = $imgheight - $bottomheight;
	$bottomsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%bottomnode,\%exiturl)) {
		if ($i >= $bottomcount) {
			last;
		}
		&fly_box(2,$node,$exiturl{$node},$x,$y,"$node",undef,2,3);
		$bottomX{$node} = $x;
		$bottomY{$node} = $y;
		if (substr($exiturl{$node},0,1) ne "<") {
			$bottomsum += $exiturl{$node};
		}
		$x += 70;
		$i++;
	}

#
# TO TRANSIT
#
	$x = $imgwidth - $rightwidth;
	$y = $topheight + $breakheight;
	$rightsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%rightnode,\%transiturl)) {
		if ($i >= $rightcount) {
			last;
		}
		&fly_box(3,$node,$transiturl{$node},$x,$y,"$node",undef,3,1);
		$rightX{$node} = $x;
		$rightY{$node} = $y;
		if (substr($transiturl{$node},0,1) ne "<") {
			$rightsum += $transiturl{$node};
		}
		$y += 30;
		$i++;
	}

#
# Show Links
#

	$linksum = 0;
	foreach $link (@inouttop) {
		($from,$to) = split(/ /,$link);
		if (defined($topX{$from}) && defined($bottomX{$to})) {
#			&fly_line($inoutlink{$link},$topX{$from},$topY{$from},$bottomX{$to},$bottomY{$to},undef,undef,4);
			&fly_line($inoutlink{$link},$topX{$from},$topY{$from},$bottomX{$to},$bottomY{$to},undef,undef,$topNr{$from});
			$linksum += $inoutlink{$link};
			$topTotal{$from} += $inoutlink{$link};
			$bottomTotal{$to} += $inoutlink{$link};
		}
	}
	foreach $link (@intop) {
		($from,$to) = split(/ /,$link);
		if (defined($topX{$from}) && defined($rightX{$to})) {
#			&fly_line($inlink{$link},$topX{$from},$topY{$from},$rightX{$to},$rightY{$to},undef,undef,2);
			&fly_line($inlink{$link},$topX{$from},$topY{$from},$rightX{$to},$rightY{$to},undef,undef,$topNr{$from});
			$linksum += $inlink{$link};
			$topTotal{$from} += $inlink{$link};
			$rightTotal{$to} += $inlink{$link};
		}
	}

#
# Show Score
#

	foreach $node (keys %topX) {
		if (!defined($topTotal{$node})) {
			$topTotal{$node} = "-";
		}
		&fly_text(1,"($topTotal{$node})",$topX{$node},$topY{$node}+8,undef,undef,undef,"small");
	}

	foreach $node (keys %bottomX) {
		if (!defined($bottomTotal{$node})) {
			$bottomTotal{$node} = "-";
		}
		&fly_text(1,"($bottomTotal{$node})",$bottomX{$node},$bottomY{$node}-8,undef,undef,undef,"small");
	}

	foreach $node (keys %rightX) {
		if (!defined($rightTotal{$node})) {
			$rightTotal{$node} = "-";
		}
		&fly_text(3,"($rightTotal{$node})",$rightX{$node}-5,$rightY{$node},undef,undef,undef,"small");
	}

#
# Show Statistics
#
	$x = $imgwidth / 2;
	$y = 50;
	if ($linksum > 0 && $topsum > 0) {
		$pct = sprintf("%.1f", $topsum / $entrystat[1] * 100.0);
		&fly_text(1,"These pages account for $pct % of all entries to your website.",$x,$y,undef,undef,undef,"small");
		$pct = sprintf("%.1f", $linksum / $topsum * 100.0);
		&fly_text(1,"The links represent $pct % of all links from these entry pages.",$x,$y+15,undef,undef,undef,"small");
	}
	else {
		&fly_text(1,"These pages are not part of the Top Pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		&fly_text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	&close_fly($tmpfile,$imgfile{32});
	&make_map("32","Top Entry Pages",$imgwidth,$imgheight);

}

#
# TOP EXITS
#

sub make_topexit {

#
# Get values
#
	$i = 0;
	foreach $node (&sort_by_topurl(\@exittop,\%exiturl)) {
		if ($i >= $topexits) {
			last;
		}
		$bottomnode{$node} = $exiturl{$node};
		$i++;
	}
	foreach $link (@inouttop) {
		($from,$to) = split(/ /,$link);
		if (defined($bottomnode{$to})) {
			$topnode{$from} += $inoutlink{$link};
		}
	}
	foreach $link (@outtop) {
		($from,$to) = split(/ /,$link);
		if (defined($bottomnode{$to})) {
			$rightnode{$from} += $outlink{$link};
		}
	}

	$topcount = keys %topnode;
	$rightcount = keys %rightnode;
	$bottomcount = keys %bottomnode;

	if ($topcount > $topentries) {
		$topcount = $topentries;
	}
	if ($rightcount > $toptransits) {
		$rightcount = $toptransits;
	}
	if ($bottomcount > $topexits) {
		$bottomcount = $topexits;
	}

	$maxcount = $topcount > $bottomcount ? $topcount : $bottomcount;
#
# Determine image size
#

	$leftwidth = 70;
	$midwidth = $maxcount * 70;
	$rightwidth = &check_nodewidth(\%rightnode,\%transiturl,$rightcount,200);
	$imgwidth = $leftwidth + $midwidth + $rightwidth;

	$topheight = &check_nodeheight(\%topnode,\%entryurl,$topcount,140);
	$breakheight = 40;
	$midheight = $rightcount * 30;
	$bottomheight = &check_nodeheight(\%bottomnode,\%exiturl,$bottomcount,140);
	$bottomheight += 30;
	$imgheight = $topheight + $midheight + $breakheight + $bottomheight;

	&open_fly($tmpfile,$imgwidth,$imgheight);

#
# Show Title
#
	&map_title("Top Exit Pages");

#
# Show Buttons
#
#	$midx = $imgwidth / 2;
#	&map_buttons("");

#
# FROM ENTRY
#

	$x = $leftwidth;
	$y = $topheight;
	$topsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%topnode,\%entryurl)) {
		if ($i >= $topcount) {
			last;
		}
		&fly_box(1,$node,$entryurl{$node},$x,$y,"$node",undef,1,2);
		$topX{$node} = $x;
		$topY{$node} = $y;
		if (substr($entryurl{$node},0,1) ne "<") {
			$topsum += $entryurl{$node};
		}
		$x += 70;
		$i++;
	}

#
# TO EXIT
#
	$x = $leftwidth;
	$y = $imgheight - $bottomheight;
	$bottomsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%bottomnode,\%exiturl)) {
		if ($i >= $bottomcount) {
			last;
		}
		&fly_box(2,$node,$exiturl{$node},$x,$y,"$node",undef,2,3);
		$bottomX{$node} = $x;
		$bottomY{$node} = $y;
		$bottomNr{$node} = $i;
		if (substr($exiturl{$node},0,1) ne "<") {
			$bottomsum += $exiturl{$node};
		}
		$x += 70;
		$i++;
	}

#
# FROM TRANSIT
#
	$x = $imgwidth - $rightwidth;
	$y = $imgheight - $bottomheight - $breakheight;
	$rightsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%rightnode,\%transiturl)) {
		if ($i >= $rightcount) {
			last;
		}
		&fly_box(3,$node,$transiturl{$node},$x,$y,"$node",undef,3,1);
		$rightX{$node} = $x;
		$rightY{$node} = $y;
		if (substr($transiturl{$node},0,1) ne "<") {
			$rightsum += $transiturl{$node};
		}
		$y -= 30;
		$i++;
	}

#
# Show Links
#

	$linksum = 0;
	foreach $link (@inouttop) {
		($from,$to) = split(/ /,$link);
		if (defined($topX{$from}) && defined($bottomX{$to})) {
#			&fly_line($inoutlink{$link},$topX{$from},$topY{$from},$bottomX{$to},$bottomY{$to},undef,undef,4);
			&fly_line($inoutlink{$link},$topX{$from},$topY{$from},$bottomX{$to},$bottomY{$to},undef,undef,$bottomNr{$to});
			$linksum += $inoutlink{$link};
			$topTotal{$from} += $inoutlink{$link};
			$bottomTotal{$to} += $inoutlink{$link};
		}
	}
	foreach $link (@outtop) {
		($from,$to) = split(/ /,$link);
		if (defined($rightX{$from}) && defined($bottomX{$to})) {
#			&fly_line($outlink{$link},$rightX{$from},$rightY{$from},$bottomX{$to},$bottomY{$to},undef,undef,3);
			&fly_line($outlink{$link},$rightX{$from},$rightY{$from},$bottomX{$to},$bottomY{$to},undef,undef,$bottomNr{$to});
			$linksum += $outlink{$link};
			$rightTotal{$from} += $outlink{$link};
			$bottomTotal{$to} += $outlink{$link};
		}
	}

#
# Show Score
#

	foreach $node (keys %topX) {
		&fly_text(1,"($topTotal{$node})",$topX{$node},$topY{$node}+8,undef,undef,undef,"small");
	}

	foreach $node (keys %bottomX) {
		&fly_text(1,"($bottomTotal{$node})",$bottomX{$node},$bottomY{$node}-8,undef,undef,undef,"small");
	}

	foreach $node (keys %rightX) {
		&fly_text(3,"($rightTotal{$node})",$rightX{$node}-5,$rightY{$node},undef,undef,undef,"small");
	}

#
# Show Statistics
#
	$x = $imgwidth / 2;
	$y = $imgheight - 60;
	if ($linksum > 0 && $bottomsum > 0) {
		$pct = sprintf("%.1f", $bottomsum / $exitstat[1] * 100.0);
		&fly_text(1,"These pages account for $pct % of all exits from your website.",$x,$y,undef,undef,undef,"small");
		$pct = sprintf("%.1f", $linksum / $bottomsum * 100.0);
		&fly_text(1,"The links represent $pct % of all links to these exit pages.",$x,$y+15,undef,undef,undef,"small");
	}
	else {
		&fly_text(1,"These pages are not part of the Top Pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		&fly_text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	&close_fly($tmpfile,$imgfile{33});
	&make_map("33","Top Exit Pages",$imgwidth,$imgheight);

}

#
# TOP TRANSITS
#

sub make_toptransit {

#
# Get values
#
	$i = 0;
	foreach $node (&sort_by_topurl(\@transittop,\%transiturl)) {
		if ($i >= $toptransits) {
			last;
		}
		$rightnode{$node} = $transiturl{$node};
		$i++;
	}
	foreach $link (@intop) {
		($from,$to) = split(/ /,$link);
		if (defined($rightnode{$to})) {
			$topnode{$from} += $inlink{$link};
		}
	}
	foreach $link (@outtop) {
		($from,$to) = split(/ /,$link);
		if (defined($rightnode{$from})) {
			$bottomnode{$to} += $outlink{$link};
		}
	}

	$topcount = keys %topnode;
	$bottomcount = keys %bottomnode;
	$rightcount = keys %rightnode;

	if ($topcount > $topentries) {
		$topcount = $topentries;
	}
	if ($rightcount > $toptransits) {
		$rightcount = $toptransits;
	}
	if ($bottomcount > $topexits) {
		$bottomcount = $topexits;
	}

	$maxcount = $topcount > $bottomcount ? $topcount : $bottomcount;
#
# Determine image size
#

	$leftwidth = 70;
	$midwidth = $maxcount * 70;
	$rightwidth = &check_nodewidth(\%rightnode,\%transiturl,$rightcount,200);
	$imgwidth = $leftwidth + $midwidth + $rightwidth;

	$topheight = &check_nodeheight(\%topnode,\%entryurl,$topcount,140);
	$topheight += 50;
	$breakheight = 40;
	$midheight = $rightcount * 30;
	$bottomheight = &check_nodeheight(\%bottomnode,\%exiturl,$bottomcount,140);
	$imgheight = $topheight + $breakheight + $midheight + $bottomheight;

	&open_fly($tmpfile,$imgwidth,$imgheight);

#
# Show Title
#
	&map_title("Top Transit Pages");

#
# Show Buttons
#
#	$midx = $imgwidth / 2;
#	&map_buttons("");

#
# FROM ENTRY
#

#	$x = 70;
	$x = $midwidth;
	$y = $topheight;
	$topsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%topnode,\%entryurl)) {
		if ($i >= $topcount) {
			last;
		}
		&fly_box(1,$node,$entryurl{$node},$x,$y,"$node",undef,1,2);
		$topX{$node} = $x;
		$topY{$node} = $y;
		if (substr($entryurl{$node},0,1) ne "<") {
			$topsum += $entryurl{$node};
		}
#		$x += 70;
		$x -= 70;
		$i++;
	}

#
# TO EXIT
#

#	$x = 70;
	$x = $midwidth;
	$y = $imgheight - $bottomheight;
	$bottomsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%bottomnode,\%exiturl)) {
		if ($i >= $bottomcount) {
			last;
		}
		&fly_box(2,$node,$exiturl{$node},$x,$y,"$node",undef,2,3);
		$bottomX{$node} = $x;
		$bottomY{$node} = $y;
		if (substr($exiturl{$node},0,1) ne "<") {
			$bottomsum += $exiturl{$node};
		}
#		$x += 70;
		$x -= 70;
		$i++;
	}

#
# FROM/TO TRANSIT
#
	$x = $imgwidth - $rightwidth;
	$y = $topheight + $breakheight;
	$rightsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%rightnode,\%transiturl)) {
		if ($i >= $rightcount) {
			last;
		}
		&fly_box(3,$node,$transiturl{$node},$x,$y,"$node",undef,3,1);
		$rightX{$node} = $x;
		$rightY{$node} = $y;
		$rightNr{$node} = $i;
		if (substr($transiturl{$node},0,1) ne "<") {
			$rightsum += $transiturl{$node};
		}
		$y += 30;
		$i++;
	}


#
# Show Links
#

	$linksumout = 0;
	foreach $link (@outtop) {
		($from,$to) = split(/ /,$link);
		if (defined($rightX{$from}) && defined($bottomX{$to})) {
#			&fly_line($outlink{$link},$rightX{$from},$rightY{$from},$bottomX{$to},$bottomY{$to},undef,undef,3);
			&fly_line($outlink{$link},$rightX{$from},$rightY{$from},$bottomX{$to},$bottomY{$to},undef,undef,$rightNr{$from});
			$linksumout += $outlink{$link};
			$rightTotal{$from} += $outlink{$link};
			$bottomTotal{$to} += $outlink{$link};
		}
	}
	$linksumin = 0;
	foreach $link (@intop) {
		($from,$to) = split(/ /,$link);
		if (defined($topX{$from}) && defined($rightX{$to})) {
#			&fly_line($inlink{$link},$topX{$from},$topY{$from},$rightX{$to},$rightY{$to},undef,undef,2);
			&fly_line($inlink{$link},$topX{$from},$topY{$from},$rightX{$to},$rightY{$to},undef,undef,$rightNr{$to});
			$linksumin += $inlink{$link};
			$topTotal{$from} += $inlink{$link};
			$rightTotal{$to} += $inlink{$link};
		}
	}

#
# Show Score
#

	foreach $node (keys %topX) {
		if (!defined($topTotal{$node})) {
			$topTotal{$node} = "-";
		}
		&fly_text(1,"($topTotal{$node})",$topX{$node},$topY{$node}+8,undef,undef,undef,"small");
	}

	foreach $node (keys %bottomX) {
		if (!defined($bottomTotal{$node})) {
			$bottomTotal{$node} = "-";
		}
		&fly_text(1,"($bottomTotal{$node})",$bottomX{$node},$bottomY{$node}-8,undef,undef,undef,"small");
	}

	foreach $node (keys %rightX) {
		if (!defined($rightTotal{$node})) {
			$rightTotal{$node} = "-";
		}
		&fly_text(3,"($rightTotal{$node})",$rightX{$node}-5,$rightY{$node},undef,undef,undef,"small");
	}

#
# Show Statistics
#
	$x = $imgwidth / 2;
	$y = 50;
	if (($linksumin > 0 || $linksumout > 0) && $rightsum > 0) {
		$pct = sprintf("%.1f", $rightsum / $transitstat[1] * 100.0);
		&fly_text(1,"These pages account for $pct % of all transits inside your website.",$x,$y,undef,undef,undef,"small");
		$pct = sprintf("%.1f", $linksumin / $rightsum * 100.0);
		&fly_text(1,"The incoming links represent $pct % of all links to these transit pages.",$x,$y+15,undef,undef,undef,"small");
		$pct = sprintf("%.1f", $linksumout / $rightsum * 100.0);
		&fly_text(1,"The outgoing links represent $pct % of all links from these transit pages.",$x,$y+30,undef,undef,undef,"small");
	}
	else {
		&fly_text(1,"These pages are not part of the Top Pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		&fly_text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	&close_fly($tmpfile,$imgfile{34});
	&make_map("34","Top Transit Pages",$imgwidth,$imgheight);
}

#
# End of reduced aWebVisit-Map
#
###########################################################################
#

