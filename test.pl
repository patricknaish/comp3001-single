#!/usr/bin/perl -w

$startPath = shift or die "No arguments provided";

listFiles($startPath);

sub listFiles{
	my $path = shift;

	opendir(DIR, $path) or die "Could not open $path";
	
	my @files = map("$path/$_", grep (!/^\.{1,2}$/, readdir(DIR)));
	closedir(DIR);

	foreach $file(@files) {
		if (-f $file) {
			$file =~ s/^$startPath\///;
			print "$file\n";
		}
		elsif (-d $file) {
			listFiles($file);
		}
	}
}

