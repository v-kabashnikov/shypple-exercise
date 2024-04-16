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
### Things to improve

1. Change endpoint from GET to POST
2. Move tests for specific tickets out from request unit tests to integration tests
3. Use money library for currency convertation
4. Extract all strategies from search service to separate classes
5. Extract math actions from RouteFinder service into separate one
6. Add serializers
