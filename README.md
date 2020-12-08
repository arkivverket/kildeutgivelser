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
