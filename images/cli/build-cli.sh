#!/bin/sh

# Run CLI build
sbcl --load quicklisp.lisp --script build-cli.lisp
# Add generated executable to path
mv /root/quicklisp/local-projects/ichiran/ichiran-cli /usr/local/bin/
