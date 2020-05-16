# PerlAutoReCaptchaV2

Module to solving Google ReCaptchaV2

http://api.anti-captcha.com/

[api params](https://anticaptcha.atlassian.net/wiki/spaces/API/pages/5079089/NoCaptchaTask+Google+Recaptcha+puzzle+solving)


```perl
use lib ".";
use ReCaptchaV2;

	my $captcha;
	my $res;
	my $task;
	my @tasks;

	$captcha = new ReCaptchaV2
	(
		"apikey",
		"domain.com",
		"google-site-key",
	);

	$captcha->setopt
	(
		{
			'proxyType'		=> 'http',
			'proxyAddress'	=> 'x.x.x.x',
			'proxyPort'		=> 'y.y.y.y',
			'userAgent'		=> 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.141 Safari/537.36',
		}
	);

	$task = $captcha->createtask();
	print "$task\r\n";

	sleep 150;

	# Return JSON
	$res = $captcha->checktask($task);
	print "".$res."\r\n";

	# waittask($task);
	# Return when response, only google site code

	return 0;
```  