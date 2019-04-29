#!/bin/sh

swipl -q -l dcg.pro -t "to_json" > /tmp/dcg.json
cat /tmp/dcg.json | jq .
