const exec = require("cordova/exec")

const service = "EpsonTMPrinterService"

const api = {
    printReceipt: (props, success, error) => {
        const {printerSeries, lines, includeCustomerCopy = false} = props
        const args = [printerSeries, lines, includeCustomerCopy]

        exec(success, error, service, "printReceipt", args)
    },
    startPrinterSearch: () => {
        exec(null, null, service, "startPrinterSearch")
    },
    stopPrinterSearch: () => {
        exec(null, null, service, "stopPrinterSearch")
    },
}

const printerSeries = Object.freeze({
    m10: 0,
    m30: 1,
    P20: 2,
    P60: 3,
    P60II: 4,
    P80: 5,
    T20: 6,
    T60: 7,
    T70: 8,
    T81: 9,
    T82: 10,
    T83: 11,
    T88: 12,
    T90: 13,
    T90KP: 14,
    U220: 15,
    U330: 16,
    L90: 17,
    H6000: 18,
    T83III: 19,
    T100: 20,
})

module.exports = {
    ...api,
    ...printerSeries,
}