package HTML::Zoom::Widget::Grid;

use Moose;
use Method::Signatures::Simple;

extends 'HTML::Zoom::Widget::Grid::Dad';

sub column_definitions { [map $_[0]->${\"${_}_column"}, @{$_[0]->columns}] }

sub _build_config {
   return {
      render_to => $_[0]->render_to,
      columns   => $_[0]->column_definitions,
   }
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
