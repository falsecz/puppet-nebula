```sh
# start up
docker-compose up -d

# tear down
docker-compose down
```

```sh
docker-compose exec puppet_master puppetserver ca clean --certname agent1.test

docker-compose exec puppet_master puppet module install puppet-archive

docker-compose exec puppet_agent_one puppet agent --test

docker-compose exec puppet_master puppet agent --test

docker-compose exec puppet_master cat /etc/nebula/config.yml

docker-compose exec puppet_master bash
```
