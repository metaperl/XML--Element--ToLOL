#!/usr/bin/perl -w
use strict;

use t::lib::T;
use t::lib::U;

use Data::Rmap qw(:all);


my $xml = <<'END_XML';
<?xml version="1.0"?>
<shopping>
    <item>sample</item>
</shopping>
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


# initial_lol has this sort of structure
# [ shopping =>
#   [ item => 'bread' ],
# ]

my @items = qw(bread butter beer beans);


# we want this sort of structure:
# [ shopping =>
#   [ item => 'bread' ],
#   [ item => 'butter'],
#   [ item => 'beer'  ]
# ]

#is ($pkg, 'code', 'code generation');

@items = map { [ item => $_ ] } @items;

my ($dump) = rmap_array {
 
  # If we get an arrayref whose first element is 'shopping'
  if ($_->[0] eq 'shopping') {
    # Make the second element the shopping list
    splice @$_, 1, 2, @items;
    # No need to drill down any further
    cut($_);
    
  } else {
    # if the arrayrefs first element is not 'shopping'
    # then simply pass it through
    $_;
  }

  } $initial_lol;


my $exp = [
          'shopping',
          [
            'item',
            'bread'
          ],
          [
            'item',
            'butter'
          ],
          [
            'item',
            'beer'
          ],
          [
            'item',
            'beans'
          ]
        ];


is_deeply ($dump, $exp, 'array surgery');

done_testing;
