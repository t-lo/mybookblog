#!/bin/bash

# Only required after initial checkout. Here to be on the safe side.
git submodule init
git submodule update

# Render pages and start hugo server. The server will auto-update content on changes.
hugo server --disableFastRender
