package ElasticSearchX::Model;

# ABSTRACT: Extensible and flexible model for ElasticSearch based on Moose
use Moose           ();
use Moose::Exporter ();
use ElasticSearchX::Model::Index;

Moose::Exporter->setup_import_methods(
        with_meta       => [qw(index analyzer tokenizer filter)],
        class_metaroles => { class => ['ElasticSearchX::Model::Trait::Class'] },
        base_class_roles => [qw(ElasticSearchX::Model::Role)], );

sub index {
    my ( $self, $name, @rest ) = @_;
    if ( !ref $name ) {
        return $self->add_index( $name, {@rest} );
    } elsif ( ref $name eq 'ARRAY' ) {
        $self->add_index( $_, {@rest} ) for (@$name);
        return;
    } else {
        my $options = $name->meta->get_index( $rest[0] );
        my $index =
          ElasticSearchX::Model::Index->new( name => $rest[0],
                                             %$options, model => $name );
        $options->{types} = $index->types;
        return $index;
    }
}

sub analyzer {
    shift->add_analyzer( shift, {@_} );
}

sub tokenizer {
    shift->add_tokenizer( shift, {@_} );
}

sub filter {
    shift->add_filter( shift, {@_} );
}

1;

__END__

=head1 SYNOPSIS

 package MyModel::Tweet;
 use Moose;
 use ElasticSearchX::Model::Document;

 has message => ( isa => 'Str' );
 has date => ( isa => 'DateTime' );

 package MyModel;
 use Moose;
 use ElasticSearchX::Model;

 __PACKAGE__->meta->make_immutable;

  my $model = MyModel->new;
  $model->deploy;
  $model->index('default')->type('tweet')->put({
      message => 'Hello there!',
      date => DateTime->now,
  });

=head1 DESCRIPTION

This an ElasticSearch to Moose mapper which hides the REST api
behind object-oriented api calls. ElasticSearch types and indices
are defined using Moose classes and a flexible DSL.

Deployment statements for ElasticSearch can be build dynamically
using these classes. Results from ElasticSearch inflate automatically
to the corresponding Moose classes. Furthermore, it provides
sensible defaults.

The powerful search API makes the tedious task of building 
ElasticSearch queries a lot easier.

B<< The L<ElasticSearchX::Model::Tutorial> is probably the best place
to start! >>

=head1 DSL

=head2 index

 index twitter => ( namespace => 'MyNamespace' );

Adds an index to the model. By default there is a C<default>
index, which will be removed once you add custom indices.

See L<ElasticSearchX::Model::Index/ATTRIBUTES> for available options.

=head2 analyzer

=head2 tokenizer

=head2 filter

 analyzer lowercase => ( tokenizer => 'keyword',  filter   => 'lowercase' );

Adds analyzers, tokenizers or filters to all indices. They can
then be used in attributes of L<ElasticSearchX::Model::Document> classes.

=head1 CONSTRUCTOR

=head1 METHODS

=head2 index

Returns a L<ElasticSearchX::Model::Index> object.

=head2 deploy

C<deploy> will remove all indices and then insert them one
after the other. See L</upgrade> for an upgrade routine.

B<< All data will be lost during C<deploy> >>

=head2 upgrade

C<upgrade> will try to add non-existing indices and update the
mapping on existing indices. Depending on the changes to
the mapping this might or might not succeed.