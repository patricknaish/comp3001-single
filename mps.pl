#!/usr/bin/perl -w
##


		use CGI qw(:standard);
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

			$method = $ENV{'REQUEST_METHOD'};
			$query = $ENV{'QUERY_STRING'};

			print "<h2>List of pdf datasheets</h2>";
			#do stuff

			print "<h2>List of doc datasheets</h2>";
			#do stuff

			print "<h2>List of dual format datasheets</h2>";
			#do stuff

			print "<h2>Number of pdf requests for dual format datasheets = ";
			#do stuff
			print "</h2>";

			print "<h2>Number of doc requests for dual format datasheets = ";
			#do stuff
			print "</h2>";
		}