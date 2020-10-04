namespace py currency_server

service CurrencyManager {
    double convert(1: string dst, 2: string src, 3: double value)
}