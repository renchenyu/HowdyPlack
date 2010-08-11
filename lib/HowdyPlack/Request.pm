package HowdyPlack::Request;

use Moose;
use namespace::autoclean -also => qr/^_/;
use Plack::Request;

has '_req' => (
	is      => 'rw',
	isa     => 'Plack::Request',
	handles => {
		env              => 'env',
		address          => 'address',
		remote_host      => 'remote_host',
		method           => 'method',
		protocol         => 'protocol',
		request_uri      => 'request_uri',
		path_info        => 'path_info',
		path             => 'path',
		script_name      => 'script_name',
		schema           => 'schema',
		secure           => 'secure',
		body             => 'body',
		input            => 'input',
		session          => 'session',
		session_options  => 'session_options',
		logger           => 'logger',
		cookies          => 'cookies',
		query_parameters => 'query_parameters',
		body_parameters  => 'body_parameters',
		parameters       => 'parameters',
		content          => 'content',
		raw_body         => 'raw_body',
		uri              => 'uri',
		base             => 'base',
		user             => 'user',
		headers          => 'headers',
		uploads          => 'uploads',
		content_encoding => 'content_encoding',
		content_length   => 'content_length',
		content_type     => 'content_type',
		header           => 'header',
		referer          => 'referer',
		user_agent       => 'user_agent',
		param            => 'param',
		upload           => 'upload',
	}
);

has 'path_arguments' => (
	is => 'rw',
	isa => 'String',
);

around BUILDARGS => sub {
	my $orig  = shift;
	my $class = shift;

	return $class->$orig( _req => Plack::Request->new( $_[0] ) );
};

no Moose;
__PACKAGE__->meta->make_immutable;
