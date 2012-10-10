#!/bin/sh
#
# note: this script is meant to be used *only* from db.stage
#

mysqladmin -upolopoly -pluggan drop -f polopoly_espresso_stage
mysqladmin -upolopoly -pluggan create polopoly_espresso_stage

