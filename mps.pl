#!/usr/bin/perl -w
##

	use strict;
	use CGI qw(:standard);
	use CGI::Carp 'fatalsToBrowser';
	our (@pdfs, @docs, $datasheetPath);
	print header;
	print start_html("Knurled Widgets Website Tools"); #from CGI sends the top of the web page
	print "<h1>Knurled Widgets Website Tools</h1>\n";
	print_form();
	process();
	print end_html; # CGI: sends the end of the html

	sub print_form {
		my $method="GET";  
			
			      
		print start_form($method);
		print "<em>Path for the datasheet hierarchy root?</em><br>";
		print textfield(
			-name=>'datasheetPath',
			-default=>'./datasheets');
		print "<p><em>Apache Log file path name?</em><br>";
		print textfield(
			-name=>'logPath',
			-default=>'access.log');
		print "<p><em>List datasheets which occur</em><br>";
		print checkbox_group(
							-name=>'datasheetOccurrence',
							-values=>['in_pdf','in_doc','in_both'],
							-linebreak=>'yes',
							-defaults=>['in_both']);

		print "<p><em>Apache log count of pdf request and doc requests for datasheets in both formats</em><br>",
			radio_group(
						-name=>'logCount',
						-values=>['yes', 'no'],
						-default=>'yes');

		print "<p>",reset;
		print submit('Action','Submit');
      
		print end_form;
		print "<hr>\n";
	}

	sub process {

		my $method = $ENV{'REQUEST_METHOD'};
		my $query = $ENV{'QUERY_STRING'};

		$datasheetPath = param('datasheetPath');
		my $logPath = param('logPath');
		my @datasheetOccurrence = param('datasheetOccurrence');
		my @logCount = param('logCount');

		if (@datasheetOccurrence) {
		
			listFiles($datasheetPath, $datasheetPath);
			my @both = getMatching(\@pdfs, \@docs);

			if (grep(/^in_pdf$/, @datasheetOccurrence)) {

				print "<h2>List of pdf datasheets</h2>";
				print @pdfs;

			}

			if (grep(/^in_doc$/, @datasheetOccurrence)) {
			
				print "<h2>List of doc datasheets</h2>";
				print @docs;

			}

			if (grep(/^in_both$/, @datasheetOccurrence)) {
				print "<h2>List of dual format datasheets</h2>";
				print @both;

			}

		}

		if (grep(/^yes$/, @logCount)) {

			my @both = getMatching(\@pdfs, \@docs);

			my ($doccount, $pdfcount) = parseLog($logPath, \@both);

			print "<h2>Number of pdf requests for dual format datasheets = ";
			print $pdfcount;
			print "</h2>";

			print "<h2>Number of doc requests for dual format datasheets = ";
			print $doccount;
			print "</h2>";

		}

	}

	sub listFiles{
		my $path = shift;
		-d $path or die "$path is not a directory";
		opendir(DIR, $path) or die "Could not open $path";
		
		my @files = map("$path/$_", grep (!/^\.{1,2}$/, readdir(DIR)));
		closedir(DIR);

		foreach my $file(@files) {
			if (-f $file) {
				$file =~ s/^$datasheetPath\///;
				if ($file =~ m/^.*\.pdf$/i) {
					$file =~ s/\.pdf$//i;
					push(our @pdfs, $file . "<br />");
				}
				elsif ($file =~ m/^.*\.doc$/i) {
					$file =~ s/\.doc$//i;
					push(our @docs, $file . "<br />");
				}
			}
			elsif (-d $file) {
				listFiles($file);
			}
		}

		our @pdfs = sort(@pdfs);
		our @docs = sort(@docs);

	}

	sub getMatching{
		my ($ref_arr1, $ref_arr2) = @_;
		my @both;
		my @arr1 = @{$ref_arr1};
		my @arr2 = @{$ref_arr2};
		my $matching = {};
		my %matching;

		for (@arr1) {
			$matching{$_}++;
		}
		for (@arr2) {
			$matching{$_}++;
		}

		push(@both, $_) for (grep {$matching{$_} > 1} keys %matching);

		@both = sort(@both);

		return @both;
	}

	sub parseLog{
		my ($path, $ref_both) = @_;
		-f $path or die "$path is not a file";
		my $doccount = 0;
		my $pdfcount = 0;
		my %dualhash;
		my @both = @{$ref_both};
		foreach my $file(@both) {
			$dualhash{$file}++;
		}
		-f $path or die "$path is not a file";
		open LOG, $path or die "$path could not be opened";
		while (my $line = <LOG>) {
			if ($line =~ m/GET \/(\w+\/?)+\.doc/i) {
				$line =~ s/(.*$datasheetPath\/|\.doc.*$)//ig;
				chomp($line);
				$line = $line . "<br />";
				if (defined $dualhash{$line}) {
					$doccount++;
				}
			}
			elsif ($line =~ m/GET \/(\w+\/?)+\.pdf/i) {
				$line =~ s/(.*$datasheetPath\/|\.pdf.*$)//ig;
				chomp($line);
				$line = $line . "<br />";
				if (defined $dualhash{$line}) {
					$pdfcount++;
				}
			}
		}
		close LOG;
		return ($doccount, $pdfcount);
	}