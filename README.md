# Klimt

Klimt is a **C**ommand **L**ine **I**nterface **M**etadata **T**ool. That almost spells Klimt. So close.

It makes it dead simple to view Artsy API json responses from the command line.

## Usage

### View a resource

```sh
$ klimt find partner gagosian-gallery
$ klimt find artist damien-hirst
```

### List a collection of resources

```sh
$ klimt list partners
$ klimt list partners eligible_for_listing=true near=30,-90
```

### Find a resource via term search

```sh
$ klimt search "Gagosian"
$ klimt search "Eyebeam" --indexes=Article
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

## Klimt :sparkling_heart: JQ

JQ is a command line JSON pretty-printing and transformation tool that works great with Klimt

```sh
$ klimt list partners | jq '.[] | { id, name }'
$ klimt find partner 'dickinson' | jq '.name'

```
