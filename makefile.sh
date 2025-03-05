#!/bin/bash

function tf-workspace {
    if terraform workspace list | grep "$ENVIRONMENT"; then
        echo "......Terraform workspace exists......" 
    else
        echo "......Terraform workspace does NOT exists......Creating......"
        terraform workspace new $ENVIRONMENT
    fi
}

$*