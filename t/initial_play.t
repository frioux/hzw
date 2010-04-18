#!perl

use 5.11.0;

use warnings;

use HTML::Zoom;
use aliased 'HTML::Zoom::Widget::Grid';

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

my $grid = Grid->new({ config => {
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

print $grid->insert_into_html($template, {
   data => [{
      id => 1,
      name => 'frew',
   }, {
      id => 2,
      name => 'wes',
   }],
   total => 100,
});

