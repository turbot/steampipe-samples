When launched in a directory that contains mod resources, Steampipe builds introspection tables including `steampipe_query`, `steampipe_benchmark`, and `steampipe_control`. This example shows how to iterate over a list of mod names, git-clone of them, query those tables, and accumulate counts of those resources in a CSV file.

```bash
echo "mod,queries,benchmarks,controls" > stats.csv

mods=('steampipe-mod-alicloud-compliance' 'steampipe-mod-alicloud-thrifty' 'steampipe-mod-aws-compliance' 'steampipe-mod-aws-tags' 'steampipe-mod-aws-thrifty' 'steampipe-mod-azure-compliance' 'steampipe-mod-azure-tags' 'steampipe-mod-azure-thrifty' 'steampipe-mod-digitalocean-thrifty' 'steampipe-mod-gcp-compliance' 'steampipe-mod-gcp-labels' 'steampipe-mod-gcp-thrifty' 'steampipe-mod-github-sherlock' 'steampipe-mod-ibm-compliance' 'steampipe-mod-kubernetes-compliance' 'steampipe-mod-oci-compliance' 'steampipe-mod-oci-thrifty' 'steampipe-mod-terraform-aws-compliance' 'steampipe-mod-terraform-azure-compliance' 'steampipe-mod-terraform-gcp-compliance' 'steampipe-mod-zoom-compliance')

modcount="${#mods[@]}"

process () {
  cd $1
  steampipe query --output csv --header=false "select '$1' as mod, ( select count(*) from steampipe_query ) as queries, ( select count(*) from steampipe_benchmark ) as benchmarks,  ( select count(*) from steampipe_control ) as controls"  >> ../stats.csv
  cd ..
}

for (( i=0; i<$modcount; i++ )); 
do
  rm -rf "${mods[$i]}" ; 
  git clone "https://github.com/turbot/${mods[$i]}" ; 
  process "${mods[$i]}" ; 
done;
```

Here's the output as of Feb 15, 2022.

```
mod,queries,benchmarks,controls
steampipe-mod-alicloud-compliance,40,9,78
steampipe-mod-alicloud-thrifty,0,5,15
steampipe-mod-aws-compliance,233,374,448
steampipe-mod-aws-tags,0,4,284
steampipe-mod-azure-compliance,281,251,360
steampipe-mod-azure-tags,0,4,228
steampipe-mod-azure-thrifty,0,4,13
steampipe-mod-digitalocean-thrifty,0,5,9
steampipe-mod-gcp-compliance,91,13,114
steampipe-mod-gcp-labels,0,4,44
steampipe-mod-gcp-thrifty,0,5,14
steampipe-mod-github-sherlock,0,4,34
steampipe-mod-ibm-compliance,20,21,67
steampipe-mod-kubernetes-compliance,165,28,158
steampipe-mod-oci-compliance,31,6,33
steampipe-mod-oci-thrifty,0,8,18
steampipe-mod-terraform-aws-compliance,153,39,153
steampipe-mod-terraform-azure-compliance,151,34,151
steampipe-mod-terraform-gcp-compliance,55,9,55
steampipe-mod-zoom-compliance,1,44,171
```




