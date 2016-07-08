server 'theater-kaisersesch.de', user: 'deployer', roles: %w{app db web resque}

set :deploy_to, '$HOME/apps/FasT'
