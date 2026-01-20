#!/bin/bash

if id minecraft &>/dev/null; then
  echo "👤 Usuario minecraft ya existe"
else
  useradd -r -m -U -d /opt/minecraft -s /bin/bash minecraft
fi