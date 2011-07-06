#!/usr/bin/perl -w
use strict;

use t::lib::T;
use t::lib::U;


my $xml = <<'END_XML';
<?xml version="1.0"?>
<note onError="stopOnError">
    <shopping>
      <item>bread</item>
    </shopping>
</note>
END_XML

ok( my $builder = XML::Element::Tolol->new, 'Build XML::Element::Tolol element' );

my $tree = XML::TreeBuilder->new({ 'NoExpand' => 0, 'ErrorContext' => 0 });
$tree->parse($xml);



# we want to manipulate the children of shopping
# counting from 0, it is a depth 1 in the xml tree
my $firstdepth = 1;
my $class = 't::My::Shopping';
my $pkg = XML::Element::Tolol->mkpkg($class => $tree, $firstdepth);

use Class::MOP;
Class::MOP::load_class($class);
my $xmlgen = $class->new;

my $initial_lol = $xmlgen->lol;

use Data::Dumper;
warn Dumper($initial_lol);

# initial_lol has this sort of structure
# [ shopping =>
#   [ item => 'bread' ],
# ]

my @shopping = qw(bread butter beer beans);


# we want this sort of structure:
# [ shopping =>
#   [ item => 'bread' ],
#   [ item => 'butter'],
#   [ item => 'beer'  ]
# ]

#is ($pkg, 'code', 'code generation');

eval $pkg;

if ($@) {
  die "error on eval: $@";
}


my %data = (
  to => 'Jane',
  from => 'Jon',
  heading => 'beheaded',
);
$data{body}{kim}{one}{kar} = 'datsun';
my $o = My::XML::Render->new(data => \%data);
$tree = $o->tree;
#warn "TREE " .$tree->as_XML;
my $prune = $tree->prune;
#warn "PRUNE $prune";

my $x = $o->tree->prune->as_XML;
warn "X:$x";
chomp($x);
my $exp = '<note onError="stopOnError"><to>Jane</to><from>Jon</from><heading>beheaded</heading><body><kim><one><kar>datsun</kar></one></kim></body></note>';

is ($x, $exp, 'xml generation');

done_testing;
