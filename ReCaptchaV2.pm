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

	bless $self => $class;

	return $self;
}

sub createtask 
{
	my $self	= shift(@_);

	my %sendit;
	my %method;

	my $json;
	my $rcvit;

	%method =
	(
		_create 		=> '/createTask',
	);

	%sendit =
	(
		clientKey	=> $self->{_apikey},
		task 		=> {
				type 			=> 'NoCaptchaTaskProxyless',
				websiteURL		=> $self->{_domain},
				websiteKey		=> $self->{_keysite},
		},
	);

	$json = encode_json \%sendit;

	$self->{_browser} = WWW::Mechanize->new();
	$self->{_browser}->add_header
	( 
		'content-type' => 'application/json',
	);

	$self->{_browser}->post
	(
		$self->{_url} . $method{_create}, 
		Content => $json
	);

	$rcvit = decode_json($self->{_browser}->response()->decoded_content());

	$rcvit->{errorId} == 0 ? return $rcvit->{taskId} : return undef;
}

sub checktask
{
	my $self	= shift(@_);
	my $task 	= shift(@_);

	my %sendit;
	my %method;

	my $json;
	my $rcvit;

	%method =
	(
		_get 			=> '/getTaskResult',
	);

	%sendit =
	(
			clientKey	=> $self->{_apikey},
			taskId 		=> $task,
	);

	$json = encode_json \%sendit;

	$self->{_browser} = WWW::Mechanize->new();
	$self->{_browser}->add_header
	( 
		'content-type' => 'application/json',
	);

	$self->{_browser}->post
	(
		$self->{_url} . $method{_get}, 
		Content => $json
	);

	return $self->{_browser}->response()->decoded_content();
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

=head1 VERSION

version 1.00

=head1 SYNOPSIS

	use ReCaptchaV2;

	my $captcha = new ReCaptchaV2
	(
		"apikey",
		"https://domain.com",
		"sitekey",
	);

		$task = $captcha->createtask();
	!$task ? warn "Problem with create task\r\n" : push(@tasks, $task);

	push(@tasks, $captcha->createtask());
	push(@tasks, $captcha->createtask());
	push(@tasks, $captcha->createtask());
	push(@tasks, $captcha->createtask());

	foreach my $task (@tasks)
	{
		# Return output in JSON
		$res = $captcha->checktask($task);
		print "".$res."\r\n";	
	}

	# Waiting to solved and return clean key
	$captcha->waittask($task);
