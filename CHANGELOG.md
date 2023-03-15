# 0.5.4 (Mar 15, 2023)
* Fix issues with database access when changing `database_name` after initial launch. 

# 0.5.3 (Feb 09, 2023)
* Use Lambda Function URL from outputs of postgres datastore outputs.

# 0.5.2 (Feb 03, 2023)
* Slow down `restapi_object` resources to prevent rate limiting issues with AWS Lambda Function URL.

# 0.5.1 (Sep 13, 2022)
* Ignore deletes for db objects.

# 0.5.0 (Sep 13, 2022)
* Convert postgres access to use full CRUD against a REST API.
