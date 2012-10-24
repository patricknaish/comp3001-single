#!/usr/bin/perl -w
##

	use CGI qw(:standard);
	use CGI::Carp 'fatalsToBrowser';
	print header;
	print start_html("Knurled Widgets Website Tools"); #from CGI sends the top of the web page
	print "<h1>Knurled Widgets Website Tools</h1>\n";
	print_form();
	process();
	print end_html; # CGI: sends the end of the html

	sub print_form {
		$method="GET";  
			
			      
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
							-values=>[in_pdf,in_doc,in_both],
							-linebreak=>'yes',
							-defaults=>[in_both]);

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
			
			listFiles($datasheetPath);
		
			if (grep(/^in_pdf$/, @datasheetOccurrence)) {

				print "<h2>List of pdf datasheets</h2>";
				print @pdfs;

			}

			if (grep(/^in_doc$/, @datasheetOccurrence)) {
			
				print "<h2>List of doc datasheets</h2>";
				print @docs;

			}

			if (grep(/^in_both$/, @datasheetOccurrence)) {
				
				getMatching(@pdfs, @docs);

				print "<h2>List of dual format datasheets</h2>";
				print @both;

			}

		}

		if (grep(/^yes$/, @logCount)) {

			print "<h2>Number of pdf requests for dual format datasheets = ";
			#do stuff
			print "</h2>";

			print "<h2>Number of doc requests for dual format datasheets = ";
			#do stuff
			print "</h2>";

		}

	}

	sub listFiles{
		my $path = shift;
		opendir(DIR, $path) or die "Could not open $path";
		
		my @files = map("$path/$_", grep (!/^\.{1,2}$/, readdir(DIR)));
		closedir(DIR);

		foreach $file(@files) {
			if (-f $file) {
				$file =~ s/^$datasheetPath\///;
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