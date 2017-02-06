# Klimt

Klimt is a **C**ommand **L**ine **I**nterface **M**etadata **T**ool. That almost spells Klimt. So close.

It makes it dead simple to view Artsy API json responses from the command line.

## Basic Usage

Klimt has four basic subcommands which will work with most REST-ful endpoints in the API (see [caveat](#caveat)).

### View a resource

Supply the model name as it appears in the v1 API endpoint, and an id:

```sh
$ klimt find partner gagosian-gallery
$ klimt find artist damien-hirst
```

### List a collection of resources

Supply the (usually plural) model name as it appears in the v1 API endpoint, and optionally some API parameters:

```sh
$ klimt list partners
$ klimt list partners eligible_for_listing=true near=30,-90
```

### Find a resource via term search

Supply the term to search for (enclosed in quotes if it contains whitespace), and optionally a list of space-delimited [indexes](https://github.com/artsy/gravity/blob/baf6bd35f4c5c1a6011d0608d641e8d6608124e7/app/api/v1/match_endpoint.rb#L150) to constrain the search.

```sh
$ klimt search "Gagosian Gallery"
$ klimt search Gagosian --indexes=Article Artwork
```

### Count a resource

Supply the (usually plural) model name as it appears in the v1 API endpoint, and optionally some API parameters:

```sh
$ klimt count cultures
$ klimt count cultures nationalities=true
```

### Caveat re: root-level endpoints

The above four commands work great when the API endpoint in question is structured as a root-level endpoint rather than a nested one. So for now… `/api/v1/partner/<id>` :heavy_check_mark: but `/api/v1/partner/<id>/locations` :x:.

See [the discussion](https://github.com/artsy/potential/blob/521d34796e2df87406cc0e780db1e44b1ac9884a/Playbook.md#out-with-the-old) under "Gravity's v1 API" in Potential.


## Klimt :sparkling_heart: JQ

[JQ](https://stedolan.github.io/jq/) is a command line JSON pretty-printing and transformation tool that works great with Klimt

```sh
$ klimt list partners | jq '.[] | { id, name }'
$ klimt find partner 'dickinson' | jq '.name'

```

## Installation

Since it's not distributed via RubyGems, you'll fetch and build it yourself which is as simple as: 

```sh
$ git clone https://github.com/anandaroop/klimt.git
$ cd klimt
$ gem build klimt
$ gem install klimt
```

Klimt uses a Gravity `ClientApplication`, whose id and secret you'll have to supply in your environment as `KLIMT_ID` and `KLIMT_SECRET`.

```sh
$ KLIMT_ID=<replace> KLIMT_SECRET=<replace> klimt help
```

Or just add these env variables to your shell startup script.

