#!/usr/bin/perl -w

$startPath = shift or die "No arguments provided";

@pdfs = ();
@docs = ();
@both = ();

listFiles($startPath);
getMatching(\@pdfs, \@docs);

print "\@pdfs contains " . scalar(@pdfs) . "\n";
print "\@docs contains " . scalar(@docs) . "\n";
print "\@both contains " . scalar(@both) . "\n";

print "\n=====PDFS=====\n";
print @pdfs;
print "\n=====DOCS=====\n";
print @docs;
print "\n=====BOTH======\n";
print @both;

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
				push(@pdfs, $file . "\n");
			}
			elsif ($file =~ m/^.*\.doc$/i) {
				$file =~ s/\.doc$//i;
				push(@docs, $file . "\n");
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
	my $matching = {};

	for (@arr1) {
		$matching{$_}++;
	}
	for (@arr2) {
		$matching{$_}++;
	}

	push(@both, $_) for (grep {$matching{$_} > 1} keys %matching);

	@both = sort(@both);
}

