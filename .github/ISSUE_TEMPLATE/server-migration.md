---
name: Server migration
about: Checklist to migrate to an upgraded server
title: ''
labels: ''
assignees: ''

---

Checklist based on general guide https://github.com/openfoodfoundation/ofn-install/wiki/Migrating-a-Production-Server

## 1. Setting up the new server
- [ ] Check old server config for any additional services to be aware of (eg `/etc/nginx/sites-available`). Document any necessary steps for migration.
- [ ] Hosting: provision new server with Ubuntu 20
- [ ] DNS: add temporary domain (eg `prod2.openfoodnetwork.org`)

### config
- [ ] Add temporary name to `inventory/hosts`
- [ ] Review `host_vars/x/config.yml`, clean up if needed
  - Make a copy for the temp hostname, add temp domain to bottom of `certbot_domains`
- [ ] Review `ofn-secrets:x_prod/secrets.yml`, clean up if needed
   - Change to shared bugsnag projects
   - Don't bother making a copy of this one

### setup
Enable passthrough on _current_ server to allow new server to generate a certificate:
- [ ] `ansible-playbook playbooks/letsencrypt_proxy.yml -l x_prod -e "proxy_target=<ip>" `

Then setup new server. Ensure you have the correct secrets (current secrets are usually fine).
`ansible-playbook -l x_prod2 -e "@../ofn-secrets/x_prod/secrets.yml playbooks/`
- [ ] `setup.yml`
- [ ] `provision.yml`
- [ ] `deploy.yml`
- [ ] `db_integrations` (Permit DB access for n8n, Metabase)

### initial migration
- [ ] Ensure sidekiq is disabled, to avoid creating subscription orders when data is loaded:
    `sudo systemctl stop sidekiq && sudo systemctl disable sidekiq`

`ansible-playbook -l x_prod -e rsync_to=x_prod2 playbooks/`
- [ ] Setup direct ssh access for `ofn-admin` and `openfoodnetwork` as per guide
- [ ] `db_transfer.yml`
- [ ] `transfer_assets.yml`

## 2. Testing
 - [ ] test `reboot`
 - [ ] send test mail (`/admin/mail_methods/edit`). 
 - [ ] terms of service file: `/admin/terms_of_service_files`
 - [ ] shop catalogue display correctly, with images, add to cart, begin checkout, login
  - note: check cookies if login won't work
 - Check integrations 
   - [ ] Payments (check Stripe connect status `/admin/stripe_connect_settings/edit`)
   - [ ] New Relic
   - [ ] Bugsnag

## 3. Migration
### preparation
- [ ] new server: `bundle exec rake db:reset -e production`
- [ ] `deploy.yml -l x_prod2 -e "git_version=vX.Y.Z"` matching version with current prod
- [ ] old server: make a tiny data change to verify later (eg add `.` in meta description `/admin/general_settings/edit`)

### switchover: old server
- [ ] 🚧 `maintenance_mode.yml`
- [ ] `sudo systemctl stop sidekiq redis-jobs puma`
- [ ] Transfer `/var/lib/redis-jobs/dump.rdb` to new server (see guide)
- [ ] `db_transfer.yml` ~3min
- [ ] `sudo systemctl stop postgres` (ensure other integrations no longer touch it)
- [ ] `transfer_assets.yml` just in case

### switchover: new server
- [ ] `sudo systemctl restart puma; sudo systemctl start sidekiq redis-jobs`
- [ ] `Rails.cache.clear` (or migrate redis-cache/dump.rdb also)
- [ ] ⏭️ `temporary_proxy.yml -e 'proxy_target=<ip>'` redirect traffic to new prod
  * Note: this doesn't include webservices, and doesn't handle images. So it's a very short-term fix if at all.
  * Use a `hosts` file entry to test a direct connection
- Check there are no alarm bells, eg:
  - [ ] `~/apps/openfoodnetwork/current/logs/production.log` and `sidekiq.log`
  - [ ] tiny data change is present. undo it.
  - [ ] shopfront and checkout looks good
  - [ ] upload a product image
  - [ ] get confirmation from local team
- [ ] Update DNS to point to new server

## 4. Cleanup (after 48hrs)
- [ ] check server access logs to verify no traffic
- [ ] shut down the old server, cancel old VPS
- [ ] remove DNS for temporary subdomain
- [ ] make sure the entries in ofn-install are up to date: remove the temporary entry made for the migration, and set the new IP address. 
- [ ] validate that `provision.yml` still works. This will rename x-prod2 to x-prod
- [ ] check metabase sync if required: https://data.openfoodnetwork.org.uk/admin/databases/
- [ ] check n8n
- [ ] check backups are functioning
- Update documentation: 
  * [ ] https://github.com/openfoodfoundation/ofn-install/wiki/Current-servers
  * [ ] This migration guide if necessary


## Rollback plan
* If an error occurs before the temporary proxy is active, and can't be resolved quickly, then restore service back to current server
* If an error occurs after proxy is active, users may have interacted with the new server (eg made payments.
   * if serious, consider putting into maintenance mode (and stop sidekiq) to avoid further changes
   * otherwise seek to resolve issue in-place.
