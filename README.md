# AceRaxxClusterExample

**An example of how to setup a multi node web service in elixir**

This example is built upon by tcp server [Ace](https://github.com/CrowdHailer/Ace) and by server interface [Raxx](https://github.com/crowdhailer/raxx).
Why? because experiments.

## Topics I want to tackle:

- node discovery
- clustering
- releases

## Status

The system looks up nodes from the `sys.config` file.
This means the core network is static although nodes that discover the core network will become part of the cluster.

i.e. it doesn't do discovery (this is the next step)

Instructions for running are with mix.

i.e. Releases are also outstanding.


## Usage

**These examples all run in Vagrant, to see an example where everything runs on one node check [version 0.1.0]()**

On host.
- clone this repo.
- start up nodes with vagrant.

On guests.
- fetch dependencies
- start program with common secret and correct name.

```
git clone git@github.com:CrowdHailer/ace-raxx-clustering-example.git
cd ace-raxx-clustering-example
vagrant box update

vagrant up

vagrant ssh prod1
...
cd /vagrant
mix deps.get
iex --name example@10.10.10.2 --erl "-config sys.config -setcookie ace" -S mix
```

visit [10.10.10.2:8080](10.10.10.2:8080)
