looppulse.web.simulator
=======================

Simulator for beacon events. It is currently supporting three modes:

0. fixed_debug
  -  A fixed and deterministic visitors routines will be generated.
  -  It doesn't connect with manager application.
  -  Sample config file: `server/settings.fixed.debug.sample.json`

1. continuous_debug
  -  Visitors will be generated continuosly
  -  It doesn't connect with manager application.
  -  Sample config file: `server/settings.continuous.debug.sample.json`

2. continuous_live
  -  Visitors will be generated continuosly
  -  It connects with a manager application.
  - Sample config file: `server/settings.continuous.live.sample.json`

Update config file:

0. fixed_debug
  -  `firebase` -> `root`: the firebase location receiving beacon_events generated by the simulator

1. continuous_debug
  -  `firebase` -> `root`: the firebase location receiving beacon_events/engagement_events generated by the simulator
  -  `engagementEvents` -> `firebaseURL`: the firebase location providing delivering_messages observed by the simulator
  -  `behaviour` -> simulation rules for visitor generation and behaviourial patterns. (More explanations below)

2. continuous_live
  -  `firebase` -> `config`: the firebase location providing beacon and product information.
  -  `application`: authentication path and token for the manager application.
  -  `engagementEvents` -> `firebaseURL`: the firebase location providing delivering_messages observed by the simulator
  -  `behaviour` -> simulation rules for visitor generation and behaviourial patterns. (More explanations below)

Simulation Rules

1. Terminologies
  - `VisitorType` specify a group of visitor, e.g. "Foodie"
  - `PeriodType` specify a type of time period, e.g. "MealTime", "RegularHours". A time period would include the proportion of visitor types, e.g. in "MealTime", there would be a lot more "Foodie" appears. It also contains the maximum number of visitors during that period.
  - `CategoryPreferences` specify the relative interests of the product categories of VisitorTypes. For example, a "Foodie" might have a higher tendency to visit "Food" product, and a lower tendency to visit "Kids" stuff.
  - `ProductPreferences` specify the relative interests of a particular product of VisitorTypes. For example, rather than having interests on a broader product category, a "McDonald Lover" might have a much higher tendency to visit "McDonald" product instead of other "Food" products.


2. How does it work
  1. Create a list of visitor types, each contains a set of category/product preferences. It also characterise the expected duration of staying in the product beacon. The duration is sampled with a normal distribution with mean and std (in seconds)
  2. Create a list of period types, each contains a set of "weights" correspond to the relative amount of visitor types being generated in that period.
  3. Define a day by splitting it into a sequence of periods. For example, from 12:00am to 7am is "RegularHours", 7am to 9am is "MealTime", so and so.

3. Sample configurations
  - `VisitorType`
    ```
    {
        "name": "Foodie",
        "stayTime": {
          "mean": 100,
          "std": 10
        },
        "categoryPreferences": [
          {
            "weight": 100,
            "categoryName": "Food"
          },
          {
            "weight": 2,
            "categoryName": "Kids"
          }
        ],
        "productPreferences": [
          {
            "productName": "Coco Curry House",
            "weight": 10
          }
        ]
    }
    ```
    Note: The default weight is 1.0 for all categories/products. So if no categoryPreferences are specified, then all categoreis are being picked equally likely. On the other than, a weight of 100 means it's 100 times more likely to being picked when compared to other items of weight 1.

  - `PeriodType`
    ```
    [
      {
        "name": "normal",
        "maxVisitors": 10,
        "visitors": [
          {
            "weight": 10,
            "visitorType": "Family"
          },
          {
            "weight": 100,
            "visitorType": "Foodie"
          }
        ]
      },
      {
        "name": "mealTime",
        "maxVisitors": 10,
        "visitors": [
          {
            "weight": 10,
            "visitorType": "Coco Lover"
          },
          {
            "weight": 1,
            "visitorType": "Family"
          }
        ]
      }
    ]
    ```

  - `Period`
    ```
    [
      {
        "startMin": 0,
        "endMin": 420,
        "periodType": "normal"
      },
      {
        "startMin": 420,
        "endMin": 540,
        "periodType": "mealTime"
      },
      {
        "startMin": 540,
        "endMin": 1440,
        "periodType": "normal"
      }
    ]
    ```

    Note: Currently, periods are specified in a daily basis (1440 minutes). The basic unit is minute. You would explicitly mention that from minute X to minute Y is a certain period. The above example would mean that from minute 420 to minute 540 of the day (i.e. 7am to 9am) would be mealTime. Other than that, it's normal time.

A detailed sample configuration file can be found under the `server` directory.

3. Notes
  - CategoryPreferences is currently not supported in `continuous_debug` mode.

Debugging:
  `URL="https://lp.firebaseio.com" SECRET="abc" node server/scripts/clear_firebase.js`
