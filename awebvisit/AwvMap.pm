###########################################################################
#
# NAME
#
#	AwvMap Module Version 0.1.7, 27/01/2002
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
#	This is a common module used by aWebVisit and aWebVisit-Map to create
#	the different graphical maps in GIF/PNG format, using the external
#	'fly' program from Martin Gleeson.
#	You can get pre-compiled binaries for Windows 95 & NT, various UNIXes,
#	and other platforms at http://martin.gleeson.com/fly/
#
# EXAMPLES OF USE
#
#	Place a copy of this file in the directories where awebvisit.pl and
#	awv-map.cgi are located.
#
# HISTORY
#
#	0.1.7 27/01/2002  First version, with support for the new barchart
#			  and distribution graphs used by aWebVisit 0.1.7
#
# FUTURE
#
#	This is probably as far as it goes, unless you send your suggestions
#	and wishes to (awebvisit@mikespub.net)...
#
###########################################################################

package AwvMap;

use strict;
# avoid 'Subroutine ... redefined' warnings
#no warnings 'redefine';

BEGIN {
use vars qw( %flyfonts $flyratio @flycolor $VERSION @ISA @EXPORT );

require Exporter;
@ISA = qw(Exporter);
@EXPORT = qw( %flyfonts $flyratio @flycolor $VERSION check_urlheight check_nodewidth check_nodeheight sort_by_topurl sort_by_nodeurl );

$VERSION = '0.1.7';

}

sub new {
	my $class = shift;

	my $self = {};
	bless($self, $class);
	return $self;
}

###########################################################################
#
# Sorting routines
#

sub sort_by_topurl {
	my($topref,$urlref) = @_;

	my(@sorted) = sort {
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

	my(@sorted) = sort {
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

###########################################################################
#
# Routines for checking the width or height of URLs
#

sub check_urlheight {
	my($url) = @_;

#	my $ychar = $flyfonts{small}[1];
	my $ychar = AwvMap::Fly->fontheight('small');

	my $height = int((length($url) - 1) / 8);
	$height = $height * ($ychar+2);

	return $height;
}

sub check_nodeheight {
	my($noderef,$urlref,$nodecount,$minheight) = @_;

#	my $ychar = $flyfonts{small}[1];
	my $ychar = AwvMap::Fly->fontheight('small');

	my $i = 0;
	my $maxlen = 0;
	foreach my $node (sort_by_nodeurl($noderef,$urlref)) {
		if ($i >= $nodecount) {
			last;
		}
		if ($maxlen < length($node)) {
			$maxlen = length($node);
		}
		$i++;
	}
	my $height = ($maxlen - 1) / 8;
	$height = $height * ($ychar + 2) + 60;
	if ($height < $minheight) {
		$height = $minheight;
	}
	return $height;
}

sub check_nodewidth {
	my($noderef,$urlref,$nodecount,$minwidth) = @_;

#	my $xchar = $flyfonts{small}[0];
	my $xchar = AwvMap::Fly->fontwidth('small');

	my $i = 0;
	my $maxlen = 0;
	foreach my $node (sort_by_nodeurl($noderef,$urlref)) {
		if ($i >= $nodecount) {
			last;
		}
		if ($maxlen < length($node)) {
			$maxlen = length($node);
		}
		$i++;
	}
# test...
#	my $width = ($maxlen + 2) * $xchar + 60;
	my $width = ($maxlen + 2) * $xchar + 80;
	if ($width < $minwidth) {
		$width = $minwidth;
	}
	return $width;
}


###########################################################################
#
# AwvMap::Fly
#
###########################################################################

package AwvMap::Fly;

use strict;
#use vars qw( @ISA );

use AwvMap;
#@ISA = qw( AwvMap );

my %flyfonts = (
	'tiny',		[ 5 , 8  ],
	'small',	[ 6 , 12 ],
	'medium',	[ 7 , 13 ],
	'large',	[ 8 , 16 ],
	'giant',	[ 9 , 15 ], # 15 ?
);

my $flyratio = 0.7;

my @flycolor = (
	[ 0	, 0	, 0	],
	[ 0	, 0	, 225	],
	[ 63	, 175	, 63	],
#	[ 0	, 255	, 0	],
	[ 225	, 0	, 0	],
	[ 255	, 255	, 63	],
#	[ 232	, 232	, 0	],
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

###########################################################################
#
# Routines for creating generic images
#

sub new {
	my $class = shift;
	my $width = shift;
	my $height = shift;
	my $infile = shift || 'awvfly.tmp';

	local *FH;
	open(FH,">$infile") || cleanup("Can't create temporary file '$infile'\nReason : $!\nCheck the directory, and the access rights of the script to this directory.\n");
	my $fh = *FH;
	print $fh "new\n";
	print $fh "size $width,$height\n";
	print $fh "fill 1,1,203,255,255\n";

	my $self = {
		width => $width,
		height => $height,
		infile => $infile,
		fh => $fh,
		maps => [],
	};
	bless($self, $class);
	return $self;
}

sub generate {
	my $self = shift;
	my $flyprog = shift || die "Please specify the location of the 'fly' program !\n";
	my $outfile = shift || 'awvfly.gif';

	close($self->{fh});
#	print "$flyprog -q -i $self->{infile} -o $outfile\n";
	#if ($keepimages != 1 || !-f $outfile) {
		system("$flyprog -q -i $self->{infile} -o $outfile");
	#}
	unlink($self->{infile});
}


###########################################################################
#
# Get stored area map entries (and image size + title)
#

sub get_map {
	my $self = shift;
	my($title) = @_;

#	return(@{$self->{maps}});
	my @map = @{$self->{maps}};
	push(@map, [ $self->{width}, $self->{height}, $title ]);
	return(@map);
}

###########################################################################
#
# Font size routines
#

sub fontsize {
	my $class = shift;
	my $size = shift;

	return @{$flyfonts{$size}};
}

sub fontwidth {
	my $class = shift;
	my $size = shift;

	return $flyfonts{$size}[0];
}

sub fontheight {
	my $class = shift;
	my $size = shift;

	return $flyfonts{$size}[1];
}

###########################################################################
#
# Routines for drawing basic graphical elements
#

sub text {
	my $self = shift;
	my($type,$text,$x,$y,$ref,$alt,$col,$size) = @_;

	if(!defined($size)) {
		$size = "medium";
	}
	my $xchar = $flyfonts{$size}[0];
	my $ychar = $flyfonts{$size}[1];

	my $width = length($text) * $xchar;
	my $height = $ychar;

	my $x1;
	if ($type == 1) { # align center
		$x1 = $x - $width/2;
	}
	elsif ($type == 2) { # align left
		$x1 = $x;
	}
	else { # align right
		$x1 = $x - $width;
	}
	my $y1 = $y - $height / 2;
	if (defined($col) && defined($flycolor[$col])) {
		print {$self->{fh}} "string $flycolor[$col][0],$flycolor[$col][1],$flycolor[$col][2],$x1,$y1,$size,$text\n";
	}
	else {
		print {$self->{fh}} "string 0,0,0,$x1,$y1,$size,$text\n";
	}

	if (defined($ref)) {
		push( @{$self->{maps}}, [ $ref, $alt, "rect", int($x1 - 5), int($y1 - 5), int($x1 + $width + 5), int($y1 + $height + 5) ] );
	}
}

sub line {
	my $self = shift;
	my($text,$x1,$y1,$x2,$y2,$ref,$alt,$col,$size) = @_;

	if (defined($col) && defined($flycolor[$col])) {
		print {$self->{fh}} "line $x1,$y1,$x2,$y2,$flycolor[$col][0],$flycolor[$col][1],$flycolor[$col][2]\n";
	}
	else {
		print {$self->{fh}} "line $x1,$y1,$x2,$y2,0,0,0\n";
	}
	my $xmid = ($x1 + $x2) / 2;
	my $ymid = ($y1 + $y2) / 2;

	if (defined($text) && $text ne "") {
		$self->text(1,$text,$xmid,$ymid,$ref,$alt,$col,$size);
	}

	if (defined($ref)) {
		my $hypot = sqrt(($x2 - $x1)**2 + ($y2 - $y1)**2);
		$xmid = 5 * ($y2 - $y1) / $hypot;
		$ymid = 5 * ($x2 - $x1) / $hypot;
		push( @{$self->{maps}}, [ $ref, $alt, "poly", int($x1 + $xmid), int($y1 - $ymid), int($x1 - $xmid), int($y1 + $ymid), int($x2 - $xmid), int($y2 + $ymid), int($x2 + $xmid), int($y2 - $ymid) ] );
	}
}

sub rect {
	my $self = shift;
	my($x1,$y1,$x2,$y2,$col) = @_;

	my $xmid = int(($x1 + $x2) / 2);
	my $ymid = int(($y1 + $y2) / 2);
	if (defined($col) && defined($flycolor[$col])) {
		if ($xmid != $x1) {
			print {$self->{fh}} "rect $x1,$y1,$x2,$y2,0,0,0\n";
			print {$self->{fh}} "fill $xmid,$ymid,$flycolor[$col][0],$flycolor[$col][1],$flycolor[$col][2]\n";
		}
		else {
			print {$self->{fh}} "rect $x1,$y1,$x2,$y2,$flycolor[$col][0],$flycolor[$col][1],$flycolor[$col][2]\n";
		}
	}
	else {
		print {$self->{fh}} "rect $x1,$y1,$x2,$y2,0,0,0\n";
	}
}

sub bar {
	my $self = shift;
	my($url,$val,$scale,$x,$y,$col,@values) = @_;

# test...
#	my $y1 = $y - 10;
#	my $y2 = $y + 10;
	my $y1 = $y - 8;
	my $y2 = $y + 8;
	my $x2 = $x;
	my $x1;

	foreach my $value (@values) {
		if ($value->[0] > 0) {
			$x1 = $x2;
			$x2 = $x1 + int($value->[0]/$scale);
			$self->rect($x1,$y1,$x2,$y2,$value->[1]);
		}
	}

#	$self->text(2,$val,$x2+5,$y,undef,undef,$col,"small");
	$self->text(2,$val,$x2+5,$y-5,undef,undef,$col,"small");
}

sub column {
	my $self = shift;
	my($url,$val,$scale,$x,$y,$col,@values) = @_;

	my $x1 = $x - 10;
	my $x2 = $x + 10;
	my $y2 = $y;
	my $y1;

	foreach my $value (@values) {
		if ($value->[0] > 0) {
			$y1 = $y2;
			$y2 = $y1 - int($value->[0]/$scale);
			$self->rect($x1,$y1,$x2,$y2,$value->[1]);
		}
	}

	$self->text(1,$val,$x,$y2-10,undef,undef,$col,"small");
}

###########################################################################
#
# Routines for creating images with generic nodes and links
#

sub node {
	my $self = shift;
	my($text,$x,$y,$textlen,$ref,$alt) = @_;

	my $xchar = $flyfonts{medium}[0];
	my $ychar = $flyfonts{medium}[1];
	my $xyratio = $flyratio;

	my $width = ($textlen + 4) * $xchar;
	my $height = $width * $xyratio;
	print {$self->{fh}} "ellipse $x,$y,$width,$height,0,0,0\n";
	print {$self->{fh}} "fill $x,$y,255,255,255\n";

	if (defined($text) && $text ne "") {
		$self->text(1,$text,$x,$y);
	}

	if (defined($ref)) {
		push( @{$self->{maps}}, [ $ref, $alt, "rect", int($x - $width / 2), int($y - $height / 2), int($x + $width / 2), int($y + $height / 2) ] );
	}
}

sub get_maxnodelen {
	my($noderef) = @_;

	my $maxlen = 0;
	for my $i (0 .. $#{$noderef}) {
		my $text = $$noderef[$i][0];
		if ($maxlen < length($text)) {
			$maxlen = length($text);
		}
	}
	return($maxlen);
}

sub get_nodesize {
	my($textlen) = @_;

	my $xchar = $flyfonts{medium}[0];
	my $xyratio = $flyratio;

	my $width = ($textlen+4) * $xchar / 2;
	my $height = $width * $xyratio;

	return($width,$height);
}

sub make_nodes {
	my $self = shift;
	my($noderef) = @_;

	my $maxlen = get_maxnodelen($noderef);

	for my $i (0 .. $#{$noderef}) {
		my ($text,$x,$y,$ref,$alt) = @{$$noderef[$i]};
		$self->node($text,$x,$y,$maxlen,$ref, defined($alt) ? $alt : $text );
	}
}

sub make_links {
	my $self = shift;
	my($noderef,$linkref) = @_;

#	my $xchar = $flyfonts{medium}[0];
#	my $ychar = $flyfonts{medium}[1];
#	my $xyratio = $flyratio;

	my $maxlen = get_maxnodelen($noderef);

#	my $width = ($maxlen+4) * $xchar / 2;
#	my $height = $width * $xyratio;

	my($width,$height) = get_nodesize($maxlen);
	my $xyratio = $height / $width;

	for my $i (0 .. $#{$linkref}) {
		my ($text,$node1,$node2,$ref,$alt,$col) = @{$$linkref[$i]};
		if ($node1 eq "") {
			my $x2 = $$noderef[$node2][1];
			my $y2 = $$noderef[$node2][2] - $height;
			my $x1 = $x2;
			my $y1 = $y2 - 80 + $height;
			$self->line($text,$x1,$y1,$x2,$y2, defined($ref) ? $ref : $$noderef[$node2][3], defined($alt) ? $alt : "--&gt; $$noderef[$node2][0]",$col);
			$x1 = $x2 - 4;
			$y1 = $y2 - 5;
			$self->line("",$x1,$y1,$x2,$y2,undef,undef,$col);
			$x1 = $x2 + 4;
			$y1 = $y2 - 5;
			$self->line("",$x1,$y1,$x2,$y2,undef,undef,$col);
		}
		elsif ($node2 eq "") {
			my $x1 = $$noderef[$node1][1];
			my $y1 = $$noderef[$node1][2] + $height;
			my $x2 = $x1; # was $x2 ??
			my $y2 = $y1 + 80 - $height;
			$self->line($text,$x1,$y1,$x2,$y2, defined($ref) ? $ref : $$noderef[$node1][3], defined($alt) ? $alt : "$$noderef[$node1][0] --&gt;",$col);
			$x1 = $x2 - 4;
			$y1 = $y2 - 5;
			$self->line("",$x1,$y1,$x2,$y2,undef,undef,$col);
			$x1 = $x2 + 4;
			$y1 = $y2 - 5;
			$self->line("",$x1,$y1,$x2,$y2,undef,undef,$col);
		}
		elsif ($node1 == $node2) {
			my $x1 = $$noderef[$node1][1];
			my $y1 = $$noderef[$node1][2];
		# cross between circle and ellipse at 45 deg
		#	$rad = 2 * sqrt(2) * $xyratio * $height / (1 + $xyratio**2);
		#	$xdiff = $width;
		#	$start = 225;
		#	$end = 135;
		# cross between camel and elephant at my place
			my $rad = sqrt(($width**2 + $height**2)/2);
			my $xdiff = $width * sqrt(2);
			my $deg = atan2($height,$width) * 45 / atan2(1,1);
			my $start = 180 + $deg;
			my $end = 180 - $deg;
			my $awidth = 2 * $rad;
			my $aheight = 2 * $rad;
		# from border of node
			if (defined($ref)) {
				push( @{$self->{maps}}, [ $ref, defined($alt) ? $alt : "$$noderef[$node1][0] --&gt; $$noderef[$node2][0]", "rect", int($x1 + $width + 1), int($y1 - $rad), int($x1 + $xdiff + $rad), int($y1 + $rad) ] );
			}
			$x1 += $xdiff;
			if (defined($col) && defined($flycolor[$col])) {
				print {$self->{fh}} "arc $x1,$y1,$awidth,$aheight,$start,$end,$flycolor[$col][0],$flycolor[$col][1],$flycolor[$col][2]\n";
			}
			else {
				print {$self->{fh}} "arc $x1,$y1,$awidth,$aheight,$start,$end,0,0,0\n";
			}
			$x1 += $rad;
			$self->text(1,$text,$x1,$y1,$ref,$alt,$col);
		}
		else {
			my $x1 = $$noderef[$node1][1];
			my $y1 = $$noderef[$node1][2];
			my $x2 = $$noderef[$node2][1];
			my $y2 = $$noderef[$node2][2];
		# intersection of line with ellipse
			my $root = sqrt(($xyratio**2) * (($x2-$x1)**2) + ($y2-$y1)**2);
			my $xdiff = $height * ($x2 - $x1) / $root;
			my $ydiff = $height * ($y2 - $y1) / $root;
			$x1 += $xdiff;
			$y1 += $ydiff;
			$x2 -= $xdiff;
			$y2 -= $ydiff;
			$self->line($text,$x1,$y1,$x2,$y2,$ref,defined($alt) ? $alt : "$$noderef[$node1][0] --&gt; $$noderef[$node2][0]",$col);
		}
	}
}

sub make_nodeimg {
	my $self = shift;
	my($noderef,$linkref,$flyprog,$outfile) = @_;

	$self->make_nodes($noderef);
	$self->make_links($noderef,$linkref);
	$self->generate($flyprog,$outfile);
}

###########################################################################
#
# Routines for creating images with page boxes and web links
#

sub box {
	my $self = shift;
	my($type,$text,$val,$x,$y,$ref,$alt,$arrow,$col) = @_;
	my($leftx,$rightx,$topy,$bottomy);

	my $xchar = $flyfonts{small}[0];
	my $ychar = $flyfonts{small}[1];

	if ($type < 3) { # wrap text
		my $maxtext = 8;
		my $width = ($maxtext + 2) * $xchar;
		my $height = int((length($text) - 1) / $maxtext);
		$height = $height * ($ychar+2);
		my $x1 = $x - $width / 2;
		my $x2 = $x + $width / 2;
		my $y1;
		my $y2;
		if ($type == 1) { # align bottom
			$y1 = $y - $height - $ychar - 4;
			$y2 = $y;
			if ($val > 0) {
				$self->line($val,$x,$y1-50,$x,$y1,undef,undef,$col);
				if ($arrow == 1 || $arrow == 3) { # to node
					$self->line("",$x+4,$y1-5,$x,$y1,undef,undef,$col);
					$self->line("",$x-4,$y1-5,$x,$y1,undef,undef,$col);
				}
				if ($arrow == 2 || $arrow == 3) { # from node
					$self->line("",$x+4,$y1-45,$x,$y1-50,undef,undef,$col);
					$self->line("",$x-4,$y1-45,$x,$y1-50,undef,undef,$col);
				}
			}
		}
		elsif ($type == 2) { # align top
			$y1 = $y;
			$y2 = $y + $height + $ychar + 4;
			if ($val > 0) {
				$self->line($val,$x,$y2,$x,$y2+50,undef,undef,$col);
				if ($arrow == 1 || $arrow == 3) { # to node
					$self->line("",$x+4,$y2+5,$x,$y2,undef,undef,$col);
					$self->line("",$x-4,$y2+5,$x,$y2,undef,undef,$col);
				}
				if ($arrow == 2 || $arrow == 3) { # from node
					$self->line("",$x+4,$y2+45,$x,$y2+50,undef,undef,$col);
					$self->line("",$x-4,$y2+45,$x,$y2+50,undef,undef,$col);
				}
			}
		}
		else { # align middle + keep position in left/right x & top/bottom y
			$y1 = $y - ($height + $ychar + 4)/2;
			$y2 = $y + ($height + $ychar + 4)/2;
			# no value or arrow supported
		}
		print {$self->{fh}} "rect $x1,$y1,$x2,$y2,0,0,0\n";
		$leftx = $x1;
		$rightx = $x2;
		$topy = $y1;
		$bottomy = $y2;
		if (defined($ref)) {
			push( @{$self->{maps}}, [ $ref, $alt, "rect", $x1, $y1, $x2, $y2 ] );
		}
		$y = $y1 + 2;
		print {$self->{fh}} "fill $x,$y,255,255,255\n";
		my $offset = 0;
		while ($offset < length($text)) {
			my $part = substr($text,$offset,$maxtext);
			$width = length($part) * $xchar;
			$x1 = $x - $width / 2;
			$y1 = $y;
			print {$self->{fh}} "string 0,0,0,$x1,$y1,small,$part\n";
			$offset += $maxtext;
			$y += $ychar + 2;
		}
	}
	elsif ($type == 3) { # no wrap, align left
		my $width = (length($text) + 2) * $xchar;
		my $x1 = $x;
		my $x2 = $x + $width;
		my $y1 = $y - $ychar / 2 - 2;
		my $y2 = $y + $ychar / 2 + 2;
		print {$self->{fh}} "rect $x1,$y1,$x2,$y2,0,0,0\n";
		$leftx = $x1;
		$rightx = $x2;
		$topy = $y1;
		$bottomy = $y2;
		if (defined($ref)) {
			push( @{$self->{maps}}, [ $ref, $alt, "rect", $x1, $y1, $x2, $y2 ] );
		}
		$x1 = $x + $width / 2;
		$y1 = $y;
		print {$self->{fh}} "fill $x1,$y1,255,255,255\n";
		$x1 = $x + $xchar;
		$y1 = $y - $ychar / 2;
		print {$self->{fh}} "string 0,0,0,$x1,$y1,small,$text\n";
		if ($val > 0) {
			$x1 = $x + $width;
			$y1 = $y;
			$x2 = $x1 + 60;
			$y2 = $y1;
			$self->line($val,$x1,$y1,$x2,$y2,undef,undef,$col);
			if ($arrow == 1 || $arrow == 3) { # to node
				$self->line("",$x1+5,$y1-3,$x1,$y1,undef,undef,$col);
				$self->line("",$x1+5,$y1+3,$x1,$y1,undef,undef,$col);
			}
			if ($arrow == 2 || $arrow == 3) { # from node
				$self->line("",$x2-5,$y2-3,$x2,$y2,undef,undef,$col);
				$self->line("",$x2-5,$y2+3,$x2,$y2,undef,undef,$col);
			}
		}
	}
	elsif ($type == 4) { # no wrap, align right
		my $width = (length($text) + 2) * $xchar;
		my $x1 = $x - $width;
		my $x2 = $x;
		my $y1 = $y - $ychar / 2 - 2;
		my $y2 = $y + $ychar / 2 + 2;
		print {$self->{fh}} "rect $x1,$y1,$x2,$y2,0,0,0\n";
		$leftx = $x1;
		$rightx = $x2;
		$topy = $y1;
		$bottomy = $y2;
		if (defined($ref)) {
			push( @{$self->{maps}}, [ $ref, $alt, "rect", $x1, $y1, $x2, $y2 ] );
		}
		$x1 = $x - $width / 2;
		$y1 = $y;
		print {$self->{fh}} "fill $x1,$y1,255,255,255\n";
		$x1 = $x - $width + $xchar;
		$y1 = $y - $ychar / 2;
		print {$self->{fh}} "string 0,0,0,$x1,$y1,small,$text\n";
		if ($val > 0) {
			$x1 = $x - $width;
			$y1 = $y;
			$x2 = $x1 - 60;
			$y2 = $y1;
			$self->line($val,$x1,$y1,$x2,$y2,undef,undef,$col);
			if ($arrow == 1 || $arrow == 3) { # to node
				$self->line("",$x1-5,$y1-3,$x1,$y1,undef,undef,$col);
				$self->line("",$x1-5,$y1+3,$x1,$y1,undef,undef,$col);
			}
			if ($arrow == 2 || $arrow == 3) { # from node
				$self->line("",$x2+5,$y1-3,$x2,$y2,undef,undef,$col);
				$self->line("",$x2+5,$y1+3,$x2,$y2,undef,undef,$col);
			}
		}
	}
	elsif ($type == 5) { # no wrap, vertical text, align bottom
		my $height = (length($text) + 2) * $xchar;
		my $x1 = $x - $ychar / 2 - 2;
		my $x2 = $x + $ychar / 2 + 2;
		my $y1 = $y - $height;
		my $y2 = $y;
		print {$self->{fh}} "rect $x1,$y1,$x2,$y2,0,0,0\n";
		$leftx = $x1;
		$rightx = $x2;
		$topy = $y1;
		$bottomy = $y2;
		if (defined($ref)) {
			push( @{$self->{maps}}, [ $ref, $alt, "rect", $x1, $y1, $x2, $y2 ] );
		}
		$x1 = $x;
		$y1 = $y - $height/2;
		print {$self->{fh}} "fill $x1,$y1,255,255,255\n";
		$x1 = $x - $ychar / 2;
		$y1 = $y - $xchar;
		print {$self->{fh}} "stringup 0,0,0,$x1,$y1,small,$text\n";
		if ($val > 0) {
			$x1 = $x;
			$y1 = $y - $height;
			$x2 = $x1;
			$y2 = $y1 - 50;
			$self->line($val,$x1,$y1,$x2,$y2,undef,undef,$col);
			if ($arrow == 1 || $arrow == 3) { # to node
				$self->line("",$x1+4,$y1-5,$x1,$y1,undef,undef,$col);
				$self->line("",$x1-4,$y1-5,$x1,$y1,undef,undef,$col);
			}
			if ($arrow == 2 || $arrow == 3) { # from node
				$self->line("",$x2+4,$y2+5,$x2,$y2,undef,undef,$col);
				$self->line("",$x2-4,$y2+5,$x2,$y2,undef,undef,$col);
			}
		}
	}
	elsif ($type == 6) { # no wrap, vertical text, align top
		my $height = (length($text) + 2) * $xchar;
		my $x1 = $x - $ychar / 2 - 2;
		my $x2 = $x + $ychar / 2 + 2;
		my $y1 = $y;
		my $y2 = $y + $height;
		print {$self->{fh}} "rect $x1,$y1,$x2,$y2,0,0,0\n";
		$leftx = $x1;
		$rightx = $x2;
		$topy = $y1;
		$bottomy = $y2;
		if (defined($ref)) {
			push( @{$self->{maps}}, [ $ref, $alt, "rect", $x1, $y1, $x2, $y2 ] );
		}
		$x1 = $x;
		$y1 = $y + $height/2;
		print {$self->{fh}} "fill $x1,$y1,255,255,255\n";
		$x1 = $x - $ychar / 2;
		$y1 = $y + $height - $xchar;
		print {$self->{fh}} "stringup 0,0,0,$x1,$y1,small,$text\n";
		if ($val > 0) {
			$x1 = $x;
			$y1 = $y + $height;
			$x2 = $x1;
			$y2 = $y1 + 50;
			$self->line($val,$x1,$y1,$x2,$y2,undef,undef,$col);
			if ($arrow == 1 || $arrow == 3) { # to node
				$self->line("",$x1+4,$y1+5,$x1,$y1,undef,undef,$col);
				$self->line("",$x1-4,$y1+5,$x1,$y1,undef,undef,$col);
			}
			if ($arrow == 2 || $arrow == 3) { # from node
				$self->line("",$x2+4,$y2-5,$x2,$y2,undef,undef,$col);
				$self->line("",$x2-4,$y2-5,$x2,$y2,undef,undef,$col);
			}
		}
	}
	elsif ($type == 7) { # no wrap, align center
		my $width = (length($text) + 2) * $xchar;
		my $x1 = $x - $width / 2;
		my $x2 = $x + $width / 2;
		my $y1 = $y - $ychar / 2 - 2;
		my $y2 = $y + $ychar / 2 + 2;
		print {$self->{fh}} "rect $x1,$y1,$x2,$y2,0,0,0\n";
		$leftx = $x1;
		$rightx = $x2;
		$topy = $y1;
		$bottomy = $y2;
		if (defined($ref)) {
			push( @{$self->{maps}}, [ $ref, $alt, "rect", $x1, $y1, $x2, $y2 ] );
		}
		$x1 = $x;
		$y1 = $y;
		print {$self->{fh}} "fill $x1,$y1,255,255,255\n";
		$x1 = $x - $width / 2 + $xchar;
		$y1 = $y - $ychar / 2;
		print {$self->{fh}} "string 0,0,0,$x1,$y1,small,$text\n";
		# no value or arrow supported
	}
	return($leftx,$topy,$rightx,$bottomy);
}

###########################################################################
#
# Show Title on Map
#

sub map_title {
	my $self = shift;
	my($title,$startdate,$enddate) = @_;

	my $x = 20;
	my $y = 20;
	$self->text(2,"$title",$x,$y);
	$self->text(2,"(from $startdate",$x,$y+20,undef,undef,undef,"small");
	$self->text(2,"to $enddate)",$x,$y+35,undef,undef,undef,"small");
	$y = $self->{height} - 20;
	$self->text(2,"Created with aWebVisit-Map $VERSION",$x,$y,"http://mikespub.net/tools/aWebVisit/",undef,undef,"small");
}

###########################################################################
#
# Show Buttons on Map
#

sub map_buttons {
	my $self = shift;
	my($pagenr,$type) = @_;

	my $midx = $self->{width} / 2;

	my %form;
	if ($type != -1) {
		$form{'summary'} = 0;
		$form{'entry'} = 2;
		$form{'exit'} = 3;
		$form{'transit'} = 4;
		$form{'details'} = 1;
		$form{'top'} = $type;
	}
	else {
		$form{'summary'} = 10;
		$form{'entry'} = 12;
		$form{'exit'} = 13;
		$form{'transit'} = 14;
		$form{'details'} = '';
		$form{'top'} = '';
	}

	my $x = $midx - 120;
	my $y = 20;
	$self->box(7,"Summary","",$x,$y,"$pagenr&f=$form{'summary'}");
	$y = $self->{height} - 20;
	$self->box(7,"Summary","",$x,$y,"$pagenr&f=$form{'summary'}");

	$x = $midx - 60;
	$y = 20;
	$self->box(7," Entry ","",$x,$y,"$pagenr&f=$form{'entry'}");
	$y = $self->{height} - 20;
	$self->box(7," Entry ","",$x,$y,"$pagenr&f=$form{'entry'}");

	$x = $midx;
	$y = 20;
	$self->box(7,"Transit","",$x,$y,"$pagenr&f=$form{'transit'}");
	$y = $self->{height} - 20;
	$self->box(7,"Transit","",$x,$y,"$pagenr&f=$form{'transit'}");

	$x = $midx + 60;
	$y = 20;
	$self->box(7,"  Exit ","",$x,$y,"$pagenr&f=$form{'exit'}");
	$y = $self->{height} - 20;
	$self->box(7,"  Exit ","",$x,$y,"$pagenr&f=$form{'exit'}");

	$x = $midx + 120;
	$y = 20;
	$self->box(7,"Details","",$x,$y,"$pagenr&f=$form{'details'}");
	$y = $self->{height} - 20;
	$self->box(7,"Details","",$x,$y,"$pagenr&f=$form{'details'}");

	$x = $midx + 180;
	$y = 20;
	$self->box(7,"  Top  ","",$x,$y,"&f=$form{'top'}");
	$y = $self->{height} - 20;
	$self->box(7,"  Top  ","",$x,$y,"&f=$form{'top'}");
}

###########################################################################
#
# Show Page on Map
#

sub map_page {
	my $self = shift;
	my($dir,$x,$y,$url,$pagenr,$entryurl,$transiturl,$exiturl,$hitrunurl,$timeval) = @_;

# keep these values !
	my($leftx,$topy,$rightx,$bottomy) = $self->box($dir,$url,"",$x,$y,"$pagenr&f=0");

	my $midx = int(($leftx + $rightx) / 2);
	my $midy = int(($topy + $bottomy) / 2);

	$self->line($entryurl,$midx,$topy-40,$midx,$topy,"$pagenr&f=2",undef,2);
	$self->line("",$midx-4,$topy-5,$midx,$topy,undef,undef,2);
	$self->line("",$midx+4,$topy-5,$midx,$topy,undef,undef,2);

	$self->line($hitrunurl,$leftx-40,$topy-40,$leftx,$topy,undef,undef,7);
	$self->line("",$leftx-40,$topy-40+5,$leftx-40,$topy-40,undef,undef,7);
	$self->line("",$leftx-40+4,$topy-40,$leftx-40,$topy-40,undef,undef,7);
	$self->line("",$leftx,$topy-5,$leftx,$topy,undef,undef,7);
	$self->line("",$leftx-4,$topy,$leftx,$topy,undef,undef,7);

	$self->line($transiturl,$leftx,$bottomy+10,$rightx,$bottomy+10,"$pagenr&f=4",undef,1);
	$self->line("",$leftx+5,$bottomy+10-3,$leftx,$bottomy+10,undef,undef,1);
	$self->line("",$leftx+5,$bottomy+10+3,$leftx,$bottomy+10,undef,undef,1);
	$self->line("",$rightx-5,$bottomy+10-3,$rightx,$bottomy+10,undef,undef,1);
	$self->line("",$rightx-5,$bottomy+10+3,$rightx,$bottomy+10,undef,undef,1);

	$self->line($exiturl,$midx,$bottomy+15,$midx,$bottomy+55,"$pagenr&f=3",undef,3);
	$self->line("",$midx-4,$bottomy+50,$midx,$bottomy+55,undef,undef,3);
	$self->line("",$midx+4,$bottomy+50,$midx,$bottomy+55,undef,undef,3);

	$self->text(2,$timeval,$rightx + 5,$topy+4,undef,undef,undef,"small");

	return($midx,$midy,$leftx,$topy,$rightx,$bottomy);
}

###########################################################################
#
# For barcharts
#

sub map_baraxis {
	my $self = shift;
	my($x1,$y1,$x2,$y2,$showtime) = @_;

	#
	# Y axis
	#
	$self->line("",$x1,$y1,$x1,$y2,undef,undef,0);
	if (!$showtime) {
		$self->line("",$x1-4,$y2-5,$x1,$y2,undef,undef,0);
		$self->line("",$x1+4,$y2-5,$x1,$y2,undef,undef,0);
	}

	#
	# X axis
	#
	$self->line("",$x1,$y1,$x2,$y1,undef,undef,0);
	$self->line("",$x2-5,$y1-3,$x2,$y1,undef,undef,0);
	$self->line("",$x2-5,$y1+3,$x2,$y1,undef,undef,0);
	$self->text(1,"Hits",$x2,$y1-15,undef,undef,undef,"small");
}

sub map_bargrid {
	my $self = shift;
	my($x1,$y1,$x2,$y2,$showtime,$maxval,$xscale,$maxtime,$timescale) = @_;

	$self->text(1,"0",$x1,$y1-15,undef,undef,undef,"small");
	$self->line("",$x1,$y1,$x1,$y1-5);

	# log base 10
	my $ten = int(log($maxval) * 0.434294);
	my $int;
	if ($maxval <= 2*10**$ten) {
		$int = 2;
	}
	elsif ($maxval <= 6*10**$ten) {
		$int = 5;
	}
	else {
		$int = 10;
	}
	$ten--;
	my $i;
	for ($i = $int*10**$ten; $i < $maxval; $i += $int*10**$ten) {
		my $x = $x1 + int($i / $xscale);
		$self->line("",$x,$y1,$x,$y2,undef,undef,7);
		$self->text(1,$i,$x,$y1-15,undef,undef,undef,"small");
		$self->line("",$x,$y1,$x,$y1-5);
	}
# add time
	if (!$showtime) {
		return;
	}
	# log base 10
	$ten = int(log($maxtime) * 0.434294);
	if ($maxtime <= 2*10**$ten) {
		$int = 2;
	}
	elsif ($maxtime <= 6*10**$ten) {
		$int = 5;
	}
	else {
		$int = 10;
	}
	$ten--;
	for ($i = $int*10**$ten; $i < $maxtime; $i += $int*10**$ten) {
		my $x = $x1 + int($i / $timescale);
		$self->text(1,$i,$x,$y2+15,undef,undef,undef,"small");
		$self->line("",$x,$y2,$x,$y2+5);
	}
	#
	# X2 axis
	#
	$self->line("",$x1,$y2,$x2,$y2,undef,undef,0);
	$self->line("",$x2-5,$y2-3,$x2,$y2,undef,undef,0);
	$self->line("",$x2-5,$y2+3,$x2,$y2,undef,undef,0);
	$self->text(1,"Time",$x2,$y2+15,undef,undef,undef,"small");
}

###########################################################################
#
# For distribution charts
#

sub map_distaxis {
	my $self = shift;
	my($x1,$y1,$x2,$y2) = @_;

	#
	# Y axis
	#
	$self->line("",$x1,$y1,$x1,$y2,undef,undef,0);
	$self->line("",$x1-4,$y1+5,$x1,$y1,undef,undef,0);
	$self->line("",$x1+4,$y1+5,$x1,$y1,undef,undef,0);

	#
	# X axis
	#
	$self->line("",$x1,$y2,$x2,$y2,undef,undef,0);
	$self->line("",$x2-5,$y2-3,$x2,$y2,undef,undef,0);
	$self->line("",$x2-5,$y2+3,$x2,$y2,undef,undef,0);
}

sub map_distgrid {
	my $self = shift;
	my($type,$x1,$y1,$x2,$y2,$maxkey,$xscale,$distscale) = @_;

	$self->text(1,"1",$x1,$y2+15,undef,undef,undef,"small");
	$self->line("",$x1,$y1,$x1,$y2+5);

	if ($type == 1) {
		foreach my $i (15,120,960,7680) {
			for (my $j = 1; $j < 5; $j++) {
				my $k = $j * $i;
				if ($k > $maxkey) {
					last;
				}
				my $x = $x1 + int(log($k) / $xscale);
				$self->line("",$x,$y1,$x,$y2,undef,undef,7);
				$self->text(1,$k,$x,$y2+15,undef,undef,undef,"small");
				$self->line("",$x,$y2,$x,$y2+5);
			}
		}
	}
	else {
		# log base 10
		my $ten = int(log($maxkey) * 0.434294);
		for (my $i = 0; $i <=$ten; $i++) {
			for (my $j = 2; $j <=10; $j += 2) {
				my $k = $j * 10**$i;
				if ($k > $maxkey) {
					last;
				}
				my $x = $x1 + int(log($k) / $xscale);
				$self->line("",$x,$y1,$x,$y2,undef,undef,7);
				$self->text(1,$k,$x,$y2+15,undef,undef,undef,"small");
				$self->line("",$x,$y2,$x,$y2+5);
			}
		}
	}
	for (my $i = 10; $i <= 100; $i += 10) {
# too bad...
#		$x = $x2-30;
		my $y = $y2 - int($i / $distscale);
		$self->line("",$x1,$y,$x2,$y,undef,undef,7);
		$self->text(3,"$i %",$x1-10,$y,undef,undef,undef,"small");
		$self->line("",$x1-5,$y,$x1,$y);
	}
}


###########################################################################
#
# AwvMap::Data
#
###########################################################################

package AwvMap::Data;

use strict;
#use vars qw( @ISA );

#use vars qw( $AUTOLOAD );

#use AwvMap;
#@ISA = qw( AwvMap );

sub new {
	my $class = shift;
	my $refs = shift;

	my $self = {};
	while (my($key,$val) = each %$refs) {
		$self->{$key} = $val;
	}
	bless($self, $class);
	return $self;
}

#sub DESTROY {
#	my $self = shift;
#
#	print "Destroying data $self\n";
#}

#sub AUTOLOAD {
#	no strict 'refs';
#	my $self = shift;
#
#	my $type = ref($self) or die "$self is not an object";
#	my $name = $AUTOLOAD;
#	$name =~ s/.*://;
#print "AUTOLOAD $name\n";
#	if (@_) {
#		return $self->{$name} = shift;
#	}
#	elsif (exists($self->{$name})) {
#		return $self->{$name};
#	}
#	else {
#		if (ref($name) eq 'SCALAR') {
#			return ${$name};
#		}
#		elsif (ref($name) eq 'ARRAY') {
#			return @{$name};
#		}
#		elsif (ref($name) eq 'HASH') {
#			return %{$name};
#		}
#		else {
#			return undef;
#		}
#	}
#}

###########################################################################
#
# Read aWebVisit statistics file
#

sub read_stats {
	my $self = shift;
	my($statfile,$delim) = @_;

	open(FILE,"<$statfile") || cleanup("Can't open statistics file '$statfile' from aWebVisit !\nReason : $!\nCheck the directory, and the access rights of the CGI script to this directory.\n");
	my $dowhat = 0;
	my $urlnr = 1;
	my ($dummy,@rest);
	while (<FILE>) {
		chomp;
		if (/^$/) {
			$dowhat = 0;
			next;
		}
		if (/^Logfile/) {
			($dummy,$self->{startdate},$self->{enddate},@rest) = split(/$delim/o);
			next;
		}
		if (/^Pages/) {
			($dummy,@{$self->{pagestat}}) = split(/$delim/o);
			$dowhat = 1;
			next;
		}
		if (/^Entries/) {
			($dummy,@{$self->{entrystat}}) = split(/$delim/o);
			$dowhat = 2;
			next;
		}
		if (/^Transits/) {
			($dummy,@{$self->{transitstat}}) = split(/$delim/o);
			$dowhat = 3;
			next;
		}
		if (/^Exits/) {
			($dummy,@{$self->{exitstat}}) = split(/$delim/o);
			$dowhat = 4;
			next;
		}
		if (/^Hit&Runs/) {
			($dummy,@{$self->{hitrunstat}}) = split(/$delim/o);
			$dowhat = 5;
			next;
		}
		if (/^Links/) {
			($dummy,@{$self->{linkstat}}) = split(/$delim/o);
			$dowhat = 6;
			next;
		}
		if (/^Incoming/) {
			($dummy,@{$self->{instat}}) = split(/$delim/o);
			$dowhat = 7;
			next;
		}
		if (/^Internal/) {
			($dummy,@{$self->{internstat}}) = split(/$delim/o);
			$dowhat = 8;
			next;
		}
		if (/^Outgoing/) {
			($dummy,@{$self->{outstat}}) = split(/$delim/o);
			$dowhat = 9;
			next;
		}
		if (/^In&Out/) {
			($dummy,@{$self->{inoutstat}}) = split(/$delim/o);
			$dowhat = 10;
			next;
		}
		if (/^Time/) {
			($dummy,@{$self->{timestat}}) = split(/$delim/o);
			$dowhat = 11;
			next;
		}
		if (/^Duration/) {
			($dummy,@{$self->{durationstat}}) = split(/$delim/o);
			$dowhat = 12;
			next;
		}
		if (/^Steps/) {
			($dummy,@{$self->{stepstat}}) = split(/$delim/o);
			$dowhat = 13;
			next;
		}
		if (/^RefPages/) {
			($dummy,@{$self->{refurlstat}}) = split(/$delim/o);
			$dowhat = 14;
			next;
		}
		if (/^RefLinks/) {
			($dummy,@{$self->{reflinkstat}}) = split(/$delim/o);
			$dowhat = 15;
			next;
		}
		if ($dowhat == 1) {
			my($key,$val,$time) = split(/$delim/o);
			push( @{$self->{pagetop}} , $key );
			$self->{pageurl}{$key} = $val;
			$self->{timeval}{$key} = $time;
			if(!defined($self->{pagenr}{$key})) {
				$self->{pagenr}{$key} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 2) {
			my($key,$val,$time) = split(/$delim/o);
			push( @{$self->{entrytop}} , $key );
			$self->{entryurl}{$key} = $val;
			$self->{timeval}{$key} = $time;
			if(!defined($self->{pagenr}{$key})) {
				$self->{pagenr}{$key} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 3) {
			my($key,$val,$time) = split(/$delim/o);
			push( @{$self->{transittop}} , $key );
			$self->{transiturl}{$key} = $val;
			$self->{timeval}{$key} = $time;
			if(!defined($self->{pagenr}{$key})) {
				$self->{pagenr}{$key} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 4) {
			my($key,$val,$time) = split(/$delim/o);
			push( @{$self->{exittop}} , $key );
			$self->{exiturl}{$key} = $val;
			$self->{timeval}{$key} = $time;
			if(!defined($self->{pagenr}{$key})) {
				$self->{pagenr}{$key} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 5) {
			my($key,$val,$time) = split(/$delim/o);
			push( @{$self->{hitruntop}} , $key );
			$self->{hitrunurl}{$key} = $val;
			$self->{timeval}{$key} = $time;
			if(!defined($self->{pagenr}{$key})) {
				$self->{pagenr}{$key} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 6) {
			my($from,$to,$val,$fromval,$toval) = split(/$delim/o);
			my $key = "$from $to";
			push( @{$self->{linktop}} , $key );
			$self->{totlink}{$key} = $val;
			if(!defined($self->{pageurl}{$from})) {
				$self->{pageurl}{$from} = $fromval;
			}
			if(!defined($self->{pageurl}{$to})) {
				$self->{pageurl}{$to} = $toval;
			}
			if(!defined($self->{pagenr}{$from})) {
				$self->{pagenr}{$from} = $urlnr;
				$urlnr++;
			}
			if(!defined($self->{pagenr}{$to})) {
				$self->{pagenr}{$to} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 7) {
			my($from,$to,$val,$fromval,$toval) = split(/$delim/o);
			my $key = "$from $to";
			push( @{$self->{intop}} , $key );
			$self->{inlink}{$key} = $val;
			if(!defined($self->{entryurl}{$from})) {
				$self->{entryurl}{$from} = $fromval;
			}
			if(!defined($self->{transiturl}{$to})) {
				$self->{transiturl}{$to} = $toval;
			}
			if(!defined($self->{pagenr}{$from})) {
				$self->{pagenr}{$from} = $urlnr;
				$urlnr++;
			}
			if(!defined($self->{pagenr}{$to})) {
				$self->{pagenr}{$to} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 8) {
			my($from,$to,$val,$fromval,$toval) = split(/$delim/o);
			my $key = "$from $to";
			push( @{$self->{interntop}} , $key );
			$self->{internlink}{$key} = $val;
			if(!defined($self->{transiturl}{$from})) {
				$self->{transiturl}{$from} = $fromval;
			}
			if(!defined($self->{transiturl}{$to})) {
				$self->{transiturl}{$to} = $toval;
			}
			if(!defined($self->{pagenr}{$from})) {
				$self->{pagenr}{$from} = $urlnr;
				$urlnr++;
			}
			if(!defined($self->{pagenr}{$to})) {
				$self->{pagenr}{$to} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 9) {
			my($from,$to,$val,$fromval,$toval) = split(/$delim/o);
			my $key = "$from $to";
			push( @{$self->{outtop}} , $key );
			$self->{outlink}{$key} = $val;
			if(!defined($self->{transiturl}{$from})) {
				$self->{transiturl}{$from} = $fromval;
			}
			if(!defined($self->{exiturl}{$to})) {
				$self->{exiturl}{$to} = $toval;
			}
			if(!defined($self->{pagenr}{$from})) {
				$self->{pagenr}{$from} = $urlnr;
				$urlnr++;
			}
			if(!defined($self->{pagenr}{$to})) {
				$self->{pagenr}{$to} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 10) {
			my($from,$to,$val,$fromval,$toval) = split(/$delim/o);
			my $key = "$from $to";
			push( @{$self->{inouttop}} , $key );
			$self->{inoutlink}{$key} = $val;
			if(!defined($self->{entryurl}{$from})) {
				$self->{entryurl}{$from} = $fromval;
			}
			if(!defined($self->{exiturl}{$to})) {
				$self->{exiturl}{$to} = $toval;
			}
			if(!defined($self->{pagenr}{$from})) {
				$self->{pagenr}{$from} = $urlnr;
				$urlnr++;
			}
			if(!defined($self->{pagenr}{$to})) {
				$self->{pagenr}{$to} = $urlnr;
				$urlnr++;
			}
			next;
		}
		if ($dowhat == 11) {
			my($key,$val,$time) = split(/$delim/o);
			push( @{$self->{timetop}} , $key );
			$self->{timeval}{$key} = $time;
# Do not keep these pages as potential candidates for maps !
#			if(!defined($self->{pagenr}{$key})) {
#				$self->{pagenr}{$key} = $urlnr;
#				$urlnr++;
#			}
			next;
		}
		if ($dowhat == 12) {
			my($key,$val) = split(/$delim/o);
			$self->{durationdist}{$key} = $val;
		}
		if ($dowhat == 13) {
			my($key,$val) = split(/$delim/o);
			$self->{stepdist}{$key} = $val;
		}
		if ($dowhat == 14) {
			my($key,$val) = split(/$delim/o);
			push( @{$self->{refurltop}} , $key );
			$self->{refurl}{$key} = $val;
#			if(!defined($self->{pagenr}{$key})) {
#				$self->{pagenr}{$key} = $urlnr;
#				$urlnr++;
#			}
			next;
		}
		if ($dowhat == 15) {
			my($from,$to,$val,$fromval,$toval) = split(/$delim/o);
			my $key = "$from $to";
			push( @{$self->{reflinktop}} , $key );
			$self->{reflink}{$key} = $val;
			if(!defined($self->{refurl}{$from})) {
				$self->{refurl}{$from} = $fromval;
			}
			if(!defined($self->{entryurl}{$to})) {
				$self->{entryurl}{$to} = $toval;
			}
#			if(!defined($self->{pagenr}{$from})) {
#				$self->{pagenr}{$from} = $urlnr;
#				$urlnr++;
#			}
			if(!defined($self->{pagenr}{$to})) {
				$self->{pagenr}{$to} = $urlnr;
				$urlnr++;
			}
			next;
		}
	}
	close(FILE);

	while (my($key,$val) = each %{$self->{pagenr}}) {
		$self->{nrpage}[$val] = $key;
	}

	$urlnr--;
	$self->{urlnr} = $urlnr;
}

sub get_page {
	my $self = shift;
	my($nr) = @_;

	if ($nr =~ /^\d+$/ && $nr >= 1 && $nr <= $self->{urlnr} && defined($self->{nrpage}[$nr])) {
		return $self->{nrpage}[$nr];
	}
	else {
		return undef;
	}
}

###########################################################################
#
# AwvMap::Top
#
###########################################################################

package AwvMap::Top;

use strict;
use vars qw( $flyprog );
#use vars qw( @ISA );

use AwvMap;
#@ISA = qw( AwvMap );

sub new {
	my $class = shift;
	my $data = shift || AwvMap::Data->new();
	$flyprog = shift || die "Please specify the location of the 'fly' program !\n";
	my $showbuttons = shift || 0;
	my $bigsite = shift || 0;
	my $topentries = shift || 7;
	my $toptransits = shift || 12;
	my $topexits = shift || 7;

	my $self = {
		data => $data,
		showbuttons => $showbuttons,
		bigsite => $bigsite,
		topentries => $topentries,
		toptransits => $toptransits,
		topexits => $topexits,
	};
	bless($self, $class);
	return $self;
}

###########################################################################
#
# Return value+color entries for barcharts
#

sub get_bars {
	my($data,$url) = @_;
	my(@vals);

	if ($data->{entryurl}{$url} > 0) {
		push(@vals, [$data->{entryurl}{$url}, 2]);
	}
	if ($data->{transiturl}{$url} > 0) {
		push(@vals, [$data->{transiturl}{$url}, 1]);
	}
	if ($data->{exiturl}{$url} > 0) {
		push(@vals, [$data->{exiturl}{$url}, 3]);
	}
	if ($data->{hitrunurl}{$url} > 0) {
		push(@vals, [$data->{hitrunurl}{$url}, 7]);
	}
	return @vals;
}

###########################################################################
#
# Return values for map_page
#

sub get_vals {
	my($data,$url) = @_;

	return($url,$data->{pagenr}{$url},$data->{entryurl}{$url},$data->{transiturl}{$url},$data->{exiturl}{$url},$data->{hitrunurl}{$url},$data->{timeval}{$url});
}

###########################################################################
#
# TOP PAGES
#

sub make_toppage {
	my $self = shift;
	my($tmpfile,$outfile) = @_;

	my $data = $self->{data};

#
# Get values
#
	my (%topnode);
	foreach my $node (sort_by_topurl($data->{pagetop},$data->{pageurl})) {
		$topnode{$node} = $data->{pageurl}{$node};
	} 

	my $topcount = keys %topnode;

	if ($topcount > $self->{toptransits}) {
		$topcount = $self->{toptransits};
	}

#
# Determine image size
#
	my $imgwidth = 100;
	$imgwidth += $topcount * 100;
	if ($imgwidth < 760) {
		$imgwidth = 760;
	}

	my $height = check_nodeheight(\%topnode,$data->{pageurl},$topcount,140);
	my $imgheight = 100 + $height + 100;
	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

#
# Show Title
#
	$fly->map_title("Top Pages Overall",$data->{startdate},$data->{enddate});

#
# Show Buttons
#
	if ($self->{showbuttons}) {
		$fly->map_buttons('n','');
	}

#
# PAGES
#

	my $x = 90;
#	$y = 170;
#	my $y = 100 + $height / 2;
	my $y = 140;
	my $topsum = 0;
	my $i = 0;
	foreach my $node (sort_by_nodeurl(\%topnode,$data->{pageurl})) {
		if ($i >= $topcount) {
			last;
		}
# trick : use map_page routine
#		$fly->map_page(0,$x,$y,get_vals($data,$node));
		$fly->map_page(2,$x,$y,get_vals($data,$node)); # align top
		if (substr($data->{pageurl}{$node},0,1) ne "<") {
			$topsum += $data->{pageurl}{$node};
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
		my $pct = sprintf("%.1f", $topsum / $data->{pagestat}[1] * 100.0);
		$fly->text(1,"These pages account for $pct % of all hits on your website.",$x,$y,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"These pages are not part of the Top Pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		$fly->text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Top Pages Overall"));
}

###########################################################################
#
# TOP ENTRIES
#

sub make_topentry {
	my $self = shift;
	my($tmpfile,$outfile) = @_;

	my $data = $self->{data};

#
# Get values
#
	my $i = 0;
	my (%topnode,%rightnode,%bottomnode);
	foreach my $node (sort_by_topurl($data->{entrytop},$data->{entryurl})) {
		if ($i >= $self->{topentries}) {
			last;
		}
		$topnode{$node} = $data->{entryurl}{$node};
		$i++;
	}
	foreach my $link (@{$data->{intop}}) {
		my ($from,$to) = split(/ /,$link);
		if (defined($topnode{$from})) {
			$rightnode{$to} += $data->{inlink}{$link};
		}
	}
	foreach my $link (@{$data->{inouttop}}) {
		my ($from,$to) = split(/ /,$link);
		if (defined($topnode{$from})) {
			$bottomnode{$to} += $data->{inoutlink}{$link};
		}
	}

	my $topcount = keys %topnode;
	my $rightcount = keys %rightnode;
	my $bottomcount = keys %bottomnode;

	if ($topcount > $self->{topentries}) {
		$topcount = $self->{topentries};
	}
	if ($rightcount > $self->{toptransits}) {
		$rightcount = $self->{toptransits};
	}
	if ($bottomcount > $self->{topexits}) {
		$bottomcount = $self->{topexits};
	}

	my $maxcount = $topcount > $bottomcount ? $topcount : $bottomcount;
#
# Determine image size
#

	my $leftwidth = 70;
#	$leftwidth = 60;
	my $midwidth = $maxcount * 70;
	my $rightwidth = check_nodewidth(\%rightnode,$data->{transiturl},$rightcount,200);
	my $imgwidth = $leftwidth + $midwidth + $rightwidth;

	my $topheight = check_nodeheight(\%topnode,$data->{entryurl},$topcount,140);
	$topheight += 30;
	my $breakheight = 40;
	my $midheight = $rightcount * 30;
	my $bottomheight = check_nodeheight(\%bottomnode,$data->{exiturl},$bottomcount,140);
	my $imgheight = $topheight + $breakheight + $midheight + $bottomheight;

	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

#
# Show Title
#
	$fly->map_title("Top Entry Pages",$data->{startdate},$data->{enddate});

#
# Show Buttons
#
	if ($self->{showbuttons}) {
		$fly->map_buttons('n','');
	}

#
# FROM ENTRY
#

	my $x = $leftwidth;
	my $y = $topheight;
	my $topsum = 0;
	$i = 0;
	my (%topX,%topY,%topNr);
	foreach my $node (sort_by_nodeurl(\%topnode,$data->{entryurl})) {
		if ($i >= $topcount) {
			last;
		}
		$fly->box(1,$node,$data->{entryurl}{$node},$x,$y,$data->{pagenr}{$node} . '&f=2',undef,1,2);
		$topX{$node} = $x;
		$topY{$node} = $y;
		$topNr{$node} = $i;
		if (substr($data->{entryurl}{$node},0,1) ne "<") {
			$topsum += $data->{entryurl}{$node};
		}
		$x += 70;
		$i++;
	}

#
# TO EXIT
#
	$x = $leftwidth;
	$y = $imgheight - $bottomheight;
	my $bottomsum = 0;
	$i = 0;
	my (%bottomX,%bottomY);
	foreach my $node (sort_by_nodeurl(\%bottomnode,$data->{exiturl})) {
		if ($i >= $bottomcount) {
			last;
		}
		$fly->box(2,$node,$data->{exiturl}{$node},$x,$y,$data->{pagenr}{$node} . '&f=3',undef,2,3);
		$bottomX{$node} = $x;
		$bottomY{$node} = $y;
		if (substr($data->{exiturl}{$node},0,1) ne "<") {
			$bottomsum += $data->{exiturl}{$node};
		}
		$x += 70;
		$i++;
	}

#
# TO TRANSIT
#
	$x = $imgwidth - $rightwidth;
	$y = $topheight + $breakheight;
	my $rightsum = 0;
	$i = 0;
	my (%rightX,%rightY);
	foreach my $node (sort_by_nodeurl(\%rightnode,$data->{transiturl})) {
		if ($i >= $rightcount) {
			last;
		}
		$fly->box(3,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . '&f=4',undef,3,1);
		$rightX{$node} = $x;
		$rightY{$node} = $y;
		if (substr($data->{transiturl}{$node},0,1) ne "<") {
			$rightsum += $data->{transiturl}{$node};
		}
		$y += 30;
		$i++;
	}

#
# Show Links
#

	my $linksum = 0;
	my (%topTotal,%bottomTotal,%rightTotal);
	foreach my $link (@{$data->{inouttop}}) {
		my ($from,$to) = split(/ /,$link);
		if (defined($topX{$from}) && defined($bottomX{$to})) {
#			$fly->line($data->{inoutlink}{$link},$topX{$from},$topY{$from},$bottomX{$to},$bottomY{$to},undef,undef,4);
			$fly->line($data->{inoutlink}{$link},$topX{$from},$topY{$from},$bottomX{$to},$bottomY{$to},undef,undef,$topNr{$from});
			$linksum += $data->{inoutlink}{$link};
			$topTotal{$from} += $data->{inoutlink}{$link};
			$bottomTotal{$to} += $data->{inoutlink}{$link};
		}
	}
	foreach my $link (@{$data->{intop}}) {
		my ($from,$to) = split(/ /,$link);
		if (defined($topX{$from}) && defined($rightX{$to})) {
#			$fly->line($data->{inlink}{$link},$topX{$from},$topY{$from},$rightX{$to},$rightY{$to},undef,undef,2);
			$fly->line($data->{inlink}{$link},$topX{$from},$topY{$from},$rightX{$to},$rightY{$to},undef,undef,$topNr{$from});
			$linksum += $data->{inlink}{$link};
			$topTotal{$from} += $data->{inlink}{$link};
			$rightTotal{$to} += $data->{inlink}{$link};
		}
	}

#
# Show Score
#

	foreach my $node (keys %topX) {
		if (!defined($topTotal{$node})) {
			$topTotal{$node} = "-";
		}
		$fly->text(1,"($topTotal{$node})",$topX{$node},$topY{$node}+8,undef,undef,undef,"small");
	}

	foreach my $node (keys %bottomX) {
		if (!defined($bottomTotal{$node})) {
			$bottomTotal{$node} = "-";
		}
		$fly->text(1,"($bottomTotal{$node})",$bottomX{$node},$bottomY{$node}-8,undef,undef,undef,"small");
	}

	foreach my $node (keys %rightX) {
		if (!defined($rightTotal{$node})) {
			$rightTotal{$node} = "-";
		}
		$fly->text(3,"($rightTotal{$node})",$rightX{$node}-5,$rightY{$node},undef,undef,undef,"small");
	}

#
# Show Statistics
#
	$x = $imgwidth / 2;
	$y = 50;
	if ($linksum > 0 && $topsum > 0) {
		my $pct = sprintf("%.1f", $topsum / $data->{entrystat}[1] * 100.0);
		$fly->text(1,"These pages account for $pct % of all entries to your website.",$x,$y,undef,undef,undef,"small");
		$pct = sprintf("%.1f", $linksum / $topsum * 100.0);
		$fly->text(1,"The links represent $pct % of all links from these entry pages.",$x,$y+15,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"These pages are not part of the Top Pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		$fly->text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Top Entry Pages"));
}

###########################################################################
#
# TOP EXITS
#

sub make_topexit {
	my $self = shift;
	my($tmpfile,$outfile) = @_;

	my $data = $self->{data};

#
# Get values
#
	my $i = 0;
	my (%topnode,%rightnode,%bottomnode);
	foreach my $node (sort_by_topurl($data->{exittop},$data->{exiturl})) {
		if ($i >= $self->{topexits}) {
			last;
		}
		$bottomnode{$node} = $data->{exiturl}{$node};
		$i++;
	}
	foreach my $link (@{$data->{inouttop}}) {
		my ($from,$to) = split(/ /,$link);
		if (defined($bottomnode{$to})) {
			$topnode{$from} += $data->{inoutlink}{$link};
		}
	}
	foreach my $link (@{$data->{outtop}}) {
		my ($from,$to) = split(/ /,$link);
		if (defined($bottomnode{$to})) {
			$rightnode{$from} += $data->{outlink}{$link};
		}
	}

	my $topcount = keys %topnode;
	my $rightcount = keys %rightnode;
	my $bottomcount = keys %bottomnode;

	if ($topcount > $self->{topentries}) {
		$topcount = $self->{topentries};
	}
	if ($rightcount > $self->{toptransits}) {
		$rightcount = $self->{toptransits};
	}
	if ($bottomcount > $self->{topexits}) {
		$bottomcount = $self->{topexits};
	}

	my $maxcount = $topcount > $bottomcount ? $topcount : $bottomcount;
#
# Determine image size
#

	my $leftwidth = 70;
	my $midwidth = $maxcount * 70;
	my $rightwidth = check_nodewidth(\%rightnode,$data->{transiturl},$rightcount,200);
	my $imgwidth = $leftwidth + $midwidth + $rightwidth;

	my $topheight = check_nodeheight(\%topnode,$data->{entryurl},$topcount,140);
	my $breakheight = 40;
	my $midheight = $rightcount * 30;
	my $bottomheight = check_nodeheight(\%bottomnode,$data->{exiturl},$bottomcount,140);
	$bottomheight += 30;
	my $imgheight = $topheight + $midheight + $breakheight + $bottomheight;

	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

#
# Show Title
#
	$fly->map_title("Top Exit Pages",$data->{startdate},$data->{enddate});

#
# Show Buttons
#
	if ($self->{showbuttons}) {
		$fly->map_buttons('n','');
	}

#
# FROM ENTRY
#

	my $x = $leftwidth;
	my $y = $topheight;
	my $topsum = 0;
	$i = 0;
	my (%topX,%topY);
	foreach my $node (sort_by_nodeurl(\%topnode,$data->{entryurl})) {
		if ($i >= $topcount) {
			last;
		}
		$fly->box(1,$node,$data->{entryurl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=2",undef,1,2);
		$topX{$node} = $x;
		$topY{$node} = $y;
		if (substr($data->{entryurl}{$node},0,1) ne "<") {
			$topsum += $data->{entryurl}{$node};
		}
		$x += 70;
		$i++;
	}

#
# TO EXIT
#
	$x = $leftwidth;
	$y = $imgheight - $bottomheight;
	my $bottomsum = 0;
	$i = 0;
	my (%bottomX,%bottomY,%bottomNr);
	foreach my $node (sort_by_nodeurl(\%bottomnode,$data->{exiturl})) {
		if ($i >= $bottomcount) {
			last;
		}
		$fly->box(2,$node,$data->{exiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=3",undef,2,3);
		$bottomX{$node} = $x;
		$bottomY{$node} = $y;
		$bottomNr{$node} = $i;
		if (substr($data->{exiturl}{$node},0,1) ne "<") {
			$bottomsum += $data->{exiturl}{$node};
		}
		$x += 70;
		$i++;
	}

#
# FROM TRANSIT
#
	$x = $imgwidth - $rightwidth;
	$y = $imgheight - $bottomheight - $breakheight;
	my $rightsum = 0;
	$i = 0;
	my (%rightX,%rightY);
	foreach my $node (sort_by_nodeurl(\%rightnode,$data->{transiturl})) {
		if ($i >= $rightcount) {
			last;
		}
		$fly->box(3,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
		$rightX{$node} = $x;
		$rightY{$node} = $y;
		if (substr($data->{transiturl}{$node},0,1) ne "<") {
			$rightsum += $data->{transiturl}{$node};
		}
		$y -= 30;
		$i++;
	}

#
# Show Links
#

	my $linksum = 0;
	my (%topTotal,%bottomTotal,%rightTotal);
	foreach my $link (@{$data->{inouttop}}) {
		my ($from,$to) = split(/ /,$link);
		if (defined($topX{$from}) && defined($bottomX{$to})) {
#			$fly->line($data->{inoutlink}{$link},$topX{$from},$topY{$from},$bottomX{$to},$bottomY{$to},undef,undef,4);
			$fly->line($data->{inoutlink}{$link},$topX{$from},$topY{$from},$bottomX{$to},$bottomY{$to},undef,undef,$bottomNr{$to});
			$linksum += $data->{inoutlink}{$link};
			$topTotal{$from} += $data->{inoutlink}{$link};
			$bottomTotal{$to} += $data->{inoutlink}{$link};
		}
	}
	foreach my $link (@{$data->{outtop}}) {
		my ($from,$to) = split(/ /,$link);
		if (defined($rightX{$from}) && defined($bottomX{$to})) {
#			$fly->line($data->{outlink}{$link},$rightX{$from},$rightY{$from},$bottomX{$to},$bottomY{$to},undef,undef,3);
			$fly->line($data->{outlink}{$link},$rightX{$from},$rightY{$from},$bottomX{$to},$bottomY{$to},undef,undef,$bottomNr{$to});
			$linksum += $data->{outlink}{$link};
			$rightTotal{$from} += $data->{outlink}{$link};
			$bottomTotal{$to} += $data->{outlink}{$link};
		}
	}

#
# Show Score
#

	foreach my $node (keys %topX) {
		$fly->text(1,"($topTotal{$node})",$topX{$node},$topY{$node}+8,undef,undef,undef,"small");
	}

	foreach my $node (keys %bottomX) {
		$fly->text(1,"($bottomTotal{$node})",$bottomX{$node},$bottomY{$node}-8,undef,undef,undef,"small");
	}

	foreach my $node (keys %rightX) {
		$fly->text(3,"($rightTotal{$node})",$rightX{$node}-5,$rightY{$node},undef,undef,undef,"small");
	}

#
# Show Statistics
#
	$x = $imgwidth / 2;
	$y = $imgheight - 60;
	if ($linksum > 0 && $bottomsum > 0) {
		my $pct = sprintf("%.1f", $bottomsum / $data->{exitstat}[1] * 100.0);
		$fly->text(1,"These pages account for $pct % of all exits from your website.",$x,$y,undef,undef,undef,"small");
		$pct = sprintf("%.1f", $linksum / $bottomsum * 100.0);
		$fly->text(1,"The links represent $pct % of all links to these exit pages.",$x,$y+15,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"These pages are not part of the Top Pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		$fly->text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Top Exit Pages"));
}

###########################################################################
#
# TOP TRANSITS
#

sub make_toptransit {
	my $self = shift;
	my($tmpfile,$outfile) = @_;

	my $data = $self->{data};

#
# Get values
#
	my $i = 0;
	my (%topnode,%rightnode,%bottomnode);
	foreach my $node (sort_by_topurl($data->{transittop},$data->{transiturl})) {
		if ($i >= $self->{toptransits}) {
			last;
		}
		$rightnode{$node} = $data->{transiturl}{$node};
		$i++;
	}
	foreach my $link (@{$data->{intop}}) {
		my ($from,$to) = split(/ /,$link);
		if (defined($rightnode{$to})) {
			$topnode{$from} += $data->{inlink}{$link};
		}
	}
	foreach my $link (@{$data->{outtop}}) {
		my ($from,$to) = split(/ /,$link);
		if (defined($rightnode{$from})) {
			$bottomnode{$to} += $data->{outlink}{$link};
		}
	}

	my $topcount = keys %topnode;
	my $bottomcount = keys %bottomnode;
	my $rightcount = keys %rightnode;

	if ($topcount > $self->{topentries}) {
		$topcount = $self->{topentries};
	}
	if ($rightcount > $self->{toptransits}) {
		$rightcount = $self->{toptransits};
	}
	if ($bottomcount > $self->{topexits}) {
		$bottomcount = $self->{topexits};
	}

	my $maxcount = $topcount > $bottomcount ? $topcount : $bottomcount;
#
# Determine image size
#

	my $leftwidth = 70;
	my $midwidth = $maxcount * 70;
	my $rightwidth = check_nodewidth(\%rightnode,$data->{transiturl},$rightcount,200);
	my $imgwidth = $leftwidth + $midwidth + $rightwidth;

	my $topheight = check_nodeheight(\%topnode,$data->{entryurl},$topcount,140);
	$topheight += 50;
	my $breakheight = 40;
	my $midheight = $rightcount * 30;
	my $bottomheight = check_nodeheight(\%bottomnode,$data->{exiturl},$bottomcount,140);
	my $imgheight = $topheight + $breakheight + $midheight + $bottomheight;

	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

#
# Show Title
#
	$fly->map_title("Top Transit Pages",$data->{startdate},$data->{enddate});

#
# Show Buttons
#
	if ($self->{showbuttons}) {
		$fly->map_buttons('n','');
	}

#
# FROM ENTRY
#

	my $x = 70;
#	$x = $midwidth;
	my $y = $topheight;
	my $topsum = 0;
	$i = 0;
	my (%topX,%topY);
	foreach my $node (sort_by_nodeurl(\%topnode,$data->{entryurl})) {
		if ($i >= $topcount) {
			last;
		}
		$fly->box(1,$node,$data->{entryurl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=2",undef,1,2);
		$topX{$node} = $x;
		$topY{$node} = $y;
		if (substr($data->{entryurl}{$node},0,1) ne "<") {
			$topsum += $data->{entryurl}{$node};
		}
		$x += 70;
#		$x -= 70;
		$i++;
	}

#
# TO EXIT
#

	$x = 70;
#	$x = $midwidth;
	$y = $imgheight - $bottomheight;
	my $bottomsum = 0;
	$i = 0;
	my (%bottomX,%bottomY);
	foreach my $node (sort_by_nodeurl(\%bottomnode,$data->{exiturl})) {
		if ($i >= $bottomcount) {
			last;
		}
		$fly->box(2,$node,$data->{exiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=3",undef,2,3);
		$bottomX{$node} = $x;
		$bottomY{$node} = $y;
		if (substr($data->{exiturl}{$node},0,1) ne "<") {
			$bottomsum += $data->{exiturl}{$node};
		}
		$x += 70;
#		$x -= 70;
		$i++;
	}

#
# FROM/TO TRANSIT
#
	$x = $imgwidth - $rightwidth;
	$y = $topheight + $breakheight;
	my $rightsum = 0;
	$i = 0;
	my (%rightX,%rightY,%rightNr);
	foreach my $node (sort_by_nodeurl(\%rightnode,$data->{transiturl})) {
		if ($i >= $rightcount) {
			last;
		}
		$fly->box(3,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
		$rightX{$node} = $x;
		$rightY{$node} = $y;
		$rightNr{$node} = $i;
		if (substr($data->{transiturl}{$node},0,1) ne "<") {
			$rightsum += $data->{transiturl}{$node};
		}
		$y += 30;
		$i++;
	}


#
# Show Links
#

	my $linksumout = 0;
	my (%topTotal,%bottomTotal,%rightTotal);
	foreach my $link (@{$data->{outtop}}) {
		my ($from,$to) = split(/ /,$link);
		if (defined($rightX{$from}) && defined($bottomX{$to})) {
#			$fly->line($data->{outlink}{$link},$rightX{$from},$rightY{$from},$bottomX{$to},$bottomY{$to},undef,undef,3);
			$fly->line($data->{outlink}{$link},$rightX{$from},$rightY{$from},$bottomX{$to},$bottomY{$to},undef,undef,$rightNr{$from});
			$linksumout += $data->{outlink}{$link};
			$rightTotal{$from} += $data->{outlink}{$link};
			$bottomTotal{$to} += $data->{outlink}{$link};
		}
	}
	my $linksumin = 0;
	foreach my $link (@{$data->{intop}}) {
		my ($from,$to) = split(/ /,$link);
		if (defined($topX{$from}) && defined($rightX{$to})) {
#			$fly->line($data->{inlink}{$link},$topX{$from},$topY{$from},$rightX{$to},$rightY{$to},undef,undef,2);
			$fly->line($data->{inlink}{$link},$topX{$from},$topY{$from},$rightX{$to},$rightY{$to},undef,undef,$rightNr{$to});
			$linksumin += $data->{inlink}{$link};
			$topTotal{$from} += $data->{inlink}{$link};
			$rightTotal{$to} += $data->{inlink}{$link};
		}
	}

#
# Show Score
#

	foreach my $node (keys %topX) {
		if (!defined($topTotal{$node})) {
			$topTotal{$node} = "-";
		}
		$fly->text(1,"($topTotal{$node})",$topX{$node},$topY{$node}+8,undef,undef,undef,"small");
	}

	foreach my $node (keys %bottomX) {
		if (!defined($bottomTotal{$node})) {
			$bottomTotal{$node} = "-";
		}
		$fly->text(1,"($bottomTotal{$node})",$bottomX{$node},$bottomY{$node}-8,undef,undef,undef,"small");
	}

	foreach my $node (keys %rightX) {
		if (!defined($rightTotal{$node})) {
			$rightTotal{$node} = "-";
		}
		$fly->text(3,"($rightTotal{$node})",$rightX{$node}-5,$rightY{$node},undef,undef,undef,"small");
	}

#
# Show Statistics
#
	$x = $imgwidth / 2;
	$y = 50;
	if (($linksumin > 0 || $linksumout > 0) && $rightsum > 0) {
		my $pct = sprintf("%.1f", $rightsum / $data->{transitstat}[1] * 100.0);
		$fly->text(1,"These pages account for $pct % of all transits inside your website.",$x,$y,undef,undef,undef,"small");
		$pct = sprintf("%.1f", $linksumin / $rightsum * 100.0);
		$fly->text(1,"The incoming links represent $pct % of all links to these transit pages.",$x,$y+15,undef,undef,undef,"small");
		$pct = sprintf("%.1f", $linksumout / $rightsum * 100.0);
		$fly->text(1,"The outgoing links represent $pct % of all links from these transit pages.",$x,$y+30,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"These pages are not part of the Top Pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		$fly->text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Top Transit Pages"));
}

###########################################################################
#
# TOP HIT&RUNS
#

sub make_tophitrun {
	my $self = shift;
	my($tmpfile,$outfile) = @_;

	my $data = $self->{data};

#
# Get values
#
	my (%topnode);
	foreach my $node (sort_by_topurl($data->{hitruntop},$data->{hitrunurl})) {
		$topnode{$node} = $data->{hitrunurl}{$node};
	} 

	my $topcount = keys %topnode;

	if ($topcount > $self->{toptransits}) {
		$topcount = $self->{toptransits};
	}

#
# Determine image size
#
	my $imgwidth = 100;
	$imgwidth += $topcount * 100;
	if ($imgwidth < 760) {
		$imgwidth = 760;
	}

	my $height = check_nodeheight(\%topnode,$data->{hitrunurl},$topcount,140);
	my $imgheight = 100 + $height + 100;
	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

#
# Show Title
#
	$fly->map_title("Top Hit&Run Pages",$data->{startdate},$data->{enddate});

#
# Show Buttons
#
	if ($self->{showbuttons}) {
		$fly->map_buttons('n','');
	}

#
# HIT&RUN
#

	my $x = 90;
#	$y = 190;
#	my $y = 100 + $height / 2;
	my $y = 140;
	my $topsum = 0;
	my $i = 0;
	foreach my $node (sort_by_nodeurl(\%topnode,$data->{hitrunurl})) {
		if ($i >= $topcount) {
			last;
		}
# trick : use map_page routine
#		$fly->map_page(1,$x,$y,get_vals($data,$node));
		$fly->map_page(2,$x,$y,get_vals($data,$node)); # align top
		if (substr($data->{hitrunurl}{$node},0,1) ne "<") {
			$topsum += $data->{hitrunurl}{$node};
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
		my $pct = sprintf("%.1f", $topsum / $data->{hitrunstat}[1] * 100.0);
		$fly->text(1,"These pages account for $pct % of all hit&runs at your website.",$x,$y,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"These pages are not part of the Top Pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		$fly->text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Top Hit&amp;Run Pages"));
}

###########################################################################
#
# TOP PAGES DETAILS
#

sub make_topdetail {
	my $self = shift;
	my($tmpfile,$outfile) = @_;

	my $data = $self->{data};

#
# Get values
#
	my $i = 0;
	my (%topnode,%midnode,%bottomnode,%rightnode,%leftnode,%toprightnode);
	foreach my $node (sort_by_topurl($data->{entrytop},$data->{entryurl})) {
		if ($i >= $self->{topentries}) {
			last;
		}
		$topnode{$node} = $data->{entryurl}{$node};
		$i++;
	}

	$i = 0;
	foreach my $node (sort_by_topurl($data->{transittop},$data->{transiturl})) {
		if ($i >= $self->{toptransits}) {
			last;
		}
		$midnode{$node} = $data->{transiturl}{$node};
		$i++;
	}

	$i = 0;
	foreach my $node (sort_by_topurl($data->{exittop},$data->{exiturl})) {
		if ($i >= $self->{topexits}) {
			last;
		}
		$bottomnode{$node} = $data->{exiturl}{$node};
		$i++;
	}

	foreach my $link (@{$data->{interntop}}) {
		my ($from,$to) = split(/ /,$link);
		if (defined($midnode{$from})) {
			$rightnode{$to} += $data->{internlink}{$link};
		}
		if (defined($midnode{$to})) {
			$leftnode{$from} += $data->{internlink}{$link};
		}
	}

	$i = 0;
	foreach my $node (sort_by_topurl($data->{hitruntop},$data->{hitrunurl})) {
		if ($i >= $self->{topentries}) {
			last;
		}
		$toprightnode{$node} = $data->{hitrunurl}{$node};
		$i++;
	}

	my $topcount = keys %topnode;
	my $bottomcount = keys %bottomnode;
	my $midcount = keys %midnode;
	my $leftcount = keys %leftnode;
	my $rightcount = keys %rightnode;
	my $toprightcount = keys %toprightnode;

	if ($topcount > $self->{topentries}) {
		$topcount = $self->{topentries};
	}
	if ($leftcount > $self->{toptransits}) {
		$leftcount = $self->{toptransits};
	}
	if ($midcount > $self->{toptransits}) {
		$midcount = $self->{toptransits};
	}
	if ($rightcount > $self->{toptransits}) {
		$rightcount = $self->{toptransits};
	}
	if ($bottomcount > $self->{topexits}) {
		$bottomcount = $self->{topexits};
	}
	if ($toprightcount > $self->{topentries}) {
		$toprightcount = $self->{topentries};
	}

	my $maxcountx = $topcount > $bottomcount ? $topcount : $bottomcount;
	my $maxcounty = $midcount > $rightcount ? $midcount : $rightcount;
	$maxcounty = $maxcounty > $leftcount ? $maxcounty : $leftcount;

#
# Determine image size
#
	my $leftwidth = check_nodewidth(\%leftnode,$data->{transiturl},$leftcount,200);
	my $breakwidth = 70;
	my $midwidth = check_nodewidth(\%midnode,$data->{transiturl},$midcount,200);
	my $linkwidth = 250;
	my $rightwidth = check_nodewidth(\%rightnode,$data->{transiturl},$rightcount,200);
	my $imgwidth = $leftwidth + $breakwidth + $maxcountx * 70 + $midwidth + $linkwidth + $rightwidth;

	my $topheight = check_nodeheight(\%topnode,$data->{entryurl},$topcount,160);
	my $tmpheight = check_nodeheight(\%toprightnode,$data->{hitrunurl},$toprightcount,160);
	if ($topheight < $tmpheight) {
		$topheight = $tmpheight;
	}
	my $breakheight = 40;
	my $midheight = $maxcounty * 30;
	my $bottomheight = check_nodeheight(\%bottomnode,$data->{exiturl},$bottomcount,160);
	my $imgheight = $topheight + $breakheight + $midheight + $bottomheight;

	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

#
# Show Title
#
	$fly->map_title("Top Pages Details",$data->{startdate},$data->{enddate});

#
# Show Buttons
#
	if ($self->{showbuttons}) {
		$fly->map_buttons('n','');
	}

#
# FROM ENTRY
#

	my $x = $leftwidth + $breakwidth;
	my $y = $topheight;
	my $topsum = 0;
	$i = 0;
	my (%topX,%topY,%topNr);
	foreach my $node (sort_by_nodeurl(\%topnode,$data->{entryurl})) {
		if ($i >= $topcount) {
			last;
		}
		$fly->box(1,$node,$data->{entryurl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=2",undef,1,2);
		$topX{$node} = $x;
		$topY{$node} = $y;
		$topNr{$node} = $i;
		if (substr($data->{entryurl}{$node},0,1) ne "<") {
			$topsum += $data->{entryurl}{$node};
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
	my $bottomsum = 0;
	$i = 0;
	my (%bottomX,%bottomY);
	foreach my $node (sort_by_nodeurl(\%bottomnode,$data->{exiturl})) {
		if ($i >= $bottomcount) {
			last;
		}
		$fly->box(2,$node,$data->{exiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=3",undef,2,3);
		$bottomX{$node} = $x;
		$bottomY{$node} = $y;
		if (substr($data->{exiturl}{$node},0,1) ne "<") {
			$bottomsum += $data->{exiturl}{$node};
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
	my $midsum = 0;
	$i = 0;
	my (%midX,%midY,%midNr);
	foreach my $node (sort_by_nodeurl(\%midnode,$data->{transiturl})) {
		if ($i >= $midcount) {
			last;
		}
		$fly->box(3,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
		$midX{$node} = $x;
		$midY{$node} = $y;
		$midNr{$node} = $i;
		if (substr($data->{transiturl}{$node},0,1) ne "<") {
			$midsum += $data->{transiturl}{$node};
		}
		$y += 30;
		$i++;
	}

#
# TO INTERN
#
	$x = $imgwidth - $rightwidth;
	$y = $topheight + $breakheight;
	my $rightsum = 0;
	$i = 0;
	my (%rightX,%rightY);
	foreach my $node (sort_by_nodeurl(\%rightnode,$data->{transiturl})) {
		if ($i >= $rightcount) {
			last;
		}
		$fly->box(3,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
		$rightX{$node} = $x;
		$rightY{$node} = $y;
		if (substr($data->{transiturl}{$node},0,1) ne "<") {
			$rightsum += $data->{transiturl}{$node};
		}
		$y += 30;
		$i++;
	}

#
# FROM INTERN
#
	$x = $leftwidth;
	$y = $topheight + $breakheight;
	my $leftsum = 0;
	$i = 0;
	my (%leftX,%leftY);
	foreach my $node (sort_by_nodeurl(\%leftnode,$data->{transiturl})) {
		if ($i >= $leftcount) {
			last;
		}
		$fly->box(4,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
		$leftX{$node} = $x;
		$leftY{$node} = $y;
		if (substr($data->{transiturl}{$node},0,1) ne "<") {
			$leftsum += $data->{transiturl}{$node};
		}
		$y += 30;
		$i++;
	}

#
# HIT&RUN
#

	$x = $leftwidth + $breakwidth + $maxcountx * 70 + 70;
	$y = $topheight;
	my $toprightsum = 0;
	$i = 0;
	foreach my $node (sort_by_nodeurl(\%toprightnode,$data->{hitrunurl})) {
		if ($i >= $toprightcount) {
			last;
		}
		$fly->box(1,$node,$data->{hitrunurl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=0",undef,3,7);
		if (substr($data->{hitrunurl}{$node},0,1) ne "<") {
			$toprightsum += $data->{hitrunurl}{$node};
		}
		$x += 70;
		$i++;
	}

#
# Show Links
#

	my $linksuminout = 0;
	my (%topTotal,%bottomTotal,%midTotalout,%midTotalin,%leftTotal,%rightTotal);
	foreach my $link (@{$data->{inouttop}}) {
		my ($from,$to) = split(/ /,$link);
		if (defined($topX{$from}) && defined($bottomX{$to})) {
#			$fly->line($data->{inoutlink}{$link},$topX{$from},$topY{$from},$bottomX{$to},$bottomY{$to},undef,undef,3);
			$fly->line($data->{inoutlink}{$link},$topX{$from},$topY{$from},$bottomX{$to},$bottomY{$to},undef,undef,$topNr{$from});
			$linksuminout += $data->{inoutlink}{$link};
			$topTotal{$from} += $data->{inoutlink}{$link};
			$bottomTotal{$to} += $data->{inoutlink}{$link};
		}
	}
	my $linksumout = 0;
	foreach my $link (@{$data->{outtop}}) {
		my ($from,$to) = split(/ /,$link);
		if (defined($midX{$from}) && defined($bottomX{$to})) {
#			$fly->line($data->{outlink}{$link},$midX{$from},$midY{$from},$bottomX{$to},$bottomY{$to},undef,undef,3);
			$fly->line($data->{outlink}{$link},$midX{$from},$midY{$from},$bottomX{$to},$bottomY{$to},undef,undef,$midNr{$from});
			$linksumout += $data->{outlink}{$link};
			$midTotalout{$from} += $data->{outlink}{$link};
			$bottomTotal{$to} += $data->{outlink}{$link};
		}
	}
	my $linksumin = 0;
	foreach my $link (@{$data->{intop}}) {
		my ($from,$to) = split(/ /,$link);
		if (defined($topX{$from}) && defined($midX{$to})) {
#			$fly->line($data->{inlink}{$link},$topX{$from},$topY{$from},$midX{$to},$midY{$to},undef,undef,2);
			$fly->line($data->{inlink}{$link},$topX{$from},$topY{$from},$midX{$to},$midY{$to},undef,undef,$topNr{$from});
			$linksumin += $data->{inlink}{$link};
			$topTotal{$from} += $data->{inlink}{$link};
			$midTotalin{$to} += $data->{inlink}{$link};
		}
	}
# tricky
	my $xchar = AwvMap::Fly->fontwidth('small');
	my $linksuminternout = 0;
	my $linksuminternin = 0;
	foreach my $link (@{$data->{interntop}}) {
		my ($from,$to) = split(/ /,$link);
		if (defined($midX{$from}) && defined($rightX{$to})) {
			$fly->line($data->{internlink}{$link},$midX{$from}+$midwidth,$midY{$from},$rightX{$to},$rightY{$to},undef,undef,$midNr{$from});
			$fly->line("",$midX{$from}+(length($from) + 2) * $xchar + 60,$midY{$from},$midX{$from}+$midwidth,$midY{$from},undef,undef,$midNr{$from});
			$linksuminternout += $data->{internlink}{$link};
			$midTotalout{$from} += $data->{internlink}{$link};
			$rightTotal{$to} += $data->{internlink}{$link};
		}
		if (defined($leftX{$from}) && defined($midX{$to})) {
			$fly->line($data->{internlink}{$link},$leftX{$from},$leftY{$from},$midX{$to},$midY{$to},undef,undef,$midNr{$to});
			$linksuminternin += $data->{internlink}{$link};
			$leftTotal{$from} += $data->{internlink}{$link};
			$midTotalin{$to} += $data->{internlink}{$link};
		}
	}

#
# Show Score
#

	foreach my $node (keys %topX) {
		if (!defined($topTotal{$node})) {
			$topTotal{$node} = "-";
		}
		$fly->text(1,"($topTotal{$node})",$topX{$node},$topY{$node}+8,undef,undef,undef,"small");
	}

	foreach my $node (keys %bottomX) {
		if (!defined($bottomTotal{$node})) {
			$bottomTotal{$node} = "-";
		}
		$fly->text(1,"($bottomTotal{$node})",$bottomX{$node},$bottomY{$node}-8,undef,undef,undef,"small");
	}

	foreach my $node (keys %midX) {
		if (!defined($midTotalin{$node})) {
			$midTotalin{$node} = "-";
		}
		if (!defined($midTotalout{$node})) {
			$midTotalout{$node} = "-";
		}
		$fly->text(3,"($midTotalin{$node}/$midTotalout{$node})",$midX{$node}-5,$midY{$node},undef,undef,undef,"small");
	}

	foreach my $node (keys %rightX) {
		if (!defined($rightTotal{$node})) {
			$rightTotal{$node} = "-";
		}
		$fly->text(3,"($rightTotal{$node})",$rightX{$node}-5,$rightY{$node},undef,undef,undef,"small");
	}

	foreach my $node (keys %leftX) {
		if (!defined($leftTotal{$node})) {
			$leftTotal{$node} = "-";
		}
		$fly->text(2,"($leftTotal{$node})",$leftX{$node}+5,$leftY{$node},undef,undef,undef,"small");
	}

#
# Show Statistics
#
	$x = $imgwidth / 2;
	$y = 50;
	if (($linksumin > 0 || $linksumout > 0) && $midsum > 0) {
		my $pct = sprintf("%.1f", ($topsum + $midsum + $bottomsum) / ($data->{entrystat}[1] + $data->{transitstat}[1] + $data->{exitstat}[1]) * 100.0);
		$fly->text(1,"These pages account for $pct % of all hits on your website.",$x,$y,undef,undef,undef,"small");
		$pct = sprintf("%.1f", ($linksumin + $linksumout + $linksuminout + $linksuminternin) / $data->{linkstat}[1] * 100.0);
		$fly->text(1,"These links represent $pct % of all links followed inside your website.",$x,$y+15,undef,undef,undef,"small");
#		$pct = sprintf("%.1f", ($linksumin + $linksuminout) / $topsum * 100.0);
#		$fly->text(1,"The incoming and in&out links represent $pct % of all links from these entry pages.",$x,$y+15,undef,undef,undef,"small");
#		$pct = sprintf("%.1f", ($linksumin + $linksuminternin) / $midsum * 100.0);
#		$fly->text(1,"The incoming and internal links represent $pct % of all links to these transit pages.",$x,$y+30,undef,undef,undef,"small");
#		$pct = sprintf("%.1f", ($linksuminternout + $linksumout) / $midsum * 100.0);
#		$fly->text(1,"The internal and outgoing links represent $pct % of all links from these transit pages.",$x,$y+45,undef,undef,undef,"small");
#		$pct = sprintf("%.1f", ($linksuminout + $linksumout) / $bottomsum * 100.0);
#		$fly->text(1,"The outgoing and in&out links represent $pct % of all links to these exit pages.",$x,$y+60,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"These pages are not part of the Top Pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		$fly->text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Top Pages Spaghetti"));
}

###########################################################################
#
# Make short description of maps
#

sub make_descr {
	my $self = shift;
	my($tmpfile,$outfile) = @_;

	my $data = $self->{data};

	my $imgwidth = 760;
	my $imgheight = 330;
	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

#
# Show Title
#
	$fly->map_title("Brief Overview of the Maps",$data->{startdate},$data->{enddate});

#
# Show Page
#
	my $x = $imgwidth / 2;
	my $y = 160;
	my ($midx,$midy,$leftx,$topy,$rightx,$bottomy) = $fly->map_page(0,$x,$y,
#		get_vals($data,$url));
		'[ Page ]', 'n', 'Entry', 'Transit', 'Exit', 'Hit&Run', 'Time Spent');

#	$x = $midx;
	$x = $imgwidth / 2;
	$y = 80;
	$fly->text(1,"The selected page will be shown with its different hit counts.",$x,$y,undef,undef,undef,"small");
	$fly->text(1,"You can then click on one of the arrows to go to the corresponding map.",$x,$y+15,undef,undef,undef,"small");

	$x = 160;
	$y = $midy - 30;
	$fly->box(4,"From Page 1",123,$x,$y,"",undef,3,1);
	$fly->line("Link 1",$x,$y,$leftx,$midy,undef,undef,1);

	$y = $midy + 30;
	$fly->box(4,"From Page 2",456,$x,$y,"",undef,3,1);
	$fly->line("Link 2",$x,$y,$leftx,$midy,undef,undef,1);

	$x += 50;
	$y = $midy;
	$fly->text(3,"Click on a page to go there",$x,$y,undef,undef,undef,"small");

	$x = $imgwidth - 270;
	$y = 125;
	$fly->text(2,"The different link types are identified",$x,$y,undef,undef,undef,"small");
	$y += 15;
	$fly->text(2,"by color :",$x,$y,undef,undef,undef,"small");
	$y += 15;
	$fly->text(2,"- Incoming Link",$x,$y,undef,undef,undef,"small");
	$fly->line("Link Count",$imgwidth - 160,$y,$imgwidth - 50,$y,undef,undef,2);
	$y += 15;
	$fly->text(2,"- Internal Link",$x,$y,undef,undef,undef,"small");
	$fly->line("Link Count",$imgwidth - 160,$y,$imgwidth - 50,$y,undef,undef,1);
	$y += 15;
	$fly->text(2,"- Outgoing Link",$x,$y,undef,undef,undef,"small");
	$fly->line("Link Count",$imgwidth - 160,$y,$imgwidth - 50,$y,undef,undef,3);
	$y += 15;
	$fly->text(2,"- In&Out Link",$x,$y,undef,undef,undef,"small");
	$fly->line("Link Count",$imgwidth - 160,$y,$imgwidth - 50,$y,undef,undef,4);
	$y += 15;
	$fly->text(2,"- All Links",$x,$y,undef,undef,undef,"small");
	$fly->line("Link Count",$imgwidth - 160,$y,$imgwidth - 50,$y,undef,undef,0);

#
# Show Buttons
#
	$fly->map_buttons('n','');

	$x = $imgwidth - 150;
	$y = 20;
	$fly->text(2,"try these 'buttons'",$x,$y,undef,undef,undef,"small");
	$fly->line("or",$imgwidth - 165,95,$imgwidth - 130,30,undef,undef,0);

#
# Show Statistics
#

	$x = $imgwidth / 2;
	$y = $imgheight - 80;
	$fly->text(1,"If the page in question is in the Top N pages as discovered by aWebVisit,",$x,$y,undef,undef,undef,"small");
	$fly->text(1,"some statistics will appear here. If it isn't, you may want to run",$x,$y+15,undef,undef,undef,"small");
	$fly->text(1,"aWebVisit again with a higher value for the \$toppages variable.",$x,$y+30,undef,undef,undef,"small");

	$fly->generate($flyprog,$outfile);
#	return($fly->get_map("Brief Overview of the Maps"));
	return( [ $imgwidth,$imgheight,"Brief Overview of the Maps" ] );
}

###########################################################################
#
# OVERVIEW DIAGRAM
#

sub make_overview {
	my $self = shift;
	my($tmpfile,$outfile,$showdata,@refs) = @_;

	my $data = $self->{data};

	my @nodes = (
		[ "Entry"	, 60	, 80	, $refs[0]	, "Entry Map"	], # node 0
		[ "Transit"	, 160	, 180	, $refs[1]	, "Transit Map"	], # node 1
		[ "Exit"	, 60	, 280	, $refs[2]	, "Exit Map"	], # node 2
#		[ "Hit&Run"	, 60	, 80	, $refs[3]	, "Hit&Run Map"	], # node 3
		[ "Hit&Run"	, 260	, 80	, $refs[3]	, "Hit&Run Map"	], # node 3
	);
#		[ "Entry"	, 160	, 80	, $refs[0]	, "Entry Map"	], # node 0
#		[ "Transit"	, 260	, 180	, $refs[1]	, "Transit Map"	], # node 1
#		[ "Exit"	, 160	, 280	, $refs[2]	, "Exit Map"	], # node 2
#		[ "Hit&Run"	, 60	, 80	, $refs[3]	, "Hit&Run Map"	], # node 3

	my @links = (
		[$showdata ? $data->{entrystat}[1] : ''	, ""	, 0	, undef		, "Entry Map"	, 2 ],
		[$showdata ? $data->{instat}[1] : 'Incoming'	, 0	, 1	, $refs[0]	, "Entry Map"	, 2 ],
		[$showdata ? $data->{internstat}[1] : 'Internal'	, 1	, 1	, $refs[1]	, "Transit Map"	, 1 ],
		[$showdata ? $data->{outstat}[1] : 'Outgoing'	, 1	, 2	, $refs[2]	, "Exit Map"	, 3 ],
		[$showdata ? $data->{inoutstat}[1] : 'In&Out'	, 0	, 2	, undef		, "In&Out"	, 4 ],
		[$showdata ? $data->{exitstat}[1] : ''	, 2	, ""	, undef		, "Exit Map"	, 3 ],
		[$showdata ? $data->{hitrunstat}[1] : ''	, ""	, 3	, undef		, "Hit&Run Map"	, 7 ],
	);

#	my $imgwidth = 400;
	my $imgwidth = 320;
	my $imgheight = 360;

	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);
	$fly->make_nodeimg(\@nodes,\@links,$flyprog,$outfile);
	return($fly->get_map("Overview Map"));
}

###########################################################################
#
# TOP PAGES & LINKS
#

sub make_toplink {
	my $self = shift;
	my($tmpfile,$outfile) = @_;

	my $data = $self->{data};

#
# Get values
#

	my (%topnode);
	$topnode{entry} = $data->{entrytop}[0];
	$topnode{transit} = $data->{transittop}[0];
	$topnode{exit} = $data->{exittop}[0];
	$topnode{page} = $data->{pagetop}[0];
	$topnode{hitrun} = $data->{hitruntop}[0];

	my ($from,$to) = split(/ /,$data->{linktop}[0]);
	$topnode{link_from} = $from;
	$topnode{link_to} = $to;
	($from,$to) = split(/ /,$data->{intop}[0]);
	$topnode{in_from} = $from;
	$topnode{in_to} = $to;
	($from,$to) = split(/ /,$data->{interntop}[0]);
	$topnode{intern_from} = $from;
	$topnode{intern_to} = $to;
	($from,$to) = split(/ /,$data->{outtop}[0]);
	$topnode{out_from} = $from;
	$topnode{out_to} = $to;
	($from,$to) = split(/ /,$data->{inouttop}[0]);
	$topnode{inout_from} = $from;
	$topnode{inout_to} = $to;

	my $topcount = keys %topnode;

#
# Determine image size
#
	my $imgwidth = 100;
#	$imgwidth += $topcount * 100;
	if ($imgwidth < 760) {
		$imgwidth = 760;
	}

	my $topheight = 0;
	foreach my $node ("page", "hitrun", "entry") {
		my $height = check_urlheight($topnode{$node});
		if ($height > $topheight) {
			$topheight = $height;
		}
	}
	foreach my $node ("inout_from", "in_from", "link_from") {
		my $height = check_urlheight($topnode{$node}) - 30;
		if ($height > $topheight) {
			$topheight = $height;
		}
	}
	$topheight += 40;

	my $bottomheight = 0;
	foreach my $node ("exit") {
		my $height = check_urlheight($topnode{$node});
		if ($height > $bottomheight) {
			$bottomheight = $height;
		}
	}
	foreach my $node ("inout_to", "out_to", "link_to") {
		my $height = check_urlheight($topnode{$node}) - 30;
		if ($height > $bottomheight) {
			$bottomheight = $height;
		}
	}
	my $midheight = 60;

	my $yspace = 25;

	my $imgheight = 100 + $topheight + $midheight + 4*$yspace + $midheight + $bottomheight + 100;
	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

#
# Show Title
#
	$fly->map_title("Main Pages & Links",$data->{startdate},$data->{enddate});

#
# Show Buttons
#
	if ($self->{showbuttons}) {
		$fly->map_buttons('n','');
	}

#
# PAGES
#

	my $ygap = 0;
	my $xgap = 0;

	my (%topX,%topY);
	my $x = 90;
#	$x += 100;
	my $y = 100 + $topheight + $ygap;
	my $url = "inout_from";
	my $node = $topnode{$url};
	my $pct = $data->{entrystat}[1] > 0 ? sprintf("%.1f", $data->{entryurl}{$node} / $data->{entrystat}[1] * 100.0) : "-";
	$fly->box(1,$node,"$pct %",$x,$y,$data->{pagenr}{$node} . "&f=2",undef,1,2);
#	$fly->box(1,$node,$data->{entryurl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=2",undef,1,2);
	$fly->text(1,"In&Out from",$x,$y+10,undef,undef,undef,"small");
	$topX{$url} = $x;
	$topY{$url} = $y;

	$y = $imgheight - 100 - $bottomheight - $ygap;
	$url = "inout_to";
	$node = $topnode{$url};
	$pct = $data->{exitstat}[1] > 0 ? sprintf("%.1f", $data->{exiturl}{$node} / $data->{exitstat}[1] * 100.0) : "-";
	$fly->box(2,$node,"$pct %",$x,$y,$data->{pagenr}{$node} . "&f=3",undef,2,3);
#	$fly->box(2,$node,$data->{exiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=3",undef,2,3);
	$fly->text(1,"In&Out to",$x,$y-10,undef,undef,undef,"small");
	$topX{$url} = $x;
	$topY{$url} = $y;

	$x += 70;
	$y = 100 + $topheight;
	$url = "entry";
	$node = $topnode{$url};
	$pct = $data->{entrystat}[1] > 0 ? sprintf("%.1f", $data->{entryurl}{$node} / $data->{entrystat}[1] * 100.0) : "-";
	$fly->box(1,$node,"$pct %",$x,$y,$data->{pagenr}{$node} . "&f=2",undef,1,2);
#	$fly->box(1,$node,$data->{entryurl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=2",undef,1,2);
	$fly->text(1,"Entries",$x,$y+10,undef,undef,2,"medium");
#	$fly->text(1,"Entries",$x,$y+10,undef,undef,undef,"small");
	$topX{$url} = $x;
	$topY{$url} = $y;

	$y = $imgheight - 100 - $bottomheight;
	$url = "exit";
	$node = $topnode{$url};
	$pct = $data->{exitstat}[1] > 0 ? sprintf("%.1f", $data->{exiturl}{$node} / $data->{exitstat}[1] * 100.0) : "-";
	$fly->box(2,$node,"$pct %",$x,$y,$data->{pagenr}{$node} . "&f=3",undef,2,3);
#	$fly->box(2,$node,$data->{exiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=3",undef,2,3);
	$fly->text(1,"Exits",$x,$y-10,undef,undef,3,"medium");
#	$fly->text(1,"Exits",$x,$y-10,undef,undef,undef,"small");
	$topX{$url} = $x;
	$topY{$url} = $y;

	$x += 70;
	$y = 100 + $topheight + $ygap;
	$url = "in_from";
	$node = $topnode{$url};
	$pct = $data->{entrystat}[1] > 0 ? sprintf("%.1f", $data->{entryurl}{$node} / $data->{entrystat}[1] * 100.0) : "-";
	$fly->box(1,$node,"$pct %",$x,$y,$data->{pagenr}{$node} . "&f=2",undef,1,2);
#	$fly->box(1,$node,$data->{entryurl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=2",undef,1,2);
	$fly->text(1,"Incoming from",$x,$y+10,undef,undef,undef,"small");
	$topX{$url} = $x;
	$topY{$url} = $y;

	$y = $imgheight - 100 - $bottomheight - $ygap;
	$url = "out_to";
	$node = $topnode{$url};
	$pct = $data->{exitstat}[1] > 0 ? sprintf("%.1f", $data->{exiturl}{$node} / $data->{exitstat}[1] * 100.0) : "-";
	$fly->box(2,$node,"$pct %",$x,$y,$data->{pagenr}{$node} . "&f=3",undef,2,3);
#	$fly->box(2,$node,$data->{exiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=3",undef,2,3);
	$fly->text(1,"Outgoing to",$x,$y-10,undef,undef,undef,"small");
	$topX{$url} = $x;
	$topY{$url} = $y;

	$x += 100;
	$y = 100 + $topheight + $midheight;
	$url = "in_to";
	$node = $topnode{$url};
	$pct = $data->{transitstat}[1] > 0 ? sprintf("%.1f", $data->{transiturl}{$node} / $data->{transitstat}[1] * 100.0) : "-";
	$fly->box(3,$node,"$pct%",$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
#	$fly->box(3,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
	$fly->text(3,"Incoming to",$x,$y-15,undef,undef,undef,"small");
	$topX{$url} = $x;
	$topY{$url} = $y;

	$y = 100 + $topheight + $midheight + 4*$yspace;
	$url = "out_from";
	$node = $topnode{$url};
	$pct = $data->{transitstat}[1] > 0 ? sprintf("%.1f", $data->{transiturl}{$node} / $data->{transitstat}[1] * 100.0) : "-";
	$fly->box(3,$node,"$pct%",$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
#	$fly->box(3,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
	$fly->text(3,"Outgoing from",$x,$y+15,undef,undef,undef,"small");
	$topX{$url} = $x;
	$topY{$url} = $y;

	$x += $xgap;
	$y = 100 + $topheight + $midheight + $yspace;
	$url = "intern_from";
	$node = $topnode{$url};
	$pct = $data->{transitstat}[1] > 0 ? sprintf("%.1f", $data->{transiturl}{$node} / $data->{transitstat}[1] * 100.0) : "-";
	$fly->box(3,$node,"$pct%",$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
#	$fly->box(3,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
	$fly->text(4,"Internal from",$x-5,$y,undef,undef,undef,"small");
	$topX{$url} = $x;
	$topY{$url} = $y;

	$x += 30;
	$y = 100 + $topheight + $midheight + 2*$yspace;
	$url = "transit";
	$node = $topnode{$url};
	$pct = $data->{transitstat}[1] > 0 ? sprintf("%.1f", $data->{transiturl}{$node} / $data->{transitstat}[1] * 100.0) : "-";
	$fly->box(3,$node,"$pct%",$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
#	$fly->box(3,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
#tricky
	my $xchar = AwvMap::Fly->fontwidth('small');
	my $nodewidth = (length($node) + 2) * $xchar + 60;
	$fly->text(2,"Transits",$x+$nodewidth+5,$y,undef,undef,1,"medium");
#	$fly->text(2,"Transits",$x+$nodewidth+5,$y,undef,undef,undef,"small");
	$topX{$url} = $x;
	$topY{$url} = $y;

	$x -= 30;
	$y = 100 + $topheight + $midheight + 3*$yspace;
	$url = "intern_to";
	$node = $topnode{$url};
	$pct = $data->{transitstat}[1] > 0 ? sprintf("%.1f", $data->{transiturl}{$node} / $data->{transitstat}[1] * 100.0) : "-";
	$fly->box(3,$node,"$pct%",$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
#	$fly->box(3,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
	$fly->text(4,"Internal to",$x-5,$y,undef,undef,undef,"small");
	$topX{$url} = $x;
	$topY{$url} = $y;


	$x += 150;
	$y = 100 + $topheight;
	$url = "page";
	$node = $topnode{$url};
	$pct = $data->{pagestat}[1] > 0 ? sprintf("%.1f", $data->{pageurl}{$node} / $data->{pagestat}[1] * 100.0) : "-";
	$fly->box(1,$node,"$pct %",$x,$y,$data->{pagenr}{$node} . "&f=0",undef,3,0);
#	$fly->box(1,$node,$data->{pageurl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=0",undef,3,0);
	$fly->text(1,"Overall Hits",$x,$y+10,undef,undef,0,"medium");
#	$fly->text(1,"Overall Hits",$x,$y+10,undef,undef,undef,"small");
	$topX{$url} = $x;
	$topY{$url} = $y;

	$x += 90;
	$y = 100 + $topheight;
	$url = "hitrun";
	$node = $topnode{$url};
	$pct = $data->{hitrunstat}[1] > 0 ? sprintf("%.1f", $data->{hitrunurl}{$node} / $data->{hitrunstat}[1] * 100.0) : "-";
	$fly->box(1,$node,"$pct %",$x,$y,$data->{pagenr}{$node} . "&f=2",undef,3,7);
#	$fly->box(1,$node,$data->{hitrunurl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=2",undef,3,7);
	$fly->text(1,"Hit&Runs",$x,$y+10,undef,undef,7,"medium");
#	$fly->text(1,"Hit&Runs",$x,$y+10,undef,undef,undef,"small");
	$topX{$url} = $x;
	$topY{$url} = $y;

	$x -= 90;
#	$y = 100 + $topheight + 30;
	$y = $imgheight - 100 - $bottomheight - 20;
	$url = "link_from";
	$node = $topnode{$url};
	$pct = $data->{pagestat}[1] > 0 ? sprintf("%.1f", $data->{pageurl}{$node} / $data->{pagestat}[1] * 100.0) : "-";
	$fly->box(3,$node,"$pct%",$x,$y,$data->{pagenr}{$node} . "&f=0",undef,3,0);
#	$fly->box(3,$node,$data->{pageurl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=0",undef,3,0);
	$fly->text(4,"Any from",$x-5,$y,undef,undef,undef,"small");
	$topX{$url} = $x;
	$topY{$url} = $y;

	$y += 40;
	$url = "link_to";
	$node = $topnode{$url};
	$pct = $data->{pagestat}[1] > 0 ? sprintf("%.1f", $data->{pageurl}{$node} / $data->{pagestat}[1] * 100.0) : "-";
	$fly->box(3,$node,"$pct%",$x,$y,$data->{pagenr}{$node} . "&f=0",undef,3,0);
#	$fly->box(3,$node,$data->{pageurl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=0",undef,3,0);
	$fly->text(4,"Any to",$x-5,$y,undef,undef,undef,"small");
	$topX{$url} = $x;
	$topY{$url} = $y;

	$pct = $data->{inoutstat}[1] > 0 ? sprintf("%.1f", $data->{inoutlink}{$data->{inouttop}[0]} / $data->{inoutstat}[1] * 100.0) : "-";
	$fly->line("$pct %",$topX{inout_from},$topY{inout_from},$topX{inout_to},$topY{inout_to},undef,undef,4);
#	$fly->line($data->{inoutlink}{$data->{inouttop}[0]},$topX{inout_from},$topY{inout_from},$topX{inout_to},$topY{inout_to},undef,undef,4);

	$pct = $data->{instat}[1] > 0 ? sprintf("%.1f", $data->{inlink}{$data->{intop}[0]} / $data->{instat}[1] * 100.0) : "-";
	$fly->line("$pct %",$topX{in_from},$topY{in_from},$topX{in_to},$topY{in_to},undef,undef,2);
#	$fly->line($data->{inlink}{$data->{intop}[0]},$topX{in_from},$topY{in_from},$topX{in_to},$topY{in_to},undef,undef,2);
	my $savepct = $pct;

	$pct = $data->{outstat}[1] > 0 ? sprintf("%.1f", $data->{outlink}{$data->{outtop}[0]} / $data->{outstat}[1] * 100.0) : "-";
	$fly->line("$pct %",$topX{out_from},$topY{out_from},$topX{out_to},$topY{out_to},undef,undef,3);
#	$fly->line($data->{outlink}{$data->{outtop}[0]},$topX{out_from},$topY{out_from},$topX{out_to},$topY{out_to},undef,undef,3);

	$pct = $data->{internstat}[1] > 0 ? sprintf("%.1f", $data->{internlink}{$data->{interntop}[0]} / $data->{internstat}[1] * 100.0) : "-";
	$fly->line("$pct %",$topX{intern_from},$topY{intern_from},$topX{intern_to},$topY{intern_to},undef,undef,1);
#	$fly->line($data->{internlink}{$data->{interntop}[0]},$topX{intern_from},$topY{intern_from},$topX{intern_to},$topY{intern_to},undef,undef,1);

	$pct = $data->{linkstat}[1] > 0 ? sprintf("%.1f", $data->{totlink}{$data->{linktop}[0]} / $data->{linkstat}[1] * 100.0) : "-";
	$fly->line("$pct %",$topX{link_from},$topY{link_from},$topX{link_to},$topY{link_to},undef,undef,0);
#	$fly->line($data->{totlink}{$data->{linktop}[0]},$topX{link_from},$topY{link_from},$topX{link_to},$topY{link_to},undef,undef,0);

#
# Show Statistics
#
	$x = $imgwidth / 2;
	$y = 50;
	$fly->text(1,"The percentages show how much traffic is accounted for",$x,$y,undef,undef,undef,"small");
	$fly->text(1,"by that page or link (e.g. $savepct % of all incoming links).",$x,$y+15,undef,undef,undef,"small");

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Main Pages &amp; Links"));
}

###########################################################################
#
# TOP PAGES BARCHART
#

sub make_barpage {
	my $self = shift;
	my($tmpfile,$outfile,$showtime) = @_;

	my $data = $self->{data};

#
# Get values
#
	my $i = 0;
	my $maxval = 0;
	my $maxtime;
	if ($showtime) {
		$maxtime = 0;
	}
	my (%topnode);
	foreach my $node (sort_by_topurl($data->{pagetop},$data->{pageurl})) {
		if ($i >= $self->{toptransits}) {
			last;
		}
		$topnode{$node} = $data->{pageurl}{$node};
		if ($maxval < $data->{pageurl}{$node}) {
			$maxval = $data->{pageurl}{$node};
		}
		if ($showtime) {
			if ($maxtime < $data->{timeval}{$node}) {
				$maxtime = $data->{timeval}{$node};
			}
		}
		$i++;
	}

	my $topcount = keys %topnode;

	if ($topcount > $self->{toptransits}) {
		$topcount = $self->{toptransits};
	}

#
# Determine image size
#

	my $leftwidth = check_nodewidth(\%topnode,$data->{pageurl},$topcount,200);
	$leftwidth -= 30; # no arrows here
# test...
#	my $midwidth = 500;
	my $midwidth = 360;
	my $rightwidth = 60;
	my $imgwidth = $leftwidth + $midwidth + $rightwidth;

	my $topheight = 60;
	my $breakheight = 60;
# test...
#	my $midheight = $topcount * 30;
	my $midheight = $topcount * 24;
	my $bottomheight = 60;
	my $imgheight = $topheight + $breakheight + $midheight + $bottomheight;

	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

	my $xscale = $maxval / $midwidth;
	my $timescale;
	if ($showtime) {
		$timescale = $maxtime / $midwidth;
	}

#
# Show Title
#
	$fly->map_title("Top Pages Overall",$data->{startdate},$data->{enddate});

#
# Show Buttons
#
	if ($self->{showbuttons}) {
		$fly->map_buttons('n',-1);
	}

#
# Show Axis
#
	$fly->map_baraxis($leftwidth, $topheight + $breakheight - 20, $leftwidth + $midwidth + 30, $topheight + $breakheight + $midheight, $showtime);

#
# PAGE
#

	my $x = $leftwidth;
	my $y = $topheight + $breakheight;
	my $topsum = 0;
	$i = 0;
	foreach my $node (sort_by_nodeurl(\%topnode,$data->{pageurl})) {
		if ($i >= $topcount) {
			last;
		}
		$fly->box(4,$node,"",$x-15,$y,$data->{pagenr}{$node} . "&f=0");
		if (substr($data->{pageurl}{$node},0,1) ne "<") {
			$topsum += $data->{pageurl}{$node};
		}
		$fly->line("",$x-5,$y,$x,$y,undef,undef,0);
		my $pct = $data->{pagestat}[1] > 0 ? sprintf("%.1f",$data->{pageurl}{$node} / $data->{pagestat}[1] * 100.0) : "-";
		$fly->bar($node,"$pct %",$xscale,$x,$y,0,get_bars($data,$node));
#print join(' ',get_vals($data,$node),$data->{pageurl}{$node}),"\n";
		if ($showtime) {
			my $x1 = $leftwidth;
			my $x2 = $x + int($data->{timeval}{$node}/$timescale);
# hide line behind bar ???
			$fly->line("",$x1,$y,$x2-2,$y,undef,undef,0);
			$fly->rect($x2-2,$y-2,$x2+2,$y+2,0);
		}
# test...
#		$y += 30;
		$y += 24;
		$i++;
	}

#
# Show Gridlines
#
	$fly->map_bargrid($leftwidth, $topheight + $breakheight - 20, $leftwidth + $midwidth + 30, $topheight + $breakheight + $midheight, $showtime, $maxval, $xscale, $maxtime, $timescale);

#
# Show Statistics
#
# test...
#	$x = $imgwidth / 2;
	$x = $imgwidth / 2 + 30;
	$y = 50;
	if ($topsum > 0) {
		my $pct = sprintf("%.1f", $topsum / $data->{pagestat}[1] * 100.0);
		$fly->text(1,"These pages account for $pct % of all hits on your website.",$x,$y,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"These pages are not part of the Top Pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		$fly->text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Top Pages Overall"));
}

###########################################################################
#
# TOP ENTRIES BARCHART
#

sub make_barentry {
	my $self = shift;
	my($tmpfile,$outfile,$showtime) = @_;

	my $data = $self->{data};

#
# Get values
#
	my $i = 0;
	my $maxval = 0;
	my $maxtime;
	if ($showtime) {
		$maxtime = 0;
	}
	my (%topnode);
	foreach my $node (sort_by_topurl($data->{entrytop},$data->{entryurl})) {
		if ($i >= $self->{topentries}) {
			last;
		}
		$topnode{$node} = $data->{entryurl}{$node};
		if ($maxval < $data->{pageurl}{$node}) {
			$maxval = $data->{pageurl}{$node};
		}
		if ($showtime) {
			if ($maxtime < $data->{timeval}{$node}) {
				$maxtime = $data->{timeval}{$node};
			}
		}
		$i++;
	}

	my $topcount = keys %topnode;

	if ($topcount > $self->{topentries}) {
		$topcount = $self->{topentries};
	}

#
# Determine image size
#

	my $leftwidth = check_nodewidth(\%topnode,$data->{entryurl},$topcount,200);
	$leftwidth -= 30; # no arrows here
# test...
#	my $midwidth = 500;
	my $midwidth = 360;
	my $rightwidth = 60;
	my $imgwidth = $leftwidth + $midwidth + $rightwidth;

	my $topheight = 60;
	my $breakheight = 60;
# test...
#	my $midheight = $topcount * 30;
	my $midheight = $topcount * 24;
	my $bottomheight = 60;
	my $imgheight = $topheight + $breakheight + $midheight + $bottomheight;

	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

	my $xscale = $maxval / $midwidth;
	my $timescale;
	if ($showtime) {
		$timescale = $maxtime / $midwidth;
	}

#
# Show Title
#
	$fly->map_title("Top Entry Pages",$data->{startdate},$data->{enddate});

#
# Show Buttons
#
	if ($self->{showbuttons}) {
		$fly->map_buttons('n',-1);
	}

#
# Show Axis
#
	$fly->map_baraxis($leftwidth, $topheight + $breakheight - 20, $leftwidth + $midwidth + 30, $topheight + $breakheight + $midheight, $showtime);

#
# ENTRY
#

	my $x = $leftwidth;
	my $y = $topheight + $breakheight;
	my $topsum = 0;
	$i = 0;
	foreach my $node (sort_by_nodeurl(\%topnode,$data->{entryurl})) {
		if ($i >= $topcount) {
			last;
		}
		$fly->box(4,$node,"",$x-15,$y,$data->{pagenr}{$node} . "&f=2");
		if (substr($data->{entryurl}{$node},0,1) ne "<") {
			$topsum += $data->{entryurl}{$node};
		}
		$fly->line("",$x-5,$y,$x,$y,undef,undef,0);
		my $pct = $data->{entrystat}[1] > 0 ? sprintf("%.1f",$data->{entryurl}{$node} / $data->{entrystat}[1] * 100.0) : "-";
		$fly->bar($node,"$pct %",$xscale,$x,$y,2,get_bars($data,$node));
		if ($showtime) {
			my $x1 = $leftwidth;
			my $x2 = $x + int($data->{timeval}{$node}/$timescale);
# hide line behind bar ???
			$fly->line("",$x1,$y,$x2-2,$y,undef,undef,0);
			$fly->rect($x2-2,$y-2,$x2+2,$y+2,0);
		}
# test...
#		$y += 30;
		$y += 24;
		$i++;
	}

#
# Show Gridlines
#
	$fly->map_bargrid($leftwidth, $topheight + $breakheight - 20, $leftwidth + $midwidth + 30, $topheight + $breakheight + $midheight, $showtime, $maxval, $xscale, $maxtime, $timescale);

#
# Show Statistics
#
# test...
#	$x = $imgwidth / 2;
	$x = $imgwidth / 2 + 30;
	$y = 50;
	if ($topsum > 0) {
		my $pct = sprintf("%.1f", $topsum / $data->{entrystat}[1] * 100.0);
		$fly->text(1,"These pages account for $pct % of all entries to your website.",$x,$y,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"These pages are not part of the Top Pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		$fly->text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Top Entry Pages"));
}

###########################################################################
#
# TOP EXITS BARCHART
#

sub make_barexit {
	my $self = shift;
	my($tmpfile,$outfile,$showtime) = @_;

	my $data = $self->{data};

#
# Get values
#
	my $i = 0;
	my $maxval = 0;
	my $maxtime;
	if ($showtime) {
		$maxtime = 0;
	}
	my (%topnode);
	foreach my $node (sort_by_topurl($data->{exittop},$data->{exiturl})) {
#		if ($i >= $self->{topexits}) {
		if ($i >= $self->{toptransits}) {
			last;
		}
		$topnode{$node} = $data->{exiturl}{$node};
		if ($maxval < $data->{pageurl}{$node}) {
			$maxval = $data->{pageurl}{$node};
		}
		if ($showtime) {
			if ($maxtime < $data->{timeval}{$node}) {
				$maxtime = $data->{timeval}{$node};
			}
		}
		$i++;
	}

	my $topcount = keys %topnode;

#	if ($topcount > $self->{topexits}) {
#		$topcount = $self->{topexits};
	if ($topcount > $self->{toptransits}) {
		$topcount = $self->{toptransits};
	}

#
# Determine image size
#

	my $leftwidth = check_nodewidth(\%topnode,$data->{exiturl},$topcount,200);
	$leftwidth -= 30; # no arrows here
# test...
#	my $midwidth = 500;
	my $midwidth = 360;
	my $rightwidth = 60;
	my $imgwidth = $leftwidth + $midwidth + $rightwidth;

	my $topheight = 60;
	my $breakheight = 60;
# test...
#	my $midheight = $topcount * 30;
	my $midheight = $topcount * 24;
	my $bottomheight = 60;
	my $imgheight = $topheight + $breakheight + $midheight + $bottomheight;

	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

	my $xscale = $maxval / $midwidth;
	my $timescale;
	if ($showtime) {
		$timescale = $maxtime / $midwidth;
	}

#
# Show Title
#
	$fly->map_title("Top Exit Pages",$data->{startdate},$data->{enddate});

#
# Show Buttons
#
	if ($self->{showbuttons}) {
		$fly->map_buttons('n',-1);
	}

#
# Show Axis
#
	$fly->map_baraxis($leftwidth, $topheight + $breakheight - 20, $leftwidth + $midwidth + 30, $topheight + $breakheight + $midheight, $showtime);

#
# EXIT
#

	my $x = $leftwidth;
	my $y = $topheight + $breakheight;
	my $topsum = 0;
	$i = 0;
	foreach my $node (sort_by_nodeurl(\%topnode,$data->{exiturl})) {
		if ($i >= $topcount) {
			last;
		}
		$fly->box(4,$node,"",$x-15,$y,$data->{pagenr}{$node} . "&f=3");
		if (substr($data->{exiturl}{$node},0,1) ne "<") {
			$topsum += $data->{exiturl}{$node};
		}
		$fly->line("",$x-5,$y,$x,$y,undef,undef,0);
		my $pct = $data->{exitstat}[1] > 0 ? sprintf("%.1f",$data->{exiturl}{$node} / $data->{exitstat}[1] * 100.0) : "-";
		$fly->bar($node,"$pct %",$xscale,$x,$y,3,get_bars($data,$node));
		if ($showtime) {
			my $x1 = $leftwidth;
			my $x2 = $x + int($data->{timeval}{$node}/$timescale);
# hide line behind bar ???
			$fly->line("",$x1,$y,$x2-2,$y,undef,undef,0);
			$fly->rect($x2-2,$y-2,$x2+2,$y+2,0);
		}
# test...
#		$y += 30;
		$y += 24;
		$i++;
	}

#
# Show Gridlines
#
	$fly->map_bargrid($leftwidth, $topheight + $breakheight - 20, $leftwidth + $midwidth + 30, $topheight + $breakheight + $midheight, $showtime, $maxval, $xscale, $maxtime, $timescale);

#
# Show Statistics
#
# test...
#	$x = $imgwidth / 2;
	$x = $imgwidth / 2 + 30;
	$y = 50;
	if ($topsum > 0) {
		my $pct = sprintf("%.1f", $topsum / $data->{exitstat}[1] * 100.0);
		$fly->text(1,"These pages account for $pct % of all exits from your website.",$x,$y,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"These pages are not part of the Top Pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		$fly->text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Top Exit Pages"));
}

###########################################################################
#
# TOP TRANSIT BARCHART
#

sub make_bartransit {
	my $self = shift;
	my($tmpfile,$outfile,$showtime) = @_;

	my $data = $self->{data};

#
# Get values
#
	my $i = 0;
	my $maxval = 0;
	my $maxtime;
	if ($showtime) {
		$maxtime = 0;
	}
	my (%topnode);
	foreach my $node (sort_by_topurl($data->{transittop},$data->{transiturl})) {
		if ($i >= $self->{toptransits}) {
			last;
		}
		$topnode{$node} = $data->{transiturl}{$node};
		if ($maxval < $data->{pageurl}{$node}) {
			$maxval = $data->{pageurl}{$node};
		}
		if ($showtime) {
			if ($maxtime < $data->{timeval}{$node}) {
				$maxtime = $data->{timeval}{$node};
			}
		}
		$i++;
	}

	my $topcount = keys %topnode;

	if ($topcount > $self->{toptransits}) {
		$topcount = $self->{toptransits};
	}

#
# Determine image size
#

	my $leftwidth = check_nodewidth(\%topnode,$data->{transiturl},$topcount,200);
	$leftwidth -= 30; # no arrows here
# test...
#	my $midwidth = 500;
	my $midwidth = 360;
	my $rightwidth = 60;
	my $imgwidth = $leftwidth + $midwidth + $rightwidth;

	my $topheight = 60;
	my $breakheight = 60;
# test...
#	my $midheight = $topcount * 30;
	my $midheight = $topcount * 24;
	my $bottomheight = 60;
	my $imgheight = $topheight + $breakheight + $midheight + $bottomheight;

	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

	my $xscale = $maxval / $midwidth;
	my $timescale;
	if ($showtime) {
		$timescale = $maxtime / $midwidth;
	}

#
# Show Title
#
	$fly->map_title("Top Transit Pages",$data->{startdate},$data->{enddate});

#
# Show Buttons
#
	if ($self->{showbuttons}) {
		$fly->map_buttons('n',-1);
	}

#
# Show Axis
#
	$fly->map_baraxis($leftwidth, $topheight + $breakheight - 20, $leftwidth + $midwidth + 30, $topheight + $breakheight + $midheight, $showtime);

#
# TRANSIT
#

	my $x = $leftwidth;
	my $y = $topheight + $breakheight;
	my $topsum = 0;
	$i = 0;
	foreach my $node (sort_by_nodeurl(\%topnode,$data->{transiturl})) {
		if ($i >= $topcount) {
			last;
		}
		$fly->box(4,$node,"",$x-15,$y,$data->{pagenr}{$node} . "&f=4");
		if (substr($data->{transiturl}{$node},0,1) ne "<") {
			$topsum += $data->{transiturl}{$node};
		}
		$fly->line("",$x-5,$y,$x,$y,undef,undef,0);
		my $pct = $data->{transitstat}[1] > 0 ? sprintf("%.1f",$data->{transiturl}{$node} / $data->{transitstat}[1] * 100.0) : "-";
		$fly->bar($node,"$pct %",$xscale,$x,$y,1,get_bars($data,$node));
		if ($showtime) {
			my $x1 = $leftwidth;
			my $x2 = $x + int($data->{timeval}{$node}/$timescale);
# hide line behind bar ???
			$fly->line("",$x1,$y,$x2-2,$y,undef,undef,0);
			$fly->rect($x2-2,$y-2,$x2+2,$y+2,0);
		}
# test...
#		$y += 30;
		$y += 24;
		$i++;
	}

#
# Show Gridlines
#
	$fly->map_bargrid($leftwidth, $topheight + $breakheight - 20, $leftwidth + $midwidth + 30, $topheight + $breakheight + $midheight, $showtime, $maxval, $xscale, $maxtime, $timescale);

#
# Show Statistics
#
# test...
#	$x = $imgwidth / 2;
	$x = $imgwidth / 2 + 30;
	$y = 50;
	if ($topsum > 0) {
		my $pct = sprintf("%.1f", $topsum / $data->{transitstat}[1] * 100.0);
		$fly->text(1,"These pages account for $pct % of all transits inside your website.",$x,$y,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"These pages are not part of the Top Pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		$fly->text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Top Transit Pages"));
}

###########################################################################
#
# TOP HIT&RUNS BARCHART (bars)
#

sub make_barhitrun {
	my $self = shift;
	my($tmpfile,$outfile,$showtime) = @_;

	my $data = $self->{data};

#
# Get values
#
	my $i = 0;
	my $maxval = 0;
	my $maxtime;
	if ($showtime) {
		$maxtime = 0;
	}
	my (%topnode);
	foreach my $node (sort_by_topurl($data->{hitruntop},$data->{hitrunurl})) {
		if ($i >= $self->{topentries}) {
			last;
		}
		$topnode{$node} = $data->{hitrunurl}{$node};
		if ($maxval < $data->{pageurl}{$node}) {
			$maxval = $data->{pageurl}{$node};
		}
		if ($showtime) {
			if ($maxtime < $data->{timeval}{$node}) {
				$maxtime = $data->{timeval}{$node};
			}
		}
		$i++;
	}

	my $topcount = keys %topnode;

	if ($topcount > $self->{topentries}) {
		$topcount = $self->{topentries};
	}

#
# Determine image size
#

	my $leftwidth = check_nodewidth(\%topnode,$data->{hitrunurl},$topcount,200);
	$leftwidth -= 30; # no arrows here
# test...
#	my $midwidth = 500;
	my $midwidth = 360;
	my $rightwidth = 60;
	my $imgwidth = $leftwidth + $midwidth + $rightwidth;

	my $topheight = 60;
	my $breakheight = 60;
# test...
#	my $midheight = $topcount * 30;
	my $midheight = $topcount * 24;
	my $bottomheight = 60;
	my $imgheight = $topheight + $breakheight + $midheight + $bottomheight;

	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

	my $xscale = $maxval / $midwidth;
	my $timescale;
	if ($showtime) {
		$timescale = $maxtime / $midwidth;
	}

#
# Show Title
#
	$fly->map_title("Top Hit&Run Pages",$data->{startdate},$data->{enddate});

#
# Show Buttons
#
	if ($self->{showbuttons}) {
		$fly->map_buttons('n',-1);
	}

#
# Show Axis
#
	$fly->map_baraxis($leftwidth, $topheight + $breakheight - 20, $leftwidth + $midwidth + 30, $topheight + $breakheight + $midheight, $showtime);

#
# HIT&RUN
#

	my $x = $leftwidth;
	my $y = $topheight + $breakheight;
	my $topsum = 0;
	$i = 0;
	foreach my $node (sort_by_nodeurl(\%topnode,$data->{hitrunurl})) {
		if ($i >= $topcount) {
			last;
		}
		$fly->box(4,$node,"",$x-15,$y,$data->{pagenr}{$node} . "&f=2");
		if (substr($data->{hitrunurl}{$node},0,1) ne "<") {
			$topsum += $data->{hitrunurl}{$node};
		}
		$fly->line("",$x-5,$y,$x,$y,undef,undef,0);
		my $pct = $data->{hitrunstat}[1] > 0 ? sprintf("%.1f",$data->{hitrunurl}{$node} / $data->{hitrunstat}[1] * 100.0) : "-";
		$fly->bar($node,"$pct %",$xscale,$x,$y,7,get_bars($data,$node));
		if ($showtime) {
			my $x1 = $leftwidth;
			my $x2 = $x + int($data->{timeval}{$node}/$timescale);
# hide line behind bar ???
			$fly->line("",$x1,$y,$x2-2,$y,undef,undef,0);
			$fly->rect($x2-2,$y-2,$x2+2,$y+2,0);
		}
# test...
#		$y += 30;
		$y += 24;
		$i++;
	}

#
# Show Gridlines
#
	$fly->map_bargrid($leftwidth, $topheight + $breakheight - 20, $leftwidth + $midwidth + 30, $topheight + $breakheight + $midheight, $showtime, $maxval, $xscale, $maxtime, $timescale);

#
# Show Statistics
#
# test...
#	$x = $imgwidth / 2;
	$x = $imgwidth / 2 + 30;
	$y = 50;
	if ($topsum > 0) {
		my $pct = sprintf("%.1f", $topsum / $data->{hitrunstat}[1] * 100.0);
		$fly->text(1,"These pages account for $pct % of all hit&runs at your website.",$x,$y,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"These pages are not part of the Top Pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		$fly->text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Top Hit&amp;Run Pages"));
}

###########################################################################
#
# TOP HIT&RUNS BARCHART (columns)
#

sub make_barhitrun2 {
	my $self = shift;
	my($tmpfile,$outfile,$showtime) = @_;

	my $data = $self->{data};

#
# Get values
#
	my $i = 0;
	my $maxval = 0;
	my (%topnode);
	foreach my $node (sort_by_topurl($data->{hitruntop},$data->{hitrunurl})) {
		if ($i >= $self->{topentries}) {
			last;
		}
		$topnode{$node} = $data->{hitrunurl}{$node};
		if ($maxval < $data->{pageurl}{$node}) {
			$maxval = $data->{pageurl}{$node};
		}
		$i++;
	}

	my $topcount = keys %topnode;

	if ($topcount > $self->{topentries}) {
		$topcount = $self->{topentries};
	}

#
# Determine image size
#

	my $leftwidth = 60;
	my $midwidth = $topcount * 30;
	if ($midwidth < 640) {
		$midwidth = 640;
	}
	my $rightwidth = 60;
	my $imgwidth = $leftwidth + $midwidth + $rightwidth;

	my $topheight = 60;
	my $breakheight = 60;
	my $midheight = 200;
	my $bottomheight = check_nodewidth(\%topnode,$data->{hitrunurl},$topcount,200);
	$bottomheight -= 30; # no arrows here
	my $imgheight = $topheight + $breakheight + $midheight + $bottomheight;

	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

#	my $xscale = $maxval / $midwidth;
	my $yscale = $maxval / $midheight;

#
# Show Title
#
	$fly->map_title("Top Hit&Run Pages",$data->{startdate},$data->{enddate});

#
# Show Buttons
#
	if ($self->{showbuttons}) {
		$fly->map_buttons('n',-1);
	}

#
# Show Axis
#
#	$fly->map_baraxis($leftwidth, $topheight + $breakheight - 20, $leftwidth + $midwidth + 30, $topheight + $breakheight + $midheight, $showtime);

#
# HIT&RUN
#

	my $x = $leftwidth + ($midwidth - $topcount * 30)/2;
	my $y = $topheight + $breakheight + $midheight;
	my $topsum = 0;
	$i = 0;
	foreach my $node (sort_by_nodeurl(\%topnode,$data->{hitrunurl})) {
		if ($i >= $topcount) {
			last;
		}
		$fly->box(6,$node,"",$x,$y+15,$data->{pagenr}{$node} . "&f=2");
		if (substr($data->{hitrunurl}{$node},0,1) ne "<") {
			$topsum += $data->{hitrunurl}{$node};
		}
#		$fly->line("",$x-5,$y,$x,$y,undef,undef,0);
		my $pct = $data->{hitrunstat}[1] > 0 ? sprintf("%.1f",$data->{hitrunurl}{$node} / $data->{hitrunstat}[1] * 100.0) : "-";
#		$fly->bar($node,"$pct %",$xscale,$x,$y,7,get_bars($data,$node));
		$fly->column($node,"$pct %",$yscale,$x,$y,7,get_bars($data,$node));
#		$y += 30;
		$x += 30;
		$i++;
	}

#
# Show Gridlines
#
#	$fly->map_bargrid($leftwidth, $topheight + $breakheight - 20, $leftwidth + $midwidth + 30, $topheight + $breakheight + $midheight, $showtime, $maxval, $xscale, $maxtime, $timescale);

#
# Show Statistics
#
	$x = $imgwidth / 2;
	$y = 50;
	if ($topsum > 0) {
		my $pct = sprintf("%.1f", $topsum / $data->{hitrunstat}[1] * 100.0);
		$fly->text(1,"These pages account for $pct % of all hit&runs at your website.",$x,$y,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"These pages are not part of the Top Pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		$fly->text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Top Hit&amp;Run Pages"));
}

###########################################################################
#
# Convert seconds in HH:MM:SS
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

###########################################################################
#
# DURATION DISTRIBUTION
#

sub make_distduration {
	my $self = shift;
	my($tmpfile,$outfile) = @_;

	my $data = $self->{data};

#
# Get values
#
	my $maxkey = 0;
	my $maxval = 0;
	foreach my $key (sort {$a <=> $b} keys %{$data->{durationdist}}) {
		$maxval += $data->{durationdist}{$key};
		$data->{durationdist}{$key} = $maxval;
		if ($maxkey < $key) {
			$maxkey = $key;
		}
	}

#
# Determine image size
#

	my $leftwidth = 60;
	my $midwidth = 640;
	my $rightwidth = 60;
	my $imgwidth = $leftwidth + $midwidth + $rightwidth;

	my $topheight = 120;
	my $midheight = 280;
	my $bottomheight = 70;
	my $imgheight = $topheight + $midheight + $bottomheight;

	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

	my $xscale = log($maxkey) / $midwidth;
	my $yscale = $maxval / $midheight;

#
# Show Title
#
	$fly->map_title("Elapsed Time per Visit",$data->{startdate},$data->{enddate});

#
# Show Buttons
#
#	$midx = $imgwidth / 2;
#	$fly->map_buttons($pagenr{$url},-1);

#
# Show Axis
#
	$fly->map_distaxis($leftwidth, $topheight - 20, $leftwidth + $midwidth + 30, $topheight + $midheight);

#
# DURATION
#

	my $x1 = $leftwidth;
	my $y1 = $topheight + $midheight;
	my $x2;
	my $y2;
	my $findit = 1;
	my ($oldkey,$newkey);
	foreach my $key (sort {$a <=> $b} keys %{$data->{durationdist}}) {
		$x2 = $leftwidth + int(log($key) / $xscale);
		$y2 = $topheight + $midheight - int($data->{durationdist}{$key} / $yscale);
		$fly->rect($x2-2,$y2-2,$x2+2,$y2+2,1);
		$fly->line("",$x1,$y1,$x2,$y2,undef,undef,1);
		$x1 = $x2;
		$y1 = $y2;
		if ($findit == 1) {
			if ($data->{durationdist}{$key} > $maxval / 2) {
				$newkey = $key;
				$findit = 0;
			}
			else {
				$oldkey = $key;
			}
		}
	}
	my $mediankey = ($newkey - $oldkey) / ($data->{durationdist}{$newkey} - $data->{durationdist}{$oldkey}) * ($maxval / 2 - $data->{durationdist}{$oldkey}) + $oldkey;
	$mediankey = int($mediankey);

#
# Show Gridlines
#
	$fly->map_distgrid(1, $leftwidth, $topheight - 20, $leftwidth + $midwidth + 30, $topheight + $midheight, $maxkey, $xscale, 100 / $midheight);

#
# Show Min./Avg./Max./Median
#

	my $key = $data->{durationstat}[0];
	if ($key > 1) {
		my $x = $leftwidth + int(log($key) / $xscale);
		$y1 = $topheight - 20;
		$y2 = $topheight + $midheight;
		$fly->line("",$x,$y1,$x,$y2,undef,undef,1);
		$fly->text(1,"Min.",$x,$y1 - 20,undef,undef,1,"small");
		$fly->text(1,time2hms($key),$x,$y1 - 10,undef,undef,1,"small");
	}

	$key = $data->{durationstat}[1];
	if ($key > 1) {
		my $x = $leftwidth + int(log($key) / $xscale);
		$y1 = $topheight - 20;
		$y2 = $topheight + $midheight;
		$fly->line("",$x,$y1,$x,$y2,undef,undef,1);
		$fly->text(1,"Avg.",$x,$y1 - 20,undef,undef,1,"small");
		$fly->text(1,time2hms($key),$x,$y1 - 10,undef,undef,1,"small");
	}

	$key = $data->{durationstat}[2];
	if ($key > 1) {
		my $x = $leftwidth + int(log($key) / $xscale);
		$y1 = $topheight - 20;
		$y2 = $topheight + $midheight;
		$fly->line("",$x,$y1,$x,$y2,undef,undef,1);
		$fly->text(1,"Max.",$x,$y1 - 20,undef,undef,1,"small");
		$fly->text(1,time2hms($key),$x,$y1 - 10,undef,undef,1,"small");
	}

	$key = $mediankey;
	if ($key >= 1) {
		my $x = $leftwidth + int(log($key) / $xscale);
		$y1 = $topheight - 20;
		$y2 = $topheight + $midheight;
		$fly->line("",$x,$y1,$x,$y2,undef,undef,1);
		$fly->text(1,"Median",$x,$y1 - 20,undef,undef,1,"small");
		$fly->text(1,time2hms($key),$x,$y1 - 10,undef,undef,1,"small");
	}
	else {
		my $x = $leftwidth;
		$y1 = $topheight - 20;
		$y2 = $topheight + $midheight;
		$fly->line("",$x,$y1,$x,$y2,undef,undef,1);
		$fly->text(1,"Median",$x,$y1 - 20,undef,undef,1,"small");
		$fly->text(1,time2hms($key),$x,$y1 - 10,undef,undef,1,"small");
	}

#
# Show Statistics
#
	$x1 = $imgwidth / 2;
	$y1 = 50;
	$fly->text(1,"Cumulative distribution of the length of visit in time (sec).",$x1,$y1,undef,undef,undef,"small");

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Elapsed Time per Visit"));
}

###########################################################################
#
# STEP DISTRIBUTION
#

sub make_diststep {
	my $self = shift;
	my($tmpfile,$outfile) = @_;

	my $data = $self->{data};

#
# Get values
#
	my $maxkey = 0;
	my $maxval = 0;
	foreach my $key (sort {$a <=> $b} keys %{$data->{stepdist}}) {
		$maxval += $data->{stepdist}{$key};
		$data->{stepdist}{$key} = $maxval;
		if ($maxkey < $key) {
			$maxkey = $key;
		}
	}

#
# Determine image size
#

	my $leftwidth = 60;
	my $midwidth = 640;
	my $rightwidth = 60;
	my $imgwidth = $leftwidth + $midwidth + $rightwidth;

	my $topheight = 120;
	my $midheight = 280;
	my $bottomheight = 70;
	my $imgheight = $topheight + $midheight + $bottomheight;

	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

	my $xscale = log($maxkey) / $midwidth;
	my $yscale = $maxval / $midheight;
# add distribution without hit&run
#	$y3scale = ($maxval - $data->{stepdist}{1}) / $midheight;

#
# Show Title
#
	$fly->map_title("Page Hits per Visit",$data->{startdate},$data->{enddate});

#
# Show Buttons
#
#	$midx = $imgwidth / 2;
#	$fly->map_buttons($pagenr{$url},-1);

#
# Show Axis
#
	$fly->map_distaxis($leftwidth, $topheight - 20, $leftwidth + $midwidth + 30, $topheight + $midheight);

#
# STEPS
#

	my $x1 = $leftwidth;
	my $y1 = $topheight + $midheight;
	my $x2;
	my $y2;
	my $findit;
	if ($data->{stepdist}{1} < $maxval / 2) {
		$findit = 1;
	}
	else {
		$findit = 0;
	}
	my ($oldkey,$newkey);
	foreach my $key (sort {$a <=> $b} keys %{$data->{stepdist}}) {
		$x2 = $leftwidth + int(log($key) / $xscale);
		$y2 = $topheight + $midheight - int($data->{stepdist}{$key} / $yscale);
		$fly->rect($x2-2,$y2-2,$x2+2,$y2+2,1);
		$fly->line("",$x1,$y1,$x2,$y2,undef,undef,1);
# add distribution without hit&run
#		$y3 = $topheight + $midheight - int(($data->{stepdist}{$key} - $data->{stepdist}{1}) / $y3scale);
#		$fly->rect($x2-2,$y3-2,$x2+2,$y3+2,1);
		$x1 = $x2;
		$y1 = $y2;
		if ($findit == 1) {
			if ($data->{stepdist}{$key} > $maxval / 2) {
				$newkey = $key;
				$findit = 0;
			}
			else {
				$oldkey = $key;
			}
		}
	}
	my $mediankey;
	if ($data->{stepdist}{1} < $maxval / 2) {
		$mediankey = ($newkey - $oldkey) / ($data->{stepdist}{$newkey} - $data->{stepdist}{$oldkey}) * ($maxval / 2 - $data->{stepdist}{$oldkey}) + $oldkey;
	}
	else {
		$mediankey = 1;
	}
	$mediankey = sprintf("%.1f",$mediankey);

#
# Show Gridlines
#
	$fly->map_distgrid(0, $leftwidth, $topheight - 20, $leftwidth + $midwidth + 30, $topheight + $midheight, $maxkey, $xscale, 100 / $midheight);

#
# Show Min./Avg./Max./Median
#

	my $key = $data->{stepstat}[0];
	if ($key > 1) {
		my $x = $leftwidth + int(log($key) / $xscale);
		$y1 = $topheight - 20;
		$y2 = $topheight + $midheight;
		$fly->line("",$x,$y1,$x,$y2,undef,undef,1);
		$fly->text(1,"Min.",$x,$y1 - 20,undef,undef,1,"small");
		$fly->text(1,$key,$x,$y1 - 10,undef,undef,1,"small");
	}

	$key = $data->{stepstat}[1];
	if ($key > 1) {
		my $x = $leftwidth + int(log($key) / $xscale);
		$y1 = $topheight - 20;
		$y2 = $topheight + $midheight;
		$fly->line("",$x,$y1,$x,$y2,undef,undef,1);
		$fly->text(1,"Avg.",$x,$y1 - 20,undef,undef,1,"small");
		$fly->text(1,$key,$x,$y1 - 10,undef,undef,1,"small");
	}

	$key = $data->{stepstat}[2];
	if ($key > 1) {
		my $x = $leftwidth + int(log($key) / $xscale);
		$y1 = $topheight - 20;
		$y2 = $topheight + $midheight;
		$fly->line("",$x,$y1,$x,$y2,undef,undef,1);
		$fly->text(1,"Max.",$x,$y1 - 20,undef,undef,1,"small");
		$fly->text(1,$key,$x,$y1 - 10,undef,undef,1,"small");
	}

	$key = $mediankey;
	if ($key >= 1) {
		my $x = $leftwidth + int(log($key) / $xscale);
		$y1 = $topheight - 20;
		$y2 = $topheight + $midheight;
		$fly->line("",$x,$y1,$x,$y2,undef,undef,1);
		$fly->text(1,"Median",$x,$y1 - 20,undef,undef,1,"small");
		$fly->text(1,$key,$x,$y1 - 10,undef,undef,1,"small");
	}
	else {
		my $x = $leftwidth;
		$y1 = $topheight - 20;
		$y2 = $topheight + $midheight;
		$fly->line("",$x,$y1,$x,$y2,undef,undef,1);
		$fly->text(1,"Median",$x,$y1 - 20,undef,undef,1,"small");
		$fly->text(1,$key,$x,$y1 - 10,undef,undef,1,"small");
	}

#
# Show Statistics
#
	$x1 = $imgwidth / 2;
	$y1 = 50;
	$fly->text(1,"Cumulative distribution of the length of visit in page hits.",$x1,$y1,undef,undef,undef,"small");

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Page Hits per Visit"));
}

###########################################################################
#
# FROM ANY ---> URL ---> TO ANY
#

sub make_any {
	my $self = shift;
	my($url,$tmpfile,$outfile) = @_;

	my $data = $self->{data};

#
# Get values
#
	my (%leftnode,%rightnode);
	foreach my $link (@{$data->{intop}}) {
		my ($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$rightnode{$to} += $data->{inlink}{$link};
		}
		if ($to eq $url) {
			$leftnode{$from} += $data->{inlink}{$link};
		}
	}
	foreach my $link (@{$data->{interntop}}) {
		my ($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$rightnode{$to} += $data->{internlink}{$link};
		}
		if ($to eq $url) {
			$leftnode{$from} += $data->{internlink}{$link};
		}
	}
	foreach my $link (@{$data->{outtop}}) {
		my ($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$rightnode{$to} += $data->{outlink}{$link};
		}
		if ($to eq $url) {
			$leftnode{$from} += $data->{outlink}{$link};
		}
	}
	foreach my $link (@{$data->{inouttop}}) {
		my ($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$rightnode{$to} += $data->{inoutlink}{$link};
		}
		if ($to eq $url) {
			$leftnode{$from} += $data->{inoutlink}{$link};
		}
	}

	my $leftcount = keys %leftnode;
	my $rightcount = keys %rightnode;

	if ($self->{bigsite} == 1) {
		if ($leftcount > $self->{toptransits}) {
			$leftcount = $self->{toptransits};
		}
		if ($rightcount > $self->{toptransits}) {
			$rightcount = $self->{toptransits};
		}
	}

	my $maxcount = $leftcount > $rightcount ? $leftcount : $rightcount;

#
# Determine image size
#
	my $leftwidth = check_nodewidth(\%leftnode,$data->{pageurl},$leftcount,200);
	my $midwidth = 360;
	my $rightwidth = check_nodewidth(\%rightnode,$data->{pageurl},$rightcount,200);
	my $imgwidth = $leftwidth + $midwidth + $rightwidth;

	my $topheight = 140;
	my $height = check_urlheight($url);
	my $midheight = $height + $maxcount * 30;
	my $bottomheight = 110;
	my $imgheight = $topheight + $midheight + $bottomheight;

	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

#
# Show Title
#
	$fly->map_title("Summary Map",$data->{startdate},$data->{enddate});

#
# Show Page
#
	my $x = $leftwidth + $midwidth / 2;
	my $y = $topheight;
	my ($midx,$midy,$leftx,$topy,$rightx,$bottomy) = $fly->map_page(2,$x,$y,get_vals($data,$url));

#
# Show Buttons
#
	$fly->map_buttons($data->{pagenr}{$url},0);

#
# FROM ANY
#
	$x = $leftwidth;
	$y = $midy;
	my $leftsum = 0;
	my $i = 0;
	foreach my $node (sort_by_nodeurl(\%leftnode,$data->{pageurl})) {
		if ($i >= $leftcount) {
			last;
		}
		$fly->box(4,$node,$data->{pageurl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=0",undef,3);
		$fly->line($leftnode{$node},$leftx,$midy,$x,$y,undef,undef,0);
		$leftsum += $leftnode{$node};
		$y += 30;
		$i++;
	}
	if ($leftcount > 0) {
		$y = $midy - 20;
		$fly->text(3,"(from any page)",$x,$y,undef,undef,undef,"small");
		$fly->text(2," --> All Links",$x,$y,undef,undef,undef,"small");
	}

#
# TO ANY
#
	$x = $imgwidth - $rightwidth;
	$y = $midy;
	my $rightsum = 0;
	$i = 0;
	foreach my $node (sort_by_nodeurl(\%rightnode,$data->{pageurl})) {
		if ($i >= $rightcount) {
			last;
		}
		$fly->box(3,$node,$data->{pageurl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=0",undef,3);
		$fly->line($rightnode{$node},$rightx,$midy,$x,$y,undef,undef,0);
		$rightsum += $rightnode{$node};
		$y += 30;
		$i++;
	}
	if ($rightcount > 0) {
		$y = $midy - 20;
		$fly->text(2,"(to any page)",$x,$y,undef,undef,undef,"small");
		$fly->text(3,"All Links --> ",$x,$y,undef,undef,undef,"small");
	}

#
# Show Statistics
#
	$x = $midx;
	$y = 50;
	if (substr($data->{pageurl}{$url},0,1) ne "<") {
		my $pct = sprintf("%.1f", $data->{pageurl}{$url} / $data->{pagestat}[1] * 100.0);
		$fly->text(1,"This page accounts for $pct % of all hits on your website.",$x,$y,undef,undef,undef,"small");
	}
	my ($totsum1,$totsum2);
	if (substr($data->{transiturl}{$url},0,1) ne "<") {
		$totsum1 = $data->{transiturl}{$url};
		$totsum2 = $data->{transiturl}{$url};
	}
	if (substr($data->{exiturl}{$url},0,1) ne "<") {
		$totsum1 += $data->{exiturl}{$url};
	}
	if (substr($data->{entryurl}{$url},0,1) ne "<") {
		$totsum2 += $data->{entryurl}{$url};
	}
	my $pct1 = $totsum1 > 0 ? sprintf("%.1f", $leftsum / $totsum1 * 100.0) : "-";
	my $pct2 = $totsum2 > 0 ? sprintf("%.1f", $rightsum / $totsum2 * 100.0) : "-";
	if ($totsum1 > 0 || $totsum2 > 0) {
		$fly->text(1,"The links on the left represent $pct1 % of all links to this page,",$x,$y+15,undef,undef,undef,"small");
		$fly->text(1,"and the links on the right represent $pct2 % of all links from this page.",$x,$y+30,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"This page is not one of the Top Pages found by aWebVisit,",$x,$y+15,undef,undef,undef,"small");
		$fly->text(1,"so there are no hit statistics available.",$x,$y+30,undef,undef,undef,"small");
	}

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Summary Map for Page $url"));
}

###########################################################################
#
#      INOUT1   IN1   OUT1
#            \   |  /      
# INTERN1 ----  URL  ---- INTERN2
#            /   |  \      
#      INOUT2   OUT2  IN2
#

sub make_detail {
	my $self = shift;
	my($url,$tmpfile,$outfile) = @_;

	my $data = $self->{data};

#
# Get values
#
	my(%topnode,%leftnode,%rightnode,%bottomnode,%bottomrightnode,%bottomleftnode,%toprightnode,%topleftnode);
	foreach my $link (@{$data->{intop}}) {
		my ($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$bottomrightnode{$to} = $data->{inlink}{$link}; # IN2
		}
		if ($to eq $url) {
			$topnode{$from} = $data->{inlink}{$link}; # IN1
		}
	}
	foreach my $link (@{$data->{interntop}}) {
		my ($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$rightnode{$to} = $data->{internlink}{$link}; # INTERN2
		}
		if ($to eq $url) {
			$leftnode{$from} = $data->{internlink}{$link}; # INTERN1
		}
	}
	foreach my $link (@{$data->{outtop}}) {
		my ($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$bottomnode{$to} = $data->{outlink}{$link}; # OUT2
		}
		if ($to eq $url) {
			$toprightnode{$from} = $data->{outlink}{$link}; # OUT1
		}
	}
	foreach my $link (@{$data->{inouttop}}) {
		my ($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$bottomleftnode{$to} = $data->{inoutlink}{$link}; # INOUT2
		}
		if ($to eq $url) {
			$topleftnode{$from} = $data->{inoutlink}{$link}; # INOUT1
		}
	}

	my $leftcount = keys %leftnode;
	my $rightcount = keys %rightnode;
	my $topcount = keys %topnode;
	my $bottomcount = keys %bottomnode;
	my $toprightcount = keys %toprightnode;
	my $bottomrightcount = keys %bottomrightnode;
	my $topleftcount = keys %topleftnode;
	my $bottomleftcount = keys %bottomleftnode;

# IN1
	if ($topcount > $self->{topentries}) {
		$topcount = $self->{topentries};
	}
# INOUT1
	if ($topleftcount > $self->{topentries}) {
		$topleftcount = $self->{topentries};
	}
# OUT2
	if ($bottomcount > $self->{topexits}) {
		$bottomcount = $self->{topexits};
	}
# INOUT2
	if ($bottomleftcount > $self->{topexits}) {
		$bottomleftcount = $self->{topexits};
	}
# IN2
	if ($bottomrightcount > $self->{toptransits}) {
		$bottomrightcount = $self->{toptransits};
	}
# INTERN2
	if ($rightcount > $self->{toptransits}) {
		$rightcount = $self->{toptransits};
	}
# OUT1
	if ($toprightcount > $self->{toptransits}) {
		$toprightcount = $self->{toptransits};
	}
# INTERN1
	if ($leftcount > $self->{toptransits}) {
		$leftcount = $self->{toptransits};
	}

	my $maxmidx = $topcount > $bottomcount ? $topcount : $bottomcount;
	my $maxleftx = $topleftcount > $bottomleftcount ? $topleftcount : $bottomleftcount;
	my $maxrightx = $toprightcount > $bottomrightcount ? $toprightcount : $bottomrightcount;

	my $maxtopy = $topleftcount > $toprightcount ? $topleftcount : $toprightcount;
	my $maxboty = $bottomleftcount > $bottomrightcount ? $bottomleftcount : $bottomrightcount;
	my $maxmidy = $leftcount > $rightcount ? $leftcount : $rightcount;

#
# Determine image size
#
	my $leftwidth = check_nodewidth(\%leftnode,$data->{transiturl},$leftcount,200);
	my $tmpwidth = check_nodewidth(\%topleftnode,$data->{entryurl},$topleftcount,200);
	if ($leftwidth < $tmpwidth) {
		$leftwidth = $tmpwidth;
	}
	$tmpwidth = check_nodewidth(\%bottomleftnode,$data->{exiturl},$bottomleftcount,200);
	if ($leftwidth < $tmpwidth) {
		$leftwidth = $tmpwidth;
	}
	my $midwidth1;
	if ($maxleftx * 30 + $maxmidx / 2 * 70 + 70 > 180) {
		$midwidth1 = $maxleftx * 30 + $maxmidx / 2 * 70 + 70;
	}
	else {
		$midwidth1 = 180;
	}
	my $midwidth2;
	if ( 70 + $maxmidx / 2 * 70 + $maxrightx * 30 > 180) {
		$midwidth2 = 70 + $maxmidx / 2 * 70 + $maxrightx * 30;
	}
	else {
		$midwidth2 = 180;
	}
	my $rightwidth = check_nodewidth(\%rightnode,$data->{transiturl},$rightcount,200);
	$tmpwidth = check_nodewidth(\%toprightnode,$data->{transiturl},$toprightcount,200);
	if ($rightwidth < $tmpwidth) {
		$rightwidth = $tmpwidth;
	}
	$tmpwidth = check_nodewidth(\%bottomrightnode,$data->{transiturl},$bottomrightcount,200);
	if ($rightwidth < $tmpwidth) {
		$rightwidth = $tmpwidth;
	}
	my $imgwidth = $leftwidth + $midwidth1 + $midwidth2 + $rightwidth;

	my $topheight = check_nodeheight(\%topnode,$data->{entryurl},$topcount,200);
	my $height = check_urlheight($url);
	my $midheight1;
	if ($maxtopy * 30 + $maxmidy / 2 * 30 + $height / 2> 150) {
		$midheight1 = $maxtopy * 30 + $maxmidy / 2 * 30 + $height / 2;
	}
	else {
		$midheight1 = 150;
	}
	my $midheight2;
	if ($height / 2 + $maxmidy / 2 * 30 + $maxboty * 30 > 150) {
		$midheight2 = $height / 2 + $maxmidy / 2 * 30 + $maxboty * 30;
	}
	else {
		$midheight2 = 150;
	}
	my $bottomheight = check_nodeheight(\%bottomnode,$data->{exiturl},$bottomcount,150);
	my $imgheight = $topheight + $midheight1 + $midheight2 + $bottomheight;

	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

#
# Show Title
#
	$fly->map_title("Detailed Map",$data->{startdate},$data->{enddate});

#
# Show Page
#
	my $x = $leftwidth + $midwidth1;
	my $y = $topheight + $midheight1;
	my ($midx,$midy,$leftx,$topy,$rightx,$bottomy) = $fly->map_page(0,$x,$y,get_vals($data,$url));

#
# Show Buttons
#
	$fly->map_buttons($data->{pagenr}{$url},1);

#
# FROM ENTRY TO TRANSIT URL
#
	if ($topcount > 0) {
		$x = $midx - ($topcount - 1) / 2 * 70;
		$y = $topheight;
		$fly->text(3,"(from entry page)",$midx,$y+10,undef,undef,undef,"small");
		$fly->text(2," --> Incoming Link",$midx,$y+10,undef,undef,undef,"small");
		my $i = 0;
		foreach my $node (sort_by_nodeurl(\%topnode,$data->{entryurl})) {
			if ($i >= $topcount) {
				last;
			}
			$fly->box(1,$node,$data->{entryurl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=2",undef,1,2);
			my $link = "$node $url";
			$fly->line($data->{inlink}{$link},$midx,$topy,$x,$y,undef,undef,2);
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
		my $i = 0;
		foreach my $node (sort_by_nodeurl(\%toprightnode,$data->{transiturl})) {
			if ($i >= $toprightcount) {
				last;
			}
			$fly->box(3,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
			my $link = "$node $url";
			$fly->line($data->{outlink}{$link},$rightx,$topy,$x,$y,undef,undef,3);
			$x += 30;
			$y += 30;
			$i++;
		}
		$fly->text(2,"(from transit page)",$x,$y-15,undef,undef,undef,"small");
		$fly->text(3,"Outgoing Link <-- ",$x,$y-15,undef,undef,undef,"small");
	}

#
# FROM TRANSIT URL TO TRANSIT
#
	if ($rightcount > 0) {
		$x = $imgwidth - $rightwidth;
		$y = $midy - ($rightcount - 1) / 2 * 30;
		$fly->text(2,"(to transit page)",$x,$y-15,undef,undef,undef,"small");
		$fly->text(3,"Internal Link --> ",$x,$y-15,undef,undef,undef,"small");
		my $i = 0;
		foreach my $node (sort_by_nodeurl(\%rightnode,$data->{transiturl})) {
			if ($i >= $rightcount) {
				last;
			}
			$fly->box(3,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
			my $link = "$url $node";
			$fly->line($data->{internlink}{$link},$rightx,$midy,$x,$y,undef,undef,1);
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
		my $i = 0;
		foreach my $node (sort_by_nodeurl(\%bottomrightnode,$data->{transiturl})) {
			if ($i >= $bottomrightcount) {
				last;
			}
			$fly->box(3,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
			my $link = "$url $node";
			$fly->line($data->{inlink}{$link},$rightx,$bottomy,$x,$y,undef,undef,2);
			$x += 30;
			$y -= 30;
			$i++;
		}
		$fly->text(2,"(to transit page)",$x,$y+15,undef,undef,undef,"small");
		$fly->text(3,"Incoming Link --> ",$x,$y+15,undef,undef,undef,"small");
	}


#
# FROM TRANSIT URL TO EXIT
#
	if ($bottomcount > 0) {
		$x = $midx - ($bottomcount - 1) / 2 * 70;
		$y = $imgheight - $bottomheight;
		$fly->text(2,"(to exit page)",$midx,$y-10,undef,undef,undef,"small");
		$fly->text(3,"Outgoing Link --> ",$midx,$y-10,undef,undef,undef,"small");
		my $i = 0;
		foreach my $node (sort_by_nodeurl(\%bottomnode,$data->{exiturl})) {
			if ($i >= $bottomcount) {
				last;
			}
			$fly->box(2,$node,$data->{exiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=3",undef,2,3);
			my $link = "$url $node";
			$fly->line($data->{outlink}{$link},$midx,$bottomy,$x,$y,undef,undef,3);
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
		my $i = 0;
		foreach my $node (sort_by_nodeurl(\%bottomleftnode,$data->{exiturl})) {
			if ($i >= $bottomleftcount) {
				last;
			}
			$fly->box(4,$node,$data->{exiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=3",undef,2,3);
			my $link = "$url $node";
			$fly->line($data->{inoutlink}{$link},$leftx,$bottomy,$x,$y,undef,undef,4);
			$x -= 30;
			$y -= 30;
			$i++;
		}
		$fly->text(3,"(to exit page)",$x,$y+15,undef,undef,undef,"small");
		$fly->text(2," <-- In&Out Link",$x,$y+15,undef,undef,undef,"small");
	}

#
# FROM TRANSIT TO TRANSIT URL
#
	if ($leftcount > 0) {
		$x = $leftwidth;
		$y = $midy - ($leftcount - 1) / 2 * 30;
		$fly->text(3,"(from transit page)",$x,$y-15,undef,undef,undef,"small");
		$fly->text(2," --> Internal Link",$x,$y-15,undef,undef,undef,"small");
		my $i = 0;
		foreach my $node (sort_by_nodeurl(\%leftnode,$data->{transiturl})) {
			if ($i >= $leftcount) {
				last;
			}
			$fly->box(4,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
			my $link = "$node $url";
			$fly->line($data->{internlink}{$link},$leftx,$midy,$x,$y,undef,undef,1);
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
		my $i = 0;
		foreach my $node (sort_by_nodeurl(\%topleftnode,$data->{entryurl})) {
			if ($i >= $topleftcount) {
				last;
			}
			$fly->box(4,$node,$data->{entryurl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=2",undef,1,2);
			my $link = "$node $url";
			$fly->line($data->{inoutlink}{$link},$leftx,$topy,$x,$y,undef,undef,4);
			$x -= 30;
			$y += 30;
			$i++;
		}
		$fly->text(3,"(from entry page)",$x,$y-15,undef,undef,undef,"small");
		$fly->text(2," --> In&Out Link",$x,$y-15,undef,undef,undef,"small");
	}

#
# Show Statistics
#

	$x = $midx;
	$y = 50;
	if (substr($data->{entryurl}{$url},0,1) ne "<") {
		my $pct = sprintf("%.1f", $data->{entryurl}{$url} / $data->{entrystat}[1] * 100.0);
		$fly->text(1,"This page accounts for $pct % of all entries to your website,",$x,$y,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"This page is not one of the Top Entry pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
	}
	$y += 15;
	if (substr($data->{transiturl}{$url},0,1) ne "<") {
		my $pct = sprintf("%.1f", $data->{transiturl}{$url} / $data->{transitstat}[1] * 100.0);
		$fly->text(1,"for $pct % of all transits inside your website,",$x,$y,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"it is not one of the Top Transit pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
	}
	$y += 15;
	if (substr($data->{exiturl}{$url},0,1) ne "<") {
		my $pct = sprintf("%.1f", $data->{exiturl}{$url} / $data->{exitstat}[1] * 100.0);
		$fly->text(1,"for $pct % of all exits from your website,",$x,$y,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"it is not one of the Top Exit pages found by aWebVisit.",$x,$y,undef,undef,undef,"small");
	}
	$y += 15;
	if (substr($data->{hitrunurl}{$url},0,1) ne "<") {
		my $pct = sprintf("%.1f", $data->{hitrunurl}{$url} / $data->{hitrunstat}[1] * 100.0);
		$fly->text(1,"and for $pct % of all hit&runs at your website.",$x,$y,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"and it is not one of the Top Hit&Run pages found by aWebVisit.",$x,$y,undef,undef,undef,"small");
	}

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Detailed Map for Page $url"));
}

###########################################################################
#
# EXIT <--- ENTRY ---> TRANSIT
#

sub make_entry {
	my $self = shift;
	my($url,$tmpfile,$outfile) = @_;

	my $data = $self->{data};

#
# Get values
#
	my (%leftnode,%rightnode);
	foreach my $link (@{$data->{intop}}) {
		my ($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$rightnode{$to} += $data->{inlink}{$link};
		}
	}
	foreach my $link (@{$data->{inouttop}}) {
		my ($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$leftnode{$to} += $data->{inoutlink}{$link};
		}
	}

	my $leftcount = keys %leftnode;
	my $rightcount = keys %rightnode;

	if ($self->{bigsite} == 1) {
		if ($leftcount > $self->{toptransits}) {
			$leftcount = $self->{toptransits};
		}
		if ($rightcount > $self->{toptransits}) {
			$rightcount = $self->{toptransits};
		}
	}
	my $maxcount = $leftcount > $rightcount ? $leftcount : $rightcount;

#
# Determine image size
#
	my $leftwidth = check_nodewidth(\%leftnode,$data->{exiturl},$leftcount,200);
	my $midwidth = 360;
	my $rightwidth = check_nodewidth(\%rightnode,$data->{transiturl},$rightcount,200);
	my $imgwidth = $leftwidth + $midwidth + $rightwidth;

	my $topheight = 120;
	my $height = check_urlheight($url);
	my $midheight = $height + $maxcount * 30;
	my $bottomheight = 110;
	my $imgheight = $topheight + $midheight + $bottomheight;

	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

#
# Show Title
#
	$fly->map_title("Entry Map",$data->{startdate},$data->{enddate});

#
# Show Page
#
	my $x = $leftwidth + $midwidth / 2;
	my $y = $topheight;
	my ($midx,$midy,$leftx,$topy,$rightx,$bottomy) = $fly->map_page(2,$x,$y,get_vals($data,$url));

#
# Show Buttons
#
	$fly->map_buttons($data->{pagenr}{$url},2);

#
# TO EXIT
#
	$x = $leftwidth;
	$y = $bottomy + 30;
	my $leftsum = 0;
	my $i = 0;
	foreach my $node (sort_by_nodeurl(\%leftnode,$data->{exiturl})) {
		if ($i >= $leftcount) {
			last;
		}
		$fly->box(4,$node,$data->{exiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=3",undef,2,3);
		$fly->line($leftnode{$node},$leftx,$bottomy,$x,$y,undef,undef,4);
		$leftsum += $leftnode{$node};
		$y += 30;
		$i++;
	}
	if ($leftcount > 0) {
		$y = $bottomy;
		$fly->text(3,"(to exit page)",$x,$y,undef,undef,undef,"small");
		$fly->text(2," <-- In&Out Link",$x,$y,undef,undef,undef,"small");
	}

#
# TO TRANSIT
#
	$x = $imgwidth - $rightwidth;
	$y = $bottomy + 30;
	my $rightsum = 0;
	$i = 0;
	foreach my $node (sort_by_nodeurl(\%rightnode,$data->{transiturl})) {
		if ($i >= $rightcount) {
			last;
		}
		$fly->box(3,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
		$fly->line($rightnode{$node},$rightx,$bottomy,$x,$y,undef,undef,2);
		$rightsum += $rightnode{$node};
		$y += 30;
		$i++;
	}
	if ($rightcount > 0) {
		$y = $bottomy;
		$fly->text(2,"(to transit page)",$x,$y,undef,undef,undef,"small");
		$fly->text(3,"Incoming Link --> ",$x,$y,undef,undef,undef,"small");
	}

#
# Show Statistics
#
	$x = $midx;
	$y = 50;
	if (substr($data->{entryurl}{$url},0,1) ne "<") {
		my $pct = sprintf("%.1f", $data->{entryurl}{$url} / $data->{entrystat}[1] * 100.0);
		$fly->text(1,"This page accounts for $pct % of all entries to your website.",$x,$y,undef,undef,undef,"small");
		$pct = sprintf("%.1f", ($leftsum + $rightsum) / $data->{entryurl}{$url} * 100.0);
		$fly->text(1,"The links represent $pct % of all links from this entry page.",$x,$y+15,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"This page is not one of the Top Entry pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		$fly->text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Entry Map for Page $url"));
}

###########################################################################
#
# ENTRY ---> EXIT <--- TRANSIT
#

sub make_exit {
	my $self = shift;
	my($url,$tmpfile,$outfile) = @_;

	my $data = $self->{data};

#
# Get values
#
	my (%leftnode,%rightnode);
	foreach my $link (@{$data->{inouttop}}) {
		my ($from,$to) = split(/ /,$link);
		if ($to eq $url) {
			$leftnode{$from} += $data->{inoutlink}{$link};
		}
	}
	foreach my $link (@{$data->{outtop}}) {
		my ($from,$to) = split(/ /,$link);
		if ($to eq $url) {
			$rightnode{$from} += $data->{outlink}{$link};
		}
	}

	my $leftcount = keys %leftnode;
	my $rightcount = keys %rightnode;

	if ($self->{bigsite} == 1) {
		if ($leftcount > $self->{toptransits}) {
			$leftcount = $self->{toptransits};
		}
		if ($rightcount > $self->{toptransits}) {
			$rightcount = $self->{toptransits};
		}
	}

	my $maxcount = $leftcount > $rightcount ? $leftcount : $rightcount;

#
# Determine image size
#
	my $leftwidth = check_nodewidth(\%leftnode,$data->{entryurl},$leftcount,200);
	my $midwidth = 360;
	my $rightwidth = check_nodewidth(\%rightnode,$data->{transiturl},$rightcount,200);
	my $imgwidth = $leftwidth + $midwidth + $rightwidth;

	my $topheight = 110;
	my $height = check_urlheight($url);
	my $midheight = $height + $maxcount * 30;
	my $bottomheight = 140;
	my $imgheight = $topheight + $midheight + $bottomheight;

	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

#
# Show Title
#
	$fly->map_title("Exit Map",$data->{startdate},$data->{enddate});

#
# Show Page
#
	my $x = $leftwidth + $midwidth / 2;
	my $y = $imgheight - $bottomheight;
	my ($midx,$midy,$leftx,$topy,$rightx,$bottomy) = $fly->map_page(1,$x,$y,get_vals($data,$url));

#
# Show Buttons
#
	$fly->map_buttons($data->{pagenr}{$url},3);

#
# FROM ENTRY
#
	$x = $leftwidth;
	$y = $topy - 30;
	my $leftsum = 0;
	my $i = 0;
	foreach my $node (sort_by_nodeurl(\%leftnode,$data->{entryurl})) {
		if ($i >= $leftcount) {
			last;
		}
		$fly->box(4,$node,$data->{entryurl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=2",undef,1,2);
		$fly->line($leftnode{$node},$leftx,$topy,$x,$y,undef,undef,4);
		$leftsum += $leftnode{$node};
		$y -= 30;
		$i++;
	}
	if ($leftcount > 0) {
		$y = $topy;
		$fly->text(3,"(from entry page)",$x,$y,undef,undef,undef,"small");
		$fly->text(2," --> In&Out Link",$x,$y,undef,undef,undef,"small");
	}

#
# FROM TRANSIT
#
	$x = $imgwidth - $rightwidth;
	$y = $topy - 30;
	my $rightsum = 0;
	$i = 0;
	foreach my $node (sort_by_nodeurl(\%rightnode,$data->{transiturl})) {
		if ($i >= $rightcount) {
			last;
		}
		$fly->box(3,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
		$fly->line($rightnode{$node},$rightx,$topy,$x,$y,undef,undef,3);
		$rightsum += $rightnode{$node};
		$y -= 30;
		$i++;
	}
	if ($rightcount > 0) {
		$y = $topy;
		$fly->text(2,"(from transit page)",$x,$y,undef,undef,undef,"small");
		$fly->text(3,"Outgoing Link <-- ",$x,$y,undef,undef,undef,"small");
	}

#
# Show Statistics
#
	$x = $midx;
	$y = $imgheight - 70;
	if (substr($data->{exiturl}{$url},0,1) ne "<") {
		my $pct = sprintf("%.1f", $data->{exiturl}{$url} / $data->{exitstat}[1] * 100.0);
		$fly->text(1,"This page accounts for $pct % of all exits from your website.",$x,$y,undef,undef,undef,"small");
		$pct = sprintf("%.1f", ($leftsum + $rightsum) / $data->{exiturl}{$url} * 100.0);
		$fly->text(1,"The links represent $pct % of all links to this exit page.",$x,$y+15,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"This page is not one of the Top Exit pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		$fly->text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Exit Map for Page $url"));
}

###########################################################################
#
#               ENTRY
#                 |
# TRANSIT ---> TRANSIT ---> TRANSIT
#                 |
#               EXIT
#

sub make_transit {
	my $self = shift;
	my($url,$tmpfile,$outfile) = @_;

	my $data = $self->{data};

#
# Get values
#
	my (%topnode,%bottomnode,%leftnode,%rightnode);
	foreach my $link (@{$data->{intop}}) {
		my ($from,$to) = split(/ /,$link);
		if ($to eq $url) {
			$topnode{$from} += $data->{inlink}{$link};
		}
	}
	foreach my $link (@{$data->{outtop}}) {
		my ($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$bottomnode{$to} += $data->{outlink}{$link};
		}
	}
	foreach my $link (@{$data->{interntop}}) {
		my ($from,$to) = split(/ /,$link);
		if ($from eq $url) {
			$rightnode{$to} += $data->{internlink}{$link};
		}
		if ($to eq $url) {
			$leftnode{$from} += $data->{internlink}{$link};
		}
	}

	my $topcount = keys %topnode;
	my $bottomcount = keys %bottomnode;
	my $leftcount = keys %leftnode;
	my $rightcount = keys %rightnode;

	if ($self->{bigsite} == 1) {
		if ($topcount > $self->{topentries}) {
			$topcount = $self->{topentries};
		}
		if ($bottomcount > $self->{topexits}) {
			$bottomcount = $self->{topexits};
		}
		if ($leftcount > $self->{toptransits}) {
			$leftcount = $self->{toptransits};
		}
		if ($rightcount > $self->{toptransits}) {
			$rightcount = $self->{toptransits};
		}
	}

	my $maxcountx = $topcount > $bottomcount ? $topcount : $bottomcount;
	my $maxcounty = $leftcount > $rightcount ? $leftcount : $rightcount;

#
# Determine image size
#
	my $leftwidth = check_nodewidth(\%leftnode,$data->{transiturl},$leftcount,200);
	my $midwidth;
	if ($maxcountx * 70 > 360) {
		$midwidth = $maxcountx * 70;
	}
	else {
		$midwidth = 360;
	}
	my $rightwidth = check_nodewidth(\%rightnode,$data->{transiturl},$rightcount,200);
	my $imgwidth = $leftwidth + $midwidth + $rightwidth;

	my $topheight;
	if ($topcount > 0) {
		$topheight = check_nodeheight(\%topnode,$data->{entryurl},$topcount,190);
	}
	else {
		$topheight = 0;
	}
	my $height = check_urlheight($url);
	my $breakheight = 150 + $height / 2;
	my $midheight;
	if ($maxcounty * 30 > 150) {
		$midheight = $height / 2 + $maxcounty * 30;
	}
	else {
		$midheight = $height / 2 + 150;
	}
	my $bottomheight;
	if ($bottomcount > 0) {
		$bottomheight = check_nodeheight(\%bottomnode,$data->{exiturl},$bottomcount,140);
	}
	else {
		$bottomheight = 0;
	}
	my $imgheight = $topheight + $breakheight + $midheight + $bottomheight;

	my $fly = AwvMap::Fly->new($imgwidth,$imgheight,$tmpfile);

#
# Show Title
#
	$fly->map_title("Transit Map",$data->{startdate},$data->{enddate});

#
# Show Page
#
	my $x = $leftwidth + $midwidth / 2;
	my $y = $topheight + $breakheight;
	my ($midx,$midy,$leftx,$topy,$rightx,$bottomy) = $fly->map_page(0,$x,$y,get_vals($data,$url));

#
# Show Buttons
#
	$fly->map_buttons($data->{pagenr}{$url},4);

#
# FROM TRANSIT
#
	$x = $leftwidth;
	$y = $midy;
	my $leftsum = 0;
	my $i = 0;
	foreach my $node (sort_by_nodeurl(\%leftnode,$data->{transiturl})) {
		if ($i >= $leftcount) {
			last;
		}
		$fly->box(4,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
		$fly->line($leftnode{$node},$leftx,$midy,$x,$y,undef,undef,1);
		$leftsum += $leftnode{$node};
		$y += 30;
		$i++;
	}
	if ($leftcount > 0) {
		$y = $midy - 20;
		$fly->text(3,"(from transit page)",$x,$y,undef,undef,undef,"small");
		$fly->text(2," --> Internal",$x,$y,undef,undef,undef,"small");
	}

#
# TO TRANSIT
#
	$x = $imgwidth - $rightwidth;
	$y = $midy;
	my $rightsum = 0;
	$i = 0;
	foreach my $node (sort_by_nodeurl(\%rightnode,$data->{transiturl})) {
		if ($i >= $rightcount) {
			last;
		}
		$fly->box(3,$node,$data->{transiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=4",undef,3,1);
		$fly->line($rightnode{$node},$rightx,$midy,$x,$y,undef,undef,1);
		$rightsum += $rightnode{$node};
		$y += 30;
		$i++;
	}
	if ($rightcount > 0) {
		$y = $midy - 20;
		$fly->text(2,"(to transit page)",$x,$y,undef,undef,undef,"small");
		$fly->text(3,"Internal --> ",$x,$y,undef,undef,undef,"small");
	}

#
# FROM ENTRY
#
	$x = $midx - 70 * ($topcount - 1) / 2;
	$y = $topheight;
	my $topsum = 0;
	$i = 0;
	foreach my $node (sort_by_nodeurl(\%topnode,$data->{entryurl})) {
		if ($i >= $topcount) {
			last;
		}
		$fly->box(1,$node,$data->{entryurl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=2",undef,1,2);
		$fly->line($topnode{$node},$midx,$topy,$x,$y,undef,undef,2);
		$topsum += $topnode{$node};
		$x += 70;
		$i++;
	}
	if ($topcount > 0) {
		$x = $midx;
		$y = $y + 10;
		$fly->text(3,"(from entry page)",$x,$y,undef,undef,undef,"small");
		$fly->text(2," --> Incoming",$x,$y,undef,undef,undef,"small");
	}

#
# TO EXIT
#
	$x = $midx - 70 * ($bottomcount - 1) / 2;
	$y = $imgheight - $bottomheight;
	my $bottomsum = 0;
	$i = 0;
	foreach my $node (sort_by_nodeurl(\%bottomnode,$data->{exiturl})) {
		if ($i >= $bottomcount) {
			last;
		}
		$fly->box(2,$node,$data->{exiturl}{$node},$x,$y,$data->{pagenr}{$node} . "&f=3",undef,2,3);
		$fly->line($bottomnode{$node},$midx,$bottomy,$x,$y,undef,undef,3);
		$bottomsum += $bottomnode{$node};
		$x += 70;
		$i++;
	}
	if ($bottomcount > 0) {
		$x = $midx;
		$y = $y - 10;
		$fly->text(2,"(to exit page)",$x,$y,undef,undef,undef,"small");
		$fly->text(3,"Outgoing --> ",$x,$y,undef,undef,undef,"small");
	}

#
# Show Statistics
#
	$x = $midx;
	$y = 60;
	if (substr($data->{transiturl}{$url},0,1) ne "<") {
		my $pct = sprintf("%.1f", $data->{transiturl}{$url} / $data->{transitstat}[1] * 100.0);
		$fly->text(1,"This page accounts for $pct % of all transits inside your website.",$x,$y,undef,undef,undef,"small");
		$pct = sprintf("%.1f", ($topsum + $leftsum) / $data->{transiturl}{$url} * 100.0);
		$fly->text(1,"The incoming and internal links TO this page represent $pct % of all transit hits on this page,",$x,$y+15,undef,undef,undef,"small");
		$pct = sprintf("%.1f", ($rightsum + $bottomsum) / $data->{transiturl}{$url} * 100.0);
		$fly->text(1,"and the internal and outgoing links FROM this page represent $pct % of all transit hits on this page.",$x,$y+30,undef,undef,undef,"small");
	}
	else {
		$fly->text(1,"This page is not one of the Top Transit pages found by aWebVisit,",$x,$y,undef,undef,undef,"small");
		$fly->text(1,"so there are no hit statistics available.",$x,$y+15,undef,undef,undef,"small");
	}

#
# Make image and page
#
	$fly->generate($flyprog,$outfile);
	return($fly->get_map("Transit Map for Page $url"));
}

1;

