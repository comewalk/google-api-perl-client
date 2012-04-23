use Test::More;
eval "use Test::Pod::Coverage";
plan skip_all => "Test::Pod::Coverage required for checking POD coverage" if $@;
all_pod_coverage_ok();
