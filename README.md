# AceRaxxClusterExample

**An example of how to setup a multi node web service in elixir**

This example is built upon by tcp server [Ace](https://github.com/CrowdHailer/Ace) and by server interface [Raxx](https://github.com/crowdhailer/raxx).
Why? because experiments.

## Topics I want to tackle:

- node discovery
- clustering
- releases

## Status

Node discovery is done by UDP broadcasts to the ip `10.10.10.255`.
This mechanism will discover all nodes with the ip address `10.10.10.*`.
Assuming:

- That the node is named `example@10.10.10.*`
- That the nodes share the same secret.
- The nodes name matches the ip address of the virtual machine.

#### Notes
- To broadcast a udp socket must have been opened with broadcast set to true.
- Vagrant by default uses a network mask of `255.255.255.0` [ref](https://friendsofvagrant.github.io/v1/docs/host_only_networking.html). "This means that as long as the first three parts of the IP are equivalent, VMs will join the same network."
- I don't really understand what the difference between multicast and broadcast is.
  There might be a reason to use multicast as in the case with [libcluster](https://github.com/bitwalker/libcluster/blob/master/lib/strategy/gossip.ex).
  Or this zeroconf [example](http://stackoverflow.com/questions/78826/erlang-multicast).

Instructions for running are with mix.

i.e. Releases are also outstanding.


## Usage

**These examples all run in Vagrant, to see an example where everything runs on one node check [version 0.1.0](https://github.com/CrowdHailer/ace-raxx-clustering-example/tree/0.1.0)**

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
iex --name example@10.10.10.2 --erl "-setcookie ace" -S mix
```

visit [10.10.10.2:8080](10.10.10.2:8080)

Start up prod2 and prod3, ensuring:

- That their names match their ip's.
- They all have the same cookie.
