# ABSTRACT: produce aoa from tree

use strict;
use warnings;

use autodie;

package XML::Element;

sub cleantag {
    my ($self, $andattr) = @_;
    my $tag = $self->{_tag};

    return $tag unless $andattr;

    my %attr = $self->all_external_attr;
    my $attr;
    if (scalar keys %attr) {
      use Data::Dumper;my $d = Data::Dumper->new([\%attr]);
      $d->Purity(1)->Terse(1);
      $attr = $d->Dump;

      $tag .=  " => $attr";

    }

    $tag;
}

sub loltag {
    my ( $self, $derefstring ) = @_;
    my $loltag = sprintf '%s[ %s => DIVE( $root, qw(%s) ) ', "\n", $self->cleantag(1),
      "@$derefstring";
}

sub lolfrom {
    my ( $self, $fh, $depth, $derefstring, $firstdepth ) = @_;
    $fh    = *STDOUT{IO} unless defined $fh;
    $depth = 0           unless defined $depth;
    my $loltag;

    my @newderef;

    if ( $depth < $firstdepth ) {
      $derefstring = [];
    }
    else {
        if ( $depth == $firstdepth ) {
            @newderef =  $self->cleantag ;
        }
        if ( $depth > $firstdepth ) {
	  @newderef = (@$derefstring, $self->cleantag);
        }
    }
    $loltag = $self->loltag(\@newderef);

    $fh->print( "  " x $depth, $loltag );
    for ( @{ $self->{'_content'} } ) {

        if ( ref $_ ) {    # element
	  #use Data::Dumper;
	  #warn Dumper($_);
            $fh->print(", ");
            $_->lolfrom( $fh, $depth + 1, \@newderef, $firstdepth ); # recurse
        }
        else {    # text node
            ;
        }
    }
    $fh->print(" ] ");
}

1;

package XML::Element::Tolol;
use base qw(XML::TreeBuilder XML::Element);
use strict;
use warnings;

use Carp::Always;

sub mkpkg {
    my ( $self, $pkg, $tree, $firstdepth, $prepend_lib, $fileheader ) = @_;

    my $lol = __PACKAGE__->mklol($tree, $firstdepth);

    my $pkgstr = __PACKAGE__->_mkpkg( $pkg => $lol, $fileheader  );

    warn "PKG: $pkg";

    my @part = split '::', $pkg;
    my $file = $part[$#part];
    warn "PART: @part";

    use File::Spec;
    my $path = File::Spec->catdir( $prepend_lib ? $prepend_lib : '', @part[0 .. $#part-1] );
    warn $path;
    use File::Path;
    File::Path::make_path($path, {verbose => 1});

    $file =  File::Spec->catfile($path, "$file.pm");
    open( my $fh, '>', $file ) or die "Could not open string for writing";

    $fh->print($pkgstr);
    $pkgstr;

}

sub mklol {
    my ( $class, $tree, $firstdepth ) = @_;
    unless ($firstdepth) {
      warn 'Assuming firstdepth == 0';
      $firstdepth = 0;
    } 
    open( my $fh, '>', \my $string ) or die "Could not open string for writing";
    $tree->lolfrom( $fh, 0, '', $firstdepth );

    use Perl::Tidy;

    perltidy( source => \$string, destination => \my $dest );
    $dest;

}

sub _mkpkg {
    my ( $self, $pkg, $lol, $fileheader ) = @_;

    open( my $fh, '>', \my $pkgstr ) or die "Could not open pkg for writing";
    $fh->printf(<<'EOPKG', $pkg, $fileheader, $lol);
package %s;
use Moose;

%s;

use Data::Diver qw( Dive DiveRef DiveError );
use XML::Element;

has 'data' => (
  is => 'rw', 
  isa => 'HashRef',
  trigger => \&maybe_morph
);

sub DIVE {
   my $ref = Dive(@_);
    my $ret;
   #warn "DIVEREF: $ref";
    if (ref $ref) {
      $ret = '';
    } elsif (not defined $ref) {
      $ret = '';
    } else {
      $ret = $ref;
    }
    #warn "DIVERET: $ret";
    $ret;


}

sub maybe_morph {
  my($self,$data)=@_;
  if ($self->can('morph')) {
    warn "MORPHING";
    $self->morph($data);
  }
}

sub lol {
  my ($self)=@_;

my $root = $self->data;


 %s

}

sub tree {
  my $self=shift;
  my $href=shift;
  XML::Element->new_from_lol($self->lol);
}

1;

EOPKG

    use Perl::Tidy;

    perltidy( source => \$pkgstr, destination => \my $dest );
    $dest;


}


1;