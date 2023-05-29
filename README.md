# NAPA

```txt
From the English: [NA]bu [PA]ackage
```

## A package format for NABU adaptor content

## What is NAPA?

NAPA is a package format for NABU adaptor content. It allows authors to package their programs, storage content, PAKs and other content, and make them available in a central repository.

## What is a NAPA package?

```bash
    /package id/ [OR] package.napa
    |── napa.yaml   # NAPA manifest
    ├── /programs/  # NABU programs (.nabu files)
    ├── /storage/   # storage files   
    ├── /paks/      # paks (unencrypted, unspooled, .nabu files)
    ├── /sources/   # source lists in any compatible format
    └── /.../       # other content the adaptor can do something with
```

A NAPA package is a NAPA file (`.napa`) or a directory with a `napa.yaml` file in it. The `napa.yaml` file contains metadata about the package and the content in the various subdirectories of the package.

### Whats in a `napa.yaml` file?

```yaml
id: nns-bundle-sample                   # A globally unique identifier for the package 
name: Sample Package                    # The human-readable name of the package
description: |                          # (Opt) a description of the package
  A sample package.
author: teragav17                       # the author of the package
version: 0.1.1                          # the version of the package
manifest:
  programs:                             # (Opt) a list of programs in the package
    - path: hot-tub.nabu
      name: Sick Game
  storage:                              # (Opt) any special file handling needed
    - path: lake-house.file             # The path to the file in the `storage` folder
      name: ice-cream.file              # (Opt) storage relative destination path
      options:                           
        updatetype: copy                # copy, move, or symlink (default: symlink)
                                        
    - path: http://site/dir/file        # Urls are supported in all path elements
                      # 
  paks:
    - path 
features:                               # Control adaptor features
  RetroNet: false                       
  NHACPv01: true
options: 
  option1: value1                       # (Opt) any other options
```
