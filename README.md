docker-compose exec puppet puppetserver ca clean --certname agent1.test

docker-compose exec puppet puppet module install puppet-archive


docker-compose exec agent1 puppet agent --test
docker-compose exec puppet puppet agent --test


docker-compose exec puppet cat /etc/nebula/config.yml

docker-compose exec puppet bash