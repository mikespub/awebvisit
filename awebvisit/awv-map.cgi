#!/usr/local/bin/perl
#
# --> adapt according to your own path to perl5. Do NOT use option -w !
#
###########################################################################
#
# NAME
#
#	aWebVisit-Map Version 0.1.6c, 08/01/2002
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
#	This is a companion program for aWebVisit. It creates graphical maps
#	via CGI, showing the different links to and from a particular webpage.
#	Its input comes from the statistics file created by aWebVisit...
#
# EXAMPLES OF USE
#
#	From a browser, call 'http://my_server.com/my_cgi_dir/awv-map.cgi'
#	For testing, try running 'perl awv-map.cgi > awv-map.html'
#
# HISTORY
#
#	0.1.6c 08/01/2002 Now available under GNU GPL license
#
#	0.1.6 17/02/99	First public release
#
#	0.1.5 07/02/99	First alpha version
#
# FUTURE
#
#	This is probably as far as it goes, unless you send your suggestions
#	and wishes to (awebvisit@mikespub.net)...
#
###########################################################################
#
# CONFIGURATION FOR aWebVisit-Map
#
# The configuration is divided into 4 sections :
#
#	1. Global Settings
#	2. Statistics File from aWebVisit
#	3. Directories and Filenames
#	4. Web Map Configuration
#
# Hint:	you always need to check the first three sections !
#

#==========================================================================
#
# 1. Global Settings - YOU ALWAYS NEED TO CHECK THIS !!!
#
#==========================================================================

#=======
# 1.a.	Location of the FLY program for graphics - CAN'T WORK WITHOUT IT !!!
#	You can get pre-compiled binaries for Windows 95 & NT, various UNIXes,
#	and other platforms at http://www.unimelb.edu.au/fly/
#=======

$flyprog = '';
#$flyprog = '/usr/local/bin/fly';
#$flyprog = 'd:\\perl\\fly-1.6.0\\fly.exe';

#=======
# 1.b.	Exact URL of this CGI script
#=======

$cgiprog = 'awv-map.cgi';
#$cgiprog = '/cgi-bin/awv-map.cgi';
#$cgiprog = '/cgibin/awv-map.cgi';

#=======
# 1.c.	Exact URL of the aWebVisit reports (something like '<name>f.html')
#=======

$awvreports = '';
#$awvreports = 'awebvisitf.html';
#$awvreports = '/awv/awebvisitf.html';

#==========================================================================
#
# 2. Statistics File from aWebVisit - YOU ALWAYS NEED TO CHECK THIS !!!
#
#==========================================================================

#=======
# 2.a.	Location of the aWebVisit statistics file - specify the full path !
#	- use the same name as aWebVisit !
#=======

$statfile = './awebvisit.stat';
#$statfile = '../webpages/awv/awebvisit.stat';
#$statfile = '../docs/awv/awebvisit.stat';

#=======
# 2.b.	Delimiter for the statistics file - usually a tab is safest
#	- change only if you changed it in aWebVisit
#=======

$delim = "\t";
#$delim = "|";

#==========================================================================
#
# 3. Directories and Filenames - YOU ALWAYS NEED TO CHECK THIS !!!
#
#==========================================================================

#=======
# 3.a.	Image directory - make sure aWebVisit-Map can create files in it !
#	- change this to a physical directory containing your web images.
#=======

$imagedir = '.';
#$imagedir = '../webpages/img';
#$imagedir = '../docs/awv';

#=======
# 3.b.	Image web reference - blank means in the same directory as the CGI.
#	- change this to the web directory (URL) containing your web images.
#=======

$imageref = '';
#$imageref = '/img';
#$imageref = '/awv';

#=======
# 3.c.	Output filenames
#	The script generates images with the following names : <name>n_nnn.gif
#	- change this if these names already appear in the image directory.
#=======

$name = "awvm";
#$name = "awv_";

#=======
# 3.d.	Temporary directory
#	- change this to a physical directory where a CGI script can create
#	files.
#=======

$tmpdir = '.';
#$tmpdir = '/tmp';

#=======
# 3.e.	Keep images that were already created by previous queries
#	- change this if you want to re-create the images each time
#=======

$keepimages = 1;
#$keepimages = 0;

# Note:	If you select this option, don't forget to delete all map images
#	whenever you run aWebVisit again !
#	Otherwise, aWebVisit-Map will TRY to do it for you... :-O

#==========================================================================
#
# 4. Web Map Configuration - YOU CAN LIVE WITHOUT THIS...
#
#==========================================================================

#=======
# 4.a.	HTML Background Color
#	- change this to your favorite background color
#=======

$bgcolor = "#FFEEDD";
#$bgcolor = "#A0E0FF";

#=======
# 4.b.	Indicate whether this is a 'big' site, so that we need to
#	limit the number of entry, transit and exit pages shown
#	in each page map
#=======

$bigsite = 1;
#$bigsite = 0;

#=======
# 4.c.	Number of entry pages to be shown in the overview maps
#	- if bigsite is 1, also used in the different page maps
#=======

$topentries = 7;
#$topentries = 10;

#=======
# 4.d.	Number of transit pages to be shown in the overview maps
#	- if bigsite is 1, also used in the different page maps
#=======

$toptransits = 12;
#$toptransits = 15;

#=======
# 4.e.	Number of exit pages to be shown in the overview maps
#	- if bigsite is 1, also used in the different page maps
#=======

$topexits = 7;
#$topexits = 10;

#
# END OF CONFIGURATION FOR aWebVisit-Map
#
###########################################################################

# Do not change anything below this line unless you have taken a back-up...

###########################################################################
#
# Analyse request from browser
#

$timestamp = localtime(time);

&ReadParse();

###########################################################################
#
# Start output to browser
#

# two new-lines needed here !!!
print "Content-type: text/html\n\n";

$|=1;

###########################################################################
#
# Check whether aWebVisit-Map can work with the current configuration
#

if (defined($flyprog) && $flyprog ne "") {
	if (!-x $flyprog) {
		&cleanup("The <I>fly</I> program '$flyprog' does not exist or is not executable !\nCheck the '\$flyprog' variable in the aWebVisit-Map configuration.\n");
	}
	&init_maps();
}
else {
	&cleanup("Please specify the location of the <I>fly</I> program for aWebVisit-Map.\nCheck the '\$flyprog' variable in the aWebVisit-Map configuration.\n");
}

if (!defined($cgiprog) || $cgiprog eq "") {
	&cleanup("Please specify the URL of this CGI script before continuing.\nCheck the '\$cgiprog' variable in the aWebVisit-Map configuration.\n");
}

if (defined($statfile) && $statfile ne "") {
	if (!-f $statfile) {
		&cleanup("The statistics file '$statfile' from aWebVisit does not exist !\nMake sure you run aWebVisit first (in command line), and then check the '\$statfile' variable in the aWebVisit-Map configuration.\n");
	}
}
else {
	&cleanup("Please specify a statistics file '\$statfile' for aWebVisit-Map.\nMake sure you run aWebVisit first (in command line), and then check the '\$statfile' variable in the aWebVisit-Map configuration.\n");
}

if (defined($imagedir) && $imagedir ne "") {
	if (!-d $imagedir) {
		&cleanup("The image directory '$imagedir' does not exist !\nCheck the '\$imagedir' variable in the aWebVisit-Map configuration.\n");
	}
}
else {
	&cleanup("Please specify an image directory '\$imagedir' for aWebVisit-Map.\nUsing an empty directory is not allowed...\n");
}

if (defined($tmpdir) && $tmpdir ne "") {
	if (!-d $tmpdir) {
		&cleanup("The temporary directory '$tmpdir' does not exist !\nCheck the '\$tmpdir' variable in the aWebVisit-Map configuration.\n");
	}
}
else {
	&cleanup("Please specify a temporary directory '\$tmpdir' for aWebVisit-Map.\nUsing an empty directory is not allowed...\n");
}

###########################################################################
#
# Get the URL
#

if (defined($in{url}) && $in{url} ne "" && defined($nrpage[$in{url}])) {
	$url = $nrpage[$in{url}];
}
else {
	$url = "[ Page ]";
	$pageurl{$url} = "Page";
	$entryurl{$url} = "Entry";
	$transiturl{$url} = "Transit";
	$exiturl{$url} = "Exit";
	$hitrunurl{$url} = "Hit&Run";
	$timeval{$url} = "Time Spent";

	$pagenr{$url} = "n";
}

###########################################################################
#
# Get the format
#

if (defined($in{f})) {
	$format = $in{f};
}
else {
	$format = "";
}

###########################################################################
#
# Fill in some default values if needed
#

if (!defined($pageurl{$url})) {
	$pageurl{$url} = "<= " . $pageurl{$pagetop[$#pagetop]};
}
if (!defined($entryurl{$url})) {
	$entryurl{$url} = "<= " . $entryurl{$entrytop[$#entrytop]};
}
if (!defined($transiturl{$url})) {
	$transiturl{$url} = "<= " . $transiturl{$transittop[$#transittop]};
}
if (!defined($exiturl{$url})) {
	$exiturl{$url} = "<= " . $exiturl{$exittop[$#exittop]};
}
if (!defined($hitrunurl{$url})) {
	$hitrunurl{$url} = "<= " . $hitrunurl{$hitruntop[$#hitruntop]};
}

###########################################################################
#
# Define some files and references
#

$imgfile = $imagedir . "/" . $name . $format . "_" . $pagenr{$url} . ".gif";
if (!defined($imageref) || $imageref eq "") {
	$imgref = $name . $format . "_" . $pagenr{$url} . ".gif";
}
else {
	$imgref = $imageref . "/" . $name . $format . "_" . $pagenr{$url} . ".gif";
}
$tmpfile = $tmpdir . "/tmpfly.$$";

###########################################################################
#
# Do what the client asks
#

if ($url eq "[ Page ]") {
	&make_hello() if $format eq "";
# reset url value for button links
	$url = "";
	&make_topentry() if $format == 2;
	&make_topexit() if $format == 3;
	&make_toptransit() if $format == 4;
	&make_tophitrun() if $format == 5;
	&make_toppage() if $format == 0;
	&make_topdetail() if $format == 1;
}
else {
	&make_any() if $format == 0;
	&make_detail() if $format == 1;
	&make_entry() if $format == 2;
	&make_exit() if $format == 3;
	&make_transit() if $format == 4;
}

###########################################################################
#
# That's all, folks !
#

exit;

###########################################################################
#
# Parse the URL
#

# Warning : version adapted for command-line tests !

sub ReadParse {
	if (@_) {
		local (*in) = @_;
	}

	local ($i, $loc, $key, $val, $null);

	# Read in text
	if ($ENV{'REQUEST_METHOD'} eq "GET") {
		$in = $ENV{'QUERY_STRING'};
		$method = "GET";
	}
	elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
		for ($i = 0; $i < $ENV{'CONTENT_LENGTH'}; $i++) {
			$in .= getc;
		}
		$method = "POST";
	}
	elsif ($ENV{'REQUEST_METHOD'} eq "") { # for off-line testing...
		$in = $ARGV[0];
	}

	@in = split(/&/,$in);

	# use this for multiple fields (see below)
	$null = "\000";

	foreach $i (0 .. $#in) {
	# Convert plus's to spaces
		$in[$i] =~ s/\+/ /g;

	# Convert %XX from hex numbers to alphanumeric
		$in[$i] =~ s/%(..)/pack("c",hex($1))/ge;

	# Split into key and value.;
		$loc = index($in[$i],"=");
		$key = substr($in[$i],0,$loc);
		$val = substr($in[$i],$loc+1);
		$in{$key} .= $null if (defined($in{$key})); # \0 is the multiple separator
		$in{$key} .= $val;
	}

	return 1; # just for fun
}

###########################################################################
#
# Error recovery
#

sub cleanup {
	my($text) = @_;

	print "<HTML>\n";
	print "<HEAD>\n";
	print "<TITLE>\n";
	print "	aWebVisit-Map - Configuration Warning\n";
	print "</TITLE>\n";
	print "</HEAD>\n";

	print "<BODY BGCOLOR=\"$bgcolor\">\n";
	print "<H1>Configuration Warning</H1>\n";

	print "<PRE>\n";
	print "$text\n";
	print "</PRE>\n";

	print "<P>\n";
	print "<HR>Created with <A HREF=\"http://mikespub.net/tools/aWebVisit/\" TARGET=\"_top\">aWebVisit-Map 0.1.6</A> on $timestamp\n";
	print "</BODY>\n";
	print "</HTML>\n";
	exit;
}

###########################################################################
#
# Initialise aWebVisit-Map
#

sub init_maps {

	#
	# Read aWebVisit statistics file
	#

	&read_stats();

	#
	# Initialise fly variables
	#

	&init_fly();
}

###########################################################################
#
# Read aWebVisit statistics file
#

sub read_stats {
	open(FILE,"<$statfile") || &cleanup("Can't open statistics file '$statfile' from aWebVisit !\nCheck its access rights and those of this CGI script.\n");
	$dowhat = 0;
	$urlnr = 1;
	while (<FILE>) {
		chomp;
		if (/^$/) {
			next;
		}
		if (/^Logfile/) {
			($dummy,$startdate,$enddate,@rest) = split(/$delim/o);
			next;
		}
		if (/^Pages/) {
			($dummy,@pagestat) = split(/$delim/o);
			$dowhat = 1;
			next;
		}
		if (/^Entries/) {
			($dummy,@entrystat) = split(/$delim/o);
			$dowhat = 2;
			next;
		}
		if (/^Transits/) {
			($dummy,@transitstat) = split(/$delim/o);
			$dowhat = 3;
			next;
		}
		if (/^Exits/) {
			($dummy,@exitstat) = split(/$delim/o);
			$dowhat = 4;
			next;
		}
		if (/^Hit&Runs/) {
			($dummy,@hitrunstat) = split(/$delim/o);
			$dowhat = 5;
			next;
		}
		if (/^Links/) {
			($dummy,@linkstat) = split(/$delim/o);
			$dowhat = 6;
			next;
		}
		if (/^Incoming/) {
			($dummy,@instat) = split(/$delim/o);
			$dowhat = 7;
			next;
		}
		if (/^Internal/) {
			($dummy,@internstat) = split(/$delim/o);
			$dowhat = 8;
			next;
		}
		if (/^Outgoing/) {
			($dummy,@outstat) = split(/$delim/o);
			$dowhat = 9;
			next;
		}
		if (/^In&Out/) {
			($dummy,@inoutstat) = split(/$delim/o);
			$dowhat = 10;
			next;
		}
		if (/^Time/) {
			($dummy,@timestat) = split(/$delim/o);
			$dowhat = 11;
			next;
		}
		if ($dowhat == 1) {
			($key,$val,$time) = split(/$delim/o);
			push( @pagetop , $key );
			$pageurl{$key} = $val;
			$timeval{$key} = $time;
			if(!defined($pagenr{$key})) {
				$pagenr{$key} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 2) {
			($key,$val,$time) = split(/$delim/o);
			push( @entrytop , $key );
			$entryurl{$key} = $val;
			$timeval{$key} = $time;
			if(!defined($pagenr{$key})) {
				$pagenr{$key} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 3) {
			($key,$val,$time) = split(/$delim/o);
			push( @transittop , $key );
			$transiturl{$key} = $val;
			$timeval{$key} = $time;
			if(!defined($pagenr{$key})) {
				$pagenr{$key} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 4) {
			($key,$val,$time) = split(/$delim/o);
			push( @exittop , $key );
			$exiturl{$key} = $val;
			$timeval{$key} = $time;
			if(!defined($pagenr{$key})) {
				$pagenr{$key} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 5) {
			($key,$val,$time) = split(/$delim/o);
			push( @hitruntop , $key );
			$hitrunurl{$key} = $val;
			$timeval{$key} = $time;
			if(!defined($pagenr{$key})) {
				$pagenr{$key} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 6) {
			($from,$to,$val,$fromval,$toval) = split(/$delim/o);
			$key = "$from $to";
			push( @linktop , $key );
			$totlink{$key} = $val;
			if(!defined($pageurl{$from})) {
				$pageurl{$from} = $fromval;
			}
			if(!defined($pageurl{$to})) {
				$pageurl{$to} = $toval;
			}
			if(!defined($pagenr{$from})) {
				$pagenr{$from} = $urlnr;
				$urlnr++;
			}
			if(!defined($pagenr{$to})) {
				$pagenr{$to} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 7) {
			($from,$to,$val,$fromval,$toval) = split(/$delim/o);
			$key = "$from $to";
			push( @intop , $key );
			$inlink{$key} = $val;
			if(!defined($entryurl{$from})) {
				$entryurl{$from} = $fromval;
			}
			if(!defined($transiturl{$to})) {
				$transiturl{$to} = $toval;
			}
			if(!defined($pagenr{$from})) {
				$pagenr{$from} = $urlnr;
				$urlnr++;
			}
			if(!defined($pagenr{$to})) {
				$pagenr{$to} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 8) {
			($from,$to,$val,$fromval,$toval) = split(/$delim/o);
			$key = "$from $to";
			push( @interntop , $key );
			$internlink{$key} = $val;
			if(!defined($transiturl{$from})) {
				$transiturl{$from} = $fromval;
			}
			if(!defined($transiturl{$to})) {
				$transiturl{$to} = $toval;
			}
			if(!defined($pagenr{$from})) {
				$pagenr{$from} = $urlnr;
				$urlnr++;
			}
			if(!defined($pagenr{$to})) {
				$pagenr{$to} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 9) {
			($from,$to,$val,$fromval,$toval) = split(/$delim/o);
			$key = "$from $to";
			push( @outtop , $key );
			$outlink{$key} = $val;
			if(!defined($transiturl{$from})) {
				$transiturl{$from} = $fromval;
			}
			if(!defined($exiturl{$to})) {
				$exiturl{$to} = $toval;
			}
			if(!defined($pagenr{$from})) {
				$pagenr{$from} = $urlnr;
				$urlnr++;
			}
			if(!defined($pagenr{$to})) {
				$pagenr{$to} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 10) {
			($from,$to,$val,$fromval,$toval) = split(/$delim/o);
			$key = "$from $to";
			push( @inouttop , $key );
			$inoutlink{$key} = $val;
			if(!defined($entryurl{$from})) {
				$entryurl{$from} = $fromval;
			}
			if(!defined($exiturl{$to})) {
				$exiturl{$to} = $toval;
			}
			if(!defined($pagenr{$from})) {
				$pagenr{$from} = $urlnr;
				$urlnr++;
			}
			if(!defined($pagenr{$to})) {
				$pagenr{$to} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 11) {
			($key,$val,$time) = split(/$delim/o);
			push( @timetop , $key );
			$timeval{$key} = $time;
# Do not keep these pages as potential candidates for maps !
#			if(!defined($pagenr{$key})) {
#				$pagenr{$key} = $urlnr;
#				$urlnr++;
#			}
			next;
		}
	}
	close(FILE);

	while (($key,$val) = each %pagenr) {
		$nrpage[$val] = $key;
	}

	$urlnr--;
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

#
# Map dimension defaults :
#
# |----------------------------------------------------------------------------------------------------------------|
# |                                                                                                                |
# | --- mapxleft ---> |                                                                       | <--- mapxright --- |
# |                   | <----------- mapxmid ------------ | ------------ mapxmid -----------> |                    |
# |                   | <- mapxsep -- | <- mapxdiff -> | ... | <- mapxdiff -> | -- mapxsep -> |                    |
# |                                                                                                                |
# |----------------------------------------------------------------------------------------------------------------|
#
#	$mapxleft = 200;
#	$mapxright = 200;
#	$mapxmid = 200;
#	$mapxsep = 60;
#	$mapxdiff = 70;
}

sub open_fly {
	my($infile,$width,$height) = @_;

	open(FLY,"> $infile") || &cleanup("Can't create temporary file '$infile'\nCheck the access rights of this CGI script to directory '$tmpdir'.\n");
	print FLY "new\n";
	print FLY "size $width,$height\n";
	print FLY "fill 1,1,203,255,255\n";

	@maps = ();
}

sub close_fly {
	my($infile,$outfile) = @_;

	close(FLY);

	if ($keepimages != 1 || !-f $outfile) {
		system("$flyprog -q -i $infile -o $outfile");
	}

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

###########################################################################
#
# Routines for creating the output files
#

#
# Routines for creating companion HTML pages and image maps
#

sub add_imgmap {
	my($width,$height) = @_;
	my($i,$j,$k);

	print "<CENTER>\n";
	print "<IMG SRC=\"$imgref\" USEMAP=\"#awvmap\" BORDER=\"0\" WIDTH=\"$width\" HEIGHT=\"$height\">\n";
	print "<MAP NAME=\"awvmap\">\n";
	for $i (0 .. $#maps) {
		if (substr($maps[$i][0],0,7) eq "http://") {
			print "<AREA HREF=\"$maps[$i][0]\" ALT=\"$maps[$i][1]\" SHAPE=\"$maps[$i][2]\" COORDS=\"";
		}
		else {
			print "<AREA HREF=\"$cgiprog?url=$maps[$i][0]\" ALT=\"$maps[$i][1]\" SHAPE=\"$maps[$i][2]\" COORDS=\"";
		}
		if ($#{$maps[$i]} > 2) {
			for $j (3 .. $#{$maps[$i]}) {
				$k = int($maps[$i][$j]);
				print "$k,";
			}
		}
		print "\">\n";
	}
	print "</MAP>\n";
	print "</CENTER>\n";
	print "<P>\n";
}

sub make_map {
	my($title,$width,$height) = @_;

	print "<HTML>\n";
	print "<HEAD>\n";
	print "<TITLE>\n";
	print "	aWebVisit-Map - $title (from $startdate to $enddate)\n";
	print "</TITLE>\n";
	print "</HEAD>\n";

	print "<BODY BGCOLOR=\"$bgcolor\">\n";

	&add_imgmap($width,$height);

	print "<P>\n";
#	print "<HR>Created with <A HREF=\"http://mikespub.net/tools/aWebVisit/\" TARGET=\"_top\">aWebVisit-Map 0.1.6</A> on $timestamp\n";
	print "</BODY>\n";
	print "</HTML>\n";
}

sub make_nodeimg {
	my($width,$height) = @_;

	&open_fly($tmpfile,$width,$height);
	&make_nodes(\@nodes);
	&make_links(\@nodes,\@links);
	&close_fly($tmpfile,$imgfile);
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
# Show Page on Map
#

sub map_page {
	my($dir) = @_;

# keep these values !
	($leftx,$topy,$rightx,$bottomy) = &fly_box($dir,$url,"",$x,$y,"$pagenr{$url}&f=0");

	$midx = int(($leftx + $rightx) / 2);
	$midy = int(($topy + $bottomy) / 2);

	&fly_line($entryurl{$url},$midx,$topy-40,$midx,$topy,"$pagenr{$url}&f=2",undef,2);
	&fly_line("",$midx-4,$topy-5,$midx,$topy,undef,undef,2);
	&fly_line("",$midx+4,$topy-5,$midx,$topy,undef,undef,2);

	&fly_line($hitrunurl{$url},$leftx-40,$topy-40,$leftx,$topy,undef,undef,7);
	&fly_line("",$leftx-40,$topy-40+5,$leftx-40,$topy-40,undef,undef,7);
	&fly_line("",$leftx-40+4,$topy-40,$leftx-40,$topy-40,undef,undef,7);
	&fly_line("",$leftx,$topy-5,$leftx,$topy,undef,undef,7);
	&fly_line("",$leftx-4,$topy,$leftx,$topy,undef,undef,7);

	&fly_line($transiturl{$url},$leftx,$bottomy+10,$rightx,$bottomy+10,"$pagenr{$url}&f=4",undef,1);
	&fly_line("",$leftx+5,$bottomy+10-3,$leftx,$bottomy+10,undef,undef,1);
	&fly_line("",$leftx+5,$bottomy+10+3,$leftx,$bottomy+10,undef,undef,1);
	&fly_line("",$rightx-5,$bottomy+10-3,$rightx,$bottomy+10,undef,undef,1);
	&fly_line("",$rightx-5,$bottomy+10+3,$rightx,$bottomy+10,undef,undef,1);

	&fly_line($exiturl{$url},$midx,$bottomy+15,$midx,$bottomy+55,"$pagenr{$url}&f=3",undef,3);
	&fly_line("",$midx-4,$bottomy+50,$midx,$bottomy+55,undef,undef,3);
	&fly_line("",$midx+4,$bottomy+50,$midx,$bottomy+55,undef,undef,3);

	&fly_text(2,$timeval{$url},$rightx + 5,$topy+4,undef,undef,undef,"small");
}

#
# Show Buttons on Map
#

sub map_buttons {
	my($type) = @_;
	my($x, $y);

	$x = $midx - 120;
	$y = 20;
	&fly_box(7,"Summary","",$x,$y,"$pagenr{$url}&f=0");
	$y = $imgheight - 20;
	&fly_box(7,"Summary","",$x,$y,"$pagenr{$url}&f=0");

	$x = $midx - 60;
	$y = 20;
	&fly_box(7," Entry ","",$x,$y,"$pagenr{$url}&f=2");
	$y = $imgheight - 20;
	&fly_box(7," Entry ","",$x,$y,"$pagenr{$url}&f=2");

	$x = $midx;
	$y = 20;
	&fly_box(7,"Transit","",$x,$y,"$pagenr{$url}&f=4");
	$y = $imgheight - 20;
	&fly_box(7,"Transit","",$x,$y,"$pagenr{$url}&f=4");

	$x = $midx + 60;
	$y = 20;
	&fly_box(7,"  Exit ","",$x,$y,"$pagenr{$url}&f=3");
	$y = $imgheight - 20;
	&fly_box(7,"  Exit ","",$x,$y,"$pagenr{$url}&f=3");

	$x = $midx + 120;
	$y = 20;
	&fly_box(7,"Details","",$x,$y,"$pagenr{$url}&f=1");
	$y = $imgheight - 20;
	&fly_box(7,"Details","",$x,$y,"$pagenr{$url}&f=1");

	$x = $midx + 180;
	$y = 20;
	&fly_box(7,"  Top  ","",$x,$y,"&f=$type");
	$y = $imgheight - 20;
	&fly_box(7,"  Top  ","",$x,$y,"&f=$type");
}

#
# Make Welcome page
#

sub make_hello {

#
# Check the age of the images vs. the age of the statistics file 
#

	if ($keepimages == 1 && -f $imgfile) {
		if (-M $statfile < -M $imgfile) {
			chdir($imagedir);
			opendir(DIR,".");
			@filelist = readdir(DIR);
			closedir(DIR);
			foreach $file (@filelist) {
				if (-f $file && $file =~ /^$name.*\.gif$/) {
					unlink($file);
				}
			}
			&cleanup("aWebVisit-Map is configured to keep existing images, but the statistics file '$statfile'\ncreated by aWebVisit is more recent than the image '$imgfile'.\n\nMake sure you delete ALL the aWebVisit-Map images from '$imagedir' the next time you run aWebVisit !\n");
			exit;
		}
	}

#
# Make short description of maps
#

	$imgwidth = 760;
	$imgheight = 330;
	&open_fly($tmpfile,$imgwidth,$imgheight);

#
# Show Title
#
	&map_title("Brief Overview of the Maps");

#
# Show Page
#
	$x = $imgwidth / 2;
	$y = 160;
	&map_page(0);

	$x = $midx;
	$y = 80;
	&fly_text(1,"The selected page will be shown with its different hit counts.",$x,$y,undef,undef,undef,"small");
	&fly_text(1,"You can then click on one of the arrows to go to the corresponding map.",$x,$y+15,undef,undef,undef,"small");

	$x = 160;
	$y = $midy - 30;
	&fly_box(4,"From Page 1",123,$x,$y,"",undef,3,1);
	&fly_line("Link 1",$x,$y,$leftx,$midy,undef,undef,1);

	$y = $midy + 30;
	&fly_box(4,"From Page 2",456,$x,$y,"",undef,3,1);
	&fly_line("Link 2",$x,$y,$leftx,$midy,undef,undef,1);

	$x += 50;
	$y = $midy;
	&fly_text(3,"Click on a page to go there",$x,$y,undef,undef,undef,"small");

	$x = $imgwidth - 270;
	$y = 125;
	&fly_text(2,"The different link types are identified",$x,$y,undef,undef,undef,"small");
	$y += 15;
	&fly_text(2,"by color :",$x,$y,undef,undef,undef,"small");
	$y += 15;
	&fly_text(2,"- Incoming Link",$x,$y,undef,undef,undef,"small");
	&fly_line("Link Count",$imgwidth - 160,$y,$imgwidth - 50,$y,undef,undef,2);
	$y += 15;
	&fly_text(2,"- Internal Link",$x,$y,undef,undef,undef,"small");
	&fly_line("Link Count",$imgwidth - 160,$y,$imgwidth - 50,$y,undef,undef,1);
	$y += 15;
	&fly_text(2,"- Outgoing Link",$x,$y,undef,undef,undef,"small");
	&fly_line("Link Count",$imgwidth - 160,$y,$imgwidth - 50,$y,undef,undef,3);
	$y += 15;
	&fly_text(2,"- In&Out Link",$x,$y,undef,undef,undef,"small");
	&fly_line("Link Count",$imgwidth - 160,$y,$imgwidth - 50,$y,undef,undef,4);
	$y += 15;
	&fly_text(2,"- All Links",$x,$y,undef,undef,undef,"small");
	&fly_line("Link Count",$imgwidth - 160,$y,$imgwidth - 50,$y,undef,undef,0);

#
# Show Buttons
#
	&map_buttons();
	
	$x = $imgwidth - 150;
	$y = 20;
	&fly_text(2,"try these 'buttons'",$x,$y,undef,undef,undef,"small");
	&fly_line("or",$imgwidth - 165,95,$imgwidth - 130,30,undef,undef,0);

#
# Show Statistics
#

	$x = $imgwidth / 2;
	$y = $imgheight - 80;
	&fly_text(1,"If the page in question is in the Top N pages as discovered by aWebVisit,",$x,$y,undef,undef,undef,"small");
	&fly_text(1,"some statistics will appear here. If it isn't, you may want to run",$x,$y+15,undef,undef,undef,"small");
	&fly_text(1,"aWebVisit again with a higher value for the \$toppages variable.",$x,$y+30,undef,undef,undef,"small");

	&close_fly($tmpfile,$imgfile);

	$oldfile = $imgfile;
	$oldref = $imgref;
	$oldwidth = $imgwidth;
	$oldheight = $imgheight;

#
# Make overview diagram
#

	@nodes = (
		[ "Entry"	, 160	, 80	, "&f=2"	], # node 0
		[ "Transit"	, 260	, 180	, "&f=4"	], # node 1
		[ "Exit"	, 160	, 280	, "&f=3"	], # node 2
		[ "Hit&Run"	, 60	, 80	, "&f=5"	], # node 3
	);

	@links = (
		[$entrystat[1]	, ""	, 0	, "&f=2"	, undef	, 2],
		[$instat[1]	, 0	, 1	, undef		, undef	, 2],
		[$internstat[1]	, 1	, 1	, "&f=4"	, undef	, 1],
		[$outstat[1]	, 1	, 2	, undef		, undef	, 3],
		[$inoutstat[1]	, 0	, 2	, undef		, undef	, 4],
		[$exitstat[1]	, 2	, ""	, "&f=3"	, undef	, 3],
		[$hitrunstat[1]	, ""	, 3	, "&f=5"	, undef	, 7],
	);

	$imgwidth = 400;
	$imgheight = 360;

	$imgfile =~ s/_n/_o/;
	$imgref =~ s/_n/_o/;
	&make_nodeimg($imgwidth,$imgheight);
	push( @maps , [ "&f=0", "", "default" ] );

#
# Make page
#

	print "<HTML>\n";
	print "<HEAD>\n";
	print "<TITLE>\n";
	print "	aWebVisit-Map - Welcome\n";
	print "</TITLE>\n";
	print "</HEAD>\n";

	print "<BODY BGCOLOR=\"$bgcolor\">\n";
	print "<H1>aWebVisit-Map - Welcome</H1>\n";
	print "(from $startdate to $enddate)<HR>\n";

	print "<H2>1. Introduction</H2>\n";
	print "This program allows you to examine the most frequently visited <B>web pages</B> on your website,\n";
	print "see <B>how visitors arrive</B> at each page, and <B>where they go</B> after each page.\n";
	print "It relies on page and link statistics generated by\n";
	if ($awvreports ne "") {
		print "<A HREF=\"$awvreports\">aWebVisit</A>\n";
	}
	else {
		print "<A HREF=\"http://mikespub.net/tools/aWebVisit/\">aWebVisit</A>\n";
	}
	print "from the access logfiles of this website.\n";

	print "<H2>2. Overview Maps</H2>\n";
	print "To get an idea of the <B>overall traffic flow</B> through your website, select one of the following overview maps.\n";
	print "You can then <B>click on one of the pages</B> to get more details on the links to and from that page.<P>\n";
	print "<TABLE BORDER=\"0\" CELLPADDING=\"5\" CELLSPACING=\"0\"><TR><TD>\n";
	&add_imgmap($imgwidth,$imgheight);
	print "</TD><TD VALIGN=\"top\">\n";
	print "<UL>\n";
	print "<LI>Top <A HREF=\"$cgiprog?f=2\">entry points</A> to your website\n";
	print "<LI>Top <A HREF=\"$cgiprog?f=4\">transit points</A> inside your website\n";
	print "<LI>Top <A HREF=\"$cgiprog?f=3\">exit points</A> from your website\n";
	print "<LI>Top <A HREF=\"$cgiprog?f=5\">hit&amp;run pages</A> on your website\n";
	print "<LI>Top <A HREF=\"$cgiprog?f=0\">pages overall</A> on your website\n";
	print "</UL>\n";
	print "</TD></TR></TABLE>\n";

	$imgwidth = $oldwidth;
	$imgheight = $oldheight;
	$imgfile = $oldfile;
	$imgref = $oldref;

	print "<H2>3. Search by Web Page</H2>\n";
	print "<FORM ACTION=\"$cgiprog\" METHOD=\"POST\">\n";
	print "If you want to examine the links to and from <B>a particular web page</B> in more detail, select one of the $urlnr pages available here :<P>\n";
	print "<SELECT NAME=\"url\">\n";
	$i = 0;
	foreach $page (sort keys %pagenr) {
		print "<OPTION VALUE=\"$pagenr{$page}\">$page\n";
		$i++;
		if ($bigsite == 1 && $i > 1500) {
			print "<OPTION VALUE=\"\">...too many to show here.\n";
			last;
		}
	}
	print "</SELECT><P>\n";
	print "And then select one of the following map types :<P>\n";
	print "<INPUT TYPE=radio NAME=f VALUE=0 CHECKED>Summary Map = all links from and to any page<BR>\n";
	print "<INPUT TYPE=radio NAME=f VALUE=2>Entry Map = all links from an entry page<BR>\n";
	print "<INPUT TYPE=radio NAME=f VALUE=4>Transit Map = all links from and to a transit page<BR>\n";
	print "<INPUT TYPE=radio NAME=f VALUE=3>Exit Map = all links to an exit page<BR>\n";
	print "<INPUT TYPE=radio NAME=f VALUE=1>Detailed Map = all links from and to any page, split by link type<P>\n";
	print "<INPUT TYPE=submit VALUE=\"Show it now\">&nbsp;&nbsp;\n";
	print "<INPUT TYPE=reset VALUE=\"Clear the form\">\n";
	print "</FORM>\n";

	print "<H2>4. Description of the Page Maps</H2>\n";
	print "<IMG SRC=\"$imgref\" BORDER=\"0\" WIDTH=\"$imgwidth\" HEIGHT=\"$imgheight\">\n";
	print "<HR>Created with <A HREF=\"http://mikespub.net/tools/aWebVisit/\" TARGET=\"_top\">aWebVisit-Map 0.1.6</A> on $timestamp\n";
	print "<A NAME=\"bottom\"> </A>\n";
	print "</BODY>\n";
	print "</HTML>\n";
	exit;
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
# TOP PAGES
#

sub make_toppage {

#
# Get values
#
	foreach $node (&sort_by_topurl(\@pagetop,\%pageurl)) {
		$topnode{$node} = $pageurl{$node};
	} 

	$topcount = keys %topnode;

	if ($topcount > $toptransits) {
		$topcount = $toptransits;
	}

#
# Determine image size
#
	$imgwidth = 100;
	$imgwidth += $topcount * 100;
	if ($imgwidth < 760) {
		$imgwidth = 760;
	}

	$height = &check_nodeheight(\%topnode,\%pageurl,$topcount,140);
	$imgheight = 100 + $height + 100;
	&open_fly($tmpfile,$imgwidth,$imgheight);

#
# Show Title
#
	&map_title("Top Pages Overall");

#
# Show Buttons
#
	$midx = $imgwidth / 2;
	&map_buttons("");

#
# PAGES
#

	$x = 90;
#	$y = 170;
	$y = 100 + $height / 2;
	$topsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%topnode,\%pageurl)) {
		if ($i >= $topcount) {
			last;
		}
# trick : use map_page routine
		$url = $node;
		&map_page(0);
		if (substr($pageurl{$node},0,1) ne "<") {
			$topsum += $pageurl{$node};
		}
		$x += 100;
		$i++;
	}

#
# Show Statistics
#
	$x = $imgwidth / 2;
	$y = 50;
	if ($topsum > 0) {
		$pct = sprintf("%.1f", $topsum / $pagestat[1] * 100.0);
		&fly_text(1,"These pages account for $pct % of all hits on your website.",$x,$y,undef,undef,undef,"small");
	}
	else {
		&fly_text(1,"These pages are not part of the Top Pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		&fly_text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	&close_fly($tmpfile,$imgfile);
	&make_map("Top Pages Overall",$imgwidth,$imgheight);

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
	$midx = $imgwidth / 2;
	&map_buttons("");

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
		&fly_box(1,$node,$entryurl{$node},$x,$y,"$pagenr{$node}&f=2",undef,1,2);
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
		&fly_box(2,$node,$exiturl{$node},$x,$y,"$pagenr{$node}&f=3",undef,2,3);
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
		&fly_box(3,$node,$transiturl{$node},$x,$y,"$pagenr{$node}&f=4",undef,3,1);
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
	&close_fly($tmpfile,$imgfile);
	&make_map("Top Entry Pages",$imgwidth,$imgheight);

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
	$midx = $imgwidth / 2;
	&map_buttons("");

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
		&fly_box(1,$node,$entryurl{$node},$x,$y,"$pagenr{$node}&f=2",undef,1,2);
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
		&fly_box(2,$node,$exiturl{$node},$x,$y,"$pagenr{$node}&f=3",undef,2,3);
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
		&fly_box(3,$node,$transiturl{$node},$x,$y,"$pagenr{$node}&f=4",undef,3,1);
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
	&close_fly($tmpfile,$imgfile);
	&make_map("Top Exit Pages",$imgwidth,$imgheight);

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
	$midx = $imgwidth / 2;
	&map_buttons("");

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
		&fly_box(1,$node,$entryurl{$node},$x,$y,"$pagenr{$node}&f=2",undef,1,2);
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
		&fly_box(2,$node,$exiturl{$node},$x,$y,"$pagenr{$node}&f=3",undef,2,3);
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
		&fly_box(3,$node,$transiturl{$node},$x,$y,"$pagenr{$node}&f=4",undef,3,1);
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
	&close_fly($tmpfile,$imgfile);
	&make_map("Top Transit Pages",$imgwidth,$imgheight);

}

#
# TOP HIT&RUNS
#

sub make_tophitrun {

#
# Get values
#
	foreach $node (&sort_by_topurl(\@hitruntop,\%hitrunurl)) {
		$topnode{$node} = $hitrunurl{$node};
	} 

	$topcount = keys %topnode;

	if ($topcount > $toptransits) {
		$topcount = $toptransits;
	}

#
# Determine image size
#
	$imgwidth = 100;
	$imgwidth += $topcount * 100;
	if ($imgwidth < 760) {
		$imgwidth = 760;
	}

	$height = &check_nodeheight(\%topnode,\%hitrunurl,$topcount,140);
	$imgheight = 100 + $height + 100;
	&open_fly($tmpfile,$imgwidth,$imgheight);

#
# Show Title
#
	&map_title("Top Hit&Run Pages");

#
# Show Buttons
#
	$midx = $imgwidth / 2;
	&map_buttons("");

#
# HIT&RUN
#

	$x = 90;
#	$y = 190;
	$y = 100 + $height / 2;
	$topsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%topnode,\%hitrunurl)) {
		if ($i >= $topcount) {
			last;
		}
# trick : use map_page routine
		$url = $node;
		&map_page(1);
		if (substr($hitrunurl{$node},0,1) ne "<") {
			$topsum += $hitrunurl{$node};
		}
		$x += 100;
		$i++;
	}

#
# Show Statistics
#
	$x = $imgwidth / 2;
	$y = 50;
	if ($topsum > 0) {
		$pct = sprintf("%.1f", $topsum / $hitrunstat[1] * 100.0);
		&fly_text(1,"These pages account for $pct % of all hit&runs at your website.",$x,$y,undef,undef,undef,"small");
	}
	else {
		&fly_text(1,"These pages are not part of the Top Pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		&fly_text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	&close_fly($tmpfile,$imgfile);
	&make_map("Top Hit&amp;Run Pages",$imgwidth,$imgheight);

}

#
# TOP PAGES DETAILS
#

sub make_topdetail {
	my($xchar);

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

	$i = 0;
	foreach $node (&sort_by_topurl(\@transittop,\%transiturl)) {
		if ($i >= $toptransits) {
			last;
		}
		$midnode{$node} = $transiturl{$node};
		$i++;
	}

	$i = 0;
	foreach $node (&sort_by_topurl(\@exittop,\%exiturl)) {
		if ($i >= $topexits) {
			last;
		}
		$bottomnode{$node} = $exiturl{$node};
		$i++;
	}

	foreach $link (@interntop) {
		($from,$to) = split(/ /,$link);
		if (defined($midnode{$from})) {
			$rightnode{$to} += $internlink{$link};
		}
		if (defined($midnode{$to})) {
			$leftnode{$from} += $internlink{$link};
		}
	}

	$i = 0;
	foreach $node (&sort_by_topurl(\@hitruntop,\%hitrunurl)) {
		if ($i >= $topentries) {
			last;
		}
		$toprightnode{$node} = $hitrunurl{$node};
		$i++;
	}

	$topcount = keys %topnode;
	$bottomcount = keys %bottomnode;
	$midcount = keys %midnode;
	$leftcount = keys %leftnode;
	$rightcount = keys %rightnode;
	$toprightcount = keys %toprightnode;

	if ($topcount > $topentries) {
		$topcount = $topentries;
	}
	if ($leftcount > $toptransits) {
		$leftcount = $toptransits;
	}
	if ($midcount > $toptransits) {
		$midcount = $toptransits;
	}
	if ($rightcount > $toptransits) {
		$rightcount = $toptransits;
	}
	if ($bottomcount > $topexits) {
		$bottomcount = $topexits;
	}
	if ($toprightcount > $topentries) {
		$toprightcount = $topentries;
	}

	$maxcountx = $topcount > $bottomcount ? $topcount : $bottomcount;
	$maxcounty = $midcount > $rightcount ? $midcount : $rightcount;
	$maxcounty = $maxcounty > $leftcount ? $maxcounty : $leftcount;

#
# Determine image size
#
	$leftwidth = &check_nodewidth(\%leftnode,\%transiturl,$leftcount,200);
	$breakwidth = 70;
	$midwidth = &check_nodewidth(\%midnode,\%transiturl,$midcount,200);
	$linkwidth = 250;
	$rightwidth = &check_nodewidth(\%rightnode,\%transiturl,$rightcount,200);
	$imgwidth = $leftwidth + $breakwidth + $maxcountx * 70 + $midwidth + $linkwidth + $rightwidth;

	$topheight = &check_nodeheight(\%topnode,\%entryurl,$topcount,160);
	$tmpheight = &check_nodeheight(\%toprightnode,\%hitrunurl,$toprightcount,160);
	if ($topheight < $tmpheight) {
		$topheight = $tmpheight;
	}
	$breakheight = 40;
	$midheight = $maxcounty * 30;
	$bottomheight = &check_nodeheight(\%bottomnode,\%exiturl,$bottomcount,160);
	$imgheight = $topheight + $breakheight + $midheight + $bottomheight;

	&open_fly($tmpfile,$imgwidth,$imgheight);

#
# Show Title
#
	&map_title("Top Pages Details");

#
# Show Buttons
#
	$midx = $imgwidth / 2;
	&map_buttons("");

#
# FROM ENTRY
#

	$x = $leftwidth + $breakwidth;
	$y = $topheight;
	$topsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%topnode,\%entryurl)) {
		if ($i >= $topcount) {
			last;
		}
		&fly_box(1,$node,$entryurl{$node},$x,$y,"$pagenr{$node}&f=2",undef,1,2);
		$topX{$node} = $x;
		$topY{$node} = $y;
		$topNr{$node} = $i;
		if (substr($entryurl{$node},0,1) ne "<") {
			$topsum += $entryurl{$node};
		}
		$x += 70;
#		$x -= 70;
		$i++;
	}

#
# TO EXIT
#

	$x = $leftwidth + $breakwidth;
	$y = $imgheight - $bottomheight;
	$bottomsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%bottomnode,\%exiturl)) {
		if ($i >= $bottomcount) {
			last;
		}
		&fly_box(2,$node,$exiturl{$node},$x,$y,"$pagenr{$node}&f=3",undef,2,3);
		$bottomX{$node} = $x;
		$bottomY{$node} = $y;
		if (substr($exiturl{$node},0,1) ne "<") {
			$bottomsum += $exiturl{$node};
		}
		$x += 70;
#		$x -= 70;
		$i++;
	}

#
# FROM/TO TRANSIT
#
	$x = $leftwidth + $breakwidth + $maxcountx * 70;
	$y = $topheight + $breakheight;
	$midsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%midnode,\%transiturl)) {
		if ($i >= $midcount) {
			last;
		}
		&fly_box(3,$node,$transiturl{$node},$x,$y,"$pagenr{$node}&f=4",undef,3,1);
		$midX{$node} = $x;
		$midY{$node} = $y;
		$midNr{$node} = $i;
		if (substr($transiturl{$node},0,1) ne "<") {
			$midsum += $transiturl{$node};
		}
		$y += 30;
		$i++;
	}

#
# TO INTERN
#
	$x = $imgwidth - $rightwidth;
	$y = $topheight + $breakheight;
	$rightsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%rightnode,\%transiturl)) {
		if ($i >= $rightcount) {
			last;
		}
		&fly_box(3,$node,$transiturl{$node},$x,$y,"$pagenr{$node}&f=4",undef,3,1);
		$rightX{$node} = $x;
		$rightY{$node} = $y;
		if (substr($transiturl{$node},0,1) ne "<") {
			$rightsum += $transiturl{$node};
		}
		$y += 30;
		$i++;
	}

#
# FROM INTERN
#
	$x = $leftwidth;
	$y = $topheight + $breakheight;
	$leftsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%leftnode,\%transiturl)) {
		if ($i >= $leftcount) {
			last;
		}
		&fly_box(4,$node,$transiturl{$node},$x,$y,"$pagenr{$node}&f=4",undef,3,1);
		$leftX{$node} = $x;
		$leftY{$node} = $y;
		if (substr($transiturl{$node},0,1) ne "<") {
			$leftsum += $transiturl{$node};
		}
		$y += 30;
		$i++;
	}

#
# HIT&RUN
#

	$x = $leftwidth + $breakwidth + $maxcountx * 70 + 70;
	$y = $topheight;
	$toprightsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%toprightnode,\%hitrunurl)) {
		if ($i >= $toprightcount) {
			last;
		}
		&fly_box(1,$node,$hitrunurl{$node},$x,$y,"$pagenr{$node}&f=0",undef,3,7);
		if (substr($hitrunurl{$node},0,1) ne "<") {
			$toprightsum += $hitrunurl{$node};
		}
		$x += 70;
		$i++;
	}

#
# Show Links
#

	$linksumin = 0;
	$linksumout = 0;
	foreach $link (@inouttop) {
		($from,$to) = split(/ /,$link);
		if (defined($topX{$from}) && defined($bottomX{$to})) {
#			&fly_line($inoutlink{$link},$topX{$from},$topY{$from},$bottomX{$to},$bottomY{$to},undef,undef,3);
			&fly_line($inoutlink{$link},$topX{$from},$topY{$from},$bottomX{$to},$bottomY{$to},undef,undef,$topNr{$from});
			$linksuminout += $inoutlink{$link};
			$topTotal{$from} += $inoutlink{$link};
			$bottomTotal{$to} += $inoutlink{$link};
		}
	}
	foreach $link (@outtop) {
		($from,$to) = split(/ /,$link);
		if (defined($midX{$from}) && defined($bottomX{$to})) {
#			&fly_line($outlink{$link},$midX{$from},$midY{$from},$bottomX{$to},$bottomY{$to},undef,undef,3);
			&fly_line($outlink{$link},$midX{$from},$midY{$from},$bottomX{$to},$bottomY{$to},undef,undef,$midNr{$from});
			$linksumout += $outlink{$link};
			$midTotalout{$from} += $outlink{$link};
			$bottomTotal{$to} += $outlink{$link};
		}
	}
	foreach $link (@intop) {
		($from,$to) = split(/ /,$link);
		if (defined($topX{$from}) && defined($midX{$to})) {
#			&fly_line($inlink{$link},$topX{$from},$topY{$from},$midX{$to},$midY{$to},undef,undef,2);
			&fly_line($inlink{$link},$topX{$from},$topY{$from},$midX{$to},$midY{$to},undef,undef,$topNr{$from});
			$linksumin += $inlink{$link};
			$topTotal{$from} += $inlink{$link};
			$midTotalin{$to} += $inlink{$link};
		}
	}
# tricky
	$xchar = $flyfonts{small}[0];
	foreach $link (@interntop) {
		($from,$to) = split(/ /,$link);
		if (defined($midX{$from}) && defined($rightX{$to})) {
			&fly_line($internlink{$link},$midX{$from}+$midwidth,$midY{$from},$rightX{$to},$rightY{$to},undef,undef,$midNr{$from});
			&fly_line("",$midX{$from}+(length($from) + 2) * $xchar + 60,$midY{$from},$midX{$from}+$midwidth,$midY{$from},undef,undef,$midNr{$from});
			$linksuminternout += $internlink{$link};
			$midTotalout{$from} += $internlink{$link};
			$rightTotal{$to} += $internlink{$link};
		}
		if (defined($leftX{$from}) && defined($midX{$to})) {
			&fly_line($internlink{$link},$leftX{$from},$leftY{$from},$midX{$to},$midY{$to},undef,undef,$midNr{$to});
			$linksuminternin += $internlink{$link};
			$leftTotal{$from} += $internlink{$link};
			$midTotalin{$to} += $internlink{$link};
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

	foreach $node (keys %midX) {
		if (!defined($midTotalin{$node})) {
			$midTotalin{$node} = "-";
		}
		if (!defined($midTotalout{$node})) {
			$midTotalout{$node} = "-";
		}
		&fly_text(3,"($midTotalin{$node}/$midTotalout{$node})",$midX{$node}-5,$midY{$node},undef,undef,undef,"small");
	}

	foreach $node (keys %rightX) {
		if (!defined($rightTotal{$node})) {
			$rightTotal{$node} = "-";
		}
		&fly_text(3,"($rightTotal{$node})",$rightX{$node}-5,$rightY{$node},undef,undef,undef,"small");
	}

	foreach $node (keys %leftX) {
		if (!defined($leftTotal{$node})) {
			$leftTotal{$node} = "-";
		}
		&fly_text(2,"($leftTotal{$node})",$leftX{$node}+5,$leftY{$node},undef,undef,undef,"small");
	}

#
# Show Statistics
#
	$x = $imgwidth / 2;
	$y = 50;
	if (($linksumin > 0 || $linksumout > 0) && $midsum > 0) {
		$pct = sprintf("%.1f", ($topsum + $midsum + $bottomsum) / ($entrystat[1] + $transitstat[1] + $exitstat[1]) * 100.0);
		&fly_text(1,"These pages account for $pct % of all hits on your website.",$x,$y,undef,undef,undef,"small");
		$pct = sprintf("%.1f", ($linksumin + $linksumout + $linksuminout + $linksuminternin) / $linkstat[1] * 100.0);
		&fly_text(1,"These links represent $pct % of all links followed inside your website.",$x,$y+15,undef,undef,undef,"small");
#		$pct = sprintf("%.1f", ($linksumin + $linksuminout) / $topsum * 100.0);
#		&fly_text(1,"The incoming and in&out links represent $pct % of all links from these entry pages.",$x,$y+15,undef,undef,undef,"small");
#		$pct = sprintf("%.1f", ($linksumin + $linksuminternin) / $midsum * 100.0);
#		&fly_text(1,"The incoming and internal links represent $pct % of all links to these transit pages.",$x,$y+30,undef,undef,undef,"small");
#		$pct = sprintf("%.1f", ($linksuminternout + $linksumout) / $midsum * 100.0);
#		&fly_text(1,"The internal and outgoing links represent $pct % of all links from these transit pages.",$x,$y+45,undef,undef,undef,"small");
#		$pct = sprintf("%.1f", ($linksuminout + $linksumout) / $bottomsum * 100.0);
#		&fly_text(1,"The outgoing and in&out links represent $pct % of all links to these exit pages.",$x,$y+60,undef,undef,undef,"small");
	}
	else {
		&fly_text(1,"These pages are not part of the Top Pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		&fly_text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	&close_fly($tmpfile,$imgfile);
	&make_map("Top Pages Spaghetti",$imgwidth,$imgheight);

}

#
# FROM ANY ---> URL ---> TO ANY
#

sub make_any {

#
# Get values
#
	foreach $link (@intop) {
		($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$rightnode{$to} += $inlink{$link};
		}
		if ($to eq $url) {
			$leftnode{$from} += $inlink{$link};
		}
	}
	foreach $link (@interntop) {
		($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$rightnode{$to} += $internlink{$link};
		}
		if ($to eq $url) {
			$leftnode{$from} += $internlink{$link};
		}
	}
	foreach $link (@outtop) {
		($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$rightnode{$to} += $outlink{$link};
		}
		if ($to eq $url) {
			$leftnode{$from} += $outlink{$link};
		}
	}
	foreach $link (@inouttop) {
		($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$rightnode{$to} += $inoutlink{$link};
		}
		if ($to eq $url) {
			$leftnode{$from} += $inoutlink{$link};
		}
	}

	$leftcount = keys %leftnode;
	$rightcount = keys %rightnode;

	if ($bigsite == 1) {
		if ($leftcount > $toptransits) {
			$leftcount = $toptransits;
		}
		if ($rightcount > $toptransits) {
			$rightcount = $toptransits;
		}
	}

	$maxcount = $leftcount > $rightcount ? $leftcount : $rightcount;

#
# Determine image size
#
	$leftwidth = &check_nodewidth(\%leftnode,\%pageurl,$leftcount,200);
	$midwidth = 360;
	$rightwidth = &check_nodewidth(\%rightnode,\%pageurl,$rightcount,200);
	$imgwidth = $leftwidth + $midwidth + $rightwidth;

	$topheight = 140;
	$height = &check_urlheight();
	$midheight = $height + $maxcount * 30;
	$bottomheight = 110;
	$imgheight = $topheight + $midheight + $bottomheight;

	&open_fly($tmpfile,$imgwidth,$imgheight);

#
# Show Title
#
	&map_title("Summary Map");

#
# Show Page
#
	$x = $leftwidth + $midwidth / 2;
	$y = $topheight;
	&map_page(2);

#
# Show Buttons
#
	&map_buttons(0);

#
# FROM ANY
#
	$x = $leftwidth;
	$y = $midy;
	$leftsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%leftnode,\%pageurl)) {
		if ($i >= $leftcount) {
			last;
		}
		&fly_box(4,$node,$pageurl{$node},$x,$y,"$pagenr{$node}&f=0",undef,3);
		&fly_line($leftnode{$node},$leftx,$midy,$x,$y,undef,undef,0);
		$leftsum += $leftnode{$node};
		$y += 30;
		$i++;
	}
	if ($leftcount > 0) {
		$y = $midy - 20;
		&fly_text(3,"(from any page)",$x,$y,undef,undef,undef,"small");
		&fly_text(2," --> All Links",$x,$y,undef,undef,undef,"small");
	}

#
# TO ANY
#
	$x = $imgwidth - $rightwidth;
	$y = $midy;
	$rightsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%rightnode,\%pageurl)) {
		if ($i >= $rightcount) {
			last;
		}
		&fly_box(3,$node,$pageurl{$node},$x,$y,"$pagenr{$node}&f=0",undef,3);
		&fly_line($rightnode{$node},$rightx,$midy,$x,$y,undef,undef,0);
		$rightsum += $rightnode{$node};
		$y += 30;
		$i++;
	}
	if ($rightcount > 0) {
		$y = $midy - 20;
		&fly_text(2,"(to any page)",$x,$y,undef,undef,undef,"small");
		&fly_text(3,"All Links --> ",$x,$y,undef,undef,undef,"small");
	}

#
# Show Statistics
#
	$x = $midx;
	$y = 50;
	if (substr($pageurl{$url},0,1) ne "<") {
		$pct = sprintf("%.1f", $pageurl{$url} / $pagestat[1] * 100.0);
		&fly_text(1,"This page accounts for $pct % of all hits on your website.",$x,$y,undef,undef,undef,"small");
	}
	if (substr($transiturl{$url},0,1) ne "<") {
		$totsum1 = $transiturl{$url};
		$totsum2 = $transiturl{$url};
	}
	if (substr($exiturl{$url},0,1) ne "<") {
		$totsum1 += $exiturl{$url};
	}
	if (substr($entryurl{$url},0,1) ne "<") {
		$totsum2 += $entryurl{$url};
	}
	$pct1 = $totsum1 > 0 ? sprintf("%.1f", $leftsum / $totsum1 * 100.0) : "-";
	$pct2 = $totsum2 > 0 ? sprintf("%.1f", $rightsum / $totsum2 * 100.0) : "-";
	if ($totsum1 > 0 || $totsum2 > 0) {
		&fly_text(1,"The links on the left represent $pct1 % of all links to this page,",$x,$y+15,undef,undef,undef,"small");
		&fly_text(1,"and the links on the right represent $pct2 % of all links from this page.",$x,$y+30,undef,undef,undef,"small");
	}
	else {
		&fly_text(1,"This page is not one of the Top Pages found by aWebVisit,",$x,$y+15,undef,undef,undef,"small");
		&fly_text(1,"so there are no hit statistics available.",$x,$y+30,undef,undef,undef,"small");
	}

#
# Make image and page
#
	&close_fly($tmpfile,$imgfile);
	&make_map("Summary Map for Page $url",$imgwidth,$imgheight);

}


#
#      INOUT1   IN1   OUT1
#            \   |  /      
# INTERN1 ----  URL  ---- INTERN2
#            /   |  \      
#      INOUT2   OUT2  IN2
#

sub make_detail {

#
# Get values
#
	foreach $link (@intop) {
		($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$bottomrightnode{$to} = $inlink{$link}; # IN2
		}
		if ($to eq $url) {
			$topnode{$from} = $inlink{$link}; # IN1
		}
	}
	foreach $link (@interntop) {
		($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$rightnode{$to} = $internlink{$link}; # INTERN2
		}
		if ($to eq $url) {
			$leftnode{$from} = $internlink{$link}; # INTERN1
		}
	}
	foreach $link (@outtop) {
		($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$bottomnode{$to} = $outlink{$link}; # OUT2
		}
		if ($to eq $url) {
			$toprightnode{$from} = $outlink{$link}; # OUT1
		}
	}
	foreach $link (@inouttop) {
		($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$bottomleftnode{$to} = $inoutlink{$link}; # INOUT2
		}
		if ($to eq $url) {
			$topleftnode{$from} = $inoutlink{$link}; # INOUT1
		}
	}

	$leftcount = keys %leftnode;
	$rightcount = keys %rightnode;
	$topcount = keys %topnode;
	$bottomcount = keys %bottomnode;
	$toprightcount = keys %toprightnode;
	$bottomrightcount = keys %bottomrightnode;
	$topleftcount = keys %topleftnode;
	$bottomleftcount = keys %bottomleftnode;

# IN1
	if ($topcount > $topentries) {
		$topcount = $topentries;
	}
# INOUT1
	if ($topleftcount > $topentries) {
		$topleftcount = $topentries;
	}
# OUT2
	if ($bottomcount > $topexits) {
		$bottomcount = $topexits;
	}
# INOUT2
	if ($bottomleftcount > $topexits) {
		$bottomleftcount = $topexits;
	}
# IN2
	if ($bottomrightcount > $toptransits) {
		$bottomrightcount = $toptransits;
	}
# INTERN2
	if ($rightcount > $toptransits) {
		$rightcount = $toptransits;
	}
# OUT1
	if ($toprightcount > $toptransits) {
		$toprightcount = $toptransits;
	}
# INTERN1
	if ($leftcount > $toptransits) {
		$leftcount = $toptransits;
	}

	$maxmidx = $topcount > $bottomcount ? $topcount : $bottomcount;
	$maxleftx = $topleftcount > $bottomleftcount ? $topleftcount : $bottomleftcount;
	$maxrightx = $toprightcount > $bottomrightcount ? $toprightcount : $bottomrightcount;

	$maxtopy = $topleftcount > $toprightcount ? $topleftcount : $toprightcount;
	$maxboty = $bottomleftcount > $bottomrightcount ? $bottomleftcount : $bottomrightcount;
	$maxmidy = $leftcount > $rightcount ? $leftcount : $rightcount;

#
# Determine image size
#
	$leftwidth = &check_nodewidth(\%leftnode,\%transiturl,$leftcount,200);
	$tmpwidth = &check_nodewidth(\%topleftnode,\%entryurl,$topleftcount,200);
	if ($leftwidth < $tmpwidth) {
		$leftwidth = $tmpwidth;
	}
	$tmpwidth = &check_nodewidth(\%bottomleftnode,\%exiturl,$bottomleftcount,200);
	if ($leftwidth < $tmpwidth) {
		$leftwidth = $tmpwidth;
	}
	if ($maxleftx * 30 + $maxmidx / 2 * 70 + 70 > 180) {
		$midwidth1 = $maxleftx * 30 + $maxmidx / 2 * 70 + 70;
	}
	else {
		$midwidth1 = 180;
	}
	if ( 70 + $maxmidx / 2 * 70 + $maxrightx * 30 > 180) {
		$midwidth2 = 70 + $maxmidx / 2 * 70 + $maxrightx * 30;
	}
	else {
		$midwidth2 = 180;
	}
	$rightwidth = &check_nodewidth(\%rightnode,\%transiturl,$rightcount,200);
	$tmpwidth = &check_nodewidth(\%toprightnode,\%transiturl,$toprightcount,200);
	if ($rightwidth < $tmpwidth) {
		$rightwidth = $tmpwidth;
	}
	$tmpwidth = &check_nodewidth(\%bottomrightnode,\%transiturl,$bottomrightcount,200);
	if ($rightwidth < $tmpwidth) {
		$rightwidth = $tmpwidth;
	}
	$imgwidth = $leftwidth + $midwidth1 + $midwidth2 + $rightwidth;

	$topheight = &check_nodeheight(\%topnode,\%entryurl,$topcount,200);
	$height = &check_urlheight();
	if ($maxtopy * 30 + $maxmidy / 2 * 30 + $height / 2> 150) {
		$midheight1 = $maxtopy * 30 + $maxmidy / 2 * 30 + $height / 2;
	}
	else {
		$midheight1 = 150;
	}
	if ($height / 2 + $maxmidy / 2 * 30 + $maxboty * 30 > 150) {
		$midheight2 = $height / 2 + $maxmidy / 2 * 30 + $maxboty * 30;
	}
	else {
		$midheight2 = 150;
	}
	$bottomheight = &check_nodeheight(\%bottomnode,\%exiturl,$bottomcount,150);
	$imgheight = $topheight + $midheight1 + $midheight2 + $bottomheight;

	&open_fly($tmpfile,$imgwidth,$imgheight);

#
# Show Title
#
	&map_title("Detailed Map");

#
# Show Page
#
	$x = $leftwidth	+ $midwidth1;
	$y = $topheight + $midheight1;
	&map_page(0);

#
# Show Buttons
#
	&map_buttons(1);

#
# FROM ENTRY TO TRANSIT URL
#
	if ($topcount > 0) {
		$x = $midx - ($topcount - 1) / 2 * 70;
		$y = $topheight;
		&fly_text(3,"(from entry page)",$midx,$y+10,undef,undef,undef,"small");
		&fly_text(2," --> Incoming Link",$midx,$y+10,undef,undef,undef,"small");
		$i = 0;
		foreach $node (&sort_by_nodeurl(\%topnode,\%entryurl)) {
			if ($i >= $topcount) {
				last;
			}
			&fly_box(1,$node,$entryurl{$node},$x,$y,"$pagenr{$node}&f=2",undef,1,2);
			$link = "$node $url";
			&fly_line($inlink{$link},$midx,$topy,$x,$y,undef,undef,2);
			$x += 70;
			$i++;
		}
	}

#
# FROM TRANSIT TO EXIT URL
#
	if ($toprightcount > 0) {
		$x = $midx + ($maxmidx - 1) / 2 * 70 + 70;
		$y = $topheight;
		$i = 0;
		foreach $node (&sort_by_nodeurl(\%toprightnode,\%transiturl)) {
			if ($i >= $toprightcount) {
				last;
			}
			&fly_box(3,$node,$transiturl{$node},$x,$y,"$pagenr{$node}&f=4",undef,3,1);
			$link = "$node $url";
			&fly_line($outlink{$link},$rightx,$topy,$x,$y,undef,undef,3);
			$x += 30;
			$y += 30;
			$i++;
		}
		&fly_text(2,"(from transit page)",$x,$y-15,undef,undef,undef,"small");
		&fly_text(3,"Outgoing Link <-- ",$x,$y-15,undef,undef,undef,"small");
	}

#
# FROM TRANSIT URL TO TRANSIT
#
	if ($rightcount > 0) {
		$x = $imgwidth - $rightwidth;
		$y = $midy - ($rightcount - 1) / 2 * 30;
		&fly_text(2,"(to transit page)",$x,$y-15,undef,undef,undef,"small");
		&fly_text(3,"Internal Link --> ",$x,$y-15,undef,undef,undef,"small");
		$i = 0;
		foreach $node (&sort_by_nodeurl(\%rightnode,\%transiturl)) {
			if ($i >= $rightcount) {
				last;
			}
			&fly_box(3,$node,$transiturl{$node},$x,$y,"$pagenr{$node}&f=4",undef,3,1);
			$link = "$url $node";
			&fly_line($internlink{$link},$rightx,$midy,$x,$y,undef,undef,1);
			$y += 30;
			$i++;
		}
	}

#
# FROM ENTRY URL TO TRANSIT
#
	if ($bottomrightcount > 0) {
		$x = $midx + ($maxmidx - 1) / 2 * 70 + 70;
		$y = $imgheight - $bottomheight;
		$i = 0;
		foreach $node (&sort_by_nodeurl(\%bottomrightnode,\%transiturl)) {
			if ($i >= $bottomrightcount) {
				last;
			}
			&fly_box(3,$node,$transiturl{$node},$x,$y,"$pagenr{$node}&f=4",undef,3,1);
			$link = "$url $node";
			&fly_line($inlink{$link},$rightx,$bottomy,$x,$y,undef,undef,2);
			$x += 30;
			$y -= 30;
			$i++;
		}
		&fly_text(2,"(to transit page)",$x,$y+15,undef,undef,undef,"small");
		&fly_text(3,"Incoming Link --> ",$x,$y+15,undef,undef,undef,"small");
	}


#
# FROM TRANSIT URL TO EXIT
#
	if ($bottomcount > 0) {
		$x = $midx - ($bottomcount - 1) / 2 * 70;
		$y = $imgheight - $bottomheight;
		&fly_text(2,"(to exit page)",$midx,$y-10,undef,undef,undef,"small");
		&fly_text(3,"Outgoing Link --> ",$midx,$y-10,undef,undef,undef,"small");
		$i = 0;
		foreach $node (&sort_by_nodeurl(\%bottomnode,\%exiturl)) {
			if ($i >= $bottomcount) {
				last;
			}
			&fly_box(2,$node,$exiturl{$node},$x,$y,"$pagenr{$node}&f=3",undef,2,3);
			$link = "$url $node";
			&fly_line($outlink{$link},$midx,$bottomy,$x,$y,undef,undef,3);
			$x += 70;
			$i++;
		}
	}

#
# FROM ENTRY URL TO EXIT
#
	if ($bottomleftcount > 0) {
		$x = $midx - ($maxmidx - 1) / 2 * 70 - 70;
		$y = $imgheight - $bottomheight;
		$i = 0;
		foreach $node (&sort_by_nodeurl(\%bottomleftnode,\%exiturl)) {
			if ($i >= $bottomleftcount) {
				last;
			}
			&fly_box(4,$node,$exiturl{$node},$x,$y,"$pagenr{$node}&f=3",undef,2,3);
			$link = "$url $node";
			&fly_line($inoutlink{$link},$leftx,$bottomy,$x,$y,undef,undef,4);
			$x -= 30;
			$y -= 30;
			$i++;
		}
		&fly_text(3,"(to exit page)",$x,$y+15,undef,undef,undef,"small");
		&fly_text(2," <-- In&Out Link",$x,$y+15,undef,undef,undef,"small");
	}

#
# FROM TRANSIT TO TRANSIT URL
#
	if ($leftcount > 0) {
		$x = $leftwidth;
		$y = $midy - ($leftcount - 1) / 2 * 30;
		&fly_text(3,"(from transit page)",$x,$y-15,undef,undef,undef,"small");
		&fly_text(2," --> Internal Link",$x,$y-15,undef,undef,undef,"small");
		$i = 0;
		foreach $node (&sort_by_nodeurl(\%leftnode,\%transiturl)) {
			if ($i >= $leftcount) {
				last;
			}
			&fly_box(4,$node,$transiturl{$node},$x,$y,"$pagenr{$node}&f=4",undef,3,1);
			$link = "$node $url";
			&fly_line($internlink{$link},$leftx,$midy,$x,$y,undef,undef,1);
			$y += 30;
			$i++;
		}
	}

#
# FROM ENTRY TO EXIT URL
#
	if ($topleftcount > 0) {
		$x = $midx - ($maxmidx - 1) / 2 * 70 - 70;
		$y = $topheight;
		$i = 0;
		foreach $node (&sort_by_nodeurl(\%topleftnode,\%entryurl)) {
			if ($i >= $topleftcount) {
				last;
			}
			&fly_box(4,$node,$entryurl{$node},$x,$y,"$pagenr{$node}&f=2",undef,1,2);
			$link = "$node $url";
			&fly_line($inoutlink{$link},$leftx,$topy,$x,$y,undef,undef,4);
			$x -= 30;
			$y += 30;
			$i++;
		}
		&fly_text(3,"(from entry page)",$x,$y-15,undef,undef,undef,"small");
		&fly_text(2," --> In&Out Link",$x,$y-15,undef,undef,undef,"small");
	}

#
# Show Statistics
#

	$x = $midx;
	$y = 50;
	if (substr($entryurl{$url},0,1) ne "<") {
		$pct = sprintf("%.1f", $entryurl{$url} / $entrystat[1] * 100.0);
		&fly_text(1,"This page accounts for $pct % of all entries to your website,",$x,$y,undef,undef,undef,"small");
	}
	else {
		&fly_text(1,"This page is not one of the Top Entry pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
	}
	$y += 15;
	if (substr($transiturl{$url},0,1) ne "<") {
		$pct = sprintf("%.1f", $transiturl{$url} / $transitstat[1] * 100.0);
		&fly_text(1,"for $pct % of all transits inside your website,",$x,$y,undef,undef,undef,"small");
	}
	else {
		&fly_text(1,"it is not one of the Top Transit pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
	}
	$y += 15;
	if (substr($exiturl{$url},0,1) ne "<") {
		$pct = sprintf("%.1f", $exiturl{$url} / $exitstat[1] * 100.0);
		&fly_text(1,"for $pct % of all exits from your website,",$x,$y,undef,undef,undef,"small");
	}
	else {
		&fly_text(1,"it is not one of the Top Exit pages found by aWebVisit.",$x,$y,undef,undef,undef,"small");
	}
	$y += 15;
	if (substr($hitrunurl{$url},0,1) ne "<") {
		$pct = sprintf("%.1f", $hitrunurl{$url} / $hitrunstat[1] * 100.0);
		&fly_text(1,"and for $pct % of all hit&runs at your website.",$x,$y,undef,undef,undef,"small");
	}
	else {
		&fly_text(1,"and it is not one of the Top Hit&Run pages found by aWebVisit.",$x,$y,undef,undef,undef,"small");
	}

#
# Make image and page
#
	&close_fly($tmpfile,$imgfile);
	&make_map("Detailed Map for Page $url",$imgwidth,$imgheight);

}

#
# EXIT <--- ENTRY ---> TRANSIT
#

sub make_entry {

#
# Get values
#
	foreach $link (@intop) {
		($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$rightnode{$to} += $inlink{$link};
		}
	}
	foreach $link (@inouttop) {
		($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$leftnode{$to} += $inoutlink{$link};
		}
	}

	$leftcount = keys %leftnode;
	$rightcount = keys %rightnode;

	if ($bigsite == 1) {
		if ($leftcount > $toptransits) {
			$leftcount = $toptransits;
		}
		if ($rightcount > $toptransits) {
			$rightcount = $toptransits;
		}
	}
	$maxcount = $leftcount > $rightcount ? $leftcount : $rightcount;

#
# Determine image size
#
	$leftwidth = &check_nodewidth(\%leftnode,\%exiturl,$leftcount,200);
	$midwidth = 360;
	$rightwidth = &check_nodewidth(\%rightnode,\%transiturl,$rightcount,200);
	$imgwidth = $leftwidth + $midwidth + $rightwidth;

	$topheight = 120;
	$height = &check_urlheight();
	$midheight = $height + $maxcount * 30;
	$bottomheight = 110;
	$imgheight = $topheight + $midheight + $bottomheight;

	&open_fly($tmpfile,$imgwidth,$imgheight);

#
# Show Title
#
	&map_title("Entry Map");

#
# Show Page
#
	$x = $leftwidth + $midwidth / 2;
	$y = $topheight;
	&map_page(2);

#
# Show Buttons
#
	&map_buttons(2);

#
# TO EXIT
#
	$x = $leftwidth;
	$y = $bottomy + 30;
	$leftsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%leftnode,\%exiturl)) {
		if ($i >= $leftcount) {
			last;
		}
		&fly_box(4,$node,$exiturl{$node},$x,$y,"$pagenr{$node}&f=3",undef,2,3);
		&fly_line($leftnode{$node},$leftx,$bottomy,$x,$y,undef,undef,4);
		$leftsum += $leftnode{$node};
		$y += 30;
		$i++;
	}
	if ($leftcount > 0) {
		$y = $bottomy;
		&fly_text(3,"(to exit page)",$x,$y,undef,undef,undef,"small");
		&fly_text(2," <-- In&Out Link",$x,$y,undef,undef,undef,"small");
	}

#
# TO TRANSIT
#
	$x = $imgwidth - $rightwidth;
	$y = $bottomy + 30;
	$rightsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%rightnode,\%transiturl)) {
		if ($i >= $rightcount) {
			last;
		}
		&fly_box(3,$node,$transiturl{$node},$x,$y,"$pagenr{$node}&f=4",undef,3,1);
		&fly_line($rightnode{$node},$rightx,$bottomy,$x,$y,undef,undef,2);
		$rightsum += $rightnode{$node};
		$y += 30;
		$i++;
	}
	if ($rightcount > 0) {
		$y = $bottomy;
		&fly_text(2,"(to transit page)",$x,$y,undef,undef,undef,"small");
		&fly_text(3,"Incoming Link --> ",$x,$y,undef,undef,undef,"small");
	}

#
# Show Statistics
#
	$x = $midx;
	$y = 50;
	if (substr($entryurl{$url},0,1) ne "<") {
		$pct = sprintf("%.1f", $entryurl{$url} / $entrystat[1] * 100.0);
		&fly_text(1,"This page accounts for $pct % of all entries to your website.",$x,$y,undef,undef,undef,"small");
		$pct = sprintf("%.1f", ($leftsum + $rightsum) / $entryurl{$url} * 100.0);
		&fly_text(1,"The links represent $pct % of all links from this entry page.",$x,$y+15,undef,undef,undef,"small");
	}
	else {
		&fly_text(1,"This page is not one of the Top Entry pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		&fly_text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	&close_fly($tmpfile,$imgfile);
	&make_map("Entry Map for Page $url",$imgwidth,$imgheight);

}

#
# ENTRY ---> EXIT <--- TRANSIT
#

sub make_exit {

#
# Get values
#
	foreach $link (@inouttop) {
		($from,$to) = split(/ /,$link);
		if ($to eq $url) {
			$leftnode{$from} += $inoutlink{$link};
		}
	}
	foreach $link (@outtop) {
		($from,$to) = split(/ /,$link);
		if ($to eq $url) {
			$rightnode{$from} += $outlink{$link};
		}
	}

	$leftcount = keys %leftnode;
	$rightcount = keys %rightnode;

	if ($bigsite == 1) {
		if ($leftcount > $toptransits) {
			$leftcount = $toptransits;
		}
		if ($rightcount > $toptransits) {
			$rightcount = $toptransits;
		}
	}

	$maxcount = $leftcount > $rightcount ? $leftcount : $rightcount;

#
# Determine image size
#
	$leftwidth = &check_nodewidth(\%leftnode,\%entryurl,$leftcount,200);
	$midwidth = 360;
	$rightwidth = &check_nodewidth(\%rightnode,\%transiturl,$rightcount,200);
	$imgwidth = $leftwidth + $midwidth + $rightwidth;

	$topheight = 110;
	$height = &check_urlheight();
	$midheight = $height + $maxcount * 30;
	$bottomheight = 140;
	$imgheight = $topheight + $midheight + $bottomheight;

	&open_fly($tmpfile,$imgwidth,$imgheight);

#
# Show Title
#
	&map_title("Exit Map");

#
# Show Page
#
	$x = $leftwidth + $midwidth / 2;
	$y = $imgheight - $bottomheight;
	&map_page(1);

#
# Show Buttons
#
	&map_buttons(3);

#
# FROM ENTRY
#
	$x = $leftwidth;
	$y = $topy - 30;
	$leftsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%leftnode,\%entryurl)) {
		if ($i >= $leftcount) {
			last;
		}
		&fly_box(4,$node,$entryurl{$node},$x,$y,"$pagenr{$node}&f=2",undef,1,2);
		&fly_line($leftnode{$node},$leftx,$topy,$x,$y,undef,undef,4);
		$leftsum += $leftnode{$node};
		$y -= 30;
		$i++;
	}
	if ($leftcount > 0) {
		$y = $topy;
		&fly_text(3,"(from entry page)",$x,$y,undef,undef,undef,"small");
		&fly_text(2," --> In&Out Link",$x,$y,undef,undef,undef,"small");
	}

#
# FROM TRANSIT
#
	$x = $imgwidth - $rightwidth;
	$y = $topy - 30;
	$rightsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%rightnode,\%transiturl)) {
		if ($i >= $rightcount) {
			last;
		}
		&fly_box(3,$node,$transiturl{$node},$x,$y,"$pagenr{$node}&f=4",undef,3,1);
		&fly_line($rightnode{$node},$rightx,$topy,$x,$y,undef,undef,3);
		$rightsum += $rightnode{$node};
		$y -= 30;
		$i++;
	}
	if ($rightcount > 0) {
		$y = $topy;
		&fly_text(2,"(from transit page)",$x,$y,undef,undef,undef,"small");
		&fly_text(3,"Outgoing Link <-- ",$x,$y,undef,undef,undef,"small");
	}

#
# Show Statistics
#
	$x = $midx;
	$y = $imgheight - 70;
	if (substr($exiturl{$url},0,1) ne "<") {
		$pct = sprintf("%.1f", $exiturl{$url} / $exitstat[1] * 100.0);
		&fly_text(1,"This page accounts for $pct % of all exits from your website.",$x,$y,undef,undef,undef,"small");
		$pct = sprintf("%.1f", ($leftsum + $rightsum) / $exiturl{$url} * 100.0);
		&fly_text(1,"The links represent $pct % of all links to this exit page.",$x,$y+15,undef,undef,undef,"small");
	}
	else {
		&fly_text(1,"This page is not one of the Top Exit pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		&fly_text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	&close_fly($tmpfile,$imgfile);
	&make_map("Exit Map for Page $url",$imgwidth,$imgheight);
}

#
#               ENTRY
#                 |
# TRANSIT ---> TRANSIT ---> TRANSIT
#                 |
#               EXIT
#

sub make_transit {

#
# Get values
#
	foreach $link (@intop) {
		($from,$to) = split(/ /,$link);
		if ($to eq $url) {
			$topnode{$from} += $inlink{$link};
		}
	}
	foreach $link (@outtop) {
		($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$bottomnode{$to} += $outlink{$link};
		}
	}
	foreach $link (@interntop) {
		($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$rightnode{$to} += $internlink{$link};
		}
		if ($to eq $url) {
			$leftnode{$from} += $internlink{$link};
		}
	}

	$topcount = keys %topnode;
	$bottomcount = keys %bottomnode;
	$leftcount = keys %leftnode;
	$rightcount = keys %rightnode;

	if ($bigsite == 1) {
		if ($topcount > $topentries) {
			$topcount = $topentries;
		}
		if ($bottomcount > $topexits) {
			$bottomcount = $topexits;
		}
		if ($leftcount > $toptransits) {
			$leftcount = $toptransits;
		}
		if ($rightcount > $toptransits) {
			$rightcount = $toptransits;
		}
	}

	$maxcountx = $topcount > $bottomcount ? $topcount : $bottomcount;
	$maxcounty = $leftcount > $rightcount ? $leftcount : $rightcount;

#
# Determine image size
#
	$leftwidth = &check_nodewidth(\%leftnode,\%transiturl,$leftcount,200);
	if ($maxcountx * 70 > 360) {
		$midwidth = $maxcountx * 70;
	}
	else {
		$midwidth = 360;
	}
	$rightwidth = &check_nodewidth(\%rightnode,\%transiturl,$rightcount,200);
	$imgwidth = $leftwidth + $midwidth + $rightwidth;

	if ($topcount > 0) {
		$topheight = &check_nodeheight(\%topnode,\%entryurl,$topcount,190);
	}
	else {
		$topheight = 0;
	}
	$height = &check_urlheight();
	$breakheight = 150 + $height / 2;
	if ($maxcounty * 30 > 150) {
		$midheight = $height / 2 + $maxcounty * 30;
	}
	else {
		$midheight = $height / 2 + 150;
	}
	if ($bottomcount > 0) {
		$bottomheight = &check_nodeheight(\%bottomnode,\%exiturl,$bottomcount,140);
	}
	else {
		$bottomheight = 0;
	}
	$imgheight = $topheight + $breakheight + $midheight + $bottomheight;

	&open_fly($tmpfile,$imgwidth,$imgheight);

#
# Show Title
#
	&map_title("Transit Map");

#
# Show Page
#
	$x = $leftwidth + $midwidth / 2;
	$y = $topheight + $breakheight;
	&map_page(0);

#
# Show Buttons
#
	&map_buttons(4);

#
# FROM TRANSIT
#
	$x = $leftwidth;
	$y = $midy;
	$leftsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%leftnode,\%transiturl)) {
		if ($i >= $leftcount) {
			last;
		}
		&fly_box(4,$node,$transiturl{$node},$x,$y,"$pagenr{$node}&f=4",undef,3,1);
		&fly_line($leftnode{$node},$leftx,$midy,$x,$y,undef,undef,1);
		$leftsum += $leftnode{$node};
		$y += 30;
		$i++;
	}
	if ($leftcount > 0) {
		$y = $midy - 20;
		&fly_text(3,"(from transit page)",$x,$y,undef,undef,undef,"small");
		&fly_text(2," --> Internal",$x,$y,undef,undef,undef,"small");
	}

#
# TO TRANSIT
#
	$x = $imgwidth - $rightwidth;
	$y = $midy;
	$rightsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%rightnode,\%transiturl)) {
		if ($i >= $rightcount) {
			last;
		}
		&fly_box(3,$node,$transiturl{$node},$x,$y,"$pagenr{$node}&f=4",undef,3,1);
		&fly_line($rightnode{$node},$rightx,$midy,$x,$y,undef,undef,1);
		$rightsum += $rightnode{$node};
		$y += 30;
		$i++;
	}
	if ($rightcount > 0) {
		$y = $midy - 20;
		&fly_text(2,"(to transit page)",$x,$y,undef,undef,undef,"small");
		&fly_text(3,"Internal --> ",$x,$y,undef,undef,undef,"small");
	}

#
# FROM ENTRY
#
	$x = $midx - 70 * ($topcount - 1) / 2;
	$y = $topheight;
	$topsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%topnode,\%entryurl)) {
		if ($i >= $topcount) {
			last;
		}
		&fly_box(1,$node,$entryurl{$node},$x,$y,"$pagenr{$node}&f=2",undef,1,2);
		&fly_line($topnode{$node},$midx,$topy,$x,$y,undef,undef,2);
		$topsum += $topnode{$node};
		$x += 70;
		$i++;
	}
	if ($topcount > 0) {
		$x = $midx;
		$y = $y + 10;
		&fly_text(3,"(from entry page)",$x,$y,undef,undef,undef,"small");
		&fly_text(2," --> Incoming",$x,$y,undef,undef,undef,"small");
	}

#
# TO EXIT
#
	$x = $midx - 70 * ($bottomcount - 1) / 2;
	$y = $imgheight - $bottomheight;
	$bottomsum = 0;
	$i = 0;
	foreach $node (&sort_by_nodeurl(\%bottomnode,\%exiturl)) {
		if ($i >= $bottomcount) {
			last;
		}
		&fly_box(2,$node,$exiturl{$node},$x,$y,"$pagenr{$node}&f=3",undef,2,3);
		&fly_line($bottomnode{$node},$midx,$bottomy,$x,$y,undef,undef,3);
		$bottomsum += $bottomnode{$node};
		$x += 70;
		$i++;
	}
	if ($bottomcount > 0) {
		$x = $midx;
		$y = $y - 10;
		&fly_text(2,"(to exit page)",$x,$y,undef,undef,undef,"small");
		&fly_text(3,"Outgoing --> ",$x,$y,undef,undef,undef,"small");
	}

#
# Show Statistics
#
	$x = $midx;
	$y = 60;
	if (substr($transiturl{$url},0,1) ne "<") {
		$pct = sprintf("%.1f", $transiturl{$url} / $transitstat[1] * 100.0);
		&fly_text(1,"This page accounts for $pct % of all transits inside your website.",$x,$y,undef,undef,undef,"small");
		$pct = sprintf("%.1f", ($topsum + $leftsum) / $transiturl{$url} * 100.0);
		&fly_text(1,"The incoming and internal links TO this page represent $pct % of all transit hits on this page,",$x,$y+15,undef,undef,undef,"small");
		$pct = sprintf("%.1f", ($rightsum + $bottomsum) / $transiturl{$url} * 100.0);
		&fly_text(1,"and the internal and outgoing links FROM this page represent $pct % of all transit hits on this page.",$x,$y+30,undef,undef,undef,"small");
	}
	else {
		&fly_text(1,"This page is not one of the Top Transit pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		&fly_text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	&close_fly($tmpfile,$imgfile);
	&make_map("Transit Map for Page $url",$imgwidth,$imgheight);

}


#
# End of aWebVisit-Map
#
###########################################################################
#

