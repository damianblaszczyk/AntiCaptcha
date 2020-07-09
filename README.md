# PerlAutoReCaptchaV2

AntiCaptcha - Automatic solving captcha from many websites.
Module for PERL.

http://api.anti-captcha.com/

```perl
	use warnings;
	use strict;

	use AntiCaptcha;

	sub main
	{
		my $captcha;
		my $res;
		my $task;
		my $balance;

		$captcha = new ReCaptchaV2
		(
			# Your API key
			"93079f5443ae3c7a8c8wb9gbw3deg09f",
		);

		# Print JSON response live in console
		$captcha->setdebug(1);

		#
		# Methods return hash with JSON parsed data
		#

		# Check Your balance
		$balance = $captcha->getbalance()->{balance};

		# Set param in request
		# More info on site with API documentation
		# setopt save param in request, if you use new setopt old params be deleted
		# clientKey is always in request, you don't declare in setopt
		$captcha->setopt({ type=>'NoCaptchaTaskProxyless', 
		websiteURL=>'https://domain.com', 
		websiteKey=>'6Lc0SxgUAA2AANZc3armJOAlR-_KRLQZpQ8XWWMk' });

		# Create new task
		$res = $captcha->createtask();
		$task = $res->{taskId} if $res->{errorId} == 0;

		# Check task result
		$res = $captcha->checktask($task);

		# Return suitable time to upload new task
		# Param ID, 6 = Recaptcha Proxyless task
		# More info on site with API documentation
		$res = $captcha->queuestats(6);

		# Waiting for solved captcha
		# Max time in second to waiting and taskId
		$res = $captcha->waittask(180, $task);

		# Incorrect solved Recaptcha?
		# Report to vendor
		$res = $captcha->reportincorrectrecaptcha($task);

		# Incorrect solved image captcha?
		# Report to vendor
		$res = $captcha->reportincorrectimagecaptcha($task);

		# Grabs account spendings and task volumes statistics
		$captcha->setopt({ queue=>'English ImageToText' });
		$res = $captcha->getspendingstats();

		# This method retrieves daily statistics for your application
		$captcha->setopt({ softId=>'247' });
		$res = $captcha->getappstats();

		# Send funds to another account
		$captcha->setopt({ amount=>'1.00' });
		$res = $captcha->sendfunds();

		# Disable printing JSON in console
		$captcha->setdebug(0);	

		return 0;
	}

	main();
```  