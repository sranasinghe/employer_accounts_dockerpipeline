## Setup Accounts project on an EC2 pairing box

 - pair me
 - cd to the src directory
 - clone the accounts project using the GIT url, i.e. “git@github…"
 - unset XDG_RUNTIME_DIR  (DO this every time you open a shell)
 - run rake db:setup
 - hitch the pairing team

## Running in dev mode

 - copy .env.example to .env
 - replace dummy variables with real urls, etc
