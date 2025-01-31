# NAPA

```txt
From the English: [NA]bu [PA]ackage
```

## A package format for NABU adaptor content

## What is NAPA?

NAPA is a package format for NABU adaptor content. It allows authors to package their programs, storage content, PAKs and other content, and make them available in a central repository.

## Why is NAPA?

As more software becomes available for NABU, it becomes harder for adaptor creators to keep up with the latest versions of the software if they have to release their entire emulator to do so. NAPA allows packaging content in a way that is easy for adaptors to consume, and easy for users to install.

## What is a NAPA package?

```bash
    /package id/                  # A folder with package contents, or bundled into a .napa file
    |── napa.yaml or napa.json    # NAPA manifest (bundled packages must contain json)
    ├── /programs/                # NABU programs (.nabu files)
    ├── /storage/                 # storage files   
    ├── /paks/                    # paks (unencrypted, unspooled, .nabu files)
    └── /.../                     # other content the adaptor can do something with
```

A NAPA package is a NAPA file (`.napa`) or a directory with a `napa.yaml` or `napa.json` file in it: a file containing metadata about the package and the content in the various subdirectories of the package.

### So what's in this file?

They look like this:

```yaml
id: nns-bundle-sample                   # A globally unique identifier for the package 
name: Sample Package                    # The human-readable name of the package
description: |                          # A description of the package
  A sample package.
author: Awesome Author                  # The author of the packages
version: 0.1.1                          # The version of the package, a string `sort order` higher 
                                        # than the previous version, dates generally work as part of
                                        # or depending on formatting, the entire version.
url: https://project/site               # A link to more information

manifest:                               # The manifest lists programs, paks, sources, and storage files
                                        # with special handling needs.
                                        # Programs are listed in a source named after the package
                                        # Storage files are symlinked to a storage folder
                                        # PAKs are listed as sources, seperate from the package they came from.

  programs:                             # A list of programs in the package
    - path: hot-tub.nabu
      name: Sick Game
  storage:                              # Any special file handling needed
    - path: lake-house.file             # The path to the file in the `storage` folder
      name: ice-cream.file              # Storage relative destination path (if required)
      options:                           
        updatetype: copy                # Copy, move, or symlink (default: symlink)
  sources:                              # source feeds
    - path: https://.../
    - name: Remote Feed
  paks:                                 # folders with cycle pak files
    - path: to/pak/folder
      name: A sweet custom cycle 
features:                               # Control adaptor features
  RetroNet: false                       
  NHACPv01: true
```

They final manifest must be JSON. The make scripts in this repository will convert yaml to json for you during packaging if you choose to author in yaml.

## What's in this repo?

This repo contains the Benevolent Societies package repository, the default repository used by NABU NetSim.
And all the tools to create the packages in that repo, and the repository list itself.

### What do you need to build the repo?

- PowerShell 7+
