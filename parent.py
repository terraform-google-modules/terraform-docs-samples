#! /Users/sampathm/.pyenv/shims/python
"""
Purpose: To check add parent region tags for all Terraform samples.
 
To use for a specific folder,
    1. update `product_prefixes` dict. Only update devrel product region tag for your 
product folder
 
    1. Run the following commands
 
        # run at terraform-docs-samples folder
        python parent_region_tags.py
 
To use for specific file,
 
    1. update `product_prefixes` dict. Only update devrel product region tag for your 
product folder
 
    1. Run command like following
    $ python parent_region_tags.py bigquery/bigquery_create_dataset/main.tf
 
If you wish some files to be ignored, then add them to `ignore_files` list
 
"""
import os
import glob

# Key-value pairs of product_folder name & product_region_tag_prefix
# Only Keys which have value will be processed
product_prefixes = dict({
    "bigquery": "bigquery_",
    "certificate_manager": "certificatemanager_",
    "cloud_sql": "",
    "composer": "composer_",
    "compute": "compute_",
    "dns": "dns_",
    "eventarc": "eventarc_",
    "functions": "functions_",
    "gkeonprem": "gke_",
    "iam": "iam_",
    "lb": "cloudloadbalancing_",
    "media_cdn": "mediacdn_",
    "network_connectivity": "networkconnectivitycenter_",
    "network_management": "networkmanagement_",
    "privateca": "",
    "run": "cloudrun_",
    "storage": "storage_",
    "traffic_director": "trafficdirector_",
    "vertex_ai": "aiplatform_",
    "vpc": "",
    "vpn": "",
})

# Region Tag
parent_region_tag_format = "{product_region_tag_prefix}{folder_name}_parent_tag"

# files defined in below are ignore for updates
ignore_files = [
    'bigquery/bigquery_create_dataset_cmek123123/main.tf'
]

def get_new_parent_region_tag(main_tf_path):
    assert len(main_tf_path.split(os.path.sep)) == 3, "Error! Un-expected file location"
    assert main_tf_path.endswith('main.tf'), "Error! Expected a main.tf file"
    product_folder, sub_folder_name, file_name = main_tf_path.split(os.path.sep)
    return parent_region_tag_format.format(**dict({
        'product_region_tag_prefix': product_prefixes[product_folder],
        'folder_name': sub_folder_name.replace('-', '_')
    }))


def tf_file_processor(main_tf_path):
    if main_tf_path in ignore_files:
        print(f'- Skipping {main_tf_path}')
        return
    # Prepare new Parent Region Tag
    print(f'- Reading {main_tf_path}')
    parent_region_tag = get_new_parent_region_tag(main_tf_path)
    print('\t New Region Tag:' + parent_region_tag)

    # Read main.tf file & prepare new main.tf
    file_info = open(main_tf_path).read().strip()
    new_file_info = []
    found_first_resource = True
    N = 0
    for line in file_info.splitlines():
        N +=1
        if found_first_resource:
            if line.startswith('resource') or\
                    line.startswith('data') or \
                    line.startswith('terraform') or line.startswith('# [START'):
                new_file_info.append(f'# [START {parent_region_tag}]')
                found_first_resource = False
        new_file_info.append(line)
    new_file_info.append(f'# [END {parent_region_tag}]')
    assert len(new_file_info) == N + 2
    # from pprint import pprint
    # pprint('\n'.join(new_file_info))

    # Write new main.tf
    with open(main_tf_path, 'w') as fp:
        fp.write('\n'.join(new_file_info))
    print('\t Updated File!')


def main():
    for folder_name, region_tag_prefix in product_prefixes.items():
        # if region tag prefix is not defined, ignore that folder
        if region_tag_prefix:
            if not os.path.isdir(folder_name):
                raise NotADirectoryError(f'Folder {folder_name} is not found!')
            print("\n" + "="*24)
            print(f'# Reading Folder: {folder_name}')
            for main_tf_path in glob.glob(f'{folder_name}/*/main.tf'):
                sub_folder_name = main_tf_path.split(os.path.sep)[1]
                tf_file_processor(main_tf_path)

                # stopper
                # break



import sys
if sys.argv and sys.argv[-1].endswith('main.tf'):
    print('Found User Args')
    print(sys.argv)
    tf_file_processor(sys.argv[-1])
else:
    # run command  on CLI>>>> clear; python parent_region_tags.py bigquery/bigquery_create_dataset/main.tf
    main()
