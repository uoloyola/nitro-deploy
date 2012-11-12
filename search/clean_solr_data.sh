#!/bin/sh
# Clean solr indexes data

rm -rf /var/lib/polopoly/index/internal/data/*
rm -rf /var/lib/polopoly/index/public/data/*
rm -rf /var/lib/polopoly/index/events/data/*