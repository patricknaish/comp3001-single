#!/usr/bin/perl -w

	#Adapted from the provided example on the course page

	use strict;
	use CGI qw(:standard);
	use CGI::Carp 'fatalsToBrowser'; #Send fatal errors to the browser, rather than hiding them

	our (@pdfs, @docs, $datasheetPath); #Global vars

	print header; Sset the headers
	print start_html("Knurled Widgets Website Tools"); #Print the opening HTML
	print "<h1>Knurled Widgets Website Tools</h1>\n"; #Display a title
	print_form(); #Print the form for user input
	process(); #Handle queries
	print end_html; #Print the closing HTML

	#Display the form
	sub print_form {
		my $method="GET";
			      
		print start_form($method); #Create form tags with the GET method
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
						-linebreak=>'true',
						-values=>['yes', 'no'],
						-default=>'yes');

		print "<p>", reset;
		print submit('Action','Submit');
      
		print end_form;
		print "<hr>\n";
	}

	#Handle queries
	sub process {

		my $query = $ENV{'QUERY_STRING'}; #Get the query (after the '?' in the URL)

		$datasheetPath = param('datasheetPath'); #Store the original datasheet path
		my $logPath = param('logPath'); #Store the path to the logfile
		my @datasheetOccurrence = param('datasheetOccurrence'); #Store the checkbox selections
		my @logCount = param('logCount'); #Store the radio selections

		if (@datasheetOccurrence) { #If at least one checkbox is checked
		
			listFiles($datasheetPath, $datasheetPath); #Populate @pdfs and @docs
			my @both = getMatching(\@pdfs, \@docs); #Get an array containing dual-format datasheets

			if (grep(/^in_pdf$/, @datasheetOccurrence)) {

				print "<h2>List of pdf datasheets</h2>";
				print @pdfs; #Display pdf datasheet paths

			}

			if (grep(/^in_doc$/, @datasheetOccurrence)) {
			
				print "<h2>List of doc datasheets</h2>";
				print @docs; #Display doc datasheet paths

			}

			if (grep(/^in_both$/, @datasheetOccurrence)) {
				print "<h2>List of dual format datasheets</h2>";
				print @both; #Display dual datasheet paths

			}

		}

		if (grep(/^yes$/, @logCount)) { #If the radio selection is "yes"

			if (!@pdfs) { #If @pdfs is not populated
				listFiles($datasheetPath, $datasheetPath); #Populate @pdfs and @docs
			}
			my @both = getMatching(\@pdfs, \@docs); #Get an array containing dual-format datasheets

			my ($doccount, $pdfcount) = parseLog($logPath, \@both); #Get the request counts

			print "<h2>Number of pdf requests for dual format datasheets = ";
			print $pdfcount; #Display the pdf request counts
			print "</h2>";

			print "<h2>Number of doc requests for dual format datasheets = ";
			print $doccount; #Display the doc request counts
			print "</h2>";

		}

	}

	#Populate @pdfs and @docs
	sub listFiles{
		my $path = shift;
		-d $path or die "$path is not a directory";
		opendir(DIR, $path) or die "Could not open $path";
		
		my @files = map("$path/$_", grep (!/^\.{1,2}$/, readdir(DIR))); #attach the whole path to the normal (non-dot)
		                                                                #directories, and read into an array 
		closedir(DIR);

		foreach my $file(@files) { #For every file in the current directory
			if (-f $file) { #If it's a file
				$file =~ s/^$datasheetPath\///; #Strip the user-supplied path from the front (to relativise it)
				if ($file =~ m/^.*\.pdf$/i) { #If the file is a .pdf (case insensitive)
					$file =~ s/\.pdf$//i; #Strip off the extension
					push(our @pdfs, $file . "<br />"); #Store the file into @pdfs
				}
				elsif ($file =~ m/^.*\.doc$/i) { #If the file is a .doc (case insensitive)
					$file =~ s/\.doc$//i; #Strip off the extension
					push(our @docs, $file . "<br />"); #Store the file into @docs
				}
			}
			elsif (-d $file) { #If the file is a directory
				listFiles($file); #Recurse
			}
		}

		our @pdfs = sort(@pdfs); #Sort the arrays
		our @docs = sort(@docs);

	}

	#Get matching values from 2 arrays
	sub getMatching{
		my ($ref_arr1, $ref_arr2) = @_;
		my @both;
		my @arr1 = @{$ref_arr1};
		my @arr2 = @{$ref_arr2};
		my $matching = {};
		my %matching;

		for (@arr1, @arr2) {
			$matching{$_}++; #Increment the hashmap value for a given array value
		}

		push(@both, $_) for (grep {$matching{$_} > 1} keys %matching); #Get every hashmap entry with more than one value increase

		@both = sort(@both); #Sort the array

		return @both;
	}

	#Parse the logfile and get file access counts
	sub parseLog{
		my ($path, $ref_both) = @_;
		-f $path or die "$path is not a file";
		my $doccount = 0;
		my $pdfcount = 0;
		my %dualhash;
		my @both = @{$ref_both};
		foreach my $file(@both) { #Build a hashmap of the array values
			$dualhash{$file}++;
		}
		-f $path or die "$path is not a file";
		open LOG, $path or die "$path could not be opened";
		while (my $line = <LOG>) {
			if ($line =~ m/GET \/(\w+\/?)+\.doc/i) { #If the line contains a GET request for a .doc
				$line =~ s/(.*$datasheetPath\/|\.doc.*$)//ig; #Remove unnecessary text
				chomp($line); #Remove EOL
				$line = $line . "<br />"; #Add br tag for comparison
				if (defined $dualhash{$line}) { #If the doc is in the hash of dual-format datasheets
					$doccount++; #Increase the count
				}
			}
			elsif ($line =~ m/GET \/(\w+\/?)+\.pdf/i) { #If the line contains a GET request for a .pdf
				$line =~ s/(.*$datasheetPath\/|\.pdf.*$)//ig; #As above
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