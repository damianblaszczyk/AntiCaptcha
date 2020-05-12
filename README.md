# PerlAutoReCaptchaV2

Module to solving Google ReCaptchaV2
http://api.anti-captcha.com/
Bitcoin payment

```perl
use lib ".";
use ReCaptchaV2;

sub main
{
	my $captcha;
	my $res;
	my $task;
	my @tasks;

	$captcha = new ReCaptchaV2
	(
		"apikey",
		"https://domain.com",
		"sitegooglekey",
	);

	push(@tasks, $captcha->createtask());

	$task = $captcha->createtask();
	!$task ? warn "Problem with create task\r\n" : push(@tasks, $task);

	foreach (@tasks)
	{
		# Return JSON data
		$res = $captcha->checktask($_);
		print "[".$_."] ".$res."\r\n";
	}

	# Return clean response key captcha
	print "".$captcha->waittask($tasks[1])."\r\n";

	return 0;
}

main();
```  