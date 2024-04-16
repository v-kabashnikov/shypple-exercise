# Shypple Calculator Service

## Live

* [App](https://shypple-excercise-702fb1829242.herokuapp.com)

### API Endpoints

* PLS-0001: Return the cheapest direct sailing between origin port & destination port

```shell
GET /api/v1/sailings?origin_port=CNSHA&destination_port=NLRTM&strategy=cheapest&max_legs=1"

[
  {
    "origin_port": "CNSHA",
    "destination_port": "NLRTM",
    "departure_date": "2022-01-30",
    "arrival_date": "2022-03-05",
    "sailing_code": "MNOP",
    "rate": "456.78",
    "rate_currency": "USD"
  }
]
```

* WRT-0002: Return the cheapest sailing (direct or indirect)

```shell
GET /api/v1/sailings?origin_port=CNSHA&destination_port=NLRTM&strategy=cheapest"

[
  {
    "origin_port": "CNSHA",
    "destination_port": "ESBCN",
    "departure_date": "2022-01-29",
    "arrival_date": "2022-02-12",
    "sailing_code": "ERXQ",
    "rate": "261.96",
    "rate_currency": "EUR"
  },
  {
    "origin_port": "ESBCN",
    "destination_port": "NLRTM",
    "departure_date": "2022-02-16",
    "arrival_date": "2022-02-20",
    "sailing_code": "ETRG",
    "rate": "69.96",
    "rate_currency": "USD"
  }
]
```

* TST-0003: Return the fastest sailing legs (direct or indirect)

```shell
GET /api/v1/sailings?origin_port=CNSHA&destination_port=NLRTM&strategy=fastest"

[
  {
    "origin_port": "CNSHA",
    "destination_port": "NLRTM",
    "departure_date": "2022-01-29",
    "arrival_date": "2022-02-15",
    "sailing_code": "QRST",
    "rate": "761.96",
    "rate_currency": "EUR"
  }
]
```
### Implementation details

1. Implemented a GET endpoint that 
accepts `origin_port`, `destination_port`, `strategy`, and `max_legs` as optional parameters.
2. The `Search` service returns sailings as an array of legs based on input parameters. `max_legs` is currently used to distinguish between direct and indirect routes. In the future, it could easily limit search results to the desired amount of legs. The `strategy` parameter is used to retrieve only one result. The service is designed to serve all routes if no strategy is specified, which can be beneficial in the future. (Currently, this option is hidden from users by strategy presence validation.)
3. `CurrencyConverter` service is designed to convert various currencies to one standard currency. Currently, I have used US dollars, but in the future, the base currency can be set via parameters, as calculations are very sensitive.
4. `RouteFinder` Path finding algorithm is a crucial part of such applications. Since we don't have much data for now, I have decided to make it cleaner and more straightforward from a business perspective. Although this may not be the most efficient algorithm (depending on amount of data), this is a perfect candidate for benchmarking, to find an optimal solution based on data and upcoming business requirements.
5. `MapReduceClient` is a simple wrapper for reading data from a file.

### Things to improve

1. Change endpoint from GET to POST.
2. Move tests for specific tickets out from request unit tests to integration tests.
3. Use money library for `CurrencyConverter`.
4. Extract all strategies from `Search` service to separate classes.
5. Extract math actions from `RouteFinder` service into separate one.
6. Extract `CurrencyConverter` from sails and don't pass sails there.
7. Add serializers.
