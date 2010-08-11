package HowdyPlack::Controller;

use Moose;
use namespace::autoclean;

BEGIN {
	extends 'HowdyPlack::Base';
}

sub begin : Action : Private {
	my ( $self, $h ) = @_;
	return 1;
}

sub end : Action : Private {
	my ( $self, $h ) = @_;
	
	$h->res->status(200) unless $h->res->status;
#	$h->res->content_type('text/html') unless $h->res->content_type;
	
	$h->res->finalize;
}

no Moose;
__PACKAGE__->meta->make_immutable;
