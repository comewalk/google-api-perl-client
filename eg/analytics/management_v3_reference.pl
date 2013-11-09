#!/usr/bin/perl

use strict;
use warnings;
use feature qw/say/;

use FindBin;
use JSON;
use Google::API::Client;
use Google::API::OAuth2::Client;

use lib 'eg/lib';
use Sample::Utils qw/get_or_restore_token store_token/;


my $service = Google::API::Client->new->build('analytics', 'v3');

my $file = "$FindBin::Bin/../client_secrets.json";
my $auth_driver = Google::API::OAuth2::Client->new_from_client_secrets($file, $service->{auth_doc});

my $dat_file = "$FindBin::Bin/token.dat";

my $access_token = get_or_restore_token($dat_file, $auth_driver);

# Traverse the Management hiearchy and print results.
traverse_hiearchy($service);

store_token($dat_file, $auth_driver);

say 'done';

sub traverse_hiearchy {
    my $accounts = $service->management->accounts->list->execute({ auth_driver => $auth_driver });
    print_accounts($accounts);
    if ($accounts->{'items'}) {
        my $first_account_id = $accounts->{'items'}[0]->{'id'};
        my $webproperties = $service->management->webproperties->list(
            body => {
                accountId => $first_account_id,
            })->execute({ auth_driver => $auth_driver });
        print_webproperties($webproperties);
  
        my ($profiles, $first_webproperty_id);
        if ($webproperties->{'items'}) {
            $first_webproperty_id = $webproperties->{'items'}[0]->{'id'};
            $profiles = $service->management->profiles->list(
                body => {
                    accountId     => $first_account_id,
                    webPropertyId => $first_webproperty_id,
                })->execute({ auth_driver => $auth_driver });
        }
        print_profiles($profiles);
  
        my $goals;
        if ($profiles->{'items'}) {
            my $first_profile_id = $profiles->{'items'}[0]->{'id'};
            $goals = $service->management->goals->list(
                body => {
                    accountId     => $first_account_id,
                    webPropertyId => $first_webproperty_id,
                    profileId     => $first_profile_id,
                })->execute({ auth_driver => $auth_driver });
        }
        print_goals($goals);
    }
    print_segments($service->management->segments->list->execute({ auth_driver => $auth_driver }));
}

sub print_accounts {
    my ($accounts) = @_;
    say '------ Account Collection -------';
    print_pagination_info($accounts);
    say '';
    for my $account (@{$accounts->{'items'}}) {
        say 'Account ID      = ' . _get($account->{'id'});
        say 'Kind            = ' . _get($account->{'kind'});
        say 'Self Link       = ' . _get($account->{'selfLink'});
        say 'Account Name    = ' . _get($account->{'name'});
        say 'Created         = ' . _get($account->{'created'});
        say 'Updated         = ' . _get($account->{'updated'});

        my $child_link = $account->{'childLink'};
        say 'Child link href = ' . _get($child_link->{'href'});
        say 'Child link type = ' . _get($child_link->{'type'});
        say '';
    }
}

sub print_webproperties {
    my ($webproperties_list) = @_;
    say '------ Web Properties Collection -------';
    print_pagination_info($webproperties_list);
    say '';
    for my $webproperty (@{$webproperties_list->{'items'}}) {
        say 'Kind               = ' . _get($webproperty->{'kind'});
        say 'Account ID         = ' . _get($webproperty->{'accountId'});
        say 'Web Property ID    = ' . _get($webproperty->{'id'});
        say 'Internal Web Property ID = ' . _get($webproperty->{'internalWebPropertyId'});

        say 'Website URL        = ' . _get($webproperty->{'websiteUrl'});
        say 'Created            = ' . _get($webproperty->{'created'});
        say 'Updated            = ' . _get($webproperty->{'updated'});

        say 'Self Link          = ' . _get($webproperty->{'selfLink'});
        my $parent_link = $webproperty->{'parentLink'};
        say 'Parent link href   = ' . _get($parent_link->{'href'});
        say 'Parent link type   = ' . _get($parent_link->{'type'});
        my $child_link = $webproperty->{'childLink'};
        say 'Child link href    = ' . _get($child_link->{'href'});
        say 'Child link type    = ' . _get($child_link->{'type'});
        say '';
    }
}

sub print_profiles {
    my ($profiles_list) = @_;
    say '------ Profiles Collection -------';
    print_pagination_info($profiles_list);
    say '';

    for my $profile (@{$profiles_list->{'items'}}) {
        say 'Kind                      = ' . _get($profile->{'kind'});
        say 'Account ID                = ' . _get($profile->{'accountId'});
        say 'Web Property ID           = ' . _get($profile->{'webPropertyId'});
        say 'Internal Web Property ID  = ' . _get($profile->{'internalWebPropertyId'});
        say 'Profile ID                = ' . _get($profile->{'id'});
        say 'Profile Name              = ' . _get($profile->{'name'});

        say 'Currency         = ' . _get($profile->{'currency'});
        say 'Timezone         = ' . _get($profile->{'timezone'});
        say 'Default Page     = ' . _get($profile->{'defaultPage'});

        say 'Exclude Query Parameters        = ' . _get($profile->{'excludeQueryParameters'});
        say 'Site Search Category Parameters = ' . _get($profile->{'siteSearchCategoryParameters'});
        say 'Site Search Query Parameters    = ' . _get($profile->{'siteSearchQueryParameters'});

        say 'Created          = ' . _get($profile->{'created'});
        say 'Updated          = ' . _get($profile->{'updated'});

        say 'Self Link        = ' . _get($profile->{'selfLink'});
        my $parent_link = $profile->{'parentLink'};
        say 'Parent link href = ' . _get($parent_link->{'href'});
        say 'Parent link type = ' . _get($parent_link->{'type'});
        my $child_link = $profile->{'childLink'};
        say 'Child link href  = ' . _get($child_link->{'href'});
        say 'Child link type  = ' . _get($child_link->{'type'});
        say '';
    }
}

sub print_goals {
    my ($goals_list) = @_;
    say '------ Goals Collection -------';
    print_pagination_info($goals_list);
    say '';

    for my $goal (@{$goals_list->{'items'}}) {
        say 'Goal ID     = ' . _get($goal->{'id'});
        say 'Kind        = ' . _get($goal->{'kind'});
        say 'Self Link        = ' . _get($goal->{'selfLink'});

        say 'Account ID               = ' . _get($goal->{'accountId'});
        say 'Web Property ID          = ' . _get($goal->{'webPropertyId'});
        say 'Internal Web Property ID = ' . _get($goal->{'internalWebPropertyId'});
        say 'Profile ID               = ' . _get($goal->{'profileId'});

        say 'Goal Name   = ' . _get($goal->{'name'});
        say 'Goal Value  = ' . _get($goal->{'value'});
        say 'Goal Active = ' . _get($goal->{'active'});
        say 'Goal Type   = ' . _get($goal->{'type'});

        say 'Created     = ' . _get($goal->{'created'});
        say 'Updated     = ' . _get($goal->{'updated'});

        my $parent_link = $goal->{'parentLink'};
        say 'Parent link href = ' . _get($parent_link->{'href'});
        say 'Parent link type = ' . _get($parent_link->{'type'});

        if ($goal->{'urlDestinationDetails'}) {
            print_url_destination_goal_details(
                $goal->{'urlDestinationDetails'});
        } elsif ($goal->{'visitTimeOnSiteDetails'}) {
            print_visit_time_on_site_goal_details(
                $goal->{'visitTimeOnSiteDetails'});
        } elsif ($goal->{'visitNumPagesDetails'}) {
            print_visit_num_pages_goal_details(
                $goal->{'visitNumPagesDetails'});
        } elsif ($goal->{'eventDetails'}) {
            print_event_goal_details(
                $goal->{'eventDetails'});
        }
        say '';
    }
}

sub print_url_destination_goal_details {
    my ($goal_details) = @_;
    say '------ Url Destination Goal -------';
    say 'Goal URL            = ' . _get($goal_details->{'url'});
    say 'Case Sensitive      = ' . _get($goal_details->{'caseSensitive'});
    say 'Match Type          = ' . _get($goal_details->{'matchType'});
    say 'First Step Required = ' . _get($goal_details->{'firstStepRequired'});

    say '------ Url Destination Goal Steps -------';
    if ($goal_details->{'steps'}) {
        for my $goal_step (@{$goal_details->{'steps'}}) {
            say 'Step Number  = ' . _get($goal_step->{'number'});
            say 'Step Name    = ' . _get($goal_step->{'name'});
            say 'Step URL     = ' . _get($goal_step->{'url'});
        }
    } else {
        say 'No Steps Configured';
    }
}

sub print_visit_time_on_site_goal_details {
    my ($goal_details) = @_;
    say '------ Visit Time On Site Goal -------';
    say 'Comparison Type  = ' . _get($goal_details->{'comparisonType'});
    say 'comparison Value = ' . _get($goal_details->{'comparisonValue'});
}

sub print_visit_num_pages_goal_details {
    my ($goal_details) = @_;
    say '------ Visit Num Pages Goal -------';
    say 'Comparison Type  = ' . _get($goal_details->{'comparisonType'});
    say 'comparison Value = ' . _get($goal_details->{'comparisonValue'});
}

sub print_event_goal_details {
    my ($goal_details) = @_;
    say '------ Event Goal -------';
    say 'Use Event Value  = ' . $goal_details->{'useEventValue'};
    for my $event_condition (@{$goal_details->{'eventConditions'}}) {
        my $event_type = $event_condition->{'type'};
        say 'Type             = ' . $event_type;
        if ($event_type =~ /CATEGORY|ACTION|LABEL/) {
            say 'Match Type       = ' . _get($event_condition->{'matchType'});
            say 'Expression       = ' . _get($event_condition->{'expression'});
        } else {
            say 'Comparison Type  = ' . _get($event_condition->{'comparisonType'});
            say 'Comparison Value = ' . _get($event_condition->{'comparisonValue'});
        }
    }
}

sub print_segments {
    my ($segments_list) = @_;
    say '------ Segments Collection -------';
    print_pagination_info($segments_list);
    say '';
    for my $segment (@{$segments_list->{'items'}}) {
        say 'Segment ID = ' . _get($segment->{'id'});
        say 'Kind       = ' . _get($segment->{'kind'});
        say 'Self Link  = ' . _get($segment->{'selfLink'});
        say 'Name       = ' . _get($segment->{'name'});
        say 'Definition = ' . _get($segment->{'definition'});
        say 'Created    = ' . _get($segment->{'created'});
        say 'Updated    = ' . _get($segment->{'updated'});
        say ''; 
    }
}

sub print_pagination_info {
    my ($mgmt_list) = @_;
    say 'Items per page = ' . _get($mgmt_list->{'itemsPerPage'});
    say 'Total Results  = ' . _get($mgmt_list->{'totalResults'});
    say 'Start Index    = ' . _get($mgmt_list->{'startIndex'});
    if ($mgmt_list->{'previousLink'}) {
        say 'Previous Link  = ' . _get($mgmt_list->{'previousLink'});
    }
    if ($mgmt_list->{'nextLink'}) {
        say 'Next Link      = ' . _get($mgmt_list->{'nextLink'});
    }
}

sub _get { return ($_[0] || ''); }
__END__
