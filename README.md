# README

## Overview

This Rails API is the backend (BE) for the "Watts My Electricity Bill".  It exposes appropriate endpoints to provide frontend (FE) functionality to provide information on users, reports that they create / searches they make, and makes external API call(s) to pull raw utility data and calculate estimated expenses.

In order to run this backend, execute `rails s`.  The server runs on port 3000 for the time being (it is important for the port to be distinct from the Vite server which runs the FE).

Note: we might wish to have more info on how to set this up for new users, deploying, etc.  Optionally can be done later.

## Test suite

All tests utilize RSpec.  In order to run any of these tests, use `bundle exec rspec [path]`.  Differet types of tests exist for any code-heavy files and objects.  Of note:
- Models: these are found in `spec/models/`
- Controllers: these are found in `spec/requests/api/v1/`
- POROS / gateways / misc: this holds objects which primarily handle external data and API calls.  These are located in `spec/poros/`

## Endpoints

This API exposes the following endpoints.  Note: these will be updated as additional functionality appears (including variable / JSON text at times).  These are only for usage by the frontend (FE).

### Utilities: Get utility rates, energy and money costs

Make a request for utility (electricity) rates / data, which is acquired from external data and API(s), massaged / calculated, and returned.

- `GET /api/v1/utilities`. Expected parameters (i.e. passed as `?<params>`):
    - `nickname` (unique name for report / property / planned establishment)
    - `zipcode` (zipcode of the user)
    - `residence_type` (type or 'class' of residence; for now simply `"apartment"` or `"house"`)
    - `num_residents` (number of residents living there)
    - `efficiency_level` (degree to which resident tries to save energy, on a scale of 1 (efficient) to 10 (comfort))

- Response structure:
    - Status:
        1. 200 - successful, standard JSON (see below)
        2. 404 - failure, resource not found (likely external API failure)
        3. 422 - problem with parameters / misc issue (note: parameters are validated, and error have an array of messages for each failed parameter)
    - Body: returns JSON data.  Typical structure (NOTE - may return more later, see below):
        {
            "nickname": (string) name of place,
            "energy_consumption": (float) energy consumption,
            "state": (string) state of the zipcode,
            "state_average": {
                "residential": (float) residential rate for month,
                "industrial":(float) industrial rate for month,
                "commercial": (float) commercial rate for month 
            },
            "zip_average": {
                "residential": (float),
                "industrial": (float),
                "commercial": (float) 
            }
        }
        ```
        Notes: `nickname` should echo what the user entered; this is a simple additional confirmation / verification.  `energy_consumption` is measured by default in kWh and is annual (1 year).  `cost` is in dollars ($), and also annual.  LATER (significantly after MVP): can return additional information, like more detailed location information, utility company / other factors, even carbon footprint, etc.
    - Additional notes:
        1. For now, this should only return one result.  Later, or if multiple utility companies exist in the area, it might return an array (like `{ [ <JSON> ] }`), but this would be post-MVP.
        2. We may wish to return state-level average energy cost rates so a user can compare them.  In this case, the JSON response could have the key-value pair `average_state_rate: <float>` or similar.

### Users: Get single user information

Request an individual user's information (likely used by FE to display user's saved reports, primarily).

- `GET /api/v1/users/:id`.  As usual, `:id` is the ID of the user of interest.
- Response structure:
    - Status:
        1. 200 - successful, standard JSON (stucture shown below).
        2. 404 - ID invalid / does not exist in database.
    - Body: returns JSON data.  Typical structure:
        ```
        {
            username: <string>,
            num_reports: <integer>,
            reports: [
                {
                    nickname: <string>,
                    id: <integer>
                },
                {
                    nickname: <string>,
                    id: <integer>
                },
                ...
            ]
        }
        ```
        For an error, typical structure is:
        ```
        {
            status: 404,
            message: <string - ActiveRecord exception>
        }
        ```
- Notes: for now, the `reports` field will only return the nicknames and IDs of all the reports belonging to that user.  The FE can then use these to individually look up details on each report (for displaying on site) by calling the relevant #show action / request in the ReportsController.  Later / if desired, we could add logic to have the user info return all of these details in the array so there is only one call.  Also note that if the user has no reports, `num_reports` will equal 0, and `reports` will be an empty array to be consistent.

### Users: Get all users (index)

This route will return all users in the database (most often used for assisting with / verifying login) as an array.

- GET `/api/v1/users`
- Response structure (as JSON):
    - Status: 200 is always expected
    - Body: returns JSON data.  Typical structure:
    ```
    [
        {
            id: user id (integer),
            username: username (string)
        },
        ...
    ]
    ```
    
### Reports: Get single report details (show)

Return all information about a single report, including the user which it belongs to.

- GET `/api/v1/reports/:id`.  `:id` refers to the report's ID.
- Reponse structure (as JSON):
    - Status:
        1. 200 - successful, standard JSON (stucture shown below).
        2. 404 - report ID invalid / does not exist in database.
    - Body:
        ```
        {
            nickname: <string>,
            energy_consumption: <float>,
            cost: <float>,
            state: <string>,
            state_average: {
                residential: <float>,
                industrial: <float>,
                commercial: <float>
            },
            zip_average: {
                residential: <float>,
                industrial: <float>,
                commercial: <float>
            }
        }
        ```
- Note: to retrieve the report, no user information is needed in the request (for simplicity).

### Reports: Create new report (create)

Creates a new report, based on parameters passed via request body.

- POST `/api/v1/reports?<params>`.  Routes to: /api/v1/reports#create.  
- Request body (as JSON - only *required* parameters present):
    ```
    {
        user_id: <integer>,
        nickname: <string>,
        energy_consumption: <float>,
        energy_cost: <float>
    }
    ```
- Response structure (as JSON):
    - Status:
        1. yep
        2. per
    - Body:
        ```
        {
            nickname: <string>,
            energy_consumption: <float>,
            energy_cost: <float>,
            state: <string>,
            state_residential_avg: <float>,
            state_industrial_avg: <float>,
            state_commercial_avg: <float>,
            zip_residential_avg: <float>,
            zip_industrial_avg: <float>,
            zip_commercial_avg: <float>,
        }
        ```
- Notes:
    - For a given user, 'nickname' must be a unique string for simplicity
    - Additional parameters may be passed in the creation request body if desired; anything from the reponse body is valid.  However, these are usually not known a priori, so this will not likely see many use cases.Many of the parameters are actually optional.

### User Reports: Get All reports for a user (Index)
- GET /api/v1/user/:id/reports to: /api/v1/reports#index
    - This route gets all the user reports (only id and name) for a given user id
    - User id needs to be a valid value in the data base
- Response body:
```
    report_list = user.reports.map do |report|
      {
        nickname: nickname of report,
        id: id of report
      }

    {
      username: username of user,
      num_reports: length of report array,
      reports: report_list (list of users reports)
    }

```

### Reports: delete report

Delete a specific report based on its ID.

- `DELETE /api/v1/reports/:id`.  Here, `:id` is the ID of the report to be deleted.
- Response structure:
    - Status:
        1. 200 - successful deletion, standard JSON (stucture shown below).
        2. 404 - ID invalid / does not exist in database.
    - Body: returns JSON data.  Typical structure:
        ```
        {
            deleted_report: {
                nickname: <string>,
                id: <integer>,
                associated_username: <string>,
            },
            num_remaining_reports: <integer>
        }
        ```
        For an error, typical structure is:
        ```
        {
            status: 404,
            message: <string - ActiveRecord exception>
        }
        ```
- Note: the ID referenced is absolute as assigned in the database, NOT relative to a specific user (though it is associated with a user).
