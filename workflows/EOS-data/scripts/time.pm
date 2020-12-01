package time;


# calculate date & time after duration seconds
sub Get_New_Time {
	use Time::Local;
	my ($date, $duration) = @_;

    my $precision = 5;

	# time difference in second w.r.t. 1970/01/01 00:00
	my ($year, $mon, $day, $hour, $min, $sec, $msec) = split " ", &Get_Head($date);
	$mon -= 1;
    my $time = timegm($sec, $min, $hour, $day, $mon, $year);

    # new time difference
    my $msec_length  = length($msec);
    my $msec_base    = 10**($msec_length);
	my $msec_sec     = $msec / $msec_base;
    #print STDERR "$msec_length $msec_base $msec_sec\n";

	$duration = sprintf("%.${precision}f", $duration);
	my $time_new     = $time + $msec_sec + $duration;
	my $time_new_int = int($time_new);
	my $msec_new     = $time_new - $time_new_int;

    # new msec
	$msec_new  = sprintf("%.${precision}f", $msec_new);
	$msec_new  = int($msec_new * $msec_base);

    # Add 0
    my $length0 = length($msec_new);
    my $zero_num= $msec_length - $length0;
    $zero_num = 0 if ($zero_num <= 0);
    $msec_new = "0"x$zero_num.$msec_new;

    # new time
	my ($wday, $yday, $isdast);
	($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdast) = gmtime($time_new_int);

    # special process of month and day
    $year += 1900;
    $mon  += 1;

    # add 0
    $mon  = "0$mon"  if ($mon  < 10);
    $day  = "0$day"  if ($day  < 10);
    $hour = "0$hour" if ($hour < 10);
    $min  = "0$min"  if ($min  < 10);
    $sec  = "0$sec"  if ($sec  < 10);

	my $new_date = "${year}${mon}${day}${hour}${min}${sec}${msec_new}";
	return $new_date;

}



# Format day of year
sub CalDOY {
    my ($origin) = @_;

    my ($wday, $yday, undef) = split " ", &CalDay($origin);
    if ($yday < 10) {
        $yday = "00${yday}"; }
    elsif ($yday < 100) {
        $yday = "0${yday}";
    }

    return "$yday";
}



# calculate day of year
# input: event origin time
# output: week of day, day of year, isdast
sub CalDay {
	use Time::Local;
	my ($date) = @_;

	my ($year, $mon, $day, $hour, $min, $sec, $msec) = split " ", &Get_Head($date);

	# time difference in second w.r.t. 1970/01/01 00:00
	$mon -= 1;
    my $time = timegm($sec, $min, $hour, $day, $mon, $year);

    # Day of week (Sun=0, Mon=1...Sat=6) and Day of year (0,1,2...)
	my ($wday, $yday, $isdast);
	($sec, $min, $hour, $day, $mon, $year, $wday, $yday, $isdast) = gmtime($time);

    # special process
    $year += 1900;
    $mon  += 1;
    $yday += 1;
    #print STDERR "$year $mon $day $hour $min $sec\n";

    return "$wday $yday $isdast";

}



# calculate time difference between two dates
# input: date1 date2
# ouput: time difference in sec
sub CalTimeInt {
    my ($time1, $time2) = @_;

    my $dt1 = &CalDt($time1);
    my $dt2 = &CalDt($time2);
    my $dt  = abs($dt1 - $dt2);

    return $dt;
}


# calculate time difference between two dates
# input: date1 date2
# ouput: time difference in sec
sub CalTimeInt1 {
    my ($time1, $time2) = @_;

    my $dt1 = &CalDt($time1);
    my $dt2 = &CalDt($time2);
    my $dt  = ($dt1 - $dt2);

    return $dt;
}


# calculate time difference between the date and 1970/01/01 00:00
# input: date
# ouput: time difference in sec
sub CalDt {
	use Time::Local;
	my ($date) = @_;

	my ($year, $mon, $day, $hour, $min, $sec, $msec) = split " ", &Get_Head($date);

	# month ranges from 0 to 11
	$mon -= 1;

	# time difference in second w.r.t. 1970/01/01 00:00
    my $time = timegm($sec, $min, $hour, $day, $mon, $year);

    # msec in ms
    my $msec_length  = length($msec);
    my $msec_base    = 10**($msec_length);
	my $msec_sec     = $msec / $msec_base;

    #print STDERR "$msec_length $msec_base $msec_sec\n";
    #$time = sprintf("%.3f", $time + $msec/1000.0);
	$time = sprintf("%.3f", $time + $msec_sec);
	return $time;
}


#adjust time form
#input: event origin time
#output:
#  year/month/day  h-min:s
sub Time_Form {
    my ($ev) = @_;

    my ($year, $mon, $day, $hour, $min, $sec, $msec) = split " ", &Get_Head($ev);

    my $date = "$year/$mon/$day";
    my $time = "${hour}:${min}:${sec}";

    return "$date $time";

}


#adjust time form
#input: event origin time
#output:
#  year-month-day  h:min:s.ms
sub Time_Form1 {
    my ($ev) = @_;

    my ($year, $mon, $day, $hour, $min, $sec, $msec) = split " ", &Get_Head($ev);

    my $date = "$year-$mon-$day";
    my $time = "${hour}:${min}:${sec}.${msec}";

    return "${date}T${time}";

}


#adjust time form
#input: event origin time
#output:
#  year/month/day  h:min:s.ms
sub Time_Form2 {
    my ($ev) = @_;

    my ($year, $mon, $day, $hour, $min, $sec, $msec) = split " ", &Get_Head($ev);

    my $date = "$year/$mon/$day";
    my $time = "${hour}:${min}:${sec}.${msec}";

    return "${date} ${time}";

}



#adjust time form
#input: event origin time
#output:
#  year/month/dayTh:min:s
sub Time_Form3 {
    my ($ev) = @_;

    my ($year, $mon, $day, $hour, $min, $sec, $msec) = split " ", &Get_Head($ev);

    my $date = "$year-$mon-$day";
    my $time = "${hour}:${min}:${sec}";

    return "${date}T${time}";
}



# get year month day hour min sec
# input  : event origin time
# output : year month day hour min sec msec
sub Get_Head {
    my ($head) = @_;

    my $year   = substr($head, 0, 4);
    my $mon    = substr($head, 4, 2);
    my $day    = substr($head, 6, 2);
    my $hour   = substr($head, 8, 2);
    my $min    = substr($head, 10, 2);
    my $sec    = substr($head, 12, 2);
    my $msec   = substr($head, 14);

    return "$year $mon $day $hour $min $sec $msec";
}



# get year month day hour min sec
# input: event origin time from csv
# output
#	year month day hour min sec msec
sub Get_Head_CSV {
    my ($head) = @_;

    my $year   = substr($head, 0, 4);
    my $mon    = substr($head, 4, 2);
    my $day    = substr($head, 6, 2);
    my $hour   = substr($head, 9, 2);
    my $min    = substr($head, 12, 2);
    my $sec    = substr($head, 15, 2);
    my $msec   = substr($head, 18,3);

    return "$year $mon $day $hour $min $sec $msec";
}



sub RemoveSplit {
    my ($date, $time) = @_;

    substr($date, 4, 1) = "";
    substr($date, 6, 1) = "";
    substr($time, 2, 1) = "";
    substr($time, 4, 1) = "";
    substr($time, 6, 1) = "";

	return "$date $time";
}



1;

