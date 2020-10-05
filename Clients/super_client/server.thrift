namespace py country

struct Country {
    1: string name,
    2: i32 id = 0,
    3: string currency,
    4: string capital
}

service CountryManager {
    Country get_country(1: string name)
}

service CurrencyManager {
    double convert(1: string dst, 2: string src, 3: double value)
}
service TimeManager{
    i8 get_time(1: string country_1, 2: string country_2)
}