# Start from postgres image with preloaded ichiran database
FROM sissbruecker/ichiran-db:latest

# Install dependencies
RUN apk add --no-cache sbcl curl git

# Collect ichiran sources into quicklisp local project storage
WORKDIR /root/quicklisp/local-projects

RUN git clone https://github.com/tshatrov/ichiran.git
COPY images/cli/settings.lisp ichiran/

# Collect build files into /var/lib/ichiran-cli
WORKDIR /var/lib/ichiran-cli

COPY images/cli/build-cli.lisp .
COPY images/cli/build-cli.sh .
COPY images/cli/jmdictdb ./jmdictdb
RUN curl -O https://beta.quicklisp.org/quicklisp.lisp
RUN chmod +x build-cli.sh
