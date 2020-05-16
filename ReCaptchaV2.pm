package ReCaptchaV2;

use warnings;
use strict;
use Carp;
use JSON;

use WWW::Mechanize ();

sub new
{
	my $class 	= shift(@_);

	my $self = 
	{
		_apikey 	=> shift(@_),
		_domain 	=> shift(@_),
		_keysite	=> shift(@_),
		_url		=> 'http://api.anti-captcha.com/',
	};

	for (keys % { $self })
	{ $self->{$_} or croak "".$_." is required."; }

	bless $self => $class;

	return $self;
}

sub setopt
{
	my $self	= shift(@_);
	my $opts 	= shift(@_);

	for (keys % { $opts })
	{$self->{opt}->{$_} = $opts->{$_};}
}

sub request
{
	my $self	= shift(@_);
	my $method 	= shift(@_);
	my $sendit 	= shift(@_);

	my $json;
	my $rcvit;

	$json = encode_json $sendit;

	$self->{_browser} = WWW::Mechanize->new();
	$self->{_browser}->add_header
	( 
		'content-type' => 'application/json',
	);

	$self->{_browser}->post
	(
		$self->{_url} . $method, 
		Content => $json
	);

	$rcvit = decode_json($self->{_browser}->response()->decoded_content());

	if ($method eq '/createTask')
	{
		$rcvit->{errorId} == 0 ? return $rcvit->{taskId} : return undef;
	}
	elsif ($method eq '/getTaskResult')
	{
		return $self->{_browser}->response()->decoded_content();
	}
}

sub createtask 
{
	my $self	= shift(@_);
	my $type;

	my %sendit;

	if (defined($self->{opt}->{proxyAddress}))
	{
		$type = 'NoCaptchaTask';
	}
	else
	{
		$type = 'NoCaptchaTaskProxyless';	
	}

	%sendit =
	(
		clientKey	=> $self->{_apikey},
		task 		=> {
				type 			=> $type,
				websiteURL		=> $self->{_domain},
				websiteKey		=> $self->{_keysite},
		},
	);

	for (keys % { $self->{opt} })
	{$sendit{task}{$_} = $self->{opt}->{$_};}

	$self->request('/createTask', \%sendit);
}

sub checktask
{
	my $self	= shift(@_);
	my $task 	= shift(@_);

	my %sendit;

	%sendit =
	(
		clientKey	=> $self->{_apikey},
		taskId 		=> $task,
	);

	$self->request('/getTaskResult', \%sendit);
}

sub waittask
{
	my $self	= shift(@_);
	my $task 	= shift(@_);

	my $res;
	my $time;

	$res->{status} = '';
	$time = 0;

	while ($res->{status} ne "ready")
	{
		last if $time > 180;
		$res = decode_json($self->checktask($task));
		sleep 5;
		$time += 5;
	}

	$time > 180 ? return 0 : return $res->{solution}->{gRecaptchaResponse};
}

1;

__END__

=pod

=encoding UTF-8

=head1 NAME

ReCaptchaV2 - Auto solve captchas from Google v2

http://api.anti-captcha.com/

https://anticaptcha.atlassian.net/wiki/spaces/API/pages/5079089/NoCaptchaTask+Google+Recaptcha+puzzle+solving

=head1 VERSION

version 1.00

=head1 SYNOPSIS

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