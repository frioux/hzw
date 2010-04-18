package HTML::Zoom::Widget::Grid;

use 5.12.0;

use HTML::Zoom;
use Method::Signatures::Simple;
use Moose;
use List::MoreUtils 'natatime';

has config => (
   is => 'ro',
   isa => 'HashRef',
   lazy_build => 1,
);

method column_spec {
   use HTML::Tags;
   my $col_id;
   my @inner = (<tr>);
   for (@{$self->config->{columns}}) {
      $col_id++;
      my $col_class = (defined $_->{column_class}?"$_->{column_class} ":'');
      push @inner, <td class="${col_class}col-$col_id">,</td>;
   }
   push @inner, </tr>;

   join '', HTML::Tags::to_html_string(@inner)
}

method render_row_data($data) {
   my @rows;
   for my $data_item (@{$data->{data}}) {
      my @columns;

      my $col_id = 1;
      for my $conf (@{$self->config->{columns}}) {
         my $value    = $data_item->{$conf->{data_index}};
         my $renderer = $conf->{renderer} || sub { $_[1] };
         push @columns, $self->$renderer($value, $data_item);

         $col_id++;
      }
      push @rows, \@columns;
   }
   return \@rows;
}

method render_rows($rendered_data) {
   [map {
      my $val = $_;
      sub {
         my $r = $_;
         my $x = 1;
         $r = $r->select(".col-$x")->replace_content($_)
            for @{$val};
         $r
      }
   } @{$rendered_data}];
}

method insert_into_html($tpl, $data) {
   my $col_spec = $self->column_spec;

   HTML::Zoom
      ->from_html($tpl)
      ->select($self->config->{render_to})
      ->replace_content(\'<table></table>')
      ->select('table')
      ->replace_content(\$col_spec)
      ->then
      ->repeat_content($self->render_rows($self->render_row_data($data)))
      ->to_html
}

1;
__END__

Sketch:

use MooseX::Declare;
class UserGrid extends HTML::Zoom::Widget::Grid {

  method id_column {
    return {
      # no renderer used so value is printed directly
      value_field => 'id',
    }
  }

  mehod email_column {
    return {
      renderer => 'email_renderer',
      value_field => 'email',
    }
  }

  method name_column {
    return {
      renderer => 'name_renderer',
      # no value field is used since it's effectively a composite field
    }
  }

  method columns {
    return [
      $self->id_column,
      $self->email_column,
      $self->name_column,
    ]
  }

  method name_renderer($value, $row) {
    "$row->{firstname} $row->{lastname}"
  }

  method email_renderer($value, $row) {
    "<a href='email:$value'>$value</a>"
   }
};
