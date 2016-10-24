# AceRaxxClusterExample

**An example of how to setup a multi node web service in elixir**

This example is built upon by tcp server [Ace](https://github.com/CrowdHailer/Ace) and by server interface [Raxx](https://github.com/crowdhailer/raxx).
Why? because experiments.

## Topics I want to tackle:

- node discovery
- clustering
- releases

## Status

The system looks up two nodes from the `sys.config` file.
i.e. it doesn't do discovery

Instructions for running are with mix.
i.e. Releases are also outstanding.

Current project is fixing Server Sent events in raxx so that the browser can be updated when nodes are added removed.

## Usage

- clone this repo.
- fetch dependencies
- start n1 and n2 nodes.

```
git clone git@github.com:CrowdHailer/ace-raxx-clustering-example.git
cd ace-raxx-clustering-example
mix deps.get
PORT=8080 iex --name n1@127.0.0.1 --erl "-config sys.config" -S mix

PORT=8081 iex --name n2@127.0.0.1 --erl "-config sys.config" -S mix
```

visit localhost:8080
