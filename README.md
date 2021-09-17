# kildeutgivelser

## Starting

- `./build.sh`
- `cp .env.default .env`
- fill out .env

## Database

The database needs a default entry to the projects table.

The Docker image contains a default project name `stattholder`.

If you want to change the default project, that change also has to be reflected in the api, web and tei_tools config

```sql
INSERT INTO public.project ("published", "name") VALUES ('2', 'stattholder');
```

## Adding new users to edith

Generate a sha1 hash of the password, and add the user to the database and the edituthsers [htpasswd](./svn/edithusers) file.

```sql
INSERT INTO edith.user (firstName, password, profile, username, active) VALUES ('[username]', '[sha1 passwrod]', 'User', '[username]', '1');
```
