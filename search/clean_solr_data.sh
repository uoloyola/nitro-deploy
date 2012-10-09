#!/bin/sh
# Clean solr indexes data

rm -rf /opt/polopoly/solr.home/internal/data/*
rm -rf /opt/polopoly/solr.home/public/data/*
rm -rf /opt/polopoly/solr.home/events/data/*

