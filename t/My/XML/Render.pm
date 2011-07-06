package My::XML::Render;
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
        note => { 'onError' => 'stopOnError' } => DIVE( $root, qw() ),
        [ to      => DIVE( $root, qw(to) ) ],
        [ from    => DIVE( $root, qw(from) ) ],
        [ heading => DIVE( $root, qw(heading) ) ],
        [
            body => DIVE( $root, qw(body) ),
            [ sexy => DIVE( $root, qw(body sexy) ) ],
            [
                kim => DIVE( $root, qw(body kim) ),
                [
                    one => DIVE( $root, qw(body kim one) ),
                    [ two => DIVE( $root, qw(body kim one two) ) ],
                    [ kar => DIVE( $root, qw(body kim one kar) ) ]
                ]
            ],
            [ super => DIVE( $root, qw(body super) ) ]
        ]
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
