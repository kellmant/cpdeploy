#!/bin/bash
mgmt_cli login -r true > id.txt
mgmt_cli RedSealNets -s id.txt > /dev/null 2>&1
mgmt_cli publish -s id.txt
mgmt_cli logout -s id.txt
