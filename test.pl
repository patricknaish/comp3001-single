#!/usr/bin/perl -w

$startPath = shift or die "No arguments provided";

our (%matching, $matching);

@pdfs = ();
@docs = ();
@both = ();

listFiles($startPath);
getMatching(\@pdfs, \@docs);
parseLog("access.log");


sub listFiles{
	my $path = shift;
	opendir(DIR, $path) or die "Could not open $path";
	
	my @files = map("$path/$_", grep (!/^\.{1,2}$/, readdir(DIR)));
	closedir(DIR);

	foreach $file(@files) {
		if (-f $file) {
			$file =~ s/^$startPath\///;
			if ($file =~ m/^.*\.pdf$/i) {
				$file =~ s/\.pdf$//i;
				push(@pdfs, $file . "<br />");
			}
			elsif ($file =~ m/^.*\.doc$/i) {
				$file =~ s/\.doc$//i;
				push(@docs, $file . "<br />");
			}
		}
		elsif (-d $file) {
			listFiles($file);
		}
	}

	@pdfs = sort(@pdfs);
	@docs = sort(@docs);

}

sub getMatching{
	my ($ref_arr1, $ref_arr2) = @_;

	my @arr1 = @{$ref_arr1};
	my @arr2 = @{$ref_arr2};
	$matching = {};

	for (@arr1) {
		$matching{$_}++;
	}
	for (@arr2) {
		$matching{$_}++;
	}

	push(@both, $_) for (grep {$matching{$_} > 1} keys %matching);

	@both = sort(@both);
}

sub parseLog{
	my %hashmap;
	foreach my $file(@both) {
		$hashmap{$file}++;
	}
	my $path = shift;
	my $doccount = 0;
	my (@logdocs, @logpdfs, @split);
	-f $path or die "$path is not a file";
	open LOG, $path or die "$path could not be opened";
	while (my $line = <LOG>) {
		if ($line =~ m/GET \/(\w+\/?)+\.doc/i) {
			$line =~ s/(.*$startPath\/|\.doc.*$)//ig;
			chomp($line);
			$line = $line . "<br />";
			if (defined $hashmap{$line}) {
				$doccount++;
			}
		}
		elsif ($line =~ m/GET \/(\w+\/?)+\.pdf/i) {
			$line =~ s/(.*$startPath\/|\.pdf.*$)//ig;
			chomp($line);
			$line = $line . "<br />";
			if (defined $hashmap{$line}) {
				$pdfcount++;
			}
		}
	}
	close LOG;
	print $doccount;
	print $pdfcount;
}