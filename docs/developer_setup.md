# Developer Setup
The warehouse application consists of two parts:
1. The Rails Application Code
2. The Rails Application Database

## Setup Your Development Environment

1. Clone the git repository
```
git clone git@github.com:greenriver/boston-cas.git
```
2. Install Docker Desktop for your OS following the [instructions provided by Docker](https://www.docker.com/get-started).

3. Adjust the Docker Resources to allow up to 8GB of RAM.  See Docker -> Preferences -> Resources

4. If you have not previously setup [nginx-proxy](https://github.com/jwilder/nginx-proxy) to streamline local development. You should [follow the instructions here](developer-networking.md) before continuing.

5. Run the setup script
```
docker-compose run --rm shell bin/setup
```

6. Run the rails server
```
docker-compose run --rm web
```

## Accessing the Site

If everything worked as designed your site should now be available at [https://boston-cas.dev.test](https://boston-cas.dev.test).  Any mail that the site sends will be delivered to [MailHog](https://github.com/mailhog/MailHog) which is availble at [https://mail.boston-cas.dev.test](https://mail.boston-cas.dev.test)

## Additional Notes

Depending on how your development environment's root permission are set, you may run into some issues with the web app-user not having required permissions on some sub-folders. The following command may clean up any folder permissions that are needed for the web user to work with these folders.

`docker compose run -u 0 --entrypoint='' web chown -R app-user:app-user /node_modules /bundle /app /log /tmp`

You may need to replace or add to the `/node_modules /bundle /app /log /tmp` section to include the directory needing a permission reset.