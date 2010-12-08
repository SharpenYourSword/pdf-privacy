#!/usr/bin/perl -w

package pdf_matrix;
use 5.006;
use strict;
use warnings;
use Data::Dumper;

use List::Util qw[min max];

require 'dumpvar.pl';

sub new
{
  my $self = {};
  if(@_ == 1)
  {
    my $matrix = [[1,0,0], [0,1,0], [0,0,1]];
    $self->{matrix} = $matrix;
  }
  elsif(@_ == 2)
  {
    my ($proto, $matrix) = @_;
    $self->{matrix} = $matrix;
  }
  else
  {
    my ($proto, $a, $b, $c, $d, $e, $f) = @_;

    my $matrix = [[$a,$b,0], [$c,$d,0], [$e,$f,1]];
    $self->{matrix} = $matrix;
  }

  bless $self;
  return $self;
}

sub translate
{
  my $self = shift;
  my $tx = shift;
  my $ty = shift;

  my $trans = pdf_matrix->new(1,0,0,1,$tx,$ty);

  $self->{matrix} = $self->multiply($trans)->{matrix};
}

sub multiply
{
  my $self = shift;
  my $other = shift;

  my $result = [[0,0,0],[0,0,0],[0,0,0]];

  for(my $i = 0; $i < 3; $i++)
  {
    for(my $j = 0; $j < 3; $j++)
    {
      for(my $k = 0; $k < 3; $k++)
      {
        $result->[$i]->[$j] += $self->{matrix}->[$i]->[$k] *
                              $other->{matrix}->[$k]->[$j];
      }
    }
  }

  return new pdf_matrix($result);
}

sub copy
{
  my $self = shift;

  my $old_ref = $self->{matrix};

  my @new = ();

  foreach my $row (@$old_ref)
  {
    my @new_row = ();
    foreach my $e (@$row)
    {
      push @new_row, $e;
    }

    push @new, \@new_row;
  }

  return pdf_matrix->new(\@new);
}

sub to_string
{
  my $self = shift;

  my $matrix = $self->{matrix};
  my @lines = ();

  foreach(@$matrix)
  {
    push @lines, join(", ", @$_);
  }

  return "[".join("]\n[", @lines)."]\n";
}

sub get_tx
{
  my $self = shift;

  return $self->{matrix}->[2]->[0];
}

sub get_ty
{
  my $self = shift;

  return $self->{matrix}->[2]->[1];
}

sub get_xscale
{
  my $self = shift;

  return $self->{matrix}->[0]->[0];
}

sub get_yscale
{
  my $self = shift;

  return $self->{matrix}->[1]->[1];
}

sub is_horizontal
{
  my $self = shift;

  return 0 if($self->{matrix}->[1]->[0] != 0);
  return 0 if($self->{matrix}->[0]->[1] != 0);
  return 1;
}

return 1;
