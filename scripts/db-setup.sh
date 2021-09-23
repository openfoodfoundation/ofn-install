#!/bin/bash
# Createded date: 21/03/2016

# Flags
set -e

bundle="$PWD/.rbenv/shims/bundle"

cd openfoodnetwork/
echo "Copy example config/application.yml"
cp -n config/application.yml.example config/application.yml
echo "Installing ruby application and gem dependencies"
"$bundle" install
echo "Doing the database setup..."
"$bundle" exec rake db:setup << EOF
spree@example.com
spree123
EOF
echo
echo "Load default data for development environment..."
"$bundle" exec rake ofn:dev:load_sample_data
