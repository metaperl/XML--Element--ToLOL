#!/usr/bin/perl -w
use strict;

use t::lib::T;
use t::lib::U;


my $xml = <<'END_XML';
<?xml version="1.0"?>
<note onError="stopOnError">
    <to>Joni</to>
    <from>Jani</from>
    <heading>Reminder</heading>
    <body>
      <sexy>Terrence</sexy>
      <kim>
        <one>
          <two>beef stew</two>
          <kar>dashian</kar>
        </one>
      </kim>
      <super>Farah</super>
    </body>
</note>
END_XML

ok( my $builder = XML::Element::Tolol->new, 'Build XML::Element::Tolol element' );

my $tree = XML::TreeBuilder->new({ 'NoExpand' => 0, 'ErrorContext' => 0 });
$tree->parse($xml);


my $lol = XML::Element::Tolol->mklol($tree, 1);

my $exp =<<'EOEXPR';

[
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
]
EOEXPR

warn "LOL\n$lol";


is ($lol, $exp, 'lol generation');

my $firstdepth = 1;
my $pkg = XML::Element::Tolol->mkpkg('My::XML::Render' => $tree, $firstdepth, 't');

#is ($pkg, 'code', 'code generation');

eval $pkg;

if ($@) {
  use Carp;
  Carp::confess "error on eval: $@";
}


my %data = (
  to => 'Jane',
  from => 'Jon',
  heading => 'beheaded',
);
$data{body}{kim}{one}{kar} = 'datsun';
my $o = My::XML::Render->new(data => \%data);
$tree = $o->tree;
use Data::Dumper;
#warn "TREE " . Dumper($tree);
my $prune = $tree->prune;
#warn "PRUNE $prune";

my $x = $o->tree->prune->as_XML;
warn "X:$x";
chomp($x);
$exp = '<note onError="stopOnError"><to>Jane</to><from>Jon</from><heading>beheaded</heading><body><kim><one><kar>datsun</kar></one></kim></body></note>';

is ($x, $exp, 'xml generation');

done_testing;
