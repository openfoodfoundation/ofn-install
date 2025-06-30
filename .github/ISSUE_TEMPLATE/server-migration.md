---
name: Server migration
about: Checklist to migrate to an upgraded server
title: ''
labels: ''
assignees: ''

---

Checklist based on general guide https://github.com/openfoodfoundation/ofn-install/wiki/Migrating-a-Production-Server

Each  server may be slightly different, so make sure to update the list as needed.

Tip: find/replace to set up most commands ready to go, eg: `x_prod` -> `ca_prod`

## 1. Setting up the new server
- [ ] Check old server config for any additional services to be aware of. Document any necessary steps for migration. Eg:
  - `ls /etc/nginx/sites-enabled`
  - `systemctl --state=running`
- [ ] Hosting: provision new server with current supported version of Ubuntu
- [ ] DNS: drop TTL of records pointing to old IP address (eg root and www).

### config
- [ ] Review `host_vars/x/config.yml`, clean up if needed
- [ ] Review `group_vars/x.yml`, clean up if needed
- [ ] Review `ofn-secrets:x_prod/secrets.yml`, clean up if needed
   - Take note of third party services, and if they need updating (eg update IP whitelist for new IP)

### setup
Enable passthrough on _current_ server to allow new server to generate a certificate:
- [ ] `ansible-playbook playbooks/letsencrypt_proxy.yml -l x_prod -e "proxy_target=<new_ip>" `

Then setup new server. Ensure you have the correct secrets (current secrets are usually fine).
`ansible-playbook -l x_prod2 -e "@../ofn-secrets/x_prod/secrets.yml" playbooks/`
- [ ] `setup.yml`
- [ ] `provision.yml`
- [ ] `deploy.yml`
- [ ] `db_integrations` (Permit DB access for n8n, Metabase)

### initial migration
- [ ] Ensure sidekiq is disabled, to avoid creating subscription orders when data is loaded:
    `sudo systemctl stop sidekiq && sudo systemctl disable sidekiq`
- [ ] Setup direct ssh access for `ofn-admin` and `openfoodnetwork` as per [guide][guide]

`ansible-playbook -l x_prod -e rsync_to=x_prod2 playbooks/`
- [ ] `db_transfer.yml` &&
- [ ] `transfer_assets.yml`

Make sure to clear cache so that instance settings are applied:
`cd ~/apps/openfoodnetwork/current; bin/rails runner -e production "Rails.cache.clear"`

## 2. Testing
Use a `hosts` file entry to test new server using the domain name
 - [ ] test `reboot`
 - [ ] send test mail (`/admin/mail_methods/edit`). 
 - [ ] terms of service file: `/admin/terms_of_service_files`
 - [ ] shop catalogue display correctly, with images, add to cart, begin checkout, login.
    note: check cookies if login won't work
 - Check integrations 
   - [ ] Payments (check Stripe connect status `/admin/stripe_connect_settings/edit`)
   - [ ] New Relic
   - [ ] Bugsnag

## 3. Migration
### preparation
- [ ] Reset database on new server, to avoid any migration issues due to being out of sync
  `bin/rake db:reset` (You will need to confirm. Make sure you're on the new server!)
- [ ] Update ansible_host IP in `inventory/hosts` and ensure provision works (this will update host in `.env.production`).
    `ansible-playbook playbooks/provision.yml -l x_prod`
- [ ] `ansible-playbook playbooks/deploy.yml -l x_prod -e "git_version=vX.Y.Z"` matching version with current prod (you can check this at the bottom of `/admin/` dashboard)
- [ ] old server: make a tiny data change to verify later (eg add `.` in meta description `/admin/general_settings/edit`)

### switchover: old server
- [ ] 🚧 `ansible-playbook playbooks/maintenance_mode.yml -l x_prod`
- [ ] `sudo systemctl stop sidekiq redis-jobs puma`
- [ ] `ansible-playbook -l x_prod -e rsync_to=x_prod2 playbooks/db_transfer.yml &&`
- [ ] `ansible-playbook -l x_prod -e rsync_to=x_prod2 playbooks/transfer_assets.yml`
- [ ] Transfer `/var/lib/redis-jobs/dump.rdb` to new server (see [guide][guide]
- [ ] `sudo systemctl stop postgresql` (ensure other integrations no longer touch it)

### switchover: new server
- [ ] `sudo systemctl restart puma; sudo systemctl start sidekiq redis-jobs`
- [ ] `cd ~/apps/openfoodnetwork/current; bin/rails runner -e production "Rails.cache.clear"` (or migrate redis-cache/dump.rdb also)
- Use a `hosts` file entry to test that there are no alarm bells, eg:
  - [ ] tiny data change is present. undo it.
  - [ ] shopfront and checkout looks good
  - [ ] upload a product image
  - [ ] `~/apps/openfoodnetwork/current/log/production.log` and `sidekiq.log`
- [ ] ⏭️ Update DNS to point to new server
- [ ] get confirmation from local team
- [ ] make sure the entries in ofn-install are up to date: set the new IP address and remove any temporary entry made for the migration
- Update documentation: 
  * [ ] https://github.com/openfoodfoundation/ofn-install/wiki/Current-servers
  * [ ] This migration guide if necessary

## 4. Cleanup (after 48hrs)
- [ ] check server access logs to verify no traffic
- [ ] shut down the old VPS
- [ ] delete old VPS (or rename for future deletion)
- [ ] check metabase sync if required: https://data.openfoodnetwork.org/admin/databases/
- [ ] check n8n
- [ ] check backups are functioning


## Rollback plan
* If an error occurs after dns change, users may have interacted with the new server (eg made payments).
   * if serious, consider putting new server into maintenance mode (and stop sidekiq) to avoid further changes, while investigating
   * otherwise seek to resolve issue in-place.
   * avoid changing dns back to old server, because it could be missing any new payments.

[guide]: https://github.com/openfoodfoundation/ofn-install/wiki/Migrating-a-Production-Server
