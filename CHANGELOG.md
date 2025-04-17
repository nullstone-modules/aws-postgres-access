# 0.6.1 (Apr 17, 2025)
* Eliminated problematic special characters from password generation.

# 0.6.0 (Oct 13, 2023)
* Use pg-db-admin v0.7.
  * Switch to using `aws_lambda_invocation` instead of `restapi_object`.
  * `restapi_object` is deprecated, it is used if the connecting postgres is using db-admin v0.6
  * "legacy" configuration of db-admin is fully removed.

# 0.5.5 (May 18, 2023)
* Added support for interpolating `database_name` with `{{ NULLSTONE_STACK}}`, `{{ NULLSTONE_STACK}}`, and `{{ NULLSTONE_ENV }}`.
* Added `server` to list of supported app categories.

# 0.5.5 (Apr 21 2023)
* Added overview and troubleshooting to `README.md`.

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
