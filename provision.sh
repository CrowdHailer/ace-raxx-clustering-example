#! /bin/bash

# Install the Elixir and Erlang languages as required.
wget https://packages.erlang-solutions.com/erlang-solutions_1.0_all.deb
dpkg -i erlang-solutions_1.0_all.deb
apt-get update
apt-get install -y erlang
apt-get install esl-erlang
apt-get install -y elixir
