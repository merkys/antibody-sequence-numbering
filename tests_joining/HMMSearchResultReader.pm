#!/usr/bin/perl

package HMMSearchResultReader;

use strict;
use warnings;

sub new
{	
	my ($class, $source) = @_;
	my $self = {'source' => $source,
		'results' => []};
	bless $self, $class;
	return $self;
}

sub add_result
{
	my ($self, %data) = @_;
	push @{ $self->{'results'} }, \%data;
}

sub get_results
{
	my ($self) = @_;
	return $self->{'results'};
}

sub parce
{
	my ($self) = @_;
	my $search_response = ${$self->{source}};
	
	#Deleting lines with cooments from responce
	my @lines = split /\n/, $search_response;
	@lines = grep { $_ !~ /^#/ } @lines;
	@lines = grep { $_ !~ /^\s*$/ } @lines;
	pop @lines;
	pop @lines;
	my $modified_search_response = join "\n", @lines;
	my @blocks = split(/\/\/\n/, $modified_search_response);
	for my $block (@blocks)
	{
		chomp ($block);
		#print $block ."\n";
		my @block_lines = split("\n", $block);
		my ($hmm_profile_name) = $block_lines[0] =~ /\S+\s+(\S+).+/;
		#print "hmm_profile name: " . $hmm_profile_name . "\n";
		if($block_lines[5] !~ /\Q[No hits detected that satisfy reporting thresholds]\E/)
		{
			my (@values) = split(/\s+/, $block_lines[10]);
			shift (@values);
			#print $block ."\n";
			#print "Values: ", join(", ", @values), "\n";
			#print $block_lines[10] . "\n";
			my %data = (
					'HMM_profile_name' 	=> $hmm_profile_name,
					'Domain_number' 	=> $values[0],
					'Significance_marker'	=> $values[1],
					'Score'         	=> $values[2],
					'Bias'          	=> $values[3],
					'c-Evalue'      	=> $values[4],
					'i-Evalue'      	=> $values[5],
					'hmmfrom'       	=> $values[6],
					'hmmto'         	=> $values[7],
					'Profile_marker' 	=> $values[8],
					'alifrom'       	=> $values[9],
					'alito'         	=> $values[10],
					'Alignment_Marker' 	=> $values[11],
					'envfrom'      		=> $values[12],
					'envto'         	=> $values[13],
					'Environment_Accuracy'	=> $values[14],
					'acc'           	=> $values[15]
				    );
			 $self->add_result(%data);
		}
		else
		{
			#print $block_lines[5] . "\n";
		}
	}
}

1;
