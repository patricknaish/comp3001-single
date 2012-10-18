#!/usr/bin/perl -w

$startPath = shift or die "No arguments provided";

listFiles($startPath);

sub listFiles{
	$path = shift;

	opendir(DIR, $path) or die "Could not open $path";
	
	my @files = grep !/^(\.|\.\.)$/, readdir(DIR);
	closedir(DIR);

	@files = map("$path/$_", @files);

	foreach $file(@files) {
		if (-f $file) {
			print "$file\n";
		}
		elsif (-d $file) {
			listFiles($file);
		}
	}
}

