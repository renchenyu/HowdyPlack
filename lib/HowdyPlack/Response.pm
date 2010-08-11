package HowdyPlack::Response;

use Moose;
use namespace::autoclean -also => qr/^_/;

require Plack::Response;

has '_res' => (
	is      => 'rw',
	isa     => 'Plack::Response',
	handles => {
		status           => 'status',
		headers          => 'headers',
		body             => 'body',
		header           => 'header',
		content_type     => 'content_type',
		content_length   => 'content_length',
		content_encoding => 'content_encoding',
		redirect         => 'redirect',
		location         => 'location',
		cookies          => 'cookies',
		finalize         => 'finalize',
	}
);

around BUILDARGS => sub {
	my $orig = shift;
	my $class  = shift;

	return $class->$orig( _res => Plack::Response->new(@_) );
};

no Moose;
__PACKAGE__->meta->make_immutable;
