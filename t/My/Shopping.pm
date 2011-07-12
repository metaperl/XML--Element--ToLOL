package t::My::Shopping;
use Moose;

use HTML::Element::Library;

use Data::Diver qw( Dive DiveRef DiveError );
use XML::Element;

has 'data' => (
    is      => 'rw',
    trigger => \&maybe_morph
);

sub DIVE {
    my $ref = Dive(@_);
    my $ret;

    #warn "DIVEREF: $ref";
    if ( ref $ref ) {
        $ret = '';
    }
    elsif ( not defined $ref ) {
        $ret = '';
    }
    else {
        $ret = $ref;
    }

    #warn "DIVERET: $ret";
    $ret;

}

sub maybe_morph {
    my ($self) = @_;
    if ( $self->can('morph') ) {
        warn "MORPHING";
        $self->morph;
    }
}

sub lol {
    my ($self) = @_;

    my $root = $self->data;

    my $lol = [
        shopping => DIVE( $root, qw() ),
        [ item => DIVE( $root, qw(item) ) ]
    ];

    # doesnt work but it should:
    # my $class=ref $self;
    # bless $lol, $class;

}

sub tree {
    my $self = shift;
    my $href = shift;
    XML::Element->new_from_lol( $self->lol );
}

1;
