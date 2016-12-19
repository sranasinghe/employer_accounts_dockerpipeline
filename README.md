# Employer Accounts

The Employer Accounts service is NewCo's OAuth2 accounts service, providing authentication and authorization for NewCo users and client applications via [OAuth2]().  The service provides registration, login, and other account-related features.

The Employer Accounts OAuth application *protects* the NewCo API endpoints by requiring the end-user to authorize any client applications before it accesses the users protected data (e.g. plan information, benefits, deductibles, etc.).

Per OAuth2 protocols, any session must have a valid OAuth2 Access Token in order to communicate with the API.  In this way, the API is itself protected, and provides the user with confidence that their personal information is being served to them and them alone.

This project has been dockerized.

# Using the Makefile

The Makefile wraps a number of convenience development methods.  It is intended to be light and encompass only basic common operations.  Specific scripts can be added to repo as neccesary, but do not have to be in the Makefile

The default docker-compose uses the latest published images.  If you don't have any local changes to the Gemfiles, you don't need to do anything else to run tasks

## Create a new local image

If you need to update the local image due to new Gemfiles run this command

`make images`

# Gemfile changes

The Gemfile.lock that gets generated if you add gems and do a `make images` is only in the image.  You need to run `bundle install` separately on the host to capture Gemfile.lock updates

# Getting Started

```
make images
make databases
```

**To connect to benefits container: (needs *actual* aetna insurance information to register)**
`make start`

**To connect to mockapi:**
`make mock_server` (uses coverage status mocks from mockapi service to register)
[Check mocks here](https://github.com/itriage/mock_api/tree/master/public/coverage_status)

# Swagger

`<pair-box-name>.dev.wellmatchhealth.com:10000/docs`

# Running Tests

`make test`

# Debugging

`make debug`
This app uses [Pry-Byebug](https://github.com/deivid-rodriguez/pry-byebug), so use `binding.pry` for your breakpoints

# Notes

### OAuth2 and Doorkeeper

The Employer Accounts service implements an [OAuth2](http://oauth.net/2) [Password Grant flow](https://tools.ietf.org/html/rfc6749#section-1.3.3) using [Doorkeeper](https://github.com/doorkeeper-gem/doorkeeper), a Rails engine for OAuth2 providers.  It is strongly suggested that any developer wishing to make changes to the OAuth mechanics in this service be well-versed in both the general OAuth specification and Doorkeeper's capabilities.

Further, the [Access Token](https://tools.ietf.org/html/rfc6749#section-1.4) being provided is in the form of a Base64-encoded JSON Web Token, or [JWT](https://tools.ietf.org/html/draft-ietf-oauth-json-web-token-32).  This functionality is being provided by [Doorkeeper::JWT](https://github.com/chriswarren/doorkeeper-jwt).  It is important to understand that the Access Token is *not* encrypted, and does not contain any PII/PHI.
