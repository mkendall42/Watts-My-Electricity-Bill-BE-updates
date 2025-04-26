# README

## Overview

This Rails API is the backend for the "Watts My Electricity Bill".  It exposes appropriate endpoints to provide frotnend functionality to provide information on users, reports that they create / searches they make, and makes external API call(s) to pull raw utility data and calculate estimated expenses.

In order to run this backend, execute `rails s`.  The server will run on port 3000 for now.  We may need to adjust this if it conflicts with the FE.

Note: we might wish to have more info on how to set this up for new user, deploying, etc.  Optionally can be done later.

## Test suite

Add later: will have some for requests/, models/, and more (maybe POROs, gateways, whatever)

## Endpoints

This API exposes the following endpoints.  Note: these will be updated as additional functionality appears (including variable / JSON text at times).  These are only for usage by the frontend.

### Utilities: Get utility rates, energy and money costs

Make a request for utility (electricity) rates / data, which is acquired from external API(s), massaged / calculated, and returned.

- `GET /api/v1/utilities`. Expected parameters (i.e. passed as `?<params>`):
    - `nickname` (unique name for report / property / planned establishment)
    - `zipcode` (zipcode of the user)
    - `residence_type` (type or 'class' of residence; for now simply `"apartment"` or `"house"`)
    - `num_residents` (number of residents living there)
    - `efficiency_level` (degree to which resident tries to save energy; for now simply 1 (efficient) or 2 (comfort) - later can be an index value or even float)

- Response structure:
    - Status:
        1. 200 - successful, standard JSON (see below)
        2. 404 - failure, resource not found (likely external API failure)
        3. 422 - problem with parameters / misc issue (note: parameters are now validated, and error have an array of messages for each failed parameter)
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
        Notes: `nickname` should echo what the user entered; this is a simple additional confirmation / verification.  `energy_consumption` is measured by default in kWh and is annual (1 year).  `cost` is in dollars ($), and also annual.  LATER (after MVP, most likely): can return additional information, like more detailed location information, utility company / other factors, even carbon footprint, etc.
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
GET /api/v1/users to: /api/v1/users#index
  - This route will get all users in the database.

### Reports: Get all reports (index)

### Reports: Get single report details
GET /api/v1/reports/:id to: /api/v1/reports#show

### Reports: Create new report
POST /api/v1/reports?<params> to: /api/v1/reports#create

```
params: 
    nickname: string,
    energy_consumption: float,
    cost: float,
    state: string,
    state_residential_avg: float,
    state_industrial_avg: float,
    state_commercial_avg: float,
    zip_residential_avg: float,
    zip_industrial_avg: float,
    zip_commercial_avg: float,
```
