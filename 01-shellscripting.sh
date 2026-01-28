#!/bin/bash

# This script demonstrates basic shell scripting concepts

# 1. Variables
name="vedavyas"
echo "Hi this is $name"

# 2. Conditional Statements
age=$1

if [ $age -eq 26 ]; then
    echo "approved welcome to devops world"
else
    echo "You are not approved!"
fi  