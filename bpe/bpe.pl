#!/usr/bin/perl

#
# Byte Pair Encoding (https://arxiv.org/abs/1508.07909)
# BPE merge operations learned from dic-tionary {‘low’, ‘lowest’, ‘newer’, ‘wider’}.
#
# Reference:
# Rico Sennrich, Barry Haddow and Alexandra Birch (2016). Neural Machine Translation of Rare Words with Subword Units.
# Proceedings of the 54th Annual Meeting of the Association for Computational Linguistics (ACL 2016). Berlin, Germany.
#

use strict;
use warnings;
use Data::Dumper;

sub GetStats() {
  my %vocab = %{$_[0]};

  my %pairs;
  while (my ($word, $freq) = each(%vocab)){
    my @symbols = split ' ', $word;
    for (my $i = 0; $i < @symbols - 1; $i++) {
      my $pair = "$symbols[$i]" . " " . "$symbols[$i + 1]";
      $pairs{$pair} += $freq;
    }
  }

  %pairs || die "no pairs created. Stopping\n";
  return %pairs;
}

sub MergeVocab() {
  my $pair = $_[0];
  my %v_in = %{$_[1]};

  my %v_out;

  while (my ($word, $freq) = each(%v_in)){
    my $merged = $pair;
    $merged =~ s/ +//g;
    $word =~ s/(?<!\S)$pair(?!\S)/$merged/g;
    $v_out{$word} = $freq;
  }

  return %v_out;
}

my %vocab = (
  "l o w</w>" => 5,
  "l o w e r</w>" => 2,
  "n e w e s t</w>" => 6,
  "w i d e s t</w>" => 3
);
my $num_merges = 15;

for (1..$num_merges) {
  my %pairs = &GetStats(\%vocab);
  my @sorted = sort { $pairs{$a} <=> $pairs{$b} } keys %pairs;
  my $best = $sorted[-1];
  $pairs{$best} < 2 && die "no pair has frequency > 1. Stopping\n";
  %vocab = &MergeVocab($best, \%vocab);
  print Dumper(\%vocab);
}
