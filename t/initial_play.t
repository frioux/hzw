#!perl

use strict;
use warnings;

use Test::More;

use HTML::Zoom;
use aliased 'HTML::Zoom::Widget::Grid::Dad' => 'Grid';

my $template = <<HTML;
<html>
  <head>
    <title>Hello people</title>
  </head>
  <body>
    <div id="grid1"></div>
  </body>
</html>
HTML

{
   package A::Grid;

   use Moose;

   extends 'HTML::Zoom::Widget::Grid';

   sub render_to { 'div#grid1' }

   sub columns { [qw( id name )] }

   sub id_column {
      {
         data_index => 'id',
         renderer => sub { $_[1] * 2 },
      }
   }

   sub name_column {
      {
         data_index => 'name',
         column_class => 'frewbot',
         renderer => sub { $_[1] . ' ' . $_[2]->{id} },
      }
   }

   1;
}

my $grid1 = Grid->new({ config => {
   render_to => 'div#grid1',
   columns => [
      {
         data_index => 'id',
         renderer => sub { $_[1] * 2 },
      }, {
         renderer => sub { $_[1] . ' ' . $_[2]->{id} },
         data_index => 'name',
         column_class => 'frewbot',
      },
   ]
}});

my A::Grid $grid2 = A::Grid->new();

my $data = {
   data => [{
      id => 1,
      name => 'frew',
   }, {
      id => 2,
      name => 'wes',
   }],
   total => 100,
};

is $grid1->insert_into_html($template, $data),'<html>
  <head>
    <title>Hello people</title>
  </head>
  <body>
    <div id="grid1"><table><tr><td class="col-1">frew 1</td><td class="frewbot col-2"></td></tr><tr><td class="col-1">wes 2</td><td class="frewbot col-2"></td></tr></table></div>
  </body>
</html>
', 'data structure grid works';

is $grid2->insert_into_html($template, $data),'<html>
  <head>
    <title>Hello people</title>
  </head>
  <body>
    <div id="grid1"><table><tr><td class="col-1">frew 1</td><td class="frewbot col-2"></td></tr><tr><td class="col-1">wes 2</td><td class="frewbot col-2"></td></tr></table></div>
  </body>
</html>
', 'class grid works';

done_testing;
