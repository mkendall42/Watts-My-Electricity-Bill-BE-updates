# README

## Overview

This Rails API is the backend for the "Watts My Electricity Bill".  It exposes appropriate endpoints to provide frotnend functionality to provide information on users, reports that they create / searches they make, and makes external API call(s) to pull raw utility data and calculate estimated expenses.

In order to run this backend, execute `rails s`.  The server will run on port 3000 for now.  We may need to adjust this if it conflicts with the FE.

Note: we might wish to have more info on how to set this up for new user, deploying, etc.  Optionally can be done later.

## Test suite

Add later: will have some for requests/, models/, and more (maybe POROs, gateways, whatever)

## Endpoints

This API exposes the following endpoints.  Note: these will be updated as additional functionality appears (including variable / JSON text at times).  These are only for usage by the frontend.

### Get utility rates, energy and money costs

Make a request for utility (electricity) rates / data, which is acquired from external API(s), massaged / calculated, and returned.

- `GET /api/v1/utilities`. Expected parameters (i.e. passed as `?<params>`):
    - `nickname` (unique name for report / property / planned establishment) 
    - `latitude` (in degrees)
    - `longitude` (in degrees)
    - `residence_type` (type or 'class' of residence; for now simply `"apartment"` or `"house"`)
    - `num_residents` (number of residents living there)
    - `efficiency_level` (degree to which resident tries to save energy; for now simply 1 (efficient) or 2 (comfort) - later can be an index value or even float)
    - `username` \[optional\] (if report should be saved under a new user)

- Response structure:
    - Status:
        1. 200 - successful, standard JSON (see below)
        2. 404 - failure, resource not found (likely external API failure)
        3. 422 - problem with parameters / misc issue
    - Body: returns JSON data.  Typical structure:
        ```
        {
            nickname: <string>
            energy_consumption: <float>,
            cost: <float>
        }
        ```
        Notes: `nickname` should echo what the user entered; this is a simple additional confirmation / verification.  `energy_consumption` is measured by default in kWh and is annual (1 year).  `cost` is in dollars ($), and also annual.  LATER (after MVP, most likely): can return additional information, like more detailed location information, utility company / other factors, even carbon footprint, etc.
    - Additional notes: for now, this should only return one result.  Later, or if multiple utility companies exist in the area, it might return an array (like `{ [ <JSON> ] }`), but this would be post-MVP.


